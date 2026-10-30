from rest_framework import serializers
from collections import Counter
from common.utils import absolute_media_url
from .models import Post, FeedPost, GymPost, Comment, Reaction, Save, Poll, PollOption, Draft, PostMedia, Sound
from apps.gyms.models import Gym
from common.age_gating import CONTENT_RATING_CHOICES

CONTENT_RATING_CHOICES_VALUES = {value for value, _label in CONTENT_RATING_CHOICES}

LEGACY_REACTION_EMOJI_MAP = {
    'pump': '💪',
    'fire': '🔥',
    'respect': '🤝',
    'grind': '😤',
    'lets_go': '🏋️',
    'haha': '😂',
    'too_hard': '💀',
    'heart': '❤️',
    'love': '❤️',
    'clap': '👏',
    'applause': '👏',
    'muscle': '💪',
    'strength': '💪',
}


def normalize_reaction(key):
    """Map legacy short-name reactions to emoji glyphs; pass through actual emoji."""
    if not key:
        return key
    return LEGACY_REACTION_EMOJI_MAP.get(key, key)


class PollOptionSerializer(serializers.ModelSerializer):
    vote_count = serializers.SerializerMethodField()
    user_voted = serializers.SerializerMethodField()

    class Meta:
        model = PollOption
        fields = ['id', 'text', 'order', 'vote_count', 'user_voted']

    def get_vote_count(self, obj):
        return obj.votes.count()

    def get_user_voted(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.votes.filter(voter=request.user.profile).exists()


class PollSerializer(serializers.ModelSerializer):
    options = PollOptionSerializer(many=True, read_only=True)
    total_votes = serializers.ReadOnlyField()
    is_closed = serializers.ReadOnlyField()
    user_voted_option_ids = serializers.SerializerMethodField()

    class Meta:
        model = Poll
        fields = ['id', 'question', 'closes_at', 'allow_multiple', 'min_selections',
                  'max_selections', 'total_votes', 'is_closed', 'options', 'user_voted_option_ids']

    def get_user_voted_option_ids(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return []
        return list(obj.votes.filter(voter=request.user.profile).values_list('option_id', flat=True))


class CommentSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    reply_count = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = ['id', 'post_id', 'author_id', 'author_data', 'body', 'media_type',
                   'media_url', 'sticker_pack', 'parent_id',
                   'is_anonymous', 'reply_count', 'reaction_counts', 'user_reaction',
                   'created_at', 'updated_at']
        read_only_fields = ['id', 'author_id', 'created_at', 'updated_at']

    def get_author_data(self, obj):
        if obj.is_anonymous:
            return {'display_name': 'Anonymous BuddyUp Fit Member', 'username': '', 'avatar_url': ''}
        request = self.context.get('request')
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': absolute_media_url(request, obj.author.avatar_url),
            'verification_status': obj.author.verification_status,
        }

    def get_reply_count(self, obj):
        return obj.replies.count()

    def get_reaction_counts(self, obj):
        counts = Counter(obj.reactions.values_list('reaction_type', flat=True))
        normalized = {}
        for key, value in counts.items():
            normalized[normalize_reaction(key)] = normalized.get(normalize_reaction(key), 0) + value
        return normalized

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        reaction = obj.reactions.filter(author=request.user.profile).first()
        return normalize_reaction(reaction.reaction_type) if reaction else None


class PostMediaSerializer(serializers.ModelSerializer):
    """Structured media row (Bud Press). Read-only; managed via create/media[]."""
    sound_audio_url = serializers.SerializerMethodField()

    class Meta:
        model = PostMedia
        fields = [
            'id', 'post', 'order', 'media_type', 'url', 'poster_url',
            'width', 'height', 'duration_ms', 'trim_start_ms', 'trim_end_ms',
            'sound', 'sound_volume', 'sound_audio_url', 'captions', 'captions_vtt', 'edit_meta', 'alt_text',
            'created_at', 'updated_at',
        ]
        read_only_fields = fields

    def get_sound_audio_url(self, obj):
        return obj.sound.audio_url if obj.sound_id and obj.sound else None


class PostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()
    repost_count = serializers.SerializerMethodField()
    save_count = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()
    is_reposted_by_me = serializers.SerializerMethodField()
    poll = serializers.SerializerMethodField()
    gym_tag_name = serializers.SerializerMethodField()
    reposters = serializers.SerializerMethodField()
    media = PostMediaSerializer(many=True, read_only=True)

    class Meta:
        model = Post
        fields = [
        'id', 'post_type', 'body', 'is_anonymous', 'gym_tag_id', 'gym_tag_name',
        'visibility',
        'location_label', 'location_lat', 'location_lng', 'workout_log_data',
        'media_urls', 'media', 'tags', 'view_count', 'share_count', 'moderation_status',
        'content_rating', 'comments_disabled',
        'author_data', 'reaction_counts', 'user_reaction',
        'comment_count', 'repost_count', 'save_count', 'is_saved', 'is_reposted_by_me', 'is_pinned',
        'poll', 'reposters', 'created_at', 'updated_at',
        'ai_analysis',
        ]
        read_only_fields = ['id', 'view_count', 'share_count', 'moderation_status', 'ai_analysis', 'created_at', 'updated_at']

    def get_author_data(self, obj):
        if obj.is_anonymous:
            return {'display_name': 'Anonymous BuddyUp Fit Member', 'username': '', 'avatar_url': ''}
        request = self.context.get('request')
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': absolute_media_url(request, obj.author.avatar_url),
            'verification_status': obj.author.verification_status,
        }

    def get_reaction_counts(self, obj):
        counts = Counter(obj.reactions.values_list('reaction_type', flat=True))
        normalized = {}
        for key, value in counts.items():
            normalized[normalize_reaction(key)] = normalized.get(normalize_reaction(key), 0) + value
        return normalized

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        reaction = obj.reactions.filter(author=request.user.profile).first()
        return normalize_reaction(reaction.reaction_type) if reaction else None

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_repost_count(self, obj):
        """Count the PostRepost log rows (reposts are post properties)."""
        return obj.reposts.count()

    def get_save_count(self, obj):
        return obj.saves.count()

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.saves.filter(user=request.user.profile).exists()

    def get_is_reposted_by_me(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.reposts.filter(profile=request.user.profile, is_deleted=False).exists()

    def get_poll(self, obj):
        if hasattr(obj, 'poll'):
            return PollSerializer(obj.poll, context=self.context).data
        return None

    def get_gym_tag_name(self, obj):
        return obj.gym_tag.name if obj.gym_tag else None

    def get_reposters(self, obj):
        """Reposter ribbon, derived from PostRepost log rows on this post."""
        request = self.context.get('request')
        if not obj.reposts.count():
            return []
        viewer = None
        try:
            if request and request.user.is_authenticated:
                viewer = request.user.profile
        except Exception:  # noqa: BLE001 — attribution ordering is best-effort
            viewer = None
        followed_ids = set()
        try:
            if viewer is not None and hasattr(viewer, 'following'):
                followed_ids = set(viewer.following.values_list('followee_id', flat=True))
        except Exception:  # noqa: BLE001 — attribution ordering is best-effort
            pass
        reposts = list(obj.reposts.filter(is_deleted=False).select_related('profile')[:20])
        # TikTok-style attribution: accounts the viewer follows first.
        reposts.sort(key=lambda r: (r.profile_id not in followed_ids, r.created_at))
        return [
            {
                'user_id': str(r.profile.user_id),
                'display_name': r.profile.display_name,
                'avatar_url': absolute_media_url(request, r.profile.avatar_url),
                'followed_by_viewer': r.profile_id in followed_ids,
            }
            for r in reposts
        ]


class CommentCreateSerializer(serializers.Serializer):
    body = serializers.CharField(max_length=500, required=False, allow_blank=True, default='')
    media_type = serializers.ChoiceField(choices=['text', 'image', 'gif', 'sticker'], default='text')
    media_url = serializers.URLField(required=False, allow_blank=True, default='')
    sticker_pack = serializers.CharField(max_length=50, required=False, allow_blank=True, default='')
    parent_id = serializers.CharField(required=False, allow_null=True)
    is_anonymous = serializers.BooleanField(default=False)

    def validate(self, attrs):
        media_type = attrs.get('media_type', 'text')
        body = attrs.get('body', '')
        media_url = attrs.get('media_url', '')
        if media_type == 'text' and not body.strip():
            raise serializers.ValidationError({
                'body': 'Text comments cannot be empty.'
            })
        if media_type in ('image', 'gif', 'sticker') and not media_url:
            raise serializers.ValidationError({
                'media_url': f'{media_type} comments require a media URL.'
            })
        return attrs


class ReactionInputSerializer(serializers.Serializer):
    reaction_type = serializers.CharField(max_length=20, min_length=1)


class RepostSerializer(serializers.Serializer):
    quote_body = serializers.CharField(max_length=500, required=False, allow_blank=True, default='')


class SavePostSerializer(serializers.Serializer):
    collection = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')


class PollCreateSerializer(serializers.Serializer):
    poll_question = serializers.CharField(max_length=300, required=False, allow_blank=True, default='')
    poll_options_json = serializers.CharField(required=False, allow_blank=True, default='[]')
    poll_closes_at = serializers.DateTimeField(required=False, allow_null=True)
    poll_allow_multiple = serializers.BooleanField(default=False)


class OptionVoteSerializer(serializers.Serializer):
    option_id = serializers.CharField(required=False, allow_null=True)
    option_ids = serializers.ListField(
        child=serializers.CharField(), required=False, default=list,
    )


class PostCreateSerializer(serializers.ModelSerializer):
    gym_tag = serializers.PrimaryKeyRelatedField(
        queryset=Gym.objects.all(), required=False, allow_null=True
    )
    comments_disabled = serializers.BooleanField(default=False, required=False)

    class Meta:
        model = Post
        fields = [
            'post_type', 'body', 'is_anonymous', 'gym_tag', 'visibility',
            'location_label', 'location_lat', 'location_lng', 'workout_log_data',
            'media_urls', 'tags', 'content_rating', 'comments_disabled',
        ]

    def validate_body(self, value):
        max_length = 2200
        if len(value) > max_length:
            raise serializers.ValidationError(f'Body must be {max_length} characters or fewer.')
        return value

    def validate_content_rating(self, value):
        if value not in (CONTENT_RATING_CHOICES_VALUES):
            raise serializers.ValidationError('content_rating must be one of general/mature.')
        return value


class DraftSerializer(serializers.ModelSerializer):
    class Meta:
        model = Draft
        fields = [
            'id', 'post_type', 'body', 'visibility', 'gym_tag',
            'location_label', 'location_lat', 'location_lng',
            'media_urls', 'tags', 'poll_question',
            'poll_options', 'poll_allow_multiple', 'poll_min_selections',
            'poll_max_selections',
            'mentioned_user_ids', 'is_anonymous', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ReactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reaction
        fields = ['post_id', 'comment_id', 'reaction_type']

    def validate(self, data):
        if not data.get('post_id') and not data.get('comment_id'):
            raise serializers.ValidationError('Must react to a post or comment.')
        return data


class SaveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Save
        fields = ['post_id', 'collection']


class FeedPostSerializer(PostSerializer):
    class Meta(PostSerializer.Meta):
        model = FeedPost


class GymPostSerializer(PostSerializer):
    class Meta(PostSerializer.Meta):
        model = GymPost


class SoundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sound
        fields = [
            'id', 'name', 'artist', 'audio_url', 'duration_ms', 'source',
            'license', 'original_post', 'usage_count', 'is_active',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'usage_count', 'is_active', 'created_at', 'updated_at']


class SoundCreateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=120)
    artist = serializers.CharField(max_length=120, required=False, allow_blank=True, default='')
    audio_url = serializers.URLField(required=False, allow_blank=True, default='')
    duration_ms = serializers.IntegerField(required=False, allow_null=True, min_value=0)
    original_post = serializers.PrimaryKeyRelatedField(
        queryset=Post.objects.all(), required=False, allow_null=True,
    )
