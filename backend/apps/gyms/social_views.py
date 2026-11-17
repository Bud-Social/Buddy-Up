"""Engage on the home feed as the gym.

Mirrors the profile-scoped feed engagement endpoints, but the actor is the
gym itself: staff (owner/co-owner/moderator) press like/comment/repost and
the row is recorded with ``gym=gym`` while ``author/profile`` keeps the
aciting staff member for audit. Public renderers show the gym identity.

The console only exposes these to staff — an owner is not a moderation or
abuse role, and nothing here lets a gym react as a *person*.
"""

from django.db import transaction
from django.db.models import Count
from rest_framework import permissions, status, views
from rest_framework.response import Response

from apps.feed.models import Comment, Post, PostRepost, Reaction, Save
from apps.feed.serializers import CommentSerializer
from apps.gyms.insights_views import _partner_staff, _error, _json_response


def _public_post(post_id):
    return Post.objects.filter(
        id=post_id, visibility='public', moderation_status='clean',
    ).first()


def _gym_by_slug(gym_slug, request):
    from apps.gyms.models import Gym
    gym = Gym.objects.filter(handle__iexact=gym_slug).first()
    if gym is None or not _partner_staff(gym, request):
        return None
    return gym


def _counts(post):
    rows = (Reaction.objects.filter(post=post)
            .values('reaction_type')
            .annotate(c=Count('id')))
    out = {}
    for row in rows:
        out[row['reaction_type']] = row['c']
    return out


class GymReactView(views.APIView):
    """Toggle the gym's reaction on a feed post.

    Omitting ``reaction_type`` clears the gym's reaction. The response
    carries the fresh ``reaction_counts`` map and ``gym_reaction``.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = _gym_by_slug(gym_slug, request)
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        post_id = request.data.get('post_id')
        reaction_type = request.data.get('reaction_type')
        post = _public_post(post_id)
        if post is None:
            return _error('Post not found.', status.HTTP_404_NOT_FOUND)

        profile = request.user.profile
        reaction_type = str(reaction_type)[:20] if reaction_type else None
        with transaction.atomic():
            existing = Reaction.objects.filter(post=post, gym=gym).first()
            if existing and existing.reaction_type == reaction_type:
                # Same reaction twice — toggle off, like the personal endpoint.
                existing.delete()
                reaction_type = None
            else:
                Reaction.objects.filter(post=post, gym=gym).delete()
                if reaction_type:
                    Reaction.objects.create(post=post, author=profile, gym=gym, reaction_type=reaction_type)

        return _json_response({
            'reaction_counts': _counts(post),
            'gym_reaction': reaction_type,
            'post_id': str(post.id),
        })


class GymRepostView(views.APIView):
    """Toggle the gym's repost of a feed post (never creates a Post)."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = _gym_by_slug(gym_slug, request)
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        original = _public_post(request.data.get('post_id'))
        if original is None:
            return _error('Post not found.', status.HTTP_404_NOT_FOUND)
        quote_body = str(request.data.get('quote_body') or '')[:500]
        profile = request.user.profile

        with transaction.atomic():
            # The PostRepost table tolerates one row per (post, gym), which
            # may be a soft-delete from an earlier toggle — restore on toggle,
            # soft-delete on un-toggle. De-dupes the race-free toggle.
            existing = PostRepost.objects.filter(post=original, gym=gym).first()
            if existing and not existing.is_deleted:
                existing.soft_delete()
                action = 'unreposted'
            elif existing and existing.is_deleted:
                existing.is_deleted = False
                existing.deleted_at = None
                existing.quote_body = quote_body[:500]
                existing.save(update_fields=['is_deleted', 'deleted_at', 'quote_body', 'updated_at'])
                action = 'reposted'
            else:
                PostRepost.objects.create(
                    profile=profile,
                    post=original,
                    gym=gym,
                    quote_body=quote_body,
                )
                action = 'reposted'

        count = PostRepost.objects.filter(post=original, is_deleted=False).count()

        if action == 'reposted' and original.author_id != profile.pk:
            try:
                from apps.notifications.tasks import send_repost_notification
                send_repost_notification.delay(str(profile.user_id), str(original.id))
            except Exception:  # noqa: BLE001
                pass

        return Response({
            'success': True,
            'action': action,
            'repost_count': count,
            'gym_reposted': action == 'reposted',
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class GymSaveView(views.APIView):
    """Toggle the gym's save on a feed post (never a collection)."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = _gym_by_slug(gym_slug, request)
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        post_id = request.data.get('post_id')
        post = _public_post(post_id)
        if post is None:
            return _error('Post not found.', status.HTTP_404_NOT_FOUND)
        profile = request.user.profile
        with transaction.atomic():
            existing = Save.objects.filter(post=post, gym=gym).first()
            if existing:
                existing.delete()
                saved = False
            else:
                Save.objects.create(user=profile, post=post, gym=gym)
                saved = True
        return _json_response({
            'saved': saved,
            'post_id': str(post.id),
        })


class GymSavedView(views.APIView):
    """Posts the gym has saved, newest first, shaped for the console feed."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = _gym_by_slug(gym_slug, request)
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        post_ids = list(
            Save.objects.filter(gym=gym)
            .order_by('-created_at')
            .values_list('post_id', flat=True)[:50]
        )
        from apps.feed.serializers import PostSerializer
        posts = (
            Post.objects.filter(id__in=post_ids)
            .exclude(moderation_status='removed')
            .select_related('author', 'gym')
        )
        ordering = {pid: i for i, pid in enumerate(post_ids)}
        posts = sorted(posts, key=lambda p: ordering.get(p.id, len(post_ids)))
        serializer = PostSerializer(posts, many=True, context={'request': request})
        data = list(serializer.data)
        total = Save.objects.filter(gym=gym).count()
        return _json_response({'count': total, 'items': data})


class GymCommentView(views.APIView):
    """Comment on a feed post as the gym."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = _gym_by_slug(gym_slug, request)
        if gym is None:
            return _error('Not found.', status.HTTP_404_NOT_FOUND)
        body = str(request.data.get('body') or '').strip()
        if not body:
            return _error('body is required.', status.HTTP_400_BAD_REQUEST)
        post = _public_post(request.data.get('post_id'))
        if post is None:
            return _error('Post not found.', status.HTTP_404_NOT_FOUND)
        parent_id = request.data.get('parent_id')
        parent = None
        if parent_id:
            parent = (Comment.objects.filter(id=parent_id, post=post).first())
            if parent is None:
                return _error('Parent comment not found.', status.HTTP_404_NOT_FOUND)

        profile = request.user.profile
        comment = Comment.objects.create(
            post=post,
            author=profile,
            body=body[:2000],
            gym=gym,
            parent=parent,
        )
        serializer = CommentSerializer(comment, context={'request': request})
        return _json_response(serializer.data, status_code=status.HTTP_201_CREATED)
