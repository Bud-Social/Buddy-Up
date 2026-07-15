import os
import uuid

from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import Post, FeedPost, Comment, Reaction, Save, Poll, PollOption, PollVote, Draft
from .serializers import (
    PostSerializer, FeedPostSerializer, PostCreateSerializer, CommentSerializer,
    ReactionSerializer, SaveSerializer, PollSerializer, DraftSerializer,
    CommentCreateSerializer, ReactionInputSerializer, RepostSerializer,
    SavePostSerializer, PollCreateSerializer, OptionVoteSerializer,
)
from apps.profiles.models import BuddyRelationship


def _handle_media_uploads(request_files):
    """Save uploaded files to media storage and return list of public URLs."""
    urls = []
    for f in request_files:
        ext = os.path.splitext(f.name)[1].lower()
        filename = f'posts/{uuid.uuid4().hex}{ext}'
        saved_name = default_storage.save(filename, ContentFile(f.read()))
        url = default_storage.url(saved_name)
        urls.append(url)
    return urls


class FeedView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tab = request.query_params.get('tab', 'for_you')
        cursor = request.query_params.get('cursor')

        user_profile = request.user.profile

        if tab == 'following':
            followed_ids = user_profile.following.values_list('followee_id', flat=True)
            queryset = FeedPost.objects.filter(
                author_id__in=followed_ids,
                visibility='public',
                moderation_status='clean',
            ).select_related('author', 'gym_tag').order_by('-is_pinned', '-created_at')
        elif tab == 'nearby':
            queryset = FeedPost.objects.filter(
                visibility='public',
                moderation_status='clean',
            )
            if user_profile.location_city:
                queryset = queryset.filter(location_label__icontains=user_profile.location_city)
            queryset = queryset.select_related('author', 'gym_tag').order_by('-is_pinned', '-created_at')
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

            queryset = FeedPost.objects.filter(
                moderation_status='clean',
                visibility__in=['public'],
            ).select_related('author', 'gym_tag').annotate(
                rank=db_models.Case(
                    db_models.When(author_id__in=buddy_ids, then=db_models.Value(100)),
                    db_models.When(author_id__in=followed_ids, then=db_models.Value(50)),
                    db_models.When(gym_tag_id__in=gym_ids, then=db_models.Value(75)),
                    default=db_models.Value(10),
                ),
            ).order_by('-is_pinned', '-rank', '-created_at')

        count = queryset.count()
        paginator = CursorPagination()
        paginator.ordering = '-created_at'
        page = paginator.paginate_queryset(queryset, request)
        page_posts = list(page)

        reposted_original_ids = {p.original_post_id for p in page_posts if p.is_repost and p.original_post_id}
        deduped_posts = [p for p in page_posts if not (not p.is_repost and p.id in reposted_original_ids)]

        serializer = FeedPostSerializer(deduped_posts, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': len(deduped_posts),
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
        # Handle file uploads — build media_urls from uploaded files
        uploaded_files = request.FILES.getlist('media')
        media_urls = []
        if uploaded_files:
            try:
                media_urls = _handle_media_uploads(uploaded_files)
            except Exception:
                pass

        # Merge uploaded URLs with any pre-existing media_urls (e.g. from mobile)
        existing_urls = request.data.getlist('media_urls') or []
        all_media_urls = existing_urls + media_urls

        # Build mutable data dict
        data = request.data.dict() if hasattr(request.data, 'dict') else dict(request.data)
        data['media_urls'] = all_media_urls

        serializer = PostCreateSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        validated = serializer.validated_data
        validated['media_urls'] = all_media_urls

        post = Post.objects.create(
            author=request.user.profile,
            **validated,
        )

        # Handle poll creation
        poll_serializer = PollCreateSerializer(data=request.data)
        poll_serializer.is_valid(raise_exception=True)
        poll_data = poll_serializer.validated_data
        poll_question = poll_data.get('poll_question', '').strip()
        import json
        try:
            poll_options_raw = json.loads(poll_data.get('poll_options_json', '[]'))
        except Exception:
            poll_options_raw = request.data.getlist('poll_options')

        if poll_question and len(poll_options_raw) >= 2:
            closes_at = poll_data.get('poll_closes_at') or None
            allow_multiple = poll_data.get('poll_allow_multiple', False)
            poll = Poll.objects.create(
                post=post,
                question=poll_question,
                closes_at=closes_at,
                allow_multiple=allow_multiple,
            )
            for i, opt_text in enumerate(poll_options_raw[:10]):
                if opt_text.strip():
                    PollOption.objects.create(poll=poll, text=opt_text.strip(), order=i)

        # Handle @mentions — store and send notifications
        mentioned_user_ids = request.data.getlist('mentioned_users')
        if mentioned_user_ids:
            from apps.profiles.models import Profile
            profiles = Profile.objects.filter(user_id__in=mentioned_user_ids)
            post.mentioned_profiles.set(profiles)

            # Fire mention notifications asynchronously
            try:
                from .tasks import send_mention_notifications
                send_mention_notifications.delay(str(post.id), str(request.user.profile.user_id))
            except Exception:
                pass

        try:
            from .tasks import moderate_content
            moderate_content.delay(str(post.id))
        except Exception:
            pass

        output = PostSerializer(post, context={'request': request})
        return Response({
            'success': True,
            'data': output.data,
            'message': 'Post created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PollVoteView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id, post_type='poll')
        try:
            poll = post.poll
        except Poll.DoesNotExist:
            return Response({'success': False, 'message': 'Poll not found.'}, status=404)

        if poll.is_closed:
            return Response({'success': False, 'message': 'This poll has closed.'}, status=400)

        serializer = OptionVoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        option_ids = serializer.validated_data.get('option_ids', [])
        if not option_ids:
            option_id = serializer.validated_data.get('option_id')
            if option_id:
                option_ids = [option_id]

        if not option_ids:
            return Response({'success': False, 'message': 'No option selected.'}, status=400)

        if not poll.allow_multiple and len(option_ids) > 1:
            return Response({'success': False, 'message': 'This poll only allows one vote.'}, status=400)

        # Remove previous votes if not multi-select
        if not poll.allow_multiple:
            PollVote.objects.filter(poll=poll, voter=request.user.profile).delete()

        for option_id in option_ids:
            option = get_object_or_404(PollOption, id=option_id, poll=poll)
            PollVote.objects.get_or_create(poll=poll, option=option, voter=request.user.profile)

        serializer = PollSerializer(poll, context={'request': request})
        return Response({'success': True, 'data': serializer.data, 'message': 'Vote recorded.', 'errors': None, 'pagination': None})


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
        serializer = CommentCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        body = data['body'][:500]
        parent_id = data.get('parent_id')

        parent = None
        if parent_id:
            parent = get_object_or_404(Comment, id=parent_id, post_id=post_id)

        comment = Comment.objects.create(
            post=post,
            author=request.user.profile,
            body=body,
            parent=parent,
            is_anonymous=data.get('is_anonymous', False),
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
        serializer = ReactionInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reaction_type = serializer.validated_data['reaction_type']

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
        serializer = RepostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        quote_body = serializer.validated_data.get('quote_body', '')

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
        serializer = SavePostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        collection = serializer.validated_data.get('collection', '')
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
        ).exclude(moderation_status='removed').select_related('author').order_by('-created_at')

        count = posts.count()
        paginator = CursorPagination()
        page = paginator.paginate_queryset(posts, request)
        serializer = PostSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class PostPinView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        if post.gym_tag:
            from apps.gyms.models import GymMembership
            is_admin = GymMembership.objects.filter(
                gym=post.gym_tag, member=request.user.profile,
                role__in=['owner', 'co_owner', 'moderator']
            ).exists()
            if not is_admin and post.author != request.user.profile:
                return Response({'success': False, 'message': 'Not authorized to pin this post.'}, status=403)
        else:
            if post.author != request.user.profile:
                return Response({'success': False, 'message': 'Not authorized.'}, status=403)

        post.is_pinned = not post.is_pinned
        post.save(update_fields=['is_pinned'])
        return Response({'success': True, 'data': {'is_pinned': post.is_pinned}, 'message': 'Pin toggled.', 'errors': None, 'pagination': None})


class DraftListCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        drafts = Draft.objects.filter(author=request.user.profile).order_by('-updated_at')
        serializer = DraftSerializer(drafts, many=True)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request):
        data = request.data.copy() if hasattr(request.data, 'copy') else dict(request.data)
        data['author'] = request.user.profile.user_id

        existing_id = data.pop('id', None)
        if existing_id:
            try:
                draft = Draft.objects.get(id=existing_id, author=request.user.profile)
                serializer = DraftSerializer(draft, data=data, partial=True)
                serializer.is_valid(raise_exception=True)
                serializer.save()
                return Response({
                    'success': True, 'data': serializer.data,
                    'message': 'Draft updated.', 'errors': None, 'pagination': None,
                })
            except Draft.DoesNotExist:
                pass

        serializer = DraftSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(author=request.user.profile)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Draft saved.', 'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class DraftDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, draft_id, user_profile):
        return get_object_or_404(Draft, id=draft_id, author=user_profile)

    def delete(self, request, draft_id):
        draft = self.get_object(draft_id, request.user.profile)
        draft.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Draft deleted.', 'errors': None, 'pagination': None,
        })


