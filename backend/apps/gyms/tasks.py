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
