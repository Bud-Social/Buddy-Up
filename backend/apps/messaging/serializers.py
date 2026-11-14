from rest_framework import serializers
from django.db.models import Count
from .models import (
    Conversation, Message, CallLog,
    ConversationMembership, CommunityPost, CommunityPostComment,
)


class StartConversationInputSerializer(serializers.Serializer):
    participants = serializers.ListField(child=serializers.CharField(), allow_empty=False)
    group_name = serializers.CharField(max_length=100, required=False, allow_blank=True)
    origin = serializers.ChoiceField(
        choices=['direct', 'discovery'], required=False, default='direct',
        help_text="Use 'discovery' for threads opened from the buddy-finder surface.",
    )


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
    view_once = serializers.BooleanField(required=False, default=False)


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
            'view_once', 'view_once_opened_at',
            'sender_data', 'reply_data', 'reactions', 'created_at',
        ]
        read_only_fields = ['id', 'sender_id', 'created_at']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        request = self.context.get('request')
        viewer = getattr(getattr(request, 'user', None), 'profile', None) if request else None
        # A view-once payload is delivered exactly once. After the recipient
        # opens it, the media URL is withheld for everyone but the sender.
        if instance.view_once and instance.view_once_opened_at:
            if viewer is None or viewer.pk != instance.sender.pk:
                data['media_url'] = ''
        return data

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
    member_count = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    membership_role = serializers.SerializerMethodField()
    invite_code = serializers.SerializerMethodField()
    origin = serializers.CharField(read_only=True)
    promoted_at = serializers.DateTimeField(read_only=True)
    promotable = serializers.SerializerMethodField()
    promotion_status = serializers.SerializerMethodField()
    promotion_id = serializers.SerializerMethodField()
    promotion_requested_by = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'is_group', 'is_community', 'group_name', 'group_avatar_url',
            'group_gym_id', 'description', 'cover_url', 'invite_code', 'is_public',
            'sub_channel', 'call_in_progress',
            'origin', 'promoted_at', 'promotable', 'promotion_status', 'promotion_id', 'promotion_requested_by',
            'participants_data', 'member_count', 'unread_count', 'membership_role',
            'last_message', 'last_message_at', 'created_at',
        ]

    def get_member_count(self, obj):
        """Roster size, always exposed — the only member signal non-members get.

        Reads a queryset annotation when the view supplied one so listing
        every community stays a single aggregate query instead of N+1.
        """
        annotated = getattr(obj, 'annotated_member_count', None)
        if annotated is not None:
            return annotated
        return obj.memberships.count()

    def get_participants_data(self, obj):
        """Full participant roster, member-only. Non-members get [] plus member_count."""
        profile = self._viewer()
        if profile is None:
            return []
        is_participant = obj.participants.filter(pk=profile.pk).exists()
        if not is_participant and not ConversationMembership.objects.filter(
            conversation=obj, profile=profile,
        ).exists():
            return []
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

    def get_invite_code(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        if ConversationMembership.objects.filter(
            conversation=obj, profile=request.user.profile,
        ).exists():
            return obj.invite_code
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return 0
        return sum(
            1 for message in obj.messages.filter(is_deleted=False, is_read=False).exclude(
                sender=request.user.profile,
            )
            if str(request.user.profile.user_id) not in (message.deleted_for or [])
        )

    def _viewer(self):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        return getattr(request.user, 'profile', None)

    def _promotion(self, obj):
        try:
            return obj.promotion
        except Exception:
            return None

    def get_promotable(self, obj):
        """True when the viewer may turn this DM into a buddy relationship."""
        profile = self._viewer()
        if profile is None:
            return False
        from .blocking import other_participant
        other = other_participant(obj, profile)
        if other is None:
            return False
        from django.db.models import Q
        from apps.profiles.models import BuddyRelationship
        return not BuddyRelationship.objects.filter(
            Q(from_user=profile, to_user=other) | Q(from_user=other, to_user=profile),
            status='confirmed',
        ).exists()

    def get_promotion_status(self, obj):
        promotion = self._promotion(obj)
        return promotion.status if promotion is not None else None

    def get_promotion_id(self, obj):
        """Expose the pending promotion so the *invited* participant can
        accept or decline it. Only meaningful while a request is pending."""
        promotion = self._promotion(obj)
        return promotion.id if promotion is not None else None

    def get_promotion_requested_by(self, obj):
        """Who asked for the promotion, so a client can show Accept/Decline
        only to the party who was asked."""
        promotion = self._promotion(obj)
        if promotion is None or promotion.requested_by_id is None:
            return None
        return str(promotion.requested_by_id)

    def get_last_message(self, obj):
        request = self.context.get('request')
        hidden_for = None
        if request and request.user.is_authenticated:
            hidden_for = str(request.user.profile.user_id)
        messages = obj.messages.filter(is_deleted=False)
        if hidden_for:
            messages = [m for m in messages if hidden_for not in (m.deleted_for or [])]
            last = messages[-1] if messages else None
        else:
            last = messages.last()
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
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPostComment
        fields = ['id', 'post_id', 'body', 'reply_to_id', 'author_data',
                  'reply_count', 'media_type', 'media_url', 'sticker_pack',
                  'reaction_counts', 'user_reaction', 'created_at']

    def get_author_data(self, obj):
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
        }

    def get_reply_count(self, obj):
        return obj.replies.count()

    def get_reaction_counts(self, obj):
        # Community comments only support a single "like" reaction today.
        count = obj.likes.count()
        return {'❤️': count} if count else {}

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        if obj.likes.filter(profile=request.user.profile).exists():
            return '❤️'
        return None


class CommunityPostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    is_reposted_by_me = serializers.SerializerMethodField()
    reposters = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()
    is_saved_by_me = serializers.SerializerMethodField()
    community_name = serializers.SerializerMethodField()
    community_cover_url = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPost
        fields = [
            'id', 'conversation_id', 'author_id', 'body', 'media_url',
            'media_mime', 'is_pinned', 'like_count', 'comment_count',
            'repost_count', 'share_count', 'save_count', 'view_count',
            'is_repost', 'original_post_id', 'is_anonymous',
            'author_data', 'is_liked', 'is_reposted_by_me', 'reposters',
            'comments', 'created_at',
            'reaction_counts', 'user_reaction', 'is_saved_by_me',
            'community_name', 'community_cover_url',
        ]
        read_only_fields = [
            'id', 'conversation_id', 'author_id', 'like_count',
            'comment_count', 'repost_count', 'share_count', 'save_count',
            'view_count', 'is_repost', 'original_post_id', 'created_at',
        ]

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

    def get_is_reposted_by_me(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.reposts.filter(profile=request.user.profile).exists()

    def get_reposters(self, obj):
        request = self.context.get('request')
        qs = obj.reposts.select_related('profile')[:5]
        return [
            {
                'user_id': str(r.profile.user_id),
                'display_name': r.profile.display_name,
                'avatar_url': r.profile.avatar_url,
                'followed_by_viewer': r.profile == getattr(
                    request.user, 'profile', None
                ) if request else False,
            }
            for r in qs
        ]

    def get_reaction_counts(self, obj):
        counts = {}
        if obj.like_count:
            counts['💪'] = obj.like_count
        for row in obj.reactions.values('reaction_type').annotate(c=Count('pk')):
            reaction = row['reaction_type']
            counts[reaction] = counts.get(reaction, 0) + row['c']
        return counts

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        profile = request.user.profile
        if obj.likes.filter(profile=profile).exists():
            return '💪'
        return (
            obj.reactions.filter(profile=profile)
            .values_list('reaction_type', flat=True)
            .first()
        )

    def get_is_saved_by_me(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.saves.filter(profile=request.user.profile).exists()

    def get_community_name(self, obj):
        return obj.conversation.group_name or ''

    def get_community_cover_url(self, obj):
        return obj.conversation.cover_url or ''

    def get_comments(self, obj):
        include = self.context.get('include_comments', False)
        if not include:
            return None
        qs = obj.comments.select_related('author').prefetch_related('replies')[:20]
        return CommunityPostCommentSerializer(qs, many=True).data


# ---------------------------------------------------------------------------
# Community activities (events / lives / schedules)
# ---------------------------------------------------------------------------
#
# These are community-scoped rows in the marketplace, lives and gyms apps. The
# input serializers here stay minimal on purpose: the community page offers one
# form per activity type, and the owning app's own detail screens remain the
# place to edit advanced fields (ticket tiers, co-hosts, recurrences).

class CommunityEventInputSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_blank=True, default='')
    event_type = serializers.ChoiceField(
        choices=['in_person', 'online', 'hybrid'], default='in_person',
    )
    location = serializers.CharField(required=False, allow_blank=True, max_length=300, default='')
    online_url = serializers.URLField(required=False, allow_blank=True, default='')
    start_datetime = serializers.DateTimeField()
    end_datetime = serializers.DateTimeField()
    timezone = serializers.CharField(required=False, max_length=60, default='UTC')
    capacity = serializers.IntegerField(required=False, default=0, min_value=0)
    is_free = serializers.BooleanField(required=False, default=True)
    cover_image_url = serializers.URLField(required=False, allow_blank=True, default='')
    tags = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    category = serializers.CharField(required=False, allow_blank=True, max_length=50, default='')

    def validate(self, attrs):
        if attrs['end_datetime'] <= attrs['start_datetime']:
            raise serializers.ValidationError({'end_datetime': 'The event must end after it starts.'})
        return attrs


class CommunityLiveInputSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=80)
    live_type = serializers.ChoiceField(
        choices=[
            'open_sweat', 'buddy_circle', 'gym_live', 'pt_session_live',
            'random_drop', 'practitioner_live', 'audio',
        ],
        default='buddy_circle',
    )
    category = serializers.CharField(required=False, max_length=50, default='fitness')
    access = serializers.ChoiceField(
        choices=['public', 'buddies', 'gym_members', 'private'], default='public',
    )
    scheduled_for = serializers.DateTimeField(required=False, allow_null=True, default=None)


