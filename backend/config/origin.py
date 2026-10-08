"""WebSocket Origin policy for the ASGI application.

The browser WebSocket spec forces every browser-initiated handshake to carry
an ``Origin`` header, so for a page that header is the only signal separating a
same-site socket from a cross-site one. Native clients are different: the
Flutter/Android/iOS app connects through ``dart:io``, and there is no browser
policy engine to attach an ``Origin`` to the request, so it simply sends none.

``channels.security.websocket.AllowedHostsOriginValidator`` cannot express
that. Its ``valid_origin()`` denies a ``None`` origin unless ``ALLOWED_HOSTS``
contains the ``"*"`` wildcard, so every native handshake was turned into a
bare ``HTTP/1.1 403 Access denied`` before a consumer ever ran — while a
browser on the same conversation connected fine. (Loosening ``ALLOWED_HOSTS``
with ``"*"`` would "fix" it by removing the cross-site check for *everybody*,
which is the opposite of what we want.)

So: an absent ``Origin`` is allowed, because absence is evidence of a native
client and is not evidence of a cross-site request. An ``Origin`` that *is*
present is still matched against ``ALLOWED_HOSTS`` with Channels' full
scheme/host/port logic and is still refused when it does not match, so the
cross-site protection browsers rely on is untouched.

The socket's own CSRF defence is unchanged and does not come from ``Origin``:
the consumer requires a valid bearer token and re-checks conversation
membership against the database on every connect.
"""
from channels.security.websocket import OriginValidator


class NativeFriendlyOriginValidator(OriginValidator):
    """``OriginValidator`` that permits a handshake with no ``Origin`` header.

    Behaves exactly like the Channels validator for every request that carries
    an ``Origin``; the single difference is that ``None`` (header absent or
    unparseable) passes instead of being denied. See the module docstring for
    why that is safe.
    """

    def valid_origin(self, parsed_origin):
        # No header at all: a native client. Not a cross-site request.
        if parsed_origin is None:
            return True
        # A header is present, so hold it to the allowlist as usual.
        return super().valid_origin(parsed_origin)


def native_friendly_origin_validator(application):
    """Build the validator from ``settings.ALLOWED_HOSTS``.

    Mirrors ``channels.security.websocket.AllowedHostsOriginValidator``, minus
    the ``None``-is-denied rule, so the app keeps one source of truth for which
    browser origins are trusted.
    """
    from django.conf import settings

    allowed_hosts = settings.ALLOWED_HOSTS
    if settings.DEBUG and not allowed_hosts:
        allowed_hosts = ['localhost', '127.0.0.1', '[::1]']
    return NativeFriendlyOriginValidator(application, allowed_hosts)