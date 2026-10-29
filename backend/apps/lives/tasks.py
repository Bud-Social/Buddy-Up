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
    from .redis_client import get_raw_redis

    client = get_raw_redis()
    if client is None:
        logger.warning('scan_random_drop_pool skipped: Redis unavailable')
        return

    activity_types = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'martial_arts', 'swimming', 'running', 'cycling', 'other']

    for activity in activity_types:
        pool_key = f"random_drop:{activity}"
        entries = client.zrangebyscore(pool_key, '-inf', '+inf')

        if not entries:
            continue

        now = timezone.now()

        pool_users = []
        for entry_raw in entries:
            try:
                entry = json.loads(entry_raw if isinstance(entry_raw, str) else entry_raw.decode('utf-8'))
                ts = timezone.datetime.fromisoformat(entry['timestamp'])
                if (now - ts).total_seconds() > 300:
                    client.zrem(pool_key, entry_raw)
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
                client.zrem(pool_key, json.dumps(user))


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
    """Finalize a finished live's recording.

    Moderation-first pipeline:
      1. Seal the durable S3 master MP4 (always available to staff, even for
         opt-out lives). ``recording_status`` tracks this lifecycle.
      2. Mux adaptive-HLS distribution is best-effort and non-blocking: a Mux
         failure never breaks replay completion (the master MP4 is the
         fault-tolerant fallback).
      3. A public ``replay_url`` is published only for lives whose
         ``recording_consent == 'auto_record'``; opt-out lives keep a master
         archive for staff review without a public replay.
      4. Transcription runs on the master (best-effort).
    """
    try:
        live = BuddyLive.objects.select_related('host').get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    from .recording import (
        stop_livekit_egress,
        stitch_and_upload_client_replay,
        create_mux_asset,
        archive_recording_url,
        generate_archive_presigned_url,
        PUBLIC_REPLAY_TTL,
    )

    master_url = None

    # (1) Server-side egress master — the staff archive source of truth.
    if live.livekit_egress_id:
        master_url = stop_livekit_egress(live.livekit_egress_id, live_id)
        live.refresh_from_db()

    # (2) Client-stitch fallback master (host uploaded chunks).
    if not master_url and live.client_recording_session_id:
        master_url = stitch_and_upload_client_replay(live_id, live.client_recording_session_id)
        if master_url:
            BuddyLive.objects.filter(pk=live_id).update(
                recording_archive_key=master_url,
                recording_status='ready',
            )
            live.refresh_from_db()

    # (3) Reconstruct a master URL from a persisted archive key if present.
    if not master_url and live.recording_archive_key:
        master_url = generate_archive_presigned_url(live, expiration_seconds=PUBLIC_REPLAY_TTL)

    if not master_url:
        logger.warning('No replay materialized for live %s', live_id)
        return

    live.refresh_from_db()

    # (4) Mux adaptive-HLS distribution — best-effort, never blocking. Only
    # created for consented (public) lives; opt-out lives rely on the MP4
    # archive that staff mint on demand.
    if live.recording_consent == 'auto_record' and live.mux_status != 'ready':
        if not live.mux_asset_id:
            asset_id, playback_id, err = create_mux_asset(master_url, live_id)
            if asset_id:
                BuddyLive.objects.filter(pk=live_id).update(
                    mux_asset_id=asset_id,
                    mux_playback_id=playback_id,
                    mux_status='created',
                    mux_processing_error=err or '',
                )
                live.refresh_from_db()
                finalize_mux_status.delay(str(live_id))
            else:
                BuddyLive.objects.filter(pk=live_id).update(
                    mux_status='failed',
                    mux_processing_error=(
                        (live.mux_processing_error + '; ' if live.mux_processing_error else '')
                        + (err or 'mux not configured')
                    ),
                )
                live.refresh_from_db()

    live.refresh_from_db()

    # (5) Publish a public replay URL only for consented (auto_record) lives
    # whose host also opted in at end-of-stream. archive_recording_url()
    # returns Mux HLS once ready, else a long-lived S3 presigned MP4 — the
    # published link is therefore always playable.
    if live.recording_consent == 'auto_record' and live.replay_saved:
        replay_url = archive_recording_url(live)
        if replay_url:
            BuddyLive.objects.filter(pk=live_id).update(
                replay_url=replay_url,
                replay_saved=True,
            )
            live.refresh_from_db()

    # (6) Transcription — staff review, best-effort, on the master archive.
    if master_url and not live.transcript:
        try:
            transcribe_live_replay.delay(str(live_id), master_url)
        except Exception as exc:  # noqa: BLE001
            logger.warning('Could not queue live transcription for %s: %s', live_id, exc)


