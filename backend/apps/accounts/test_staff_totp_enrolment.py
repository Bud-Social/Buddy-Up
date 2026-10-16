"""The staff 2FA enrolment flow, end to end.

This exists because the flow used to be a dead end, and it is not obvious from
any single view that it is one:

* staff are required to have two-factor authentication;
* until they do, ``_check_staff_mfa`` refuses to mint a session at login or at
  token refresh;
* but ``/totp/setup`` and ``/totp/verify`` are ``IsAuthenticated``.

Refusing the session therefore refused the enrolment. A staff account created
before the requirement existed could not reach the console, could not reach the
setup screen, and the only remaining route was a password reset -- which does
not enrol anything. There was no way back in at all.

The fix mints a scoped enrolment credential, but only *after* the email OTP has
been verified. That ordering is the whole point and it is asserted here: the
credential proves the caller holds the password *and* can read mail at the
account's address, which is the same bar the platform sets for a password reset.
"""
import hashlib
from datetime import timedelta

import pyotp
from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import DeviceSession, OTPToken, User
from apps.accounts.tests import (
    LOGIN_URL,
    REFRESH_URL,
    VERIFY_LOGIN_OTP_URL,
    _CacheClearingMixin,
)

TOTP_SETUP_URL = '/api/v1/auth/totp/setup/'
TOTP_VERIFY_URL = '/api/v1/auth/totp/verify/'
ENROLMENT_HEADER = 'HTTP_X_TOTP_ENROLMENT_TOKEN'
# The wire name a client actually sends.
HEADER_NAME = 'X-TOTP-Enrolment-Token'


def _staff(email='enrol@example.com', is_staff=True, totp_enabled=False):
    user = User.objects.create_user(
        email=email,
        password='TestPass123!',
        is_staff=is_staff,
        email_verified=True,
        is_adult=True,
        dob_hash='x' * 64,
    )
    user.totp_enabled = totp_enabled
    if totp_enabled:
        user.totp_secret = pyotp.random_base32()
    user.save()
    return user


def _login(client, user, password='TestPass123!'):
    """Password step only. Returns the response carrying the login_token."""
    res = client.post(
        LOGIN_URL, {'email': user.email, 'password': password}, format='json')
    return res


def _otp_for(user):
    return OTPToken.objects.filter(
        user=user, channel='email', is_used=False).latest('created_at').code


