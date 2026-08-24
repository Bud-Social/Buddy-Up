from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.messaging.models import Conversation, CallSession, CallParticipant


class ConversationCallSessionTests(TestCase):
    """Multi-party LiveKit calls: membership is enforced, sessions are shared."""

    def setUp(self):
        self.client = APIClient()

        self.alice_user = User.objects.create_user(email='alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='bob@example.com', password='TestPass123!')
        self.eve_user = User.objects.create_user(email='eve@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='bob', display_name='Bob')
        self.eve = Profile.objects.create(user=self.eve_user, username='eve', display_name='Eve')

        self.conv = Conversation.objects.create(is_group=True, group_name='Run Club')
        self.conv.participants.add(self.alice, self.bob)

        for profile in (self.alice, self.bob, self.eve):
            refresh = RefreshToken.for_user(profile.user)
            client = APIClient()
            client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            setattr(self, f'client_{profile.username}', client)
        self.client_alice = self.client_alice
        self.client_bob = self.client_bob
        self.client_eve = self.client_eve

    def test_non_member_cannot_join_call(self):
        url = f'/api/v1/messaging/conversations/{self.conv.id}/calls/session/'
        resp = self.client_eve.post(url, {'call_type': 'audio'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

    def test_start_then_join_shares_session_and_room(self):
        url = f'/api/v1/messaging/conversations/{self.conv.id}/calls/session/'
        r1 = self.client_alice.post(url, {'call_type': 'video'}, format='json')
        self.assertEqual(r1.status_code, status.HTTP_200_OK)
        data1 = r1.data['data']
        self.assertEqual(data1['status'], 'ringing')
        self.assertEqual(len(data1['participants']), 1)

        # Bob joins the same ringing call rather than creating a second one.
        r2 = self.client_bob.post(url, {'call_type': 'video'}, format='json')
        self.assertEqual(r2.status_code, status.HTTP_200_OK)
        data2 = r2.data['data']
        self.assertEqual(data1['session_id'], data2['session_id'])
        self.assertEqual(data1['livekit']['room'], data2['livekit']['room'])
        self.assertEqual(data2['status'], 'active')  # promoted once two joined
        self.assertEqual(CallSession.objects.count(), 1)
        self.assertEqual(CallParticipant.objects.count(), 2)

    def test_last_leave_ends_session(self):
        url = f'/api/v1/messaging/conversations/{self.conv.id}/calls/session/'
        self.client_alice.post(url, {'call_type': 'audio'}, format='json')
        self.client_bob.post(url, {'call_type': 'audio'}, format='json')

        resp = self.client_alice.delete(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertFalse(resp.data['data']['ended'])  # bob still present
        self.conv.refresh_from_db()
        self.assertTrue(self.conv.call_in_progress)

        resp2 = self.client_bob.delete(url)
        self.assertTrue(resp2.data['data']['ended'])
        self.assertEqual(CallSession.objects.filter(status='ended').count(), 1)
        self.conv.refresh_from_db()
        self.assertFalse(self.conv.call_in_progress)
