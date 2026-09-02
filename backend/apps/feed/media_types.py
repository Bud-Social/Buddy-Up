"""Shared media extension → type mapping (Bud Press creation studio).

Used by the create-post view, the PostMedia backfill data migration and the
uploads signing endpoint so every surface agrees on what is an image, video
or audio URL.
"""
import os

IMAGE_EXTS = ('jpg', 'jpeg', 'png', 'webp', 'gif')
VIDEO_EXTS = ('mp4', 'mov', 'webm', 'm4v', 'mpeg', 'mkv')
AUDIO_EXTS = ('mp3', 'wav', 'ogg', 'm4a', 'aac')
ALLOWED_EXTS = IMAGE_EXTS + VIDEO_EXTS + AUDIO_EXTS

MEDIA_TYPE_CHOICES = ('image', 'video', 'audio')


def url_extension(url: str) -> str:
    """Lowercased extension of `url`'s path, ignoring query/fragment. '' if none."""
    if not url:
        return ''
    path = str(url).split('?', 1)[0].split('#', 1)[0]
    if '.' not in path:
        return ''
    return path.rsplit('.', 1)[-1].lower()


def guess_media_type(url: str) -> str:
    """Infer media_type from the URL extension; defaults to 'image'."""
    ext = url_extension(url)
    if ext in VIDEO_EXTS:
        return 'video'
    if ext in AUDIO_EXTS:
        return 'audio'
    return 'image'


def is_allowed_media_host(url: str) -> bool:
    """SSRF guard for client-supplied media URLs.

    The platform fetches these URLs server-side (moderation, transcription,
    meal analysis) — only hosts we control may pass: the configured
    Cloudinary cloud and the API origin itself (local media in DEBUG).
    """
    from urllib.parse import urlparse
    from django.conf import settings

    parsed = urlparse(url or '')
    if parsed.scheme not in ('https', 'http'):
        return False
    if parsed.scheme == 'http' and not settings.DEBUG:
        return False
    host = (parsed.hostname or '').lower()

    # res.cloudinary.com is a fixed public CDN host, not attacker-controlled
    # infrastructure — allow it regardless of which cloud is configured.
    if host == 'res.cloudinary.com':
        return True

    public_api = os.environ.get('PUBLIC_API_URL', '')
    if public_api:
        api_host = urlparse(public_api).hostname or ''
        if host == api_host.lower():
            return True

    allowed_hosts = {'localhost', '127.0.0.1', 'backend', 'testserver'}
    if settings.DEBUG and host in allowed_hosts:
        return True
    return False
