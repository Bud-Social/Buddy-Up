import logging
from datetime import date

import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


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
    # TODO: Send push notification to each active profile
    pass


def _build_profile_text(profile):
    from apps.accounts.models import User
    parts = [profile.bio] if profile.bio else []
    if profile.role:
        parts.append(f'Role: {profile.role}')
    loc_parts = []
    if profile.location_city:
        loc_parts.append(profile.location_city)
    if profile.location_country:
        loc_parts.append(profile.location_country)
    if loc_parts:
        parts.append('Location: ' + ', '.join(loc_parts))
    try:
        user = User.objects.get(pk=profile.user_id)
        prefs = user.preferences or {}
        if prefs.get('primary_goal'):
            parts.append('Goals: ' + ', '.join(prefs['primary_goal']))
        if prefs.get('activity_level'):
            parts.append('Activity: ' + prefs['activity_level'])
        if prefs.get('preferred_workouts'):
            parts.append('Workouts: ' + ', '.join(prefs['preferred_workouts']))
        if prefs.get('preferred_time'):
            parts.append('Time: ' + prefs['preferred_time'])
    except Exception:  # noqa: BLE001
        pass
    return '. '.join(parts) or profile.username


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def generate_profile_embedding(self, profile_id: str):
    from .models import Profile
    try:
        profile = Profile.objects.get(pk=profile_id)
    except Profile.DoesNotExist:
        logger.warning('Profile %s not found, skipping embedding.', profile_id)
        return

    text = _build_profile_text(profile)
    ai_url = f'{settings.AI_SERVICE_URL}/api/v1/embeddings/text'
    try:
        resp = requests.post(ai_url, params={'text': text}, timeout=15)
        resp.raise_for_status()
        data = resp.json()
        vector = data['vector']
    except requests.RequestException as e:
        logger.error('Failed to generate embedding for profile %s: %s', profile_id, e)
        raise self.retry(exc=e)

    store_url = f'{settings.AI_SERVICE_URL}/api/v1/embeddings/store'
    try:
        resp = requests.post(store_url, params={'profile_id': profile_id}, json=vector, timeout=10)
        resp.raise_for_status()
    except requests.RequestException as e:
        logger.error('Failed to store embedding for profile %s: %s', profile_id, e)
        raise self.retry(exc=e)


@shared_task
def refresh_all_embeddings():
    from .models import Profile
    pks = Profile.objects.values_list('pk', flat=True)
    for pk in pks:
        generate_profile_embedding.delay(str(pk))