@shared_task
def finalize_mux_status(live_id: str):
    """Poll Mux asynchronously and, when the asset is ready, upgrade the live's
    recording surface to HLS. A not-yet-ready asset leaves the long-lived S3
    presigned MP4 in place as the public/visible fallback."""
    try:
        live = BuddyLive.objects.get(id=live_id)
    except BuddyLive.DoesNotExist:
        return
    if live.mux_status != 'created' or not live.mux_asset_id:
        return

    from .recording import poll_mux_asset_status, archive_recording_url
    status = poll_mux_asset_status(live.mux_asset_id, attempts=12, delay=10)

    if status == 'ready':
        updates = ['mux_status']
        live.mux_status = 'ready'
        if live.recording_consent == 'auto_record':
            replay_url = archive_recording_url(live)
            if replay_url:
                live.replay_url = replay_url
                updates.append('replay_url')
        live.save(update_fields=updates)
        logger.info('Mux asset ready for live %s', live_id)
    elif status in ('errored', 'failed', 'deleted'):
        live.mux_status = 'failed'
        live.mux_processing_error = (
            (live.mux_processing_error + '; ' if live.mux_processing_error else '')
            + f'mux status={status}'
        )
        live.save(update_fields=['mux_status', 'mux_processing_error'])
        logger.warning('Mux asset for live %s ended in %s', live_id, status)
    # else: still 'created' (processing) — leave it; MP4 fallback stays live.


@shared_task(bind=True, max_retries=2, default_retry_delay=30, queue='ai')
def transcribe_live_replay(self, live_id: str, media_url: str | None = None):
    """Transcribe a finished live's replay so moderators can read it.

    The console resolves a live through `moderation.resolve`, which reads the
    stored text. Nothing here is exposed on the public live serializer — a
    replay is reviewable by staff, not republished as captions.
    """
    from apps.ai.client import ai_post

    try:
        live = BuddyLive.objects.get(id=live_id)
    except BuddyLive.DoesNotExist:
        return

    media = media_url or live.replay_url
    if live.transcript or not media:
        return

    try:
        resp = ai_post(
            f'{settings.AI_SERVICE_URL}/api/v1/transcribe',
            json={'media_url': media},
            timeout=300,
        )
        resp.raise_for_status()
        result = resp.json()
        segments = result.get('segments') or []
        text = ' '.join(str(seg.get('text') or '') for seg in segments).strip()
        text = text or str(result.get('text') or '').strip()
        if not text:
            logger.info('Live %s transcription returned no text', live_id)
            return
        BuddyLive.objects.filter(pk=live.id).update(transcript=text[:200_000])
    except Exception as exc:  # noqa: BLE001
        logger.warning('Live %s transcription failed: %s', live_id, exc)
        raise self.retry(exc=exc)


@shared_task
def retry_failed_replays():
    from django.db import models as db_models
    pending = BuddyLive.objects.filter(
        status='ended',
    ).filter(
        db_models.Q(recording_status='recording') | db_models.Q(mux_status='created'),
    )[:100]
    for live in pending:
        if live.recording_status == 'recording' and not live.livekit_egress_id and not live.client_recording_session_id:
            live.recording_status = 'failed'
            live.save(update_fields=['recording_status'])
        else:
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
                body='Your gym live session starts in 15 minutes.',
                metadata={'live_id': str(live.id), 'gym_id': str(live.gym_id), 'agora_channel': live.agora_channel},
            )


@shared_task
def send_live_reminders():
    from django.db import models as db_models
    from apps.notifications.tasks import _deliver_notification
    from apps.profiles.models import Profile
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
