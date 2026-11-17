"""Engage with community posts as the gym.

Mirrors the main feed's gym-actor engagement for the community surface:
staff press like/react/repost/save/comment and the row is tagged with
``gym=gym`` while ``profile/author`` carries the acting staff member for
audit. Public renderers surface the gym identity.

Access mirrors personal community engagement: gym can act on any public
community, or any community the gym has linked (active ``GymCommunityLink``).
"""

from django.db import transaction
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status, views

from apps.gyms.insights_views import _error, _json_response, _partner_staff
from apps.gyms.models import Gym, GymCommunityLink
from apps.messaging.models import (
    CommunityPost,
    CommunityPostLike,
    CommunityPostRepost,
    CommunityPostSave,
    CommunityPostReaction,
    CommunityPostComment,
    CommunityPostCommentLike,
    Conversation,
)
from apps.messaging.serializers import CommunityPostCommentSerializer, _staffed_gym_ids


def _gym_and_conversation(slug, request, conversation_id):
    """Return (gym, conversation) or (None, response_error)."""
    gym = Gym.objects.filter(handle__iexact=slug).first()
    if gym is None or not _partner_staff(gym, request):
        return None, _error('Not found.', status.HTTP_404_NOT_FOUND)
    conv = Conversation.objects.filter(id=conversation_id, is_community=True).first()
    if conv is None:
        return None, _error('Not found.', status.HTTP_404_NOT_FOUND)
    if not conv.is_public and not GymCommunityLink.objects.filter(
        gym=gym, community_id=conv.id, status='active',
    ).exists():
        return None, _error(
            'Gym is not a member of this community.', status.HTTP_403_FORBIDDEN,
        )
    return gym, conv


def _notify(post, actor_profile, gym, body):
    """Mirror the personal community notification fan-out for the gym actor."""
    if post.author_id == actor_profile.user_id:
        return
    try:
        from apps.messaging.views import _push_community_notification
        _push_community_notification(
            post.author.user_id, 'community_reaction',
            f'{gym.name} reacted to your post', body[:100],
            {'community_id': str(post.conversation_id), 'post_id': str(post.id)},
        )
    except Exception:  # noqa: BLE001
        # Notification fan-out is best-effort; never fail an engagement write.
        pass


class GymCommunityReactView(views.APIView):
    """Toggle the gym's reaction/like on a community post.

    ``reaction_type`` ``like`` writes a CommunityPostLike row (and manages the
    post's ``like_count``). Any other reaction type toggles a row in
    CommunityPostReaction. The acting member stays on the row as audit trail.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, conversation_id, post_id):
        gym, conv = _gym_and_conversation(gym_slug, request, conversation_id)
        if gym is None:
            return conv  # already an error response
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)
        reaction_type = (request.data.get('reaction_type') or 'fire').strip().lower()

        with transaction.atomic():
            if reaction_type == 'like':
                existing = CommunityPostLike.objects.filter(post=post, gym=gym).first()
                if existing:
                    existing.delete()
                    gym_likes = False
                    post.like_count = max(0, post.like_count - 1)
                else:
                    CommunityPostLike.objects.create(post=post, profile=request.user.profile, gym=gym)
                    gym_likes = True
                    post.like_count += 1
                post.save(update_fields=['like_count', 'updated_at'])
                _notify(post, request.user.profile, gym, post.body or '')
                return _json_response({
                    'reaction_type': 'like',
                    'is_reacted': gym_likes,
                    'is_liked': gym_likes,
                    'like_count': post.like_count,
                })
            existing = CommunityPostReaction.objects.filter(
                post=post, gym=gym, reaction_type=reaction_type,
            ).first()
            if existing:
                existing.delete()
                gym_reacted = False
            else:
                CommunityPostReaction.objects.create(
                    post=post, profile=request.user.profile, gym=gym,
                    reaction_type=reaction_type,
                )
                gym_reacted = True
                _notify(post, request.user.profile, gym, post.body or '')
            return _json_response({
                'reaction_type': reaction_type,
                'is_reacted': gym_reacted,
            })


class GymCommunityRepostView(views.APIView):
    """Toggle the gym's repost of a community post."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, conversation_id, post_id):
        gym, conv = _gym_and_conversation(gym_slug, request, conversation_id)
        if gym is None:
            return conv
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)

        with transaction.atomic():
            existing = CommunityPostRepost.objects.filter(post=post, gym=gym).first()
            if existing:
                existing.delete()
                post.repost_count = max(0, post.repost_count - 1)
                reposted = False
            else:
                CommunityPostRepost.objects.create(post=post, profile=request.user.profile, gym=gym)
                post.repost_count += 1
                reposted = True
            post.save(update_fields=['repost_count', 'updated_at'])

        if reposted:
            _notify(post, request.user.profile, gym, post.body or '')

        return _json_response({'reposted': reposted, 'repost_count': post.repost_count})


