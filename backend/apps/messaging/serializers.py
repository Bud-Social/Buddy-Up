from rest_framework import serializers
from .models import Conversation, Message, MessageReaction


class MessageSerializer(serializers.ModelSerializer):
    sender_data = serializers.SerializerMethodField()
    reply_data = serializers.SerializerMethodField()
    reactions = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'conversation_id', 'sender_id', 'message_type', 'body',
                   'media_url', 'reply_to_id', 'metadata', 'is_read',
                   'sender_data', 'reply_data', 'reactions', 'created_at']
        read_only_fields = ['id', 'sender_id', 'created_at']

    def get_sender_data(self, obj):
        return {
            'username': obj.sender.username,
            'display_name': obj.sender.display_name,
            'avatar_url': obj.sender.avatar_url,
        }

    def get_reply_data(self, obj):
        if obj.reply_to:
            return {
                'id': str(obj.reply_to.id),
                'body': obj.reply_to.body[:100],
                'sender_name': obj.reply_to.sender.display_name,
            }
        return None

    def get_reactions(self, obj):
        from collections import Counter
        return dict(Counter(obj.reactions.values_list('emoji', flat=True)))


class ConversationSerializer(serializers.ModelSerializer):
    participants_data = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'is_group', 'group_name', 'group_gym_id',
                   'sub_channel', 'participants_data', 'unread_count',
                   'last_message', 'last_message_at', 'created_at']

    def get_participants_data(self, obj):
        return [{
            'username': p.username,
            'display_name': p.display_name,
            'avatar_url': p.avatar_url,
        } for p in obj.participants.all()]

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return 0
        return obj.messages.filter(
            is_read=False,
        ).exclude(sender=request.user.profile).count()

    def get_last_message(self, obj):
        last = obj.messages.last()
        if last:
            return {
                'body': last.body[:100],
                'message_type': last.message_type,
                'sender_name': last.sender.display_name,
            }
        return None
