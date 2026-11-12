"""Server-side composition of branded BuddyUp video cards.

The browser renders the card chrome (background, post frame, author, caption,
metrics, footer) and the decorations that sit on top of the clip (fade,
badge, watermark) as two PNG layers. ffmpeg then places the *whole* clip
inside the media block and carries the source audio track across untouched —
so the shared file is the complete video, not a preview.

Rendering the chrome in the browser keeps one source of truth for the design
(Pillow cannot reproduce the web fonts), while ffmpeg on the server does the
video work a browser cannot: full duration, original audio, one clean encode.

The render takes roughly as long as the clip itself, so it runs on a worker
thread and the client polls for the result. Django's ASGI handler runs every
synchronous view on one shared thread, so a long render inline would stall
every other API request.
"""

from __future__ import annotations

import io
import logging
import os
import shutil
import subprocess
import tempfile
import threading
import uuid
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from django.core.cache import cache
from django.http import FileResponse, HttpResponse
from rest_framework import status
from rest_framework.response import Response

logger = logging.getLogger(__name__)

CARD_WIDTH = 1080
CARD_HEIGHT = 1350

#: Corner radius of the media block, matching the card chrome.
MEDIA_RADIUS = 36

#: Frames per second in the exported card.
CARD_FPS = 24

#: The longest a card may run, and the longest a render may take. A clip
#: longer than this is cut there rather than tying up a worker for minutes.
MAX_RENDER_SECONDS = 600

#: How long a finished render stays downloadable.
RESULT_TTL = 3600

#: How long a job may sit pending before it is considered lost.
PENDING_TTL = 900


def result_ttl() -> int:
    """How long a finished card stays downloadable."""
    from django.conf import settings

    return int(getattr(settings, 'VIDEO_CARD_TTL', RESULT_TTL) or RESULT_TTL)


class VideoCardError(Exception):
    """Raised when a video card cannot be composed."""


def ffmpeg_executable() -> str | None:
    """Locate an ffmpeg binary.

    A system install wins; otherwise fall back to the static binary that
    imageio-ffmpeg ships, which keeps slim Docker images working without an
    apt dependency.
    """
    system = shutil.which('ffmpeg')
    if system:
        return system
    try:
        import imageio_ffmpeg

        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        return None


def _resolve_local_media(media_url: str) -> Path | None:
    """Map a stored '/media/…' path onto a file inside MEDIA_ROOT."""
    if not media_url or media_url.startswith(('http://', 'https://')):
        return None
    rel = media_url.lstrip('/')
    if rel.startswith('media/'):
        rel = rel[len('media/'):]
    if not rel:
        return None
    from django.conf import settings

    candidate = Path(settings.MEDIA_ROOT) / rel
    try:
        if candidate.is_file():
            return candidate
    except OSError:
        return None
    return None


def _resolve_source_input(media_url: str) -> str:
    """Return a path or URL ffmpeg can read the clip from directly.

    The source is handed to ffmpeg rather than copied: a clip can be
    hundreds of megabytes, and a copy would need that much scratch space.
    Local '/media/…' paths resolve to the file on disk; remote URLs are
    passed through for ffmpeg to fetch.
    """
    local = _resolve_local_media(media_url)
    if local is not None:
        return str(local)

    url = media_url
    if not url.startswith(('http://', 'https://')):
        # Relative path that is not on disk: try the public API origin.
        base = (os.environ.get('PUBLIC_API_URL') or '').rstrip('/')
        if not base:
            raise VideoCardError('Source media could not be located.')
        url = f"{base}{url if url.startswith('/') else '/' + url}"
    return url


