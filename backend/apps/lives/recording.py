import os
import uuid
import logging
import tempfile
import asyncio
from pathlib import Path

from django.conf import settings

import cloudinary
import cloudinary.uploader

from .models import BuddyLive

logger = logging.getLogger(__name__)


def upload_to_cloudinary(file_path: str, public_id: str) -> str | None:
    try:
        result = cloudinary.uploader.upload(
            file_path,
            folder='replays',
            public_id=public_id,
            resource_type='video',
            overwrite=True,
        )
        url = result.get('secure_url') or result.get('url', '')
        if url:
            logger.info('Uploaded replay %s to Cloudinary: %s', public_id, url)
            return url
        logger.warning('Cloudinary upload returned no URL for %s', public_id)
        return None
    except Exception as e:
        logger.error('Cloudinary upload failed for %s: %s', public_id, e)
        return None


def _run_async(coro):
    loop = asyncio.new_event_loop()
    try:
        asyncio.set_event_loop(loop)
        return loop.run_until_complete(coro)
    finally:
        loop.close()


def start_livekit_egress(live_id: str, room_name: str) -> str | None:
    api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
    api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')
    livekit_url = getattr(settings, 'LIVEKIT_URL', '')

    if not api_key or not api_secret or not livekit_url:
        logger.warning('LiveKit Egress not configured — skipping')
        return None

    http_url = livekit_url.replace('wss://', 'https://').replace('ws://', 'http://')

    async def _start():
        from livekit.api import LiveKitAPI, RoomCompositeEgressRequest, EncodedFileOutput, EncodedFileType
        api = LiveKitAPI(http_url, api_key, api_secret)
        try:
            egress = await api.egress_service.start_room_composite_egress(
                RoomCompositeEgressRequest(
                    room_name=room_name,
                    file_outputs=[EncodedFileOutput(file_type=EncodedFileType.MP4)],
                    file_prefix=live_id,
                )
            )
            logger.info('Started LiveKit egress %s for room %s', egress.egress_id, room_name)
            return egress.egress_id
        except Exception as e:
            logger.error('Failed to start LiveKit egress for room %s: %s', room_name, e)
            return None
        finally:
            await api.aclose()

    return _run_async(_start())


def stop_livekit_egress(egress_id: str, live_id: str) -> str | None:
    api_key = getattr(settings, 'LIVEKIT_API_KEY', '')
    api_secret = getattr(settings, 'LIVEKIT_API_SECRET', '')
    livekit_url = getattr(settings, 'LIVEKIT_URL', '')

    if not api_key or not api_secret or not livekit_url:
        logger.warning('LiveKit not configured — cannot stop egress %s', egress_id)
        return None

    http_url = livekit_url.replace('wss://', 'https://').replace('ws://', 'http://')

    async def _stop():
        from livekit.api import LiveKitAPI, StopEgressRequest
        api = LiveKitAPI(http_url, api_key, api_secret)
        try:
            info = await api.egress_service.stop_egress(StopEgressRequest(egress_id=egress_id))
            logger.info('Stopped LiveKit egress %s, status=%s', egress_id, info.status)

            file_url = _extract_egress_url(info)
            if file_url:
                replay_url = _download_and_upload(file_url, live_id)
                if replay_url:
                    return replay_url
            return None
        except Exception as e:
            logger.error('Failed to stop LiveKit egress %s: %s', egress_id, e)
            return None
        finally:
            await api.aclose()

    return _run_async(_stop())


def _extract_egress_url(egress_info) -> str | None:
    try:
        if egress_info.file_results:
            for f in egress_info.file_results:
                if f.url:
                    return f.url
                if f.filename:
                    return f.filename
        if egress_info.file_outputs:
            for f in egress_info.file_outputs:
                if f.file_type == 1:
                    return f.filepath or None
    except Exception:
        pass
    return None


def _download_and_upload(file_url: str, live_id: str) -> str | None:
    tmp = None
    try:
        import requests
        resp = requests.get(file_url, timeout=300, stream=True)
        resp.raise_for_status()

        tmp = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')
        for chunk in resp.iter_content(chunk_size=8192):
            if chunk:
                tmp.write(chunk)
        tmp.close()

        replay_url = upload_to_cloudinary(tmp.name, live_id)
        return replay_url
    except Exception as e:
        logger.error('Failed to download/upload recording for %s: %s', live_id, e)
        return None
    finally:
        if tmp and os.path.exists(tmp.name):
            os.unlink(tmp.name)


def save_client_replay_chunk(live_id: str, chunk_index: int, chunk_data: bytes, recording_session_id: str) -> bool:
    chunk_dir = Path(tempfile.gettempdir()) / f'replay_chunks_{recording_session_id}'
    chunk_dir.mkdir(parents=True, exist_ok=True)
    chunk_path = chunk_dir / f'{live_id}_{chunk_index:04d}.webm'
    try:
        chunk_path.write_bytes(chunk_data)
        logger.info('Saved replay chunk %d for live %s (session %s)', chunk_index, live_id, recording_session_id)
        return True
    except Exception as e:
        logger.error('Failed to save replay chunk %d for live %s: %s', chunk_index, live_id, e)
        return False


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
        replay_url = upload_to_cloudinary(output_path, live_id)
        return replay_url
    except Exception as e:
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
