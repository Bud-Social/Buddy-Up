from rest_framework import serializers
from .models import (
    Conversation, Message, CallLog,
    ConversationMembership, CommunityPost, CommunityPostComment,
)


class StartConversationInputSerializer(serializers.Serializer):
    participants = serializers.ListField(child=serializers.CharField(), allow_empty=False)
    group_name = serializers.CharField(max_length=100, required=False, allow_blank=True)


class SendMessageInputSerializer(serializers.Serializer):
    body = serializers.CharField(max_length=5000, allow_blank=True, default='')
    message_type = serializers.ChoiceField(
        choices=['text', 'photo', 'video', 'voice', 'document', 'location',
                 'poll', 'event',
                 'workout_log', 'meal_plan', 'artifact_tip', 'accountability_ping', 'call_log'],
        default='text',
    )
    media_url = serializers.URLField(required=False, allow_blank=True, max_length=1000)
    media_mime = serializers.CharField(required=False, allow_blank=True, max_length=100)
    file_name = serializers.CharField(required=False, allow_blank=True, max_length=255)
    reply_to_id = serializers.UUIDField(required=False, allow_null=True)
    metadata = serializers.JSONField(required=False, default=dict)


class MessageReactionSerializer(serializers.Serializer):
    emoji = serializers.CharField(max_length=20)


class MessageSerializer(serializers.ModelSerializer):
    sender_data = serializers.SerializerMethodField()
    reply_data = serializers.SerializerMethodField()
    reactions = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id', 'conversation_id', 'sender_id', 'message_type', 'body',
            'media_url', 'media_mime', 'file_name',
            'reply_to_id', 'metadata', 'is_read', 'deleted_for',
            'sender_data', 'reply_data', 'reactions', 'created_at',
        ]
        read_only_fields = ['id', 'sender_id', 'created_at']

    def get_sender_data(self, obj):
        return {
            'username': obj.sender.username,
            'display_name': obj.sender.display_name,
            'avatar_url': obj.sender.avatar_url,
            'verification_status': obj.sender.verification_status,
        }

    def get_reply_data(self, obj):
        if obj.reply_to:
            return {
                'id': str(obj.reply_to.id),
                'body': obj.reply_to.body[:100],
                'sender_name': obj.reply_to.sender.display_name,
                'message_type': obj.reply_to.message_type,
                'media_url': obj.reply_to.media_url,
            }
        return None

    def get_reactions(self, obj):
        from collections import Counter
        return dict(Counter(obj.reactions.values_list('emoji', flat=True)))


class ConversationSerializer(serializers.ModelSerializer):
    participants_data = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    membership_role = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'is_group', 'is_community', 'group_name', 'group_avatar_url',
            'group_gym_id', 'description', 'cover_url', 'invite_code', 'is_public',
            'sub_channel', 'call_in_progress',
            'participants_data', 'unread_count', 'membership_role',
            'last_message', 'last_message_at', 'created_at',
        ]

    def get_participants_data(self, obj):
        return [{
            'user_id': str(p.user_id),
            'username': p.username,
            'display_name': p.display_name,
            'avatar_url': p.avatar_url,
            'verification_status': p.verification_status,
            'role': p.role,
        } for p in obj.participants.all()]

    def get_membership_role(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        m = ConversationMembership.objects.filter(
            conversation=obj, profile=request.user.profile
        ).first()
        return m.role if m else None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return 0
        return obj.messages.filter(is_read=False).exclude(sender=request.user.profile).count()

    def get_last_message(self, obj):
        last = obj.messages.last()
        if last:
            return {
                'body': last.body[:100],
                'message_type': last.message_type,
                'media_url': last.media_url,
                'sender_name': last.sender.display_name,
            }
        return None


class CallLogSerializer(serializers.ModelSerializer):
    caller_data = serializers.SerializerMethodField()
    callee_data = serializers.SerializerMethodField()

    class Meta:
        model = CallLog
        fields = [
            'id', 'conversation_id', 'call_type', 'status',
            'duration_seconds', 'caller_data', 'callee_data',
            'created_at', 'ended_at',
        ]

    def get_caller_data(self, obj):
        return {
            'username': obj.caller.username,
            'display_name': obj.caller.display_name,
            'avatar_url': obj.caller.avatar_url,
        }

    def get_callee_data(self, obj):
        return {
            'username': obj.callee.username,
            'display_name': obj.callee.display_name,
            'avatar_url': obj.callee.avatar_url,
        }


class CommunityMemberSerializer(serializers.ModelSerializer):
    user_id = serializers.CharField(source='profile.user_id')
    username = serializers.CharField(source='profile.username')
    display_name = serializers.CharField(source='profile.display_name')
    avatar_url = serializers.URLField(source='profile.avatar_url')
    verification_status = serializers.CharField(source='profile.verification_status')

    class Meta:
        model = ConversationMembership
        fields = ['user_id', 'username', 'display_name', 'avatar_url',
                  'verification_status', 'role', 'created_at']


class CommunityPostCommentSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    reply_count = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPostComment
        fields = ['id', 'post_id', 'body', 'reply_to_id', 'author_data',
                  'reply_count', 'created_at']

    def get_author_data(self, obj):
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
        }

    def get_reply_count(self, obj):
        return obj.replies.count()


class CommunityPostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPost
        fields = ['id', 'conversation_id', 'author_id', 'body', 'media_url',
                  'media_mime', 'is_pinned', 'like_count', 'comment_count',
                  'author_data', 'is_liked', 'comments', 'created_at']
        read_only_fields = ['id', 'conversation_id', 'author_id', 'like_count',
                            'comment_count', 'created_at']

    def get_author_data(self, obj):
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
            'role': obj.author.role,
        }

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.likes.filter(profile=request.user.profile).exists()

    def get_comments(self, obj):
        include = self.context.get('include_comments', False)
        if not include:
            return None
        qs = obj.comments.select_related('author').prefetch_related('replies')[:20]
        return CommunityPostCommentSerializer(qs, many=True).data
