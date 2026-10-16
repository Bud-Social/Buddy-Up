"""Settings for the automated test runs only.

Why this file exists
--------------------
Django used to swap in a cheap ``MD5PasswordHasher`` for the duration of a test
run, and that override was removed in Django 5.0. We are on 5.2, so every
``create_user`` in the suite now runs production-strength PBKDF2.

That is not a rounding error. PBKDF2-SHA256 at the configured iteration count
costs ~0.78s per hash on the CI runner, and the suite creates users constantly
(fixtures, permission matrices, moderation actors). One `setUp` that builds
fourteen profiles spent 10.9 of its 11.2 seconds purely hashing, and a 49-test
module took nine minutes to run.

Security is unaffected: this module is never imported by a running server. It
exists so `DJANGO_SETTINGS_MODULE` can point at it from `pytest.ini` and CI.
Tests that care about hashing *behaviour* (TOTP enrolment, recovery codes,
session rotation) are testing the surrounding logic, not KDF cost, and they all
still pass.

The hasher is intentionally MD5 rather than PBKDF2 with a low iteration count:
it is still a real salted hash, so anything that round-trips a password through
`check_password` keeps working, it is just not deliberately slow.

Media storage
-------------
`conftest.py` used to be the only place that pinned storage to a local
filesystem, which meant the pinning applied under `pytest` but *not* under
`manage.py test`. Anything uploaded in a test then reached the real Cloudinary
API using the developer's live credentials -- five verification/marketplace
tests failed with a remote `Invalid image file` 500 purely because of which
runner started the suite.

Doing it here makes the guarantee a property of the settings module, so both
entry points inherit it.
"""
import os

# Blanked before the cloudinary SDK is imported by anything downstream.
os.environ.pop('CLOUDINARY_URL', None)
os.environ['CLOUDINARY_CLOUD_NAME'] = ''
os.environ['CLOUDINARY_API_KEY'] = ''
os.environ['CLOUDINARY_API_SECRET'] = ''
os.environ['CLOUDINARY_URL'] = ''

from .development import *  # noqa: E402,F401,F403

# Inherit production cost for nothing; make the test run affordable.
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]

CLOUDINARY_CLOUD_NAME = ''
CLOUDINARY_API_KEY = ''
CLOUDINARY_API_SECRET = ''
CLOUDINARY_URL = ''
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': 'test-cloud',
    'API_KEY': 'test-key',
    'API_SECRET': 'test-secret',
    'SECURE': True,
}

# No test may ever write to a real object store.
STORAGES = {
    **globals().get('STORAGES', {}),
    'default': {'BACKEND': 'django.core.files.storage.FileSystemStorage'},
}