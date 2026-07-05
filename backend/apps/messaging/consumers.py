import json
import time
import logging
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from django.core.cache import cache
from django.db import models as db_models
from django.utils import timezone
from .auth import get_user_from_token, get_token_from_scope
from apps.lives.models import BuddyLive
from apps.wallet.models import ArtifactTransaction
from apps.wallet.views import _deduct_artifacts, _credit_artifacts

_viewer_sets: dict[str, set] = {}


async def _viewer_add(live_id, user_id):
    try:
        cache.sadd(f'live_viewers:{live_id}', user_id)
        cache.expire(f'live_viewers:{live_id}', 3600)
        return cache.scard(f'live_viewers:{live_id}')
    except (AttributeError, TypeError):
        _viewer_sets.setdefault(live_id, set()).add(user_id)
        return len(_viewer_sets[live_id])


async def _viewer_remove(live_id, user_id):
    try:
        cache.srem(f'live_viewers:{live_id}', user_id)
        return cache.scard(f'live_viewers:{live_id}')
    except (AttributeError, TypeError):
        _viewer_sets.get(live_id, set()).discard(user_id)
        return len(_viewer_sets.get(live_id, set()))

logger = logging.getLogger(__name__)


class UserConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.user_id = self.scope['url_route']['kwargs']['user_id']

        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous or str(user.id) != self.user_id:
            logger.warning('UserConsumer REJECT: token=%s user=%s anonymous=%s url_user_id=%s token_user_id=%s',
                           'present' if token else 'missing', type(user).__name__,
                           getattr(user, 'is_anonymous', 'N/A'), self.user_id,
                           str(getattr(user, 'id', 'N/A')))
            await self.close(code=4001)
            return

        self.group_name = f'user_{self.user_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        pass

    async def event_notification(self, event):
        await self.send_json(event['data'])

    async def event_message(self, event):
        await self.send_json(event['data'])

    async def event_presence(self, event):
        await self.send_json(event['data'])


class ConversationConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous:
            await self.close(code=4001)
            return

        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.group_name = f'conversation_{self.conversation_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'chat_message',
            'data': content,
        })

    async def chat_message(self, event):
        await self.send_json(event['data'])


class TypingConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous:
            await self.close(code=4001)
            return

        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.group_name = f'typing_{self.conversation_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'typing_event',
            'data': content,
        })

    async def typing_event(self, event):
        await self.send_json(event['data'])


class LiveConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.live_id = self.scope['url_route']['kwargs']['live_id']
        self.group_name = f'live_{self.live_id}'
        self.viewer_key = f'live_viewers:{self.live_id}'

        token = get_token_from_scope(self.scope)
        self.user = await get_user_from_token(token) if token else None

        if not self.user or self.user.is_anonymous:
            await self.close(code=4001)
            return

        self.user_id = str(self.user.id)
        self.profile = await database_sync_to_async(lambda: getattr(self.user, 'profile', None))()

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

        viewer_count = await _viewer_add(self.live_id, self.user_id)
        await self.channel_layer.group_send(self.group_name, {
            'type': 'live_viewer_count',
            'data': {
                'type': 'live_viewer_count',
                'count': viewer_count,
            },
        })

        await database_sync_to_async(self._update_viewer_peak)(viewer_count)

        await self.send_json({
            'type': 'connected',
            'data': {
                'user_id': self.user_id,
                'live_id': self.live_id,
                'viewer_count': viewer_count,
            },
        })

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

        viewer_count = 0
        if hasattr(self, 'user_id'):
            viewer_count = await _viewer_remove(self.live_id, self.user_id)
            await self.channel_layer.group_send(self.group_name, {
                'type': 'live_viewer_count',
                'data': {
                    'type': 'live_viewer_count',
                    'count': viewer_count,
                },
            })
            await database_sync_to_async(self._mark_attendee_left)()

    def _mark_attendee_left(self):
        try:
            from apps.lives.models import LiveAttendee
            LiveAttendee.objects.filter(
                live_id=self.live_id,
                user=self.profile,
                left_at__isnull=True,
            ).update(left_at=timezone.now())
        except Exception:
            pass

    def _update_viewer_peak(self, viewer_count):
        try:
            live = BuddyLive.objects.get(id=self.live_id)
            if viewer_count > live.viewer_peak:
                live.viewer_peak = viewer_count
                live.save(update_fields=['viewer_peak'])
        except BuddyLive.DoesNotExist:
            pass

    async def _get_live_host(self):
        try:
            live = await database_sync_to_async(BuddyLive.objects.get)(id=self.live_id)
            return await database_sync_to_async(lambda: live.host)()
        except BuddyLive.DoesNotExist:
            return None

    async def _process_gift(self, artifact_type: str, quantity: int):
        from apps.wallet.views import _platform_cut

        host = await self._get_live_host()
        if not host or host.user_id == self.user_id:
            return None

        ok = await database_sync_to_async(_deduct_artifacts)(self.profile, artifact_type, quantity)
        if not ok:
            return None

        cut = await database_sync_to_async(_platform_cut)('tip', artifact_type, quantity)
        host_credit = quantity - cut

        if host_credit > 0:
            await database_sync_to_async(_credit_artifacts)(host, artifact_type, host_credit)

        tx = await database_sync_to_async(ArtifactTransaction.objects.create)(
            user=self.profile, transaction_type='tip_sent',
            artifact_type=artifact_type, quantity=quantity,
            direction='debit', counterparty=host,
            status='completed', reference_id=f'live_{self.live_id}',
        )
        if host_credit > 0:
            await database_sync_to_async(ArtifactTransaction.objects.create)(
                user=host, transaction_type='tip_received',
                artifact_type=artifact_type, quantity=host_credit,
                direction='credit', counterparty=self.profile,
                status='completed', reference_id=f'live_{self.live_id}',
            )
        if cut > 0:
            await database_sync_to_async(ArtifactTransaction.objects.create)(
                user=host, transaction_type='platform_cut',
                artifact_type=artifact_type, quantity=cut,
                direction='debit', status='completed',
                description=f'Platform fee ({int(_platform_cut("tip", artifact_type, 100))}%)',
            )

        try:
            total = cache.hincrby(f'live_gifts:{self.live_id}', artifact_type, quantity)
        except (AttributeError, TypeError):
            total = quantity

        return {
            'tx_id': str(tx.id),
            'artifact_type': artifact_type,
            'quantity': quantity,
            'sender_id': self.user_id,
            'sender_name': getattr(self.profile, 'display_name', 'Anonymous'),
            'total': total,
        }

    async def receive_json(self, content, **kwargs):
        event_type = content.get('type', 'chat')
        if event_type == 'chat':
            chat_data = content.get('data', {})
            message = chat_data.get('message', '')
            gift = chat_data.get('gift')

            enriched = {
                'type': 'live_chat',
                'data': {
                    'type': 'live_chat',
                    'user_id': self.user_id,
                    'display_name': getattr(self.profile, 'display_name', 'Anonymous'),
                    'avatar_url': getattr(self.profile, 'avatar_url', ''),
                    'message': message,
                    'timestamp': time.time(),
                },
            }

            if gift and isinstance(gift, dict):
                gift_result = await self._process_gift(
                    gift.get('artifact_type', ''), gift.get('quantity', 0),
                )
                if gift_result:
                    enriched['data']['gift'] = gift_result
                    enriched['data']['priority'] = True

            await self.channel_layer.group_send(self.group_name, enriched)

        elif event_type == 'reaction':
            enriched = {
                'type': 'live_reaction',
                'data': {
                    'type': 'live_reaction',
                    'user_id': self.user_id,
                    'display_name': getattr(self.profile, 'display_name', 'Anonymous'),
                    'emoji': content.get('data', {}).get('emoji', '🔥'),
                    'timestamp': time.time(),
                },
            }
            await self.channel_layer.group_send(self.group_name, enriched)

        elif event_type == 'gift':
            gift_data = content.get('data', {})
            if self.profile and self.live_id:
                gift_result = await self._process_gift(
                    gift_data.get('artifact_type', ''), gift_data.get('quantity', 0),
                )
                if gift_result:
                    try:
                        totals = cache.hgetall(f'live_gifts:{self.live_id}')
                        totals = {k.decode(): int(v) for k, v in totals.items()} if totals else {}
                    except (AttributeError, TypeError):
                        totals = {}
                    await self.channel_layer.group_send(self.group_name, {
                        'type': 'live_gift',
                        'data': {
                            'type': 'live_gift',
                            'gift': gift_result,
                            'totals': totals,
                        },
                    })
        else:
            await self.channel_layer.group_send(self.group_name, {
                'type': f'live_{event_type}',
                'data': content,
            })

    async def live_chat(self, event):
        await self.send_json(event)

    async def live_reaction(self, event):
        await self.send_json(event)

    async def live_viewer_count(self, event):
        await self.send_json(event)

    async def live_gift(self, event):
        await self.send_json(event)

    async def live_rep_counter(self, event):
        await self.send_json(event)


class GymChatConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous:
            await self.close(code=4001)
            return

        self.gym_id = self.scope['url_route']['kwargs']['gym_id']
        self.group_name = f'gym_chat_{self.gym_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'gym_message',
            'data': content,
        })

    async def gym_message(self, event):
        await self.send_json(event['data'])


class RandomDropConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous:
            await self.close(code=4001)
            return

        self.group_name = 'random_drop_pool'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        event_type = content.get('type', 'join_pool')
        await self.channel_layer.group_send(self.group_name, {
            'type': f'random_drop_{event_type}',
            'data': content,
        })

    async def random_drop_join_pool(self, event):
        await self.send_json(event['data'])

    async def random_drop_match_found(self, event):
        await self.send_json(event['data'])
