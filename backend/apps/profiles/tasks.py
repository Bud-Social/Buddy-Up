from celery import shared_task
from django.utils import timezone
from datetime import date


@shared_task
def check_streaks():
    from .models import Profile
    yesterday = date.today() - timezone.timedelta(days=1)
    profiles = Profile.objects.filter(streak_last_activity=yesterday)
    for p in profiles:
        p.streak_days += 1
        p.streak_last_activity = date.today()
        p.save(update_fields=['streak_days', 'streak_last_activity'])

    broken = Profile.objects.filter(
        streak_last_activity__lt=yesterday,
        streak_days__gt=0,
    )
    for p in broken:
        p.streak_days = 0
        p.save(update_fields=['streak_days'])


@shared_task
def send_streak_reminder():
    from .models import Profile
    from apps.accounts.tasks import send_otp_email
    today = date.today()
    profiles = Profile.objects.filter(
        streak_days__gte=1,
    ).exclude(streak_last_activity=today)
    # TODO: Send push notification to each profile
