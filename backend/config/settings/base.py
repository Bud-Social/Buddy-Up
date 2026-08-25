import os
from datetime import timedelta
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

INSTALLED_APPS = [
    'daphne',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'django_filters',
    'drf_spectacular',
    'django_celery_beat',
    'django_celery_results',
    'social_django',
    'django_otp',
    'django_otp.plugins.otp_totp',
    'cloudinary_storage',
    'cloudinary',

    # BuddyUp apps
    'apps.accounts',
    'apps.profiles',
    'apps.feed',
    'apps.gyms',
    'apps.lives',
    'apps.sessions',
    'apps.messaging',
    'apps.marketplace',
    'apps.wallet',
    'apps.notifications',
    'apps.moderation',
    'apps.verification',
    'apps.ai',
    'apps.analytics',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'
ASGI_APPLICATION = 'config.asgi.application'

AUTH_USER_MODEL = 'accounts.User'

# Database
# Railway provides a single postgres URL. Fall back to discrete DB_* vars for
# the docker-compose stack.
import urllib.parse as _urlparse  # noqa: E402

_DATABASE_URL = os.environ.get('DATABASE_URL', '')


def _database_from_url(url: str) -> dict:
    parsed = _urlparse.urlparse(url)
    return {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': parsed.path.lstrip('/') or 'postgres',
        'USER': parsed.username or 'postgres',
        'PASSWORD': parsed.password or '',
        'HOST': parsed.hostname or 'localhost',
        'PORT': parsed.port or '5432',
    }


if _DATABASE_URL:
    DATABASES = {'default': _database_from_url(_DATABASE_URL)}
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('DB_NAME', 'buddyup_dev'),
            'USER': os.environ.get('DB_USER', 'buddyup'),
            'PASSWORD': os.environ.get('DB_PASSWORD', 'devpassword'),
            'HOST': os.environ.get('DB_HOST', 'db'),
            'PORT': os.environ.get('DB_PORT', '5432'),
        }
    }

# Redis / Channels
REDIS_URL = os.environ.get('REDIS_URL', 'redis://redis:6379/0')

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [REDIS_URL],
        },
    },
}

# Shared cache. Redis when available (multi-worker safe: passkey challenges,
# rate limits), otherwise local memory for dev.
if os.environ.get('REDIS_URL'):
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.redis.RedisCache',
            'LOCATION': REDIS_URL,
        }
    }
else:
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        }
    }

# Celery
CELERY_BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = 'django-db'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = 'UTC'
CELERY_TASK_DEFAULT_QUEUE = 'default'
CELERY_TASK_QUEUES = {
    'default': {},
    'high_priority': {},
    'media': {},
    'ai': {},
}
CELERY_TASK_ROUTES = {
    'apps.lives.tasks.*': {'queue': 'media'},
    'apps.ai.tasks.*': {'queue': 'ai'},
    'apps.feed.tasks.*': {'queue': 'high_priority'},
    'apps.marketplace.tasks.send_meal_plan_daily_reminders': {'queue': 'high_priority'},
    'apps.marketplace.tasks.send_programme_activity_reminder': {'queue': 'high_priority'},
    'apps.notifications.tasks.*': {'queue': 'high_priority'},
}

CELERY_BEAT_SCHEDULE = {
    'meal-plan-daily-reminders': {
        'task': 'apps.marketplace.tasks.send_meal_plan_daily_reminders',
        'schedule': 3600.0,  # Run every hour; task checks if current hour matches subscriber preference
    },
    'event-ticket-reminders': {
        'task': 'apps.marketplace.tasks.send_event_ticket_reminders',
        'schedule': 900.0,  # Every 15 min; notifies holders of events starting within 24h
    },
    'visual-search-index-rebuild': {
        'task': 'apps.ai.tasks.embed_and_index_images',
        'schedule': 604800.0,  # Weekly marketplace image index rebuild
    },
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 8}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Whitenoise serves collected static files from the container itself — no
# separate static host required on Railway. The `default` storage backend is
# chosen below (Cloudinary with filesystem fallback).
STORAGES = {
    'staticfiles': {
        'BACKEND': 'whitenoise.storage.CompressedManifestStaticFilesStorage',
    },
}

MEDIA_URL = 'media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Upload limits — allow larger post media (photos, videos, documents).
DATA_UPLOAD_MAX_MEMORY_SIZE = int(os.environ.get('DATA_UPLOAD_MAX_MEMORY_SIZE', 52428800))
FILE_UPLOAD_MAX_MEMORY_SIZE = int(os.environ.get('FILE_UPLOAD_MAX_MEMORY_SIZE', 52428800))
DATA_UPLOAD_MAX_NUMBER_FILES = int(os.environ.get('DATA_UPLOAD_MAX_NUMBER_FILES', 24))

