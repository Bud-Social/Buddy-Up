"""Tests for the live-room enhancement endpoints.

Covers the pieces that were added with the live-quality pass:
visibility control, replay admission on browse/serializer, feedback
pinning, audience polls, host mutes and not-interested, and sharing a
replay as a composer draft.
"""
from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.feed.models import Draft
from apps.profiles.models import BuddyRelationship, Profile

from .models import BuddyLive, LiveFeedback, LiveHostMute, LivePoll, LivePollVote
from .serializers import BuddyLiveSerializer


def _mk_user(email, username, display_name):
    user = User.objects.create_user(email=email, password='TestPass123!')
    return Profile.objects.create(user=user, username=username, display_name=display_name)


def _mk_live(host, **kwargs):
    defaults = dict(
        title='A Live', live_type='open_sweat', category='strength',
        status='live', viewer_peak=5,
    )
    defaults.update(kwargs)
    return BuddyLive.objects.create(host=host, **defaults)


class LiveTestCase(TestCase):
    def setUp(self):
        self.host_user = User.objects.create_user(email='qa-host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(
            user=self.host_user, username='qa-host', display_name='Host',
        )
        self.viewer_user = User.objects.create_user(email='qa-viewer@example.com', password='TestPass123!')
        self.viewer = Profile.objects.create(
            user=self.viewer_user, username='qa-viewer', display_name='Viewer',
        )
        self.host_client = APIClient()
        self.host_client.force_authenticate(self.host_user)
        self.viewer_client = APIClient()
        self.viewer_client.force_authenticate(self.viewer_user)
        self.live = _mk_live(self.host)

    def _join(self, client=None):
        client = client or self.viewer_client
        return client.post(f'/api/v1/lives/{self.live.id}/join/')


