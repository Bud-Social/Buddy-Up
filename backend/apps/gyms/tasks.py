from celery import shared_task
from django.db import models as db_models


@shared_task
def check_expired_subscriptions():
    from django.utils import timezone
    from .models import GymMembership, Gym
    expired = GymMembership.objects.filter(
        subscription_active=True,
        subscription_expires_at__lt=timezone.now(),
    ).select_related('gym')
    for membership in expired:
        membership.subscription_active = False
        membership.save(update_fields=['subscription_active'])
        Gym.objects.filter(id=membership.gym_id).update(
            member_count=db_models.F('member_count') - 1
        )


@shared_task
def generate_schedule_notifications():
    from .models import GymMembership
    from apps.lives.models import BuddyLive
    from apps.notifications.models import Notification
    from django.utils import timezone
    from datetime import timedelta

    window = timezone.now() + timedelta(minutes=15)
    upcoming_lives = BuddyLive.objects.filter(
        status='scheduled',
        scheduled_for__lte=window,
        scheduled_for__gte=timezone.now(),
        gym__isnull=False,
    )

    for live in upcoming_lives:
        members = GymMembership.objects.filter(
            gym=live.gym, subscription_active=True
        ).values_list('member_id', flat=True)

        for member_id in members:
            Notification.objects.create(
                recipient_id=member_id,
                notification_type='live_starting',
                title=f'{live.gym.name}: {live.title} starting soon!',
                body='Live session starts in 15 minutes.',
                metadata={'live_id': str(live.id), 'gym_id': str(live.gym_id)},
            )


@shared_task
def sweep_tier_grace_periods():
    """Nightly: lapse paid tiers after their paid period + 7 days grace.

    - subscription with an expired period moves to grace (badge intact)
    - grace past deadline flips the gym to regular and member cap re-imposes
    - owners get a notification on each step
    """
    from datetime import timedelta
    from django.utils import timezone

    from .models import GymTierSubscription

    now = timezone.now()
    grace_delta = timedelta(days=7)

    for sub in (
        GymTierSubscription.objects.select_related('gym')
        .filter(status__in=('active', 'grace'))
    ):
        if sub.current_period_end is None:
            continue
        if sub.status == 'active' and sub.current_period_end <= now:
            sub.status = GymTierSubscription.GRACE
            sub.grace_deadline = now + grace_delta
            sub.save(update_fields=['status', 'grace_deadline'])
            _notify_owners(sub, 'payment_overdue',
                           f'{sub.gym.name} tier payment overdue',
                           'Your BuddyUp tier charge failed. You have 7 days of grace before the badge downgrades to Regular.')
        elif sub.status == 'grace' and sub.grace_deadline and sub.grace_deadline <= now:
            gym = sub.gym
            sub.status = GymTierSubscription.CANCELLED
            sub.grace_deadline = None
            sub.save(update_fields=['status', 'grace_deadline'])
            if gym.tier != 'regular':
                gym.tier = 'regular'
                gym.save(update_fields=['tier', 'updated_at'])
            _notify_owners(sub, 'gym_tier_cancelled',
                           f'{gym.name} verification downgraded',
                           'The grace period ended. Your gym is back to Regular — new joins are capped at 50 until you resubscribe.')


def _notify_owners(sub, notification_type, title, body):
    from .models import GymMembership
    from apps.notifications.tasks import _deliver_notification

    for membership in GymMembership.objects.filter(gym=sub.gym, role='owner'):
        _deliver_notification(
            str(membership.member.user_id), notification_type, title, body,
            {'gym_handle': sub.gym.handle},
        )

