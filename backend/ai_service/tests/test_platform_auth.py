"""ai_service production hardening assertions.

Coverage here replaces a live integration layer: the service boots open by
default for local dev, but *must* refuse once AI_ENV=production without an
AI_API_KEY, and CORS must never carry credentials while origins stay open.
"""

from unittest import mock

import app.main as m


def test_fail_closed_in_production():
    with mock.patch.object(m.settings, 'env', 'production'), \
            mock.patch.object(m.settings, 'api_key', ''):
        try:
            m.assert_key_configured()
        except RuntimeError as exc:
            assert 'AI_API_KEY' in str(exc)
            return
    raise AssertionError('expected RuntimeError when AI_API_KEY missing in production')


def test_dev_stays_open_unkeyed():
    with mock.patch.object(m.settings, 'env', 'development'), \
            mock.patch.object(m.settings, 'api_key', ''):
        m.assert_key_configured()  # legacy dev posture: no raise


def test_cors_dev_wide_but_never_credentialed():
    with mock.patch.object(m.settings, 'cors_origins', ''):
        s = m._cors_settings()
    assert s['allow_origins'] == ['*']
    assert s['allow_credentials'] is False


def test_cors_pinned_origins_no_credentials():
    with mock.patch.object(m.settings, 'cors_origins',
                           'https://buddyup.app, https://localhost:3000'):
        s = m._cors_settings()
    assert s['allow_origins'] == ['https://buddyup.app', 'https://localhost:3000']
    assert s['allow_credentials'] is False
