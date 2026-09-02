# ruff: noqa: F403, F405
from .base import *
import os

try:
    import sentry_sdk
    from sentry_sdk.integrations.django import DjangoIntegration
    from sentry_sdk.integrations.celery import CeleryIntegration
    _HAS_SENTRY = True
except ImportError:
    sentry_sdk = None
    _HAS_SENTRY = False

DEBUG = False

# Platform hosts always allowed (Railway + Vercel + local), extended by the
# ALLOWED_HOSTS env var (e.g. your custom domain).
ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '.up.railway.app',
    '.vercel.app',
    'buddyup.app',
    'www.buddyup.app',
    'api.buddyup.app',
] + [h.strip() for h in os.environ.get('ALLOWED_HOSTS', '').split(',') if h.strip()]

CORS_ALLOWED_ORIGINS = [
    'https://buddy-up-tan.vercel.app',
    'https://buddyup.app',
    'https://www.buddyup.app',
]
# Env-supplied origins must never crash deploys (corsheaders.E013 turns a
# single malformed entry into SystemCheckError → container unhealthy →
# every fix stops shipping). Sanitise instead: prepend https:// to bare
# hostnames, drop anything still unusable.
import logging as _logging  # noqa: E402

_logging.basicConfig(level=_logging.INFO)
_cors_logger = _logging.getLogger(__name__)
for _origin in os.environ.get('CORS_ALLOWED_ORIGINS', '').split(','):
    _origin = _origin.strip().rstrip('/')
    if not _origin:
        continue
    if '://' not in _origin:
        _fixed = f'https://{_origin}'
        _cors_logger.warning(
            'CORS_ALLOWED_ORIGINS entry %r had no scheme — using %r', _origin, _fixed,
        )
        _origin = _fixed
    if _origin not in CORS_ALLOWED_ORIGINS:
        CORS_ALLOWED_ORIGINS.append(_origin)

SECRET_KEY = os.environ['SECRET_KEY']

SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
# Railway's internal health probe hits the container directly over HTTP on the
# private network (no X-Forwarded-Proto), so SECURE_SSL_REDIRECT would 301 it.
# Exempt the health path so the probe gets a 200 and the deploy succeeds.
SECURE_REDIRECT_EXEMPT = [r'^api/v1/health/$']

SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_SAMESITE = 'Lax'
SECURE_REFERRER_POLICY = 'strict-origin-when-cross-origin'
SECURE_CROSS_ORIGIN_OPENER_POLICY = 'same-origin'
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# The frontend is a separate SPA; explicitly list its origins rather than
# allowing credentials from arbitrary origins.
CORS_ALLOW_CREDENTIALS = False

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

if _HAS_SENTRY:
    sentry_sdk.init(
        dsn=os.environ.get('SENTRY_DSN', ''),
        integrations=[DjangoIntegration(), CeleryIntegration()],
        traces_sample_rate=0.1,
        send_default_pii=False,
    )

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} request_id={request_id} {name} {module}:{lineno} {message}',
            'style': '{',
        },
    },
    'handlers': {
        # Railway captures stdout/stderr; the verbose formatter keeps full
        # tracebacks visible so 500s point at real causes instead of
        # "Internal Server Error".
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
            'stream': 'ext://sys.stdout',
            'filters': ['request_id'],
        },
        'console_err': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
            'stream': 'ext://sys.stderr',
            'filters': ['request_id'],
        },
    },
    'filters': {
        'request_id': {
            '()': 'common.observability.RequestIdFilter',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django.request': {
            'handlers': ['console_err'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.server': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
        'buddyup.request': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
