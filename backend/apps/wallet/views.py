import json
import logging
import uuid
from datetime import timedelta

from django.conf import settings
from django.db import transaction as db_transaction
from django.shortcuts import get_object_or_404
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
from .utils import (
    _get_profile_balance, _get_creator_balance, _get_total_balance,
    credit_artifacts, credit_creator_artifacts,
    platform_cut, calculate_fiat, reserve_withdrawal,
    transfer_artifacts,
)

logger = logging.getLogger(__name__)


class WalletBalanceView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        regular_balance = _get_profile_balance(profile)
        creator_balance = _get_creator_balance(profile)
        total_balance = _get_total_balance(profile)

        def to_list(bal):
            return [{
                'artifact_type': k,
                'label': ARTIFACT_LABELS.get(k, k),
                'quantity': v,
                'usd_value': round(ARTIFACT_VALUES.get(k, 0) * v, 2),
            } for k, v in bal.items() if v > 0]

        regular_list = to_list(regular_balance)
        creator_list = to_list(creator_balance)
        total_list = to_list(total_balance)

        regular_fiat = calculate_fiat(regular_balance)
        creator_fiat = calculate_fiat(creator_balance)
        total_fiat = calculate_fiat(total_balance)

        result = {
            'balance': total_list,
            'total_label': total_fiat['display'],
            'total_fiat': total_fiat['amount'],
            'fiat_currency': total_fiat['currency'],
            'regular_balance': regular_list,
            'regular_total_fiat': regular_fiat['amount'],
            'creator_balance': creator_list,
            'creator_total_fiat': creator_fiat['amount'],
            'creator_display_name': profile.creator_display_name or '',
        }
        return Response({
            'success': True,
            'data': result,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class CreatorWalletTransferView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile
        artifact_type = request.data.get('artifact_type')
        quantity = request.data.get('quantity')

        if not artifact_type or artifact_type not in ARTIFACT_VALUES:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid artifact type.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        try:
            quantity = int(quantity)
            if quantity <= 0:
                raise ValueError
        except (TypeError, ValueError):
            return Response({
                'success': False, 'data': None,
                'message': 'Quantity must be a positive integer.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        transfer = transfer_artifacts(
            profile, profile, artifact_type, quantity, source='creator',
            operation='creator_transfer',
            idempotency_key=request.headers.get('Idempotency-Key', ''),
            reference_id=f'creator-transfer:{profile.pk}:{artifact_type}:{quantity}',
        )
        if transfer is None:
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens in creator wallet.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        entry, created = transfer
        if not created:
            return Response({
                'success': True, 'data': {'journal_entry_id': str(entry.id)},
                'message': 'Already processed.', 'errors': None, 'pagination': None,
            })

        transfer_ref = f'ct_{uuid.uuid4().hex[:12]}'
        ArtifactTransaction.objects.create(
            user=profile,
            transaction_type='creator_transfer',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            status='completed',
            reference_id=transfer_ref,
            description='Transfer from creator wallet to regular wallet', journal_entry=entry,
        )
        ArtifactTransaction.objects.create(
            user=profile,
            transaction_type='creator_transfer',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='credit',
            status='completed',
            reference_id=transfer_ref,
            description='Transfer received in regular wallet from creator wallet', journal_entry=entry,
        )

        return Response({
            'success': True,
            'data': {
                'regular_balance': _get_profile_balance(profile),
                'creator_balance': _get_creator_balance(profile),
                'reference_id': transfer_ref,
            },
            'message': f'Transferred {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to regular wallet.',
            'errors': None,
            'pagination': None,
        })


class CreatorProfileView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        profile = request.user.profile
        display_name = request.data.get('creator_display_name', None)

        if display_name is not None:
            display_name = (display_name or '').strip()
            if display_name and (len(display_name) < 3 or len(display_name) > 50):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Creator display name must be between 3 and 50 characters.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            profile.creator_display_name = display_name
            profile.save(update_fields=['creator_display_name'])

        return Response({
            'success': True,
            'data': {
                'creator_display_name': profile.creator_display_name or '',
                'creator_balance': _get_creator_balance(profile),
            },
            'message': 'Creator profile updated.',
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
        count = qs.count()
        page = paginator.paginate_queryset(qs, request)
        serializer = ArtifactTransactionSerializer(page, many=True)

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
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
            payment_provider='flutterwave',
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
                    'new_balance': _get_profile_balance(request.user.profile),
                },
                'message': 'Already confirmed.',
                'errors': None, 'pagination': None,
            })

        fw = FlutterwaveClient()
        verification = fw.verify_transaction(data['flutterwave_id'])

        if verification.success and verification.data:
            verified_amount = float(verification.data.get('amount', 0))
            expected_amount = float(tx.fiat_amount)
            verified_ref = str(verification.data.get('tx_ref', ''))
            verified_currency = str(verification.data.get('currency', ''))
            if (abs(verified_amount - expected_amount) > 0.01
                    or verified_ref != tx.tx_ref
                    or (verified_currency and verified_currency != tx.fiat_currency)):
                tx.status = 'failed'
                tx.flutterwave_response = verification.data
                tx.save(update_fields=['status', 'flutterwave_response'])
                return Response({
                    'success': False, 'data': None,
                    'message': 'Amount mismatch. Transaction flagged.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)

            with db_transaction.atomic():
                tx = ArtifactTransaction.objects.select_for_update().get(pk=tx.pk)
                if tx.status != 'completed':
                    credit_artifacts(
                        request.user.profile, tx.artifact_type, tx.quantity,
                        idempotency_key=f'purchase:{tx.tx_ref}', reference_id=tx.tx_ref,
                    )
                    tx.status = 'completed'
                    tx.flutterwave_id = data['flutterwave_id']
                    tx.flutterwave_response = verification.data
                    tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])

            return Response({
                'success': True,
                'data': {
                    'transaction': ArtifactTransactionSerializer(tx).data,
                    'new_balance': _get_profile_balance(request.user.profile),
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
        import hmac as hmac_module
        from django.conf import settings
        from django.db import transaction as db_transaction

        expected_hash = getattr(settings, 'FLUTTERWAVE_WEBHOOK_HASH', '')
        signature = request.headers.get('verif-hash', '')
        # Fail closed: an unconfigured webhook secret must never accept events,
        # otherwise anyone could credit themselves free artifacts.
        if not expected_hash:
            logger.warning('Flutterwave webhook rejected: FLUTTERWAVE_WEBHOOK_HASH not configured')
            return Response(status=status.HTTP_503_SERVICE_UNAVAILABLE)
        if not signature or not hmac_module.compare_digest(str(signature), str(expected_hash)):
            logger.warning('Flutterwave webhook rejected: bad verif-hash')
            return Response(status=status.HTTP_403_FORBIDDEN)

        try:
            event = json.loads(request.body)
        except (json.JSONDecodeError, AttributeError):
            event = request.data

        event_type = event.get('event', '')
        event_data = event.get('data', {}) if isinstance(event.get('data'), dict) else {}

        if event_type == 'charge.completed':
            # Only credit payments Flutterwave marked successful and whose
            # amount matches the pending ledger entry.
            if str(event_data.get('status', '')).lower() != 'successful':
                return Response({'status': 'ignored'})
            tx_ref = event_data.get('tx_ref', '')
            flutterwave_id = str(event_data.get('id', ''))
            try:
                with db_transaction.atomic():
                    tx = ArtifactTransaction.objects.select_for_update().get(tx_ref=tx_ref, status='pending')
                    charged_amount = event_data.get('amount')
                    currency = event_data.get('currency')
                    amount_ok = True
                    try:
                        if charged_amount is not None and tx.fiat_amount is not None:
                            amount_ok = abs(float(charged_amount) - float(tx.fiat_amount)) < 0.01 \
                                and (not currency or not tx.fiat_currency or str(currency) == str(tx.fiat_currency))
                    except (TypeError, ValueError):
                        amount_ok = False
                    if not amount_ok:
                        logger.warning(
                            'Flutterwave webhook amount mismatch tx=%s charged=%s %s',
                            tx_ref, charged_amount, currency,
                        )
                        return Response({'status': 'mismatch'}, status=400)
                    credit_artifacts(
                        tx.user, tx.artifact_type, tx.quantity,
                        idempotency_key=f'purchase:{tx.tx_ref}', reference_id=tx.tx_ref,
                    )
                    tx.status = 'completed'
                    tx.flutterwave_id = flutterwave_id
                    tx.flutterwave_response = event_data
                    tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])
            except ArtifactTransaction.DoesNotExist:
                pass

        elif event_type == 'transfer.completed':
            flutterwave_id = str(event_data.get('id', ''))
            try:
                from .tasks import _complete_withdrawal
                with db_transaction.atomic():
                    tx = ArtifactTransaction.objects.select_for_update().get(
                        flutterwave_id=flutterwave_id, status='pending'
                    )
                    _complete_withdrawal(tx, event_data)
            except ArtifactTransaction.DoesNotExist:
                pass

        elif event_type in ('transfer.failed', 'transfer.cancelled', 'transfer.reversed'):
            flutterwave_id = str(event_data.get('id', ''))
            try:
                from .tasks import _refund_failed_withdrawal
                tx = ArtifactTransaction.objects.get(
                    flutterwave_id=flutterwave_id,
                    transaction_type='withdrawal',
                    status='pending',
                )
                tx.flutterwave_response = {
                    **(tx.flutterwave_response or {}),
                    'provider_event': event_data,
                }
                tx.save(update_fields=['flutterwave_response'])
                _refund_failed_withdrawal(tx, reason=event_type)
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
        source = data.get('source', 'regular')

        cut = platform_cut('tip', artifact_type, quantity)
        creator_qty = quantity - cut
        result = transfer_artifacts(
            request.user.profile, target, artifact_type, quantity,
            source=source, operation='tip',
            idempotency_key=request.headers.get('Idempotency-Key', ''),
            reference_id=f'tip:{request.user.profile.pk}:{target.pk}:{artifact_type}:{quantity}',
            platform_fee=cut,
        )
        if result is None:
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        entry, created = result
        if not created:
            return Response({
                'success': True, 'data': {'journal_entry_id': str(entry.id)},
                'message': 'Already processed.', 'errors': None, 'pagination': None,
            })

        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='tip_sent',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=target,
            status='completed',
            description=f'Tipped {ARTIFACT_LABELS[artifact_type]} to @{target.username} from {source} wallet', journal_entry=entry,
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
            description=f'Tip from @{request.user.profile.username}', journal_entry=entry,
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='platform_cut',
            artifact_type=artifact_type,
            quantity=cut,
            direction='debit',
            status='completed',
            description=f'Platform fee ({int(PLATFORM_CUTS["tip"] * 100)}%)', journal_entry=entry,
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
        source = data.get('source', 'regular')

        result = transfer_artifacts(
            request.user.profile, target, artifact_type, quantity,
            source=source, operation='gift',
            idempotency_key=request.headers.get('Idempotency-Key', ''),
            reference_id=f'gift:{request.user.profile.pk}:{target.pk}:{artifact_type}:{quantity}',
        )
        if result is None:
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        entry, created = result
        if not created:
            return Response({
                'success': True, 'data': {'journal_entry_id': str(entry.id)},
                'message': 'Already processed.', 'errors': None, 'pagination': None,
            })

        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='gift_sent',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=target,
            status='completed',
            description=f'Gifted {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to @{target.username} from {source} wallet', journal_entry=entry,
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='gift_received',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='credit',
            counterparty=request.user.profile,
            status='completed',
            description=f'Gift from @{request.user.profile.username}', journal_entry=entry,
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

        if profile.verification_status not in ('id', 'trainer', 'practitioner', 'shop', 'gym'):
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

        source = request.data.get('source', 'regular')
        method = data['method']

        # Validate destination details BEFORE deducting so a failed withdrawal can never strand funds.
        if method == 'bank_transfer':
            if not data.get('bank_account') or not data.get('bank_code'):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Bank account and bank code required for bank transfer.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        tx_ref = f'bw-{uuid.uuid4().hex[:12]}'
        tx = reserve_withdrawal(
            profile,
            source=source,
            artifact_type=artifact_type,
            quantity=quantity,
            fiat_amount=round(fiat_value * getattr(settings, 'KES_PER_USD', 129.5), 2),
            fiat_currency='KES',
            phone_number=data.get('phone_number', ''),
            bank_account=data.get('bank_account', ''),
            tx_ref=tx_ref,
            idempotency_key=request.headers.get('Idempotency-Key') or tx_ref,
            method=method,
        )
        if tx is None:
            wallet_label = 'creator wallet' if source == 'creator' else 'wallet'
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {ARTIFACT_LABELS[artifact_type]} tokens in {wallet_label}.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        tx.flutterwave_response = {
            **(tx.flutterwave_response or {}),
            'usd_value': fiat_value,
        }
        tx.save(update_fields=['flutterwave_response'])

        if method == 'bank_transfer':
            bank_account = data.get('bank_account', '')
            bank_code = data.get('bank_code', '')
            account_name = data.get('account_name', '')

            fw = FlutterwaveClient()
            recipient_resp = fw.create_transfer_recipient(
                bank_code=bank_code,
                account_number=bank_account,
                name=account_name or 'BuddyUp User',
            )

            if recipient_resp.success and recipient_resp.data:
                recipient_id = recipient_resp.data.get('id')
                transfer_resp = fw.initiate_transfer(recipient_id, float(tx.fiat_amount))
                tx.flutterwave_id = transfer_resp.flutterwave_ref or ''
                tx.flutterwave_response = {
                    'wallet_source': source,
                    'usd_value': fiat_value,
                    'initiation': transfer_resp.data,
                }

                if transfer_resp.success:
                    # Initiated is not settled: completion only comes from a
                    # signed provider webhook or reconciliation result.
                    tx.description = 'Bank withdrawal submitted; awaiting provider confirmation'
                    tx.save(update_fields=['description', 'flutterwave_id', 'flutterwave_response'])
                    from .tasks import process_withdrawal
                    process_withdrawal.delay(str(tx.id))
                    return Response({
                        'success': True,
                        'data': ArtifactTransactionSerializer(tx).data,
                        'message': f'Withdrawal submitted for {account_name}; settlement is pending provider confirmation.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_201_CREATED)
                else:
                    tx.status = 'failed'
                    tx.save(update_fields=['status', 'flutterwave_id', 'flutterwave_response'])
                    if source == 'creator':
                        credit_creator_artifacts(profile, artifact_type, quantity)
                    else:
                        credit_artifacts(profile, artifact_type, quantity)
                    return Response({
                        'success': False, 'data': None,
                        'message': transfer_resp.message or 'Transfer failed. Funds returned to balance.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_402_PAYMENT_REQUIRED)
            else:
                tx.status = 'failed'
                tx.flutterwave_response = recipient_resp.data
                tx.save(update_fields=['status', 'flutterwave_response'])
                if source == 'creator':
                    credit_creator_artifacts(profile, artifact_type, quantity)
                else:
                    credit_artifacts(profile, artifact_type, quantity)
                return Response({
                    'success': False, 'data': None,
                    'message': recipient_resp.message or 'Could not create recipient.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        # Defensive fallback; serializer currently permits bank transfer only.
        return Response({
            'success': False, 'data': None,
            'message': 'No supported payout provider was selected.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


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


class PayoutRequestView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = request.user.profile

        if profile.verification_status not in ('id', 'trainer', 'practitioner', 'shop', 'gym'):
            return Response({
                'success': False, 'data': None,
                'message': 'ID verification is required before requesting payouts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        # This endpoint previously deducted a mixture of creator artifacts and
        # then marked the payout as successful without a provider settlement.
        # Keep the unsafe legacy route closed until the payout service has a
        # double-entry settlement account and verified provider callback.
        return Response({
            'success': False,
            'data': None,
            'message': 'Creator cash payouts are temporarily disabled while settlement reconciliation is finalized.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class PayoutHistoryView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = ArtifactTransaction.objects.filter(
            user=request.user.profile,
            transaction_type__in=['withdrawal', 'payout'],
        ).order_by('-created_at')

        paginator = CursorPagination()
        count = qs.count()
        page = paginator.paginate_queryset(qs, request)
        serializer = ArtifactTransactionSerializer(page, many=True)

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'pagination': {
                'count': count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })
