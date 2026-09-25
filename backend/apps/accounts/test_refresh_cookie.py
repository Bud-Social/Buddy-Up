"""Refresh-token httpOnly cookie flow (web clients).

Web keeps the refresh token out of localStorage: the backend sets it as an
httpOnly cookie on every login/refresh, the refresh endpoint prefers the
cookie (and NEVER echoes the rotated token to a cookie client), and logout
clears it. Native clients continue to use the JSON body.

Also covers the websocket token carrier: the Sec-WebSocket-Protocol
subprotocol must win over the legacy ?token= query parameter, and the token
must be stripped from scope so it is never echoed back in the handshake.
"""
import hashlib

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from .models import DeviceSession, OTPToken, User
from .views import REFRESH_COOKIE_NAME
from apps.profiles.models import Profile

LOGIN_URL = '/api/v1/auth/login/'
REFRESH_URL = '/api/v1/auth/token/refresh/'
LOGOUT_URL = '/api/v1/auth/logout/'


def _make_user(email, verified=True):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.email_verified = verified
    user.save()
    Profile.objects.create(
        user=user,
        username=email.split('@')[0].replace('-', '_').replace('.', '_')[:24] or 'buddy',
        display_name='Test User',
    )
    return user


class RefreshCookieTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_verify_login_otp_sets_httponly_auth_scoped_cookie(self):
        _make_user('cookie-login@example.com')
        login_res = self.client.post(LOGIN_URL, {
            'email': 'cookie-login@example.com', 'password': 'TestPass123!',
        }, format='json', HTTP_X_DEVICE_ID='device-a')
        self.assertEqual(login_res.status_code, status.HTTP_200_OK)
        self.assertTrue(login_res.data['data']['require_otp'])

        otp = OTPToken.objects.get(
            user=User.objects.get(email='cookie-login@example.com'),
            channel='email', is_used=False,
        ).code
        verify_res = self.client.post('/api/v1/auth/verify-login-otp/', {
            'login_token': login_res.data['data']['login_token'],
            'otp': otp,
        }, format='json', HTTP_X_DEVICE_ID='device-a')
        self.assertEqual(verify_res.status_code, status.HTTP_200_OK)

        cookie = verify_res.cookies[REFRESH_COOKIE_NAME]
        self.assertTrue(cookie['httponly'])
        self.assertEqual(cookie['path'], '/auth/')
        self.assertNotEqual(cookie.value, '')
        # The JSON body still carries the token for native clients.
        self.assertIn('refresh', verify_res.data['data'])

    def test_cookie_refresh_returns_access_only_and_rotates_cookie(self):
        user = _make_user('cookie-refresh@example.com')
        refresh_str = str(RefreshToken.for_user(user))
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest(),
            device_name='Test', ip_address='127.0.0.1',
        )

        self.client.cookies[REFRESH_COOKIE_NAME] = refresh_str
        res = self.client.post(
            REFRESH_URL, {}, format='json', HTTP_X_DEVICE_ID='device-a')

        self.assertEqual(res.status_code, status.HTTP_200_OK)
        # Access token in the body; the rotated refresh token must NOT be
        # readable by web JS — it only travels in the new Set-Cookie.
        self.assertIn('access', res.data['data'])
        self.assertNotIn('refresh', res.data['data'])
        new_cookie = res.cookies[REFRESH_COOKIE_NAME]
        self.assertTrue(new_cookie['httponly'])
        self.assertNotEqual(new_cookie.value, refresh_str)

        # The session hash now points at the rotated cookie token.
        session = DeviceSession.objects.get(user=user)
        self.assertEqual(
            session.refresh_token_hash,
            hashlib.sha256(new_cookie.value.encode()).hexdigest(),
        )

    def test_cookie_refresh_without_device_header_is_rejected(self):
        user = _make_user('cookie-csrf@example.com')
        refresh_str = str(RefreshToken.for_user(user))
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest(),
            device_name='Test', ip_address='127.0.0.1',
        )

        self.client.cookies[REFRESH_COOKIE_NAME] = refresh_str
        res = self.client.post(REFRESH_URL, {}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        # Nothing was rotated or blacklisted.
        session = DeviceSession.objects.get(user=user)
        self.assertTrue(session.is_active)

    def test_body_refresh_still_returns_refresh_for_native_clients(self):
        user = _make_user('body-refresh@example.com')
        refresh_str = str(RefreshToken.for_user(user))
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest(),
            device_name='Test', ip_address='127.0.0.1',
        )

        res = self.client.post(REFRESH_URL, {'refresh': refresh_str}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access', res.data['data'])
        self.assertIn('refresh', res.data['data'])

    def test_logout_clears_cookie_and_deactivates_session_without_auth(self):
        user = _make_user('cookie-logout@example.com')
        refresh_str = str(RefreshToken.for_user(user))
        session = DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(refresh_str.encode()).hexdigest(),
            device_name='Test', ip_address='127.0.0.1',
        )

        # No Authorization header at all — cookie-only logout must work.
        self.client.cookies[REFRESH_COOKIE_NAME] = refresh_str
        res = self.client.post(LOGOUT_URL, {}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        cleared = res.cookies[REFRESH_COOKIE_NAME]
        self.assertEqual(cleared.value, '')
        session.refresh_from_db()
        self.assertFalse(session.is_active)

        # The cookie token can no longer refresh.
        self.client.cookies[REFRESH_COOKIE_NAME] = refresh_str
        res = self.client.post(
            REFRESH_URL, {}, format='json', HTTP_X_DEVICE_ID='device-a')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


class WsSubprotocolTokenTests(TestCase):
    """WebSocket token carrier: subprotocol preferred, query kept for native."""

    def test_subprotocol_token_is_extracted_and_stripped(self):
        from apps.messaging.auth import get_token_from_scope

        scope = {'query_string': b'', 'subprotocols': [b'bearer', b'aa.bb_cc']}
        token = get_token_from_scope(scope)
        self.assertEqual(token, 'aa.bb_cc')
        # The raw token must never survive in scope (echoed in handshake).
        self.assertEqual(scope['subprotocols'], [b'bearer'])

    def test_query_token_fallback_still_works(self):
        from apps.messaging.auth import get_token_from_scope

        scope = {'query_string': b'x=1&token=abc.def', 'subprotocols': []}
        self.assertEqual(get_token_from_scope(scope), 'abc.def')

    def test_no_token(self):
        from apps.messaging.auth import get_token_from_scope

        self.assertIsNone(get_token_from_scope({'query_string': b'', 'subprotocols': []}))
