"""Verification-tier checkout, activation, cancellation and webhooks.

The gym tier is a recurring monthly charge in the gym's local currency
(USD default, KES for Kenyan gyms — see ``tier_pricing.py``). Checkout uses
the Flutterwave inline widget exactly like artifact purchases; if we can
create a payment plan for the (tier, currency) pair, the inline checkout
gets ``payment_plan`` attached and Flutterwave bills the card monthly on
its own. If the PSP plan cannot be created (network error, keys missing),
the member sees a one-time charge and must renew manually each month — the
``currency``/``amount_minor`` are then honoured as a per-cycle payment.

Upgrade: immediate on verify (gym.tier flips immediately, badge colour
changes). Downgrade: after the paid period ends, a daily sweep gives 7-day
grace with reminders on days 3, 5 and 6, then flips the gym back to
``regular``. Existing members never get kicked out; the member cap only
blocks *new* joins.
"""

import datetime
import json
import logging
from uuid import uuid4

from django.db import transaction
from django.utils import timezone
from rest_framework import views, status, permissions
from rest_framework.response import Response

from . import capacity, tier_pricing
from .models import Gym, GymMembership, GymTierSubscription, GymTierPlan

logger = logging.getLogger(__name__)


def _owner_gym(request, gym_slug) -> tuple[Gym, GymMembership | None]:
    gym = Gym.objects.filter(handle__iexact=gym_slug).first()
    if gym is None:
        return None, None
    logger.debug('tier checkout %s gym=%s', gym_slug, gym.handle)
    membership = GymMembership.objects.filter(
        gym=gym, member=request.user.profile,
        role__in=['owner'],
    ).first()
    return gym, membership


def _subscription_payload(sub, gym):
    return {
        'tier': gym.tier,
        'status': 'regular' if gym.tier == 'regular' else sub.status,
        'current_period_end': sub.current_period_end.isoformat() if sub.current_period_end else None,
        'grace_deadline': sub.grace_deadline.isoformat() if sub.grace_deadline else None,
        'auto_renew': sub.auto_renew,
        'currency': sub.currency,
        'amount_minor': sub.amount_minor,
        'capacity': capacity.capacity_status(gym),
    }


