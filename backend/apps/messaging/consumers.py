"""
Unified WebSocket consumers for BuddyUp messaging, live rooms, and gym chat.
"""
import json
import time
import logging
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from django.core.cache import cache
from django.utils import timezone
from .auth import get_user_from_token, get_token_from_scope
from apps.lives.models import BuddyLive
from apps.lives.access import can_access_live, has_live_admission
from apps.wallet.models import ArtifactTransaction
from apps.wallet.utils import deduct_artifacts, credit_artifacts

_viewer_sets: dict[str, set] = {}
logger = logging.getLogger(__name__)


# ─── Viewer helpers ───────────────────────────────────────────────────────────

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


# ─── User presence consumer ──────────────────────────────────────────────────

class UserConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.user_id = self.scope['url_route']['kwargs']['user_id']
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous or str(user.id) != self.user_id:
            await self.close(code=4001)
            return
        self.group_name = f'user_{self.user_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

        # Mark user as online in cache
        from django.core.cache import cache
        cache.set(f'user_online_{self.user_id}', True, timeout=86400)
        
        # Broadcast presence
        await self.channel_layer.group_send('presence', {
            'type': 'event_presence',
            'data': {'type': 'presence', 'user_id': self.user_id, 'status': 'online'}
        })

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)
        
        if hasattr(self, 'user_id'):
            from django.core.cache import cache
            cache.delete(f'user_online_{self.user_id}')
            await database_sync_to_async(self._update_last_seen)()
            
            await self.channel_layer.group_send('presence', {
                'type': 'event_presence',
                'data': {'type': 'presence', 'user_id': self.user_id, 'status': 'offline'}
            })

    def _update_last_seen(self):
        try:
            from apps.profiles.models import Profile
            from django.utils import timezone
            Profile.objects.filter(user_id=self.user_id).update(last_seen=timezone.now())
        except Exception:
            pass

    async def receive_json(self, content, **kwargs):
        pass

    async def event_notification(self, event):
        await self.send_json(event['data'])

    async def event_message(self, event):
        await self.send_json(event['data'])

    async def event_presence(self, event):
        await self.send_json(event['data'])


# ─── Chat consumer (messages + typing + WebRTC signaling) ────────────────────