class StaffEnrolmentFlowTests(_CacheClearingMixin, TestCase):
    def setUp(self):
        super().setUp()
        self.client = APIClient()

    # -- the ordering the user asked for -------------------------------------

    def test_login_sends_an_email_otp_before_anything_about_2fa(self):
        """The identity proof comes first. Nothing about MFA is offered yet."""
        staff = _staff()

        res = _login(self.client, staff)

        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.assertTrue(res.data['data']['require_otp'])
        self.assertTrue(
            OTPToken.objects.filter(user=staff, channel='email', is_used=False).exists(),
            'an OTP must be sent to the account address before any 2FA prompt',
        )
        # Crucially: no mention of 2FA, and no enrolment credential, yet.
        self.assertNotIn('enrolment_token', res.data['data'])

    def test_no_enrolment_credential_is_issued_before_the_otp(self):
        """A password alone must not be enough to start enrolling."""
        staff = _staff()

        first = _login(self.client, staff)

        body = str(first.data)
        self.assertNotIn('enrolment_token', body)
        self.assertNotIn('totp_enrolment', body)

    def test_a_wrong_otp_yields_no_enrolment_credential(self):
        staff = _staff()
        first = _login(self.client, staff)

        res = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': '000000',
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertNotIn('enrolment_token', str(res.data))

    # -- after a verified OTP ------------------------------------------------

    def test_verified_otp_yields_the_credential_and_the_redirect(self):
        staff = _staff()
        first = _login(self.client, staff)

        res = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)
        self.assertEqual(res.data['code'], 'mfa_enrolment_required')
        self.assertIn('enrolment_token', res.data['data'])
        self.assertEqual(res.data['data']['enrolment_path'], TOTP_SETUP_URL)
        # Still no session. The credential is not a login.
        self.assertNotIn('access', res.data['data'])
        self.assertFalse(DeviceSession.objects.filter(user=staff).exists())

    def test_the_credential_completes_enrolment_end_to_end(self):
        """Password -> email OTP -> 2FA setup -> challenge -> a real session."""
        staff = _staff()
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        setup = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
        self.assertEqual(setup.status_code, status.HTTP_200_OK, setup.data)
        secret = setup.data['data']['secret']
        self.assertIn('qr_code', setup.data['data'])

        confirm = self.client.post(
            TOTP_VERIFY_URL,
            {'secret': secret, 'code': pyotp.TOTP(secret).now()},
            format='json',
            HTTP_X_TOTP_ENROLMENT_TOKEN=token,
        )
        self.assertEqual(confirm.status_code, status.HTTP_200_OK, confirm.data)
        self.assertEqual(len(confirm.data['data']['recovery_codes']), 10)

        staff.refresh_from_db()
        self.assertTrue(staff.totp_enabled)

        # And now they can actually sign in.
        second = APIClient()
        login = _login(second, staff)
        challenge = second.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': login.data['data']['login_token'],
            'otp': _otp_for(staff),
        }, format='json')
        self.assertEqual(challenge.status_code, status.HTTP_200_OK, challenge.data)
        self.assertTrue(challenge.data['data']['require_totp'])
        self.assertIn('temp_token', challenge.data['data'])

    # -- what the credential must NOT do ------------------------------------

    def test_the_credential_is_refused_once_totp_is_enabled(self):
        """Spent the moment enrolment succeeds. No re-running, no secret reset."""
        staff = _staff()
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        staff.totp_enabled = True
        staff.totp_secret = pyotp.random_base32()
        staff.save()

        res = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED, res.data)

    def test_the_credential_grants_nothing_outside_enrolment(self):
        """The important one: it must not be a backdoor to the platform."""
        staff = _staff()
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        for url in (
            '/api/v1/profiles/me/',
            '/api/v1/gyms/',
            '/api/v1/portal/users/',
            '/api/v1/feed/',
        ):
            with self.subTest(url=url):
                res = self.client.get(url, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
                self.assertIn(res.status_code, (401, 403), f'{url} -> {res.status_code}')

    def test_the_credential_is_not_accepted_as_an_access_token(self):
        staff = _staff()
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        res = self.client.get(
            '/api/v1/profiles/me/',
            HTTP_AUTHORIZATION=f'Bearer {token}',
        )
        self.assertIn(res.status_code, (401, 403))

    def test_the_credential_cannot_be_exchanged_at_the_refresh_endpoint(self):
        """It is a RefreshToken; refresh must not turn it into a session."""
        staff = _staff()
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        res = self.client.post(REFRESH_URL, {'refresh': token}, format='json')
        self.assertNotEqual(res.status_code, status.HTTP_200_OK)
        self.assertNotIn('access', str(res.data))

    def test_a_login_token_is_not_accepted_as_an_enrolment_credential(self):
        """Purpose is checked. One temp token cannot be replayed as another."""
        staff = _staff()
        first = _login(self.client, staff)
        login_token = first.data['data']['login_token']

        res = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=login_token)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_a_plain_user_is_never_issued_an_enrolment_credential(self):
        user = _staff(email='plain-enrol@example.com', is_staff=False)

        res = APIClient().post(LOGIN_URL, {
            'email': user.email, 'password': 'TestPass123!',
        }, format='json')
        body = str(res.data)
        self.assertNotIn('enrolment_token', body)
        self.assertNotIn('mfa_enrolment_required', body)

    def test_refresh_does_not_issue_one(self):
        """A refresh means a session already exists: nothing to bootstrap, and
        issuing one would be a standing bypass for pre-existing staff sessions."""
        staff = _staff(email='refresh-enrol@example.com')
        refresh = str(__import__(
            'rest_framework_simplejwt.tokens', fromlist=['RefreshToken'],
        ).RefreshToken.for_user(staff))
        DeviceSession.objects.create(
            user=staff, refresh_token_hash=hashlib.sha256(refresh.encode()).hexdigest(),
            device_name='Laptop', ip_address='127.0.0.1',
        )

        res = self.client.post(REFRESH_URL, {'refresh': refresh}, format='json')

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertNotIn('enrolment_token', str(res.data))

    def test_a_suspended_staff_member_cannot_enrol(self):
        """Standing is still enforced on this path, exactly as at login."""
        from apps.accounts.models import AccountStanding

        staff = _staff(email='banned-enrol@example.com')
        first = _login(self.client, staff)
        verified = self.client.post(VERIFY_LOGIN_OTP_URL, {
            'login_token': first.data['data']['login_token'], 'otp': _otp_for(staff),
        }, format='json')
        token = verified.data['data']['enrolment_token']

        AccountStanding.objects.create(
            user=staff, state=AccountStanding.STATE_SUSPENDED,
            reason='under review', is_moderation_action=True,
        )

        res = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
        self.assertIn(res.status_code, (401, 403))

    def test_the_expired_credential_stops_working(self):
        """Ten minutes, as the response advertises."""
        from apps.accounts.views import TOTP_ENROLMENT_PURPOSE, _generate_temp_token

        token = _generate_temp_token(
            _staff(email='expired-enrol@example.com'), TOTP_ENROLMENT_PURPOSE,
            expiry_minutes=-1,
        )

        res = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED, res.data)

    def test_a_garbled_credential_is_refused_rather_than_crashing(self):
        res = self.client.get(
            TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN='not-a-token-at-all')

        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


