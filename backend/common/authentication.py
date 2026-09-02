"""Authentication classes shared across the API."""
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication


class SafeJWTAuthentication(JWTAuthentication):
    """JWT auth that treats invalid/expired tokens as anonymous.

    DRF authenticates whenever *any* Authorization header is present — even on
    AllowAny endpoints — so a stale token from a previous session turns public
    reads (profiles, posts, feed) into 401s. With this class an invalid token
    simply means "anonymous": public endpoints keep working, and protected
    views still reject anonymous callers with 401/403 as usual.
    """

    def authenticate(self, request):
        try:
            return super().authenticate(request)
        except AuthenticationFailed:
            return None
