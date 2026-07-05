import json
import uuid
from datetime import timedelta

from django.shortcuts import get_object_or_404
from django.db import models as db_models, transaction
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import ArtifactTransaction
from .serializers import (
    ArtifactTransactionSerializer, TipSerializer,
    InitializePurchaseSerializer, ConfirmPurchaseSerializer,
    BankResolveSerializer, WithdrawSerializer,
    GiftArtifactsSerializer, ARTIFACT_VALUES, ARTIFACT_LABELS,
    BUNDLES, PLATFORM_CUTS,
)
from apps.profiles.models import Profile
from .flutterwave import FlutterwaveClient


def _get_balance_dict(profile):
    return profile.artifact_balance or {
        'dumbbell': 0, 'barbell': 0, 'burpee': 0,
        'squat': 0, 'sprint': 0, 'pr': 0, 'champion': 0,
    }


def _deduct_artifacts(profile, artifact_type, quantity):
    from .models import Profile as ProfileModel
    with transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref)
        if balance.get(artifact_type, 0) < quantity:
            return False
        balance[artifact_type] -= quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])
    return True


def _credit_artifacts(profile, artifact_type, quantity):
    from .models import Profile as ProfileModel
    with transaction.atomic():
        profile_ref = ProfileModel.objects.select_for_update().get(pk=profile.pk)
        balance = _get_balance_dict(profile_ref)
        balance[artifact_type] = balance.get(artifact_type, 0) + quantity
        profile_ref.artifact_balance = balance
        profile_ref.save(update_fields=['artifact_balance'])


def _calculate_fiat(balance_dict, currency='USD'):
    total = sum(ARTIFACT_VALUES.get(k, 0) * v for k, v in balance_dict.items())
    return {
        'amount': round(total, 2),
        'currency': currency,
        'display': f'{currency} {total:,.2f}',
    }


def _platform_cut(transaction_type, artifact_type, quantity):
    rate = PLATFORM_CUTS.get(transaction_type, 0.20)
    cut_qty = max(1, int(quantity * rate))
    return cut_qty


