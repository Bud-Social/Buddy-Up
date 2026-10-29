"""Recording helpers for live sessions.

Design (moderation-first)
-------------------------
* Every live is **always** recorded server-side (LiveKit Egress -> an
  S3-compatible master MP4 at ``replays/<live_id>.mp4``). ``recording_consent``
  only gates whether that master is **published** as a public replay, never
  whether it is retained for staff review.
* The master MP4 is the source of truth. Public ``replay_url`` prefers a Mux HLS
  asset (adaptive) and falls back to a long-lived S3 presigned URL (the
  fault-tolerant alternative) so a viewer link never dies the moment Mux is
  unavailable.
* Staff mint a **fresh** presigned URL on every request via
  :func:`generate_archive_presigned_url`, so the archive is reachable from the
  moderation console "at all times" regardless of presigned-URL expiry.
"""
import os
import uuid
import logging
import tempfile
import time
import asyncio
from pathlib import Path

import requests

from django.conf import settings

from .models import BuddyLive


logger = logging.getLogger(__name__)

# Public replay links survive link-sharing longer than a single hop.
PUBLIC_REPLAY_TTL = int(getattr(settings, 'LIVE_REPLAY_TTL', 7 * 24 * 3600))
# Staff archive links are minted fresh on each request; this TTL is a floor.
ARCHIVE_TTL = int(getattr(settings, 'LIVE_ARCHIVE_TTL', 86400))


def _run_async(coro):
    loop = asyncio.new_event_loop()
    try:
        asyncio.set_event_loop(loop)
        return loop.run_until_complete(coro)
    finally:
        loop.close()


# ── LiveKit egress ─────────────────────────────────────────────────────


def start_livekit_egress(live_id: str, room_name: str) -> str | None:
    """Start a server-side room composite egress to S3-compatible storage.

    Moderation-first: this runs for every live. Marks the live row
    ``recording_status='recording'`` and records the master archive key so the
    recording lifecycle is observable even if the host force-quits.
    """
    api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
    api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')
    livekit_url = getattr(settings, 'LIVEKIT_INTERNAL_URL', '')

    if not all((api_key, api_secret, livekit_url, settings.LIVE_RECORDING_S3_ENDPOINT,
                settings.LIVE_RECORDING_S3_ACCESS_KEY, settings.LIVE_RECORDING_S3_SECRET_KEY)):
        logger.warning('LiveKit Egress or self-hosted replay storage is not configured — skipping')
        return None

    http_url = livekit_url.replace('wss://', 'https://').replace('ws://', 'http://')
    archive_bucket = getattr(settings, 'LIVE_ARCHIVE_BUCKET', '') or getattr(
        settings, 'LIVE_RECORDING_S3_BUCKET', '')

    async def _start():
        from livekit.api import (
            LiveKitAPI, RoomCompositeEgressRequest, EncodedFileOutput,
            EncodedFileType, S3Upload,
        )
        api = LiveKitAPI(http_url, api_key, api_secret)
        try:
            egress = await api.egress_service.start_room_composite_egress(
                RoomCompositeEgressRequest(
                    room_name=room_name,
                    file_outputs=[EncodedFileOutput(
                        file_type=EncodedFileType.MP4,
                        filepath=f'replays/{live_id}.mp4',
                        s3=S3Upload(
                            endpoint=settings.LIVE_RECORDING_S3_ENDPOINT,
                            bucket=archive_bucket,
                            access_key=settings.LIVE_RECORDING_S3_ACCESS_KEY,
                            secret=settings.LIVE_RECORDING_S3_SECRET_KEY,
                            force_path_style=True,
                        ),
                    )],
                )
            )
            logger.info('Started LiveKit egress %s for room %s', egress.egress_id, room_name)
            return egress.egress_id
        except Exception as e:  # noqa: BLE001
            logger.error('Failed to start LiveKit egress for room %s: %s', room_name, e)
            BuddyLive.objects.filter(pk=live_id).update(recording_status='failed')
            return None
        finally:
            await api.aclose()

    egress_id = _run_async(_start())
    if egress_id:
        BuddyLive.objects.filter(pk=live_id).update(
            livekit_egress_id=egress_id,
            recording_status='recording',
            recording_archive_key=f'replays/{live_id}.mp4',
        )
    return egress_id


