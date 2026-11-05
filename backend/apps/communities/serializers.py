from rest_framework import serializers
from common.utils import absolute_media_url
from .models import Community, CommunityPost


class CommunitySerializer(serializers.ModelSerializer):
    member_count = serializers.SerializerMethodField()
    is_member = serializers.SerializerMethodField()
    cover_url = serializers.SerializerMethodField()
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = Community
        fields = [
            'id', 'name', 'slug', 'description', 'description_short',
            'cover_url', 'avatar_url', 'creator', 'member_count',
            'is_member', 'is_private', 'is_nsfw', 'category',
            'tags', 'post_count', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'creator', 'member_count', 'post_count', 'created_at', 'updated_at']

    def get_member_count(self, obj):
        return obj.members.count()

    def get_is_member(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.members.filter(id=request.user.profile.id).exists()

    def get_cover_url(self, obj):
        request = self.context.get('request')
        return absolute_media_url(request, obj.cover_url)

    def get_avatar_url(self, obj):
        request = self.context.get('request')
        return absolute_media_url(request, obj.avatar_url)


class CommunityPostSerializer(serializers.ModelSerializer):
    community = CommunitySerializer(read_only=True)

    class Meta:
        model = CommunityPost
        fields = ['id', 'community', 'post', 'added_by', 'created_at']
        read_only_fields = ['id', 'community', 'post', 'added_by', 'created_at']
