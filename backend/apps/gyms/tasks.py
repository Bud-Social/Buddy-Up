from celery import shared_task


@shared_task
def generate_schedule_notifications():
    from .models import Gym, GymMembership
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
                body=f'Live session starts in 15 minutes.',
                metadata={'live_id': str(live.id), 'gym_id': str(live.gym_id)},
            )