class GymCommunitySaveView(views.APIView):
    """Toggle the gym's save on a community post."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, conversation_id, post_id):
        gym, conv = _gym_and_conversation(gym_slug, request, conversation_id)
        if gym is None:
            return conv
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)

        with transaction.atomic():
            existing = CommunityPostSave.objects.filter(post=post, gym=gym).first()
            if existing:
                existing.delete()
                post.save_count = max(0, post.save_count - 1)
                saved = False
            else:
                CommunityPostSave.objects.create(post=post, profile=request.user.profile, gym=gym)
                post.save_count += 1
                saved = True
            post.save(update_fields=['save_count', 'updated_at'])

        return _json_response({'saved': saved, 'save_count': post.save_count})


class GymCommunityCommentLikeView(views.APIView):
    """Toggle the gym's like on a community post comment."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, conversation_id, post_id, comment_id):
        gym, conv = _gym_and_conversation(gym_slug, request, conversation_id)
        if gym is None:
            return conv
        post = get_object_or_404(CommunityPost, id=post_id, conversation=conv)
        comment = get_object_or_404(CommunityPostComment, id=comment_id, post=post)
        profile = request.user.profile

        from django.db.models import Q
        with transaction.atomic():
            existing = CommunityPostCommentLike.objects.filter(comment=comment, gym=gym).first()
            if existing:
                existing.delete()
            else:
                CommunityPostCommentLike.objects.create(comment=comment, profile=profile, gym=gym)

        like_count = comment.likes.count()
        # Gym-aware: the viewer's staffed-gym likes count as their reaction too.
        gym_ids = _staffed_gym_ids(profile)
        staffed_liked = comment.likes.filter(Q(profile=profile) | Q(gym_id__in=gym_ids)).exists()
        return _json_response({
            'is_liked': staffed_liked,
            'like_count': like_count,
            'reaction_counts': {'❤️': like_count} if like_count else {},
            'user_reaction': '❤️' if staffed_liked else None,
        })


class GymCommunityCommentView(views.APIView):
    """List or create comments on a community post as the gym."""
    permission_classes = [permissions.IsAuthenticated]

    def _post(self, request, gym_slug, conversation_id, post_id):
        gym, conv = _gym_and_conversation(gym_slug, request, conversation_id)
        if gym is None:
            return None, conv
        return get_object_or_404(CommunityPost, id=post_id, conversation=conv), None

    def get(self, request, gym_slug, conversation_id, post_id):
        post, err = self._post(request, gym_slug, conversation_id, post_id)
        if err is not None:
            return err
        serializer = CommunityPostCommentSerializer(
            post.comments.select_related('author').prefetch_related('replies').order_by('created_at'),
            many=True, context={'request': request},
        )
        return _json_response(serializer.data)

    def post(self, request, gym_slug, conversation_id, post_id):
        post, err = self._post(request, gym_slug, conversation_id, post_id)
        if err is not None:
            return err
        body = (request.data.get('body') or '').strip()
        if not body:
            return _error('Comment body required.', status.HTTP_400_BAD_REQUEST)
        from apps.gyms.insights_views import _coerce_uuid
        reply_to_id = _coerce_uuid(request.data.get('reply_to_id'))
        if reply_to_id and not post.comments.filter(id=reply_to_id).exists():
            return _error('Invalid reply target.', status.HTTP_400_BAD_REQUEST)
        gym = Gym.objects.filter(handle__iexact=gym_slug).first()
        comment = CommunityPostComment.objects.create(
            post=post, author=request.user.profile, body=body[:2000],
            gym=gym, reply_to_id=reply_to_id,
        )
        post.comment_count = post.comment_count + 1
        post.save(update_fields=['comment_count', 'updated_at'])
        _notify(post, request.user.profile, gym, body)
        serializer = CommunityPostCommentSerializer(comment, context={'request': request})
        return _json_response(serializer.data, status_code=status.HTTP_201_CREATED)
