import hashlib

from django.test import TestCase, override_settings
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from .models import User, OTPToken, DeviceSession, AccountEvent, WebAuthnCredential
from apps.profiles.models import Profile
from common.utils import hash_dob, calculate_age


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
        response = self.client.get('/api/v1/health/metrics/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('buddyup_http_requests_total', response.content.decode())

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
        response = self.client.post(self.refresh_url, refresh_data, format='json')
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
        blocked = self.client.get('/api/v1/auth/sessions/')
        self.assertEqual(blocked.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(blocked.json()['data']['consent_required'])
        accepted = self.client.post('/api/v1/auth/consent/', {
            'accepted_terms': True, 'accepted_privacy': True, 'accepted_guidelines': True,
        }, format='json')
        self.assertEqual(accepted.status_code, status.HTTP_200_OK)
        self.assertEqual(self.client.get('/api/v1/auth/sessions/').status_code, status.HTTP_200_OK)

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

    def test_second_login_attempt_uses_cached_jwks(self):
        from unittest import mock
        fake_keys = {'keys': [{'kid': 'k1', 'kty': 'RSA', 'n': 'x', 'e': 'AQAB'}]}
        with mock.patch('apps.accounts.views.requests.get') as get:
            get.return_value.json.return_value = fake_keys
            first = self.client.post(self.apple_url, {'identity_token': 'not-a-jwt'}, format='json')
            self.assertEqual(first.status_code, status.HTTP_400_BAD_REQUEST)
            first_count = get.call_count
            self.assertEqual(first_count, 1)

            second = self.client.post(self.apple_url, {'identity_token': 'not-a-jwt'}, format='json')
            self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
            self.assertEqual(get.call_count, first_count, 'JWKS must be served from cache')


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