class ChatConsumer(AsyncJsonWebsocketConsumer):
    """
    Single consumer per conversation handling:
    - Real-time messages
    - Typing start/stop
    - Read receipts
    - Message reactions
    - WebRTC call signaling (offer, answer, ice-candidate, hang-up)
    """

    async def connect(self):
        token = get_token_from_scope(self.scope)
        user = await get_user_from_token(token) if token else None
        if not user or user.is_anonymous:
            await self.close(code=4001)
            return

        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.user = user
        self.profile = await database_sync_to_async(
            lambda: getattr(user, 'profile', None)
        )()
        if not self.profile:
            await self.close(code=4001)
            return

        # Verify membership
        is_member = await self._is_member()
        if not is_member:
            await self.close(code=4003)
            return

        self.group_name = f'conversation_{self.conversation_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'group_name'):
            # Auto-stop typing on disconnect
            await self.channel_layer.group_send(self.group_name, {
                'type': 'typing_event',
                'data': {
                    'type': 'typing_stop',
                    'user_id': str(self.profile.user_id) if hasattr(self, 'profile') and self.profile else '',
                    'username': getattr(self.profile, 'username', '') if hasattr(self, 'profile') else '',
                }
            })
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        msg_type = content.get('type', 'message')

        if msg_type == 'message':
            await self._handle_message(content)
        elif msg_type == 'typing_start':
            await self._handle_typing(True)
        elif msg_type == 'typing_stop':
            await self._handle_typing(False)
        elif msg_type == 'read':
            await self._handle_read(content)
        elif msg_type == 'react':
            await self._handle_react(content)
        elif msg_type in ('call_offer', 'call_answer', 'call_ice', 'call_end', 'call_decline', 'call_ringing'):
            await self._handle_call_signal(msg_type, content)

    # ── Message handling ──────────────────────────────────────────────────────

    async def _handle_message(self, content):
        data = content.get('data', {})
        body = (data.get('body') or '').strip()
        message_type = data.get('message_type', 'text')
        # Validate message_type to allowed values
        allowed_types = {'text', 'photo', 'video', 'voice', 'document', 'location', 'poll', 'event'}
        if message_type not in allowed_types:
            message_type = 'text'
        media_url = data.get('media_url', '')
        media_mime = data.get('media_mime', '')
        file_name = data.get('file_name', '')
        reply_to_id = data.get('reply_to_id') or None
        metadata = data.get('metadata', {})

        if not body and not media_url:
            return

        msg = await self._save_message(
            body=body,
            message_type=message_type,
            media_url=media_url,
            media_mime=media_mime,
            file_name=file_name,
            reply_to_id=reply_to_id,
            metadata=metadata,
        )
        if not msg:
            return

        payload = await self._serialize_message(msg)

        # Broadcast to conversation group
        await self.channel_layer.group_send(self.group_name, {
            'type': 'chat_message',
            'data': payload,
        })

        # Also push to each recipient's user channel for notification badge
        await self._push_to_recipients(payload)

    async def _handle_typing(self, is_typing: bool):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'typing_event',
            'data': {
                'type': 'typing_start' if is_typing else 'typing_stop',
                'user_id': str(self.profile.user_id),
                'username': self.profile.username,
                'display_name': self.profile.display_name,
                'avatar_url': getattr(self.profile, 'avatar_url', ''),
                'conversation_id': self.conversation_id,
            }
        })

    async def _handle_read(self, content):
        message_id = content.get('message_id')
        count = await self._mark_read(message_id)
        await self.channel_layer.group_send(self.group_name, {
            'type': 'read_receipt',
            'data': {
                'type': 'read',
                'conversation_id': self.conversation_id,
                'reader_id': str(self.profile.user_id),
                'message_id': message_id,
                'count': count,
            }
        })

    async def _handle_react(self, content):
        message_id = content.get('message_id')
        emoji = content.get('emoji', '')
        if not message_id or not emoji:
            return
        reactions = await self._toggle_reaction(message_id, emoji)
        await self.channel_layer.group_send(self.group_name, {
            'type': 'reaction_event',
            'data': {
                'type': 'react',
                'conversation_id': self.conversation_id,
                'message_id': message_id,
                'reactions': reactions,
            }
        })

    async def _handle_call_signal(self, signal_type: str, content: dict):
        """Relay WebRTC signaling data to all other members of the conversation."""
        payload = {
            'type': signal_type,
            'conversation_id': self.conversation_id,
            'from_user_id': str(self.profile.user_id),
            'from_username': self.profile.username,
            'from_display_name': self.profile.display_name,
            'from_avatar_url': getattr(self.profile, 'avatar_url', ''),
            'data': content.get('data', {}),
            'call_type': content.get('call_type', 'audio'),
        }
        await self.channel_layer.group_send(self.group_name, {
            'type': 'call_signal',
            'data': payload,
            'sender_channel': self.channel_name,
        })
        if signal_type == 'call_offer':
            await self._push_call_signal_to_recipients(payload)

    # ── Channel layer handlers (broadcast receivers) ──────────────────────────

    async def chat_message(self, event):
        await self.send_json({'type': 'message', **event['data']})

    async def typing_event(self, event):
        # Don't echo typing events back to the sender
        if event['data'].get('user_id') == str(self.profile.user_id):
            return
        await self.send_json(event['data'])

    async def read_receipt(self, event):
        await self.send_json(event['data'])

    async def reaction_event(self, event):
        await self.send_json(event['data'])

    async def call_signal(self, event):
        # Don't relay back to the sender's own channel
        if event.get('sender_channel') == self.channel_name:
            return
        await self.send_json(event['data'])

    # ── DB helpers ────────────────────────────────────────────────────────────

    @database_sync_to_async
    def _is_member(self):
        from .models import Conversation
        return Conversation.objects.filter(
            id=self.conversation_id,
            participants=self.profile,
        ).exists()

    @database_sync_to_async
    def _save_message(self, body, message_type, media_url, media_mime, file_name, reply_to_id, metadata):
        from .models import Conversation, Message
        try:
            conv = Conversation.objects.get(id=self.conversation_id)
            if reply_to_id and not Message.objects.filter(
                id=reply_to_id, conversation=conv,
            ).exists():
                logger.warning('Rejected cross-conversation reply target in conversation=%s', self.conversation_id)
                return None
            msg = Message.objects.create(
                conversation=conv,
                sender=self.profile,
                message_type=message_type,
                body=body,
                media_url=media_url,
                media_mime=media_mime,
                file_name=file_name,
                reply_to_id=reply_to_id,
                metadata=metadata or {},
            )
            conv.last_message_text = body[:200] if body else message_type
            conv.last_message_at = timezone.now()
            conv.save(update_fields=['last_message_text', 'last_message_at'])
            return msg
        except Exception as exc:
            logger.exception('ChatConsumer._save_message error: %s', exc)
            return None

    @database_sync_to_async
    def _serialize_message(self, msg):
        reply_data = None
        if msg.reply_to_id:
            try:
                r = msg.reply_to
                reply_data = {
                    'id': str(r.id),
                    'body': r.body[:100],
                    'sender_name': r.sender.display_name,
                }
            except Exception:
                pass
        return {
            'id': str(msg.id),
            'conversation_id': str(msg.conversation_id),
            'sender_id': str(msg.sender.user_id),
            'message_type': msg.message_type,
            'body': msg.body,
            'media_url': msg.media_url,
            'media_mime': msg.media_mime,
            'file_name': msg.file_name,
            'reply_to_id': str(msg.reply_to_id) if msg.reply_to_id else None,
            'reply_data': reply_data,
            'metadata': msg.metadata,
            'is_read': msg.is_read,
            'reactions': {},
            'sender_data': {
                'username': msg.sender.username,
                'display_name': msg.sender.display_name,
                'avatar_url': msg.sender.avatar_url or '',
                'verification_status': msg.sender.verification_status or 'none',
                'role': msg.sender.role or 'user',
            },
            'created_at': msg.created_at.isoformat(),
        }

    @database_sync_to_async
    def _push_to_recipients(self, payload):
        from .models import Conversation
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        try:
            conv = Conversation.objects.prefetch_related('participants').get(id=self.conversation_id)
            for participant in conv.participants.exclude(user_id=self.profile.user_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{participant.user_id}',
                    {'type': 'event_message', 'data': {'type': 'new_message', **payload}},
                )
        except Exception:
            pass

    @database_sync_to_async
    def _push_call_signal_to_recipients(self, payload):
        from .models import Conversation
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        try:
            conv = Conversation.objects.prefetch_related('participants').get(id=self.conversation_id)
            for participant in conv.participants.exclude(user_id=self.profile.user_id):
                async_to_sync(channel_layer.group_send)(
                    f'user_{participant.user_id}',
                    {'type': 'event_notification', 'data': {'type': 'incoming_call', **payload}},
                )
        except Exception:
            pass

    @database_sync_to_async
    def _mark_read(self, message_id=None):
        from .models import Conversation, Message
        conv = Conversation.objects.get(id=self.conversation_id)
        qs = Message.objects.filter(conversation=conv).exclude(sender=self.profile)
        if message_id:
            qs = qs.filter(id=message_id)
        return qs.update(is_read=True)

    @database_sync_to_async
    def _toggle_reaction(self, message_id, emoji):
        from .models import Message, MessageReaction
        from collections import Counter
        try:
            msg = Message.objects.get(id=message_id, conversation_id=self.conversation_id)
            obj, created = MessageReaction.objects.get_or_create(
                message=msg, user=self.profile, emoji=emoji[:10]
            )
            if not created:
                obj.delete()
            return dict(Counter(msg.reactions.values_list('emoji', flat=True)))
        except Exception:
            return {}


# ─── Live stream consumer ────────────────────────────────────────────────────

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
        if not await database_sync_to_async(self._may_connect)():
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

        viewer_count = await _viewer_add(self.live_id, self.user_id)
        await self.channel_layer.group_send(self.group_name, {
            'type': 'live_viewer_count',
            'data': {'type': 'live_viewer_count', 'count': viewer_count},
        })
        await database_sync_to_async(self._update_viewer_peak)(viewer_count)
        await self.send_json({
            'type': 'connected',
            'data': {'user_id': self.user_id, 'live_id': self.live_id, 'viewer_count': viewer_count},
        })

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)
        if hasattr(self, 'user_id'):
            viewer_count = await _viewer_remove(self.live_id, self.user_id)
            await self.channel_layer.group_send(self.group_name, {
                'type': 'live_viewer_count',
                'data': {'type': 'live_viewer_count', 'count': viewer_count},
            })
            await database_sync_to_async(self._mark_attendee_left)()

    def _mark_attendee_left(self):
        try:
            from apps.lives.models import LiveAttendee
            LiveAttendee.objects.filter(
                live_id=self.live_id, user=self.profile, left_at__isnull=True,
            ).update(left_at=timezone.now())
        except Exception:
            pass

    def _may_connect(self):
        try:
            live = BuddyLive.objects.prefetch_related('co_hosts', 'attendees').get(id=self.live_id)
        except BuddyLive.DoesNotExist:
            return False
        return can_access_live(live, self.profile) and has_live_admission(live, self.profile)

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
        from apps.wallet.utils import platform_cut
        host = await self._get_live_host()
        if not host or host.user_id == self.user_id:
            return None
        ok = await database_sync_to_async(deduct_artifacts)(self.profile, artifact_type, quantity)
        if not ok:
            return None
        cut = await database_sync_to_async(platform_cut)('tip', artifact_type, quantity)
        host_credit = quantity - cut
        if host_credit > 0:
            await database_sync_to_async(credit_artifacts)(host, artifact_type, host_credit)
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
                description=f'Platform fee ({int(platform_cut("tip", artifact_type, 100))}%)',
            )
        try:
            total = cache.hincrby(f'live_gifts:{self.live_id}', artifact_type, quantity)
        except (AttributeError, TypeError):
            total = quantity
        return {
            'tx_id': str(tx.id), 'artifact_type': artifact_type, 'quantity': quantity,
            'sender_id': self.user_id,
            'sender_name': getattr(self.profile, 'display_name', 'Anonymous'), 'total': total,
        }

    async def receive_json(self, content, **kwargs):
        event_type = content.get('type', 'chat')
        if event_type == 'chat':
            chat_data = content.get('data', {})
            enriched = {
                'type': 'live_chat',
                'data': {
                    'type': 'live_chat',
                    'user_id': self.user_id,
                    'display_name': getattr(self.profile, 'display_name', 'Anonymous'),
                    'avatar_url': getattr(self.profile, 'avatar_url', ''),
                    'message': chat_data.get('message', ''),
                    'timestamp': time.time(),
                },
            }
            # Reply-to support: attach the quoted message so UIs can render a reply thread
            reply_to = chat_data.get('reply_to')
            if reply_to and isinstance(reply_to, dict):
                enriched['data']['reply_data'] = {
                    'message': reply_to.get('message', ''),
                    'sender_name': reply_to.get('sender_name', ''),
                    'user_id': reply_to.get('user_id', ''),
                }
            gift = chat_data.get('gift')
            if gift and isinstance(gift, dict):
                gift_result = await self._process_gift(gift.get('artifact_type', ''), gift.get('quantity', 0))
                if gift_result:
                    enriched['data']['gift'] = gift_result
                    enriched['data']['priority'] = True
            await self.channel_layer.group_send(self.group_name, enriched)
        elif event_type == 'reaction':
            await self.channel_layer.group_send(self.group_name, {
                'type': 'live_reaction',
                'data': {
                    'type': 'live_reaction',
                    'user_id': self.user_id,
                    'display_name': getattr(self.profile, 'display_name', 'Anonymous'),
                    'emoji': content.get('data', {}).get('emoji', '🔥'),
                    'timestamp': time.time(),
                },
            })
        elif event_type == 'gift':
            gift_data = content.get('data', {})
            if self.profile and self.live_id:
                gift_result = await self._process_gift(gift_data.get('artifact_type', ''), gift_data.get('quantity', 0))
                if gift_result:
                    try:
                        totals = cache.hgetall(f'live_gifts:{self.live_id}')
                        totals = {k.decode(): int(v) for k, v in totals.items()} if totals else {}
                    except (AttributeError, TypeError):
                        totals = {}
                    await self.channel_layer.group_send(self.group_name, {
                        'type': 'live_gift',
                        'data': {'type': 'live_gift', 'gift': gift_result, 'totals': totals},
                    })
        elif event_type in ('cohost_invite', 'cohost_request', 'cohost_response', 'cohost_removed'):
            # Relay live cohost management events to everyone in the room so the
            # host panel and attendee UI stay in sync in real time.
            data = content.get('data', {})
            data.setdefault('user_id', self.user_id)
            await self.channel_layer.group_send(self.group_name, {
                'type': f'live_{event_type}',
                'data': {'type': f'live_{event_type}', **data},
            })
        else:
            await self.channel_layer.group_send(self.group_name, {
                'type': f'live_{event_type}', 'data': content,
            })

    async def live_chat(self, event): await self.send_json(event)
    async def live_reaction(self, event): await self.send_json(event)
    async def live_viewer_count(self, event): await self.send_json(event)
    async def live_gift(self, event): await self.send_json(event)
    async def live_rep_counter(self, event): await self.send_json(event)
    async def live_cohost_invite(self, event): await self.send_json(event)
    async def live_cohost_request(self, event): await self.send_json(event)
    async def live_cohost_response(self, event): await self.send_json(event)
    async def live_cohost_removed(self, event): await self.send_json(event)


# ─── Gym group chat consumer ─────────────────────────────────────────────────

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
        await self.channel_layer.group_send(self.group_name, {'type': 'gym_message', 'data': content})

    async def gym_message(self, event):
        await self.send_json(event['data'])


# ─── Random drop pool consumer ───────────────────────────────────────────────

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
            'type': f'random_drop_{event_type}', 'data': content,
        })

    async def random_drop_join_pool(self, event): await self.send_json(event['data'])
    async def random_drop_match_found(self, event): await self.send_json(event['data'])
