from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from datetime import timedelta

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import ArtifactTransaction
from .serializers import (
    ArtifactTransactionSerializer, TipSerializer,
    PurchaseArtifactsSerializer, WithdrawSerializer,
    GiftArtifactsSerializer, ARTIFACT_VALUES, ARTIFACT_LABELS,
    BUNDLES, PLATFORM_CUTS,
)
from apps.profiles.models import Profile


def _get_balance_dict(profile):
    return profile.artifact_balance or {
        'dumbbell': 0, 'barbell': 0, 'burpee': 0,
        'squat': 0, 'sprint': 0, 'pr': 0, 'champion': 0,
    }


def _deduct_artifacts(profile, artifact_type, quantity):
    balance = _get_balance_dict(profile)
    if balance.get(artifact_type, 0) < quantity:
        return False
    balance[artifact_type] -= quantity
    profile.artifact_balance = balance
    profile.save(update_fields=['artifact_balance'])
    return True


def _credit_artifacts(profile, artifact_type, quantity):
    balance = _get_balance_dict(profile)
    balance[artifact_type] = balance.get(artifact_type, 0) + quantity
    profile.artifact_balance = balance
    profile.save(update_fields=['artifact_balance'])


def _calculate_fiat(balance_dict, currency='KES'):
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


class PurchaseArtifactsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PurchaseArtifactsSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        artifact_type = data['artifact_type']
        quantity = data['quantity']
        fiat_amount = round(ARTIFACT_VALUES[artifact_type] * quantity, 2)

        if data.get('bundle') and data['bundle'] in BUNDLES:
            bundle = BUNDLES[data['bundle']]
            artifact_type = bundle['artifact']
            quantity = bundle['qty']
            fiat_amount = bundle['price']

        _credit_artifacts(request.user.profile, artifact_type, quantity)

        tx = ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='purchase',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='credit',
            status='completed',
            fiat_amount=fiat_amount,
            fiat_currency='KES',
            payment_provider=data['payment_method'],
            description=f'Purchased {quantity} {ARTIFACT_LABELS[artifact_type]}(s)',
        )

        return Response({
            'success': True,
            'data': {
                'transaction': ArtifactTransactionSerializer(tx).data,
                'new_balance': _get_balance_dict(request.user.profile),
            },
            'message': f'Purchased {quantity} {ARTIFACT_LABELS[artifact_type]}(s).',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


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
            transaction_type='tip_sent',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            counterparty=target,
            status='completed',
            description=f'Gifted {quantity} {ARTIFACT_LABELS[artifact_type]}(s) to @{target.username}',
        )

        ArtifactTransaction.objects.create(
            user=target,
            transaction_type='tip_received',
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

        tx = ArtifactTransaction.objects.create(
            user=profile,
            transaction_type='withdrawal',
            artifact_type=artifact_type,
            quantity=quantity,
            direction='debit',
            status='pending',
            fiat_amount=fiat_value,
            fiat_currency='KES',
            description=f'Withdrawal via {data["method"]}',
        )

        return Response({
            'success': True,
            'data': ArtifactTransactionSerializer(tx).data,
            'message': f'Withdrawal request submitted. Processing within 3–5 business days.',
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