class VisibilityTests(LiveTestCase):
    def test_host_can_flip_visibility(self):
        resp = self.host_client.patch(
            f'/api/v1/lives/{self.live.id}/visibility/', {'access': 'buddies'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.live.refresh_from_db()
        self.assertEqual(self.live.access, 'buddies')

    def test_private_is_accepted(self):
        resp = self.host_client.patch(
            f'/api/v1/lives/{self.live.id}/visibility/', {'access': 'private'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.live.refresh_from_db()
        self.assertEqual(self.live.access, 'private')

    def test_viewers_cannot_flip_visibility(self):
        resp = self.viewer_client.patch(
            f'/api/v1/lives/{self.live.id}/visibility/', {'access': 'private'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_invalid_access_is_rejected(self):
        resp = self.host_client.patch(
            f'/api/v1/lives/{self.live.id}/visibility/', {'access': 'everyone'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class ReplayAdmissionTests(LiveTestCase):
    def _ended_replay(self, access):
        return _mk_live(
            self.host, title='Replay', status='ended', replay_saved=True,
            replay_url='https://cdn.example.com/r.mp4',
            ended_at=timezone.now() - timedelta(days=1),
            access=access,
        )

    def _browse_replay_ids(self, client):
        resp = client.get('/api/v1/lives/browse/?tab=replays')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        return [item['id'] for item in resp.data['data']]

    def test_public_replay_is_listed_and_url_visible(self):
        replay = self._ended_replay('public')
        self.assertIn(str(replay.id), self._browse_replay_ids(self.viewer_client))
        data = BuddyLiveSerializer(replay, context={'request': type('R', (), {'user': self.viewer_user})()}).data
        self.assertEqual(data['replay_url'], 'https://cdn.example.com/r.mp4')

    def test_buddies_replay_hidden_from_non_buddies(self):
        replay = self._ended_replay('buddies')
        self.assertNotIn(str(replay.id), self._browse_replay_ids(self.viewer_client))
        # The host still sees their own replays.
        self.assertIn(str(replay.id), self._browse_replay_ids(self.host_client))

    def test_buddies_replay_visible_to_confirmed_buddy(self):
        replay = self._ended_replay('buddies')
        BuddyRelationship.objects.create(
            from_user=self.host, to_user=self.viewer, status='confirmed',
        )
        self.assertIn(str(replay.id), self._browse_replay_ids(self.viewer_client))

    def test_private_replay_hidden_from_everyone_but_host(self):
        replay = self._ended_replay('private')
        self.assertNotIn(str(replay.id), self._browse_replay_ids(self.viewer_client))
        self.assertIn(str(replay.id), self._browse_replay_ids(self.host_client))
        data = BuddyLiveSerializer(replay, context={'request': type('R', (), {'user': self.viewer_user})()}).data
        self.assertEqual(data['replay_url'], '')


class FeedbackTests(LiveTestCase):
    def test_joiner_can_leave_feedback_and_edit_it(self):
        self._join()
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/feedback/', {'rating': 4, 'comment': 'good pace'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/feedback/', {'rating': 5, 'comment': 'great pace'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(LiveFeedback.objects.filter(live=self.live, user=self.viewer).count(), 1)
        self.assertEqual(LiveFeedback.objects.get(live=self.live).rating, 5)

    def test_outsider_gets_403_on_a_restricted_live(self):
        # Public lives admit anyone; the gate only bites on restricted rooms.
        self.live.access = 'buddies'
        self.live.save(update_fields=['access'])
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/feedback/', {'rating': 4}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_rating_out_of_range_is_rejected(self):
        self._join()
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/feedback/', {'rating': 9}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_host_sees_the_aggregate_viewers_see_their_own(self):
        self._join()
        LiveFeedback.objects.create(live=self.live, user=self.viewer, rating=4, comment='solid')
        resp = self.host_client.get(f'/api/v1/lives/{self.live.id}/feedback/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['count'], 1)
        self.assertEqual(resp.data['data']['average'], 4)
        resp = self.viewer_client.get(f'/api/v1/lives/{self.live.id}/feedback/')
        self.assertEqual(resp.data['data']['rating'], 4)


class PollTests(LiveTestCase):
    def test_host_can_schedule_a_poll_and_it_broadcasts(self):
        resp = self.host_client.post(
            f'/api/v1/lives/{self.live.id}/polls/',
            {'question': 'Tempo or intervals?', 'options': ['Tempo', 'Intervals'],
             'show_after_seconds': 5, 'duration_seconds': 60},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        poll = LivePoll.objects.get(live=self.live)
        # Eager celery in dev: the broadcast already fired, stamping dispatched_at.
        self.assertIsNotNone(poll.dispatched_at)

    def test_viewers_cannot_create_polls(self):
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/polls/',
            {'question': 'Q?', 'options': ['a', 'b']},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def _dispatched_poll(self, question='Pick one', options=('a', 'b')):
        return LivePoll.objects.create(
            live=self.live, host=self.host, question=question,
            options=list(options), show_after_seconds=0, duration_seconds=300,
            dispatched_at=timezone.now(),
        )

    def test_current_poll_returns_the_open_poll_with_tally(self):
        poll = self._dispatched_poll()
        resp = self.viewer_client.get(f'/api/v1/lives/{self.live.id}/polls/current/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['poll_id'], str(poll.id))
        self.assertEqual(resp.data['data']['tally'], [0, 0])

    def test_voting_counts_and_is_upsertable(self):
        poll = self._dispatched_poll()
        self._join()
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/polls/{poll.id}/vote/', {'option': 1}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['tally'], [0, 1])
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/polls/{poll.id}/vote/', {'option': 0}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['tally'], [1, 0])
        self.assertEqual(LivePollVote.objects.filter(poll=poll).count(), 1)

    def test_voting_on_a_closed_poll_conflicts(self):
        poll = self._dispatched_poll()
        poll.dispatched_at = timezone.now() - timedelta(seconds=400)
        poll.save(update_fields=['dispatched_at'])
        self._join()
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/polls/{poll.id}/vote/', {'option': 0}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_409_CONFLICT)

    def test_option_out_of_range_is_rejected(self):
        poll = self._dispatched_poll()
        self._join()
        resp = self.viewer_client.post(
            f'/api/v1/lives/{self.live.id}/polls/{poll.id}/vote/', {'option': 7}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class MuteAndNotInterestedTests(LiveTestCase):
    def test_not_interested_toggles_and_hides_the_live(self):
        resp = self.viewer_client.post(f'/api/v1/lives/{self.live.id}/not-interested/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.data['data']['not_interested'])
        ids = [item['id'] for item in self.viewer_client.get('/api/v1/lives/browse/?tab=live').data['data']]
        self.assertNotIn(str(self.live.id), ids)
        resp = self.viewer_client.post(f'/api/v1/lives/{self.live.id}/not-interested/')
        self.assertFalse(resp.data['data']['not_interested'])

    def test_mute_host_toggles_and_hides_their_lives(self):
        resp = self.viewer_client.post(f'/api/v1/lives/{self.live.id}/mute-host/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.data['data']['muted'])
        self.assertTrue(LiveHostMute.objects.filter(host=self.host, user=self.viewer).exists())
        ids = [item['id'] for item in self.viewer_client.get('/api/v1/lives/browse/?tab=live').data['data']]
        self.assertNotIn(str(self.live.id), ids)
        resp = self.viewer_client.post(f'/api/v1/lives/{self.live.id}/mute-host/')
        self.assertFalse(resp.data['data']['muted'])

    def test_host_cannot_mute_themselves(self):
        resp = self.host_client.post(f'/api/v1/lives/{self.live.id}/mute-host/')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class LiveReplayShareTests(LiveTestCase):
    def _replay(self):
        self.live.status = 'ended'
        self.live.replay_saved = True
        self.live.replay_url = 'https://cdn.example.com/r.mp4'
        self.live.started_at = timezone.now() - timedelta(hours=1)
        self.live.ended_at = timezone.now()
        self.live.save()
        return self.live

    def test_host_can_prepare_and_publish_a_replay_draft(self):
        replay = self._replay()
        resp = self.host_client.post(
            '/api/v1/analytics/share/prepare/',
            {'kind': 'live', 'obj_id': str(replay.id)},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        draft = Draft.objects.get(source_live=replay)
        self.assertEqual(draft.post_type, 'long_video')
        self.assertEqual(draft.media_urls, ['https://cdn.example.com/r.mp4'])

        resp = self.host_client.post(f'/api/v1/analytics/share/draft/{draft.id}/publish/', {}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        draft.refresh_from_db()
        self.assertIsNone(draft.source_live)
        self.assertEqual(draft.source_kind, '')

    def test_viewers_cannot_share_the_hosts_replay(self):
        replay = self._replay()
        resp = self.viewer_client.post(
            '/api/v1/analytics/share/prepare/',
            {'kind': 'live', 'obj_id': str(replay.id)},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)


class WelcomeLineTests(LiveTestCase):
    def test_first_join_welcomes_once_and_skips_host(self):
        from apps.messaging.consumers import LiveConsumer

        class FakeCache:
            def __init__(self):
                self.seen = set()

            def add(self, key, value, timeout=None):
                if key in self.seen:
                    return False
                self.seen.add(key)
                return True

        consumer = LiveConsumer()
        consumer.live_id = str(self.live.id)
        consumer.profile = self.viewer
        from unittest import mock
        with mock.patch('apps.messaging.consumers.cache', FakeCache()):
            first = consumer._welcome_if_first_join()
            second = consumer._welcome_if_first_join()
        self.assertEqual(first, 'Viewer joined the live')
        self.assertIsNone(second)

        consumer.profile = self.host
        with mock.patch('apps.messaging.consumers.cache', FakeCache()):
            self.assertIsNone(consumer._welcome_if_first_join())
