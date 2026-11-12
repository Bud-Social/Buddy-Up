from rest_framework import views, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.db import transaction
from django.utils import timezone

from .models import Community, CommunityPost
from .serializers import CommunitySerializer
from .post_payload import community_post_payload
from apps.messaging.models import Conversation, ConversationMembership, CommunityPost as MessagingCommunityPost, CommunityPostSave, CommunityPostRepost, CommunityPostLike, CommunityPostReaction, _generate_invite_code
from apps.feed.models import Post


class CommunityListView(views.APIView):
    """List communities — public communities by default, with optional membership filter."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Community.objects.filter(is_deleted=False)
        if not request.GET.get('include_private'):
            qs = qs.filter(is_private=False)
        # Order by member count descending (most popular first)
        qs = qs.annotate(member_cnt=db_models.Count('members')).order_by('-member_cnt', '-created_at')
        data = CommunitySerializer(qs, many=True, context={'request': request}).data
        return Response({'success': True, 'data': data, 'message': 'Communities.', 'errors': None, 'pagination': None})


class AllCommunityPostsView(views.APIView):
    """List posts from communities the user has joined or that are public."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = request.user.profile
        # Return messaging community posts from communities the user has joined
        # OR that are public (read-only access, join button shown on frontend)
        messaging_posts = MessagingCommunityPost.objects.filter(
            conversation__is_community=True
        ).filter(
            db_models.Q(conversation__participants=profile) |
            db_models.Q(conversation__is_public=True)
        ).select_related('author', 'conversation')
        # The OR across the participants M2M join otherwise returns one row per
        # participant, duplicating posts in the feed (and React keys).
        messaging_posts = messaging_posts.distinct().order_by('-created_at')[:20]

        # Precompute user engagement state for all posts at once
        post_ids = [str(cp.id) for cp in messaging_posts]
        saved_ids = {
            str(x) for x in CommunityPostSave.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        reposted_ids = {
            str(x) for x in CommunityPostRepost.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        liked_ids = {
            str(x) for x in CommunityPostLike.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        # Reaction counts by type per post
        reaction_counts_qs = CommunityPostReaction.objects.filter(
            post_id__in=post_ids
        ).values('post_id', 'reaction_type').annotate(
            cnt=db_models.Count('pk')
        )
        reaction_counts_map = {}
        for rc in reaction_counts_qs:
            reaction_counts_map.setdefault(str(rc['post_id']), {})[rc['reaction_type']] = rc['cnt']
        # User reactions per post
        user_reactions_qs = CommunityPostReaction.objects.filter(
            post_id__in=post_ids, profile=profile
        ).values('post_id', 'reaction_type')
        user_reaction_map = {str(ur['post_id']): ur['reaction_type'] for ur in user_reactions_qs}
        # Likes live in their own table; surface them as 💪 so the count and
        # the viewer's like state survive a refresh.
        for cp in messaging_posts:
            pid = str(cp.id)
            if cp.like_count:
                counts = reaction_counts_map.setdefault(pid, {})
                counts['💪'] = counts.get('💪', 0) + cp.like_count
            if pid in liked_ids:
                user_reaction_map[pid] = '💪'

        # Reposters per post (bulk query to avoid N+1)
        reposters_qs = CommunityPostRepost.objects.filter(
            post_id__in=post_ids
        ).select_related('profile').order_by('created_at')
        reposters_map = {}
        for rp in reposters_qs:
            reposters_map.setdefault(str(rp.post_id), []).append({
                'user_id': str(rp.profile.user_id),
                'username': rp.profile.username or '',
                'display_name': rp.profile.display_name or '',
                'avatar_url': rp.profile.avatar_url or '',
                'verification_status': rp.profile.verification_status or 'verified',
            })

        # Precompute membership per conversation (community)
        joined_community_ids = {
            str(x) for x in Conversation.objects.filter(
                is_community=True, participants=profile
            ).values_list('id', flat=True)
        }

        data = []
        for cp in messaging_posts:
            pid = str(cp.id)
            data.append(community_post_payload(
                cp,
                reaction_counts=reaction_counts_map.get(pid, {}),
                user_reaction=user_reaction_map.get(pid),
                is_saved=pid in saved_ids,
                is_reposted_by_me=pid in reposted_ids,
                reposters=reposters_map.get(pid, []),
                is_member=str(cp.conversation_id) in joined_community_ids,
            ))

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

        # Precompute user engagement state for all posts at once
        profile = request.user.profile
        post_ids = [str(cp.id) for cp in messaging_posts]
        saved_ids = {
            str(x) for x in CommunityPostSave.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        reposted_ids = {
            str(x) for x in CommunityPostRepost.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        liked_ids = {
            str(x) for x in CommunityPostLike.objects.filter(
                post_id__in=post_ids, profile=profile
            ).values_list('post_id', flat=True)
        }
        # Reaction counts by type per post
        reaction_counts_qs = CommunityPostReaction.objects.filter(
            post_id__in=post_ids
        ).values('post_id', 'reaction_type').annotate(
            cnt=db_models.Count('pk')
        )
        reaction_counts_map = {}
        for rc in reaction_counts_qs:
            reaction_counts_map.setdefault(str(rc['post_id']), {})[rc['reaction_type']] = rc['cnt']
        # User reactions per post
        user_reactions_qs = CommunityPostReaction.objects.filter(
            post_id__in=post_ids, profile=profile
        ).values('post_id', 'reaction_type')
        user_reaction_map = {str(ur['post_id']): ur['reaction_type'] for ur in user_reactions_qs}
        # Likes live in their own table; surface them as 💪 so the count and
        # the viewer's like state survive a refresh.
        for cp in messaging_posts:
            pid = str(cp.id)
            if cp.like_count:
                counts = reaction_counts_map.setdefault(pid, {})
                counts['💪'] = counts.get('💪', 0) + cp.like_count
            if pid in liked_ids:
                user_reaction_map[pid] = '💪'

        # Reposters per post (bulk query to avoid N+1)
        reposters_qs = CommunityPostRepost.objects.filter(
            post_id__in=post_ids
        ).select_related('profile').order_by('created_at')
        reposters_map = {}
        for rp in reposters_qs:
            reposters_map.setdefault(str(rp.post_id), []).append({
                'user_id': str(rp.profile.user_id),
                'username': rp.profile.username or '',
                'display_name': rp.profile.display_name or '',
                'avatar_url': rp.profile.avatar_url or '',
                'verification_status': rp.profile.verification_status or 'verified',
            })

        for cp in messaging_posts:
            pid = str(cp.id)
            data.append(community_post_payload(
                cp,
                reaction_counts=reaction_counts_map.get(pid, {}),
                user_reaction=user_reaction_map.get(pid),
                is_saved=pid in saved_ids,
                is_reposted_by_me=pid in reposted_ids,
                reposters=reposters_map.get(pid, []),
            ))
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

        with transaction.atomic():
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

            # Also create a matching messaging Conversation so that the
            # messaging app's community post endpoints (like, repost, save, react,
            # view, share) can resolve this community by UUID. Uses the same UUID
            # as the Community so both models share one identifier.
            conv = Conversation.objects.create(
                id=community.id,
                is_group=True,
                is_community=True,
                group_name=name[:100],
                description=description,
                is_public=not is_private,
                invite_code=_generate_invite_code(),
                created_by=request.user.profile,
                last_message_at=timezone.now(),
            )
            conv.participants.add(request.user.profile)
            ConversationMembership.objects.create(
                conversation=conv, profile=request.user.profile, role='owner',
            )
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