def stop_livekit_egress(egress_id: str, live_id: str) -> str | None:
    """Stop a running egress and seal the durable master archive.

    Sets ``recording_status`` to ``'ready'`` when the master is observable and
    ``'failed'`` otherwise. Returns a durable (long-lived presigned) archive URL
    for the replay pipeline to build the public link on.
    """
    api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
    api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')
    livekit_url = getattr(settings, 'LIVEKIT_INTERNAL_URL', '')

    if not api_key or not api_secret or not livekit_url:
        logger.warning('LiveKit not configured — cannot stop egress %s', egress_id)
        BuddyLive.objects.filter(pk=live_id).update(recording_status='failed')
        return None

    http_url = livekit_url.replace('wss://', 'https://').replace('ws://', 'http://')

    async def _stop():
        from livekit.api import LiveKitAPI, StopEgressRequest
        api = LiveKitAPI(http_url, api_key, api_secret)
        try:
            info = await api.egress_service.stop_egress(StopEgressRequest(egress_id=egress_id))
            logger.info('Stopped LiveKit egress %s, status=%s', egress_id, info.status)
            return _extract_egress_url(info)
        except Exception as e:  # noqa: BLE001
            logger.error('Failed to stop LiveKit egress %s: %s', egress_id, e)
            return None
        finally:
            await api.aclose()

    result = _run_async(_stop())
    archive_key = f'replays/{live_id}.mp4'
    # The master always lands at a known key, so the staff-only archive is
    # always addressable.
    BuddyLive.objects.filter(pk=live_id).update(recording_archive_key=archive_key)

    live = BuddyLive.objects.filter(pk=live_id).first()
    if not live:
        return None

    if result:
        BuddyLive.objects.filter(pk=live_id).update(recording_status='ready')
        return generate_archive_presigned_url(live, expiration_seconds=PUBLIC_REPLAY_TTL)
    BuddyLive.objects.filter(pk=live_id).update(recording_status='failed')
    return None


def _extract_egress_url(egress_info) -> str | None:
    if getattr(egress_info, 'file_results', None):
        for f in egress_info.file_results:
            if getattr(f, 'filename', None):
                return f.filename
    if getattr(egress_info, 'file_outputs', None):
        for f in egress_info.file_outputs:
            if getattr(f, 'filepath', None):
                return f.filepath
    return None


# ── Archive / distribution URLs ────────────────────────────────────────


def _archive_bucket():
    return getattr(settings, 'LIVE_ARCHIVE_BUCKET', '') or getattr(
        settings, 'LIVE_RECORDING_S3_BUCKET', '')


def mux_hls_url(playback_id: str) -> str:
    """Public HLS endpoint for a Mux playback id."""
    return f'https://stream.mux.com/{playback_id}.m3u8'


def generate_archive_presigned_url(live: BuddyLive, expiration_seconds: int | None = None) -> str | None:
    """Fresh presigned URL for the durable master archive (staff-only surface).

    Minted on every request so expiry is a non-issue for moderators. Uses
    ``LIVE_ARCHIVE_BUCKET`` so the archive can live in a separate,
    long-retention bucket.
    """
    if expiration_seconds is None:
        expiration_seconds = ARCHIVE_TTL
    key = live.recording_archive_key or f'replays/{live.id}.mp4'
    from common.s3_utils import generate_presigned_url
    bucket = _archive_bucket() or None
    return generate_presigned_url(key, expiration_seconds=expiration_seconds, bucket=bucket)


def archive_recording_url(live: BuddyLive) -> str | None:
    """Best durable URL for playback: Mux HLS when ready, else a long-lived S3
    presigned MP4 (the fault-tolerant alternative)."""
    if live.mux_status == 'ready' and live.mux_playback_id:
        return mux_hls_url(live.mux_playback_id)
    from common.s3_utils import generate_presigned_url
    return generate_presigned_url(
        live.recording_archive_key or f'replays/{live.id}.mp4',
        expiration_seconds=PUBLIC_REPLAY_TTL,
        bucket=_archive_bucket() or None,
    )


# ── Mux (adaptive HLS distribution) ────────────────────────────────────


def _mux_credentials():
    token_id = getattr(settings, 'MUX_TOKEN_ID', '')
    token_secret = getattr(settings, 'MUX_TOKEN_SECRET', '')
    if not (token_id and token_secret):
        return None
    return token_id, token_secret


def create_mux_asset(input_url: str, live_id: str = '') -> tuple[str | None, str | None, str]:
    """Create a Mux asset from a master URL.

    Returns ``(asset_id, playback_id, error)``; ``error`` is empty on success.
    Best-effort: never raises (Mux is the convenience tier, not a hard
    dependency — the S3 master is always the fault-tolerant fallback).
    """
    creds = _mux_credentials()
    if not creds:
        return None, None, 'MUX_TOKEN_ID/MUX_TOKEN_SECRET not configured'
    token_id, token_secret = creds
    try:
        resp = requests.post(
            'https://api.mux.com/video/v1/assets',
            json={
                'input': [{'type': 'video', 'url': input_url, 'remux': True}],
                'playback_policies': ['public'],
            },
            auth=(token_id, token_secret),
            timeout=30,
        )
    except Exception as e:  # noqa: BLE001
        return None, None, f'mux request failed: {e}'
    if not resp.ok:
        return None, None, f'mux returned {resp.status_code}: {resp.text[:200]}'
    data = resp.json().get('data', {})
    asset_id = data.get('id')
    playback_id = (data.get('playback_ids') or [{}])[0].get('id')
    return asset_id, playback_id, ''


