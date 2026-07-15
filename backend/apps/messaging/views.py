from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import Conversation, Message, MessageReaction
from .serializers import ConversationSerializer, MessageSerializer, StartConversationInputSerializer, SendMessageInputSerializer, MessageReactionSerializer
from apps.profiles.models import BuddyRelationship, Profile


class ConversationListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        conversations = Conversation.objects.filter(
            participants=request.user.profile,
        ).prefetch_related('participants').order_by('-last_message_at')

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

        all_participants = [request.user.profile] + participants

        if len(all_participants) == 2:
            other = all_participants[1]
            is_buddy = BuddyRelationship.objects.filter(
                (db_models.Q(from_user=request.user.profile, to_user=other) |
                 db_models.Q(from_user=other, to_user=request.user.profile)),
                status='confirmed',
            ).exists()
            if not is_buddy:
                return Response({
                    'success': False, 'data': None,
                    'message': 'You must be buddies to message.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_403_FORBIDDEN)

            existing = Conversation.objects.filter(
                is_group=False,
                participants__in=all_participants,
            ).annotate(
                pc=db_models.Count('participants')
            ).filter(pc=len(all_participants)).distinct().first()

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

        Message.objects.filter(
            conversation=conv,
        ).exclude(sender=request.user.profile).update(is_read=True)

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

        paginator = CursorPagination()
        page = paginator.paginate_queryset(messages, request)
        serializer = MessageSerializer(page, many=True)

        return Response({
            'success': True, 'data': list(reversed(serializer.data)), 'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
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
            reply_to_id=data.get('reply_to_id'),
            metadata=data.get('metadata', {}),
        )

        conv.last_message_text = msg.body[:200] if msg.body else msg.message_type
        conv.last_message_at = timezone.now()
        conv.save(update_fields=['last_message_text', 'last_message_at'])

        from asgiref.sync import async_to_sync
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()

        serializer = MessageSerializer(msg)
        payload = serializer.data

        for participant in conv.participants.exclude(id=request.user.profile.id):
            async_to_sync(channel_layer.group_send)(
                f'user_{participant.user_id}',
                {'type': 'event_message', 'data': payload},
            )
            async_to_sync(channel_layer.group_send)(
                f'conversation_{conversation_id}',
                {'type': 'chat_message', 'data': payload},
            )

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Message sent.',
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
        MessageReaction.objects.get_or_create(
            message=msg, user=request.user.profile, emoji=emoji[:10],
        )

        return Response({
            'success': True, 'data': None,
            'message': 'Reaction added.',
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