def _rounded_mask(width: int, height: int, radius: int) -> bytes:
    """A white rounded rectangle on black — the clip's alpha mask."""
    from PIL import Image, ImageDraw

    mask = Image.new('L', (width, height), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [0, 0, width - 1, height - 1],
        radius=max(0, min(radius, min(width, height) // 2)),
        fill=255,
    )
    buf = io.BytesIO()
    mask.save(buf, format='PNG')
    return buf.getvalue()


def parse_rect(value: str | None) -> tuple[int, int, int, int]:
    """Parse and validate the 'x,y,w,h' media rectangle from the client."""
    if not value:
        raise VideoCardError('Missing media rectangle.')
    try:
        parts = [int(p) for p in str(value).split(',')]
    except (TypeError, ValueError):
        raise VideoCardError('Invalid media rectangle.')
    if len(parts) != 4:
        raise VideoCardError('Invalid media rectangle.')
    x, y, w, h = parts
    if w <= 0 or h <= 0 or x < 0 or y < 0:
        raise VideoCardError('Invalid media rectangle.')
    if x + w > CARD_WIDTH or y + h > CARD_HEIGHT:
        raise VideoCardError('Invalid media rectangle.')
    return x, y, w, h


def parse_radius(value) -> int:
    try:
        radius = int(value)
    except (TypeError, ValueError):
        return MEDIA_RADIUS
    return max(0, min(radius, 200))


def trim_start_seconds(trim_start_ms: int | None) -> float | None:
    """Return the offset the post's clip starts at, in seconds.

    A post records where the author kept the video when they trimmed it in
    the studio, and the stored asset can still hold the footage before that
    point. The card starts at the same offset the feed player seeks to, so
    the shared file shows the same clip the post shows.

    The end is deliberately left alone: the player runs the clip out to its
    natural end, and cutting it short would drop footage the post still
    shows.
    """
    start_ms = max(0, int(trim_start_ms or 0))
    if start_ms <= 0:
        return None
    return start_ms / 1000.0


def compose_video_card(
    media_url: str,
    base_png: bytes,
    over_png: bytes | None,
    rect: tuple[int, int, int, int],
    radius: int = MEDIA_RADIUS,
    link: str = '',
    caption: str = '',
    author: str = '',
    trim_start_ms: int | None = None,
) -> bytes:
    """Return an MP4 of the clip composed into the BuddyUp card.

    The clip is *fitted* inside the media block: a blurred, darkened copy of
    the video fills the block and the full frame sits centred on top, so the
    viewer always sees the whole shot rather than a crop that may have cut
    the subject in half. The source audio is carried across in full.
    """
    ffmpeg = ffmpeg_executable()
    if not ffmpeg:
        raise VideoCardError('Video composition is not available on this server.')

    x, y, w, h = rect
    trim_start = trim_start_seconds(trim_start_ms)

    with tempfile.TemporaryDirectory() as tmp:
        tmpdir = Path(tmp)
        base_path = tmpdir / 'base.png'
        over_path = tmpdir / 'over.png'
        mask_path = tmpdir / 'mask.png'
        out_path = tmpdir / 'card.mp4'

        base_path.write_bytes(base_png)
        mask_path.write_bytes(_rounded_mask(w, h, radius))
        if over_png:
            over_path.write_bytes(over_png)

        source = _resolve_source_input(media_url)

        command = [
            ffmpeg, '-y', '-hide_banner', '-loglevel', 'error',
        ]
        # An input seek is frame-accurate when the stream is re-encoded, and
        # it avoids decoding the footage before the post's start.
        if trim_start:
            command += ['-ss', f'{trim_start:.3f}']
        command += [
            '-i', source,
            '-i', str(base_path),
        ]
        base_index = 1
        over_index = None
        if over_png:
            command += ['-i', str(over_path)]
            over_index = 2
        command += ['-i', str(mask_path)]
        mask_index = (over_index + 1) if over_index is not None else base_index + 1

        # The clip is scaled once and reused: the blurred backdrop is derived
        # from that same scaled frame, which keeps the cost to a single
        # resample of the source instead of two.
        filter_complex = (
            f"[0:v]fps={CARD_FPS},"
            f"scale={w}:{h}:force_original_aspect_ratio=decrease:flags=bicubic,"
            f"setsar=1,split[fg][bg0];"
            f"[bg0]scale=64:48:force_original_aspect_ratio=increase:flags=fast_bilinear,"
            f"crop=64:48,gblur=sigma=4,scale={w}:{h}:flags=fast_bilinear,"
            f"eq=brightness=-0.3:saturation=1.1[bgv];"
            f"[bgv][fg]overlay=(W-w)/2:(H-h)/2[plate];"
            f"[{mask_index}:v]format=gray[msk];"
            f"[plate][msk]alphamerge[platea];"
            f"[{base_index}:v]format=rgba[base];"
            f"[base][platea]overlay={x}:{y}:format=auto[e1];"
        )
        if over_index is not None:
            filter_complex += (
                f"[{over_index}:v]format=rgba[over];"
                f"[e1][over]overlay=0:0:format=auto[outv];"
            )
        else:
            filter_complex += "[e1]null[outv];"

        command += [
            '-filter_complex', filter_complex,
            '-map', '[outv]',
            '-map', '0:a?',
            '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '26',
            '-pix_fmt', 'yuv420p',
            '-c:a', 'aac', '-b:a', '128k',
            '-movflags', '+faststart',
        ]
        # The safety cap keeps a render bounded; a shorter clip keeps all of
        # it, so nothing the post shows is ever dropped.
        command += ['-t', f'{MAX_RENDER_SECONDS:.3f}', '-shortest']

        metadata = [
            '-metadata', f'title=BuddyUp Fit{(" — " + author) if author else ""}',
            '-metadata', 'artist=BuddyUp Fit',
            '-metadata', 'comment=Shared from BuddyUp Fit',
        ]
        if link:
            metadata += ['-metadata', f'description={link}']
        if caption:
            metadata += ['-metadata', f'synopsis={caption[:400]}']
        command += metadata

        command += [str(out_path)]

        try:
            result = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=MAX_RENDER_SECONDS,
                check=False,
            )
        except subprocess.TimeoutExpired:
            raise VideoCardError('Timed out while composing the video card.')
        except Exception as exc:
            raise VideoCardError(f'Video composition failed: {exc}')

        if result.returncode != 0 or not out_path.exists():
            detail = result.stderr.decode('utf-8', 'replace').strip().splitlines()
            message = detail[-1] if detail else 'unknown error'
            raise VideoCardError(f'Video composition failed: {message}')

        data = out_path.read_bytes()

    if not data:
        raise VideoCardError('Video composition produced an empty file.')
    return data


# --- Job plumbing -----------------------------------------------------------
#
# A render takes about as long as the clip, so it cannot run inside the
# request: Django's ASGI handler runs synchronous views on one shared thread
# and a long render there stalls every other API request. The job runs on a
# worker thread instead and the client polls for the result.
#
# The rendered file is written to disk rather than kept in the cache: a card
# is several megabytes, and the cache is a small Redis with an LRU policy
# that other features depend on.

_render_pool = ThreadPoolExecutor(max_workers=2, thread_name_prefix='videocard')
_render_lock = threading.Lock()


def _render_dir() -> Path:
    """Where finished cards are written. Kept outside MEDIA_ROOT so the
    files are only reachable through the authenticated status endpoint."""
    from django.conf import settings

    configured = getattr(settings, 'VIDEO_CARD_TMP_DIR', '')
    path = (
        Path(configured)
        if configured
        else Path(settings.MEDIA_ROOT).parent / 'tmp' / 'video_cards'
    )
    path.mkdir(parents=True, exist_ok=True)
    return path


def _result_key(job_id: str) -> str:
    return f'videocard:result:{job_id}'


def _status_key(job_id: str) -> str:
    return f'videocard:status:{job_id}'


def _prune_old_cards() -> None:
    """Drop cards older than the result TTL so the directory cannot grow
    without bound on a server that never gets read."""
    import time

    cutoff = time.time() - result_ttl()
    try:
        for entry in _render_dir().iterdir():
            try:
                if entry.is_file() and entry.stat().st_mtime < cutoff:
                    entry.unlink()
            except OSError:
                continue
    except OSError:
        return


def submit_video_card(job_id: str, render) -> None:
    """Run `render()` on a worker thread and record the outcome."""

    def run() -> None:
        ttl = result_ttl()
        try:
            data = render()
        except Exception as exc:  # noqa: BLE001 — surfaced to the client
            logger.warning('video card render failed: %s', exc)
            cache.set(
                _status_key(job_id),
                {'status': 'failed', 'error': str(exc)},
                ttl,
            )
            return
        try:
            target = _render_dir() / f'{job_id}.mp4'
            target.write_bytes(data)
        except OSError as exc:
            logger.warning('could not store the rendered video card: %s', exc)
            cache.set(
                _status_key(job_id),
                {'status': 'failed', 'error': 'The rendered card could not be stored.'},
                ttl,
            )
            return
        cache.set(_result_key(job_id), str(target), ttl)
        cache.set(_status_key(job_id), {'status': 'ready', 'size': len(data)}, ttl)
        _prune_old_cards()

    with _render_lock:
        cache.set(_status_key(job_id), {'status': 'pending'}, PENDING_TTL)
    _render_pool.submit(run)


def video_card_status(job_id: str) -> dict | None:
    """Return the job's status, or None when the job is unknown."""
    return cache.get(_status_key(job_id))


def video_card_path(job_id: str) -> Path | None:
    """Return the path of the rendered card, or None when it is gone."""
    stored = cache.get(_result_key(job_id))
    if not stored:
        return None
    path = Path(stored)
    try:
        return path if path.is_file() else None
    except OSError:
        return None


def new_job_id() -> str:
    return uuid.uuid4().hex


def video_card_response(path: Path, filename_stem: str) -> HttpResponse:
    """Stream a rendered card back as a downloadable MP4."""
    response = FileResponse(
        path.open('rb'),
        content_type='video/mp4',
        as_attachment=True,
        filename=f'buddyup_{filename_stem}.mp4',
    )
    response['X-Content-Type-Options'] = 'nosniff'
    return response


def video_card_error_response(exc: VideoCardError) -> Response:
    return Response({
        'success': False, 'data': None,
        'message': str(exc),
        'errors': None, 'pagination': None,
    }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
