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
        # A view-once payload is never delivered in the conversation feed:
        # recipients only receive a URL from the consume endpoint, and only
        # on the first open. The sender keeps their own copy.
        if instance.view_once:
            if viewer is None or viewer.pk != instance.sender.pk:
                data['media_url'] = ''
                reply = data.get('reply_data')
                if isinstance(reply, dict):
                    reply['media_url'] = ''
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
        return dict(Counter(reaction.emoji for reaction in obj.reactions.all()))


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
    is_archived = serializers.SerializerMethodField()
    is_muted = serializers.SerializerMethodField()
    is_pinned = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'is_group', 'is_community', 'group_name', 'group_avatar_url',
            'group_gym_id', 'description', 'cover_url', 'invite_code', 'is_public',
            'sub_channel', 'call_in_progress',
            'origin', 'promoted_at', 'promotable', 'promotion_status', 'promotion_id', 'promotion_requested_by',
            'is_archived', 'is_muted', 'is_pinned',
            'participants_data', 'member_count', 'unread_count', 'membership_role',
            'last_message', 'last_message_at', 'created_at',
        ]

    def get_preference(self, obj):
        from .models import ConversationPreference

        prefetched = getattr(obj, '_viewer_prefs', None)
        if prefetched is not None:
            return prefetched[0] if prefetched else None
        profile = self._viewer()
        if profile is None:
            return None
        return ConversationPreference.objects.filter(
            conversation=obj, profile=profile,
        ).first()

    def get_is_archived(self, obj):
        pref = self.get_preference(obj)
        return pref.is_archived if pref else False

    def get_is_muted(self, obj):
        pref = self.get_preference(obj)
        return pref.is_muted if pref else False

    def get_is_pinned(self, obj):
        pref = self.get_preference(obj)
        return pref.is_pinned if pref else False

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
        participants = list(obj.participants.all())
        is_participant = any(p.pk == profile.pk for p in participants)
        membership = getattr(obj, '_viewer_membership', None)
        if membership is None:
            membership = ConversationMembership.objects.filter(
                conversation=obj, profile=profile,
            ).first()
        if not is_participant and membership is None:
            return []
        return [{
            'user_id': str(p.user_id),
            'username': p.username,
            'display_name': p.display_name,
            'avatar_url': p.avatar_url,
            'verification_status': p.verification_status,
            'role': p.role,
        } for p in participants]

    def get_membership_role(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        membership = getattr(obj, '_viewer_membership', None)
        if membership is None:
            membership = ConversationMembership.objects.filter(
                conversation=obj, profile=request.user.profile
            ).first()
        return membership.role if membership else None

    def get_invite_code(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        membership = getattr(obj, '_viewer_membership', None)
        if membership is None:
            membership = ConversationMembership.objects.filter(
                conversation=obj, profile=request.user.profile,
            ).first()
        return obj.invite_code if membership else None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return 0
        annotated = getattr(obj, '_unread_count', None)
        if annotated is not None:
            return annotated
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

    def _buddy_ids(self):
        cached = self.context.get('_viewer_buddy_ids')
        if cached is not None:
            return cached
        profile = self._viewer()
        if profile is None:
            cached = set()
        else:
            from django.db.models import Q
            from apps.profiles.models import BuddyRelationship
            cached = set()
            for from_id, to_id in BuddyRelationship.objects.filter(
                Q(from_user=profile) | Q(to_user=profile),
                status='confirmed',
            ).values_list('from_user_id', 'to_user_id'):
                cached.add(to_id if from_id == profile.user_id else from_id)
            cached.discard(profile.user_id)
        self.context['_viewer_buddy_ids'] = cached
        return cached

    def get_promotable(self, obj):
        """True when the viewer may turn this DM into a buddy relationship."""
        profile = self._viewer()
        if profile is None:
            return False
        from .blocking import other_participant
        other = other_participant(obj, profile)
        if other is None:
            return False
        return other.user_id not in self._buddy_ids()

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
        # The list view annotates the latest message so the inbox stays one
        # query. Fall back to a bounded recent window for single-object reads.
        last_type = getattr(obj, '_last_message_type', None)
        if last_type is not None:
            return {
                'body': (getattr(obj, '_last_message_body', '') or '')[:100],
                'message_type': last_type,
                'media_url': getattr(obj, '_last_message_media_url', '') or '',
                'sender_name': getattr(obj, '_last_message_sender_name', '') or '',
            }
        request = self.context.get('request')
        hidden_for = None
        if request and request.user.is_authenticated:
            hidden_for = str(request.user.profile.user_id)
        recent = list(
            obj.messages.filter(is_deleted=False)
            .select_related('sender')
            .order_by('-created_at')[:20]
        )
        if hidden_for:
            recent = [m for m in recent if hidden_for not in (m.deleted_for or [])]
        last = recent[0] if recent else None
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


def _staffed_gym_ids(profile):
    """Gyms where this profile holds a staff role — the gym-identity actors."""
    if profile is None:
        return []
    try:
        from apps.gyms.models import GymMembership
        return list(
            GymMembership.objects.filter(
                member=profile,
                role__in=['owner', 'co_owner', 'moderator'],
                subscription_active=True,
            ).values_list('gym_id', flat=True)
        )
    except Exception:  # noqa: BLE001
        return []


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
    gym_data = serializers.SerializerMethodField()
    reply_count = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPostComment
        fields = ['id', 'post_id', 'body', 'reply_to_id', 'author_data', 'gym_data',
                  'reply_count', 'media_type', 'media_url', 'sticker_pack',
                  'reaction_counts', 'user_reaction', 'created_at']

    def get_author_data(self, obj):
        if obj.gym_id is not None:
            gym = obj.gym
            return {
                'user_id': str(gym.id),
                'username': gym.handle,
                'display_name': gym.name,
                'avatar_url': getattr(gym, 'logo_url', '') or '',
                'is_gym': True,
                'verification_status': 'gym',
                'is_verified': gym.is_verified,
                'tier': gym.tier,
            }
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
            'verification_status': obj.author.verification_status or 'none',
        }

    def get_gym_data(self, obj):
        if obj.gym_id is None:
            return None
        gym = obj.gym
        logo = getattr(gym, 'logo_url', '') or ''
        return {'id': str(gym.id), 'name': gym.name, 'handle': gym.handle, 'logo_url': logo,
                'is_verified': gym.is_verified, 'tier': gym.tier}

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
        from django.db.models import Q
        gym_ids = _staffed_gym_ids(request.user.profile)
        if obj.likes.filter(Q(profile=request.user.profile) | Q(gym_id__in=gym_ids)).exists():
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
