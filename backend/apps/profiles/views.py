from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.contrib.postgres.search import SearchVector, SearchQuery
from rest_framework import views, permissions, status, generics
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes

from .models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship
from .serializers import (
    ProfileSerializer, ProfileUpdateSerializer, OnboardingSerializer,
    BuddyRequestSerializer, ProfileSearchSerializer,
)
from common.pagination import CursorPagination, PageNumberPagination
from common.permissions import AreBuddies


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
            (BlockRelationship.Q(blocker=profile) & BlockRelationship.Q(blocked=request.user.profile if request.user.is_authenticated else None)) |
            (BlockRelationship.Q(blocker=request.user.profile if request.user.is_authenticated else None) & BlockRelationship.Q(blocked=profile))
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
                (BuddyRelationship.Q(from_user=request.user.profile, to_user=profile) |
                 BuddyRelationship.Q(from_user=profile, to_user=request.user.profile)),
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

    def post(self, request):
        serializer = OnboardingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        profile = request.user.profile
        user = request.user
        user.preferences = serializer.validated_data
        user.save(update_fields=['preferences'])

        return Response({
            'success': True,
            'data': ProfileSerializer(profile, context={'request': request}).data,
            'message': 'Onboarding complete. Welcome to BuddyUp!',
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
            (BlockRelationship.Q(blocker=request.user.profile, blocked=target) |
             BlockRelationship.Q(blocker=target, blocked=request.user.profile))
        ).exists()
        if blocked:
            return Response({
                'success': False, 'data': None,
                'message': 'Unable to send buddy request.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        existing = BuddyRelationship.objects.filter(
            (BuddyRelationship.Q(from_user=request.user.profile, to_user=target) |
             BuddyRelationship.Q(from_user=target, to_user=request.user.profile))
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

        return Response({
            'success': True, 'data': {'status': 'pending'},
            'message': f'Buddy request sent to @{target.username}.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, username):
        target = get_object_or_404(Profile, username=username)
        BuddyRelationship.objects.filter(
            (BuddyRelationship.Q(from_user=request.user.profile, to_user=target) |
             BuddyRelationship.Q(from_user=target, to_user=request.user.profile))
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
            (BuddyRelationship.Q(from_user=request.user.profile, to_user=target) |
             BuddyRelationship.Q(from_user=target, to_user=request.user.profile))
        ).delete()
        FollowRelationship.objects.filter(
            (FollowRelationship.Q(follower=request.user.profile, followee=target) |
             FollowRelationship.Q(follower=target, followee=request.user.profile))
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
            queryset = queryset.annotate(
                search=SearchVector('username', 'display_name', 'bio'),
            ).filter(
                search=SearchQuery(q)
            )
        if role:
            queryset = queryset.filter(role=role)
        if location:
            queryset = queryset.filter(
                location_city__icontains=location,
            ) | queryset.filter(location_country__icontains=location)

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
