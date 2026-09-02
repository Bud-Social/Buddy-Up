"""Speech-to-text via faster-whisper (Bud Press captions).

Downloads the media, transcribes it locally and returns timestamped
segments. Falls back to raising ImportError when faster-whisper is not
installed so routers can surface a clean 503.
"""
import logging
import os
import tempfile

import requests

from .config import settings
from .urlguard import assert_public_http_url as _assert_public_http_url

logger = logging.getLogger(__name__)


def _device() -> str:
    """Map the shared torch DEVICE to a ctranslate2 device string."""
    try:
        from .model_registry import DEVICE

        if DEVICE.type == 'cuda':
            return 'cuda'
    except Exception:  # noqa: BLE001
        pass
    return 'cpu'


def _compute_type() -> str:
    if _device() == 'cuda':
        return 'float16'
    return settings.whisper_compute or 'int8'


def _load_model():
    from faster_whisper import WhisperModel

    from .model_registry import ModelRegistry

    name = settings.whisper_model or 'base'
    registry_key = f'whisper-{name}'
    cached = ModelRegistry.get(registry_key)
    if cached is not None:
        return cached
    logger.info('Loading faster-whisper model %s (%s/%s)', name, _device(), _compute_type())
    model = WhisperModel(name, device=_device(), compute_type=_compute_type())
    ModelRegistry.register(registry_key, model)
    return model


_MAX_DOWNLOAD_BYTES = int(getattr(settings, 'transcribe_max_download_mb', 200)) * 1024 * 1024
_MAX_REDIRECTS = 3


def _download_to_temp(media_url: str) -> str:
    _assert_public_http_url(media_url)
    fd, path = tempfile.mkstemp(prefix='transcribe_')
    os.close(fd)
    try:
        downloaded = 0
        with requests.get(media_url, stream=True, timeout=60, allow_redirects=False) as resp:
            # Follow redirects manually so every hop is re-validated.
            hops = 0
            while resp.status_code in (301, 302, 303, 307, 308):
                hops += 1
                if hops > _MAX_REDIRECTS:
                    raise ValueError('Too many redirects fetching media.')
                next_url = resp.headers.get('Location', '')
                _assert_public_http_url(next_url)
                resp.close()
                resp = requests.get(next_url, stream=True, timeout=60, allow_redirects=False)
            resp.raise_for_status()
            declared = resp.headers.get('Content-Length')
            if declared and int(declared) > _MAX_DOWNLOAD_BYTES:
                raise ValueError('Media exceeds the maximum download size.')
            with open(path, 'wb') as fh:
                for chunk in resp.iter_content(chunk_size=1024 * 1024):
                    if chunk:
                        downloaded += len(chunk)
                        if downloaded > _MAX_DOWNLOAD_BYTES:
                            raise ValueError('Media exceeds the maximum download size.')
                        fh.write(chunk)
    except Exception:
        if os.path.exists(path):
            os.unlink(path)
        raise
    return path


def transcribe(media_url: str) -> dict:
    """Transcribe `media_url`; returns {segments, language, duration_ms}."""
    if not media_url:
        raise ValueError('media_url is required.')

    model = _load_model()  # ImportError propagates → router returns 503
    tmp_path = _download_to_temp(media_url)
    try:
        segments_iter, info = model.transcribe(tmp_path, vad_filter=True)
        max_seconds = settings.transcribe_max_duration_sec or 240
        if info.duration and info.duration > max_seconds:
            raise ValueError(f'Media exceeds the {max_seconds}s transcription limit.')
        segments = [
            {
                'start_ms': int(seg.start * 1000),
                'end_ms': int(seg.end * 1000),
                'text': seg.text.strip(),
            }
            for seg in segments_iter
        ]
        return {
            'segments': segments,
            'language': info.language or '',
            'duration_ms': int((info.duration or 0) * 1000),
        }
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
