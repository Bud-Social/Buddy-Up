from rest_framework import views, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Count

from .models import Community, CommunityPost
from .serializers import CommunitySerializer, CommunityPostSerializer
from apps.feed.models import Post


class CommunityListView(views.APIView):
    """List communities — public communities by default, with optional membership filter."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Community.objects.filter(is_deleted=False)
        if not request.GET.get('include_private'):
            qs = qs.filter(is_private=False)
        # Order by member count descending (most popular first)
        qs = qs.annotate(member_cnt=Count('members')).order_by('-member_cnt', '-created_at')
        data = CommunitySerializer(qs, many=True, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Communities.', 'errors': None, 'pagination': None})


class CommunityDetailView(views.APIView):
    """Get a single community with its posts."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, slug):
        community = get_object_or_404(Community, slug=slug, is_deleted=False)
        data = CommunitySerializer(community, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Community.', 'errors': None, 'pagination': None})


class CommunityJoinView(views.APIView):
    """Join a community."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, slug):
        community = get_object_or_404(Community, slug=slug, is_deleted=False)
        profile = request.user.profile
        if community.members.filter(id=profile.id).exists():
            return Response({'success': False, 'data': None, 'message': 'Already a member.', 'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)
        community.members.add(profile)
        return Response({'success': True, 'data': {'member_count': community.members.count()}, 'message': 'Joined community.', 'errors': None, 'pagination': None})


class CommunityLeaveView(views.APIView):
    """Leave a community."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, slug):
        community = get_object_or_404(Community, slug=slug, is_deleted=False)
        profile = request.user.profile
        community.members.remove(profile)
        return Response({'success': True, 'data': {'member_count': community.members.count()}, 'message': 'Left community.', 'errors': None, 'pagination': None})


class CommunityPostsView(views.APIView):
    """List posts in a community."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, slug):
        community = get_object_or_404(Community, slug=slug, is_deleted=False)
        cursor = request.GET.get('cursor')
        qs = CommunityPost.objects.filter(community=community, is_deleted=False).select_related('post__author', 'post')
        # Simple cursor-free pagination for now — return latest 20
        qs = qs.order_by('-created_at')[:20]
        data = CommunityPostSerializer(qs, many=True, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Community posts.', 'errors': None, 'pagination': None})


class CommunityCreateView(views.APIView):
    """Create a new community."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        name = request.data.get('name', '').strip()
        description = request.data.get('description', '').strip()
        category = request.data.get('category', '').strip()
        is_private = request.data.get('is_private', False)
        is_nsfw = request.data.get('is_nsfw', False)
        tags = request.data.get('tags', [])

        if not name:
            return Response({'success': False, 'data': None, 'message': 'Name is required.', 'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)

        community = Community.objects.create(
            name=name,
            slug=name.lower().replace(' ', '-'),
            description=description,
            category=category,
            is_private=is_private,
            is_nsfw=is_nsfw,
            tags=tags if isinstance(tags, list) else [],
            creator=request.user.profile,
        )
        community.members.add(request.user.profile)
        data = CommunitySerializer(community, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Community created.', 'errors': None, 'pagination': None}, status=status.HTTP_201_CREATED)


class CommunityPostCreateView(views.APIView):
    """Add an existing post to a community."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, slug):
        community = get_object_or_404(Community, slug=slug, is_deleted=False)
        post_id = request.data.get('post_id')
        if not post_id:
            return Response({'success': False, 'data': None, 'message': 'post_id is required.', 'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)
        post = get_object_or_404(Post, id=post_id, is_deleted=False)
        cp, created = CommunityPost.objects.get_or_create(
            community=community, post=post,
            defaults={'added_by': request.user.profile},
        )
        if created:
            community.post_count = CommunityPost.objects.filter(community=community, is_deleted=False).count()
            community.save(update_fields=['post_count'])
        data = CommunityPostSerializer(cp, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Post added to community.', 'errors': None, 'pagination': None})
