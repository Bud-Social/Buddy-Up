"""Authentication classes shared across the API."""
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication


def _assert_account_may_authenticate(user):
    """Reject a user whose account standing forbids authentication.

    Imported lazily: ``common`` must not import ``apps`` at module scope —
    ``config.settings`` imports this module while the app registry is still
    populating, and a top-level ``apps.accounts`` import there is a
    circular-import crash at startup.
    """
    from apps.accounts.services import get_standing_object

    # Standing first: it carries the reason a human can act on, and the
    # is_active check below would otherwise mask it for every moderation
    # action (those set is_active=False too).
    standing = get_standing_object(user)
    if standing is not None and standing.blocks_authentication():
        raise AuthenticationFailed(
            f'This account is {standing.state}'
            + (' permanently.' if standing.permanent else '.')
            + ' Contact support to appeal.'
        )

    # is_active on its own covers the admin portal's suspend button, which
    # flips the flag without writing an AccountStanding row. Without this an
    # access token issued before the suspension keeps working for its full
    # 15-minute lifetime.
    if not user.is_active:
        raise AuthenticationFailed('This account is not active.')


class SafeJWTAuthentication(JWTAuthentication):
    """JWT auth that treats invalid/expired tokens as anonymous.

    DRF authenticates whenever *any* Authorization header is present — even on
    AllowAny endpoints — so a stale token from a previous session turns public
    reads (profiles, posts, feed) into 401s. With this class an invalid token
    simply means "anonymous": public endpoints keep working, and protected
    views still reject anonymous callers with 401/403 as usual.

    A *valid* token for a suspended or banned account is a different case and
    is NOT swallowed: it raises, so the ban takes effect on the next request
    rather than after the 15-minute access-token lifetime. An expired
    temporary suspension is treated as clear (the standing self-clears on
    read), so lapsed suspensions lift themselves without a background job.
    """

    def authenticate(self, request):
        try:
            result = super().authenticate(request)
        except AuthenticationFailed:
            return None

        if result is not None:
            _assert_account_may_authenticate(result[0])
        return result
