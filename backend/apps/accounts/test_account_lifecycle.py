"""Account lifecycle: reactivation, session revocation, scheduled deletion,
data export status/payload.

Complements tests.py (auth basics) with the login-driven reactivation flow,
device-session management and the hard-deletion sweep.
"""
import hashlib
import json
import shutil
import tempfile
from datetime import timedelta
from unittest import mock

import pyotp
from django.core.files.storage import FileSystemStorage
from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken, OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from .models import AccountEvent, DeviceSession, User
from apps.feed.models import Post
from apps.gamification.models import AchievementDefinition, UserAchievement
from apps.notifications.models import Notification, NotificationPreference
from apps.profiles.models import Profile

LOGIN_URL = '/api/v1/auth/login/'
DEACTIVATE_URL = '/api/v1/auth/deactivate/'
DELETE_URL = '/api/v1/auth/delete/'
SESSIONS_URL = '/api/v1/auth/sessions/'
EXPORT_STATUS_URL = '/api/v1/auth/export-data/status/'


def _make_user(email, verified=True):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.email_verified = verified
    user.save()
    Profile.objects.create(
        user=user, username=email.split('@')[0][:28], display_name='User',
    )
    return user


class TempMediaStorageMixin:
    """Pin default_storage to a throwaway directory for the test."""

    def setUp(self):
        super().setUp()
        tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, tmp, ignore_errors=True)
        patcher = mock.patch(
            'django.core.files.storage.default_storage',
            FileSystemStorage(location=tmp),
        )
        patcher.start()
        self.addCleanup(patcher.stop)


