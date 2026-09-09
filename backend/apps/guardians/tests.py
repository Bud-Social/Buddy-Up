"""Guardian/teen family-link system: invites, acceptance, permissions,
enforcement gates and the parental dashboard.

Complements the contract served at /api/v1/guardians/ — the web and Flutter
clients parse these envelopes, so response shapes are asserted literally.
"""
import re
from unittest import mock

from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.feed.models import Post
from apps.profiles.models import Profile

from .models import GuardianLink
from .services import (
    guardian_blocks_new_dms,
    guardian_blocks_spends,
    hash_token,
    is_minor,
)

User = get_user_model()

GUARDIANS_URL = '/api/v1/guardians/'
INVITE_URL = f'{GUARDIANS_URL}invite/'
LINKS_URL = f'{GUARDIANS_URL}links/'
DASHBOARD_URL = f'{GUARDIANS_URL}dashboard/'
ACCEPT_INVITE_URL = f'{GUARDIANS_URL}accept-invite/'
START_CONVERSATION_URL = '/api/v1/messaging/conversations/start/'
TIP_URL = '/api/v1/wallet/tip/'

PASSWORD = 'TestPass123!'


def _make_user(email, is_adult=True):
    user = User.objects.create_user(email=email, password=PASSWORD)
    user.is_adult = is_adult
    user.email_verified = True
    user.save()
    Profile.objects.create(
        user=user, username=email.split('@')[0][:28], display_name='User',
    )
    return user


class GuardianHelpersTests(TestCase):
    """services.py gate helpers."""

    def setUp(self):
        self.guardian = _make_user('helper-guardian@example.com', is_adult=True)
        self.teen = _make_user('helper-teen@example.com', is_adult=False)

    def _link(self, status='active', permissions=None):
        return GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen, status=status,
            invite_email=self.teen.email,
            permissions=permissions or {'allow_direct_messages': True,
                                        'allow_spends': True},
        )

    def test_is_minor_resolves_user_and_profile(self):
        self.assertTrue(is_minor(self.teen))
        self.assertFalse(is_minor(self.guardian))
        self.assertTrue(is_minor(self.teen.profile))
        self.assertTrue(is_minor(None) is False)

    def test_adult_is_never_blocked(self):
        self.assertFalse(guardian_blocks_spends(self.guardian))
        self.assertFalse(guardian_blocks_new_dms(self.guardian))

    def test_minor_without_link_not_blocked(self):
        self.assertFalse(guardian_blocks_spends(self.teen))
        self.assertFalse(guardian_blocks_new_dms(self.teen))

    def test_pending_link_does_not_block(self):
        self._link(status='pending', permissions={'allow_direct_messages': False,
                                                  'allow_spends': False})
        self.assertFalse(guardian_blocks_spends(self.teen))
        self.assertFalse(guardian_blocks_new_dms(self.teen))

    def test_active_link_permissions_block(self):
        self._link(permissions={'allow_direct_messages': False,
                                'allow_spends': False})
        self.assertTrue(guardian_blocks_spends(self.teen))
        self.assertTrue(guardian_blocks_new_dms(self.teen))

    def test_permissive_active_link_does_not_block(self):
        self._link()
        self.assertFalse(guardian_blocks_spends(self.teen))
        self.assertFalse(guardian_blocks_new_dms(self.teen))

    def test_hash_token_is_sha256_hex(self):
        digest = hash_token('raw-token')
        self.assertEqual(len(digest), 64)
        self.assertEqual(digest, hash_token('raw-token'))
        self.assertNotEqual(digest, hash_token('other-token'))


