import json
import logging
from celery import shared_task
from django.utils import timezone
from django.core.cache import cache
from django.conf import settings

from .models import BuddyLive
from .provider_service import generate_agora_token, generate_livekit_token, generate_live_channel_id, get_livekit_url

logger = logging.getLogger(__name__)


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
            channel_id = generate_live_channel_id()

            live = BuddyLive.objects.create(
                host_id=group[0]['user_id'],
                title=f"Random Drop {activity.title()}",
                live_type='random_drop',
                category=activity,
                access='public',
                status='live',
                started_at=now,
                agora_channel=channel_id,
            )

            for user in group:
                uid = user['user_id']
                agora_token = generate_agora_token(channel_id, uid=uid, role='publisher')
                livekit_token = generate_livekit_token(
                    str(live.id), identity=uid,
                    display_name=user.get('display_name', ''),
                    avatar_url=user.get('avatar_url', ''),
                )

                cache.set(
                    f"random_drop_match:{uid}",
                    json.dumps({
                        'live_id': str(live.id),
                        'agora': {
                            'app_id': getattr(settings, 'AGORA_APP_ID', ''),
                            'channel': channel_id,
                            'token': agora_token,
                        },
                        'livekit': {
                            'url': get_livekit_url(),
                            'room': str(live.id),
                            'token': livekit_token,
                        },
                        'matched_at': now.isoformat(),
                    }),
                    timeout=3600,
                )

            for user in group:
                user_key = f"random_drop_user:{user['user_id']}"
                cache.delete(user_key)
                cache.zrem(pool_key, json.dumps(user))


@shared_task
def start_livekit_recording(live_id: str):
    try:
        live = BuddyLive.objects.get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    if live.status != 'live' or live.livekit_egress_id:
        return

    from .recording import start_livekit_egress
    egress_id = start_livekit_egress(live_id, str(live.id))
    if egress_id:
        live.livekit_egress_id = egress_id
        live.save(update_fields=['livekit_egress_id'])


@shared_task
def process_live_replay(live_id: str):
    try:
        live = BuddyLive.objects.select_related('host').get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    from .recording import stop_livekit_egress, stitch_and_upload_client_replay

    if live.livekit_egress_id:
        replay_url = stop_livekit_egress(live.livekit_egress_id, live_id)
        if replay_url:
            live.replay_url = replay_url
            live.replay_saved = True
            live.save(update_fields=['replay_url', 'replay_saved'])

    if not live.replay_url and live.client_recording_session_id:
        replay_url = stitch_and_upload_client_replay(live_id, live.client_recording_session_id)
        if replay_url:
            live.replay_url = replay_url
            live.replay_saved = True
            live.save(update_fields=['replay_url', 'replay_saved'])

    if not live.replay_url:
        from common.s3_utils import generate_presigned_url
        presigned = generate_presigned_url(f'replays/{live_id}.mp4')
        if presigned:
            live.replay_url = presigned
        else:
            base_url = (settings.LIVE_REPLAY_BASE_URL or '').rstrip('/')
            if base_url:
                live.replay_url = f"{base_url}/{live_id}.mp4"
            else:
                logger.warning('No replay storage configured for live %s', live_id)
                return
        live.replay_saved = True
        live.save(update_fields=['replay_url', 'replay_saved'])

    mux_token_id = getattr(settings, 'MUX_TOKEN_ID', '')
    mux_token_secret = getattr(settings, 'MUX_TOKEN_SECRET', '')

    if mux_token_id and mux_token_secret and live.replay_url and not live.mux_asset_id:
        try:
            import requests
            resp = requests.post(
                f'https://api.mux.com/video/v1/assets',
                json={'input': [{'type': 'video', 'url': live.replay_url}]},
                auth=(mux_token_id, mux_token_secret),
                timeout=30,
            )
            if resp.ok:
                data = resp.json().get('data', {})
                live.mux_asset_id = data.get('id', live.mux_asset_id or '')
                live.mux_playback_id = data.get('playback_ids', [{}])[0].get('id', '')
                live.save(update_fields=['mux_asset_id', 'mux_playback_id'])
        except Exception as e:
            logger.error(f'Mux ingest failed for {live_id}: {e}')


@shared_task
def retry_failed_replays():
    from django.db import models as db_models
    pending = BuddyLive.objects.filter(
        status='ended',
        replay_saved=True,
    ).filter(
        db_models.Q(replay_url='') | db_models.Q(replay_url__isnull=True),
    )[:100]
    for live in pending:
        process_live_replay.delay(str(live.id))


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


@shared_task
def send_live_reminders():
    from django.db import models as db_models
    from apps.notifications.models import Notification
    from apps.notifications.tasks import _deliver_notification
    from apps.profiles.models import Profile, BuddyRelationship
    from apps.lives.models import LiveRSVP

    now = timezone.now()
    upcoming = BuddyLive.objects.filter(
        status='scheduled',
        scheduled_for__gte=now,
        scheduled_for__lte=now + timezone.timedelta(hours=1),
    ).select_related('host')

    thresholds = (60, 30, 15, 5)

    for live in upcoming:
        minutes_until = (live.scheduled_for - now).total_seconds() / 60.0
        sent = set(live.reminders_sent or [])

        for threshold in thresholds:
            if str(threshold) in sent:
                continue
            lower_bound = max(threshold - 6, 0)
            if lower_bound < minutes_until <= threshold:
                recipients = set(
                    LiveRSVP.objects.filter(live=live).values_list('user_id', flat=True)
                )
                buddy_q = db_models.Q(buddy_sent__to_user=live.host, buddy_sent__status='confirmed') | \
                          db_models.Q(buddy_received__from_user=live.host, buddy_received__status='confirmed')
                followers = Profile.objects.filter(following__followee=live.host).values_list('user_id', flat=True)
                recipients.update(Profile.objects.filter(buddy_q).distinct().values_list('user_id', flat=True))
                recipients.update(followers)

                co_host_ids = live.co_hosts.values_list('user_id', flat=True)
                for co_host_id in co_host_ids:
                    recipients.update(
                        Profile.objects.filter(following__followee_id=co_host_id).values_list('user_id', flat=True)
                    )
                recipients.discard(live.host_id)

                countdown_label = (
                    'starting now' if threshold <= 5 else f'starting in about {threshold} minutes'
                )
                title = f'{live.host.display_name}: "{live.title}" {countdown_label}'
                body = f'Don\'t miss it — {live.title} goes live soon.'
                metadata = {
                    'live_id': str(live.id),
                    'scheduled_for': live.scheduled_for.isoformat() if live.scheduled_for else None,
                    'countdown_minutes': threshold,
                    'host_display_name': live.host.display_name,
                    'host_username': live.host.username,
                    'host_avatar_url': live.host.avatar_url,
                }

                for recipient_id in recipients:
                    _deliver_notification(recipient_id, 'live_reminder', title, body, metadata)

                live.reminders_sent = live.reminders_sent + [str(threshold)]
                live.save(update_fields=['reminders_sent'])