class ReactivationTests(TestCase):
    """Deactivated / scheduled-for-deletion accounts re-enter via login."""

    def setUp(self):
        self.client = APIClient()

    def _deactivate(self, user, hard_delete_at=None):
        user.is_active = False
        user.deleted_at = timezone.now()
        user.deletion_type = 'user'
        user.hard_delete_at = hard_delete_at
        user.save()

    def _login(self, user, **extra):
        payload = {'email': user.email, 'password': 'TestPass123!', **extra}
        return self.client.post(LOGIN_URL, payload, format='json')

    def test_deactivated_login_returns_reactivatable_403(self):
        user = _make_user('react@example.com')
        self._deactivate(user)

        res = self._login(user)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.data['success'])
        self.assertTrue(res.data['data']['reactivatable'])
        self.assertIsNone(res.data['data']['hard_deletion_scheduled'])
        self.assertIn('reactivate', res.data['message'].lower())

        user.refresh_from_db()
        self.assertFalse(user.is_active, 'login without opt-in must not reactivate')

    def test_scheduled_deletion_login_names_date_and_cancellation(self):
        user = _make_user('scheduled@example.com')
        self._deactivate(user, hard_delete_at=timezone.now() + timedelta(days=10))

        res = self._login(user)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(res.data['data']['reactivatable'])
        self.assertEqual(
            res.data['data']['hard_deletion_scheduled'],
            user.hard_delete_at.isoformat(),
        )
        self.assertIn('cancel', res.data['message'].lower())

    def test_reactivate_restores_account_and_continues_login(self):
        user = _make_user('restore@example.com')
        self._deactivate(user)

        res = self._login(user, reactivate=True)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['data']['require_otp'],
                        'reactivated login must continue into the OTP step')

        user.refresh_from_db()
        self.assertTrue(user.is_active)
        self.assertIsNone(user.deleted_at)
        self.assertIsNone(user.hard_delete_at)
        self.assertTrue(AccountEvent.objects.filter(
            user=user, event_type='account_reactivated').exists())

    def test_reactivate_cancels_scheduled_deletion(self):
        user = _make_user('restore2@example.com')
        self._deactivate(user, hard_delete_at=timezone.now() + timedelta(days=5))

        res = self._login(user, reactivate=True)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        user.refresh_from_db()
        self.assertTrue(user.is_active)
        self.assertIsNone(user.deleted_at)
        self.assertIsNone(user.hard_delete_at, 'reactivation must cancel the deletion')
        self.assertTrue(AccountEvent.objects.filter(
            user=user, event_type='account_reactivated').exists())

    def test_reactivated_unverified_account_enters_verification_gate(self):
        user = _make_user('restore3@example.com', verified=False)
        self._deactivate(user)

        res = self._login(user, reactivate=True)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertTrue(res.data['data']['require_email_verification'],
                        'flow must continue into the email-verification gate')

        user.refresh_from_db()
        self.assertTrue(user.is_active)
        self.assertIsNone(user.deleted_at)

    def test_wrong_password_never_reactivates(self):
        user = _make_user('wrongpw@example.com')
        self._deactivate(user)

        res = self.client.post(LOGIN_URL, {
            'email': user.email, 'password': 'NotThePassword1!', 'reactivate': True,
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        user.refresh_from_db()
        self.assertFalse(user.is_active)
        self.assertIsNotNone(user.deleted_at)
        self.assertFalse(AccountEvent.objects.filter(
            user=user, event_type='account_reactivated').exists())


class DeactivateSessionsTests(TestCase):
    """Deactivation kills every device session and refresh token."""

    def setUp(self):
        self.client = APIClient()

    def test_deactivate_revokes_sessions_and_tokens(self):
        user = _make_user('deact@example.com')
        token = RefreshToken.for_user(user)
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(str(token).encode()).hexdigest(),
            device_name='Phone', ip_address='127.0.0.1', device_id='device-a',
        )
        DeviceSession.objects.create(
            user=user,
            refresh_token_hash=hashlib.sha256(b'second').hexdigest(),
            device_name='Tablet', ip_address='10.0.0.1', device_id='device-b',
        )
        self.assertEqual(OutstandingToken.objects.filter(user=user).count(), 1)

        self.client.force_authenticate(user)
        res = self.client.post(DEACTIVATE_URL, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('reactivat', res.data['message'].lower())

        self.assertEqual(
            DeviceSession.objects.filter(user=user, is_active=True).count(), 0)
        self.assertEqual(
            BlacklistedToken.objects.filter(token__user=user).count(),
            OutstandingToken.objects.filter(user=user).count(),
        )

        user.refresh_from_db()
        self.assertFalse(user.is_active)
        self.assertIsNone(user.hard_delete_at)

        # And the account can come back through the login flow.
        self.client.force_authenticate(None)
        reactivated = self.client.post(LOGIN_URL, {
            'email': user.email, 'password': 'TestPass123!', 'reactivate': True,
        }, format='json')
        self.assertEqual(reactivated.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.is_active)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class DeleteAccountTests(TestCase):
    """Deletion requires proof (password or TOTP) and schedules a hard delete."""

    # The 30-day countdown task must NOT run inside the test (eager mode
    # ignores countdown and would hard-delete the user mid-assertion).
    # Publishing to the memory broker (no worker) keeps it pending.
    @override_settings(CELERY_TASK_ALWAYS_EAGER=False)
    def setUp(self):
        self.client = APIClient()

    def _delete(self, user, **extra):
        self.client.force_authenticate(user)
        payload = {'confirm': 'delete my account', **extra}
        return self.client.post(DELETE_URL, payload, format='json')

    def test_delete_without_password_rejected(self):
        user = _make_user('del1@example.com')
        res = self._delete(user)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['message'], 'Password confirmation required.')
        user.refresh_from_db()
        self.assertTrue(user.is_active, 'failed confirmation must not deactivate')

    def test_delete_with_wrong_password_rejected(self):
        user = _make_user('del2@example.com')
        res = self._delete(user, current_password='Nope12345!')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data['message'], 'Password confirmation required.')

    def test_delete_with_password_schedules_hard_deletion(self):
        user = _make_user('del3@example.com')
        res = self._delete(user, current_password='TestPass123!')
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        user.refresh_from_db()
        self.assertFalse(user.is_active)
        self.assertIsNotNone(user.deleted_at)
        expected = timezone.now() + timedelta(days=30)
        self.assertIsNotNone(user.hard_delete_at)
        self.assertLess(abs(user.hard_delete_at - expected), timedelta(minutes=5))
        self.assertEqual(
            res.data['data']['hard_deletion_scheduled'],
            user.hard_delete_at.isoformat(),
        )
        self.assertEqual(
            DeviceSession.objects.filter(user=user, is_active=True).count(), 0)

    def test_totp_user_can_confirm_with_totp_code(self):
        user = _make_user('del4@example.com')
        user.set_unusable_password()
        user.totp_enabled = True
        user.totp_secret = 'JBSWY3DPEHPK3PXP'
        user.save()
        code = pyotp.TOTP(user.totp_secret).now()

        res = self._delete(user, totp_code=code)
        self.assertEqual(res.status_code, status.HTTP_200_OK,
                         f'unexpected: {getattr(res, "data", None)}')
        user.refresh_from_db()
        self.assertFalse(user.is_active)

    def test_totp_wrong_code_rejected(self):
        user = _make_user('del5@example.com')
        user.set_unusable_password()
        user.totp_enabled = True
        user.totp_secret = 'JBSWY3DPEHPK3PXP'
        user.save()

        res = self._delete(user, totp_code='000000')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class SweepScheduledDeletionsTests(TestCase):
    """The daily sweep hard-deletes expired accounts and nothing else."""

    def _post(self, profile):
        return Post.objects.create(author=profile, post_type='text', body='hello')

    def test_sweep_hard_deletes_only_expired_users(self):
        expired = _make_user('sweep-expired@example.com')
        expired.is_active = False
        expired.deleted_at = timezone.now() - timedelta(days=2)
        expired.hard_delete_at = timezone.now() - timedelta(hours=1)
        expired.save()
        post = self._post(expired.profile)

        active = _make_user('sweep-active@example.com')
        active.hard_delete_at = timezone.now() - timedelta(hours=1)
        active.save()

        future = _make_user('sweep-future@example.com')
        future.is_active = False
        future.deleted_at = timezone.now() - timedelta(days=2)
        future.hard_delete_at = timezone.now() + timedelta(days=3)
        future.save()

        from .tasks import sweep_scheduled_deletions
        removed = sweep_scheduled_deletions()
        self.assertEqual(removed, 1)

        self.assertFalse(User.objects.filter(pk=expired.pk).exists())
        self.assertFalse(Profile.objects.filter(pk=expired.profile.pk).exists())
        # The author FK cascades: the post is removed with the profile.
        self.assertFalse(Post.objects.filter(pk=post.pk).exists())

        self.assertTrue(User.objects.filter(pk=active.pk).exists(),
                        'active accounts are never swept')
        self.assertTrue(User.objects.filter(pk=future.pk).exists(),
                        'future-scheduled accounts are not swept yet')

    def test_sweep_removes_deleted_user_without_profile(self):
        orphan = User.objects.create_user(email='sweep-orphan@example.com',
                                          password='TestPass123!')
        orphan.is_active = False
        orphan.deleted_at = timezone.now() - timedelta(days=2)
        orphan.hard_delete_at = timezone.now() - timedelta(hours=1)
        orphan.save()

        from .tasks import sweep_scheduled_deletions
        sweep_scheduled_deletions()
        self.assertFalse(User.objects.filter(pk=orphan.pk).exists())

    def test_delete_user_data_task_still_respects_guard(self):
        live = _make_user('guard-live@example.com')
        from .tasks import delete_user_data
        delete_user_data(str(live.id))  # deleted_at is null → untouched
        self.assertTrue(User.objects.filter(pk=live.pk).exists())

        gone = _make_user('guard-gone@example.com')
        gone.is_active = False
        gone.deleted_at = timezone.now()
        gone.save()
        delete_user_data(str(gone.id))
        self.assertFalse(User.objects.filter(pk=gone.pk).exists())


