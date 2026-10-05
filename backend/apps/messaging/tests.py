from django.test import TestCase, TransactionTestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.lives.models import BuddyLive
from apps.messaging.models import (
    Conversation, ConversationPromotion, CallSession, CallParticipant, Message,
)
from apps.profiles.models import (
    BlockRelationship, BuddyRelationship, BuddySearchProfile, Profile,
)
from apps.wallet.models import ArtifactTransaction

import asyncio

from .consumers import LiveConsumer, RandomDropConsumer, _RateLimiter


class _FakeChannelLayer:
    """Captures group_send traffic so relay logic can be asserted directly."""

    def __init__(self):
        self.sent = []

    async def group_send(self, group, message):
        self.sent.append((group, message))


def _make_live_consumer(user_id, profile, live_id):
    consumer = LiveConsumer()
    consumer.channel_layer = _FakeChannelLayer()
    consumer.channel_name = 'test-channel'
    consumer.user_id = user_id
    consumer.profile = profile
    consumer.live_id = live_id
    consumer.group_name = f'live_{live_id}'
    consumer._limiter = _RateLimiter()
    return consumer


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


class MessagingContractTests(TestCase):
    def setUp(self):
        self.alice_user = User.objects.create_user(email='contract-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='contract-bob@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='contract-alice', display_name='Alice')
        self.bob = Profile.objects.create(
            user=self.bob_user, username='contract-bob', display_name='Bob', role='trainer',
        )
        self.client = APIClient()
        self.client.force_authenticate(self.alice_user)

    def test_start_conversation_accepts_profile_user_ids(self):
        response = self.client.post(
            '/api/v1/messaging/conversations/start/',
            {'participants': [str(self.bob.user_id)]}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            {item['username'] for item in response.data['data']['participants_data']},
            {'contract-alice', 'contract-bob'},
        )

    def test_deleted_messages_are_not_returned(self):
        conversation = Conversation.objects.create()
        conversation.participants.add(self.alice, self.bob)
        visible = Message.objects.create(conversation=conversation, sender=self.bob, body='visible')
        Message.objects.create(
            conversation=conversation, sender=self.bob, body='hidden for alice',
            deleted_for=[str(self.alice.user_id)],
        )
        response = self.client.get(
            f'/api/v1/messaging/conversations/{conversation.id}/messages/',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual([item['id'] for item in response.data['data']], [str(visible.id)])


class LiveConsumerRelayTests(TestCase):
    """Live-room relay: event allowlist, identity forcing, rate limits.

    These exercise the pure relay logic — no DB access happens in the
    chat/reaction paths, so a plain TestCase + fake channel layer suffices.
    """

    def setUp(self):
        self.sender_user = User.objects.create_user(email='live-sender@example.com', password='TestPass123!')
        self.sender = Profile.objects.create(user=self.sender_user, username='live-sender', display_name='Sender')
        self.live_id = '11111111-1111-1111-1111-111111111111'
        self.consumer = _make_live_consumer(str(self.sender.user_id), self.sender, self.live_id)

    def test_chat_broadcasts_server_side_identity(self):
        asyncio.run(self.consumer.receive_json({
            'type': 'chat',
            'data': {'message': 'hello', 'user_id': 'spoofed-id'},
        }))
        self.assertEqual(len(self.consumer.channel_layer.sent), 1)
        payload = self.consumer.channel_layer.sent[0][1]
        self.assertEqual(payload['data']['user_id'], str(self.sender.user_id))
        self.assertEqual(payload['data']['display_name'], 'Sender')

    def test_unknown_event_type_is_dropped(self):
        asyncio.run(self.consumer.receive_json({'type': 'mute_user', 'data': {'target': 'x'}}))
        self.assertEqual(self.consumer.channel_layer.sent, [])

    def test_chat_is_rate_limited_per_connection(self):
        for i in range(25):
            asyncio.run(self.consumer.receive_json({'type': 'chat', 'data': {'message': f'm{i}'}}))
        self.assertEqual(len(self.consumer.channel_layer.sent), 20)

    def test_reactions_are_rate_limited(self):
        for i in range(15):
            asyncio.run(self.consumer.receive_json({'type': 'reaction', 'data': {'emoji': '🔥'}}))
        self.assertEqual(len(self.consumer.channel_layer.sent), 10)

    def test_gift_events_are_rate_limited(self):
        for i in range(5):
            asyncio.run(self.consumer.receive_json({'type': 'gift', 'data': {'artifact_type': 'dumbbell', 'quantity': 1}}))
        # No live/host exists in this TestCase — settlements fail, but only
        # two events may ever reach the settlement stage per window.
        self.assertLessEqual(len(self.consumer.channel_layer.sent), 2)


class LiveConsumerCohostAuthorizationTests(TransactionTestCase):
    """Cohost events must be verified against the live's host/cohost records."""

    def setUp(self):
        self.host_user = User.objects.create_user(email='live-host@example.com', password='TestPass123!')
        self.cohost_user = User.objects.create_user(email='live-cohost@example.com', password='TestPass123!')
        self.attendee_user = User.objects.create_user(email='live-attendee@example.com', password='TestPass123!')
        self.host = Profile.objects.create(user=self.host_user, username='live-host', display_name='Host')
        self.cohost = Profile.objects.create(user=self.cohost_user, username='live-cohost', display_name='Cohost')
        self.attendee = Profile.objects.create(user=self.attendee_user, username='live-attendee', display_name='Attendee')
        self.live = BuddyLive.objects.create(
            host=self.host, title='Auth live', live_type='open_sweat',
            category='strength', status='live',
        )
        self.live.co_hosts.add(self.cohost)

    def _consumer_for(self, profile):
        return _make_live_consumer(str(profile.user_id), profile, str(self.live.id))

    def test_host_cohost_event_is_relayed_with_forced_identity(self):
        consumer = self._consumer_for(self.host)
        asyncio.run(consumer.receive_json({
            'type': 'cohost_invite',
            'data': {'user_id': 'spoofed-id', 'username': 'spoofed', 'display_name': 'Spoofed'},
        }))
        self.assertEqual(len(consumer.channel_layer.sent), 1)
        payload = consumer.channel_layer.sent[0][1]
        self.assertEqual(payload['data']['user_id'], str(self.host.user_id))
        self.assertEqual(payload['data']['username'], 'live-host')
        self.assertEqual(payload['data']['display_name'], 'Host')

    def test_attendee_cannot_send_host_only_events(self):
        for event_type in ('cohost_invite', 'cohost_removed'):
            consumer = self._consumer_for(self.attendee)
            asyncio.run(consumer.receive_json({'type': event_type, 'data': {}}))
            self.assertEqual(consumer.channel_layer.sent, [], event_type)

    def test_cohost_can_relay_cohost_response(self):
        consumer = self._consumer_for(self.cohost)
        asyncio.run(consumer.receive_json({'type': 'cohost_response', 'data': {'action': 'accept'}}))
        self.assertEqual(len(consumer.channel_layer.sent), 1)
        self.assertEqual(consumer.channel_layer.sent[0][1]['data']['user_id'], str(self.cohost.user_id))

    def test_attendee_cannot_relay_cohost_response(self):
        consumer = self._consumer_for(self.attendee)
        asyncio.run(consumer.receive_json({'type': 'cohost_response', 'data': {'action': 'accept'}}))
        self.assertEqual(consumer.channel_layer.sent, [])

    def test_host_cohost_removed_event_is_relayed(self):
        consumer = self._consumer_for(self.host)
        asyncio.run(consumer.receive_json({'type': 'cohost_removed', 'data': {}}))
        self.assertEqual(len(consumer.channel_layer.sent), 1)


class RandomDropIdentityTests(TestCase):
    """The random-drop relay must overwrite client-supplied identity fields."""

    def setUp(self):
        self.user = User.objects.create_user(email='drop-user@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='drop-user', display_name='Drop User')
        self.consumer = RandomDropConsumer()
        self.consumer.channel_layer = _FakeChannelLayer()
        self.consumer.user_id = str(self.user.id)
        self.consumer.profile = self.profile
        self.consumer.group_name = 'random_drop_pool'
        self.consumer._limiter = _RateLimiter()

    def test_client_supplied_identity_is_overwritten(self):
        asyncio.run(self.consumer.receive_json({
            'type': 'join_pool',
            'data': {'user_id': 'victim-id', 'username': 'victim', 'display_name': 'Victim'},
        }))
        self.assertEqual(len(self.consumer.channel_layer.sent), 1)
        data = self.consumer.channel_layer.sent[0][1]['data']['data']
        self.assertEqual(data['user_id'], str(self.user.id))
        self.assertEqual(data['username'], 'drop-user')
        self.assertEqual(data['display_name'], 'Drop User')

    def test_non_dict_data_gets_server_identity(self):
        asyncio.run(self.consumer.receive_json({'type': 'ready', 'data': 'garbage'}))
        self.assertEqual(self.consumer.channel_layer.sent[0][1]['data']['data']['user_id'], str(self.user.id))

    def test_unknown_event_type_is_dropped(self):
        asyncio.run(self.consumer.receive_json({'type': 'match_mine', 'data': {}}))
        self.assertEqual(self.consumer.channel_layer.sent, [])


class LiveGiftSettlementTests(TransactionTestCase):
    """Gift settlement is atomic and idempotent — replays never double-charge."""

    def setUp(self):
        self.sender_user = User.objects.create_user(email='gifter@example.com', password='TestPass123!')
        self.host_user = User.objects.create_user(email='gift-host@example.com', password='TestPass123!')
        self.sender = Profile.objects.create(
            user=self.sender_user, username='gifter', display_name='Gifter',
            artifact_balance={'dumbbell': 10},
        )
        self.host = Profile.objects.create(
            user=self.host_user, username='gift-host', display_name='Gift Host',
            artifact_balance={'dumbbell': 0},
        )
        self.live = BuddyLive.objects.create(
            host=self.host, title='Gift live', live_type='open_sweat',
            category='strength', status='live',
        )
        self.consumer = _make_live_consumer(str(self.sender.user_id), self.sender, str(self.live.id))

    def _send_gift(self, gift_key='event-1'):
        return asyncio.run(self.consumer.receive_json({
            'type': 'gift',
            'data': {'artifact_type': 'dumbbell', 'quantity': 5, 'gift_key': gift_key},
        }))

    def test_gift_settles_once_and_replay_does_not_double_charge(self):
        self._send_gift('event-1')
        self.sender.refresh_from_db()
        self.host.refresh_from_db()
        self.assertEqual(self.sender.artifact_balance['dumbbell'], 5)
        # tip cut is 20%: host receives 4 of 5
        self.assertEqual(self.host.artifact_balance['dumbbell'], 4)
        self.assertEqual(
            ArtifactTransaction.objects.filter(
                user=self.sender, transaction_type='tip_sent',
            ).count(), 1,
        )

        # Replayed WS event: same gift key — must not charge again.
        self._send_gift('event-1')
        self.sender.refresh_from_db()
        self.host.refresh_from_db()
        self.assertEqual(self.sender.artifact_balance['dumbbell'], 5)
        self.assertEqual(self.host.artifact_balance['dumbbell'], 4)
        self.assertEqual(
            ArtifactTransaction.objects.filter(
                user=self.sender, transaction_type='tip_sent',
            ).count(), 1,
        )

    def test_distinct_gifts_settle_separately(self):
        self._send_gift('event-1')
        self._send_gift('event-2')
        self.sender.refresh_from_db()
        self.assertEqual(self.sender.artifact_balance['dumbbell'], 0)
        self.assertEqual(
            ArtifactTransaction.objects.filter(
                user=self.sender, transaction_type='tip_sent',
            ).count(), 2,
        )

    def test_insufficient_balance_settles_nothing(self):
        self.sender.artifact_balance = {'dumbbell': 1}
        self.sender.save(update_fields=['artifact_balance'])
        self._send_gift('event-1')
        self.sender.refresh_from_db()
        self.host.refresh_from_db()
        self.assertEqual(self.sender.artifact_balance['dumbbell'], 1)
        self.assertEqual(self.host.artifact_balance['dumbbell'], 0)
        self.assertFalse(
            ArtifactTransaction.objects.filter(user=self.sender, transaction_type='tip_sent').exists(),
        )


class ConversationPromotionTests(TestCase):
    """Discovery DM -> buddy relationship promotion (mutual consent)."""

    def setUp(self):
        self.alice_user = User.objects.create_user(email='promo-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='promo-bob@example.com', password='TestPass123!')
        self.carol_user = User.objects.create_user(email='promo-carol@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='promo-alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='promo-bob', display_name='Bob')
        self.carol = Profile.objects.create(user=self.carol_user, username='promo-carol', display_name='Carol')

        self.conv = Conversation.objects.create(is_group=False, origin='discovery')
        self.conv.participants.add(self.alice, self.bob)

        def client_for(profile):
            c = APIClient()
            refresh = RefreshToken.for_user(profile.user)
            c.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            return c

        self.client_alice = client_for(self.alice)
        self.client_bob = client_for(self.bob)
        self.client_carol = client_for(self.carol)

    def _promote_url(self):
        return f'/api/v1/messaging/conversations/{self.conv.id}/promote/'

    def _respond_url(self, promotion):
        return f'/api/v1/messaging/conversations/promotions/{promotion.id}/respond/'

    def test_promote_requires_authentication(self):
        anon = APIClient()
        resp = anon.post(self._promote_url(), {}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_promote_then_accept_creates_confirmed_buddies_and_stamps_origin(self):
        r = self.client_alice.post(self._promote_url(), {}, format='json')
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        self.assertEqual(r.data['data']['status'], 'pending')

        promotion = ConversationPromotion.objects.get(conversation=self.conv)
        self.assertEqual(promotion.requested_by, self.alice)

        resp = self.client_bob.post(
            self._respond_url(promotion), {'accept': True}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        promotion.refresh_from_db()
        self.assertEqual(promotion.status, 'accepted')
        self.assertIsNotNone(promotion.responded_at)

        self.conv.refresh_from_db()
        self.assertEqual(self.conv.origin, 'buddy')
        self.assertIsNotNone(self.conv.promoted_at)

        rel = BuddyRelationship.objects.get(from_user=self.alice, to_user=self.bob)
        self.assertEqual(rel.status, 'confirmed')

        # Serialized view reflects the promoted state.
        detail = self.client_alice.get(f'/api/v1/messaging/conversations/{self.conv.id}/')
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data['data']['origin'], 'buddy')
        self.assertEqual(detail.data['data']['promotion_status'], 'accepted')
        self.assertFalse(detail.data['data']['promotable'])

    def test_promote_is_idempotent_for_pending_request(self):
        self.client_alice.post(self._promote_url(), {}, format='json')
        second = self.client_alice.post(self._promote_url(), {}, format='json')
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(ConversationPromotion.objects.filter(conversation=self.conv).count(), 1)

    def test_only_other_participant_can_respond(self):
        self.client_alice.post(self._promote_url(), {}, format='json')
        promotion = ConversationPromotion.objects.get(conversation=self.conv)

        resp = self.client_alice.post(
            self._respond_url(promotion), {'accept': True}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(resp.data['success'])

        outsider = self.client_carol.post(
            self._respond_url(promotion), {'accept': True}, format='json',
        )
        self.assertEqual(outsider.status_code, status.HTTP_403_FORBIDDEN)

        promotion.refresh_from_db()
        self.assertEqual(promotion.status, 'pending')
        self.assertFalse(BuddyRelationship.objects.exists())

    def test_confirmed_buddies_get_409_on_promote(self):
        BuddyRelationship.objects.create(
            from_user=self.alice, to_user=self.bob, status='confirmed',
        )
        resp = self.client_alice.post(self._promote_url(), {}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_409_CONFLICT)
        self.assertFalse(ConversationPromotion.objects.exists())

    def test_promote_rejects_group_conversation(self):
        group = Conversation.objects.create(is_group=True, group_name='Crew')
        group.participants.add(self.alice, self.bob, self.carol)
        resp = self.client_alice.post(
            f'/api/v1/messaging/conversations/{group.id}/promote/', {}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_decline_leaves_conversation_unpromoted(self):
        self.client_alice.post(self._promote_url(), {}, format='json')
        promotion = ConversationPromotion.objects.get(conversation=self.conv)

        resp = self.client_bob.post(
            self._respond_url(promotion), {'accept': False}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        promotion.refresh_from_db()
        self.assertEqual(promotion.status, 'declined')
        self.assertIsNotNone(promotion.responded_at)

        self.conv.refresh_from_db()
        self.assertEqual(self.conv.origin, 'discovery')
        self.assertIsNone(self.conv.promoted_at)
        self.assertFalse(BuddyRelationship.objects.exists())

        detail = self.client_alice.get(f'/api/v1/messaging/conversations/{self.conv.id}/')
        self.assertEqual(detail.data['data']['promotion_status'], 'declined')
        self.assertTrue(detail.data['data']['promotable'])


class MessagingBlockEnforcementTests(TestCase):
    """Blocks are enforced on read/write paths, not only at conversation creation."""

    def setUp(self):
        self.alice_user = User.objects.create_user(email='block-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='block-bob@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='block-alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='block-bob', display_name='Bob')

        self.conv = Conversation.objects.create(is_group=False, origin='discovery')
        self.conv.participants.add(self.alice, self.bob)
        Message.objects.create(conversation=self.conv, sender=self.bob, body='hello')

        def client_for(profile):
            c = APIClient()
            refresh = RefreshToken.for_user(profile.user)
            c.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            return c

        self.client_alice = client_for(self.alice)
        self.client_bob = client_for(self.bob)

    def _messages_url(self):
        return f'/api/v1/messaging/conversations/{self.conv.id}/messages/'

    def test_blocker_cannot_see_or_send_in_conversation(self):
        BlockRelationship.objects.create(blocker=self.bob, blocked=self.alice)

        listing = self.client_bob.get('/api/v1/messaging/conversations/')
        self.assertEqual(listing.status_code, status.HTTP_200_OK)
        self.assertEqual(listing.data['data'], [])

        read = self.client_bob.get(self._messages_url())
        self.assertEqual(read.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(read.data['success'])

        send = self.client_bob.post(self._messages_url(), {'body': 'hi'}, format='json')
        self.assertEqual(send.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(send.data['success'])
        self.assertEqual(self.conv.messages.count(), 1)

    def test_blocked_user_cannot_see_or_send_in_conversation(self):
        BlockRelationship.objects.create(blocker=self.alice, blocked=self.bob)

        listing = self.client_bob.get('/api/v1/messaging/conversations/')
        self.assertEqual(listing.status_code, status.HTTP_200_OK)
        self.assertEqual(listing.data['data'], [])

        self.assertEqual(self.client_bob.get(self._messages_url()).status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(
            self.client_bob.post(self._messages_url(), {'body': 'hi'}, format='json').status_code,
            status.HTTP_403_FORBIDDEN,
        )

    def test_unblocked_conversation_is_visible_and_readable(self):
        listing = self.client_alice.get('/api/v1/messaging/conversations/')
        self.assertEqual([c['id'] for c in listing.data['data']], [str(self.conv.id)])
        self.assertTrue(listing.data['data'][0]['promotable'])

        self.assertEqual(self.client_alice.get(self._messages_url()).status_code, status.HTTP_200_OK)
        resp = self.client_alice.post(self._messages_url(), {'body': 'hey'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)

    def test_chat_consumer_membership_check_rejects_blocked_pair(self):
        from .consumers import ChatConsumer

        consumer = ChatConsumer()
        consumer.conversation_id = str(self.conv.id)
        consumer.profile = self.bob

        # Call the sync body directly: the database_sync_to_async wrapper hops to a
        # thread executor, which sqlite (in-transaction) will not allow here.
        is_member = ChatConsumer._is_member.__wrapped__.__get__(consumer, ChatConsumer)

        self.assertTrue(is_member())

        BlockRelationship.objects.create(blocker=self.bob, blocked=self.alice)
        self.assertFalse(is_member())

    def test_blocked_pair_cannot_promote(self):
        BlockRelationship.objects.create(blocker=self.bob, blocked=self.alice)
        resp = self.client_alice.post(
            f'/api/v1/messaging/conversations/{self.conv.id}/promote/', {}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)


class DiscoveryThreadOriginTests(TestCase):
    """Threads opened from the buddy-finder surface must be tagged
    'discovery', otherwise the buddy-messages list can never find them."""

    def setUp(self):
        self.alice_user = User.objects.create_user(email='origin-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='origin-bob@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='origin-alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='origin-bob', display_name='Bob')
        # Both need a search profile for _allowed_to_message to permit the DM.
        BuddySearchProfile.objects.create(profile=self.alice, visibility='public')
        BuddySearchProfile.objects.create(profile=self.bob, visibility='public')

        def client_for(profile):
            c = APIClient()
            refresh = RefreshToken.for_user(profile.user)
            c.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            return c

        self.client_alice = client_for(self.alice)

    def test_start_with_origin_discovery_is_tagged(self):
        resp = self.client_alice.post(
            '/api/v1/messaging/conversations/start/',
            {'participants': ['origin-bob'], 'origin': 'discovery'},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.data)
        self.assertEqual(resp.data['data']['origin'], 'discovery')

    def test_start_without_origin_defaults_to_direct(self):
        resp = self.client_alice.post(
            '/api/v1/messaging/conversations/start/',
            {'participants': ['origin-bob']},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.data)
        self.assertEqual(resp.data['data']['origin'], 'direct')

    def test_unknown_origin_is_rejected(self):
        resp = self.client_alice.post(
            '/api/v1/messaging/conversations/start/',
            {'participants': ['origin-bob'], 'origin': 'bogus'},
            format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class PromotionExposureTests(TestCase):
    """The invited participant needs the promotion id to accept it, so the
    conversation payload must expose it while a request is pending."""

    def setUp(self):
        self.alice_user = User.objects.create_user(email='exp-alice@example.com', password='TestPass123!')
        self.bob_user = User.objects.create_user(email='exp-bob@example.com', password='TestPass123!')
        self.alice = Profile.objects.create(user=self.alice_user, username='exp-alice', display_name='Alice')
        self.bob = Profile.objects.create(user=self.bob_user, username='exp-bob', display_name='Bob')
        self.conv = Conversation.objects.create(is_group=False, origin='discovery')
        self.conv.participants.add(self.alice, self.bob)

        def client_for(profile):
            c = APIClient()
            refresh = RefreshToken.for_user(profile.user)
            c.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
            return c

        self.client_alice = client_for(self.alice)
        self.client_bob = client_for(self.bob)

    def test_conversation_payload_exposes_pending_promotion_id(self):
        self.client_alice.post(
            f'/api/v1/messaging/conversations/{self.conv.id}/promote/', {}, format='json',
        )
        resp = self.client_bob.get(f'/api/v1/messaging/conversations/{self.conv.id}/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        data = resp.data['data']
        self.assertEqual(data['promotion_status'], 'pending')
        self.assertIsNotNone(data['promotion_id'])
        self.assertTrue(data['promotable'])

    def test_promotion_id_absent_before_any_request(self):
        resp = self.client_bob.get(f'/api/v1/messaging/conversations/{self.conv.id}/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertIsNone(resp.data['data']['promotion_id'])
        self.assertIsNone(resp.data['data']['promotion_status'])

    def test_conversation_payload_identifies_the_requester(self):
        self.client_alice.post(
            f'/api/v1/messaging/conversations/{self.conv.id}/promote/', {}, format='json',
        )
        resp = self.client_bob.get(f'/api/v1/messaging/conversations/{self.conv.id}/')
        data = resp.data['data']
        self.assertEqual(str(data['promotion_requested_by']), str(self.alice.user_id))
        # The responder can tell they are NOT the requester, so only they see
        # the Accept/Decline controls.
        self.assertNotEqual(str(data['promotion_requested_by']), str(self.bob.user_id))

    def test_requester_is_identifiable_in_their_own_session(self):
        self.client_alice.post(
            f'/api/v1/messaging/conversations/{self.conv.id}/promote/', {}, format='json',
        )
        resp = self.client_alice.get('/api/v1/messaging/conversations/')
        convo = next(c for c in resp.data['data'] if c['id'] == str(self.conv.id))
        self.assertEqual(str(convo['promotion_requested_by']), str(self.alice.user_id))