# Messaging attachment storage (S3-compatible, falls back to FileSystemStorage)
MESSAGING_S3_ENDPOINT = os.environ.get('MESSAGING_S3_ENDPOINT', '')
MESSAGING_S3_BUCKET = os.environ.get('MESSAGING_S3_BUCKET', '')
MESSAGING_S3_ACCESS_KEY = os.environ.get('MESSAGING_S3_ACCESS_KEY', '')
MESSAGING_S3_SECRET_KEY = os.environ.get('MESSAGING_S3_SECRET_KEY', '')
MESSAGING_S3_REGION = os.environ.get('MESSAGING_S3_REGION', 'us-east-1')
MESSAGING_S3_PRESIGNED_EXPIRY = int(os.environ.get('MESSAGING_S3_PRESIGNED_EXPIRY', '3600'))

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# DRF
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ),
    'DEFAULT_PAGINATION_CLASS': 'common.pagination.CursorPagination',
    'DEFAULT_PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_RENDERER_CLASSES': (
        'rest_framework.renderers.JSONRenderer',
    ),
    'EXCEPTION_HANDLER': 'common.exceptions.custom_exception_handler',
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.ScopedRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'registration': '10/h',
        'login': '30/h',
        'otp': '3/h',
        'password_reset': '3/h',
        'upload_attachment': '20/h',
        'link_preview': '30/h',
    },
}

# JWT
SIMPLE_JWT = {
    # Access tokens are bearer credentials and must be short lived. Refresh
    # tokens are bound to a DeviceSession and are rotated on use.
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
}

# Spectacular
SPECTACULAR_SETTINGS = {
    'TITLE': 'BuddyUp API',
    'DESCRIPTION': 'Health & fitness social platform API',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}

# Email (SMTP)
# Transactional email. SendGrid is wired automatically when SENDGRID_API_KEY
# is set (SMTP relay: user 'apikey', key as password); otherwise generic SMTP.
SENDGRID_API_KEY = os.environ.get('SENDGRID_API_KEY', '')
if not os.environ.get('EMAIL_BACKEND'):
    if SENDGRID_API_KEY:
        os.environ.setdefault('EMAIL_HOST', 'smtp.sendgrid.net')
        os.environ.setdefault('EMAIL_HOST_USER', 'apikey')
        os.environ.setdefault('EMAIL_HOST_PASSWORD', SENDGRID_API_KEY)
        os.environ.setdefault('EMAIL_PORT', '587')
        os.environ.setdefault('EMAIL_USE_TLS', 'True')

EMAIL_BACKEND = os.environ.get('EMAIL_BACKEND', 'django.core.mail.backends.smtp.EmailBackend')
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 587))
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'True').lower() in ('true', '1', 'yes')
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'noreply@buddyup.app')

# Africa's Talking SMS (used only when both credentials are configured).
AFRICASTALKING_USERNAME = os.environ.get('AFRICASTALKING_USERNAME', '')
AFRICASTALKING_API_KEY = os.environ.get('AFRICASTALKING_API_KEY', '')
AFRICASTALKING_SMS_URL = os.environ.get(
    'AFRICASTALKING_SMS_URL', 'https://api.africastalking.com/version1/messaging'
)

# Social Auth
AUTHENTICATION_BACKENDS = (
    'social_core.backends.google.GoogleOAuth2',
    'social_core.backends.apple.AppleIdAuth',
    'django.contrib.auth.backends.ModelBackend',
)

SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.environ.get('GOOGLE_CLIENT_ID', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.environ.get('GOOGLE_CLIENT_SECRET', '')

GOOGLE_PLACES_API_KEY = os.environ.get('GOOGLE_PLACES_API_KEY', '')

SOCIAL_AUTH_LOGIN_REDIRECT_URL = '/feed'

CSRF_TRUSTED_ORIGINS = os.environ.get(
    'CSRF_TRUSTED_ORIGINS',
    'https://buddyup.app,https://buddy-up-tan.vercel.app,https://*.up.railway.app,https://*.vercel.app',
).split(',')
SOCIAL_AUTH_LOGIN_ERROR_URL = '/login'
SOCIAL_AUTH_GOOGLE_OAUTH2_SCOPE = ['email', 'profile']
SOCIAL_AUTH_USER_FIELDS = ['email', 'username']
SOCIAL_AUTH_PIPELINE = (
    'social_core.pipeline.social_auth.social_details',
    'social_core.pipeline.social_auth.social_uid',
    'social_core.pipeline.social_auth.auth_allowed',
    'social_core.pipeline.social_auth.social_user',
    'social_core.pipeline.user.get_username',
    'social_core.pipeline.user.create_user',
    'social_core.pipeline.social_auth.associate_user',
    'social_core.pipeline.social_auth.load_extra_data',
    'social_core.pipeline.user.user_details',
)

# Agora RTC
AGORA_APP_ID = os.environ.get('AGORA_APP_ID', '')
AGORA_APP_CERTIFICATE = os.environ.get('AGORA_APP_CERTIFICATE', '')

# LiveKit
LIVEKIT_URL = os.environ.get('LIVEKIT_URL', '')
LIVEKIT_INTERNAL_URL = os.environ.get('LIVEKIT_INTERNAL_URL', LIVEKIT_URL)
LIVEKIT_API_KEY = os.environ.get('LIVEKIT_API_KEY', '')
LIVEKIT_API_SECRET = os.environ.get('LIVEKIT_API_SECRET', '')

# Self-hosted, S3-compatible replay storage (MinIO in the production compose stack).
LIVE_RECORDING_S3_ENDPOINT = os.environ.get('LIVE_RECORDING_S3_ENDPOINT', '')
LIVE_RECORDING_S3_BUCKET = os.environ.get('LIVE_RECORDING_S3_BUCKET', 'buddyup-replays')
LIVE_RECORDING_S3_ACCESS_KEY = os.environ.get('LIVE_RECORDING_S3_ACCESS_KEY', '')
LIVE_RECORDING_S3_SECRET_KEY = os.environ.get('LIVE_RECORDING_S3_SECRET_KEY', '')
LIVE_REPLAY_BASE_URL = os.environ.get('LIVE_REPLAY_BASE_URL', '')

# Mux (replay recording)
MUX_TOKEN_ID = os.environ.get('MUX_TOKEN_ID', '')
MUX_TOKEN_SECRET = os.environ.get('MUX_TOKEN_SECRET', '')

# Flutterwave
FLUTTERWAVE_SECRET_KEY = os.environ.get('FLUTTERWAVE_SECRET_KEY', '')
FLUTTERWAVE_PUBLIC_KEY = os.environ.get('FLUTTERWAVE_PUBLIC_KEY', '')
FLUTTERWAVE_WEBHOOK_HASH = os.environ.get('FLUTTERWAVE_WEBHOOK_HASH', '')
FLUTTERWAVE_ENCRYPTION_KEY = os.environ.get('FLUTTERWAVE_ENCRYPTION_KEY', '')

# AI microservice
AI_SERVICE_URL = os.environ.get('AI_SERVICE_URL', 'http://ai-service:8003')

# Minimum age
BUDDYUP_MINIMUM_AGE = 16

# ---------------------------------------------------------------------------
# Cloudinary (primary media storage) + Django media fallback
# ---------------------------------------------------------------------------
CLOUDINARY_CLOUD_NAME = os.environ.get('CLOUDINARY_CLOUD_NAME', '')
CLOUDINARY_API_KEY = os.environ.get('CLOUDINARY_API_KEY', '')
CLOUDINARY_API_SECRET = os.environ.get('CLOUDINARY_API_SECRET', '')
CLOUDINARY_URL = os.environ.get('CLOUDINARY_URL', '')  # Overrides individual vars if set

if CLOUDINARY_CLOUD_NAME and CLOUDINARY_API_KEY:
    import cloudinary
    cloudinary.config(
        cloud_name=CLOUDINARY_CLOUD_NAME,
        api_key=CLOUDINARY_API_KEY,
        api_secret=CLOUDINARY_API_SECRET,
        secure=True,
    )
    CLOUDINARY_STORAGE = {
        'CLOUD_NAME': CLOUDINARY_CLOUD_NAME,
        'API_KEY': CLOUDINARY_API_KEY,
        'API_SECRET': CLOUDINARY_API_SECRET,
        'SECURE': True,
        'MEDIA_TAG': 'buddyup-media',
        'INVALID_VIDEO_ERROR_MESSAGE': 'Please upload a valid video file.',
        'EXCLUDE_DELETE_ORPHANED_MEDIA_PATHS': [],
    }
    STORAGES['default'] = {'BACKEND': 'cloudinary_storage.storage.MediaCloudinaryStorage'}
else:
    # Fall back to local Django media when no Cloudinary credentials are configured
    STORAGES['default'] = {'BACKEND': 'django.core.files.storage.FileSystemStorage'}
    # Local media must be addressed absolutely in deployed environments:
    # a relative '/media/…' URL resolves against whichever frontend origin
    # rendered it (e.g. Vercel), which serves no media. PUBLIC_API_URL lets
    # ops point clients at the API domain; nginx serves /media/ there.
    _public_api_url = os.environ.get('PUBLIC_API_URL', '').rstrip('/')
    if _public_api_url:
        MEDIA_URL = f'{_public_api_url}/media/'

# ---------------------------------------------------------------------------
# FCM / Firebase push notifications
# ---------------------------------------------------------------------------
FCM_SERVER_KEY = os.environ.get('FCM_SERVER_KEY', '')
FCM_PROJECT_ID = os.environ.get('FCM_PROJECT_ID', '')
FCM_SERVICE_ACCOUNT_FILE = os.environ.get('FCM_SERVICE_ACCOUNT_FILE', '')

# ---------------------------------------------------------------------------
# Web Push (VAPID)
# ---------------------------------------------------------------------------
VAPID_PUBLIC_KEY = os.environ.get('VAPID_PUBLIC_KEY', '')
VAPID_PRIVATE_KEY = os.environ.get('VAPID_PRIVATE_KEY', '')
VAPID_CLAIM_EMAIL = os.environ.get('VAPID_CLAIM_EMAIL', 'admin@buddyup.app')
