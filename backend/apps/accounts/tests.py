import hashlib

from datetime import timedelta

from django.core.cache import cache
from django.db import connection
from django.test import SimpleTestCase, TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from .models import (
    AccountStanding, DeviceSession, OTPToken, RecoveryCode, User, AccountEvent,
    WebAuthnCredential,
)
from .services import apply_standing_action, lift_standing_action
from apps.profiles.models import Profile
from common.utils import hash_dob, calculate_age

LOGIN_URL = '/api/v1/auth/login/'
VERIFY_LOGIN_OTP_URL = '/api/v1/auth/verify-login-otp/'
REFRESH_URL = '/api/v1/auth/token/refresh/'
TOTP_CHALLENGE_URL = '/api/v1/auth/totp/challenge/'


def _standing_user(email, *, verified=True, password='TestPass123!', **extra):
    user = User.objects.create_user(email=email, password=password, **extra)
    user.dob_hash = hash_dob(date(1995, 5, 5))
    user.email_verified = verified
    user.save()
    Profile.objects.create(
        user=user, username=email.split('@')[0][:24], display_name='Standing User',
    )
    return user


def _login(user, client=None, **extra):
    client = client or APIClient()
    return client.post(LOGIN_URL, {
        'email': user.email, 'password': 'TestPass123!', **extra,
    }, format='json')


def _full_login(user, client=None, password='TestPass123!'):
    """Drive login -> OTP verification and return the final response."""
    client = client or APIClient()
    first = client.post(LOGIN_URL, {'email': user.email, 'password': password}, format='json')
    assert first.status_code == status.HTTP_200_OK, first.data
    otp = OTPToken.objects.filter(user=user, channel='email', is_used=False).latest('created_at').code
    return client.post(VERIFY_LOGIN_OTP_URL, {
        'login_token': first.data['data']['login_token'], 'otp': otp,
    }, format='json')


class _CacheClearingMixin:
    """DRF throttles through the default cache, which locmem shares across
    tests in a process. Clearing it keeps a new test class from inheriting
    another one's exhausted 'login' / 'otp' budget."""

    def setUp(self):
        super().setUp()
        cache.clear()
        self.addCleanup(cache.clear)


class AuthTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/v1/auth/register/'
        self.login_url = '/api/v1/auth/login/'
        self.refresh_url = '/api/v1/auth/token/refresh/'

    def test_register_user_creates_account(self):
        data = {
            'email': 'test@example.com',
            'password': 'TestPass123!',
            'dob': '2000-06-15',
            'username': 'testuser',
            'display_name': 'Test User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertIn('registration_token', response.data['data'])
        self.assertTrue(User.objects.filter(email='test@example.com').exists())
        self.assertTrue(Profile.objects.filter(username='testuser').exists())

        user = User.objects.get(email='test@example.com')
        self.assertFalse(user.email_verified)
        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'registration_token': response.data['data']['registration_token'],
            'otp': otp,
        }
        verify_res = self.client.post(
            '/api/v1/auth/verify-registration-otp/', verify_data, format='json')
        self.assertEqual(verify_res.status_code, status.HTTP_200_OK)
        self.assertIn('access', verify_res.data['data'])
        self.assertIn('refresh', verify_res.data['data'])
        user.refresh_from_db()
        self.assertTrue(user.email_verified)

    @override_settings(CACHES={'default': {'BACKEND': 'django.core.cache.backends.locmem.LocMemCache'}})
    def test_health_returns_request_id_and_dependency_checks(self):
        response = self.client.get('/api/v1/health/', HTTP_X_REQUEST_ID='health-test-1')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response['X-Request-ID'], 'health-test-1')
        self.assertEqual(response.data['request_id'], 'health-test-1')
        self.assertIn('database', response.data['checks'])
        self.assertIn('cache', response.data['checks'])
        self.assertIn('migrations', response.data['checks'])
        self.assertIn('release', response.data)
        self.assertIn('commit', response.data)

    def test_metrics_endpoint_returns_prometheus_counters(self):
        # pytest-django forces DEBUG=False; the endpoint is open only when
        # DEBUG is on (fail-closed in production). Tested at view level —
        # flipping DEBUG via the test client would also activate the
        # debug-toolbar middleware, which has no URLs under the test runner.
        from django.test import override_settings as _os
        from rest_framework.test import APIRequestFactory

        from .views import metrics as metrics_view

        request = APIRequestFactory().get('/api/v1/health/metrics/')
        with _os(DEBUG=True):
            response = metrics_view(request)
        assert response.status_code == 200
        assert 'buddyup_http_requests_total' in response.content.decode()

    def test_metrics_endpoint_fail_closed_without_debug_or_token(self):
        # No token configured + DEBUG off → the endpoint must not exist.
        self.assertEqual(self.client.get('/api/v1/health/metrics/').status_code, 404)

    @override_settings(METRICS_TOKEN='test-metrics-token')
    def test_metrics_endpoint_requires_configured_token(self):
        self.assertEqual(self.client.get('/api/v1/health/metrics/').status_code, status.HTTP_404_NOT_FOUND)
        response = self.client.get(
            '/api/v1/health/metrics/',
            HTTP_X_METRICS_TOKEN='test-metrics-token',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_register_under_16_blocked(self):
        today = date.today()
        dob = date(today.year - 15, 6, 15)
        data = {
            'email': 'young@example.com',
            'password': 'TestPass123!',
            'dob': dob.isoformat(),
            'username': 'younguser',
            'display_name': 'Young User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(User.objects.filter(email='young@example.com').exists())

    def test_login_with_valid_credentials(self):
        user = User.objects.create_user(email='login@example.com', password='TestPass123!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.is_adult = True
        user.email_verified = True
        user.save()
        Profile.objects.create(user=user, username='loginuser', display_name='Login User')

        data = {'email': 'login@example.com', 'password': 'TestPass123!'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertTrue(response.data['data']['require_otp'])
        self.assertIn('login_token', response.data['data'])

        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'login_token': response.data['data']['login_token'],
            'otp': otp,
        }
        verify_res = self.client.post(
            '/api/v1/auth/verify-login-otp/', verify_data, format='json')
        self.assertEqual(verify_res.status_code, status.HTTP_200_OK)
        self.assertIn('access', verify_res.data['data'])

    def test_login_with_wrong_password(self):
        user = User.objects.create_user(email='wrong@example.com', password='CorrectPass1!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.save()
        Profile.objects.create(user=user, username='wronguser', display_name='Wrong User')

        data = {'email': 'wrong@example.com', 'password': 'WrongPass1!'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh(self):
        user = User.objects.create_user(email='refresh@example.com', password='TestPass123!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.is_adult = True
        user.email_verified = True
        user.save()
        Profile.objects.create(user=user, username='refreshuser', display_name='Refresh User')

        login_data = {'email': 'refresh@example.com', 'password': 'TestPass123!'}
        login_res = self.client.post(self.login_url, login_data, format='json')
        self.assertTrue(login_res.data['data']['require_otp'])
        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'login_token': login_res.data['data']['login_token'],
            'otp': otp,
        }
        login_verified = self.client.post(
            '/api/v1/auth/verify-login-otp/', verify_data, format='json')
        refresh_token = login_verified.data['data']['refresh']

        refresh_data = {'refresh': refresh_token}
        response = self.client.post(
            self.refresh_url, refresh_data, format='json', HTTP_X_DEVICE_ID='device-a')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data['data'])

    def test_otp_created_on_register(self):
        data = {
            'email': 'otp@example.com',
            'password': 'TestPass123!',
            'dob': '2000-06-15',
            'username': 'otpuser',
            'display_name': 'OTP User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        self.client.post(self.register_url, data, format='json')
        user = User.objects.get(email='otp@example.com')
        self.assertTrue(OTPToken.objects.filter(user=user, channel='email').exists())

    def test_password_reset_request_does_not_enumerate_email(self):
        unknown = self.client.post('/api/v1/auth/forgot-password/', {'email': 'none@example.com'}, format='json')
        user = User.objects.create_user(email='known@example.com', password='TestPass123!')
        known = self.client.post('/api/v1/auth/forgot-password/', {'email': user.email}, format='json')
        self.assertEqual(unknown.status_code, known.status_code)
        self.assertEqual(unknown.data['message'], known.data['message'])

    def test_stale_consent_is_enforced_and_can_be_updated(self):
        user = User.objects.create_user(email='consent@example.com', password='TestPass123!')
        user.consent_log = {'terms_version': 'old'}
        user.save(update_fields=['consent_log'])
        Profile.objects.create(user=user, username='consentuser', display_name='Consent User')
        token = __import__('rest_framework_simplejwt.tokens', fromlist=['RefreshToken']).RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token.access_token}')
        # Auth endpoints are exempt (they are how consent gets accepted);
        # enforcement applies to app-data endpoints.
        self.assertEqual(self.client.get('/api/v1/auth/sessions/').status_code, status.HTTP_200_OK)
        blocked = self.client.get('/api/v1/profiles/me/')
        self.assertEqual(blocked.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(blocked.json()['data']['consent_required'])
        accepted = self.client.post('/api/v1/auth/consent/', {
            'accepted_terms': True, 'accepted_privacy': True, 'accepted_guidelines': True,
        }, format='json')
        self.assertEqual(accepted.status_code, status.HTTP_200_OK)
        self.assertEqual(self.client.get('/api/v1/profiles/me/').status_code, status.HTTP_200_OK)

    def test_passkey_can_be_renamed_and_revoked_with_password(self):
        user = User.objects.create_user(email='key@example.com', password='TestPass123!')
        user.consent_log = {'terms_version': '1.2', 'privacy_version': '1.1', 'guidelines_version': '1.2', 'cookie_policy_version': '1.1', 'medical_disclaimer_version': '1.1', 'sponsorship_policy_version': '1.1', 'adult_content_policy_version': '1.0'}
        user.save(update_fields=['consent_log'])
        Profile.objects.create(user=user, username='keyuser', display_name='Key User')
        credential = WebAuthnCredential.objects.create(user=user, credential_id='cred', public_key=b'key', device_name='Phone')
        self.client.force_authenticate(user)
        renamed = self.client.patch(f'/api/v1/auth/passkeys/{credential.id}/rename/', {'device_name': 'Work phone'}, format='json')
        self.assertEqual(renamed.status_code, status.HTTP_200_OK)
        revoked = self.client.post(f'/api/v1/auth/passkeys/{credential.id}/revoke/', {'password': 'TestPass123!'}, format='json')
        self.assertEqual(revoked.status_code, status.HTTP_200_OK)
        credential.refresh_from_db()
        self.assertIsNotNone(credential.revoked_at)


class AgeGateTests(TestCase):
    def test_16_years_exact_allowed(self):
        age = calculate_age(date(2010, 6, 23))
        self.assertEqual(age, 16)

    def test_15_years_blocked(self):
        age = calculate_age(date(2011, 6, 23))
        self.assertLess(age, 16)

    def test_25_years_allowed(self):
        age = calculate_age(date(1999, 6, 23))
        self.assertGreaterEqual(age, 16)


class TokenRefreshRotationTests(TestCase):
    """A rotated refresh token can never be replayed against its session."""

    def setUp(self):
        self.client = APIClient()
        self.refresh_url = '/api/v1/auth/token/refresh/'

    def _make_session(self, email):
        user = User.objects.create_user(email=email, password='TestPass123!')
        token = RefreshToken.for_user(user)
        refresh_str = str(token)
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest(),
            device_name='Test device',
            ip_address='127.0.0.1',
        )
        return refresh_str

    def test_second_refresh_with_old_token_fails(self):
        refresh_str = self._make_session('rotate@example.com')

        first = self.client.post(self.refresh_url, {'refresh': refresh_str}, format='json')
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertIn('refresh', first.data['data'])

        # Replaying the pre-rotation token must be rejected: the session now
        # points at the NEW hash (and the old jti is blacklisted).
        replay = self.client.post(self.refresh_url, {'refresh': refresh_str}, format='json')
        self.assertEqual(replay.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_refresh_with_session_rotated_out_of_band_fails(self):
        refresh_str = self._make_session('rotate2@example.com')
        session = DeviceSession.objects.get(refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest())
        # Simulate a racing refresh that already rotated the row.
        session.refresh_token_hash = hashlib.sha256(b'rotated-elsewhere').hexdigest()
        session.save(update_fields=['refresh_token_hash'])

        replay = self.client.post(self.refresh_url, {'refresh': refresh_str}, format='json')
        self.assertEqual(replay.status_code, status.HTTP_401_UNAUTHORIZED)


class WebAuthnChallengeBindingTests(TestCase):
    """WebAuthn challenges are server-side, user/purpose-bound and single-use."""

    def setUp(self):
        self.client = APIClient()
        self.register_begin = '/api/v1/auth/passkeys/register/begin/'
        self.register_finish = '/api/v1/auth/passkeys/register/finish/'
        self.login_begin = '/api/v1/auth/passkeys/login/begin/'
        self.login_finish = '/api/v1/auth/passkeys/login/finish/'

    def _auth(self, email):
        user = User.objects.create_user(email=email, password='TestPass123!')
        self.client.force_authenticate(user)
        return user

    def _credential_payload(self, cred_id='cred-1'):
        return {'id': cred_id, 'rawId': cred_id, 'type': 'public-key', 'response': {}}

    def test_registration_challenge_replay_fails(self):
        from types import SimpleNamespace
        from unittest import mock
        self._auth('passkey@example.com')

        begin = self.client.post(self.register_begin, {}, format='json')
        self.assertEqual(begin.status_code, status.HTTP_200_OK)

        verification = SimpleNamespace(
            credential_id=b'cred-bytes', credential_public_key=b'pk',
            sign_count=0, credential_transports=['internal'],
        )
        with mock.patch('webauthn.verify_registration_response', return_value=verification) as verify:
            payload = {'credential': self._credential_payload()}
            first = self.client.post(self.register_finish, payload, format='json')
            self.assertEqual(first.status_code, status.HTTP_200_OK)

            # Challenge was consumed by the first finish — a replayed attempt
            # fails even before verification runs.
            replay = self.client.post(self.register_finish, payload, format='json')
            self.assertEqual(replay.status_code, status.HTTP_400_BAD_REQUEST)
            verify.assert_called_once()

    def test_registration_challenge_is_user_bound(self):
        from unittest import mock
        user_a = self._auth('passkey-a@example.com')

        begin = self.client.post(self.register_begin, {}, format='json')
        self.assertEqual(begin.status_code, status.HTTP_200_OK)

        user_b = User.objects.create_user(email='passkey-b@example.com', password='TestPass123!')
        self.client.force_authenticate(user_b)
        with mock.patch('webauthn.verify_registration_response') as verify:
            attempt = self.client.post(
                self.register_finish, {'credential': self._credential_payload()}, format='json',
            )
            self.assertEqual(attempt.status_code, status.HTTP_400_BAD_REQUEST)
            verify.assert_not_called()

        # User A's challenge is untouched by B's failed attempt.
        self.client.force_authenticate(user_a)
        self.assertIn('options', begin.data['data'])

    def test_login_challenge_cannot_be_redeemed_by_wrong_user(self):
        user_a = User.objects.create_user(email='login-a@example.com', password='TestPass123!')
        user_b = User.objects.create_user(email='login-b@example.com', password='TestPass123!')
        WebAuthnCredential.objects.create(
            user=user_b, credential_id='b-cred', public_key=b'key', device_name='B phone',
        )

        begin = self.client.post(self.login_begin, {'email': user_a.email}, format='json')
        self.assertEqual(begin.status_code, status.HTTP_200_OK)
        challenge_key = begin.data['data']['challenge_key']

        # User B's credential presented against a challenge bound to user A.
        attempt = self.client.post(
            self.login_finish,
            {'challenge_key': challenge_key, 'credential': self._credential_payload('b-cred')},
            format='json',
        )
        self.assertEqual(attempt.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('different account', attempt.data['message'])

    def test_login_challenge_is_single_use(self):
        user = User.objects.create_user(email='login-once@example.com', password='TestPass123!')

        begin = self.client.post(self.login_begin, {'email': user.email}, format='json')
        challenge_key = begin.data['data']['challenge_key']

        first = self.client.post(
            self.login_finish,
            {'challenge_key': challenge_key, 'credential': self._credential_payload('unknown')},
            format='json',
        )
        self.assertEqual(first.status_code, status.HTTP_400_BAD_REQUEST)

        # Consumed on the first attempt — replaying the same challenge key
        # can never reach credential verification.
        replay = self.client.post(
            self.login_finish,
            {'challenge_key': challenge_key, 'credential': self._credential_payload('unknown')},
            format='json',
        )
        self.assertEqual(replay.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('expired', replay.data['message'])


class AppleJWKSCacheTests(TestCase):
    """Apple's JWKS is fetched with a timeout and cached for an hour."""

    def setUp(self):
        self.client = APIClient()
        self.apple_url = '/api/v1/auth/apple/'

    @override_settings(APPLE_CLIENT_ID='com.buddyup.web')
    def test_second_login_attempt_uses_cached_jwks(self):
        from unittest import mock
        fake_keys = {'keys': [{'kid': 'k1', 'kty': 'RSA', 'n': '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86ZuT6Y7PFMuZ0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGOcic2vZnhnL6QDxZ4cWnzVRIXlT90ebRww9tV0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGO', 'e': 'AQAB'}]}
        with mock.patch('apps.accounts.views.requests.get') as get:
            get.return_value.json.return_value = fake_keys
            first = self.client.post(self.apple_url, {'identity_token': 'not-a-jwt'}, format='json')
            self.assertEqual(first.status_code, status.HTTP_400_BAD_REQUEST)
            first_count = get.call_count
            self.assertEqual(first_count, 1)

            second = self.client.post(self.apple_url, {'identity_token': 'not-a-jwt'}, format='json')
            self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertEqual(get.call_count, first_count, 'JWKS must be served from cache')


class AppleSignInFailClosedTests(TestCase):
    """Audience/issuer verification is mandatory; unconfigured → 503."""

    def setUp(self):
        self.client = APIClient()
        self.apple_url = '/api/v1/auth/apple/'

    def test_unconfigured_client_id_returns_503(self):
        from django.test import override_settings
        with override_settings(APPLE_CLIENT_ID=''):
            resp = self.client.post(self.apple_url, {'identity_token': 'x'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)

    def test_wrong_audience_is_rejected(self):
        import jwt as pyjwt
        from unittest import mock
        from django.test import override_settings
        fake_keys = {'keys': [{'kid': 'k1', 'kty': 'RSA', 'n': '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86ZuT6Y7PFMuZ0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGOcic2vZnhnL6QDxZ4cWnzVRIXlT90ebRww9tV0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGO', 'e': 'AQAB'}]}
        with override_settings(APPLE_CLIENT_ID='com.buddyup.web'):
            with mock.patch('apps.accounts.views.requests.get') as get, \
                    mock.patch('apps.accounts.views.jwt.decode') as decode, \
                    mock.patch('apps.accounts.views.jwt.get_unverified_header') as header:
                get.return_value.json.return_value = fake_keys
                header.return_value = {'kid': 'k1', 'alg': 'RS256'}
                decode.side_effect = pyjwt.InvalidAudienceError('Invalid audience')
                resp = self.client.post(self.apple_url, {'identity_token': 'tok'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_correct_audience_verifies_and_logs_in(self):
        from unittest import mock
        from django.test import override_settings
        fake_keys = {'keys': [{'kid': 'k1', 'kty': 'RSA', 'n': '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86ZuT6Y7PFMuZ0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGOcic2vZnhnL6QDxZ4cWnzVRIXlT90ebRww9tV0dcWaTPCegyQvR35gZ05DkpjT8wNJdFJGO', 'e': 'AQAB'}]}
        with override_settings(APPLE_CLIENT_ID='com.buddyup.web'):
            with mock.patch('apps.accounts.views.requests.get') as get, \
                    mock.patch('apps.accounts.views.jwt.decode') as decode, \
                    mock.patch('apps.accounts.views.jwt.get_unverified_header') as header, \
                    mock.patch('apps.accounts.views._provision_social_user') as provision, \
                    mock.patch('apps.accounts.views._finalize_social_login') as finalize:
                get.return_value.json.return_value = fake_keys
                header.return_value = {'kid': 'k1', 'alg': 'RS256'}
                decode.return_value = {
                    'email': 'appleuser@example.com', 'sub': 'apple-sub-1',
                }
                user = User.objects.create_user(email='appleuser@example.com', password='TestPass123!')
                provision.return_value = (user, True)
                finalize.return_value = ({'access': 'a', 'refresh': 'r'}, False)
                resp = self.client.post(self.apple_url, {'identity_token': 'tok'}, format='json')
        self.assertEqual(
            resp.status_code, status.HTTP_200_OK,
            f'unexpected response: {getattr(resp, "data", None)}',
        )

        # Issuer was enforced on the decode call.
        _, kwargs = decode.call_args
        self.assertEqual(kwargs.get('issuer'), 'https://appleid.apple.com')
        self.assertEqual(kwargs.get('audience'), 'com.buddyup.web')
        self.assertTrue(kwargs['options'].get('verify_iss'))


class PasswordResetTwoFactorTests(TestCase):
    """Password reset disables TOTP and records + notifies the change."""

    def setUp(self):
        self.client = APIClient()
        self.request_url = '/api/v1/auth/forgot-password/'
        self.confirm_url = '/api/v1/auth/reset-password/'

    def _totp_user(self, email):
        user = User.objects.create_user(email=email, password='TestPass123!')
        user.totp_enabled = True
        user.totp_secret = 'JBSWY3DPEHPK3PXP'
        user.save()
        return user

    def test_reset_disables_totp_with_event_and_alert(self):
        from unittest import mock
        user = self._totp_user('totp-reset@example.com')

        self.client.post(self.request_url, {'email': user.email}, format='json')
        token = OTPToken.objects.filter(user=user, channel='email').latest('created_at')

        with mock.patch('apps.accounts.views._security_alert') as alert:
            response = self.client.post(self.confirm_url, {
                'email': user.email, 'token': token.code, 'new_password': 'NewSecurePass123!',
            }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        user.refresh_from_db()
        self.assertFalse(user.totp_enabled)
        self.assertTrue(
            AccountEvent.objects.filter(user=user, event_type='2fa_disabled').exists(),
        )
        alert_calls = [str(call) for call in alert.call_args_list]
        self.assertTrue(
            any('Two-factor authentication was disabled' in call for call in alert_calls),
            f'expected a 2FA-disabled security alert, got {alert_calls}',
        )


class FriendlyErrorTests(TestCase):
    """Validation failures surface human sentences, not developer JSON."""

    def setUp(self):
        self.client = APIClient()

    def test_duplicate_email_returns_friendly_message(self):
        payload = {
            'email': 'dup@example.com', 'password': 'TestPass123!',
            'dob': '2000-01-01', 'accepted_terms': True, 'accepted_privacy': True,
            'accepted_guidelines': True, 'is_16_plus': True,
        }
        first = self.client.post('/api/v1/auth/register/', payload, format='json')
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        second = self.client.post('/api/v1/auth/register/', payload, format='json')
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
        # The message must be the human sentence — never a stringified dict.
        self.assertEqual(second.data['message'], 'An account with this email already exists.')

    def test_missing_field_returns_friendly_message(self):
        resp = self.client.post('/api/v1/auth/register/', {'email': 'x@example.com'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertNotIn('{', resp.data['message'])
        self.assertNotIn('ErrorDetail', resp.data['message'])


class SetPasswordTests(TestCase):
    """Social sign-ups can set a password; password accounts cannot bypass."""

    def _auth(self, email):
        user = User.objects.create_user(email=email, password='TestPass123!')
        user.save()
        from rest_framework_simplejwt.tokens import RefreshToken
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(user).access_token}')
        return client, user

    def test_social_user_sets_password_without_current(self):
        client, user = self._auth('social@example.com')
        user.set_unusable_password()
        user.save()
        status_check = client.get('/api/v1/auth/set-password/')
        self.assertFalse(status_check.data['data']['has_password'])

        resp = client.post('/api/v1/auth/set-password/', {'new_password': 'NewSecure123!'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.has_usable_password())
        self.assertTrue(user.check_password('NewSecure123!'))

    def test_password_user_must_supply_current(self):
        client, user = self._auth('existing@example.com')
        resp = client.post('/api/v1/auth/set-password/', {'new_password': 'NewSecure123!'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

        resp = client.post('/api/v1/auth/set-password/', {
            'new_password': 'NewSecure123!', 'current_password': 'wrong',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

        resp = client.post('/api/v1/auth/set-password/', {
            'new_password': 'NewSecure123!', 'current_password': 'TestPass123!',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

    def test_weak_password_rejected(self):
        client, _ = self._auth('weak@example.com')
        resp = client.post('/api/v1/auth/set-password/', {'new_password': 'password'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class ThrottleBudgetTests(SimpleTestCase):
    """OTP resends stay usable: local dev overrides the tight prod budget."""

    def test_dev_otp_rate_is_usable(self):
        from django.conf import settings
        self.assertGreaterEqual(
            int(settings.REST_FRAMEWORK['DEFAULT_THROTTLE_RATES']['otp'].split('/')[0]), 10,
        )


class UnverifiedLoginRedirectTests(TestCase):
    """Password login by an unverified user must hand back an OTP redirect.

    A still-valid OTP is reused (no spam email); a fresh one is only sent
    when the previous code has expired, been consumed, or exhausted attempts.
    """

    def setUp(self):
        self.client = APIClient()
        self.url = '/api/v1/auth/login/'
        self.user = User.objects.create_user(
            email='unverified@example.com', password='TestPass123!')
        # create_user leaves email_verified False by default
        self.user.email_verified = False
        self.user.save()
        # Registration always creates a profile — mirror that here.
        Profile.objects.create(
            user=self.user, username='unverified', display_name='Unverified',
        )

    def _login(self):
        return self.client.post(self.url, {
            'email': 'unverified@example.com', 'password': 'TestPass123!',
        }, format='json')

    def test_unverified_login_returns_verification_redirect(self):
        resp = self._login()
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        data = resp.data['data']
        self.assertTrue(data['require_email_verification'])
        self.assertTrue(data['registration_token'])
        self.assertTrue(data['otp_resent'], 'first login with no OTP should send one')
        self.assertEqual(data['email'], 'unverified@example.com')
        self.assertIn('not been verified', resp.data['message'])
        self.assertTrue(OTPToken.objects.filter(
            user=self.user, channel='email', is_used=False).exists())

    def test_valid_pending_otp_is_reused_not_resent(self):
        first = self._login()
        self.assertTrue(first.data['data']['otp_resent'])
        count_before = OTPToken.objects.filter(user=self.user).count()

        second = self._login()
        self.assertEqual(second.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(second.data['data']['otp_resent'])
        self.assertIn('not been verified', second.data['message'])
        # No extra OTP row — the still-valid code is reused.
        self.assertEqual(
            OTPToken.objects.filter(user=self.user).count(), count_before)

    def test_expired_otp_gets_replaced_with_fresh_one(self):
        from django.utils import timezone
        expired = OTPToken.objects.create(
            user=self.user, code='111111', channel='email',
            expires_at=timezone.now() - timedelta(minutes=1),
        )
        resp = self._login()
        self.assertTrue(resp.data['data']['otp_resent'])
        fresh = OTPToken.objects.filter(
            user=self.user, is_used=False, attempts__lt=3,
        ).order_by('-created_at').first()
        self.assertIsNotNone(fresh)
        self.assertNotEqual(fresh.id, expired.id)
        self.assertTrue(fresh.is_valid())

    def test_exhausted_attempts_otp_gets_replaced(self):
        OTPToken.objects.create(
            user=self.user, code='222222', channel='email',
            expires_at=timezone.now() + timedelta(minutes=10), attempts=3,
        )
        resp = self._login()
        self.assertTrue(resp.data['data']['otp_resent'])
        self.assertTrue(OTPToken.objects.filter(
            user=self.user, is_used=False, attempts=0).exists())

    def test_token_works_on_the_verification_endpoint(self):
        resp = self._login()
        token = resp.data['data']['registration_token']
        otp = OTPToken.objects.filter(user=self.user, channel='email').latest('created_at').code
        verify = self.client.post('/api/v1/auth/verify-registration-otp/', {
            'registration_token': token, 'otp': otp,
        }, format='json')
        self.assertEqual(verify.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertTrue(self.user.email_verified)


class AccountStandingServiceTests(TestCase):
    """The writer: apply_standing_action / lift_standing_action."""

    def setUp(self):
        self.user = _standing_user('standing-svc@example.com')

    def test_unknown_action_raises_value_error(self):
        with self.assertRaises(ValueError) as ctx:
            apply_standing_action(
                target_user_id=self.user.id, action='user_nuked', reason='nope',
            )
        self.assertIn('user_nuked', str(ctx.exception))
        # Nothing was written and the account is untouched.
        self.assertFalse(AccountStanding.objects.filter(user=self.user).exists())
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_active)

    def test_suspension_without_duration_is_indefinite_not_permanent(self):
        standing = apply_standing_action(
            target_user_id=self.user.id, action='user_suspended', reason='spam',
        )
        self.assertEqual(standing.state, AccountStanding.STATE_SUSPENDED)
        self.assertFalse(standing.permanent)
        self.assertIsNone(standing.suspended_until)
        self.assertTrue(standing.is_moderation_action)
        self.assertFalse(standing.is_expired)
        self.assertTrue(standing.blocks_authentication())

    def test_suspension_with_duration_sets_an_expiry(self):
        standing = apply_standing_action(
            target_user_id=self.user.id, action='user_suspended',
            reason='spam', duration_days=7,
        )
        self.assertFalse(standing.permanent)
        self.assertIsNotNone(standing.suspended_until)
        self.assertGreater(standing.suspended_until, timezone.now() + timedelta(days=6))
        self.assertFalse(standing.is_expired)

    def test_ban_is_permanent_and_ignores_duration(self):
        standing = apply_standing_action(
            target_user_id=self.user.id, action='user_banned',
            reason='fraud', duration_days=3,
        )
        self.assertEqual(standing.state, AccountStanding.STATE_BANNED)
        self.assertTrue(standing.permanent)
        self.assertIsNone(standing.suspended_until)

    def test_non_positive_duration_is_rejected(self):
        with self.assertRaises(ValueError):
            apply_standing_action(
                target_user_id=self.user.id, action='user_suspended',
                reason='x', duration_days=0,
            )

    def test_apply_deactivates_and_revokes_every_device_session(self):
        for i in range(3):
            DeviceSession.objects.create(
                user=self.user, refresh_token_hash=hashlib.sha256(f's{i}'.encode()).hexdigest(),
                device_name=f'Device {i}', ip_address='127.0.0.1',
            )

        apply_standing_action(
            target_user_id=self.user.id, action='user_banned',
            reason='fraud', actor=self.user, source='governance:abc-123',
        )

        self.user.refresh_from_db()
        self.assertFalse(self.user.is_active)
        self.assertEqual(DeviceSession.objects.filter(user=self.user, is_active=True).count(), 0)
        standing = AccountStanding.objects.get(user=self.user)
        self.assertEqual(standing.action_id, 'governance:abc-123')
        self.assertTrue(AccountEvent.objects.filter(
            user=self.user, event_type='account_banned').exists())

    def test_lift_restores_the_account(self):
        apply_standing_action(
            target_user_id=self.user.id, action='user_suspended', reason='spam',
        )
        standing = lift_standing_action(
            target_user_id=self.user.id, actor=self.user, reason='appeal upheld',
        )
        self.assertEqual(standing.state, AccountStanding.STATE_CLEAR)
        self.assertFalse(standing.blocks_authentication())
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_active)
        self.assertTrue(AccountEvent.objects.filter(
            user=self.user, event_type='account_standing_lifted').exists())


class AccountStandingEnforcementTests(_CacheClearingMixin, TestCase):
    """A suspension has to bite immediately, not in fifteen minutes."""

    def setUp(self):
        super().setUp()
        self.client = APIClient()

    def _session_and_tokens(self, user):
        refresh = str(RefreshToken.for_user(user))
        DeviceSession.objects.create(
            user=user, refresh_token_hash=hashlib.sha256(refresh.encode()).hexdigest(),
            device_name='Phone', ip_address='127.0.0.1',
        )
        return refresh, str(RefreshToken.for_user(user).access_token)

    def test_suspended_user_cannot_log_in(self):
        user = _standing_user('suspended-login@example.com')
        apply_standing_action(
            target_user_id=user.id, action='user_suspended', reason='spam',
        )

        res = _login(user, self.client)

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.data['success'])
        self.assertEqual(res.data['standing']['state'], 'suspended')
        self.assertEqual(res.data['standing']['reason'], 'spam')
        self.assertIsNone(res.data['standing']['until'])
        self.assertFalse(res.data['standing']['permanent'])
        self.assertNotIn('access', res.data.get('data') or {})
        # No login OTP was sent either — nothing was minted for them.
        self.assertFalse(OTPToken.objects.filter(
            user=user, channel='email', is_used=False).exists())

    def test_banned_user_cannot_log_in_even_with_reactivate(self):
        user = _standing_user('banned-reactivate@example.com')
        apply_standing_action(
            target_user_id=user.id, action='user_banned', reason='fraud',
        )

        res = _login(user, self.client, reactivate=True)

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['standing']['state'], 'banned')
        self.assertTrue(res.data['standing']['permanent'])
        user.refresh_from_db()
        self.assertFalse(user.is_active, 'reactivate must never undo a ban')

    def test_reactivation_prompt_is_not_offered_for_a_moderation_suspension(self):
        user = _standing_user('susp-no-prompt@example.com')
        apply_standing_action(
            target_user_id=user.id, action='user_suspended', reason='spam',
        )

        res = _login(user, self.client)

        self.assertNotIn('reactivatable', (res.data.get('data') or {}))

    def test_self_deactivation_is_still_reactivatable(self):
        """The regression guard: the fix must not break the legitimate path."""
        user = _standing_user('self-deactivate@example.com')
        user.is_active = False
        user.deleted_at = timezone.now()
        user.deletion_type = 'user'
        user.save()

        prompt = _login(user, self.client)
        self.assertEqual(prompt.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(prompt.data['data']['reactivatable'])

        restored = _login(user, self.client, reactivate=True)
        self.assertEqual(restored.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.is_active)

    def test_suspended_user_cannot_refresh(self):
        user = _standing_user('suspended-refresh@example.com')
        refresh, _access = self._session_and_tokens(user)
        apply_standing_action(
            target_user_id=user.id, action='user_suspended', reason='spam',
        )

        res = self.client.post(REFRESH_URL, {'refresh': refresh}, format='json')

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['standing']['state'], 'suspended')
        self.assertNotIn('access', res.data.get('data') or {})

    def test_already_issued_access_token_stops_working(self):
        user = _standing_user('suspended-drf@example.com')
        _refresh, access = self._session_and_tokens(user)

        ok = self.client.get('/api/v1/auth/sessions/',
                             HTTP_AUTHORIZATION=f'Bearer {access}')
        self.assertEqual(ok.status_code, status.HTTP_200_OK)

        apply_standing_action(
            target_user_id=user.id, action='user_banned', reason='fraud',
        )

        blocked = self.client.get('/api/v1/auth/sessions/',
                                  HTTP_AUTHORIZATION=f'Bearer {access}')
        self.assertEqual(blocked.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_warned_user_logs_in_normally(self):
        user = _standing_user('warned@example.com')
        AccountStanding.objects.create(
            user=user, state=AccountStanding.STATE_WARNED, reason='first warning',
            is_moderation_action=True,
        )

        res = _full_login(user, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access', res.data['data'])

    def test_expired_suspension_self_clears(self):
        user = _standing_user('lapsed@example.com')
        apply_standing_action(
            target_user_id=user.id, action='user_suspended',
            reason='7 days', duration_days=7,
        )
        standing = AccountStanding.objects.get(user=user)
        AccountStanding.objects.filter(pk=standing.pk).update(
            suspended_until=timezone.now() - timedelta(minutes=1),
        )

        res = _full_login(user, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access', res.data['data'])
        standing.refresh_from_db()
        self.assertEqual(standing.state, AccountStanding.STATE_CLEAR)
        self.assertIsNone(standing.suspended_until)
        user.refresh_from_db()
        self.assertTrue(user.is_active, 'a lapsed suspension hands the account back')

    def test_social_login_funnel_refuses_a_suspended_user(self):
        """_finalize_social_login is the shared Google/Apple/passkey funnel."""
        from unittest import mock

        from . import views as accounts_views

        user = _standing_user('suspended-social@example.com')
        apply_standing_action(
            target_user_id=user.id, action='user_suspended', reason='spam',
        )
        request = APIClient().post('/').wsgi_request

        with self.assertRaises(accounts_views._StandingBlocked) as ctx:
            accounts_views._finalize_social_login(user, 'google', request)

        self.assertEqual(ctx.exception.response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(
            DeviceSession.objects.filter(user=user).exists(),
            'no session may be created for a suspended account',
        )


class TotpSecretEncryptionTests(TestCase):
    """The seed must not sit in the table — or in the admin — in clear."""

    def setUp(self):
        self.user = _standing_user('secret@example.com')
        self.plain = 'JBSWY3DPEHPK3PXP'

    def _raw_secret(self, user):
        """The value as it physically sits in the column.

        Raw SQL because the ORM decrypts on read, which is the whole point.
        Matched on email so it is backend-agnostic (SQLite stores UUIDs as
        dashless hex, Postgres as a native uuid column).
        """
        with connection.cursor() as cursor:
            cursor.execute(
                'SELECT totp_secret FROM accounts_user WHERE email = %s', [user.email],
            )
            row = cursor.fetchone()
        self.assertIsNotNone(row, 'the account row was not found')
        return row[0]

    def test_secret_round_trips_through_encryption(self):
        self.user.totp_secret = self.plain
        self.user.totp_enabled = True
        self.user.save()

        raw = self._raw_secret(self.user)
        self.assertNotEqual(raw, self.plain)
        self.assertNotIn(self.plain, raw)
        self.assertTrue(raw.startswith('f1:'))

        self.user.refresh_from_db()
        self.assertEqual(self.user.totp_secret, self.plain)

    def test_challenges_still_verify_with_an_encrypted_secret(self):
        import pyotp

        self.user.totp_secret = self.plain
        self.user.totp_enabled = True
        self.user.save()
        self.user.refresh_from_db()

        self.assertTrue(pyotp.TOTP(self.user.totp_secret).verify(
            pyotp.TOTP(self.plain).now()))

    def test_legacy_plaintext_value_is_readable_and_encrypted_on_write(self):
        User.objects.filter(pk=self.user.pk).update(totp_secret=self.plain)

        self.user.refresh_from_db()
        self.assertEqual(self.user.totp_secret, self.plain)

        self.user.save(update_fields=['totp_secret'])
        self.assertTrue(self._raw_secret(self.user).startswith('f1:'))

    def test_admin_fieldset_does_not_expose_the_secret(self):
        from .admin import UserAdmin

        rendered = repr(UserAdmin.fieldsets) + repr(UserAdmin.add_fieldsets)
        self.assertNotIn('totp_secret', rendered)
        self.assertIn('totp_enabled', rendered)


class StaffMfaEnrolmentTests(_CacheClearingMixin, TestCase):
    """Staff cannot hold a session without a second factor."""

    def setUp(self):
        super().setUp()
        self.client = APIClient()

    def test_staff_without_totp_cannot_complete_login(self):
        staff = _standing_user('staff-mfa@example.com', is_staff=True)

        res = _full_login(staff, self.client)

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['code'], 'mfa_enrolment_required')
        self.assertNotIn('access', res.data['data'])
        self.assertFalse(
            DeviceSession.objects.filter(user=staff).exists(),
            'no session may be created before enrolment',
        )

    def test_superuser_is_covered_too(self):
        su = _standing_user('su-mfa@example.com', is_superuser=True)

        res = _full_login(su, self.client)

        self.assertEqual(res.data.get('code'), 'mfa_enrolment_required')

    def test_staff_with_totp_gets_the_normal_challenge(self):
        staff = _standing_user('staff-ok@example.com', is_staff=True)
        staff.totp_secret = 'JBSWY3DPEHPK3PXP'
        staff.totp_enabled = True
        staff.save()

        res = _full_login(staff, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['data']['require_totp'])

    def test_refresh_is_blocked_for_staff_without_totp(self):
        staff = _standing_user('staff-refresh@example.com', is_staff=True)
        refresh = str(RefreshToken.for_user(staff))
        DeviceSession.objects.create(
            user=staff, refresh_token_hash=hashlib.sha256(refresh.encode()).hexdigest(),
            device_name='Laptop', ip_address='127.0.0.1',
        )

        res = self.client.post(REFRESH_URL, {'refresh': refresh}, format='json')

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['code'], 'mfa_enrolment_required')

    def test_non_staff_login_is_unaffected(self):
        user = _standing_user('plain-mfa@example.com')

        res = _full_login(user, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access', res.data['data'])


class RecoveryCodeLoginTests(_CacheClearingMixin, TestCase):
    """The documented recovery path actually works end to end."""

    def setUp(self):
        super().setUp()
        self.client = APIClient()
        self.user = _standing_user('recovery@example.com')
        self.user.totp_secret = 'JBSWY3DPEHPK3PXP'
        self.user.totp_enabled = True
        self.user.save()
        self.plain_code = 'ABCDE-FGHIJ'
        RecoveryCode.objects.create(
            user=self.user,
            code_hash=RecoveryCode.hash_code(self.plain_code),
        )

    def _challenge(self):
        first = self.client.post(LOGIN_URL, {
            'email': self.user.email, 'password': 'TestPass123!',
        }, format='json')
        otp = OTPToken.objects.filter(user=self.user, channel='email', is_used=False).latest('created_at').code
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': otp,
        }, format='json')
        self.assertTrue(verified.data['data']['require_totp'])
        return verified.data['data']['temp_token']

    def test_recovery_code_login_succeeds(self):
        temp_token = self._challenge()

        res = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token, 'recovery_code': self.plain_code,
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.assertIn('access', res.data['data'])
        self.assertTrue(res.data['data']['recovery_code_used'])
        self.assertTrue(RecoveryCode.objects.filter(
            user=self.user, is_used=True).exists())

    def test_recovery_code_is_single_use(self):
        temp_token = self._challenge()
        first = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token, 'recovery_code': self.plain_code,
        }, format='json')
        self.assertEqual(first.status_code, status.HTTP_200_OK)

        replay = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token, 'recovery_code': self.plain_code,
        }, format='json')

        self.assertEqual(replay.status_code, status.HTTP_400_BAD_REQUEST)

    def test_authenticator_code_still_works(self):
        import pyotp

        temp_token = self._challenge()

        res = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token,
            'code': pyotp.TOTP('JBSWY3DPEHPK3PXP').now(),
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.assertNotIn('recovery_code_used', res.data['data'])

    def test_neither_or_both_is_rejected(self):
        temp_token = self._challenge()

        neither = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token,
        }, format='json')
        both = self.client.post(TOTP_CHALLENGE_URL, {
            'temp_token': temp_token,
            'code': '123456',
            'recovery_code': self.plain_code,
        }, format='json')

        self.assertEqual(neither.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(both.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(RecoveryCode.objects.filter(
            user=self.user, is_used=True).exists())


class LoginLockoutTests(_CacheClearingMixin, TestCase):
    """Five failures lock the account; a success clears the counter."""

    def setUp(self):
        super().setUp()
        self.client = APIClient()
        self.user = _standing_user('lockout@example.com')

    def _fail(self, times=1, password='WrongPass123!'):
        for _ in range(times):
            return_value = self.client.post(LOGIN_URL, {
                'email': self.user.email, 'password': password,
            }, format='json')
        return return_value

    def test_five_failures_lock_the_account(self):
        for _ in range(4):
            res = _login(self.user, self.client, password='WrongPass123!')
            self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        fifth = _login(self.user, self.client, password='WrongPass123!')
        self.assertEqual(fifth.status_code, status.HTTP_401_UNAUTHORIZED)
        self.user.refresh_from_db()
        self.assertEqual(self.user.failed_login_count, 5)
        self.assertIsNotNone(self.user.locked_until)

        correct = _login(self.user, self.client)
        self.assertEqual(correct.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assertIn('locked', correct.data['message'].lower())
        self.assertGreater(correct.data['data']['retry_after_seconds'], 0)

    def test_locked_out_user_cannot_reactivate_either(self):
        for _ in range(5):
            _login(self.user, self.client, password='WrongPass123!')
        self.user.refresh_from_db()
        self.user.is_active = False
        self.user.deleted_at = timezone.now()
        self.user.deletion_type = 'user'
        self.user.save()

        res = _login(self.user, self.client, reactivate=True)

        self.assertEqual(res.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.user.refresh_from_db()
        self.assertFalse(self.user.is_active)

    def test_successful_login_resets_the_counter(self):
        _login(self.user, self.client, password='WrongPass123!')
        _login(self.user, self.client, password='WrongPass123!')
        self.user.refresh_from_db()
        self.assertEqual(self.user.failed_login_count, 2)

        res = _full_login(self.user, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.failed_login_count, 0)
        self.assertIsNone(self.user.locked_until)

    def test_wrong_otp_counts_as_a_failure(self):
        """The OTP step feeds the same account-level counter as the password.

        Each OTP token has its own 3-attempt cap, so the account lock is only
        reachable across several login rounds — which is exactly why the
        counter has to live on the user and not on the token.
        """
        statuses = []
        for _ in range(5):
            first = _login(self.user, self.client)
            if first.status_code == status.HTTP_429_TOO_MANY_REQUESTS:
                statuses.append(first.status_code)
                break
            login_token = first.data['data']['login_token']
            for _ in range(2):
                res = self.client.post(VERIFY_LOGIN_OTP_URL, {
                    'login_token': login_token, 'otp': '000000',
                }, format='json')
                statuses.append(res.status_code)

        self.assertIn(status.HTTP_429_TOO_MANY_REQUESTS, statuses)
        self.user.refresh_from_db()
        self.assertGreaterEqual(self.user.failed_login_count, 5)
        self.assertIsNotNone(self.user.locked_until)

        locked = _login(self.user, self.client)
        self.assertEqual(locked.status_code, status.HTTP_429_TOO_MANY_REQUESTS)

    def test_forgot_password_stays_available_while_locked_out(self):
        for _ in range(5):
            _login(self.user, self.client, password='WrongPass123!')

        res = self.client.post('/api/v1/auth/forgot-password/',
                               {'email': self.user.email}, format='json')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['success'])
        self.assertTrue(OTPToken.objects.filter(user=self.user, channel='email').exists())

    def test_lock_lapses_once_the_window_passes(self):
        for _ in range(5):
            _login(self.user, self.client, password='WrongPass123!')
        User.objects.filter(pk=self.user.pk).update(
            locked_until=timezone.now() - timedelta(minutes=1),
        )
        self.user.refresh_from_db()

        res = _login(self.user, self.client)

        self.assertEqual(res.status_code, status.HTTP_200_OK)


class RegistrationVerifyStandingTests(_CacheClearingMixin, TestCase):
    """Completing email verification must not be a way around a suspension.

    ``VerifyRegistrationOTPView`` mints a full access+refresh pair and a
    DeviceSession exactly like a login does, so it is a fourth enforcement
    point. It is the one most easily overlooked because it does not look like
    a login — but a mass fake-account signup that gets banned before its
    email is verified would otherwise complete registration and hold a session.
    """

    def setUp(self):
        super().setUp()
        self.client = APIClient()
        self.user = _standing_user('unverified-suspended@example.com', verified=False)
        self.url = '/api/v1/auth/verify-registration-otp/'

    def _registration_token(self):
        OTPToken.objects.create(
            user=self.user, code='123456', channel='email',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        from .views import _generate_temp_token
        return _generate_temp_token(self.user, 'registration', expiry_minutes=10)

    def test_suspended_user_cannot_complete_registration(self):
        apply_standing_action(
            target_user_id=self.user.id, action='user_suspended', reason='fake signup',
        )

        res = self.client.post(
            self.url,
            {'registration_token': self._registration_token(), 'otp': '123456'},
            format='json',
        )

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['standing']['state'], 'suspended')
        self.assertEqual(res.data['standing']['reason'], 'fake signup')
        self.assertNotIn('access', res.data.get('data') or {})
        self.assertFalse(
            DeviceSession.objects.filter(user=self.user).exists(),
            'no session may be minted for a suspended account',
        )

    def test_banned_user_cannot_complete_registration(self):
        apply_standing_action(
            target_user_id=self.user.id, action='user_banned', reason='fraud',
        )

        res = self.client.post(
            self.url,
            {'registration_token': self._registration_token(), 'otp': '123456'},
            format='json',
        )

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['standing']['state'], 'banned')
        self.assertNotIn('access', res.data.get('data') or {})
        self.user.refresh_from_db()
        self.assertFalse(self.user.is_active)

    def test_unverified_user_with_clear_standing_still_completes(self):
        """The guard must not break ordinary onboarding."""
        res = self.client.post(
            self.url,
            {'registration_token': self._registration_token(), 'otp': '123456'},
            format='json',
        )

        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.assertIn('access', res.data['data'])

    def test_staff_cannot_complete_registration_without_totp(self):
        self.user.is_staff = True
        self.user.save(update_fields=['is_staff'])

        res = self.client.post(
            self.url,
            {'registration_token': self._registration_token(), 'otp': '123456'},
            format='json',
        )

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['code'], 'mfa_enrolment_required')


class AccountEventChoiceIntegrityTests(SimpleTestCase):
    """Every event the code logs must be a declared choice.

    ``Model.save()`` does not validate ``choices``, so an undeclared event
    type writes happily and then fails ``full_clean()`` — invisible in the app,
    visible as a 500 on any admin/serializer path that validates. The recovery
    branch of TOTPChallengeView logged '2fa_recovery_used', which was not in
    EVENT_CHOICES.
    """

    #: Scoped to the MFA events this change added/fixed. An AST sweep of every
    #: ``_log_event`` call also turns up pre-existing undeclared types
    #: ('registered', 'email_verified', 'age_verified', 'session_revoked',
    #: '2fa_recovery_regenerated'). Those are unrelated drift in a taxonomy other
    #: apps filter on, so widening EVENT_CHOICES for them is a separate change
    #: with its own review — flagged, not silently absorbed here.
    GUARDED = {'2fa_enabled', '2fa_disabled', '2fa_recovery_used'}

    def test_mfa_events_logged_by_the_view_are_declared_choices(self):
        import ast
        import pathlib

        from .models import AccountEvent

        declared = {choice for choice, _label in AccountEvent.EVENT_CHOICES}
        source = pathlib.Path(__file__).with_name('views.py').read_text()
        tree = ast.parse(source)

        logged = set()
        for node in ast.walk(tree):
            if (
                isinstance(node, ast.Call)
                and isinstance(node.func, ast.Name)
                and node.func.id == '_log_event'
                and len(node.args) > 1
                and isinstance(node.args[1], ast.Constant)
            ):
                logged.add(node.args[1].value)

        self.assertTrue(
            self.GUARDED <= logged,
            f'expected these MFA events to be logged: {sorted(self.GUARDED - logged)}',
        )
        undeclared = (logged & self.GUARDED) - declared
        self.assertEqual(
            undeclared, set(),
            f'_log_event writes undeclared MFA event types: {sorted(undeclared)}',
        )
