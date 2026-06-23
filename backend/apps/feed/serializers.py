from rest_framework import serializers
from .models import Post, Comment, Reaction, Save


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
        from collections import Counter
        counts = Counter(obj.reactions.values_list('reaction_type', flat=True))
        return dict(counts)

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        reaction = obj.reactions.filter(author=request.user.profile).first()
        return reaction.reaction_type if reaction else None


class PostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()
    reaction_counts = serializers.SerializerMethodField()
    user_reaction = serializers.SerializerMethodField()
    comment_count = serializers.SerializerMethodField()
    repost_count = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
            'id', 'post_type', 'body', 'is_anonymous', 'gym_tag_id',
            'visibility', 'is_repost', 'original_post_id', 'quote_body',
            'location_label', 'workout_log_data', 'meal_data', 'progress_data',
            'media_urls', 'tags', 'view_count', 'moderation_status',
            'author_data', 'reaction_counts', 'user_reaction',
            'comment_count', 'repost_count', 'is_saved',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'view_count', 'moderation_status', 'created_at', 'updated_at']

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
        from collections import Counter
        counts = Counter(obj.reactions.values_list('reaction_type', flat=True))
        return dict(counts)

    def get_user_reaction(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        reaction = obj.reactions.filter(author=request.user.profile).first()
        return reaction.reaction_type if reaction else None

    def get_comment_count(self, obj):
        return obj.comments.count()

    def get_repost_count(self, obj):
        return obj.reposts.count()

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.saves.filter(user=request.user.profile).exists()


class PostCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = [
            'post_type', 'body', 'is_anonymous', 'gym_tag_id', 'visibility',
            'location_label', 'workout_log_data', 'meal_data', 'progress_data',
            'media_urls', 'tags',
        ]

    def validate_body(self, value):
        max_length = 2200
        if len(value) > max_length:
            raise serializers.ValidationError(f'Body must be {max_length} characters or fewer.')
        return value


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
