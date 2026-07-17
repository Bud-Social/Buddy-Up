import os
import uuid

from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from rest_framework import views, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response

from common.pagination import CursorPagination
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
        messages = conv.messages.select_related('sender', 'reply_to__sender').prefetch_related('reactions')
        if before:
            messages = messages.filter(created_at__lt=before)
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

        msg = Message.objects.create(
            conversation=conv,
            sender=request.user.profile,
            message_type=data.get('message_type', 'text'),
            body=data.get('body', ''),
            media_url=data.get('media_url', ''),
            media_mime=data.get('media_mime', ''),
            file_name=data.get('file_name', ''),
            reply_to_id=data.get('reply_to_id'),
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

    ALLOWED_MIME_PREFIXES = ('image/', 'video/', 'audio/')
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
            return Response({
                'success': False, 'data': None,
                'message': 'No file provided.',
                'errors': 'file field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if file.size > self.MAX_SIZE_MB * 1024 * 1024:
            return Response({
                'success': False, 'data': None,
                'message': f'File exceeds {self.MAX_SIZE_MB} MB limit.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ext = os.path.splitext(file.name)[1].lower()
        if ext not in self.ALLOWED_EXTENSIONS:
            return Response({
                'success': False, 'data': None,
                'message': 'File type not allowed.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        filename = f'messaging/{uuid.uuid4().hex}{ext}'
        saved_name = default_storage.save(filename, ContentFile(file.read()))
        url = default_storage.url(saved_name)

        return Response({
            'success': True,
            'data': {
                'url': url,
                'mime': file.content_type or '',
                'file_name': file.name,
                'size': file.size,
            },
            'message': 'Uploaded.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


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


class CreateGroupConversationView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        participant_ids = request.data.get('participant_ids', [])
        group_name = request.data.get('group_name', 'New Group')
        
        if not participant_ids:
            return Response({'success': False, 'message': 'Participants required.'}, status=400)
            
        profiles = list(Profile.objects.filter(user_id__in=participant_ids))
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
