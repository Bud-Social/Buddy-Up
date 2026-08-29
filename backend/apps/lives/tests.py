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
