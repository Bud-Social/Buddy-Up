from rest_framework import views, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Count

from .models import Community, CommunityPost
from .serializers import CommunitySerializer
from apps.messaging.models import Conversation, CommunityPost as MessagingCommunityPost
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


class AllCommunityPostsView(views.APIView):
    """List posts from all communities."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        # Return messaging community posts as Post-like objects
        messaging_posts = MessagingCommunityPost.objects.filter().select_related('author', 'conversation')
        messaging_posts = messaging_posts.order_by('-created_at')[:20]

        data = []
        for cp in messaging_posts:
            author_data = {}
            if cp.author:
                author_data = {
                    'user_id': str(cp.author.user_id) if hasattr(cp.author, 'user_id') else str(cp.author.id),
                    'username': cp.author.username if hasattr(cp.author, 'username') else '',
                    'display_name': cp.author.display_name if hasattr(cp.author, 'display_name') else '',
                    'avatar_url': cp.author.avatar_url if hasattr(cp.author, 'avatar_url') else '',
                    'verification_status': 'verified',
                }
            data.append({
                'id': str(cp.id),
                'post_type': 'text',
                'body': cp.body or '',
                'is_anonymous': False,
                'gym_tag_id': None,
                'gym_tag_name': None,
                'visibility': 'public',
                'location_label': '',
                'location_lat': None,
                'location_lng': None,
                'workout_log_data': None,
                'media_urls': [cp.media_url] if cp.media_url else [],
                'media': [],
                'tags': [],
                'view_count': 0,
                'share_count': 0,
                'moderation_status': 'clean',
                'content_rating': 'safe',
                'comments_disabled': False,
                'author_data': author_data,
                'reaction_counts': {},
                'user_reaction': 'like' if cp.is_liked else None,
                'comment_count': cp.comment_count or 0,
                'repost_count': 0,
                'save_count': 0,
                'is_saved': False,
                'is_reposted_by_me': False,
                'is_repost': False,
                'original_post_data': None,
                'is_pinned': cp.is_pinned,
                'poll': None,
                'reposters': [],
                'created_at': cp.created_at.isoformat() if cp.created_at else None,
                'updated_at': cp.updated_at.isoformat() if cp.updated_at else None,
                'ai_analysis': {},
                'community_id': str(cp.conversation_id),
            })

        return Response({'success': True, 'data': data, 'message': 'All community posts.', 'errors': None, 'pagination': None})


class CommunityDetailView(views.APIView):
    """Get a single community with its posts."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, slug):
        try:
            community = Community.objects.get(id=slug, is_deleted=False)
        except (Community.DoesNotExist, ValueError):
            # Fall back to messaging conversation
            try:
                conv = Conversation.objects.get(id=slug, is_community=True, is_deleted=False)
                community = Community.objects.create(
                    id=conv.id,
                    name=conv.group_name or 'Community',
                    slug=conv.group_name.lower().replace(' ', '-') if conv.group_name else str(conv.id),
                    description=conv.description or '',
                    cover_url=conv.cover_url or '',
                    avatar_url=conv.group_avatar_url or '',
                    creator=conv.created_by,
                    is_private=not conv.is_public,
                )
                community.members.add(request.user.profile)
            except Exception:
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
        # Try to find the community in messaging system
        try:
            conv = Conversation.objects.get(id=slug, is_community=True)
        except (Conversation.DoesNotExist, ValueError):
            # Fall back to communities app
            try:
                community = Community.objects.get(id=slug, is_deleted=False)
            except Community.DoesNotExist:
                community = get_object_or_404(Community, slug=slug, is_deleted=False)
            qs = Post.objects.filter(
                is_deleted=False,
                community_links__community=community,
                community_links__is_deleted=False,
            ).select_related('author')
            qs = qs.order_by('-created_at')[:20]
            from apps.feed.serializers import PostSerializer
            data = PostSerializer(qs, many=True, context={'request': request}).data
            return Response({'success': True, 'data': data, 'message': 'Community posts.', 'errors': None, 'pagination': None})

        # Return messaging community posts as Post-like objects
        messaging_posts = MessagingCommunityPost.objects.filter(
            conversation=conv
        ).select_related('author').order_by('-created_at')[:20]

        data = []
        for cp in messaging_posts:
            author_data = {}
            if cp.author:
                author_data = {
                    'user_id': str(cp.author.user_id) if hasattr(cp.author, 'user_id') else str(cp.author.id),
                    'username': cp.author.username if hasattr(cp.author, 'username') else '',
                    'display_name': cp.author.display_name if hasattr(cp.author, 'display_name') else '',
                    'avatar_url': cp.author.avatar_url if hasattr(cp.author, 'avatar_url') else '',
                    'verification_status': 'verified',
                }
            data.append({
                'id': str(cp.id),
                'post_type': 'text',
                'body': cp.body or '',
                'is_anonymous': False,
                'gym_tag_id': None,
                'gym_tag_name': None,
                'visibility': 'public',
                'location_label': '',
                'location_lat': None,
                'location_lng': None,
                'workout_log_data': None,
                'media_urls': [cp.media_url] if cp.media_url else [],
                'media': [],
                'tags': [],
                'view_count': 0,
                'share_count': 0,
                'moderation_status': 'clean',
                'content_rating': 'safe',
                'comments_disabled': False,
                'author_data': author_data,
                'reaction_counts': {},
                'user_reaction': 'like' if cp.is_liked else None,
                'comment_count': cp.comment_count or 0,
                'repost_count': 0,
                'save_count': 0,
                'is_saved': False,
                'is_reposted_by_me': False,
                'is_repost': False,
                'original_post_data': None,
                'is_pinned': cp.is_pinned,
                'poll': None,
                'reposters': [],
                'created_at': cp.created_at.isoformat() if cp.created_at else None,
                'updated_at': cp.updated_at.isoformat() if cp.updated_at else None,
                'ai_analysis': {},
                'community_id': str(conv.id),
            })

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
            creator=request.user.profile,
            is_private=is_private,
            is_nsfw=is_nsfw,
            tags=tags if isinstance(tags, list) else [],
            description=description,
            category=category,
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
        from apps.feed.serializers import PostSerializer
        data = PostSerializer(post, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Post added to community.', 'errors': None, 'pagination': None})