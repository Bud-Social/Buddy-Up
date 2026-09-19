"""Tests for buddy alarm sharing (apps.alarms)."""

import shutil
import tempfile
from unittest import mock

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.alarms.models import Alarm, AlarmShare, AlarmSound, AlarmSuggestion
from apps.profiles.models import BuddyRelationship, Profile


def _make_user(email, username=None):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.is_adult = True
    user.email_verified = True
    user.save()
    return Profile.objects.create(
        user=user,
        username=username or email.split('@')[0],
        display_name=username or email.split('@')[0],
    )


def _make_buddies(a, b):
    BuddyRelationship.objects.create(from_user=a, to_user=b, status='confirmed')


def _audio(name='tone.mp3', size=1024):
    return SimpleUploadedFile(
        name, b'\x49\x44\x33' + b'\x00' * size, content_type='audio/mpeg',
    )


def payload(res):
    """Unwrap the repo-standard {success, data, ...} envelope."""
    return res.json()['data']


class AlarmSharingTests(TestCase):
    def setUp(self):
        self.sender = _make_user('sender@test.com', 'sender')
        self.recipient = _make_user('recipient@test.com', 'recipient')
        self.stranger = _make_user('stranger@test.com', 'stranger')
        _make_buddies(self.sender, self.recipient)
        self.sender_client = APIClient()
        self.sender_client.force_authenticate(self.sender.user)
        self.recipient_client = APIClient()
        self.recipient_client.force_authenticate(self.recipient.user)
        self.stranger_client = APIClient()
        self.stranger_client.force_authenticate(self.stranger.user)

    def _create_sound(self):
        res = self.sender_client.post(
            '/api/v1/alarms/sounds/',
            {'name': 'Morning Energy', 'source': 'upload', 'visibility': 'buddies'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        return payload(res)

    @mock.patch('apps.alarms.views.create_notification')
    def test_share_happy_path_and_notification_fired(self, mock_notify):
        sound = self._create_sound()

        res = self.sender_client.post(
            f"/api/v1/alarms/sounds/{sound['id']}/share/",
            {'recipient_profile_id': str(self.recipient.pk)},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(payload(res)['status'], 'pending')
        share_id = payload(res)['id']
        self.assertTrue(
            AlarmShare.objects.filter(
                sound_id=sound['id'], recipient=self.recipient, status='pending',
            ).exists(),
        )

        # alarm_shared notification fired to the recipient (user id).
        mock_notify.delay.assert_called_once()
        args, _ = mock_notify.delay.call_args
        self.assertEqual(args[0], str(self.recipient.user_id))
        self.assertEqual(args[1], 'alarm_shared')

        # Duplicate share rejected by unique (sound, recipient).
        res = self.sender_client.post(
            f"/api/v1/alarms/sounds/{sound['id']}/share/",
            {'recipient_profile_id': str(self.recipient.pk)},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

        # Recipient sees it in the inbox.
        res = self.recipient_client.get('/api/v1/alarms/shares/inbox/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(len(payload(res)), 1)

        # Recipient accepts → sender gets alarm_share_accepted.
        mock_notify.reset_mock()
        res = self.recipient_client.post(
            f'/api/v1/alarms/shares/{share_id}/respond/',
            {'accept': True},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(payload(res)['status'], 'accepted')
        mock_notify.delay.assert_called_once()
        args, _ = mock_notify.delay.call_args
        self.assertEqual(args[0], str(self.sender.user_id))
        self.assertEqual(args[1], 'alarm_share_accepted')

        # Accepted sound is usable by the recipient for their own alarm.
        res = self.recipient_client.post(
            '/api/v1/alarms/',
            {'time': '07:00:00', 'days_mask': 31, 'label': 'Gym',
             'sound': sound['id'], 'snooze_minutes': 5},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_non_buddy_share_rejected(self):
        sound = self._create_sound()
        res = self.sender_client.post(
            f"/api/v1/alarms/sounds/{sound['id']}/share/",
            {'recipient_profile_id': str(self.stranger.pk)},
            format='json',
        )
        self.assertIn(
            res.status_code,
            (status.HTTP_400_BAD_REQUEST, status.HTTP_403_FORBIDDEN),
        )
        self.assertFalse(AlarmShare.objects.exists())

    def test_respond_permissions(self):
        sound = self._create_sound()
        res = self.sender_client.post(
            f"/api/v1/alarms/sounds/{sound['id']}/share/",
            {'recipient_profile_id': str(self.recipient.pk)},
            format='json',
        )
        share_id = payload(res)['id']

        # Stranger cannot accept someone else's share.
        res = self.stranger_client.post(
            f'/api/v1/alarms/shares/{share_id}/respond/',
            {'accept': True},
            format='json',
        )
        self.assertIn(
            res.status_code,
            (status.HTTP_403_FORBIDDEN, status.HTTP_404_NOT_FOUND),
        )
        self.assertEqual(
            AlarmShare.objects.get(id=share_id).status, 'pending',
        )

        # Sender cannot accept their own outgoing share.
        res = self.sender_client.post(
            f'/api/v1/alarms/shares/{share_id}/respond/',
            {'accept': True},
            format='json',
        )
        self.assertIn(
            res.status_code,
            (status.HTTP_403_FORBIDDEN, status.HTTP_404_NOT_FOUND),
        )

        # Decline path works for the recipient.
        res = self.recipient_client.post(
            f'/api/v1/alarms/shares/{share_id}/respond/',
            {'accept': False},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(payload(res)['status'], 'declined')

    def test_cannot_use_unshared_sound(self):
        sound = self._create_sound()
        res = self.stranger_client.post(
            '/api/v1/alarms/',
            {'time': '07:00:00', 'days_mask': 1, 'sound': sound['id']},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class AlarmCrudTests(TestCase):
    def setUp(self):
        self.owner = _make_user('owner@test.com', 'owner')
        self.other = _make_user('other@test.com', 'other')
        self.owner_client = APIClient()
        self.owner_client.force_authenticate(self.owner.user)
        self.other_client = APIClient()
        self.other_client.force_authenticate(self.other.user)

    def test_alarm_crud_scoped_to_owner(self):
        res = self.owner_client.post(
            '/api/v1/alarms/',
            {'time': '06:30:00', 'days_mask': 62, 'label': 'Run',
             'enabled': True, 'snooze_minutes': 10},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        alarm_id = payload(res)['id']
        self.assertEqual(payload(res)['snooze_minutes'], 10)

        # Owner lists their alarm.
        res = self.owner_client.get('/api/v1/alarms/')
        self.assertEqual(len(payload(res)), 1)

        # Other user sees nothing and cannot access the detail.
        res = self.other_client.get('/api/v1/alarms/')
        self.assertEqual(len(payload(res)), 0)
        res = self.other_client.get(f'/api/v1/alarms/{alarm_id}/')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        res = self.other_client.patch(
            f'/api/v1/alarms/{alarm_id}/', {'enabled': False}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

        # Owner can patch and delete.
        res = self.owner_client.patch(
            f'/api/v1/alarms/{alarm_id}/', {'enabled': False}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertFalse(payload(res)['enabled'])
        res = self.owner_client.delete(f'/api/v1/alarms/{alarm_id}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertFalse(Alarm.objects.filter(id=alarm_id).exists())

    def test_days_mask_validated(self):
        res = self.owner_client.post(
            '/api/v1/alarms/',
            {'time': '06:30:00', 'days_mask': 128},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


# Hermetic uploads: never touch the real (cloudinary-backed) default storage.
@override_settings(STORAGES={
    'default': {'BACKEND': 'django.core.files.storage.FileSystemStorage'},
    'staticfiles': {
        'BACKEND': 'django.contrib.staticfiles.storage.StaticFilesStorage',
    },
})
class SoundUploadTests(TestCase):
    @classmethod
    def setUpClass(cls):
        cls._media_dir = tempfile.mkdtemp(prefix='alarms-test-media-')
        cls._media_override = override_settings(MEDIA_ROOT=cls._media_dir)
        cls._media_override.enable()
        super().setUpClass()

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        cls._media_override.disable()
        shutil.rmtree(cls._media_dir, ignore_errors=True)

    def setUp(self):
        self.owner = _make_user('uploader@test.com', 'uploader')
        self.client = APIClient()
        self.client.force_authenticate(self.owner.user)

    def test_non_audio_rejected(self):
        bad = SimpleUploadedFile(
            'notes.txt', b'not audio at all', content_type='text/plain',
        )
        res = self.client.post(
            '/api/v1/alarms/sounds/',
            {'name': 'Bad', 'visibility': 'private', 'audio': bad},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(AlarmSound.objects.exists())

    def test_oversized_audio_rejected(self):
        big = _audio(size=2 * 1024 * 1024 + 1)
        res = self.client.post(
            '/api/v1/alarms/sounds/',
            {'name': 'Big', 'visibility': 'private', 'audio': big},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(AlarmSound.objects.exists())

    def test_valid_audio_upload_exposes_audio_url(self):
        res = self.client.post(
            '/api/v1/alarms/sounds/',
            {'name': 'Wake Up', 'visibility': 'buddies', 'audio': _audio()},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertTrue(payload(res)['audio_url'])

    def test_json_create_with_link(self):
        res = self.client.post(
            '/api/v1/alarms/sounds/',
            {'name': 'Linked', 'source': 'suggestion',
             'audio_url': 'https://example.com/tone.mp3'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(payload(res)['audio_url'], 'https://example.com/tone.mp3')


class SuggestionTests(TestCase):
    def setUp(self):
        self.sender = _make_user('sugg-sender@test.com', 'suggsender')
        self.recipient = _make_user('sugg-recip@test.com', 'suggrecip')
        self.stranger = _make_user('sugg-stranger@test.com', 'suggstranger')
        _make_buddies(self.sender, self.recipient)
        self.sender_client = APIClient()
        self.sender_client.force_authenticate(self.sender.user)
        self.recipient_client = APIClient()
        self.recipient_client.force_authenticate(self.recipient.user)

    @mock.patch('apps.alarms.views.create_notification')
    def test_suggestion_flow(self, mock_notify):
        res = self.sender_client.post(
            '/api/v1/alarms/suggestions/',
            {'recipient_profile_id': str(self.recipient.pk),
             'title': 'Try this beat', 'note': 'Great for mornings',
             'url': 'https://example.com/beat.mp3'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(payload(res)['status'], 'pending')
        suggestion_id = payload(res)['id']

        mock_notify.delay.assert_called_once()
        args, _ = mock_notify.delay.call_args
        self.assertEqual(args[0], str(self.recipient.user_id))
        self.assertEqual(args[1], 'alarm_suggestion')

        # Recipient lists received suggestions.
        res = self.recipient_client.get('/api/v1/alarms/suggestions/')
        self.assertEqual(len(payload(res)), 1)

        for decision in ('accepted', 'declined', 'dismissed'):
            suggestion = AlarmSuggestion.objects.get(id=suggestion_id)
            suggestion.status = 'pending'
            suggestion.save(update_fields=['status'])
            res = self.recipient_client.post(
                f'/api/v1/alarms/suggestions/{suggestion_id}/respond/',
                {'decision': decision},
                format='json',
            )
            self.assertEqual(res.status_code, status.HTTP_200_OK)
            self.assertEqual(payload(res)['status'], decision)

        res = self.recipient_client.post(
            f'/api/v1/alarms/suggestions/{suggestion_id}/respond/',
            {'decision': 'bogus'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_suggestion_to_non_buddy_rejected(self):
        res = self.sender_client.post(
            '/api/v1/alarms/suggestions/',
            {'recipient_profile_id': str(self.stranger.pk), 'title': 'Nope'},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(AlarmSuggestion.objects.exists())