class DeviceSessionTests(TestCase):
    """is_current detection via X-Device-Id and per-session revocation."""

    def setUp(self):
        self.client = APIClient()
        self.user = _make_user('sessions@example.com')

    def _session(self, device_id, token_secret=None):
        return DeviceSession.objects.create(
            user=self.user,
            refresh_token_hash=hashlib.sha256(
                (token_secret or device_id.encode())).hexdigest(),
            device_name=f'Device {device_id}',
            ip_address='127.0.0.1',
            device_id=device_id,
        )

    def _get_sessions(self, **headers):
        self.client.force_authenticate(self.user)
        return self.client.get(SESSIONS_URL, **headers)

    def test_login_otp_verify_persists_device_id(self):
        from .models import OTPToken
        res = self.client.post(LOGIN_URL, {
            'email': self.user.email, 'password': 'TestPass123!',
        }, format='json', HTTP_X_DEVICE_ID='device-login')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        otp = OTPToken.objects.filter(
            user=self.user, channel='email', is_used=False).latest('created_at').code
        verify = self.client.post('/api/v1/auth/verify-login-otp/', {
            'login_token': res.data['data']['login_token'], 'otp': otp,
        }, format='json', HTTP_X_DEVICE_ID='device-login')
        self.assertEqual(verify.status_code, status.HTTP_200_OK)
        session = DeviceSession.objects.filter(user=self.user).latest('created_at')
        self.assertEqual(session.device_id, 'device-login')

    def test_is_current_matches_device_id_header(self):
        a = self._session('device-a')
        self._session('device-b')

        res = self._get_sessions(HTTP_X_DEVICE_ID='device-a')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        by_id = {row['id']: row for row in res.data['data']}
        self.assertTrue(by_id[str(a.id)]['is_current'])
        self.assertEqual(
            [row['is_current'] for row in res.data['data']].count(True), 1)

    def test_is_current_falls_back_to_latest_last_active(self):
        old = self._session('device-a', b'old-token')
        new = self._session('device-b', b'new-token')
        DeviceSession.objects.filter(pk=old.pk).update(
            last_active=timezone.now() - timedelta(hours=1))

        res = self._get_sessions()  # no X-Device-Id header
        by_id = {row['id']: row for row in res.data['data']}
        self.assertTrue(by_id[str(new.id)]['is_current'])
        self.assertFalse(by_id[str(old.id)]['is_current'])

    def test_revoke_session_deactivates_and_blacklists(self):
        token = RefreshToken.for_user(self.user)
        session = self._session('device-a', str(token).encode())

        self.client.force_authenticate(self.user)
        res = self.client.delete(f'{SESSIONS_URL}{session.id}/', format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['data']['revoked'])

        session.refresh_from_db()
        self.assertFalse(session.is_active)
        self.assertTrue(BlacklistedToken.objects.filter(token__jti=token['jti']).exists())

        # The blacklisted refresh token no longer refreshes.
        refresh_res = self.client.post('/api/v1/auth/token/refresh/', {
            'refresh': str(token),
        }, format='json')
        self.assertEqual(refresh_res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_revoke_other_users_session_is_404(self):
        other = _make_user('other-sessions@example.com')
        theirs = DeviceSession.objects.create(
            user=other,
            refresh_token_hash=hashlib.sha256(b'theirs').hexdigest(),
            device_name='Theirs', ip_address='127.0.0.1',
        )
        self.client.force_authenticate(self.user)
        res = self.client.delete(f'{SESSIONS_URL}{theirs.id}/', format='json')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        theirs.refresh_from_db()
        self.assertTrue(theirs.is_active)


class ExportDataTests(TempMediaStorageMixin, TestCase):
    """Expanded export payload + status endpoint + failure notification."""

    def setUp(self):
        super().setUp()
        self.client = APIClient()
        self.user = _make_user('export@example.com')

    def _seed_export_data(self):
        profile = self.user.profile
        NotificationPreference.objects.create(profile=profile)
        Notification.objects.create(
            recipient=profile, notification_type='comment',
            title='Hello', body='Hi there',
        )
        AccountEvent.objects.create(user=self.user, event_type='login')
        DeviceSession.objects.create(
            user=self.user, refresh_token_hash=hashlib.sha256(b'x').hexdigest(),
            device_name='Phone', ip_address='127.0.0.1', device_id='device-a',
        )
        from apps.analytics.models import ActivityRecord, BodyMetric, WorkoutLog
        ActivityRecord.objects.create(user=profile, activity_type='run', distance_meters=1000)
        WorkoutLog.objects.create(user=profile, exercise='Squat')
        BodyMetric.objects.create(user=profile, weight_kg=80.0)
        definition = AchievementDefinition.objects.create(
            code='first-run', title='First Run', description='Run once',
            metric='activities_total', threshold=1,
        )
        UserAchievement.objects.create(profile=profile, definition=definition)

    def test_status_not_ready_without_exports(self):
        self.client.force_authenticate(self.user)
        res = self.client.get(EXPORT_STATUS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertFalse(res.data['data']['ready'])
        self.assertIsNone(res.data['data']['filename'])

    def test_status_ready_after_export_and_payload_is_expanded(self):
        self._seed_export_data()
        from .tasks import export_user_data
        export_user_data(str(self.user.id))

        self.client.force_authenticate(self.user)
        res = self.client.get(EXPORT_STATUS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['data']['ready'])
        filename = res.data['data']['filename']
        self.assertTrue(filename.endswith('.json'))
        self.assertIn(f'exports/{self.user.profile.username}/', filename)

        from django.core.files.storage import default_storage
        with default_storage.open(filename) as f:
            payload = json.load(f)

        for key in ('notifications', 'activity_events', 'device_sessions',
                    'analytics', 'achievements'):
            self.assertIn(key, payload, f'expanded export must include {key}')

        self.assertEqual(len(payload['notifications']['recent']), 1)
        self.assertEqual(len(payload['notifications']['preferences']), 1)
        self.assertEqual(len(payload['activity_events']), 1)

        # Device metadata only — token material must never be exported.
        for session in payload['device_sessions']:
            self.assertNotIn('refresh_token_hash', session)
            self.assertEqual(session['device_id'], 'device-a')

        analytics = payload['analytics']
        for key in ('activity_records', 'workout_logs', 'body_metrics'):
            self.assertEqual(len(analytics[key]), 1, f'analytics.{key} expected')

        self.assertEqual(payload['achievements'][0]['definition__code'], 'first-run')

    def test_export_failure_emails_the_user(self):
        from .tasks import export_user_data
        success_mail = mock.MagicMock(side_effect=[Exception('smtp down'), None])
        with mock.patch('apps.accounts.tasks.send_mail', success_mail):
            export_user_data(str(self.user.id))

        self.assertEqual(success_mail.call_count, 2,
                         'user must be emailed on failure, not left waiting')
        failure_subject = success_mail.call_args_list[1].args[0]
        self.assertIn('failed', failure_subject.lower())