class WorkoutAnalysisView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        import requests as http_requests
        profile = request.user.profile
        posts = Post.objects.filter(
            author=profile, post_type='workout_log',
            workout_log_data__isnull=False,
        ).order_by('created_at').values('workout_log_data', 'created_at')

        history = []
        for p in posts:
            entry = p['workout_log_data']
            if isinstance(entry, dict):
                entry['date'] = p['created_at'].isoformat()
                history.append({'workout_log_data': entry})

        if not history:
            return Response({
                'success': True, 'data': None,
                'message': 'No workout logs found.',
                'errors': None, 'pagination': None,
            })

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/workout/analyze'
        try:
            resp = http_requests.post(ai_url, json={'history': history}, timeout=30)
            resp.raise_for_status()
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Workout analysis complete.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            return Response({
                'success': False, 'data': None,
                'message': 'Workout analysis service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class HealthInsightsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        import requests as http_requests
        profile = request.user.profile
        period = request.query_params.get('period', 'weekly')

        cutoff = timezone.now() - timezone.timedelta(days=7 if period == 'weekly' else 30)
        workout_posts = Post.objects.filter(
            author=profile, post_type='workout_log',
            workout_log_data__isnull=False, created_at__gte=cutoff,
        ).order_by('created_at').values('workout_log_data', 'created_at')

        workouts = []
        for p in workout_posts:
            entry = dict(p['workout_log_data'])
            entry['date'] = p['created_at'].isoformat()
            workouts.append({'workout_log_data': entry})

        meal_posts = Post.objects.filter(
            author=profile, post_type='meal',
            meal_data__isnull=False, created_at__gte=cutoff,
        ).order_by('created_at').values('meal_data')

        meals = [{'meal_data': dict(m['meal_data'])} for m in meal_posts if m['meal_data']]

        streak = {
            'days': profile.streak_days,
            'longest_streak': profile.streak_days,
        }

        payload = {
            'workouts': workouts,
            'meals': meals,
            'streak': streak,
            'period': period,
        }

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/health-insights/analyze'
        try:
            resp = http_requests.post(ai_url, json=payload, timeout=30)
            resp.raise_for_status()
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Health insights generated.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            return Response({
                'success': False, 'data': None,
                'message': 'Health insights service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)


class WorkoutFormAnalysisView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        import requests as http_requests
        file = request.FILES.get('image')
        exercise = request.data.get('exercise', 'auto')

        if not file:
            return Response({
                'success': False, 'data': None,
                'message': 'No image provided.',
                'errors': 'image field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/form-analyzer/analyze'
        try:
            resp = http_requests.post(
                ai_url,
                files={'file': (file.name, file.read(), file.content_type)},
                data={'exercise': exercise},
                timeout=30,
            )
            resp.raise_for_status()
            return Response({
                'success': True, 'data': resp.json(),
                'message': 'Form analysis complete.',
                'errors': None, 'pagination': None,
            })
        except http_requests.RequestException as e:
            return Response({
                'success': False, 'data': None,
                'message': 'Form analysis service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