class TierOverviewView(views.APIView):
    """GET /gyms/<slug>/tier/ — status + locally-priced plans for all tiers."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        currency = tier_pricing.currency_for_country(gym.location_country)
        plans = {
            tier: {
                'tier': tier,
                'amount_minor': tier_pricing.price_for(tier, gym.location_country)[1],
                'currency': currency,
                'cap': capacity.member_cap_for_tier(tier),
            }
            for tier in ('regular', 'midlevel', 'executive')
        }
        try:
            sub = gym.tier_subscription
        except GymTierSubscription.DoesNotExist:
            sub = GymTierSubscription(gym=gym, tier='regular', status='active',
                                      currency='USD', amount_minor=0)
        logger.info('tier overview gym=%s currency=%s country=%s',
                    gym.handle, currency, gym.location_country)
        return Response({
            'success': True,
            'data': {
                'subscription': _subscription_payload(sub, gym),
                'plans': plans,
                'country': (gym.location_country or '').strip().upper()[:2],
                'currency': currency,
            },
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class TierCheckoutView(views.APIView):
    """POST {tier, method} — prepare the Flutterwave checkout for an upgrade."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        tier = (request.data.get('tier') or '').strip().lower()
        if tier not in ('midlevel', 'executive'):
            return Response({'success': False, 'message': 'tier must be midlevel or executive (regular is free).'},
                            status=status.HTTP_400_BAD_REQUEST)

        currency = tier_pricing.currency_for_country(gym.location_country)
        plan = tier_pricing.seeded_plan(tier, currency)
        tx_ref = f'tier-{uuid4().hex[:12]}'

        sub, _ = GymTierSubscription.objects.get_or_create(gym=gym,
                                defaults={'tier': 'regular', 'currency': 'USD', 'amount_minor': 0})
        sub.tier = tier
        sub.currency = currency
        sub.amount_minor = plan.amount_minor
        sub.flutterwave_tx_ref = tx_ref
        sub.save()

        response_data = {
            'tx_ref': tx_ref,
            'amount': round(plan.amount_minor / 100.0, 2),
            'currency': currency,
            'tier': tier,
            'country': (gym.location_country or '').strip().upper()[:2],
            'public_key': __import__('django.conf', fromlist=['settings']).settings.FLUTTERWAVE_PUBLIC_KEY,
            'customer_email': request.user.email,
            'customer_name': request.user.profile.display_name,
        }

        method = (request.data.get('method') or 'card').lower()

        # Best effort: create the recurring payment plan so the card bills
        # monthly automatically. Failure just means "pay monthly by hand".
        if method == 'card':
            plan_id = self._ensure_payment_plan(tier, currency, plan)
            response_data['payment_plan'] = plan_id
            sub.flutterwave_subscription_id = plan_id or ''
            sub.save(update_fields=['flutterwave_subscription_id'])
            return Response({
                'success': True, 'data': response_data,
                'message': 'Card payment initialised.', 'errors': None, 'pagination': None,
            })

        if method == 'mpesa':
            phone = (request.data.get('mpesa_phone') or '').strip()
            if not phone:
                return Response({'success': False, 'message': 'mpesa_phone is required.'},
                                status=status.HTTP_400_BAD_REQUEST)
            from apps.wallet.flutterwave import FlutterwaveClient
            fw = FlutterwaveClient()
            push = fw.mpesa_stk_push(phone, response_data['amount'], tx_ref, request.user.email)
            sub.flutterwave_tx_ref = tx_ref
            sub.save(update_fields=['flutterwave_tx_ref'])
            return Response({
                'success': push.success or push.status == 'pending',
                'data': {'tx_ref': tx_ref, 'amount': response_data['amount'], 'currency': currency,
                         'flutterwave_ref': push.flutterwave_ref, 'status': push.status},
                'message': push.message or 'M-Pesa prompt sent.', 'errors': None, 'pagination': None,
            }, status=status.HTTP_200_OK if push.success else status.HTTP_402_PAYMENT_REQUIRED)

        return Response({'success': False, 'message': 'method must be card or mpesa.'},
                        status=status.HTTP_400_BAD_REQUEST)

    def _ensure_payment_plan(self, tier, currency, plan):
        if plan.flutterwave_plan_id:
            return plan.flutterwave_plan_id
        from apps.wallet.flutterwave import FlutterwaveClient
        try:
            fw = FlutterwaveClient()
            created = fw._request('POST', 'payment-plans', json={
                'name': f'BuddyUp {tier} tier ({currency})',
                'amount': int(plan.amount_minor / 100),
                'interval': 'monthly',
                'duration': 0,
                'description': f'BuddyUp Fit {tier} verification tier',
                'currency': currency,
            })
            if created.success and isinstance(created.data, dict):
                pid = str(created.data.get('id') or created.flutterwave_ref or '')
                if pid:
                    plan.flutterwave_plan_id = pid
                    plan.save(update_fields=['flutterwave_plan_id'])
                    return pid
        except Exception:  # noqa: BLE001 — recurring is optional; fall back to manual renewals
            logger.warning('Flutterwave payment plan creation failed for %s/%s', tier, currency)
        return ''


