from rest_framework import serializers
from collections import Counter
from .models import Post, FeedPost, GymPost, Comment, Reaction, Save, Poll, PollOption, Draft
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
        fields = ['id', 'question', 'closes_at', 'allow_multiple', 'total_votes', 'is_closed', 'options', 'user_voted_option_ids']

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
        fields = ['id', 'post_id', 'author_id', 'author_data', 'body', 'parent_id',
                   'is_anonymous', 'reply_count', 'reaction_counts', 'user_reaction',
                   'created_at', 'updated_at']
        read_only_fields = ['id', 'author_id', 'created_at', 'updated_at']

    def get_author_data(self, obj):
        if obj.is_anonymous:
            return {'display_name': 'Anonymous BuddyUp Member', 'username': '', 'avatar_url': ''}
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
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


class PostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()
    repost_count = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()
    is_reposted_by_me = serializers.SerializerMethodField()
    poll = serializers.SerializerMethodField()
    gym_tag_name = serializers.SerializerMethodField()
    original_post_data = serializers.SerializerMethodField()
    reposters = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
        'id', 'post_type', 'body', 'is_anonymous', 'gym_tag_id', 'gym_tag_name',
        'visibility', 'is_repost', 'original_post_id', 'quote_body',
        'location_label', 'location_lat', 'location_lng', 'workout_log_data',
        'meal_data', 'progress_data',
        'media_urls', 'tags', 'view_count', 'moderation_status',
        'content_rating',
        'author_data', 'reaction_counts', 'user_reaction',
        'comment_count', 'repost_count', 'is_saved', 'is_reposted_by_me', 'is_pinned',
        'poll', 'original_post_data', 'reposters', 'created_at', 'updated_at',
        'ai_analysis',
        ]
        read_only_fields = ['id', 'view_count', 'moderation_status', 'ai_analysis', 'created_at', 'updated_at']

    def get_author_data(self, obj):
        if obj.is_anonymous:
            return {'display_name': 'Anonymous BuddyUp Member', 'username': '', 'avatar_url': ''}
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
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
        return obj.reposts.count()

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.saves.filter(user=request.user.profile).exists()

    def get_is_reposted_by_me(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.reposts.filter(author=request.user.profile).exists()

    def get_poll(self, obj):
        if hasattr(obj, 'poll'):
            return PollSerializer(obj.poll, context=self.context).data
        return None

    def get_gym_tag_name(self, obj):
        return obj.gym_tag.name if obj.gym_tag else None

    def get_original_post_data(self, obj):
        if obj.is_repost and obj.original_post:
            orig = obj.original_post
            return {
                'id': str(orig.id),
                'post_type': orig.post_type,
                'author_data': {
                    'user_id': str(orig.author.user_id),
                    'username': orig.author.username,
                    'display_name': orig.author.display_name,
                    'avatar_url': orig.author.avatar_url,
                    'verification_status': orig.author.verification_status,
                },
                'body': orig.body,
                'media_urls': orig.media_urls or [],
                'location_label': orig.location_label,
                'location_lat': orig.location_lat,
                'location_lng': orig.location_lng,
                'meal_data': orig.meal_data,
                'progress_data': orig.progress_data,
                'workout_log_data': orig.workout_log_data,
                'quote_body': orig.quote_body,
                'gym_tag_name': orig.gym_tag.name if orig.gym_tag else None,
                'created_at': orig.created_at.isoformat(),
            }
        return None

    def get_reposters(self, obj):
        if not obj.is_repost or not obj.original_post_id:
            return []
        reposts = Post.objects.filter(
            original_post_id=obj.original_post_id,
            is_repost=True,
        ).select_related('author')[:20]
        return [
            {
                'user_id': str(r.author.user_id),
                'display_name': r.author.display_name,
                'avatar_url': r.author.avatar_url,
            }
            for r in reposts
        ]


class CommentCreateSerializer(serializers.Serializer):
    body = serializers.CharField(max_length=500)
    parent_id = serializers.CharField(required=False, allow_null=True)
    is_anonymous = serializers.BooleanField(default=False)


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

    class Meta:
        model = Post
        fields = [
            'post_type', 'body', 'is_anonymous', 'gym_tag', 'visibility',
            'location_label', 'location_lat', 'location_lng', 'workout_log_data',
            'meal_data', 'progress_data',
            'media_urls', 'tags', 'content_rating',
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
            'location_label', 'media_urls', 'tags', 'poll_question',
            'poll_options', 'poll_allow_multiple', 'mentioned_user_ids',
            'is_anonymous', 'created_at', 'updated_at',
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
