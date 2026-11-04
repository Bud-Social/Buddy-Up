"""Burn a BuddyUp Fit watermark into videos using ffmpeg (keyless, no external API).

Uses the ``drawtext`` filter with a semi-transparent diagonal repeating
watermark, mirroring the report PNG watermark style. Runs via subprocess so no
Python ffmpeg binding is required.
"""

import logging
import os
import subprocess

logger = logging.getLogger(__name__)

WATERMARK_TEXT = 'BuddyUp Fit'
WATERMARK_FONT_SIZE_RATIO = 1 / 12  # font height as fraction of video height
WATERMARK_OPACITY = 0.35
WATERMARK_ANGLE = -30  # degrees, diagonal


def _font_path() -> str | None:
    """Locate a freely licensed TrueType font for the drawtext filter."""
    candidates = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
        '/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf',
    ]
    for path in candidates:
        if os.path.exists(path):
            return path
    return None


def _ffprobe_dimensions(input_path: str) -> tuple[int, int] | None:
    """Return (width, height) of the video, or None if unreadable."""
    try:
        result = subprocess.run(
            [
                'ffprobe', '-v', 'error', '-select_streams', 'v:0',
                '-show_entries', 'stream=width,height',
                '-of', 'csv=p=0', input_path,
            ],
            check=True, capture_output=True, timeout=30,
        )
        out = result.stdout.decode().strip()
        if not out:
            return None
        w, h = out.split(',')
        return int(w), int(h)
    except Exception:  # noqa: BLE001 — ffprobe may not be installed or file invalid
        logger.warning('ffprobe failed for %s', input_path)
        return None


def watermark_video(input_path: str, output_path: str | None = None) -> str:
    """Burn a semi-transparent diagonal ``BuddyUp Fit`` watermark into a video.

    Returns the output path. If ffmpeg is unavailable or the input is not a
    readable video, the input path is returned unchanged (caller falls back to
    the unwatermarked file).
    """
    font = _font_path()
    if font is None:
        logger.warning('No TrueType font found — skipping video watermark')
        return input_path

    dims = _ffprobe_dimensions(input_path)
    if dims is None:
        logger.warning('Cannot probe dimensions for %s — skipping watermark', input_path)
        return input_path
    width, height = dims

    font_size = max(16, int(height * WATERMARK_FONT_SIZE_RATIO))

    # drawtext with a repeating diagonal tile via modulo arithmetic.
    # We draw the text at positions (x, y) where (x + y) % tile == 0 to
    # create a diagonal grid without needing a separate overlay image.
    tile = max(font_size * 3, 300)
    drawtext = (
        f"fontfile={font}:"
        f"text='{WATERMARK_TEXT}':"
        f"fontsize={font_size}:"
        f"fontcolor=white@{WATERMARK_OPACITY}:"
        f"x='(w/2)-(text_w/2)+((t*{tile})%{tile})-{tile}':"
        f"y='(h/2)-(text_h/2)+((t*{tile})%{tile})-{tile}':"
        f"enable='between(t,0,99999)'"
    )

    if output_path is None:
        output_path = input_path + '.watermarked.mp4'

    cmd = [
        'ffmpeg', '-y', '-hide_banner', '-loglevel', 'error',
        '-i', input_path,
        '-vf', drawtext,
        '-c:a', 'copy',
        '-movflags', '+faststart',
        output_path,
    ]

    try:
        subprocess.run(
            cmd, check=True, capture_output=True, timeout=600,
        )
        logger.info('Watermarked video %s -> %s', input_path, output_path)
        return output_path
    except subprocess.CalledProcessError as exc:
        logger.error(
            'ffmpeg watermark failed for %s: %s',
            input_path, exc.stderr.decode()[:500] if exc.stderr else exc,
        )
        return input_path
    except FileNotFoundError:
        logger.warning('ffmpeg not found — returning unwatermarked video')
        return input_path
    except subprocess.TimeoutExpired:
        logger.error('ffmpeg watermark timed out for %s', input_path)
        return input_path