class CommunityScheduleInputSerializer(serializers.Serializer):
    title = serializers.CharField(required=False, allow_blank=True, max_length=150, default='')
    content = serializers.CharField(required=False, allow_blank=True, max_length=2000, default='')
    activity_type = serializers.ChoiceField(
        choices=[
            'yoga', 'hiit', 'strength', 'cardio', 'live_stream',
            'workshop', 'event', 'session', 'other',
        ],
        default='other',
    )
    custom_activity_type = serializers.CharField(required=False, allow_blank=True, max_length=50, default='')
    location_mode = serializers.ChoiceField(
        choices=['in_house', 'online', 'hybrid'], default='in_house',
    )
    start_time = serializers.DateTimeField(required=False, allow_null=True, default=None)
    end_time = serializers.DateTimeField(required=False, allow_null=True, default=None)
    recurrence = serializers.ChoiceField(
        choices=['none', 'daily', 'weekly', 'monthly', 'yearly'], default='none',
    )
    recurrence_end_date = serializers.DateField(required=False, allow_null=True, default=None)
    recurrence_days = serializers.ListField(
        child=serializers.IntegerField(min_value=0, max_value=6),
        required=False, default=list,
    )
    max_slots = serializers.IntegerField(required=False, default=0, min_value=0)
    timezone = serializers.CharField(required=False, max_length=60, default='UTC')

    def validate(self, attrs):
        start, end = attrs.get('start_time'), attrs.get('end_time')
        if start and end and end <= start:
            raise serializers.ValidationError({'end_time': 'The session must end after it starts.'})
        return attrs
