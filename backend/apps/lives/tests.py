from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.wallet.models import ArtifactTransaction

from .models import BuddyLive


class LiveBrowseTests(TestCase):
    """Browse tabs used by the clients: live / scheduled / replays.

    'upcoming' is also accepted by the endpoint as an alias for 'scheduled'.
    """

    def setUp(self):
        self.client = APIClient()

        self.viewer_user = User.objects.create_user(email='viewer@example.com', password='TestPass123!')
        self.viewer = Profile.objects.create(user=self.viewer_user, username='viewer', display_name='Viewer')
        refresh = RefreshToken.for_user(self.viewer_user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        self.host_user = User.objects.create_user(email='host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(user=self.host_user, username='host', display_name='Host')

        self.live_now = BuddyLive.objects.create(
            host=self.host, title='Now', live_type='open_sweat', category='strength',
            status='live', viewer_peak=10,
        )
        self.scheduled = BuddyLive.objects.create(
            host=self.host, title='Soon', live_type='open_sweat', category='strength',
            status='scheduled', scheduled_for=timezone.now() + timedelta(hours=2),
        )
        ended_at = timezone.now() - timedelta(days=1)
        self.replay = BuddyLive.objects.create(
            host=self.host, title='Replay', live_type='open_sweat', category='strength',
            status='ended', replay_saved=True,
            replay_url='https://cdn.example.com/replays/replay.mp4',
            ended_at=ended_at,
        )
        # Ended without a saved replay must not surface in the replays tab.
        BuddyLive.objects.create(
            host=self.host, title='No replay', live_type='open_sweat', category='strength',
            status='ended', ended_at=ended_at,
        )

    def _browse(self, tab):
        resp = self.client.get(f'/api/v1/lives/browse/?tab={tab}')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.data['success'])
        return resp.data['data']

    def test_live_tab(self):
        items = self._browse('live')
        self.assertEqual([item['id'] for item in items], [str(self.live_now.id)])

    def test_scheduled_tab(self):
        items = self._browse('scheduled')
        self.assertEqual([item['id'] for item in items], [str(self.scheduled.id)])

    def test_upcoming_tab_aliases_scheduled(self):
        items = self._browse('upcoming')
        self.assertEqual([item['id'] for item in items], [str(self.scheduled.id)])

    def test_replays_tab_returns_public_replay_urls(self):
        items = self._browse('replays')
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]['id'], str(self.replay.id))
        self.assertTrue(items[0]['replay_saved'])
        self.assertEqual(items[0]['replay_url'], self.replay.replay_url)


