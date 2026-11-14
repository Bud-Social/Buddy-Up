from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.gyms.models import GymRoutinePost
from apps.lives.models import BuddyLive
from apps.marketplace.models import MarketplaceEvent
from apps.messaging.models import Conversation, ConversationMembership
from apps.profiles.models import Profile


class CommunityActivityTests(TestCase):
    """Community events, lives and schedule slots.

    The community detail page is the only place members manage these, so the
    rules that matter are: members read, admins write, non-members can read a
    public community but get nothing from a private one.
    """

    def setUp(self):
        self.owner_user = User.objects.create_user(email='owner@example.com', password='TestPass123!')
        self.member_user = User.objects.create_user(email='member@example.com', password='TestPass123!')
        self.outsider_user = User.objects.create_user(email='outsider@example.com', password='TestPass123!')
        self.owner = Profile.objects.create(user=self.owner_user, username='owner', display_name='Owner')
        self.member = Profile.objects.create(user=self.member_user, username='member', display_name='Member')
        self.outsider = Profile.objects.create(user=self.outsider_user, username='outsider', display_name='Outsider')

        self.community = Conversation.objects.create(
            is_community=True, group_name='Run Club', is_public=True,
        )
        self.community.participants.add(self.owner, self.member)
        ConversationMembership.objects.create(conversation=self.community, profile=self.owner, role='owner')
        ConversationMembership.objects.create(conversation=self.community, profile=self.member, role='member')

        self.client_owner = self._client_for(self.owner)
        self.client_member = self._client_for(self.member)
        self.client_outsider = self._client_for(self.outsider)

    def _client_for(self, profile):
        refresh = RefreshToken.for_user(profile.user)
        client = APIClient()
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        return client

    def _event_payload(self):
        start = timezone.now() + timedelta(days=2)
        return {
            'title': 'Saturday long run',
            'description': 'Meet at the gate.',
            'event_type': 'in_person',
            'location': 'Karura Gate',
            'start_datetime': start.isoformat(),
            'end_datetime': (start + timedelta(hours=2)).isoformat(),
        }

    def _url(self, suffix):
        return f'/api/v1/messaging/communities/{self.community.id}/{suffix}/'

    # ── Events ─────────────────────────────────────────────────────────
    def test_only_admins_create_events(self):
        response = self.client_member.post(self._url('events'), self._event_payload(), format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_admin_creates_a_community_event_that_serialises_its_community(self):
        response = self.client_owner.post(self._url('events'), self._event_payload(), format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        payload = response.data['data']
        self.assertEqual(str(payload['community_id']), str(self.community.id))
        self.assertEqual(payload['community_name'], 'Run Club')
        self.assertIsNone(payload['gym_id'])
        self.assertTrue(MarketplaceEvent.objects.filter(community=self.community).exists())

    def test_event_requires_an_end_after_the_start(self):
        payload = self._event_payload()
        payload['end_datetime'] = payload['start_datetime']
        response = self.client_owner.post(self._url('events'), payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_event_delete_cancels_without_destroying_ticket_history(self):
        event = MarketplaceEvent.objects.create(
            creator=self.owner, community=self.community,
            title='Run', start_datetime=timezone.now() + timedelta(days=1),
            end_datetime=timezone.now() + timedelta(days=1, hours=2),
        )
        response = self.client_owner.delete(self._url(f'events/{event.id}'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        event.refresh_from_db()
        self.assertTrue(event.is_cancelled)
        self.assertFalse(event.is_published)

    # ── Lives ──────────────────────────────────────────────────────────
    def test_admin_schedules_a_community_live(self):
        response = self.client_owner.post(
            self._url('lives'),
            {'title': 'Mobility Q&A', 'live_type': 'buddy_circle'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        payload = response.data['data']
        self.assertEqual(str(payload['community_id']), str(self.community.id))
        self.assertEqual(payload['community_name'], 'Run Club')
        self.assertTrue(BuddyLive.objects.filter(community=self.community).exists())

    def test_a_schedule_slot_can_create_a_linked_live(self):
        start = timezone.now() + timedelta(days=3)
        response = self.client_owner.post(
            self._url('schedules'),
            {
                'title': 'Tempo session',
                'activity_type': 'live_stream',
                'start_time': start.isoformat(),
                'end_time': (start + timedelta(hours=1)).isoformat(),
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        post = GymRoutinePost.objects.get(community=self.community)
        self.assertIsNotNone(post.linked_live_id)
        self.assertEqual(post.linked_live.community_id, self.community.id)

    # ── Visibility ─────────────────────────────────────────────────────
    def test_non_member_can_read_a_public_community_calendar(self):
        MarketplaceEvent.objects.create(
            creator=self.owner, community=self.community, title='Public run',
            start_datetime=timezone.now() + timedelta(days=1),
            end_datetime=timezone.now() + timedelta(days=1, hours=1),
        )
        response = self.client_outsider.get(self._url('events'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']), 1)

    def test_non_member_gets_nothing_from_a_private_community(self):
        self.community.is_public = False
        self.community.save(update_fields=['is_public'])
        response = self.client_outsider.get(self._url('events'))
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_member_can_read_but_not_delete_an_activity(self):
        event = MarketplaceEvent.objects.create(
            creator=self.owner, community=self.community, title='Run',
            start_datetime=timezone.now() + timedelta(days=1),
            end_datetime=timezone.now() + timedelta(days=1, hours=1),
        )
        self.assertEqual(self.client_member.get(self._url('events')).status_code, status.HTTP_200_OK)
        self.assertEqual(
            self.client_member.delete(self._url(f'events/{event.id}')).status_code,
            status.HTTP_403_FORBIDDEN,
        )

    # ── Model constraints ──────────────────────────────────────────────
    def test_routine_post_owner_is_exclusive(self):
        from django.db import IntegrityError, transaction

        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                GymRoutinePost.objects.create(author=self.owner)

    def test_event_cannot_belong_to_gym_and_community_at_once(self):
        from django.db import IntegrityError, transaction
        from apps.gyms.models import Gym

        gym = Gym.objects.create(name='Iron Core', handle='ironcore', category='fitness')
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                MarketplaceEvent.objects.create(
                    creator=self.owner, gym=gym, community=self.community,
                    title='Both', start_datetime=timezone.now(),
                    end_datetime=timezone.now() + timedelta(hours=1),
                )