class TierConfirmView(views.APIView):
    """POST {tx_ref, flutterwave_id} — verify and activate the tier upgrade."""

    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        tx_ref = (request.data.get('tx_ref') or '').strip()
        flutterwave_id = str(request.data.get('flutterwave_id') or '')
        if not tx_ref or not flutterwave_id:
            return Response({'success': False, 'message': 'tx_ref and flutterwave_id are required.'},
                            status=status.HTTP_400_BAD_REQUEST)

        sub = GymTierSubscription.objects.filter(gym=gym, flutterwave_tx_ref=tx_ref)
        sub = sub.select_for_update().first()
        if sub is None:
            return Response({'success': False, 'message': 'Unknown tx_ref for this gym.'},
                            status=status.HTTP_404_NOT_FOUND)
        if sub.status == GymTierSubscription.ACTIVE and sub.current_period_end and sub.current_period_end > timezone.now():
            pass  # already confirmed; extend idempotently

        from apps.wallet.flutterwave import FlutterwaveClient
        verification = FlutterwaveClient().verify_transaction(flutterwave_id)
        data = verification.data or {}
        paid_ok = verification.success and str(data.get('status', '')).lower() in ('successful', 'succeeded') and \
            str(data.get('currency', '')).upper() == sub.currency and \
            float(data.get('amount') or 0) >= sub.amount_minor / 100.0
        if not paid_ok:
            return Response({
                'success': False,
                'message': verification.message or 'Payment could not be verified.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_402_PAYMENT_REQUIRED)

        now = timezone.now()
        base = sub.current_period_end if sub.current_period_end and sub.current_period_end > now else now
        sub.current_period_end = base + datetime.timedelta(days=30)
        sub.status = GymTierSubscription.ACTIVE
        sub.grace_deadline = None
        sub.auto_renew = bool(sub.flutterwave_subscription_id)
        sub.save()

        gym.tier = sub.tier
        gym.save(update_fields=['tier', 'updated_at'])

        return Response({
            'success': True,
            'data': {
                'tier': gym.tier,
                'current_period_end': sub.current_period_end.isoformat(),
                'auto_renew': sub.auto_renew,
            },
            'message': f'{sub.tier} verified. Badge upgraded and capacity raised.',
            'errors': None, 'pagination': None,
        })


class TierCancelView(views.APIView):
    """POST — stop auto-renew; the tier downgrades after the paid period."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym, membership = _owner_gym(request, gym_slug)
        if gym is None or membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        sub, _ = GymTierSubscription.objects.get_or_create(gym=gym)
        sub.auto_renew = False
        sub.save(update_fields=['auto_renew'])
        return Response({
            'success': True,
            'data': _subscription_payload(sub, gym),
            'message': 'Future charges cancelled. Your tier stays until the paid period ends.',
            'errors': None, 'pagination': None,
        })


class TierWebhookView(views.APIView):
    """Flutterwave events for tier subscriptions and renewals."""

    permission_classes = []

    def post(self, request):
        import hmac as hmac_module
        from django.conf import settings

        expected_hash = getattr(settings, 'FLUTTERWAVE_WEBHOOK_HASH', '')
        signature = request.headers.get('verif-hash', '')
        if not expected_hash:
            logger.warning('tier webhook rejected: FLUTTERWAVE_WEBHOOK_HASH not configured')
            return Response(status=status.HTTP_503_SERVICE_UNAVAILABLE)
        if not signature or not hmac_module.compare_digest(str(signature), str(expected_hash)):
            logger.warning('tier webhook rejected: bad verif-hash')
            return Response(status=status.HTTP_403_FORBIDDEN)

        try:
            event = json.loads(request.body)
        except (json.JSONDecodeError, AttributeError):
            event = request.data

        event_type = event.get('event', '')
        data = event.get('data', {}) if isinstance(event.get('data'), dict) else {}
        tx_ref = str(data.get('tx_ref', '') or data.get('txRef', '') or '')
        payment_plan = str(data.get('payment_plan', '') or data.get('paymentPlan', '') or '')
        customer = data.get('customer') if isinstance(data.get('customer'), dict) else {}
        customer_email = str(customer.get('email', '') or '').lower()

        sub = None
        if tx_ref.startswith('tier-'):
            sub = GymTierSubscription.objects.filter(flutterwave_tx_ref=tx_ref).select_related('gym').first()
        elif payment_plan:
            # Recurring charge from the payment plan: match plan + owner email.
            matches = GymTierSubscription.objects.filter(flutterwave_subscription_id=payment_plan).select_related('gym')
            for candidate in matches:
                emails = list(
                    GymMembership.objects.filter(gym=candidate.gym, role='owner')
                    .select_related('member').values_list('member__user__email', flat=True)
                )
                if emails and any(e and e.lower() == customer_email for e in emails):
                    sub = candidate
                    break

        if sub is None:
            return Response({'status': 'ignored'})

        if event_type == 'charge.completed' and str(data.get('status', '')).lower() in ('successful', 'succeeded'):
            now = timezone.now()
            base = sub.current_period_end if sub.current_period_end and sub.current_period_end > now else now
            sub.current_period_end = base + datetime.timedelta(days=30)
            sub.status = GymTierSubscription.ACTIVE
            sub.grace_deadline = None
            sub.save()
            gym = sub.gym
            gym.tier = sub.tier
            gym.save(update_fields=['tier', 'updated_at'])
            return Response({'status': 'ok'})

        if event_type in ('subscription.cancelled', 'subscription.expired'):
            sub.status = GymTierSubscription.CANCELLED
            sub.grace_deadline = None
            sub.save()
            gym = sub.gym
            if gym.tier != 'regular':
                gym.tier = 'regular'
                gym.save(update_fields=['tier', 'updated_at'])
            from apps.notifications.tasks import _deliver_notification
            for owner in GymMembership.objects.filter(gym=gym, role='owner', subscription_active=True):
                _deliver_notification(
                    str(owner.member.user_id), 'gym_tier_cancelled',
                    f'{gym.name} verification tier ended',
                    'Your tier ended, so new members may not join past the free Regular cap. Resubscribe to raise it.',
                    {'gym_handle': gym.handle},
                )
            return Response({'status': 'ok'})

        if event_type in ('charge.failed', 'payment.failed', 'invoice.payment_failed'):
            sub.status = GymTierSubscription.GRACE
            sub.grace_deadline = timezone.now() + datetime.timedelta(days=7)
            sub.save()
            return Response({'status': 'ok'})

        return Response({'status': 'ignored'})


class TierWalletView(views.APIView):
    """GET /gyms/<slug>/wallet/ — balance and ledger for the revenue tab."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        if gym is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        membership = GymMembership.objects.filter(
            gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner'],
        ).first()
        if membership is None:
            return Response({'success': False, 'message': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        from .models import GymWallet
        from django.db.models import Sum, Count, Q

        wallet, _ = GymWallet.objects.get_or_create(gym=gym, defaults={'balance': {}})
        window_days = int(request.query_params.get('days') or 30)
        if window_days not in (7, 30, 90, 365):
            window_days = 30
        window_start = timezone.now() - datetime.timedelta(days=window_days)
        entries = wallet.entries.filter(created_at__gte=window_start).order_by('-created_at')

        by_kind = {}
        for row in entries.values('kind', 'direction').annotate(total=Sum('quantity'), n=Count('id')):
            by_kind.setdefault(row['kind'], {})[row['direction']] = {
                'quantity': row['total'] or 0,
                'count': row['n'],
            }

        kind_totals_credits = entries.filter(direction='credit').values('kind').annotate(total=Sum('quantity'))

        return Response({
            'success': True,
            'data': {
                'balance': wallet.balance or {},
                'usd_estimate': capacity.usd_estimate(wallet.balance or {}),
                'entries': [
                    {
                        'id': str(e.id),
                        'artifact_type': e.artifact_type,
                        'quantity': e.quantity,
                        'direction': e.direction,
                        'kind': e.kind,
                        'reference_id': e.reference_id,
                        'note': e.note,
                        'created_at': e.created_at.isoformat(),
                    }
                    for e in entries[:200]
                ],
                'by_kind': by_kind,
                'window_days': window_days,
                'capacity': capacity.capacity_status(gym),
                'donations_received': (gym.wallet_balance or {}).get('donations_received', 0.0),
            },
            'message': 'OK', 'errors': None, 'pagination': None,
        })