def poll_mux_asset_status(asset_id: str, attempts: int = 6, delay: int = 5) -> str:
    """Poll Mux until the asset settles. Returns the final asset ``status``."""
    creds = _mux_credentials()
    if not creds:
        return 'not_created'
    token_id, token_secret = creds
    url = f'https://api.mux.com/video/v1/assets/{asset_id}'
    last = 'created'
    for _ in range(max(1, attempts)):
        try:
            resp = requests.get(url, auth=(token_id, token_secret), timeout=15)
            if resp.ok:
                last = (resp.json().get('data') or {}).get('status', last)
            if last in ('ready', 'errored', 'failed', 'deleted'):
                return last
        except Exception:  # noqa: BLE001
            pass
        time.sleep(delay)
    return last


# ── Client-side (stitched) replay ──────────────────────────────────────


def save_client_replay_chunk(live_id: str, chunk_index: int, chunk_data: bytes, recording_session_id: str) -> bool:
    chunk_dir = Path(tempfile.gettempdir()) / f'replay_chunks_{recording_session_id}'
    try:
        chunk_dir.mkdir(parents=True, exist_ok=True)
        chunk_path = chunk_dir / f'{live_id}_{chunk_index}.webm'
        chunk_path.write_bytes(chunk_data)
        logger.info('Saved replay chunk %d for live %s (session %s)', chunk_index, live_id, recording_session_id)
        return True
    except Exception as e:  # noqa: BLE001
        logger.error('Failed to save replay chunk %d for live %s: %s', chunk_index, live_id, e)
        return False


def _upload_replay_file(live_id: str, file_path: str) -> str | None:
    """Upload a stitched replay to Cloudinary when configured; otherwise return None."""
    cloudinary_config = getattr(settings, 'CLOUDINARY_STORAGE', {})
    cloud_name = cloudinary_config.get('CLOUD_NAME')
    api_key = cloudinary_config.get('API_KEY')
    api_secret = cloudinary_config.get('API_SECRET')
    if not (cloud_name and api_key and api_secret):
        return None
    try:
        import cloudinary
        import cloudinary.uploader
        if not getattr(cloudinary.config, 'cloud_name', None):
            cloudinary.config(
                cloud_name=cloud_name, api_key=api_key, api_secret=api_secret, secure=True,
            )
        result = cloudinary.uploader.upload(
            file_path, resource_type='video',
            folder='lives/replays', public_id=live_id, overwrite=True,
        )
        url = result.get('secure_url') or result.get('url')
        if url:
            logger.info('Uploaded client replay for live %s to Cloudinary', live_id)
            return url
    except Exception as e:  # noqa: BLE001
        logger.error('Cloudinary upload failed for live %s: %s', live_id, e)
    return None


def stitch_and_upload_client_replay(live_id: str, recording_session_id: str) -> str | None:
    chunk_dir = Path(tempfile.gettempdir()) / f'replay_chunks_{recording_session_id}'
    if not chunk_dir.exists():
        logger.warning('No client replay chunks found for session %s', recording_session_id)
        return None
    chunks = sorted(chunk_dir.glob(f'{live_id}_*.webm'), key=lambda p: int(p.stem.split('_')[-1]))
    if not chunks:
        return None
    output_path = os.path.join(tempfile.gettempdir(), f'{live_id}_stitched.mp4')
    try:
        _stitch_webm_chunks(chunks, output_path)
        if not os.path.exists(output_path):
            return None
        return _upload_replay_file(live_id, output_path)
    except Exception as e:  # noqa: BLE001
        logger.error('Failed to stitch client replay for %s: %s', live_id, e)
        return None
    finally:
        for p in chunks:
            p.unlink(missing_ok=True)
        try:
            chunk_dir.rmdir()
        except OSError:
            pass
        if os.path.exists(output_path):
            os.unlink(output_path)


def _stitch_webm_chunks(chunks: list[Path], output_path: str):
    import subprocess
    if len(chunks) == 1:
        chunks[0].rename(output_path)
        return
    filelist_path = os.path.join(tempfile.gettempdir(), f'filelist_{uuid.uuid4().hex}.txt')
    try:
        with open(filelist_path, 'w') as f:
            for chunk in chunks:
                f.write(f"file '{chunk}'\n")
        subprocess.run(
            ['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', filelist_path,
             '-c', 'copy', '-movflags', '+faststart', output_path],
            check=True, capture_output=True, timeout=120,
        )
    except FileNotFoundError:
        logger.warning('ffmpeg not found — copying first chunk as fallback')
        chunks[0].rename(output_path)
    except subprocess.CalledProcessError as e:
        logger.error('ffmpeg concat failed: %s', e.stderr.decode()[:200])
        raise
    finally:
        if os.path.exists(filelist_path):
            os.unlink(filelist_path)