class GuardianInviteTests(TestCase):
    """POST /guardians/invite/ — existing teens and provisioned accounts."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('invite-guardian@example.com')

    def test_minor_cannot_invite(self):
        minor = _make_user('invite-minor@example.com', is_adult=False)
        self.client.force_authenticate(minor)
        response = self.client.post(
            INVITE_URL, {'teen_email': 'kid@example.com'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_invite_existing_user_creates_pending_link_and_emails(self):
        teen = _make_user('existing-teen@example.com', is_adult=False)
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail') as mocked_mail:
            response = self.client.post(
                INVITE_URL, {'teen_email': teen.email}, format='json',
            )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        data = response.data['data']
        self.assertEqual(data['status'], 'pending')
        self.assertEqual(data['role'], 'guardian')
        self.assertEqual(data['permissions']['allow_spends'], True)
        link = GuardianLink.objects.get(guardian=self.guardian, teen=teen)
        self.assertEqual(link.status, 'pending')
        self.assertEqual(link.invite_email, teen.email)
        self.assertEqual(link.invite_token_hash, '')
        mocked_mail.assert_called_once()
        self.assertEqual(
            mocked_mail.call_args.kwargs['recipient_list'], [teen.email],
        )

    def test_invite_existing_user_cannot_be_guardian_themselves(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.post(
            INVITE_URL, {'teen_email': self.guardian.email}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_invite_new_teen_creates_account_with_unusable_password(self):
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail') as mocked_mail:
            response = self.client.post(
                INVITE_URL,
                {'teen_email': 'fresh.teen@example.com', 'teen_name': 'Junior'},
                format='json',
            )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        teen = User.objects.get(email='fresh.teen@example.com')
        self.assertFalse(teen.is_adult)
        self.assertFalse(teen.email_verified)
        self.assertFalse(teen.has_usable_password())
        profile = teen.profile
        self.assertEqual(profile.display_name, 'Junior')
        self.assertEqual(profile.privacy_level, 'private')
        self.assertFalse(profile.onboarding_completed)
        link = GuardianLink.objects.get(teen=teen)
        self.assertEqual(link.status, 'pending')
        self.assertNotEqual(link.invite_token_hash, '')
        self.assertEqual(len(link.invite_token_hash), 64)
        message = mocked_mail.call_args.kwargs['message']
        match = re.search(r'token=([A-Za-z0-9_\-]+)', message)
        self.assertIsNotNone(match)
        self.assertEqual(hash_token(match.group(1)), link.invite_token_hash)
        self.assertIn('/settings/family/accept?token=', message)

    def test_invite_new_teen_with_adult_dob_rejected(self):
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail'):
            response = self.client.post(
                INVITE_URL,
                {'teen_email': 'adult@example.com', 'teen_dob': '2000-01-01'},
                format='json',
            )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('under 18', response.data['message'])
        self.assertFalse(User.objects.filter(email='adult@example.com').exists())

    def test_reinvite_updates_invite_email_without_duplicates(self):
        teen = _make_user('reinvite-teen@example.com', is_adult=False)
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail'):
            first = self.client.post(
                INVITE_URL, {'teen_email': teen.email}, format='json',
            )
            second = self.client.post(
                INVITE_URL, {'teen_email': teen.email}, format='json',
            )
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(GuardianLink.objects.filter(teen=teen).count(), 1)
        self.assertIn('updated', second.data['message'])

    def test_reinvite_after_revocation_reopens_link(self):
        teen = _make_user('reopened-teen@example.com', is_adult=False)
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail'):
            self.client.post(INVITE_URL, {'teen_email': teen.email}, format='json')
        link = GuardianLink.objects.get(teen=teen)
        link.status = 'revoked'
        link.save()
        with mock.patch('apps.guardians.tasks.send_mail'):
            response = self.client.post(
                INVITE_URL, {'teen_email': teen.email}, format='json',
            )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        link.refresh_from_db()
        self.assertEqual(link.status, 'pending')
        self.assertIsNone(link.accepted_at)


class GuardianLinkAcceptTests(TestCase):
    """POST /guardians/links/<id>/accept/ — teen-only acceptance."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('accept-guardian@example.com')
        self.teen = _make_user('accept-teen@example.com', is_adult=False)
        self.link = GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen,
            invite_email=self.teen.email,
        )

    def test_teen_accept_sets_active_and_guardian_verified(self):
        self.client.force_authenticate(self.teen)
        response = self.client.post(f'{LINKS_URL}{self.link.id}/accept/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.link.refresh_from_db()
        self.teen.refresh_from_db()
        self.assertEqual(self.link.status, 'active')
        self.assertIsNotNone(self.link.accepted_at)
        self.assertTrue(self.teen.guardian_verified)

    def test_accept_only_by_teen(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.post(f'{LINKS_URL}{self.link.id}/accept/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        other = _make_user('accept-other@example.com')
        self.client.force_authenticate(other)
        response = self.client.post(f'{LINKS_URL}{self.link.id}/accept/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.link.refresh_from_db()
        self.assertEqual(self.link.status, 'pending')

    def test_accept_non_pending_fails(self):
        self.link.status = 'active'
        self.link.save()
        self.client.force_authenticate(self.teen)
        response = self.client.post(f'{LINKS_URL}{self.link.id}/accept/')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class GuardianAcceptInviteTests(TestCase):
    """POST /guardians/accept-invite/ — token + password claims the account."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('token-guardian@example.com')

    def _invite_new_teen(self, email='token-teen@example.com'):
        self.client.force_authenticate(self.guardian)
        with mock.patch('apps.guardians.tasks.send_mail') as mocked_mail:
            self.client.post(INVITE_URL, {'teen_email': email}, format='json')
        message = mocked_mail.call_args.kwargs['message']
        return re.search(r'token=([A-Za-z0-9_\-]+)', message).group(1)

    def test_accept_invite_activates_account(self):
        raw_token = self._invite_new_teen()
        self.client.force_authenticate(None)
        response = self.client.post(
            ACCEPT_INVITE_URL,
            {'invite_token': raw_token, 'new_password': 'FreshPass123!'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        teen = User.objects.get(email='token-teen@example.com')
        self.teen_refresh = teen
        self.assertTrue(teen.has_usable_password())
        self.assertTrue(teen.email_verified)
        self.assertTrue(teen.guardian_verified)
        link = GuardianLink.objects.get(teen=teen)
        self.assertEqual(link.status, 'active')
        self.assertIsNotNone(link.accepted_at)
        self.assertEqual(link.invite_token_hash, '')

    def test_accept_invite_token_is_single_use(self):
        raw_token = self._invite_new_teen()
        self.client.force_authenticate(None)
        first = self.client.post(
            ACCEPT_INVITE_URL,
            {'invite_token': raw_token, 'new_password': 'FreshPass123!'},
            format='json',
        )
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        second = self.client.post(
            ACCEPT_INVITE_URL,
            {'invite_token': raw_token, 'new_password': 'FreshPass123!'},
            format='json',
        )
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)

    def test_accept_invite_invalid_token(self):
        self.client.force_authenticate(None)
        response = self.client.post(
            ACCEPT_INVITE_URL,
            {'invite_token': 'not-a-real-token', 'new_password': 'FreshPass123!'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_accept_invite_rejects_weak_password(self):
        raw_token = self._invite_new_teen()
        self.client.force_authenticate(None)
        response = self.client.post(
            ACCEPT_INVITE_URL,
            {'invite_token': raw_token, 'new_password': '123'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        teen = User.objects.get(email='token-teen@example.com')
        self.assertFalse(teen.has_usable_password())
        link = GuardianLink.objects.get(teen=teen)
        self.assertEqual(link.status, 'pending')


class GuardianPermissionsTests(TestCase):
    """PATCH /guardians/links/<id>/permissions/ — guardian-only."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('perm-guardian@example.com')
        self.teen = _make_user('perm-teen@example.com', is_adult=False)
        self.link = GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen,
            invite_email=self.teen.email,
        )

    def test_guardian_updates_permissions(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.patch(
            f'{LINKS_URL}{self.link.id}/permissions/',
            {'allow_spends': False}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['data']['permissions']['allow_spends'])
        self.assertTrue(
            response.data['data']['permissions']['allow_direct_messages'],
        )
        self.link.refresh_from_db()
        self.assertFalse(self.link.permissions['allow_spends'])
        self.assertTrue(self.link.permissions['allow_direct_messages'])

    def test_teen_and_strangers_cannot_patch(self):
        self.client.force_authenticate(self.teen)
        response = self.client.patch(
            f'{LINKS_URL}{self.link.id}/permissions/',
            {'allow_spends': False}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        other = _make_user('perm-other@example.com')
        self.client.force_authenticate(other)
        response = self.client.patch(
            f'{LINKS_URL}{self.link.id}/permissions/',
            {'allow_spends': False}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.link.refresh_from_db()
        self.assertTrue(self.link.permissions['allow_spends'])

    def test_empty_patch_rejected(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.patch(
            f'{LINKS_URL}{self.link.id}/permissions/', {}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class GuardianLinksListTests(TestCase):
    """GET /guardians/links/ — links split by requester role."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('list-guardian@example.com')
        self.teen = _make_user('list-teen@example.com', is_adult=False)
        self.link = GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen,
            invite_email=self.teen.email,
        )

    def test_list_splits_by_role_with_person_payloads(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.get(LINKS_URL)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        self.assertEqual(len(data['as_guardian']), 1)
        self.assertEqual(data['as_teen'], [])
        entry = data['as_guardian'][0]
        self.assertEqual(entry['role'], 'guardian')
        self.assertEqual(entry['status'], 'pending')
        self.assertEqual(entry['invite_email'], self.teen.email)
        self.assertEqual(entry['teen']['username'], self.teen.profile.username)
        self.assertIn('hard_deletion_scheduled', entry)
        self.assertIsNone(entry['hard_deletion_scheduled'])
        self.assertIn('guardian', entry)
        self.assertIn('accepted_at', entry)
        self.assertIn('created_at', entry)
        self.assertIn('permissions', entry)

        self.client.force_authenticate(self.teen)
        response = self.client.get(LINKS_URL)
        data = response.data['data']
        self.assertEqual(data['as_guardian'], [])
        self.assertEqual(len(data['as_teen']), 1)
        self.assertEqual(data['as_teen'][0]['role'], 'teen')
        self.assertEqual(
            data['as_teen'][0]['guardian']['username'],
            self.guardian.profile.username,
        )


class GuardianUnlinkTests(TestCase):
    """DELETE /guardians/links/<id>/ — either party revokes."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('unlink-guardian@example.com')
        self.teen = _make_user('unlink-teen@example.com', is_adult=False)
        self.link = GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen,
            invite_email=self.teen.email,
        )

    def test_guardian_revokes(self):
        self.client.force_authenticate(self.guardian)
        response = self.client.delete(f'{LINKS_URL}{self.link.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.link.refresh_from_db()
        self.assertEqual(self.link.status, 'revoked')

    def test_teen_revokes(self):
        self.client.force_authenticate(self.teen)
        response = self.client.delete(f'{LINKS_URL}{self.link.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.link.refresh_from_db()
        self.assertEqual(self.link.status, 'revoked')

    def test_third_party_cannot_revoke(self):
        other = _make_user('unlink-other@example.com')
        self.client.force_authenticate(other)
        response = self.client.delete(f'{LINKS_URL}{self.link.id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.link.refresh_from_db()
        self.assertEqual(self.link.status, 'pending')


class GuardianDashboardTests(TestCase):
    """GET /guardians/dashboard/ — per-active-teen aggregates."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('dash-guardian@example.com')
        self.teen = _make_user('dash-teen@example.com', is_adult=False)

    def test_dashboard_shape_for_active_links(self):
        link = GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen, status='active',
            invite_email=self.teen.email,
            permissions={'allow_direct_messages': True, 'allow_spends': False},
        )
        Post.objects.create(
            author=self.teen.profile, post_type='text', body='hello',
        )
        self.client.force_authenticate(self.guardian)
        response = self.client.get(DASHBOARD_URL)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        self.assertEqual(len(data), 1)
        entry = data[0]
        self.assertEqual(entry['link_id'], link.id)
        self.assertEqual(
            entry['teen']['username'], self.teen.profile.username,
        )
        self.assertIn('display_name', entry['teen'])
        self.assertIn('avatar_url', entry['teen'])
        self.assertIsInstance(entry['account_age_days'], int)
        self.assertGreaterEqual(entry['account_age_days'], 0)
        self.assertEqual(entry['posts_last_7d'], 1)
        self.assertEqual(entry['workouts_last_7d'], 0)
        self.assertEqual(entry['upcoming_sessions'], 0)
        self.assertFalse(entry['permissions']['allow_spends'])
        self.assertIn('last_active', entry)

    def test_dashboard_excludes_non_active_links(self):
        GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen, status='pending',
            invite_email=self.teen.email,
        )
        self.client.force_authenticate(self.guardian)
        response = self.client.get(DASHBOARD_URL)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'], [])

    def test_dashboard_forbidden_for_minors(self):
        minor = _make_user('dash-minor@example.com', is_adult=False)
        self.client.force_authenticate(minor)
        response = self.client.get(DASHBOARD_URL)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class EnforcementGateTests(TestCase):
    """Messaging DM gate + wallet spend gate wired to guardian permissions."""

    def setUp(self):
        self.client = APIClient()
        self.guardian = _make_user('gate-guardian@example.com')
        self.teen = _make_user('gate-teen@example.com', is_adult=False)

    def _activate(self, permissions):
        return GuardianLink.objects.create(
            guardian=self.guardian, teen=self.teen, status='active',
            invite_email=self.teen.email, permissions=permissions,
        )

    def test_dm_gate_blocks_new_conversations(self):
        self._activate({'allow_direct_messages': False, 'allow_spends': True})
        self.client.force_authenticate(self.teen)
        response = self.client.post(
            START_CONVERSATION_URL,
            {'participants': [self.guardian.profile.username]},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('co-owner', response.data['message'])

    def test_dm_gate_allows_when_permission_on(self):
        self._activate({'allow_direct_messages': True, 'allow_spends': True})
        self.client.force_authenticate(self.teen)
        response = self.client.post(
            START_CONVERSATION_URL,
            {'participants': [self.guardian.profile.username]},
            format='json',
        )
        # The gate passed: any later rejection is buddy-gating, not the
        # parental co-owner block.
        self.assertNotIn('co-owner', response.data['message'])

    def test_spend_gate_blocks_tips(self):
        self._activate({'allow_direct_messages': True, 'allow_spends': False})
        self.client.force_authenticate(self.teen)
        response = self.client.post(
            TIP_URL,
            {
                'username': self.guardian.profile.username,
                'artifact_type': 'dumbbell',
                'quantity': 1,
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('co-owner', response.data['message'])

    def test_spend_gate_allows_when_permission_on(self):
        self._activate({'allow_direct_messages': True, 'allow_spends': True})
        self.client.force_authenticate(self.teen)
        response = self.client.post(
            TIP_URL,
            {
                'username': self.guardian.profile.username,
                'artifact_type': 'dumbbell',
                'quantity': 1,
            },
            format='json',
        )
        # Gate passed; the transfer itself fails on balance, not permission.
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_revoked_link_does_not_block(self):
        link = self._activate({'allow_direct_messages': False,
                               'allow_spends': False})
        link.status = 'revoked'
        link.save()
        self.client.force_authenticate(self.teen)
        response = self.client.post(
            TIP_URL,
            {
                'username': self.guardian.profile.username,
                'artifact_type': 'dumbbell',
                'quantity': 1,
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
