"""URL safety guard for server-side media fetches (pure stdlib).

Shared by the AI service (transcription downloads) and exercised from the
Django test-suite. No framework imports — everything here must stay
dependency-free so it can be loaded from any environment.
"""
import ipaddress
from urllib.parse import urlparse

_LOCAL_SUFFIXES = ('.local', '.internal')


def assert_public_http_url(media_url: str) -> None:
    """Reject non-HTTP(S) and private/loopback/link-local targets (SSRF guard)."""
    parsed = urlparse(media_url)
    if parsed.scheme not in ('https', 'http'):
        raise ValueError('Only http(s) media URLs are supported.')
    hostname = parsed.hostname or ''
    if not hostname:
        raise ValueError('media_url has no host.')
    if hostname in ('localhost',) or hostname.endswith(_LOCAL_SUFFIXES):
        raise ValueError('Refusing to fetch from a local host.')
    import socket
    try:
        infos = socket.getaddrinfo(hostname, None)
    except OSError as exc:
        raise ValueError(f'Cannot resolve media host: {exc}') from exc
    for info in infos:
        ip = info[4][0]
        addr = ipaddress.ip_address(ip)
        if addr.is_private or addr.is_loopback or addr.is_link_local or addr.is_reserved:
            raise ValueError('Refusing to fetch from a private address.')
