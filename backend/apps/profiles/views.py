
from django.shortcuts import get_object_or_404
from django.conf import settings
from django.db import models as db_models
from django.utils import timezone
from django.db.models import Q
from django.contrib.postgres.search import SearchVector, SearchQuery
from rest_framework import views, permissions, status, generics
from rest_framework.response import Response

from .models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship, AccountabilityPing
from .buddy_notifications import notify_buddy_request, notify_buddy_accepted, notify_follow
from .serializers import (
    ProfileSerializer, ProfileUpdateSerializer, OnboardingSerializer,
    PingMessageSerializer,
)
from common.pagination import CursorPagination, PageNumberPagination
from common.age_gating import gate_mature_queryset, request_can_access_mature, can_view_content


class MyProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user.profile

    def get_serializer_class(self):
        if self.request.method in ('PUT', 'PATCH'):
            return ProfileUpdateSerializer
        return ProfileSerializer

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def partial_update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'success': True,
            'data': ProfileSerializer(instance, context={'request': request}).data,
            'message': 'Profile updated',
            'errors': None,
            'pagination': None,
        })

class UserProfileView(generics.RetrieveAPIView):
    permission_classes = [permissions.AllowAny]
    lookup_field = 'username'
    lookup_url_kwarg = 'username'
    queryset = Profile.objects.all()

    def get_serializer_class(self):
        return ProfileSerializer

    def retrieve(self, request, *args, **kwargs):
        profile = get_object_or_404(Profile, username=self.kwargs['username'])

        blocked = BlockRelationship.objects.filter(
            (Q(blocker=profile) & Q(blocked=request.user.profile if request.user.is_authenticated else None)) |
            (Q(blocker=request.user.profile if request.user.is_authenticated else None) & Q(blocked=profile))
        ).exists() if request.user.is_authenticated else False

        if blocked:
            return Response({
                'success': False, 'data': None,
                'message': 'Profile not available.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        if profile.privacy_level == 'private' and (
            not request.user.is_authenticated or
            not BuddyRelationship.objects.filter(
                (Q(from_user=request.user.profile, to_user=profile) |
                 Q(from_user=profile, to_user=request.user.profile)),
                status='confirmed'
            ).exists()
        ):
            return Response({
                'success': True,
                'data': {
                    'username': profile.username,
                    'display_name': profile.display_name,
                    'avatar_url': profile.avatar_url,
                    'verification_status': profile.verification_status,
                    'privacy_level': 'private',
                },
                'message': 'This profile is private.',
                'errors': None,
                'pagination': None,
            })

        if profile != (request.user.profile if request.user.is_authenticated else None) and not can_view_content(request, profile):
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(profile, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class OnboardingView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    CURRENT_TERMS_VERSION = '2026-08-v1'

    def post(self, request):
        serializer = OnboardingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = dict(serializer.validated_data)

        terms_version = data.pop('terms_version', '')
        marketing_consent = data.pop('marketing_consent', False)

        profile = request.user.profile
        user = request.user

        # Profile essentials (validated above); username uniqueness enforced by DB.
        for field in ('display_name', 'username', 'location_city', 'bio'):
            if field in data:
                setattr(profile, field, data[field])
        try:
            profile.save(update_fields=[
                f for f in ('display_name', 'username', 'location_city', 'bio') if f in data
            ] or None)
        except Exception:
            return Response({
                'success': False, 'data': None,
                'message': 'That username is already taken.',
                'errors': {'username': ['Already taken.']}, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        user.preferences = {k: v for k, v in data.items() if k not in ('display_name', 'username', 'location_city', 'bio')}
        user.save(update_fields=['preferences'])

        from django.utils import timezone
        profile.terms_version = terms_version
        profile.terms_accepted_at = timezone.now()
        profile.marketing_consent = bool(marketing_consent)
        profile.onboarding_completed = True
        profile.save(update_fields=[
            'terms_version', 'terms_accepted_at', 'marketing_consent', 'onboarding_completed',
        ])

        onboarding_plan = None
        import requests as http_requests
        try:
            ai_url = f'{settings.AI_SERVICE_URL}/api/v1/onboarding/personalise'
            resp = http_requests.post(ai_url, json=data, timeout=15)
            resp.raise_for_status()
            onboarding_plan = resp.json()
        except Exception:  # noqa: BLE001 — plan is best-effort; never block entry
            pass

        return Response({
            'success': True,
            'data': {
                'profile': ProfileSerializer(profile, context={'request': request}).data,
                'onboarding_plan': onboarding_plan,
            },
            'message': 'Onboarding complete. Welcome to BuddyUp!',
            'errors': None,
            'pagination': None,
        })


MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10 MB
ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.webp'}


def _validate_image_file(file):
    if not file:
        return 'No file provided.'

    if file.size > MAX_UPLOAD_SIZE:
        return f'File size exceeds {MAX_UPLOAD_SIZE // (1024*1024)} MB limit.'

    import os
    ext = os.path.splitext(file.name)[1].lower()
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        return f'File type "{ext}" is not supported. Allowed: {", ".join(sorted(ALLOWED_IMAGE_EXTENSIONS))}.'

    try:
        from PIL import Image
        from io import BytesIO
        Image.open(BytesIO(file.read()))
        file.seek(0)
    except Exception:  # noqa: BLE001
        return 'File is not a valid image or is corrupted.'

    return None


class AvatarUploadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        file = request.FILES.get('avatar')
        error = _validate_image_file(file)
        if error:
            return Response({
                'success': False, 'data': None,
                'message': error,
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        import os
        import uuid
        from django.core.files.storage import default_storage
        from django.core.files.base import ContentFile
        ext = os.path.splitext(file.name)[1].lower() or '.jpg'
        # Unique key per upload: identical URLs across uploads make browsers
        # serve a stale cached avatar (the 'success but no change' bug).
        filename = f'avatars/{request.user.profile.user_id}_{uuid.uuid4().hex[:8]}{ext}'
        saved_name = default_storage.save(filename, ContentFile(file.read()))
        url = request.build_absolute_uri(default_storage.url(saved_name))

        request.user.profile.avatar_url = url
        request.user.profile.save(update_fields=['avatar_url'])

        return Response({
            'success': True,
            'data': {'avatar_url': url},
            'message': 'Avatar updated.',
            'errors': None,
            'pagination': None,
        }, headers={'Cache-Control': 'no-store'})


class CoverUploadView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        file = request.FILES.get('cover')
        error = _validate_image_file(file)
        if error:
            return Response({
                'success': False, 'data': None,
                'message': error,
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        import os
        from django.core.files.storage import default_storage
        from django.core.files.base import ContentFile
        ext = os.path.splitext(file.name)[1].lower() or '.jpg'
        filename = f'covers/{request.user.profile.user_id}{ext}'
        saved_name = default_storage.save(filename, ContentFile(file.read()))
        url = default_storage.url(saved_name)

        request.user.profile.cover_url = url
        request.user.profile.save(update_fields=['cover_url'])

        return Response({
            'success': True,
            'data': {'cover_url': url},
            'message': 'Cover updated.',
            'errors': None,
            'pagination': None,
        })


class SendBuddyRequestView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)

        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot send a buddy request to yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        blocked = BlockRelationship.objects.filter(
            (Q(blocker=request.user.profile, blocked=target) |
             Q(blocker=target, blocked=request.user.profile))
        ).exists()
        if blocked:
            return Response({
                'success': False, 'data': None,
                'message': 'Unable to send buddy request.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        existing = BuddyRelationship.objects.filter(
            (Q(from_user=request.user.profile, to_user=target) |
             Q(from_user=target, to_user=request.user.profile))
        ).first()

        if existing:
            if existing.status == 'confirmed':
                return Response({
                    'success': False, 'data': None,
                    'message': 'You are already buddies.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if existing.status == 'pending':
                if existing.from_user == request.user.profile:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'Buddy request already sent.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                existing.status = 'confirmed'
                existing.save(update_fields=['status'])
                notify_buddy_accepted(str(request.user.profile.user_id), str(target.user_id))
                return Response({
                    'success': True, 'data': {'status': 'confirmed'},
                    'message': f'You and @{target.username} are now BuddyUp Buddies! 🎉',
                    'errors': None, 'pagination': None,
                })

        BuddyRelationship.objects.create(
            from_user=request.user.profile,
            to_user=target,
            status='pending',
        )

        notify_buddy_request(str(request.user.profile.user_id), str(target.user_id))

        return Response({
            'success': True, 'data': {'status': 'pending'},
            'message': f'Buddy request sent to @{target.username}.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, username):
        target = get_object_or_404(Profile, username=username)
        BuddyRelationship.objects.filter(
            (Q(from_user=request.user.profile, to_user=target) |
             Q(from_user=target, to_user=request.user.profile))
        ).delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Buddy removed.',
            'errors': None, 'pagination': None,
        })


class AcceptBuddyRequestView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        buddy_req = get_object_or_404(
            BuddyRelationship,
            from_user=target,
            to_user=request.user.profile,
            status='pending',
        )
        buddy_req.status = 'confirmed'
        buddy_req.save(update_fields=['status'])

        notify_buddy_accepted(str(target.user_id), str(request.user.profile.user_id))

        return Response({
            'success': True, 'data': {'status': 'confirmed'},
            'message': f'You and @{target.username} are now BuddyUp Buddies! 🎉',
            'errors': None, 'pagination': None,
        })


class DeclineBuddyRequestView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        buddy_req = get_object_or_404(
            BuddyRelationship,
            from_user=target,
            to_user=request.user.profile,
            status='pending',
        )
        buddy_req.status = 'declined'
        buddy_req.save(update_fields=['status'])

        return Response({
            'success': True, 'data': None,
            'message': 'Buddy request declined.',
            'errors': None, 'pagination': None,
        })


class FollowUserView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot follow yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        FollowRelationship.objects.get_or_create(
            follower=request.user.profile,
            followee=target,
        )
        notify_follow(str(request.user.profile.user_id), str(target.user_id))
        return Response({
            'success': True, 'data': None,
            'message': f'Now following @{target.username}.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, username):
        target = get_object_or_404(Profile, username=username)
        FollowRelationship.objects.filter(
            follower=request.user.profile,
            followee=target,
        ).delete()
        return Response({
            'success': True, 'data': None,
            'message': f'Unfollowed @{target.username}.',
            'errors': None, 'pagination': None,
        })


class BlockUserView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        if target == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot block yourself.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        BlockRelationship.objects.get_or_create(
            blocker=request.user.profile,
            blocked=target,
        )
        BuddyRelationship.objects.filter(
            (Q(from_user=request.user.profile, to_user=target) |
             Q(from_user=target, to_user=request.user.profile))
        ).delete()
        FollowRelationship.objects.filter(
            (Q(follower=request.user.profile, followee=target) |
             Q(follower=target, followee=request.user.profile))
        ).delete()

        return Response({
            'success': True, 'data': None,
            'message': f'@ {target.username} blocked.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, username):
        target = get_object_or_404(Profile, username=username)
        BlockRelationship.objects.filter(
            blocker=request.user.profile,
            blocked=target,
        ).delete()
        return Response({
            'success': True, 'data': None,
            'message': f'@ {target.username} unblocked.',
            'errors': None, 'pagination': None,
        })


class BuddiesListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ProfileSerializer
    pagination_class = CursorPagination

    def get_queryset(self):
        profile = get_object_or_404(Profile, username=self.kwargs['username'])
        buddy_ids = BuddyRelationship.objects.filter(
            (db_models.Q(from_user=profile) | db_models.Q(to_user=profile)),
            status='confirmed',
        ).values_list(
            db_models.Case(
                db_models.When(from_user=profile, then='to_user_id'),
                default='from_user_id',
            ), flat=True
        )
        return Profile.objects.filter(user_id__in=buddy_ids).order_by('username')


class FollowersListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ProfileSerializer
    pagination_class = CursorPagination

    def get_queryset(self):
        profile = get_object_or_404(Profile, username=self.kwargs['username'])
        follower_ids = FollowRelationship.objects.filter(
            followee=profile
        ).values_list('follower_id', flat=True)
        return Profile.objects.filter(user_id__in=follower_ids).order_by('username')


class FollowingListView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ProfileSerializer
    pagination_class = CursorPagination

    def get_queryset(self):
        profile = get_object_or_404(Profile, username=self.kwargs['username'])
        followee_ids = FollowRelationship.objects.filter(
            follower=profile
        ).values_list('followee_id', flat=True)
        return Profile.objects.filter(user_id__in=followee_ids).order_by('username')


class BlockedUsersView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        blocked_ids = BlockRelationship.objects.filter(
            blocker=request.user.profile
        ).values_list('blocked_id', flat=True)
        blocked = Profile.objects.filter(user_id__in=blocked_ids)
        serializer = ProfileSerializer(blocked, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ProfileSearchView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = PageNumberPagination

    def get(self, request):
        q = request.query_params.get('q', '')
        role = request.query_params.get('role', '')
        location = request.query_params.get('location', '')

        queryset = Profile.objects.filter(privacy_level='public')

        if q:
            from django.db import connection
            if connection.vendor == 'postgresql':
                queryset = queryset.annotate(
                    search=SearchVector('username', 'display_name', 'bio'),
                ).filter(
                    search=SearchQuery(q)
                )
            else:
                queryset = queryset.filter(
                    Q(username__icontains=q) |
                    Q(display_name__icontains=q) |
                    Q(bio__icontains=q)
                )
        if role:
            queryset = queryset.filter(role=role)
        if location:
            queryset = queryset.filter(
                location_city__icontains=location,
            ) | queryset.filter(location_country__icontains=location)

        queryset = gate_mature_queryset(request, queryset)
        paginator = self.pagination_class()
        page = paginator.paginate_queryset(queryset, request)
        serializer = ProfileSerializer(page, many=True, context={'request': request})

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


class PendingBuddyRequestsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from .serializers import ProfileSerializer
        pending = BuddyRelationship.objects.filter(
            to_user=request.user.profile,
            status='pending',
        ).select_related('from_user')
        profiles = [br.from_user for br in pending]
        serializer = ProfileSerializer(profiles, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class BuddySearchView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        q = request.query_params.get('q', '')
        from .serializers import ProfileSerializer

        user_profile = request.user.profile
        confirmed_buddies = BuddyRelationship.objects.filter(
            (db_models.Q(from_user=user_profile) | db_models.Q(to_user=user_profile)),
            status='confirmed',
        ).values_list(
            db_models.Case(db_models.When(from_user=user_profile, then='to_user_id'), default='from_user_id'),
            flat=True,
        )

        queryset = Profile.objects.filter(
            user_id__in=confirmed_buddies,
        )

        if q:
            queryset = queryset.filter(
                db_models.Q(username__icontains=q) | db_models.Q(display_name__icontains=q),
            )

        serializer = ProfileSerializer(queryset, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class SendPingView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        target = get_object_or_404(Profile, username=username)
        user_profile = request.user.profile

        is_buddy = BuddyRelationship.objects.filter(
            (db_models.Q(from_user=user_profile, to_user=target) |
             db_models.Q(from_user=target, to_user=user_profile)),
            status='confirmed',
        ).exists()

        if not is_buddy:
            return Response({
                'success': False, 'data': None,
                'message': 'You must be buddies to send a ping.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        today_pings = AccountabilityPing.objects.filter(
            from_user=user_profile,
            to_user=target,
            created_at__date=timezone.now().date(),
        ).count()

        if today_pings >= 1:
            return Response({
                'success': False, 'data': None,
                'message': 'You can only send 1 accountability ping per buddy per day.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_429_TOO_MANY_REQUESTS)

        input_serializer = PingMessageSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        ping = AccountabilityPing.objects.create(
            from_user=user_profile,
            to_user=target,
            message=input_serializer.validated_data.get('message', "How's your workout going? 💪")[:100],
        )

        from apps.notifications.tasks import create_notification
        create_notification.delay(
            str(target.user_id),
            'accountability_ping',
            f'{user_profile.display_name} pinged you! 💪',
            ping.message[:100],
            {
                'from_user_id': str(user_profile.user_id),
                'from_username': user_profile.username,
                'ping_id': str(ping.id),
            },
        )

        return Response({
            'success': True,
            'data': {'ping_id': str(ping.id)},
            'message': f'Ping sent to @{target.username}!',
            'errors': None,
            'pagination': None,
        })


class ProfileRecommendationsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _base_qs(self, profile):
        exclude_ids = {str(profile.user_id)}
        buddy_rel = BuddyRelationship.objects.filter(
            db_models.Q(from_user=profile) | db_models.Q(to_user=profile),
        )
        exclude_ids.update((str(pid) for pid in buddy_rel.values_list('from_user_id', flat=True)))
        exclude_ids.update((str(pid) for pid in buddy_rel.values_list('to_user_id', flat=True)))
        block_rel = BlockRelationship.objects.filter(
            db_models.Q(blocker=profile) | db_models.Q(blocked=profile),
        )
        exclude_ids.update((str(pid) for pid in block_rel.values_list('blocker_id', flat=True)))
        exclude_ids.update((str(pid) for pid in block_rel.values_list('blocked_id', flat=True)))
        return Profile.objects.filter(privacy_level='public').exclude(pk__in=list(exclude_ids))

    def get(self, request):
        import requests as http_requests
        profile = request.user.profile
        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/embeddings/match'
        matches = []
        try:
            resp = http_requests.post(
                ai_url,
                json={'profile_id': str(profile.user_id), 'top_k': 20},
                timeout=15,
            )
            resp.raise_for_status()
            matches = resp.json().get('matches', [])
        except Exception:  # noqa: BLE001
            matches = []

        base_qs = self._base_qs(profile)

        def _interleave(profiles):
            groups = {'trainer': [], 'practitioner': [], 'regular': []}
            for p in profiles:
                key = p.verification_status if p.verification_status in groups else 'regular'
                groups[key].append(p)
            result = []
            while any(groups.values()):
                for key in ('trainer', 'practitioner', 'regular'):
                    if groups[key]:
                        result.append(groups[key].pop(0))
            return result

        if not matches:
            # AI unavailable — fall back to a popularity-ranked browse so the
            # Discover page can still surface recommended users automatically.
            # Interleave regular users with practitioners and trainers for a mix.
            from django.db.models import Count
            popular = list(
                base_qs.annotate(
                    follower_total=Count('followers', distinct=True),
                    post_total=Count('posts', distinct=True),
                ).order_by('-follower_total', '-post_total')[:60]
            )
            popular = _interleave(popular)[:20]
            return Response({
                'success': True,
                'data': [
                    {'profile': ProfileSerializer(p, context={'request': request}).data, 'match_score': None}
                    for p in popular
                ],
                'message': 'OK',
                'errors': None,
                'pagination': None,
            })

        matched_ids = [m['profile_id'] for m in matches]

        profiles_qs = base_qs.filter(pk__in=matched_ids).select_related('user')

        profile_map = {str(p.user_id): p for p in profiles_qs}
        ordered_profiles = [
            profile_map[m['profile_id']]
            for m in matches
            if m['profile_id'] in profile_map
        ]
        ordered_profiles = _interleave(ordered_profiles)

        return Response({
            'success': True,
            'data': [
                {'profile': ProfileSerializer(p, context={'request': request}).data, 'match_score': None}
                for p in ordered_profiles
            ],
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class DiscoverTrendingView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from django.db.models import Count
        from apps.feed.models import FeedPost
        from apps.feed.serializers import FeedPostSerializer
        from apps.marketplace.models import DiscountCode, MarketplaceEvent
        from apps.marketplace.serializers import DiscountCodeSerializer, MarketplaceEventSerializer
        from apps.messaging.serializers import ConversationSerializer

        mature_allowed = request_can_access_mature(request)

        now = timezone.now()
        since = now - timezone.timedelta(days=7)

        # Trending hashtags aggregated from recent posts' tags.
        tag_counts = {}
        recent_tags = FeedPost.objects.filter(
            created_at__gte=since,
            moderation_status='clean',
        ).exclude(
            db_models.Q(tags=[]) | db_models.Q(tags__isnull=True),
        )
        if not mature_allowed:
            recent_tags = recent_tags.exclude(content_rating='mature')
        recent_tags = recent_tags.values_list('tags', flat=True)[:1000]
        for tags in recent_tags:
            for tag in (tags or []):
                t = str(tag).lower().lstrip('#')
                if t:
                    tag_counts[t] = tag_counts.get(t, 0) + 1
        trending_hashtags = [
            {'tag': tag, 'count': count}
            for tag, count in sorted(tag_counts.items(), key=lambda kv: kv[1], reverse=True)[:10]
        ]

        # Trending posts ranked by engagement.
        trending_posts_qs = FeedPost.objects.filter(
            created_at__gte=since,
            moderation_status='clean',
            visibility='public',
        )
        if not mature_allowed:
            trending_posts_qs = trending_posts_qs.exclude(content_rating='mature')
        trending_posts_qs = trending_posts_qs.select_related('author', 'gym_tag').annotate(
            engagement=(
                Count('reactions', distinct=True)
                + Count('comments', distinct=True)
                + Count('reposts', distinct=True)
                + db_models.F('view_count')
            ),
        ).order_by('-engagement', '-created_at')[:10]
        trending_posts = FeedPostSerializer(trending_posts_qs, many=True, context={'request': request}).data

        # Trending offers: most-used active discount codes + free upcoming events.
        trending_offers = []
        active_codes = DiscountCode.objects.filter(
            is_active=True,
            is_retired=False,
        ).filter(
            db_models.Q(valid_until__isnull=True) | db_models.Q(valid_until__gte=now),
        ).select_related('creator').order_by('-times_used', '-share_count')[:5]
        for code in active_codes:
            trending_offers.append({
                'type': 'discount_code',
                'data': DiscountCodeSerializer(code, context={'request': request}).data,
            })

        free_events = MarketplaceEvent.objects.filter(
            is_free=True,
            is_published=True,
            is_draft=False,
            is_cancelled=False,
            start_datetime__gte=now,
        )
        if not mature_allowed:
            free_events = free_events.exclude(content_rating='mature')
        free_events = free_events.select_related('creator').order_by('-attendee_count', 'start_datetime')[:5]
        for event in free_events:
            trending_offers.append({
                'type': 'free_event',
                'data': MarketplaceEventSerializer(event, context={'request': request}).data,
            })

        # Trending discussions: posts with the most comments in the window.
        discussions_qs = FeedPost.objects.filter(
            created_at__gte=since,
            moderation_status='clean',
            visibility='public',
        )
        if not mature_allowed:
            discussions_qs = discussions_qs.exclude(content_rating='mature')
        trending_discussions = FeedPostSerializer(
            discussions_qs.select_related('author', 'gym_tag')
            .annotate(comment_total=Count('comments', distinct=True))
            .filter(comment_total__gt=0)
            .order_by('-comment_total', '-created_at')[:8],
            many=True,
            context={'request': request},
        ).data

        # Trending communities by recent public post activity.
        from apps.messaging.models import Conversation
        trending_communities = Conversation.objects.filter(
            is_community=True, is_public=True, is_deleted=False,
        ).annotate(
            recent_posts=Count('community_posts', distinct=True),
        ).order_by('-recent_posts', '-last_message_at')[:8]
        communities_data = ConversationSerializer(trending_communities, many=True, context={'request': request}).data

        # Upcoming lives (public).
        from apps.lives.models import BuddyLive
        upcoming_lives = BuddyLive.objects.filter(
            status__in=('scheduled', 'live'),
        ).exclude(content_rating='mature') if hasattr(BuddyLive, 'content_rating') else             BuddyLive.objects.filter(status__in=('scheduled', 'live'))
        lives_data = []
        try:
            from apps.lives.serializers import BuddyLiveSerializer
            upcoming_lives = list(upcoming_lives.select_related('host').order_by('start_time')[:8])
            lives_data = BuddyLiveSerializer(upcoming_lives, many=True, context={'request': request}).data
        except Exception:  # noqa: BLE001 — lives section degrades gracefully
            pass

        # Trending meal plans (published, top-rated/purchased).
        from apps.marketplace.models import MealPlan
        meal_plans = MealPlan.objects.filter(
            is_published=True, visibility='public',
        ).order_by('-purchase_count', '-average_rating')[:8]
        try:
            from apps.marketplace.serializers import MealPlanSerializer as _MPS
            meal_plans_data = _MPS(meal_plans, many=True, context={'request': request}).data
        except Exception:  # noqa: BLE001
            meal_plans_data = []

        # Challenges: events tagged/keyworded as challenges or competitions.
        challenge_events = MarketplaceEvent.objects.filter(
            is_published=True, is_draft=False, is_cancelled=False,
            start_datetime__gte=now,
        )
        challenge_q = (
            db_models.Q(title__icontains='challenge')
            | db_models.Q(title__icontains='competition')
            | db_models.Q(category='challenge')
            | db_models.Q(category='competition')
        )
        if not mature_allowed:
            challenge_events = challenge_events.exclude(content_rating='mature')
        challenges_data = MarketplaceEventSerializer(
            challenge_events.filter(challenge_q)
            .select_related('creator').order_by('-attendee_count', 'start_datetime')[:8],
            many=True,
            context={'request': request},
        ).data

        return Response({
            'success': True,
            'data': {
                'hashtags': trending_hashtags,
                'posts': trending_posts,
                'discussions': trending_discussions,
                'communities': communities_data,
                'lives': lives_data,
                'meal_plans': meal_plans_data,
                'challenges': challenges_data,
                'offers': trending_offers,
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class UserPostsView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, username):
        profile = get_object_or_404(Profile, username=username)
        from apps.feed.models import Post
        from apps.feed.serializers import PostSerializer

        qs = Post.objects.filter(author=profile, is_deleted=False).order_by('-created_at')
        page_size = int(request.query_params.get('limit', 20))
        qs = qs[:page_size]

        serializer = PostSerializer(qs, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class PresenceStatusView(views.APIView):
    """
    POST /api/profiles/presence/
    Body: { "user_ids": ["uuid1", "uuid2", ...] }
    Returns online status and last_seen for each requested user.
    """
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['post', 'options', 'head']

    def options(self, request, *args, **kwargs):
        return Response(status=200)

    def post(self, request):
        from django.core.cache import cache
        user_ids = request.data.get('user_ids', [])
        if not isinstance(user_ids, list):
            return Response({'success': False, 'data': None, 'message': 'user_ids must be a list.',
                             'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)

        profiles = Profile.objects.filter(user_id__in=user_ids).values('user_id', 'last_seen', 'show_active_status')
        result = {}
        for p in profiles:
            uid = str(p['user_id'])
            is_online = bool(cache.get(f'user_online_{uid}')) if p['show_active_status'] else False
            last_seen = p['last_seen'].isoformat() if p['last_seen'] else None
            result[uid] = {
                'online': is_online,
                'last_seen': last_seen if p['show_active_status'] else None,
            }

        return Response({'success': True, 'data': result, 'message': 'OK', 'errors': None, 'pagination': None})
