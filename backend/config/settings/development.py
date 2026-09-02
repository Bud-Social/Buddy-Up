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

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}

CELERY_BROKER_URL = 'memory://'
CELERY_TASK_ALWAYS_EAGER = True