class StaffEnrolmentAfterRegistrationTests(_CacheClearingMixin, TestCase):
    """Staff who are still email-unverified must reach the enrolment screen too.

    The MFA gate used to sit *before* the registration OTP was checked. That was
    broken twice over: it fired before the one action that would have proved who
    the caller was, and it fired with no way forward. A staff member who had
    registered and never confirmed their address could not confirm it, and was
    then stuck with neither a session nor a way to enrol.

    Three of the four administrator accounts promoted this session were in
    exactly that state, which is how it surfaced.

    The flow driven here is the real one: register, get promoted to staff, then
    confirm the address.
    """

    REGISTER_URL = '/api/v1/auth/register/'
    REG_OTP_URL = '/api/v1/auth/verify-registration-otp/'
    EMAIL = 'freshly-promoted@example.com'
    PASSWORD = 'Str0ngPass!23'

    def setUp(self):
        super().setUp()
        self.client = APIClient()
        self.registration_token = self._register()

    def _register(self):
        res = self.client.post(self.REGISTER_URL, {
            'email': self.EMAIL,
            'password': self.PASSWORD,
            'dob': '1990-04-02',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED, res.data)
        return res.data['data']['registration_token']

    def _promote_to_staff(self):
        """The real sequence: a normal signup, promoted later."""
        self.staff = User.objects.get(email__iexact=self.EMAIL)
        self.staff.is_staff = True
        self.staff.save(update_fields=['is_staff'])
        return self.staff

    def _otp(self):
        return OTPToken.objects.filter(
            user__email__iexact=self.EMAIL, channel='email', is_used=False,
        ).latest('created_at').code

    def _verify(self, otp=None):
        return self.client.post(self.REG_OTP_URL, {
            'registration_token': self.registration_token,
            'otp': otp or self._otp(),
        }, format='json')

    def test_a_wrong_otp_does_not_reach_the_mfa_gate(self):
        """Nothing about 2FA is offered until the address is actually proven."""
        self._promote_to_staff()

        res = self._verify(otp='000000')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST, res.data)
        self.assertNotIn('enrolment_token', str(res.data))
        self.staff.refresh_from_db()
        self.assertFalse(self.staff.email_verified)

    def test_verifying_the_address_yields_the_enrolment_credential(self):
        self._promote_to_staff()

        res = self._verify()

        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN, res.data)
        self.assertEqual(res.data['code'], 'mfa_enrolment_required')
        self.assertIn('enrolment_token', res.data['data'])
        self.assertNotIn('access', res.data['data'])

    def test_the_address_is_still_marked_verified_before_the_block(self):
        """The proof landed. Refusing a session must not undo it, or the operator
        would have to re-enter the OTP on every attempt."""
        self._promote_to_staff()

        self._verify()

        self.staff.refresh_from_db()
        self.assertTrue(self.staff.email_verified)

    def test_the_credential_enrols_end_to_end_from_registration(self):
        res = self._verify_after_promotion()
        token = res.data['data']['enrolment_token']

        setup = self.client.get(TOTP_SETUP_URL, HTTP_X_TOTP_ENROLMENT_TOKEN=token)
        self.assertEqual(setup.status_code, status.HTTP_200_OK, setup.data)

        secret = setup.data['data']['secret']
        confirm = self.client.post(
            TOTP_VERIFY_URL,
            {'secret': secret, 'code': pyotp.TOTP(secret).now()},
            format='json',
            HTTP_X_TOTP_ENROLMENT_TOKEN=token,
        )
        self.assertEqual(confirm.status_code, status.HTTP_200_OK, confirm.data)

        self.staff.refresh_from_db()
        self.assertTrue(self.staff.totp_enabled)

    def _verify_after_promotion(self):
        self._promote_to_staff()
        return self._verify()

    def test_a_non_staff_unverified_user_still_gets_a_session(self):
        """The move must not have cost ordinary signups their tokens."""
        res = self._verify()

        self.assertEqual(res.status_code, status.HTTP_200_OK, res.data)
        self.assertIn('access', res.data['data'])

    def test_already_verified_is_still_refused(self):
        self._promote_to_staff()
        self._verify()
        # Second attempt with a fresh OTP: the address is already proven, so the
        # useful message is the pre-existing one, not an enrolment offer.
        otp = OTPToken.objects.create(
            user=self.staff, code='123456', channel='email',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        res = self.client.post(self.REG_OTP_URL, {
            'registration_token': self.registration_token, 'otp': otp.code,
        }, format='json')

        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('already verified', str(res.data).lower())
