"""Authentication classes shared across the API."""
from rest_framework.authentication import BaseAuthentication
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


#: Header the enrolment credential travels in. Separate from `Authorization`
#: so it can never be mistaken for a session by middleware that reads the
#: standard header, and so a client cannot accidentally send it where an access
#: token was expected.
TOTP_ENROLMENT_HEADER = 'HTTP_X_TOTP_ENROLMENT_TOKEN'

#: The one purpose this credential is allowed to have.
TOTP_ENROLMENT_PURPOSE = 'totp_enrolment'


class TotpEnrolmentAuthentication(BaseAuthentication):
    """Authenticate a staff member who is not yet allowed a session.

    The problem this exists to solve
    -------------------------------
    Staff are required to have two-factor authentication. Until they do,
    ``_check_staff_mfa`` refuses to mint them a session -- at login and at token
    refresh. But ``TOTPSetupView`` and ``TOTPVerifyView`` are ``IsAuthenticated``,
    so refusing the session also refused the enrolment. A staff account created
    before the requirement existed had no way in: not the console, not the
    enrolment screen, and the only remaining route was a password reset, which
    does not enrol anything.

    Why an OTP-gated credential is the fix
    --------------------------------------
    The email OTP is the identity proof, and it already happens: login sends one
    to the account's own address and ``VerifyLoginOTPView`` refuses to continue
    without it. So by the time we mint this credential, the person has proven
    they can read mail at that address *and* know the password. That is the same
    bar the platform sets for a password reset, which is the right comparison.

    What it is not
    --------------
    A session. It is a short-lived token carrying one claim, and this class
    refuses it unless **all** of the following hold:

    * the token's ``purpose`` is exactly ``totp_enrolment``;
    * the account is staff (or a superuser);
    * the account does **not** already have TOTP enabled -- once enrolled, this
      credential is spent and must not remain a way to re-run enrolment;
    * account standing allows authentication, same as a real login.

    It authenticates on exactly two endpoints (the TOTP setup pair). Every other
    view lists ``SafeJWTAuthentication`` and never this, so the credential is
    inert everywhere else. It is also a ``RefreshToken``, whose ``token_type`` is
    ``refresh``, so SimpleJWT will not accept it as an access token -- and
    ``TokenRefreshView`` additionally requires a matching active
    ``DeviceSession`` row, which only a completed login creates.
    """

    def authenticate_header(self, request):
        # Without this DRF treats a failure as "anonymous" and answers 403
        # rather than 401, because 403 means "authenticated but not allowed".
        # A missing or rejected enrolment credential is the former, and clients
        # distinguish them: 401 means "sign in again", 403 means "you may not".
        return 'Bearer realm="api"'

    def authenticate(self, request):
        raw = request.META.get(TOTP_ENROLMENT_HEADER)
        if not raw:
            return None

        # Imported lazily for the same reason as above: `common` must not import
        # `apps` at module scope.
        from apps.accounts.views import _verify_temp_token

        user = _verify_temp_token(raw, TOTP_ENROLMENT_PURPOSE)
        if user is None:
            # Malformed, expired, or a different purpose (a `login` or
            # `totp_challenge` token presented here). Stay anonymous and let the
            # view's own permission class answer, rather than leaking that the
            # token was real but wrong-purpose.
            return None

        if not (user.is_staff or user.is_superuser):
            return None
        if user.totp_enabled:
            # Already enrolled: this credential has done its job and must not
            # be a way to re-run enrolment or reset a secret.
            return None

        _assert_account_may_authenticate(user)
        return (user, raw)
