from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from datetime import timedelta
from collections import Counter

from rest_framework import views, permissions, status, generics
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes

from common.pagination import CursorPagination, PageNumberPagination
from .models import Post, Comment, Reaction, Save
from .serializers import PostSerializer, PostCreateSerializer, CommentSerializer, ReactionSerializer, SaveSerializer
from apps.profiles.models import Profile, BuddyRelationship


class FeedView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tab = request.query_params.get('tab', 'for_you')
        cursor = request.query_params.get('cursor')

        user_profile = request.user.profile
        now = timezone.now()

        if tab == 'following':
            followed_ids = user_profile.following.values_list('followee_id', flat=True)
            queryset = Post.objects.filter(
                author_id__in=followed_ids,
                visibility='public',
                moderation_status='clean',
                post_type__ne='moment',
            ).select_related('author').order_by('-created_at')
        elif tab == 'nearby':
            queryset = Post.objects.filter(
                visibility='public',
                moderation_status='clean',
                post_type__ne='moment',
            )
            if user_profile.location_city:
                queryset = queryset.filter(location_label__icontains=user_profile.location_city)
            queryset = queryset.select_related('author').order_by('-created_at')
        else:  # for_you
            buddy_ids = set(
                BuddyRelationship.objects.filter(
                    (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
                    status='confirmed',
                ).values_list(
                    db_models.Case(db_models.When(from_user=user_profile, then='to_user_id'), default='from_user_id'),
                    flat=True,
                )
            )
            followed_ids = set(user_profile.following.values_list('followee_id', flat=True))
            gym_ids = set(user_profile.gym_memberships.filter(subscription_active=True).values_list('gym_id', flat=True))

            queryset = Post.objects.filter(
                moderation_status='clean',
                post_type__ne='moment',
                visibility__in=['public'],
            ).select_related('author').annotate(
                rank=db_models.Case(
                    db_models.When(author_id__in=buddy_ids, then=db_models.Value(100)),
                    db_models.When(author_id__in=followed_ids, then=db_models.Value(50)),
                    db_models.When(gym_tag_id__in=gym_ids, then=db_models.Value(75)),
                    default=db_models.Value(10),
                ),
            ).order_by('-rank', '-created_at')

        paginator = CursorPagination()
        paginator.ordering = '-created_at'
        page = paginator.paginate_queryset(queryset, request)
        serializer = PostSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class PostDetailView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)

        if post.moderation_status == 'removed':
            return Response({
                'success': False, 'data': None,
                'message': 'This post has been removed.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_410_GONE)

        if post.visibility == 'private' and (
            not request.user.is_authenticated or post.author_id != request.user.profile.user_id
        ):
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        if request.user.is_authenticated:
            post.view_count = db_models.F('view_count') + 1
            post.save(update_fields=['view_count'])
            post.refresh_from_db()

        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        post = get_object_or_404(Post, id=post_id)
        if post.author_id != request.user.profile.user_id:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only delete your own posts.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        post.soft_delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Post deleted.',
            'errors': None, 'pagination': None,
        })


class CreatePostView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PostCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        post = Post.objects.create(
            author=request.user.profile,
            **data,
        )

        from .tasks import moderate_content
        moderate_content.delay(str(post.id))

        output = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': output.data,
            'message': 'Post created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommentsView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        sort = request.query_params.get('sort', 'newest')

        comments = post.comments.filter(parent__isnull=True).select_related('author')
        if sort == 'oldest':
            comments = comments.order_by('created_at')
        elif sort == 'top':
            comments = sorted(comments, key=lambda c: c.reactions.count(), reverse=True)
        else:
            comments = comments.order_by('-created_at')

        serializer = CommentSerializer(comments, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def post(self, request, post_id):
        if not request.user.is_authenticated:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        post = get_object_or_404(Post, id=post_id)
        body = request.data.get('body', '')[:500]
        parent_id = request.data.get('parent_id')

        parent = None
        if parent_id:
            parent = get_object_or_404(Comment, id=parent_id, post_id=post_id)

        comment = Comment.objects.create(
            post=post,
            author=request.user.profile,
            body=body,
            parent=parent,
            is_anonymous=request.data.get('is_anonymous', False),
        )

        serializer = CommentSerializer(comment, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Comment added.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class CommentDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, post_id, comment_id):
        comment = get_object_or_404(Comment, id=comment_id, post_id=post_id)
        if comment.author_id != request.user.profile.user_id:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only delete your own comments.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        comment.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Comment deleted.',
            'errors': None, 'pagination': None,
        })


class ReactionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        reaction_type = request.data.get('reaction_type')
        if reaction_type not in dict(Reaction.REACTION_CHOICES):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid reaction type.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        Reaction.objects.update_or_create(
            post_id=post_id,
            author=request.user.profile,
            defaults={'reaction_type': reaction_type, 'comment': None},
        )

        post = get_object_or_404(Post, id=post_id)
        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data.get('reaction_counts', {}),
            'message': 'Reaction saved.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, post_id):
        Reaction.objects.filter(
            post_id=post_id,
            author=request.user.profile,
        ).delete()

        post = get_object_or_404(Post, id=post_id)
        serializer = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': {},
            'message': 'Reaction removed.',
            'errors': None,
            'pagination': None,
        })


class RepostView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        original = get_object_or_404(Post, id=post_id, visibility='public', moderation_status='clean')
        quote_body = request.data.get('quote_body', '')

        repost = Post.objects.create(
            author=request.user.profile,
            post_type='text',
            body='',
            is_repost=True,
            original_post=original,
            quote_body=quote_body[:500],
            visibility='public',
        )

        serializer = PostSerializer(repost, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Reposted.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class SaveView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        collection = request.data.get('collection', '')
        Save.objects.get_or_create(
            user=request.user.profile,
            post_id=post_id,
            defaults={'collection': collection},
        )
        return Response({
            'success': True, 'data': None,
            'message': 'Post saved.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, post_id):
        Save.objects.filter(user=request.user.profile, post_id=post_id).delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Post unsaved.',
            'errors': None, 'pagination': None,
        })


class SavedPostsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        collection = request.query_params.get('collection')
        saves = Save.objects.filter(user=request.user.profile).select_related('post__author')
        if collection:
            saves = saves.filter(collection=collection)

        post_ids = saves.values_list('post_id', flat=True)
        posts = Post.objects.filter(
            id__in=post_ids,
            moderation_status__ne='removed',
        ).select_related('author').order_by('-created_at')

        paginator = CursorPagination()
        page = paginator.paginate_queryset(posts, request)
        serializer = PostSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })
