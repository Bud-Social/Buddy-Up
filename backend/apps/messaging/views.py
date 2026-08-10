import logging
import mimetypes
import os
import uuid
import ipaddress
import socket
from pathlib import PurePosixPath
from urllib.parse import unquote, urlparse

logger = logging.getLogger(__name__)

from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.http import FileResponse, Http404
from django.utils import timezone
from django.core.files.storage import default_storage

from rest_framework import views, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle

from common.pagination import CursorPagination
from common.utils import validate_file_signature, validate_mime_from_bytes
from .models import Conversation, Message, MessageReaction, CallLog
from .serializers import (
    ConversationSerializer, MessageSerializer,
    StartConversationInputSerializer, SendMessageInputSerializer,
    MessageReactionSerializer, CallLogSerializer,
)
from apps.profiles.models import BuddyRelationship, Profile


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

        participants = list(Profile.objects.filter(username__in=participant_usernames))
        if len(participants) != len(participant_usernames):
            return Response({
                'success': False, 'data': None,
                'message': 'One or more users not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

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
        messages = conv.messages.select_related('sender', 'reply_to__sender').prefetch_related('reactions')
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
        messages = messages.order_by('-created_at')[:50]

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
        except Exception:
            preview['title'] = url

        return Response({
            'success': True, 'data': preview, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ForwardMessageView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        original = get_object_or_404(Message, id=message_id)
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
