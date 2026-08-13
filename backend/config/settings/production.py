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
    'http://localhost:3002',
    'http://localhost:5173',
] + [o.strip() for o in os.environ.get('CORS_ALLOWED_ORIGINS', '').split(',') if o.strip()]

SECRET_KEY = os.environ['SECRET_KEY']

SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
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
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}
