import os

# Hermetic tests: strip real provider credentials from the environment
# BEFORE Django imports settings. The dev compose passes a live
# CLOUDINARY_URL into the container; tests must never talk to real
# providers (uploads would make network calls and fail).
os.environ.pop('CLOUDINARY_URL', None)
os.environ['CLOUDINARY_CLOUD_NAME'] = ''
os.environ['CLOUDINARY_API_KEY'] = ''
os.environ['CLOUDINARY_API_SECRET'] = ''
os.environ['CLOUDINARY_URL'] = ''

import pytest

from django.core.cache import cache


def pytest_configure(config):
    """Force hermetic media config AFTER django.setup().

    pytest-django runs django.setup() before root conftest bodies load, so
    module-level env edits are too late: settings (and the cloudinary SDK,
    which reads CLOUDINARY_URL at import) still see the dev compose's real
    credentials. pytest_configure hooks from the root conftest run after
    django.setup(), making this the reliable place to (1) point the default
    storage at local FileSystemStorage so tests never touch real providers,
    and (2) blank the cloudinary SDK singleton.
    """
    import os
    os.environ.pop('CLOUDINARY_URL', None)
    os.environ['CLOUDINARY_URL'] = ''
    from django.conf import settings

    settings.CLOUDINARY_CLOUD_NAME = ''
    settings.CLOUDINARY_API_KEY = ''
    settings.CLOUDINARY_API_SECRET = ''
    # The cloudinary_storage app lazily reads this dict on first use — give it
    # a dummy so the installed-but-unused app can never crash or phone home.
    settings.CLOUDINARY_STORAGE = {
        'CLOUD_NAME': 'test-cloud',
        'API_KEY': 'test-key',
        'API_SECRET': 'test-secret',
        'SECURE': True,
    }
    settings.STORAGES = {
        **getattr(settings, 'STORAGES', {}),
        'default': {'BACKEND': 'django.core.files.storage.FileSystemStorage'},
    }
    try:
        import cloudinary
        # Blank the SDK singleton — empty strings raise in config(), so poke
        # the attributes directly instead of calling config().
        cfg = cloudinary.config()
        cfg.cloud_name = ''
        cfg.api_key = ''
        cfg.api_secret = ''
    except Exception:  # noqa: BLE001 — never block collection
        pass
    # The storage handler may already have been instantiated during
    # django.setup() (app ready() hooks touching media) — reset the lazy
    # singletons AND deterministically pin a local-FS default storage so no
    # test can ever reach a real provider. Keep this in its own try-block:
    # an earlier failure must not skip it.
    try:
        from django.core.files.storage import FileSystemStorage, default_storage, storages
        default_storage._wrapped = FileSystemStorage()
        storages._wrapped = {
            'default': default_storage._wrapped,
        }
    except Exception:  # noqa: BLE001
        pass


@pytest.fixture(autouse=True)
def _isolate_cache():
    """Reset the shared cache around every test.

    Rate limits, idempotency markers and other throttling state live in the
    cache backend. Without this fixture, counters survive ``--reuse-db`` runs
    and make throttle-heavy suites order-dependent and flaky.
    """
    cache.clear()
    yield
    cache.clear()
