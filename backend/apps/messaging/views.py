import logging
import mimetypes
import os
import uuid
import ipaddress
import socket
from datetime import timedelta
from pathlib import PurePosixPath
from urllib.parse import unquote, urlparse

from django.shortcuts import get_object_or_404
from django.db import models as db_models, transaction
from django.http import FileResponse, Http404
from django.utils import timezone
from django.core.files.storage import default_storage

from rest_framework import views, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle

from common.utils import validate_file_signature
from .models import (
    Conversation, Message, MessageReaction, CallLog,
    ConversationMembership, CommunityPost, CommunityPostLike, CommunityPostComment,
    CallSession, CallParticipant,
)
from .serializers import (
    ConversationSerializer, MessageSerializer,
    StartConversationInputSerializer, SendMessageInputSerializer,
    MessageReactionSerializer, CallLogSerializer,
    CommunityMemberSerializer, CommunityPostSerializer, CommunityPostCommentSerializer,
)
from apps.profiles.models import BuddyRelationship, Profile

logger = logging.getLogger(__name__)


def _safe_media_url(value) -> str:
    """Normalise a client-supplied media URL: only http(s), no credentials."""
    if not value or not isinstance(value, str):
        return ''
    cleaned = value.strip()
    if not cleaned:
        return ''
    parsed = urlparse(cleaned)
    if parsed.scheme not in ('http', 'https') or not parsed.hostname:
        return ''
    if parsed.username or parsed.password:
        return ''
    return cleaned[:1000]


def _allowed_to_message(requester: Profile, other: Profile) -> bool:
    """Return True if requester can message other."""
    if other.role in ('trainer', 'practitioner') or requester.role in ('trainer', 'practitioner'):
        return True
    return BuddyRelationship.objects.filter(
        (db_models.Q(from_user=requester, to_user=other) |
         db_models.Q(from_user=other, to_user=requester)),
        status='confirmed',
    ).exists()


def _is_public_preview_url(value: str) -> bool:
    """Reject URLs that could make the server request an internal service."""
    from urllib.parse import urlparse

    if len(value) > 2048:
        return False
    parsed = urlparse(value)
    if parsed.scheme not in ('http', 'https') or not parsed.hostname:
        return False
    if parsed.username or parsed.password:
        return False
    try:
        addresses = {
            info[4][0] for info in socket.getaddrinfo(
                parsed.hostname, parsed.port or (443 if parsed.scheme == 'https' else 80),
                type=socket.SOCK_STREAM,
            )
        }
    except (socket.gaierror, ValueError):
        return False
    if not addresses:
        return False
    for address in addresses:
        ip = ipaddress.ip_address(address)
        if (ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_multicast
                or ip.is_reserved or ip.is_unspecified):
            return False
    return True


class _NoRedirectHandler(__import__('urllib.request', fromlist=['HTTPRedirectHandler']).HTTPRedirectHandler):
    """A redirect can turn a safe public URL into an internal request."""
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


class ConversationListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        conversations = Conversation.objects.filter(
            participants=request.user.profile,
        ).prefetch_related('participants').order_by(
            db_models.F('last_message_at').desc(nulls_last=True)
        )
        serializer = ConversationSerializer(conversations, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class StartConversationView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        input_serializer = StartConversationInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        participant_usernames = input_serializer.validated_data['participants']

        participant_map = {}
        for value in participant_usernames:
            profile = Profile.objects.filter(username=value).first()
            if profile is None:
                try:
                    profile = Profile.objects.filter(user_id=value).first()
                except (TypeError, ValueError):
                    profile = None
            if profile is not None:
                participant_map[str(value)] = profile
        if len(participant_map) != len(set(participant_usernames)):
            return Response({
                'success': False, 'data': None,
                'message': 'One or more users not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        participants = [participant_map[value] for value in participant_usernames]
        all_participants = [request.user.profile] + [p for p in participants if p != request.user.profile]

        unauthorized = [
            p for p in all_participants
            if p != request.user.profile and not _allowed_to_message(request.user.profile, p)
        ]
        if unauthorized:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only add confirmed buddies or professionals to a conversation.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if len(all_participants) == 2:
            other = all_participants[1]
            if not _allowed_to_message(request.user.profile, other):
                return Response({
                    'success': False, 'data': None,
                    'message': 'You must be buddies or interacting with a professional to message.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_403_FORBIDDEN)

            # Return existing 1-to-1 conversation if present
            existing = (
                Conversation.objects
                .filter(is_group=False, participants=all_participants[0])
                .filter(participants=all_participants[1])
                .annotate(pc=db_models.Count('participants'))
                .filter(pc=2)
                .first()
            )
            if existing:
                return Response({
                    'success': True,
                    'data': ConversationSerializer(existing, context={'request': request}).data,
                    'message': 'Conversation already exists.',
                    'errors': None, 'pagination': None,
                })

        conv = Conversation.objects.create(
            is_group=len(all_participants) > 2,
            group_name=input_serializer.validated_data.get('group_name', ''),
            created_by=request.user.profile,
        )
        conv.participants.set(all_participants)

        return Response({
            'success': True,
            'data': ConversationSerializer(conv, context={'request': request}).data,
            'message': 'Conversation started.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ConversationDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        Message.objects.filter(conversation=conv).exclude(sender=request.user.profile).update(is_read=True)
        serializer = ConversationSerializer(conv, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class MessageListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        before = request.query_params.get('before')
        attachment_type = request.query_params.get('attachment_type', '')
        messages = conv.messages.filter(is_deleted=False).select_related(
            'sender', 'reply_to__sender',
        ).prefetch_related('reactions')
        if before:
            messages = messages.filter(created_at__lt=before)
        if attachment_type:
            type_map = {
                'photo': 'photo',
                'video': 'video',
                'audio': 'voice',
                'document': 'document',
                'link': 'text',
                'location': 'location',
                'poll': 'poll',
                'event': 'event',
            }
            mapped = type_map.get(attachment_type)
            if mapped == 'text':
                messages = messages.filter(message_type='text', media_url='', body__regex=r'https?://')
            elif mapped:
                messages = messages.filter(message_type=mapped)
        messages = [
            message for message in messages.order_by('-created_at')
            if str(request.user.profile.user_id) not in (message.deleted_for or [])
        ][:50]

        serializer = MessageSerializer(
            list(reversed(list(messages))), many=True, context={'request': request}
        )
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        input_serializer = SendMessageInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        data = input_serializer.validated_data

        reply_to_id = data.get('reply_to_id')
        if reply_to_id and not Message.objects.filter(id=reply_to_id, conversation=conv).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'A reply must reference a message in this conversation.',
                'errors': {'reply_to_id': ['Invalid reply target.']}, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        msg = Message.objects.create(
            conversation=conv,
            sender=request.user.profile,
            message_type=data.get('message_type', 'text'),
            body=data.get('body', ''),
            media_url=data.get('media_url', ''),
            media_mime=data.get('media_mime', ''),
            file_name=data.get('file_name', ''),
            reply_to_id=reply_to_id,
            metadata=data.get('metadata', {}),
        )
        conv.last_message_text = msg.body[:200] if msg.body else msg.message_type
        conv.last_message_at = timezone.now()
        conv.save(update_fields=['last_message_text', 'last_message_at'])

        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()

        serializer = MessageSerializer(msg, context={'request': request})
        payload = serializer.data

        # Push to conversation group and each participant's user channel
        async_to_sync(channel_layer.group_send)(
            f'conversation_{conversation_id}',
            {'type': 'chat_message', 'data': payload},
        )
        for participant in conv.participants.exclude(user_id=request.user.profile.user_id):
            async_to_sync(channel_layer.group_send)(
                f'user_{participant.user_id}',
                {'type': 'event_message', 'data': {'type': 'new_message', **payload}},
            )

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Message sent.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class DeleteMessageView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, message_id):
        msg = get_object_or_404(Message, id=message_id)
        get_object_or_404(Conversation, id=msg.conversation_id, participants=request.user.profile)
        user_id = str(request.user.profile.user_id)
        delete_for_everyone = request.data.get('for_everyone', False)

        if delete_for_everyone and str(msg.sender.user_id) == user_id:
            msg.soft_delete()
        else:
            if user_id not in msg.deleted_for:
                msg.deleted_for.append(user_id)
                msg.save(update_fields=['deleted_for'])

        return Response({
            'success': True, 'data': None,
            'message': 'Message deleted.',
            'errors': None, 'pagination': None,
        })


class UploadAttachmentView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    throttle_scope = 'upload_attachment'
    throttle_classes = [ScopedRateThrottle]

    ALLOWED_EXTENSIONS = {
        '.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic',
        '.mp4', '.mov', '.webm',
        '.mp3', '.ogg', '.m4a', '.wav',
        '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt',
    }
    MAX_SIZE_MB = 50

    def post(self, request):
        file = request.FILES.get('file')
        if not file:
            logger.warning('UploadAttachmentView: no file provided')
            return Response({
                'success': False, 'data': None,
                'message': 'No file provided.',
                'errors': 'file field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if file.size > self.MAX_SIZE_MB * 1024 * 1024:
            logger.warning('UploadAttachmentView: file too large (%s bytes > %s MB)', file.size, self.MAX_SIZE_MB)
            return Response({
                'success': False, 'data': None,
                'message': f'File exceeds {self.MAX_SIZE_MB} MB limit.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ext = os.path.splitext(file.name)[1].lower()
        if ext not in self.ALLOWED_EXTENSIONS:
            logger.warning('UploadAttachmentView: extension %s not allowed for file %s', ext, file.name)
            return Response({
                'success': False, 'data': None,
                'message': 'File type not allowed.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        # ── Magic byte validation ────────────────────────────────────────
        chunk = file.read(512)
        file.seek(0)
        if ext in ('.jpg', '.jpeg', '.png', '.gif', '.webp', '.mp4', '.mov', '.webm',
                    '.mp3', '.ogg', '.m4a', '.wav', '.pdf'):
            if not validate_file_signature(chunk, ext):
                logger.warning('UploadAttachmentView: magic bytes mismatch for file %s (ext=%s, chunk[:8]=%s)',
                               file.name, ext, chunk[:8].hex())
                return Response({
                    'success': False, 'data': None,
                    'message': 'File content does not match its extension.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        # ── MIME type enforcement ────────────────────────────────────────
        declared_mime = file.content_type or ''
        if declared_mime:
            allowed_prefixes = ('image/', 'video/', 'audio/', 'application/', 'text/')
            if not declared_mime.startswith(allowed_prefixes):
                logger.warning('UploadAttachmentView: MIME %s not allowed for file %s', declared_mime, file.name)
                return Response({
                    'success': False, 'data': None,
                    'message': 'Declared MIME type not allowed.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        # ── Stream to storage (avoid full read into memory) ──────────────
        filename = f'messaging/{uuid.uuid4().hex}{ext}'
        saved_name = default_storage.save(filename, file)
        url = default_storage.url(saved_name)

        return Response({
            'success': True,
            'data': {
                'url': url,
                'mime': declared_mime or '',
                'file_name': file.name,
                'size': file.size,
            },
            'message': 'Uploaded.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ServeMessageFileView(views.APIView):
    """
    Authenticated file proxy for message attachments.
    Serves files with security headers instead of exposing raw storage URLs.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, message_id):
        msg = get_object_or_404(Message, id=message_id)
        get_object_or_404(Conversation, id=msg.conversation_id, participants=request.user.profile)

        if not msg.media_url:
            raise Http404('No attachment on this message.')

        # Only proxy attachments that were placed in our messaging storage.
        # Never turn an arbitrary URL saved in a message into a filesystem path.
        storage_base_path = urlparse(default_storage.url('')).path.rstrip('/') + '/'
        media_path = urlparse(msg.media_url).path
        if not media_path.startswith(storage_base_path):
            raise Http404('Attachment is not available through the secure proxy.')
        relative_path = unquote(media_path[len(storage_base_path):]).lstrip('/')
        path_parts = PurePosixPath(relative_path)
        if (not relative_path.startswith('messaging/') or '..' in path_parts.parts
                or path_parts.is_absolute()):
            raise Http404('Invalid attachment path.')

        try:
            attachment = default_storage.open(relative_path, 'rb')
        except (FileNotFoundError, OSError):
            raise Http404('File not found.')

        guessed_type, _ = mimetypes.guess_type(relative_path)
        content_type = guessed_type or 'application/octet-stream'
        response = FileResponse(attachment, content_type=content_type)
        # Office documents and unknown types must download rather than render.
        if content_type.startswith(('image/', 'video/', 'audio/')) or content_type == 'application/pdf':
            response['Content-Disposition'] = 'inline'
        else:
            response['Content-Disposition'] = 'attachment'
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-Frame-Options'] = 'DENY'
        response['Content-Security-Policy'] = "default-src 'none'; media-src 'self'; img-src 'self'"
        response['Cache-Control'] = 'private, max-age=3600'
        return response


class MessageReactionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        msg = get_object_or_404(Message, id=message_id)
        get_object_or_404(Conversation, id=msg.conversation_id, participants=request.user.profile)
        input_serializer = MessageReactionSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        emoji = input_serializer.validated_data['emoji']
        obj, created = MessageReaction.objects.get_or_create(
            message=msg, user=request.user.profile, emoji=emoji[:10],
        )
        if not created:
            obj.delete()

        from collections import Counter
        reactions = dict(Counter(msg.reactions.values_list('emoji', flat=True)))
        return Response({
            'success': True, 'data': {'reactions': reactions},
            'message': 'Reaction toggled.',
            'errors': None, 'pagination': None,
        })


class MarkReadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        count = Message.objects.filter(
            conversation=conv,
        ).exclude(sender=request.user.profile).update(is_read=True)
        return Response({
            'success': True,
            'data': {'marked_read': count},
            'message': 'Messages marked as read.',
            'errors': None, 'pagination': None,
        })


class CallLogView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        logs = conv.call_logs.select_related('caller', 'callee').order_by('-created_at')[:20]
        serializer = CallLogSerializer(logs, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        callee_id = request.data.get('callee_id')
        callee = get_object_or_404(Profile, user_id=callee_id)
        if callee == request.user.profile or not conv.participants.filter(id=callee.id).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'The callee must be another participant in this conversation.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        call_type = request.data.get('call_type', 'audio')
        call_status = request.data.get('status', 'initiated')
        duration = request.data.get('duration_seconds', 0)

        log = CallLog.objects.create(
            conversation=conv,
            caller=request.user.profile,
            callee=callee,
            call_type=call_type,
            status=call_status,
            duration_seconds=int(duration),
            ended_at=timezone.now() if call_status in ('ended', 'missed', 'declined') else None,
        )
        serializer = CallLogSerializer(log)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'Call log saved.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ConversationCallSessionView(views.APIView):
    """Secure multi-party LiveKit calls for a conversation.

    POST   – start or join the conversation's live call; returns short-lived
             LiveKit credentials scoped to this room and membership-verified.
    GET    – fetch the current live session + fresh credentials (rejoin/refresh).
    DELETE – leave the call; ends the session when the last participant leaves.
    """
    permission_classes = [permissions.IsAuthenticated]

    MAX_SESSION_AGE = timedelta(hours=6)

    def _active_session(self, conv):
        cutoff = timezone.now() - self.MAX_SESSION_AGE
        return (
            CallSession.objects
            .filter(conversation=conv, status__in=('ringing', 'active'), created_at__gte=cutoff)
            .select_related('initiated_by')
            .first()
        )

    @staticmethod
    def _notify_members(conv, payload, exclude_user_id=None):
        """Push a call event to every member's personal user channel."""
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        try:
            layer = get_channel_layer()
            recipients = conv.participants.all()
            if exclude_user_id:
                recipients = recipients.exclude(user_id=exclude_user_id)
            for participant in recipients:
                async_to_sync(layer.group_send)(
                    f'user_{participant.user_id}',
                    {'type': 'event_notification', 'data': payload},
                )
        except Exception:  # noqa: BLE001
            logger.exception('call notify failed for conversation=%s', conv.id)

    def _credentials(self, profile, session, conv):
        from apps.lives.provider_service import generate_livekit_token, get_livekit_url
        token = generate_livekit_token(
            session.room_name,
            identity=str(profile.user_id),
            display_name=profile.display_name,
            avatar_url=getattr(profile, 'avatar_url', '') or '',
            can_publish=True,
            token_expire_sec=600,
        )
        participants = (
            session.participants.filter(left_at__isnull=True)
            .select_related('profile')
        )
        return {
            'session_id': str(session.id),
            'status': session.status,
            'call_type': session.call_type,
            'livekit': {
                'url': get_livekit_url(),
                'room': session.room_name,
                'token': token,
                'identity': str(profile.user_id),
            },
            'participants': [
                {
                    'user_id': str(p.profile.user_id),
                    'display_name': p.profile.display_name,
                    'username': p.profile.username,
                    'avatar_url': p.profile.avatar_url or '',
                    'joined_at': p.joined_at.isoformat() if p.joined_at else None,
                }
                for p in participants
            ],
            'conversation': {
                'id': str(conv.id),
                'is_group': conv.is_group,
                'is_community': conv.is_community,
                'group_name': conv.group_name,
                'group_avatar_url': conv.group_avatar_url,
            },
        }

    def post(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        requested_type = request.data.get('call_type')
        call_type = requested_type if requested_type in ('audio', 'video') else 'audio'

        session = self._active_session(conv)
        is_new = session is None
        if is_new:
            session = CallSession.objects.create(
                conversation=conv,
                initiated_by=request.user.profile,
                call_type=call_type,
                status='ringing',
                room_name=f'convo_{conv.id}',
            )
            conv.call_in_progress = True
            conv.save(update_fields=['call_in_progress'])

        participant, created = CallParticipant.objects.get_or_create(
            session=session, profile=request.user.profile,
        )
        if created or participant.joined_at is None:
            participant.joined_at = timezone.now()
            participant.left_at = None
            participant.declined = False
            participant.save(update_fields=['joined_at', 'left_at', 'declined'])

        # A second active participant promotes ringing → active.
        active_count = session.participants.filter(left_at__isnull=True).count()
        if session.status == 'ringing' and active_count >= 2:
            session.status = 'active'
            session.started_at = session.started_at or timezone.now()
            session.save(update_fields=['status', 'started_at'])

        data = self._credentials(request.user.profile, session, conv)
        data['created'] = is_new

        # Ring everyone else (new session) or announce the join.
        self._notify_members(conv, {
            'type': 'incoming_call' if is_new else 'call_participant_joined',
            'session_id': str(session.id),
            'conversation_id': str(conv.id),
            'call_type': session.call_type,
            'from_user_id': str(request.user.profile.user_id),
            'from_username': request.user.profile.username,
            'from_display_name': request.user.profile.display_name,
            'from_avatar_url': getattr(request.user.profile, 'avatar_url', '') or '',
            'participant_count': active_count,
        }, exclude_user_id=request.user.profile.user_id)

        return Response({'success': True, 'data': data, 'message': 'Joined call.',
                         'errors': None, 'pagination': None})

    def get(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        session = self._active_session(conv)
        if not session:
            return Response({
                'success': True, 'data': None, 'message': 'No live call.',
                'errors': None, 'pagination': None,
            })
        return Response({
            'success': True,
            'data': self._credentials(request.user.profile, session, conv),
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    @transaction.atomic
    def delete(self, request, conversation_id):
        conv = get_object_or_404(Conversation, id=conversation_id, participants=request.user.profile)
        session = self._active_session(conv)
        if not session:
            return Response({'success': True, 'data': None, 'message': 'No live call.',
                             'errors': None, 'pagination': None})
        now = timezone.now()
        CallParticipant.objects.filter(session=session, profile=request.user.profile).update(left_at=now)

        remaining = session.participants.filter(left_at__isnull=True).count()
        ended = remaining == 0
        if ended:
            session.status = 'ended'
            session.ended_at = now
            session.save(update_fields=['status', 'ended_at'])
            conv.call_in_progress = False
            conv.save(update_fields=['call_in_progress'])
            # Summary row so call history keeps working for DMs and groups alike.
            initiator_id = session.initiated_by_id
            CallLog.objects.create(
                conversation=conv,
                caller=session.initiated_by or request.user.profile,
                callee=(session.participants.exclude(profile_id=initiator_id)
                        .select_related('profile').first().profile
                        if session.participants.exclude(profile_id=initiator_id).exists()
                        else request.user.profile),
                call_type=session.call_type,
                status='answered' if session.started_at else ('missed' if not session.participants.exclude(profile_id=initiator_id).exists() else 'ended'),
                duration_seconds=session.duration_seconds,
                ended_at=now,
            )
        self._notify_members(conv, {
            'type': 'call_ended' if ended else 'call_participant_left',
            'session_id': str(session.id),
            'conversation_id': str(conv.id),
            'from_user_id': str(request.user.profile.user_id),
            'participant_count': remaining,
        })
        return Response({'success': True, 'data': {'ended': ended}, 'message': 'Left call.',
                         'errors': None, 'pagination': None})


class LinkPreviewView(views.APIView):
    """Fetch Open Graph metadata for a URL to generate link previews."""
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'link_preview'
    throttle_classes = [ScopedRateThrottle]

    def post(self, request):
        url = request.data.get('url', '').strip()
        if not url:
            return Response({'success': False, 'message': 'URL required.'}, status=400)
        if not _is_public_preview_url(url):
            return Response({
                'success': False, 'data': None,
                'message': 'Only public HTTP(S) links can be previewed.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        import urllib.request
        import urllib.parse
        import urllib.error
        import re as re_module

        preview = {'url': url, 'title': '', 'description': '', 'image': '', 'domain': ''}
        try:
            parsed = urllib.parse.urlparse(url)
            preview['domain'] = parsed.netloc or parsed.hostname or url

            req = urllib.request.Request(url, headers={
                'User-Agent': 'BuddyUp/1.0 (+https://buddyup.app)',
                'Accept': 'text/html,application/xhtml+xml',
            })
            opener = urllib.request.build_opener(_NoRedirectHandler())
            with opener.open(req, timeout=5) as resp:
                content_type = (resp.headers.get_content_type() or '').lower()
                content_length = resp.headers.get('Content-Length')
                if content_type not in ('text/html', 'application/xhtml+xml'):
                    raise ValueError('Preview response is not HTML')
                if content_length and int(content_length) > 128 * 1024:
                    raise ValueError('Preview response is too large')
                html = resp.read(128 * 1024).decode('utf-8', errors='ignore')

            og_title = re_module.search(r'<meta\s+[^>]*property=["\']og:title["\'][^>]*content=["\']([^"\']+)["\']', html, re_module.I)
            og_desc = re_module.search(r'<meta\s+[^>]*property=["\']og:description["\'][^>]*content=["\']([^"\']+)["\']', html, re_module.I)
            og_img = re_module.search(r'<meta\s+[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']+)["\']', html, re_module.I)
            html_title = re_module.search(r'<title>([^<]+)</title>', html, re_module.I)

            if og_title:
                preview['title'] = og_title.group(1)
            elif html_title:
                preview['title'] = html_title.group(1)
            else:
                preview['title'] = preview['domain']

            if og_desc:
                preview['description'] = og_desc.group(1)[:300]
            if og_img:
                preview['image'] = og_img.group(1)
        except Exception:  # noqa: BLE001
            preview['title'] = url

        return Response({
            'success': True, 'data': preview, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ForwardMessageView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        original = get_object_or_404(Message, id=message_id, is_deleted=False)
        get_object_or_404(Conversation, id=original.conversation_id, participants=request.user.profile)

        target_conversation_id = request.data.get('conversation_id')
        if not target_conversation_id:
            return Response({'success': False, 'message': 'target conversation_id required.'}, status=400)
        target_conv = get_object_or_404(
            Conversation, id=target_conversation_id, participants=request.user.profile
        )

        msg = Message.objects.create(
            conversation=target_conv,
            sender=request.user.profile,
            message_type=original.message_type,
            body=original.body,
            media_url=original.media_url,
            media_mime=original.media_mime,
            file_name=original.file_name,
            metadata={
                **(original.metadata or {}),
                'forwarded_from': {
                    'message_id': str(original.id),
                    'sender_name': original.sender.display_name,
                    'conversation_id': str(original.conversation_id),
                },
            },
        )
        target_conv.last_message_text = msg.body[:200] or msg.message_type
        target_conv.last_message_at = timezone.now()
        target_conv.save(update_fields=['last_message_text', 'last_message_at'])

        serializer = MessageSerializer(msg, context={'request': request})
        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            f'conversation_{target_conversation_id}',
            {'type': 'chat_message', 'data': serializer.data},
        )
        for participant in target_conv.participants.exclude(user_id=request.user.profile.user_id):
            async_to_sync(channel_layer.group_send)(
                f'user_{participant.user_id}',
                {'type': 'event_message', 'data': {'type': 'new_message', **serializer.data}},
            )

        return Response({
            'success': True, 'data': serializer.data, 'message': 'Message forwarded.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CreateGroupConversationView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        participant_ids = request.data.get('participant_ids', [])
        group_name = request.data.get('group_name', 'New Group')
        
        if not participant_ids:
            return Response({'success': False, 'message': 'Participants required.'}, status=400)
            
        profiles = list(Profile.objects.filter(user_id__in=participant_ids))
        unauthorized = [
            profile for profile in profiles
            if profile != request.user.profile and not _allowed_to_message(request.user.profile, profile)
        ]
        if unauthorized:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only add confirmed buddies or professionals to a group.',
            }, status=status.HTTP_403_FORBIDDEN)
        if request.user.profile not in profiles:
            profiles.append(request.user.profile)
            
        conv = Conversation.objects.create(
            is_group=True,
            group_name=group_name,
            created_by=request.user.profile,
            last_message_at=timezone.now(),
        )
        conv.participants.set(profiles)
        
        serializer = ConversationSerializer(conv, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'Group created.',
        }, status=201)


def _community_roles() -> set:
    return {'owner', 'admin', 'member'}


def _get_membership(conv: Conversation, profile: Profile):
    return ConversationMembership.objects.filter(conversation=conv, profile=profile).first()


def _is_community_manager(membership) -> bool:
    return membership is not None and membership.role in ('owner', 'admin')


def _notify_community_members(conv, payload):
    """Fan out an event to every community participant's user channel."""
    from asgiref.sync import async_to_sync
    from channels.layers import get_channel_layer
    channel_layer = get_channel_layer()
    for participant in conv.participants.all():
        async_to_sync(channel_layer.group_send)(
            f'user_{participant.user_id}',
            {'type': 'event_message', 'data': payload},
        )


def _push_community_notification(recipient_id, notification_type, title, body='', metadata=None):
    from apps.notifications.tasks import create_notification
    create_notification.delay(
        str(recipient_id), notification_type, title, body, metadata or {}
    )


class CommunityListView(views.APIView):
    """List communities I'm in + discoverable public communities; create a community."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        mine = Conversation.objects.filter(
            is_community=True, participants=profile,
        ).order_by('-last_message_at')
        discoverable = Conversation.objects.filter(
            is_community=True, is_public=True,
        ).exclude(participants=profile).order_by('-created_at')

        my_data = ConversationSerializer(mine, many=True, context={'request': request}).data
        discover_data = ConversationSerializer(discoverable, many=True, context={'request': request}).data
        return Response({
            'success': True, 'data': {'mine': my_data, 'discover': discover_data},
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request):
        name = (request.data.get('name') or '').strip()
        description = (request.data.get('description') or '').strip()
        cover_url = _safe_media_url(request.data.get('cover_url'))
        group_avatar_url = _safe_media_url(request.data.get('group_avatar_url'))
        group_gym_id = request.data.get('group_gym_id') or request.data.get('gym_id')
        is_public = bool(request.data.get('is_public'))

        if not name:
            return Response({
                'success': False, 'data': None,
                'message': 'A community name is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        gym = None
        if group_gym_id:
            from apps.gyms.models import Gym
            gym = Gym.objects.filter(id=group_gym_id).first()

        from .models import _generate_invite_code
        conv = Conversation.objects.create(
            is_group=True,
            is_community=True,
            group_name=name[:100],
            description=description,
            cover_url=cover_url,
            group_avatar_url=group_avatar_url,
            group_gym=gym,
            is_public=is_public,
            invite_code=_generate_invite_code(),
            created_by=request.user.profile,
            last_message_at=timezone.now(),
        )
        conv.participants.add(request.user.profile)
        ConversationMembership.objects.create(
            conversation=conv, profile=request.user.profile, role='owner',
        )

        return Response({
            'success': True,
            'data': ConversationSerializer(conv, context={'request': request}).data,
            'message': 'Community created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommunityDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get_community(self, request, community_id):
        return get_object_or_404(Conversation, id=community_id, is_community=True)

    def get(self, request, community_id):
        conv = self._get_community(request, community_id)
        membership = _get_membership(conv, request.user.profile)
        if not membership and not conv.is_public:
            return Response({
                'success': False, 'data': None,
                'message': 'You are not a member of this community.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        members = conv.memberships.select_related('profile').order_by(
            db_models.Case(
                db_models.When(role='owner', then=0),
                db_models.When(role='admin', then=1),
                default=2,
            ), 'created_at',
        )
        data = ConversationSerializer(conv, context={'request': request}).data
        data['members'] = CommunityMemberSerializer(members, many=True).data
        data['member_count'] = members.count()
        data['my_role'] = membership.role if membership else None
        return Response({
            'success': True, 'data': data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def patch(self, request, community_id):
        conv = self._get_community(request, community_id)
        membership = _get_membership(conv, request.user.profile)
        if not _is_community_manager(membership):
            return Response({
                'success': False, 'data': None,
                'message': 'Only admins can update community settings.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if 'name' in request.data:
            name = (request.data.get('name') or '').strip()
            if not name:
                return Response({'success': False, 'message': 'Name required.'}, status=400)
            conv.group_name = name[:100]
        if 'description' in request.data:
            conv.description = (request.data.get('description') or '').strip()
        if 'cover_url' in request.data:
            conv.cover_url = _safe_media_url(request.data.get('cover_url'))
        if 'is_public' in request.data:
            conv.is_public = bool(request.data.get('is_public'))
        if 'group_gym_id' in request.data:
            from apps.gyms.models import Gym
            gym_id = request.data.get('group_gym_id')
            conv.group_gym = Gym.objects.filter(id=gym_id).first() if gym_id else None
        if 'group_avatar_url' in request.data:
            conv.group_avatar_url = _safe_media_url(request.data.get('group_avatar_url'))
        conv.save()

        return Response({
            'success': True,
            'data': ConversationSerializer(conv, context={'request': request}).data,
            'message': 'Community updated.',
            'errors': None, 'pagination': None,
        })


class CommunityJoinView(views.APIView):
    """Join a community by invite code or via a public community's id."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        profile = request.user.profile

        invite_code = (request.data.get('invite_code') or '').strip().upper()
        if not conv.is_public and conv.invite_code != invite_code:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or missing invite code.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        existing = _get_membership(conv, profile)
        if existing:
            return Response({
                'success': True,
                'data': ConversationSerializer(conv, context={'request': request}).data,
                'message': 'Already a member.',
                'errors': None, 'pagination': None,
            })

        conv.participants.add(profile)
        ConversationMembership.objects.create(conversation=conv, profile=profile, role='member')

        _notify_community_members(conv, {
            'type': 'community_member_joined',
            'community_id': str(conv.id),
            'community_name': conv.group_name,
            'user_id': str(profile.user_id),
            'display_name': profile.display_name,
        })
        return Response({
            'success': True,
            'data': ConversationSerializer(conv, context={'request': request}).data,
            'message': 'Joined the community.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommunityJoinByCodeView(views.APIView):
    """Join a community using just its invite code."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        invite_code = (request.data.get('invite_code') or '').strip().upper()
        if not invite_code:
            return Response({'success': False, 'message': 'Invite code required.'}, status=400)
        conv = Conversation.objects.filter(is_community=True, invite_code=invite_code).first()
        if not conv:
            return Response({
                'success': False, 'data': None,
                'message': 'No community found for that invite code.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)
        return CommunityJoinView().post(request, str(conv.id))


class CommunityLeaveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        profile = request.user.profile
        membership = _get_membership(conv, profile)

        if not membership:
            return Response({'success': False, 'message': 'Not a member.'}, status=400)

        if membership.role == 'owner':
            other_owners = conv.memberships.filter(role='owner').exclude(id=membership.id).exists()
            if not other_owners and conv.memberships.count() > 1:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Transfer ownership before leaving.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        membership.delete()
        conv.participants.remove(profile)
        _notify_community_members(conv, {
            'type': 'community_member_left',
            'community_id': str(conv.id),
            'user_id': str(profile.user_id),
        })
        return Response({
            'success': True, 'data': None, 'message': 'Left the community.',
            'errors': None, 'pagination': None,
        })


class CommunityMemberManagementView(views.APIView):
    """Add/remove members and manage roles (manager permission)."""
    permission_classes = [permissions.IsAuthenticated]

    def _conv(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not _is_community_manager(membership):
            return conv, None
        return conv, membership

    def post(self, request, community_id):
        conv, my_membership = self._conv(request, community_id)
        if my_membership is None:
            return Response({'success': False, 'message': 'Admins only.'}, status=403)

        user_ids = request.data.get('user_ids', [])
        if not isinstance(user_ids, list) or not user_ids:
            return Response({'success': False, 'message': 'user_ids required.'}, status=400)

        profiles = list(Profile.objects.filter(user_id__in=user_ids))
        if len(profiles) != len(set(user_ids)):
            return Response({'success': False, 'message': 'Some users not found.'}, status=400)

        added = []
        for profile in profiles:
            if profile.user_id == request.user.profile.user_id or conv.participants.filter(user_id=profile.user_id).exists():
                continue
            conv.participants.add(profile)
            ConversationMembership.objects.create(conversation=conv, profile=profile, role='member')
            added.append(str(profile.user_id))
            _push_community_notification(
                profile.user_id, 'community_invite',
                f'You were added to {conv.group_name}',
                f'{request.user.profile.display_name} added you to a community.',
                {'community_id': str(conv.id), 'community_name': conv.group_name},
            )

        return Response({
            'success': True,
            'data': {'added_user_ids': added},
            'message': 'Members added.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)

    def delete(self, request, community_id, user_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        my_membership = _get_membership(conv, request.user.profile)
        if not _is_community_manager(my_membership):
            return Response({'success': False, 'message': 'Admins only.'}, status=403)

        target_profile = get_object_or_404(Profile, user_id=user_id)
        target_membership = _get_membership(conv, target_profile)
        if not target_membership:
            return Response({'success': False, 'message': 'Not a member.'}, status=400)
        if target_membership.role == 'owner':
            return Response({'success': False, 'message': 'Cannot remove the owner.'}, status=400)
        if target_membership.role == 'admin' and my_membership.role != 'owner':
            return Response({'success': False, 'message': 'Only the owner can remove admins.'}, status=403)

        target_membership.delete()
        conv.participants.remove(target_profile)
        return Response({
            'success': True, 'data': None, 'message': 'Member removed.',
            'errors': None, 'pagination': None,
        })


class CommunityRoleView(views.APIView):
    """Owner-only: promote/demote a member between admin and member."""
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, community_id, user_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        my_membership = _get_membership(conv, request.user.profile)
        if my_membership is None or my_membership.role != 'owner':
            return Response({'success': False, 'message': 'Owner only.'}, status=403)

        role = request.data.get('role')
        if role not in ('admin', 'member'):
            return Response({'success': False, 'message': 'role must be admin or member.'}, status=400)

        target = get_object_or_404(ConversationMembership, conversation=conv, profile__user_id=user_id)
        if target.role == 'owner':
            return Response({'success': False, 'message': 'Cannot change the owner role.'}, status=400)
        target.role = role
        target.save(update_fields=['role', 'updated_at'])
        return Response({
            'success': True,
            'data': CommunityMemberSerializer(target).data,
            'message': 'Role updated.',
            'errors': None, 'pagination': None,
        })


class CommunityTransferOwnershipView(views.APIView):
    """Owner-only: transfer ownership to another member."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        my_membership = _get_membership(conv, request.user.profile)
        if my_membership is None or my_membership.role != 'owner':
            return Response({'success': False, 'message': 'Owner only.'}, status=403)

        target = get_object_or_404(
            ConversationMembership, conversation=conv, profile__user_id=request.data.get('user_id')
        )
        if target.id == my_membership.id:
            return Response({'success': False, 'message': 'You already own this community.'}, status=400)
        my_membership.role = 'admin'
        my_membership.save(update_fields=['role', 'updated_at'])
        target.role = 'owner'
        target.save(update_fields=['role', 'updated_at'])
        return Response({
            'success': True, 'data': None, 'message': 'Ownership transferred.',
            'errors': None, 'pagination': None,
        })


class CommunityInviteView(views.APIView):
    """Owner/admin: rotate the community invite code."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not _is_community_manager(membership):
            return Response({'success': False, 'message': 'Admins only.'}, status=403)
        from .models import _generate_invite_code
        conv.invite_code = _generate_invite_code()
        conv.save(update_fields=['invite_code', 'updated_at'])
        return Response({
            'success': True, 'data': {'invite_code': conv.invite_code},
            'message': 'Invite code rotated.',
            'errors': None, 'pagination': None,
        })


class CommunityPostListView(views.APIView):
    """Feed of a community's posts; create a post."""
    permission_classes = [permissions.IsAuthenticated]

    def _conv(self, request, community_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not membership and not conv.is_public:
            return conv, None
        return conv, membership

    def get(self, request, community_id):
        conv, membership = self._conv(request, community_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)

        posts = conv.community_posts.select_related('author').prefetch_related('likes')
        author_id = request.query_params.get('author_id')
        if author_id:
            posts = posts.filter(author__user_id=author_id)
        only_pinned = request.query_params.get('pinned') in ('true', '1')
        if only_pinned:
            posts = posts.filter(is_pinned=True)
        posts = posts[:50]

        serializer = CommunityPostSerializer(
            posts, many=True, context={'request': request, 'include_comments': True}
        )
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, community_id):
        conv, membership = self._conv(request, community_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)

        body = (request.data.get('body') or '').strip()
        media_url = (request.data.get('media_url') or '').strip()
        is_pinned = bool(request.data.get('is_pinned'))
        if is_pinned and not _is_community_manager(membership):
            return Response({'success': False, 'message': 'Admins only can pin.'}, status=403)
        if not body and not media_url:
            return Response({'success': False, 'message': 'Body or media required.'}, status=400)

        post = CommunityPost.objects.create(
            conversation=conv,
            author=request.user.profile,
            body=body,
            media_url=media_url,
            media_mime=(request.data.get('media_mime') or '').strip(),
            is_pinned=is_pinned,
        )
        _notify_community_members(conv, {
            'type': 'community_post',
            'community_id': str(conv.id),
            'post_id': str(post.id),
            'author_name': request.user.profile.display_name,
        })
        serializer = CommunityPostSerializer(post, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'Post created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommunityPostDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _post(self, request, community_id, post_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not membership:
            return None, None
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)
        return post, membership

    def get(self, request, community_id, post_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        serializer = CommunityPostSerializer(
            post, context={'request': request, 'include_comments': True}
        )
        return Response({'success': True, 'data': serializer.data, 'message': 'OK',
                         'errors': None, 'pagination': None})

    def patch(self, request, community_id, post_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        is_author = post.author_id == request.user.profile.user_id
        if not is_author and not _is_community_manager(membership):
            return Response({'success': False, 'message': 'Authors or admins only.'}, status=403)

        if 'body' in request.data:
            post.body = (request.data.get('body') or '').strip()
        if 'media_url' in request.data:
            post.media_url = (request.data.get('media_url') or '').strip()
        if 'is_pinned' in request.data and _is_community_manager(membership):
            post.is_pinned = bool(request.data.get('is_pinned'))
        post.save()

        serializer = CommunityPostSerializer(post, context={'request': request})
        return Response({'success': True, 'data': serializer.data, 'message': 'Post updated.',
                         'errors': None, 'pagination': None})

    def delete(self, request, community_id, post_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        is_author = post.author_id == request.user.profile.user_id
        if not is_author and not _is_community_manager(membership):
            return Response({'success': False, 'message': 'Authors or admins only.'}, status=403)
        post.delete()
        return Response({'success': True, 'data': None, 'message': 'Post deleted.',
                         'errors': None, 'pagination': None})


class CommunityPostLikeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, community_id, post_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not membership:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)

        like = CommunityPostLike.objects.filter(post=post, profile=request.user.profile).first()
        if like:
            like.delete()
            post.like_count = max(0, post.like_count - 1)
            post.save(update_fields=['like_count', 'updated_at'])
            liked = False
        else:
            CommunityPostLike.objects.create(post=post, profile=request.user.profile)
            post.like_count += 1
            post.save(update_fields=['like_count', 'updated_at'])
            liked = True
            if post.author_id != request.user.profile.user_id:
                _push_community_notification(
                    post.author.user_id, 'community_reaction',
                    f'{request.user.profile.display_name} reacted to your post',
                    post.body[:100],
                    {'community_id': str(conv.id), 'post_id': str(post.id)},
                )
        return Response({
            'success': True, 'data': {'is_liked': liked, 'like_count': post.like_count},
            'message': 'Like toggled.', 'errors': None, 'pagination': None,
        })


class CommunityPostCommentView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _post(self, request, community_id, post_id):
        conv = get_object_or_404(Conversation, id=community_id, is_community=True)
        membership = _get_membership(conv, request.user.profile)
        if not membership:
            return None, None
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)
        return post, membership

    def get(self, request, community_id, post_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        comments = post.comments.select_related('author').prefetch_related('replies').order_by('created_at')
        serializer = CommunityPostCommentSerializer(comments, many=True)
        return Response({'success': True, 'data': serializer.data, 'message': 'OK',
                         'errors': None, 'pagination': None})

    def post(self, request, community_id, post_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        body = (request.data.get('body') or '').strip()
        if not body:
            return Response({'success': False, 'message': 'Comment body required.'}, status=400)
        reply_to_id = request.data.get('reply_to_id')
        if reply_to_id and not post.comments.filter(id=reply_to_id).exists():
            return Response({'success': False, 'message': 'Invalid reply target.'}, status=400)

        comment = CommunityPostComment.objects.create(
            post=post, author=request.user.profile, body=body,
            reply_to_id=reply_to_id,
        )
        post.comment_count += 1
        post.save(update_fields=['comment_count', 'updated_at'])

        if post.author_id != request.user.profile.user_id:
            _push_community_notification(
                post.author.user_id, 'community_comment',
                f'{request.user.profile.display_name} commented on your post',
                body[:100],
                {'community_id': str(post.conversation_id),
                 'post_id': str(post.id), 'comment_id': str(comment.id)},
            )
        serializer = CommunityPostCommentSerializer(comment)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'Comment added.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)

    def delete(self, request, community_id, post_id, comment_id):
        post, membership = self._post(request, community_id, post_id)
        if membership is None:
            return Response({'success': False, 'message': 'Not a member.'}, status=403)
        comment = get_object_or_404(CommunityPostComment, id=comment_id, post=post)
        is_author = comment.author_id == request.user.profile.user_id
        if not is_author and not _is_community_manager(membership):
            return Response({'success': False, 'message': 'Authors or admins only.'}, status=403)
        comment.delete()
        post.comment_count = max(0, post.comment_count - 1)
        post.save(update_fields=['comment_count', 'updated_at'])
        return Response({'success': True, 'data': None, 'message': 'Comment deleted.',
                         'errors': None, 'pagination': None})
