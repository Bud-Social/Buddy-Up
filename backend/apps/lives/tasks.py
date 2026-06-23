import json
import uuid
import secrets
from celery import shared_task
from django.utils import timezone
from django.core.cache import cache

from .models import BuddyLive


@shared_task
def scan_random_drop_pool():
    activity_types = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'martial_arts', 'swimming', 'running', 'cycling', 'other']

    compatible_pairs = {
        'hiit': ['cardio', 'crossfit'],
        'cardio': ['hiit', 'running', 'cycling'],
        'running': ['cardio', 'cycling'],
        'cycling': ['cardio', 'running'],
        'crossfit': ['hiit', 'weights'],
        'weights': ['crossfit'],
        'yoga': ['pilates'],
        'pilates': ['yoga'],
        'martial_arts': ['cardio', 'crossfit'],
        'swimming': ['cardio'],
    }

    for activity in activity_types:
        pool_key = f"random_drop:{activity}"
        entries = cache.zrangebyscore(pool_key, '-inf', '+inf')

        if not entries:
            continue

        now = timezone.now()

        pool_users = []
        for entry_raw in entries:
            try:
                entry = json.loads(entry_raw if isinstance(entry_raw, str) else entry_raw.decode('utf-8'))
                ts = timezone.datetime.fromisoformat(entry['timestamp'])
                if (now - ts).total_seconds() > 300:
                    cache.zrem(pool_key, entry_raw)
                else:
                    pool_users.append(entry)
            except (json.JSONDecodeError, KeyError, ValueError):
                continue

        if len(pool_users) >= 2:
            group = pool_users[:min(15, len(pool_users))]
            channel_id = f"drop_{secrets.token_hex(6)}"

            for user in group:
                cache.set(
                    f"random_drop_match:{user['user_id']}",
                    json.dumps({
                        'channel': channel_id,
                        'token': 'temp_agora_token',
                        'matched_at': now.isoformat(),
                    }),
                    timeout=3600,
                )

            for user in group:
                user_key = f"random_drop_user:{user['user_id']}"
                cache.delete(user_key)
                cache.zrem(pool_key, json.dumps(user))

            BuddyLive.objects.create(
                host_id=group[0]['user_id'],
                title=f"Random Drop {activity.title()}",
                live_type='random_drop',
                category=activity,
                access='public',
                status='live',
                started_at=now,
                agora_channel=channel_id,
            )


@shared_task
def process_live_replay(live_id: str):
    try:
        live = BuddyLive.objects.get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    # TODO: Download from Mux → store on Cloudinary → set replay_url
    live.replay_url = f"https://res.cloudinary.com/buddyup/video/upload/replays/{live_id}.mp4"
    live.save(update_fields=['replay_url'])


@shared_task
def send_live_starting_notifications(live_id: str):
    from apps.notifications.models import Notification
    from apps.gyms.models import GymMembership

    try:
        live = BuddyLive.objects.select_related('gym').get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    if live.gym:
        members = GymMembership.objects.filter(
            gym=live.gym, subscription_active=True
        ).values_list('member_id', flat=True)

        for member_id in members:
            Notification.objects.create(
                recipient_id=member_id,
                notification_type='live_starting',
                title=f'{live.gym.name}: {live.title} starting soon!',
                body=f'Your gym live session starts in 15 minutes.',
                metadata={'live_id': str(live.id), 'gym_id': str(live.gym_id), 'agora_channel': live.agora_channel},
            )
