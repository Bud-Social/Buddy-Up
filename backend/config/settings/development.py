# Settings modules extend the base with `from .base import *`, which is the
# standard Django composition pattern; ruff can't statically resolve those.
# ruff: noqa: F403, F405
from .base import *

DEBUG = True
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'localhost,127.0.0.1,backend').split(',')
ALLOWED_HOSTS = list(set(ALLOWED_HOSTS + ['localhost', '127.0.0.1', 'testserver']))
CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ALLOWED_ORIGINS', 'http://localhost:3002').split(',')
CORS_ALLOWED_ORIGINS = list(set(CORS_ALLOWED_ORIGINS + ['http://localhost:3002']))
CSRF_TRUSTED_ORIGINS = os.environ.get('CSRF_TRUSTED_ORIGINS', 'http://localhost:3002').split(',')
CSRF_TRUSTED_ORIGINS = list(set(CSRF_TRUSTED_ORIGINS + ['http://localhost:3002']))

SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-prod')

# django-debug-toolbar renders its own panel when a view raises, and its
# rendering path raises `KeyError` on the URL namespace. Under the test
# runner that masks the real traceback and turns a readable failure into an
# opaque one, so keep the toolbar out of test runs entirely.
import sys as _sys

_TOOLBAR_DISABLED = (
    os.environ.get('DISABLE_DEBUG_TOOLBAR') == '1'
    or 'test' in _sys.argv
    or 'pytest' in _sys.argv
)
if not _TOOLBAR_DISABLED:
    INSTALLED_APPS += [
        'django_extensions',
        'debug_toolbar',
    ]
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')

INTERNAL_IPS = ['127.0.0.1', 'localhost']

SECURE_CROSS_ORIGIN_OPENER_POLICY = None

# Email: use real SMTP when credentials exist (Gmail app password in .env),
# otherwise fall back to the console backend — OTPs then print to the Django
# and Celery worker logs so local flows are never blocked.
if os.environ.get('EMAIL_BACKEND'):
    EMAIL_BACKEND = os.environ['EMAIL_BACKEND']
elif os.environ.get('EMAIL_HOST_PASSWORD'):
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
else:
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Relaxed throttle scopes so local flows (register → resend → login) are not
# blocked by production's tighter budgets.
REST_FRAMEWORK = {
    **REST_FRAMEWORK,
    'DEFAULT_THROTTLE_RATES': {
        **REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'],
        'otp': '30/h',
        'registration': '30/h',
        'login': '60/h',
        'password_reset': '20/h',
    },
}

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
        'level': 'INFO',
    },
}

# ── Local Development Overrides (no Docker) ──────────────────────────

# Docker Compose passes DATABASE_URL (Postgres). Local dev without Docker
# falls back to a SQLite file.
from urllib.parse import urlparse  # noqa: E402

if os.environ.get('DATABASE_URL'):
    _db_url = urlparse(os.environ['DATABASE_URL'])
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': _db_url.path[1:],
        'USER': _db_url.username,
        'PASSWORD': _db_url.password,
        'HOST': _db_url.hostname,
        'PORT': _db_url.port or '5432',
    }
else:
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }

# ── Channel layer ───────────────────────────────────────────────────────────
# Daphne serves HTTP + WebSocket from one process, so same-process group_send
# works with the in-memory layer and the bug is invisible locally. But the
# celery worker/beat containers are separate processes: anything they broadcast
# (notifications, live updates) never reaches a socket, and nothing in the logs
# says so. Use the same Redis layer base.py configures and only fall back to
# in-memory when Redis is genuinely unreachable (a laptop with no compose
# stack). The probe is guarded so importing these settings can never fail on a
# machine without Redis.
import logging as _logging  # noqa: E402

CHANNEL_LAYER_LOGGER = _logging.getLogger('buddyup.channel_layer')


def _redis_reachable(url, timeout=0.5):
    """True when Redis answers a PING at ``url``; never raises."""
    try:
        import redis

        client = redis.Redis.from_url(
            url, socket_connect_timeout=timeout, socket_timeout=timeout,
        )
        return bool(client.ping())
    except Exception:  # noqa: BLE001 — unreachable, unparseable, or no redis lib
        return False


CHANNEL_LAYER_BACKEND = 'channels.layers.InMemoryChannelLayer'
if _redis_reachable(REDIS_URL):
    CHANNEL_LAYER_BACKEND = 'channels_redis.core.RedisChannelLayer'
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': CHANNEL_LAYER_BACKEND,
            'CONFIG': {
                'hosts': [REDIS_URL],
            },
        },
    }
else:
    CHANNEL_LAYER_LOGGER.warning(
        'Redis at %s is unreachable; falling back to InMemoryChannelLayer — '
        'same-process group_send still works, but broadcasts raised in the '
        'celery worker/beat containers will never reach a WebSocket client.',
        REDIS_URL,
    )
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': CHANNEL_LAYER_BACKEND,
        },
    }

CELERY_BROKER_URL = 'memory://'
CELERY_TASK_ALWAYS_EAGER = True