class RefundGiftScopeTests(TestCase):
    """A host may only refund gift transactions that belong to their own live."""

    def setUp(self):
        self.client = APIClient()

        self.host_a_user = User.objects.create_user(email='refund-host-a@example.com', password='TestPass123!')
        self.host_b_user = User.objects.create_user(email='refund-host-b@example.com', password='TestPass123!')
        self.gifter_user = User.objects.create_user(email='refund-gifter@example.com', password='TestPass123!')
        self.host_a = Profile.objects.create(user=self.host_a_user, username='refund-host-a', display_name='Host A')
        self.host_b = Profile.objects.create(user=self.host_b_user, username='refund-host-b', display_name='Host B')
        self.gifter = Profile.objects.create(user=self.gifter_user, username='refund-gifter', display_name='Gifter')

        self.live_a = BuddyLive.objects.create(
            host=self.host_a, title='Live A', live_type='open_sweat', category='strength', status='live',
        )
        self.live_b = BuddyLive.objects.create(
            host=self.host_b, title='Live B', live_type='open_sweat', category='strength', status='live',
        )

        # Gift tip sent during live B (as the WS settlement would create it).
        self.gift_tx_b = ArtifactTransaction.objects.create(
            user=self.gifter, transaction_type='tip_sent',
            artifact_type='dumbbell', quantity=5, direction='debit',
            counterparty=self.host_b, status='completed',
            reference_id=f'live_{self.live_b.id}',
        )

        # Host B funded with artifacts so a legitimate refund can settle.
        self.host_b.artifact_balance = {'dumbbell': 5}
        self.host_b.save(update_fields=['artifact_balance'])

    def _client_for(self, profile):
        client = APIClient()
        refresh = RefreshToken.for_user(profile.user)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        return client

    def test_host_of_live_a_cannot_refund_transaction_of_live_b(self):
        client = self._client_for(self.host_a)
        response = client.post(f'/api/v1/lives/{self.live_a.id}/refund-gift/{self.gift_tx_b.id}/')
        self.assertIn(response.status_code, (status.HTTP_404_NOT_FOUND, status.HTTP_403_FORBIDDEN))
        self.gift_tx_b.refresh_from_db()
        self.assertEqual(self.gift_tx_b.status, 'completed')

    def test_host_can_refund_own_live_gift(self):
        client = self._client_for(self.host_b)
        response = client.post(f'/api/v1/lives/{self.live_b.id}/refund-gift/{self.gift_tx_b.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.gift_tx_b.refresh_from_db()
        self.assertEqual(self.gift_tx_b.status, 'refunded')
        # The settlement is recorded against this live.
        self.assertTrue(
            ArtifactTransaction.objects.filter(
                reference_id=f'live_refund_{self.live_b.id}', transaction_type='refund',
            ).exists(),
        )

    def test_refund_requires_host_role(self):
        gifter_client = self._client_for(self.gifter)
        response = gifter_client.post(f'/api/v1/lives/{self.live_b.id}/refund-gift/{self.gift_tx_b.id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.gift_tx_b.refresh_from_db()
        self.assertEqual(self.gift_tx_b.status, 'completed')

    def test_non_gift_transaction_cannot_be_refunded_via_gift_endpoint(self):
        # A purchase belonging to the refunding host's own live is still out
        # of scope for the gift refund endpoint.
        purchase = ArtifactTransaction.objects.create(
            user=self.gifter, transaction_type='purchase',
            artifact_type='sprint', quantity=2, direction='debit',
            counterparty=self.host_b, status='completed',
            reference_id=f'live_{self.live_b.id}',
        )
        self.host_b.artifact_balance = {'sprint': 2}
        self.host_b.save(update_fields=['artifact_balance'])
        client = self._client_for(self.host_b)
        response = client.post(f'/api/v1/lives/{self.live_b.id}/refund-gift/{purchase.id}/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        purchase.refresh_from_db()
        self.assertEqual(purchase.status, 'completed')


class ReplayViewTests(TestCase):
    """POST /lives/<id>/replay/view/ — unique-per-viewer replay counts."""

    def setUp(self):
        self.client = APIClient()
        self.viewer_user = User.objects.create_user(email='rv_viewer@example.com', password='TestPass123!')
        self.viewer = Profile.objects.create(user=self.viewer_user, username='rv_viewer', display_name='RV')
        refresh = RefreshToken.for_user(self.viewer_user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        self.host_user = User.objects.create_user(email='rv_host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(user=self.host_user, username='rv_host', display_name='RH')
        self.replay = BuddyLive.objects.create(
            host=self.host, title='RV Replay', live_type='open_sweat', category='strength',
            status='ended', replay_saved=True,
            replay_url='https://cdn.example.com/replays/rv.mp4',
            ended_at=timezone.now() - timedelta(days=1),
        )
        self.live_now = BuddyLive.objects.create(
            host=self.host, title='RV Live', live_type='open_sweat', category='strength',
            status='live',
        )

    def _host_client(self):
        from rest_framework_simplejwt.tokens import RefreshToken

        c = APIClient()
        c.credentials(HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(self.host_user).access_token}')
        return c

    def test_first_replay_view_counts_once(self):
        res = self.client.post(f'/api/v1/lives/{self.replay.id}/replay/view/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()['data'], {'unique_viewers': 1})
        self.assertEqual(res.json()['message'], 'Replay view recorded.')

    def test_repeat_replay_view_not_recounted(self):
        self.client.post(f'/api/v1/lives/{self.replay.id}/replay/view/')
        res = self.client.post(f'/api/v1/lives/{self.replay.id}/replay/view/')
        self.assertEqual(res.json()['data'], {'unique_viewers': 1})
        self.assertEqual(res.json()['message'], 'Replay view already counted.')

    def test_host_replay_view_not_counted(self):
        res = self._host_client().post(f'/api/v1/lives/{self.replay.id}/replay/view/')
        self.assertEqual(res.json()['data'], {'unique_viewers': 0})

    def test_live_without_replay_404s(self):
        res = self.client.post(f'/api/v1/lives/{self.live_now.id}/replay/view/')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_detail_exposes_unique_and_replay_counts(self):
        from .models import LiveAttendee

        LiveAttendee.objects.create(live=self.replay, user=self.viewer, role='attendee')
        self.client.post(f'/api/v1/lives/{self.replay.id}/replay/view/')
        res = self.client.get(f'/api/v1/lives/{self.replay.id}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()['data']['unique_viewers'], 1)
        self.assertEqual(res.json()['data']['replay_views'], 1)


from unittest import mock


class StaffRecordingViewTests(TestCase):
    """Staff-only master recording endpoints (IsAdminUser)."""

    def setUp(self):
        self.staff_user = User.objects.create_user(
            email='mod@example.com', password='TestPass123!', is_staff=True)
        self.staff_client = APIClient()
        self.staff_client.credentials(
            HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(self.staff_user).access_token}')

        self.viewer_user = User.objects.create_user(
            email='viewer@example.com', password='TestPass123!')
        Profile.objects.create(user=self.viewer_user, username='viewer', display_name='V')
        self.viewer_client = APIClient()
        self.viewer_client.credentials(
            HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(self.viewer_user).access_token}')

        self.host_user = User.objects.create_user(
            email='host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(
            user=self.host_user, username='host', display_name='Host')

        self.with_archive = BuddyLive.objects.create(
            host=self.host, title='Archived', live_type='open_sweat', category='strength',
            status='ended', recording_archive_key='replays/archived.mp4',
            recording_status='ready', mux_status='ready', mux_playback_id='pb_ready',
            mux_processing_error='looks great', recording_consent='auto_record',
            replay_saved=True, transcript='Host transcript',
            replay_url='https://cdn.example.com/old.mp4',
        )
        self.no_archive = BuddyLive.objects.create(
            host=self.host, title='No Master', live_type='open_sweat', category='strength',
            status='ended', recording_consent='auto_record',
        )

    def _recording_url(self, live):
        return f'/api/v1/lives/{live.id}/recording/'

    @mock.patch('apps.lives.recording.generate_archive_presigned_url')
    def test_staff_get_returns_statuses_and_fresh_archive(self, mock_presigned):
        counter = {'n': 0}

        def fake(live, expiration_seconds=None):
            counter['n'] += 1
            return f'http://fresh.example/{counter["n"]}'
        mock_presigned.side_effect = fake

        first = self.staff_client.get(self._recording_url(self.with_archive))
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        d = first.json()['data']
        self.assertEqual(d['recording_status'], 'ready')
        self.assertEqual(d['mux_status'], 'ready')
        self.assertEqual(d['mux_playback_id'], 'pb_ready')
        self.assertEqual(d['mux_processing_error'], 'looks great')
        self.assertTrue(d['archive_url'].startswith('http://fresh.example/'))

        # Fresh URL minted per request.
        second = self.staff_client.get(self._recording_url(self.with_archive)).json()['data']
        self.assertNotEqual(second['archive_url'], d['archive_url'])
        self.assertEqual(mock_presigned.call_count, 2)

    def test_non_staff_forbidden(self):
        resp = self.viewer_client.get(self._recording_url(self.with_archive))
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_live_without_archive_404s(self):
        resp = self.staff_client.get(self._recording_url(self.no_archive))
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

    @mock.patch('apps.lives.recording.generate_archive_presigned_url')
    def test_download_redirects_staff_to_fresh_presigned(self, mock_presigned):
        mock_presigned.return_value = 'http://fresh.example/dl.mp4?sig=1'
        resp = self.staff_client.get(f'{self._recording_url(self.with_archive)}download/')
        # DRF emits 302 with Location for a redirect Response.
        self.assertEqual(resp.status_code, status.HTTP_302_FOUND)
        self.assertEqual(resp['Location'], 'http://fresh.example/dl.mp4?sig=1')

    @mock.patch('apps.lives.recording.generate_archive_presigned_url')
    def test_download_404_without_archive(self, mock_presigned):
        resp = self.staff_client.get(f'{self._recording_url(self.no_archive)}download/')
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

    @mock.patch('apps.lives.recording.generate_archive_presigned_url')
    def test_download_503_when_storage_misconfigured(self, mock_presigned):
        mock_presigned.return_value = None
        resp = self.staff_client.get(f'{self._recording_url(self.with_archive)}download/')
        self.assertEqual(resp.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)


class RecordingPipelineTests(TestCase):
    """process_live_replay: moderation-first seal, best-effort Mux, MP4 fallback."""

    def setUp(self):
        self.host_user = User.objects.create_user(
            email='pipe_host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(
            user=self.host_user, username='pipe_host', display_name='Host')
        self.live = BuddyLive.objects.create(
            host=self.host, title='Pipe', live_type='open_sweat', category='strength',
            status='ended', recording_consent='auto_record', replay_saved=True,
            livekit_egress_id='egress-1', recording_archive_key='replays/m.mp4',
            recording_status='recording',
        )

    def _fake_stop(self):
        def _stop(egress_id, live_id):
            BuddyLive.objects.filter(pk=live_id).update(recording_status='ready')
            return 'http://master.mp4'
        return _stop

    @mock.patch('apps.lives.tasks.transcribe_live_replay')
    @mock.patch('apps.lives.recording.archive_recording_url')
    @mock.patch('apps.lives.recording.create_mux_asset')
    @mock.patch('apps.lives.recording.stop_livekit_egress')
    def test_mux_failure_falls_back_to_mp4(self, mock_stop, mock_mux, mock_archive, mock_tx):
        from apps.lives.tasks import process_live_replay
        mock_stop.side_effect = self._fake_stop()
        mock_mux.return_value = (None, None, 'mux not configured')
        mock_archive.return_value = 'http://fallback.mp4'
        process_live_replay(str(self.live.id))
        self.live.refresh_from_db()
        self.assertEqual(self.live.recording_status, 'ready')
        self.assertEqual(self.live.mux_status, 'failed')
        self.assertIn('mux not configured', self.live.mux_processing_error)
        # Public replay still published as a long-lived MP4 fallback.
        self.assertEqual(self.live.replay_url, 'http://fallback.mp4')
        mock_archive.assert_called_once()

    @mock.patch('apps.lives.tasks.transcribe_live_replay')
    @mock.patch('apps.lives.recording.archive_recording_url')
    @mock.patch('apps.lives.recording.create_mux_asset')
    @mock.patch('apps.lives.recording.stop_livekit_egress')
    def test_mux_success_publishes_hls(self, mock_stop, mock_mux, mock_archive, mock_tx):
        from apps.lives.tasks import process_live_replay
        with mock.patch('apps.lives.tasks.finalize_mux_status') as mock_finalize:
            mock_stop.side_effect = self._fake_stop()
            mock_mux.return_value = ('asset1', 'pb_hls', '')
            mock_archive.return_value = 'https://stream.mux.com/hls.m3u8'
            process_live_replay(str(self.live.id))
            mock_finalize.delay.assert_called_once_with(str(self.live.id))
        self.live.refresh_from_db()
        self.assertEqual(self.live.recording_status, 'ready')
        self.assertEqual(self.live.mux_status, 'created')
        self.assertEqual(self.live.mux_playback_id, 'pb_hls')
        self.assertEqual(self.live.replay_url, 'https://stream.mux.com/hls.m3u8')

    @mock.patch('apps.lives.tasks.transcribe_live_replay')
    @mock.patch('apps.lives.recording.archive_recording_url')
    @mock.patch('apps.lives.recording.create_mux_asset')
    @mock.patch('apps.lives.recording.stop_livekit_egress')
    def test_opt_out_live_keeps_master_without_public_replay(self, mock_stop, mock_mux, mock_archive, mock_tx):
        from apps.lives.tasks import process_live_replay
        self.live.recording_consent = 'opt_out'
        self.live.replay_saved = False
        self.live.save()
        mock_stop.side_effect = self._fake_stop()
        mock_mux.return_value = (None, None, 'mux not configured')
        process_live_replay(str(self.live.id))
        self.live.refresh_from_db()
        self.assertEqual(self.live.recording_status, 'ready')
        # No public replay, no Mux attempt for opt-out lives.
        self.assertEqual(self.live.replay_url, '')
        self.assertEqual(self.live.mux_status, 'not_created')
        mock_mux.assert_not_called()
        mock_archive.assert_not_called()


class FinalizeMuxStatusTests(TestCase):
    def setUp(self):
        self.host_user = User.objects.create_user(
            email='fin_host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(
            user=self.host_user, username='fin_host', display_name='Host')
        self.live = BuddyLive.objects.create(
            host=self.host, title='Fin', live_type='open_sweat', category='strength',
            status='ended', recording_consent='auto_record', replay_saved=True,
            recording_archive_key='replays/m.mp4', recording_status='ready',
            mux_status='created', mux_asset_id='asset1',
        )

    @mock.patch('apps.lives.recording.archive_recording_url')
    @mock.patch('apps.lives.recording.poll_mux_asset_status')
    def test_upgrades_to_ready_and_publishes_hls(self, mock_poll, mock_archive):
        from apps.lives.tasks import finalize_mux_status
        mock_poll.return_value = 'ready'
        mock_archive.return_value = 'https://stream.mux.com/final.m3u8'
        finalize_mux_status(str(self.live.id))
        self.live.refresh_from_db()
        self.assertEqual(self.live.mux_status, 'ready')
        self.assertEqual(self.live.replay_url, 'https://stream.mux.com/final.m3u8')

    @mock.patch('apps.lives.recording.archive_recording_url')
    @mock.patch('apps.lives.recording.poll_mux_asset_status')
    def test_failed_mux_records_error(self, mock_poll, mock_archive):
        from apps.lives.tasks import finalize_mux_status
        mock_poll.return_value = 'failed'
        finalize_mux_status(str(self.live.id))
        self.live.refresh_from_db()
        self.assertEqual(self.live.mux_status, 'failed')
        self.assertIn('mux status=failed', self.live.mux_processing_error)
        mock_archive.assert_not_called()


class ResolveLiveRecordingFieldsTests(TestCase):
    """moderation.resolve._resolve_live surfaces the recording lifecycle."""

    def setUp(self):
        self.host_user = User.objects.create_user(
            email='res_host@example.com', password='TestPass123!')
        self.host = Profile.objects.create(
            user=self.host_user, username='res_host', display_name='Host')
        self.live = BuddyLive.objects.create(
            host=self.host, title='Resolved', live_type='open_sweat', category='strength',
            status='ended', recording_archive_key='replays/r.mp4',
            recording_status='ready', mux_status='ready', mux_playback_id='pb_resolved',
            mux_processing_error='boom', recording_consent='auto_record',
            replay_saved=True, transcript='A transcript', replay_url='https://cdn.example.com/r.mp4',
        )

    def test_resolve_exposes_recording_fields(self):
        from apps.moderation.resolve import resolve_content
        resolved = resolve_content('lives.buddy_live', str(self.live.id))
        self.assertIsNotNone(resolved)
        fields = resolved['fields']
        self.assertEqual(fields['recording_status'], 'ready')
        self.assertEqual(fields['mux_status'], 'ready')
        self.assertEqual(fields['mux_playback_id'], 'pb_resolved')
        self.assertEqual(fields['mux_processing_error'], 'boom')
        self.assertIn('transcript', fields)
        self.assertIn('replay_url', fields)
