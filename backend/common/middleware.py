import logging
import time
import uuid
from django.http import JsonResponse

from .observability import record_request, request_id_var


logger = logging.getLogger('buddyup.request')


class RequestIdMiddleware:
    """Correlate client errors, Railway logs and downstream requests.

    A caller-supplied ID is accepted only within a conservative length and
    character set; otherwise a fresh UUID is issued. Every response carries
    ``X-Request-ID`` and every request is logged with latency and status.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        supplied = request.headers.get('X-Request-ID', '')[:64]
        request_id = supplied if supplied.replace('-', '').replace('_', '').isalnum() else uuid.uuid4().hex
        request.request_id = request_id
        token = request_id_var.set(request_id)
        started = time.monotonic()
        try:
            response = self.get_response(request)
        except Exception:
            record_request(500, (time.monotonic() - started) * 1000)
            logger.exception(
                'request_failed method=%s path=%s', request.method, request.path,
            )
            raise
        else:
            duration_ms = round((time.monotonic() - started) * 1000, 1)
            record_request(response.status_code, duration_ms)
            response['X-Request-ID'] = request_id
            logger.info(
                'request_complete method=%s path=%s status=%s duration_ms=%s',
                request.method, request.path, response.status_code, duration_ms,
            )
            return response
        finally:
            request_id_var.reset(token)


class ConsentEnforcementMiddleware:
    """Stop authenticated users with stale legal consent at the API boundary."""

    # The entire auth namespace is exempt: register / login / social signup /
    # onboarding are the very endpoints a user needs in order to accept the
    # current policies, so blocking them would deadlock the account.
    EXEMPT_PREFIXES = ('/api/v1/auth/', '/api/v1/health/')

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.method == 'OPTIONS' or request.path.startswith(self.EXEMPT_PREFIXES):
            return self.get_response(request)
        user = getattr(request, 'user', None)
        # DRF JWT authentication runs after Django middleware. Decode only the
        # bearer token here so stale-consent users cannot bypass this boundary.
        authorization = request.headers.get('Authorization', '')
        if authorization.lower().startswith('bearer '):
            try:
                from rest_framework_simplejwt.authentication import JWTAuthentication
                jwt_auth = JWTAuthentication()
                token = jwt_auth.get_validated_token(authorization.split(' ', 1)[1])
                user = jwt_auth.get_user(token)
            except Exception:  # invalid tokens are handled by DRF as usual
                pass
        if user and user.is_authenticated:
            from apps.accounts.policy_versions import CURRENT_POLICY_VERSIONS
            log = user.consent_log or {}
            tracked = any(f'{key}_version' in log for key in CURRENT_POLICY_VERSIONS)
            stale = tracked and any(log.get(f'{key}_version') != meta['version'] for key, meta in CURRENT_POLICY_VERSIONS.items())
            incomplete = bool(getattr(getattr(user, 'profile', None), 'onboarding_completed', True) is False)
            if stale or incomplete:
                return JsonResponse({'success': False, 'data': {'consent_required': True}, 'message': 'Please review and accept the current policies before continuing.', 'errors': None, 'pagination': None}, status=403)
        return self.get_response(request)
