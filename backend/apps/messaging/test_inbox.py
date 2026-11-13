"""Tests for the split between the buddy inbox and the main one.

Buddy chats have their own inbox: a chat opened from the buddy finder is
filed there, and promoting a chat to a buddy relationship moves it rather
than leaving it in both.
"""

from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.messaging.models import Conversation
from apps.profiles.models import Profile


class ConversationInboxTests(TestCase):
    def setUp(self):
        self.alice_user = User.objects.create_user(email='inbox-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='inbox-bob@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='inbox-alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='inbox-bob', display_name='Bob')

        def client_for(profile):
            c = APIClient()
            refresh = RefreshToken.for_user(profile.user)
            c.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            return c

        self.client = client_for(self.alice)

    def _conversation(self, **kwargs):
        conv = Conversation.objects.create(is_group=False, **kwargs)
        conv.participants.add(self.alice, self.bob)
        return conv

    def test_the_inboxes_are_asked_for_by_kind(self):
        main = self._conversation(origin='direct', kind='main')
        buddy = self._conversation(origin='discovery', kind='buddy')

        resp = self.client.get('/api/v1/messaging/conversations/', {'kind': 'main'})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual([c['id'] for c in resp.data['data']], [str(main.id)])

        resp = self.client.get('/api/v1/messaging/conversations/', {'kind': 'buddy'})
        self.assertEqual([c['id'] for c in resp.data['data']], [str(buddy.id)])

    def test_the_main_inbox_is_the_default(self):
        self._conversation(origin='direct', kind='main')
        self._conversation(origin='discovery', kind='buddy')
        resp = self.client.get('/api/v1/messaging/conversations/')
        self.assertEqual(len(resp.data['data']), 1)
        self.assertEqual(resp.data['data'][0]['origin'], 'direct')

    def test_a_chat_opened_from_the_buddy_finder_goes_to_the_buddy_inbox(self):
        # People who meet through the buddy finder can text each other, so
        # both need a search profile.
        from apps.profiles.models import BuddySearchProfile
        BuddySearchProfile.objects.create(profile=self.alice, intents=['walk'])
        BuddySearchProfile.objects.create(profile=self.bob, intents=['run'])

        resp = self.client.post('/api/v1/messaging/conversations/start/', {
            'participants': ['inbox-bob'],
            'origin': 'discovery',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        conv = Conversation.objects.get(id=resp.data['data']['id'])
        self.assertEqual(conv.kind, 'buddy')

    def test_promoting_a_chat_moves_it_rather_than_copying_it(self):
        conv = self._conversation(origin='discovery', kind='buddy')
        resp = self.client.post(f'/api/v1/messaging/conversations/{conv.id}/promote/')
        self.assertIn(resp.status_code, (200, 201))

        # The other side accepts, which is what makes them buddies.
        bob_client = APIClient()
        refresh = RefreshToken.for_user(self.bob_user)
        bob_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        promotion_id = resp.data['data']['id']
        accept = bob_client.post(
            f'/api/v1/messaging/conversations/promotions/{promotion_id}/respond/',
            {'accept': True}, format='json',
        )
        self.assertIn(accept.status_code, (200, 201))

        conv.refresh_from_db()
        self.assertEqual(conv.origin, 'buddy')
        self.assertEqual(conv.kind, 'buddy')
        # One conversation, in one inbox.
        self.assertEqual(
            Conversation.objects.filter(id=conv.id, kind='buddy').count(), 1,
        )