class WalletBalanceView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        balance = _get_balance_dict(request.user.profile)

        balance_list = [{
            'artifact_type': k,
            'label': ARTIFACT_LABELS.get(k, k),
            'quantity': v,
            'usd_value': round(ARTIFACT_VALUES.get(k, 0) * v, 2),
        } for k, v in balance.items()]

        fiat = _calculate_fiat(balance)

        return Response({
            'success': True,
            'data': {
                'balance': balance_list,
                'total_label': fiat['display'],
                'total_fiat': fiat['amount'],
                'fiat_currency': fiat['currency'],
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class TransactionHistoryView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tx_type = request.query_params.get('type', '')
        direction = request.query_params.get('direction', '')

        qs = ArtifactTransaction.objects.filter(
            user=request.user.profile,
        ).order_by('-created_at')

        if tx_type:
            qs = qs.filter(transaction_type=tx_type)
        if direction:
            qs = qs.filter(direction=direction)

        paginator = CursorPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = ArtifactTransactionSerializer(page, many=True)

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class InitializePurchaseView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = InitializePurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        artifact_type = data['artifact_type']
        quantity = data['quantity']
        payment_method = data['payment_method']
        fiat_amount = round(ARTIFACT_VALUES[artifact_type] * quantity, 2)

        if data.get('bundle') and data['bundle'] in BUNDLES:
            bundle = BUNDLES[data['bundle']]
            artifact_type = bundle['artifact']
            quantity = bundle['qty']
            fiat_amount = bundle['price']

        tx_ref = f'bp-{uuid.uuid4().hex[:12]}'

        tx = ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='purchase',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='credit',
            status='pending',
            fiat_amount=fiat_amount,
            fiat_currency='USD',
            payment_provider=payment_method,
            tx_ref=tx_ref,
            description=f'Purchase {quantity} {ARTIFACT_LABELS[artifact_type]}(s)',
        )

        from django.conf import settings
        fw = FlutterwaveClient()

        if payment_method == 'mpesa':
            phone = data.get('mpesa_phone', '')
            if not phone:
                tx.status = 'failed'
                tx.save(update_fields=['status'])
                return Response({
                    'success': False, 'data': None,
                    'message': 'M-Pesa phone number is required.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

            flutterwave_resp = fw.mpesa_stk_push(phone, fiat_amount, tx_ref, request.user.email)
            tx.flutterwave_id = flutterwave_resp.flutterwave_ref or ''
            tx.flutterwave_response = flutterwave_resp.data
            tx.save(update_fields=['flutterwave_id', 'flutterwave_response'])

            if flutterwave_resp.success or flutterwave_resp.status == 'pending':
                return Response({
                    'success': True,
                    'data': {
                        'tx_ref': tx_ref,
                        'flutterwave_ref': flutterwave_resp.flutterwave_ref,
                        'status': flutterwave_resp.status,
                        'public_key': settings.FLUTTERWAVE_PUBLIC_KEY,
                    },
                    'message': 'M-Pesa payment prompt sent. Complete on your phone.',
                    'errors': None, 'pagination': None,
                })
            else:
                tx.status = 'failed'
                tx.save(update_fields=['status'])
                return Response({
                    'success': False, 'data': None,
                    'message': flutterwave_resp.message or 'M-Pesa payment initiation failed.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)

        elif payment_method == 'card':
            return Response({
                'success': True,
                'data': {
                    'tx_ref': tx_ref,
                    'amount': fiat_amount,
                    'currency': 'USD',
                    'public_key': settings.FLUTTERWAVE_PUBLIC_KEY,
                    'customer_email': request.user.email,
                    'customer_name': request.user.profile.display_name,
                },
                'message': 'Card payment initialized. Complete via Flutterwave checkout.',
                'errors': None, 'pagination': None,
            })

        return Response({
            'success': True,
            'data': {
                'tx_ref': tx_ref,
                'public_key': settings.FLUTTERWAVE_PUBLIC_KEY,
            },
            'message': 'Payment initialized.',
            'errors': None, 'pagination': None,
        })


class ConfirmPurchaseView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ConfirmPurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        tx = get_object_or_404(ArtifactTransaction, tx_ref=data['tx_ref'], user=request.user.profile)

        if tx.status == 'completed':
            return Response({
                'success': True, 'data': {
                    'transaction': ArtifactTransactionSerializer(tx).data,
                    'new_balance': _get_balance_dict(request.user.profile),
                },
                'message': 'Already confirmed.',
                'errors': None, 'pagination': None,
            })

        fw = FlutterwaveClient()
        verification = fw.verify_transaction(data['flutterwave_id'])

        if verification.success and verification.data:
            verified_amount = float(verification.data.get('amount', 0))
            expected_amount = float(tx.fiat_amount)
            if abs(verified_amount - expected_amount) > 0.01:
                tx.status = 'failed'
                tx.flutterwave_response = verification.data
                tx.save(update_fields=['status', 'flutterwave_response'])
                return Response({
                    'success': False, 'data': None,
                    'message': 'Amount mismatch. Transaction flagged.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)

            _credit_artifacts(request.user.profile, tx.artifact_type, tx.quantity)
            tx.status = 'completed'
            tx.flutterwave_id = data['flutterwave_id']
            tx.flutterwave_response = verification.data
            tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])

            return Response({
                'success': True,
                'data': {
                    'transaction': ArtifactTransactionSerializer(tx).data,
                    'new_balance': _get_balance_dict(request.user.profile),
                },
                'message': f'Purchased {tx.quantity} {ARTIFACT_LABELS.get(tx.artifact_type, tx.artifact_type)}(s).',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_201_CREATED)

        tx.status = 'failed'
        tx.flutterwave_response = verification.data if verification.data else {'error': verification.message}
        tx.save(update_fields=['status', 'flutterwave_response'])

        return Response({
            'success': False, 'data': None,
            'message': verification.message or 'Payment verification failed.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_402_PAYMENT_REQUIRED)


class BankListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        country = request.query_params.get('country', 'KE')
        fw = FlutterwaveClient()
        resp = fw.get_banks(country)
        if resp.success and resp.data:
            banks = [{'code': b['code'], 'name': b['name']} for b in resp.data if b.get('code') and b.get('name')]
            return Response({
                'success': True, 'data': banks,
                'message': 'OK', 'errors': None, 'pagination': None,
            })
        return Response({
            'success': True, 'data': [],
            'message': 'No banks found.', 'errors': None, 'pagination': None,
        })


class BankResolveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = BankResolveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        fw = FlutterwaveClient()
        resp = fw.resolve_account(data['account_number'], data['bank_code'])
        if resp.success and resp.data:
            return Response({
                'success': True,
                'data': {
                    'account_number': data['account_number'],
                    'bank_code': data['bank_code'],
                    'account_name': resp.data.get('account_name', ''),
                },
                'message': 'Account resolved.',
                'errors': None, 'pagination': None,
            })
        return Response({
            'success': False, 'data': None,
            'message': resp.message or 'Could not resolve account.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_400_BAD_REQUEST)


@method_decorator(csrf_exempt, name='dispatch')
class FlutterwaveWebhookView(views.APIView):
    permission_classes = []

    def post(self, request):
        from django.conf import settings
        signature = request.headers.get('verif-hash', '')
        if settings.FLUTTERWAVE_WEBHOOK_HASH and signature != settings.FLUTTERWAVE_WEBHOOK_HASH:
            return Response(status=status.HTTP_403_FORBIDDEN)

        try:
            event = json.loads(request.body)
        except (json.JSONDecodeError, AttributeError):
            event = request.data

        event_type = event.get('event', '')
        event_data = event.get('data', {})

        if event_type == 'charge.completed':
            tx_ref = event_data.get('tx_ref', '')
            flutterwave_id = str(event_data.get('id', ''))
            try:
                tx = ArtifactTransaction.objects.get(tx_ref=tx_ref, status='pending')
                tx.status = 'completed'
                tx.flutterwave_id = flutterwave_id
                tx.flutterwave_response = event_data
                tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])
                _credit_artifacts(tx.user, tx.artifact_type, tx.quantity)
            except ArtifactTransaction.DoesNotExist:
                pass

        elif event_type == 'transfer.completed':
            flutterwave_id = str(event_data.get('id', ''))
            try:
                tx = ArtifactTransaction.objects.get(flutterwave_id=flutterwave_id, status='pending')
                tx.status = 'completed'
                tx.flutterwave_response = event_data
                tx.save(update_fields=['status', 'flutterwave_response'])
            except ArtifactTransaction.DoesNotExist:
                pass

        return Response({'status': 'ok'})


class TipUserView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TipSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        target = get_object_or_404(Profile, username=data['username'])
        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot tip yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        artifact_type = data['artifact_type']
        quantity = data['quantity']

        if not _deduct_artifacts(request.user.profile, artifact_type, quantity):
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        cut = _platform_cut('tip', artifact_type, quantity)
        creator_qty = quantity - cut

        _credit_artifacts(target, artifact_type, creator_qty)

        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='tip_sent',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=target,
            status='completed',
            description=f'Tipped {ARTIFACT_LABELS[artifact_type]} to @{target.username}',
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='tip_received',
            artifact_type=artifact_type,
            quantity=creator_qty,
            direction='credit',
            counterparty=request.user.profile,
            status='completed',
            clearance_at=timezone.now() + timedelta(days=7),
            description=f'Tip from @{request.user.profile.username}',
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='platform_cut',
            artifact_type=artifact_type,
            quantity=cut,
            direction='debit',
            status='completed',
            description=f'Platform fee ({int(PLATFORM_CUTS["tip"] * 100)}%)',
        )

        return Response({
            'success': True,
            'data': None,
            'message': f'Tipped {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to @{target.username}!',
            'errors': None,
            'pagination': None,
        })


class GiftArtifactsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = GiftArtifactsSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        target = get_object_or_404(Profile, username=data['username'])
        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot gift artifacts to yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        artifact_type = data['artifact_type']
        quantity = data['quantity']

        if not _deduct_artifacts(request.user.profile, artifact_type, quantity):
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        _credit_artifacts(target, artifact_type, quantity)

        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='gift_sent',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=target,
            status='completed',
            description=f'Gifted {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to @{target.username}',
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='gift_received',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='credit',
            counterparty=request.user.profile,
            status='completed',
            description=f'Gift from @{request.user.profile.username}',
        )

        return Response({
            'success': True,
            'data': None,
            'message': f'Gifted {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to @{target.username}!',
            'errors': None,
            'pagination': None,
        })


class WithdrawView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = WithdrawSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        profile = request.user.profile

        if profile.verification_status not in ('id', 'trainer', 'practitioner'):
            return Response({
                'success': False, 'data': None,
                'message': 'ID verification is required before withdrawing.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        artifact_type = data['artifact_type']
        quantity = data['quantity']

        fiat_value = round(ARTIFACT_VALUES[artifact_type] * quantity, 2)
        if fiat_value < 10.00:
            return Response({
                'success': False, 'data': None,
                'message': 'Minimum withdrawal is $10.00 equivalent.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not _deduct_artifacts(profile, artifact_type, quantity):
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        method = data['method']
        tx_ref = f'bw-{uuid.uuid4().hex[:12]}'
        tx = ArtifactTransaction.objects.create(
            user=profile,
            transaction_type='withdrawal',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            status='pending' if method == 'bank_transfer' else 'completed',
            fiat_amount=fiat_value,
            fiat_currency='USD',
            phone_number=data.get('phone_number', ''),
            bank_account=data.get('bank_account', ''),
            tx_ref=tx_ref,
            description=f'Withdrawal via {method}',
        )

        if method == 'bank_transfer':
            bank_account = data.get('bank_account', '')
            bank_code = data.get('bank_code', '')
            account_name = data.get('account_name', '')

            if not bank_account or not bank_code:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Bank account and bank code required for bank transfer.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

            fw = FlutterwaveClient()
            recipient_resp = fw.create_transfer_recipient(
                bank_code=bank_code,
                account_number=bank_account,
                name=account_name or 'BuddyUp User',
            )

            if recipient_resp.success and recipient_resp.data:
                recipient_id = recipient_resp.data.get('id')
                transfer_resp = fw.initiate_transfer(recipient_id, fiat_value)
                tx.flutterwave_id = transfer_resp.flutterwave_ref or ''
                tx.flutterwave_response = transfer_resp.data

                if transfer_resp.success:
                    tx.status = 'completed'
                    tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])
                    return Response({
                        'success': True,
                        'data': ArtifactTransactionSerializer(tx).data,
                        'message': f'Withdrawal of {quantity} {ARTIFACT_LABELS[artifact_type]}(s) sent to {account_name}.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_201_CREATED)
                else:
                    tx.status = 'failed'
                    tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])
                    _credit_artifacts(profile, artifact_type, quantity)
                    return Response({
                        'success': False, 'data': None,
                        'message': transfer_resp.message or 'Transfer failed. Funds returned to balance.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_402_PAYMENT_REQUIRED)
            else:
                tx.status = 'failed'
                tx.flutterwave_response = recipient_resp.data
                tx.save(update_fields=['status', 'flutterwave_response'])
                _credit_artifacts(profile, artifact_type, quantity)
                return Response({
                    'success': False, 'data': None,
                    'message': recipient_resp.message or 'Could not create recipient.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'success': True,
            'data': ArtifactTransactionSerializer(tx).data,
            'message': f'Withdrawal of {quantity} {ARTIFACT_LABELS[artifact_type]}(s) processed successfully.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class BundleListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        bundles = [{
            'id': key,
            'artifact_type': v['artifact'],
            'artifact_label': ARTIFACT_LABELS[v['artifact']],
            'quantity': v['qty'],
            'price_usd': v['price'],
            'savings': round((ARTIFACT_VALUES[v['artifact']] * v['qty']) - v['price'], 2),
        } for key, v in BUNDLES.items()]

        return Response({
            'success': True,
            'data': bundles,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ExchangeRateView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({
            'success': True,
            'data': {
                'rates': ARTIFACT_VALUES,
                'base_currency': 'USD',
                'local_currency': 'KES',
                'conversion_rate': 129.5,
                'labels': ARTIFACT_LABELS,
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })
