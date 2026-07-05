import hashlib
from datetime import timedelta

from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.conf import settings
from django.contrib.postgres.search import SearchVector, SearchQuery

from rest_framework import views, permissions, status, generics
from rest_framework.response import Response

import requests

from common.pagination import PageNumberPagination
from .models import Gym, GymMembership, GymCategory, GymCategoryPricing, JoinRequest, GymInvite
from .serializers import (
    GymSerializer, CreateGymSerializer, GymMembershipSerializer,
    GymCategorySerializer, JoinRequestSerializer, CreateJoinRequestSerializer,
    ApproveRejectSerializer, GymInviteSerializer, CreateInviteSerializer,
    HandleCheckSerializer, GymSchedulePostSerializer, GymReviewSerializer, GymDonationSerializer,
)
from .models import GymSchedulePost, GymReview, GymDonation


class GymListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        q = request.query_params.get('q', '')
        category = request.query_params.get('category', '')
        my_gyms = request.query_params.get('my') == 'true'

        if my_gyms:
            gym_ids = GymMembership.objects.filter(
                member=request.user.profile, subscription_active=True
            ).values_list('gym_id', flat=True)
            queryset = Gym.objects.filter(id__in=gym_ids)
        else:
            queryset = Gym.objects.filter(access_type__in=['public', 'private'])

        if q:
            queryset = queryset.annotate(
                search=SearchVector('name', 'description', 'tags'),
            ).filter(search=SearchQuery(q))

        if category:
            queryset = queryset.filter(categories__name=category)

        queryset = queryset.order_by('-member_count')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = GymSerializer(page, many=True, context={'request': request})

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


class CheckHandleView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = HandleCheckSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        candidate = serializer.validated_data['candidate']

        taken = Gym.objects.filter(handle__iexact=candidate).exists()
        suggested = None

        if taken:
            for i in range(1, 100):
                test = f'{candidate}_{i}'
                if not Gym.objects.filter(handle__iexact=test).exists():
                    suggested = test
                    break

        return Response({
            'success': True,
            'data': {
                'available': not taken,
                'suggested': suggested,
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class GymCategoriesView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        categories = GymCategory.objects.filter(is_active=True)
        serializer = GymCategorySerializer(categories, many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class CitySearchView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        q = request.query_params.get('q', '').strip()
        if len(q) < 2:
            return Response({
                'success': True,
                'data': [],
                'message': 'OK',
                'errors': None,
                'pagination': None,
            })

        api_key = getattr(settings, 'GOOGLE_PLACES_API_KEY', '')
        if not api_key:
            return Response({
                'success': False,
                'data': None,
                'message': 'City search is not configured.',
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        params = {
            'input': q,
            'types': '(cities)',
            'key': api_key,
            'language': 'en',
        }

        try:
            r = requests.get(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json',
                params=params, timeout=5,
            )
            r.raise_for_status()
            predictions = r.json().get('predictions', [])
            results = []
            for p in predictions:
                terms = p.get('terms', [])
                city = terms[0]['value'] if terms else ''
                country = terms[-1]['value'] if len(terms) > 1 else ''
                results.append({
                    'place_id': p['place_id'],
                    'city': city,
                    'country': country,
                    'description': p['description'],
                })
            return Response({
                'success': True,
                'data': results,
                'message': 'OK',
                'errors': None,
                'pagination': None,
            })
        except requests.RequestException:
            return Response({
                'success': True,
                'data': [],
                'message': 'City search temporarily unavailable.',
                'errors': None,
                'pagination': None,
            })


class CreateGymView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CreateGymSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        gym = serializer.save()

        GymMembership.objects.create(
            gym=gym,
            member=request.user.profile,
            role='owner',
        )

        gym.member_count = 1
        gym.save(update_fields=['member_count'])

        output = GymSerializer(gym, context={'request': request})
        return Response({
            'success': True,
            'data': output.data,
            'message': 'Gym created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymDetailView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)

        if gym.access_type == 'secret':
            if not (request.user.is_authenticated and GymMembership.objects.filter(
                gym=gym, member=request.user.profile, subscription_active=True
            ).exists()):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Not found.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_404_NOT_FOUND)

        serializer = GymSerializer(gym, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })

    def patch(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        membership = get_object_or_404(
            GymMembership,
            gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner'],
        )

        allowed_fields = [
            'description', 'logo_url', 'cover_url', 'rules', 'tags',
            'location_city', 'location_country',
        ]

        if membership.role == 'owner':
            allowed_fields.append('access_type')

        update_data = {k: v for k, v in request.data.items() if k in allowed_fields}

        if 'access_type' in update_data:
            new_type = update_data['access_type']
            if new_type == 'secret' and gym.member_count == 0:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Cannot set to secret with no active members.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        for k, v in update_data.items():
            setattr(gym, k, v)
        gym.save(update_fields=list(update_data.keys()))

        serializer = GymSerializer(gym, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'Gym updated.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        membership = get_object_or_404(
            GymMembership,
            gym=gym, member=request.user.profile,
            role='owner',
        )
        gym.soft_delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Gym deleted.',
            'errors': None, 'pagination': None,
        })


class JoinGymView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)

        if gym.access_type == 'secret':
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        existing = GymMembership.objects.filter(gym=gym, member=request.user.profile).first()
        if existing:
            if existing.subscription_active:
                return Response({
                    'success': False, 'data': None,
                    'message': 'You are already a member of this gym.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            existing.subscription_active = True
            existing.save(update_fields=['subscription_active'])
            gym.member_count = db_models.F('member_count') + 1
            gym.save(update_fields=['member_count'])
            return Response({
                'success': True, 'data': None,
                'message': 'Rejoined gym.',
                'errors': None, 'pagination': None,
            })

        if gym.access_type == 'public':
            role = 'member'
            if gym.join_fee_artifacts:
                pass
            GymMembership.objects.create(
                gym=gym,
                member=request.user.profile,
                role=role,
            )
            gym.member_count = db_models.F('member_count') + 1
            gym.save(update_fields=['member_count'])
            return Response({
                'success': True,
                'data': {'role': role},
                'message': 'Welcome to the gym!',
                'errors': None,
                'pagination': None,
            })

        recent = JoinRequest.objects.filter(
            gym=gym, requester=request.user.profile,
            created_at__gte=timezone.now() - timedelta(hours=24),
        ).exclude(status='rejected').exists()
        if recent:
            return Response({
                'success': False, 'data': None,
                'message': 'You already have a pending request for this gym.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_429_TOO_MANY_REQUESTS)

        serializer = CreateJoinRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        JoinRequest.objects.create(
            gym=gym,
            requester=request.user.profile,
            message=serializer.validated_data.get('message', ''),
        )

        return Response({
            'success': True,
            'data': None,
            'message': 'Join request sent. Awaiting approval.',
            'errors': None,
            'pagination': None,
        })


class LeaveGymView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        membership = get_object_or_404(GymMembership, gym=gym, member=request.user.profile)

        if membership.role == 'owner':
            other_owners = GymMembership.objects.filter(
                gym=gym, role__in=['owner', 'co_owner']
            ).exclude(member=request.user.profile).count()
            if other_owners == 0:
                return Response({
                    'success': False, 'data': None,
                    'message': 'You are the only owner. Transfer ownership or delete the gym first.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        membership.subscription_active = False
        membership.save(update_fields=['subscription_active'])

        gym.member_count = db_models.F('member_count') - 1
        gym.save(update_fields=['member_count'])

        return Response({
            'success': True, 'data': None,
            'message': 'You have left the gym.',
            'errors': None, 'pagination': None,
        })


class GymMembersView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        is_member = GymMembership.objects.filter(
            gym=gym, member=request.user.profile, subscription_active=True
        ).exists()

        if not is_member and gym.access_type != 'public':
            return Response(status=status.HTTP_403_FORBIDDEN)

        role = request.query_params.get('role', '')
        q = request.query_params.get('q', '')

        memberships = GymMembership.objects.filter(
            gym=gym, subscription_active=True
        ).select_related('member')

        if role:
            memberships = memberships.filter(role=role)
        if q:
            memberships = memberships.filter(
                db_models.Q(member__username__icontains=q) | db_models.Q(member__display_name__icontains=q)
            )

        memberships = memberships.order_by('member__username')

        serializer = GymMembershipSerializer(memberships, many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ManageMemberView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, user_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(GymMembership, gym=gym, member=request.user.profile, role__in=['owner', 'co_owner', 'moderator'])

        target = get_object_or_404(GymMembership, gym=gym, member_id=user_id)
        new_role = request.data.get('role')

        if new_role and new_role in dict(GymMembership.ROLE_CHOICES):
            if new_role in ['owner', 'co_owner']:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Use transfer ownership to change to owner/co-owner.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            target.role = new_role
            target.save(update_fields=['role'])

        return Response({
            'success': True, 'data': None,
            'message': f'Member role updated to {target.role}.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, gym_slug, user_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        admin = get_object_or_404(GymMembership, gym=gym, member=request.user.profile, role__in=['owner', 'co_owner', 'moderator'])

        target = get_object_or_404(GymMembership, gym=gym, member_id=user_id)

        if target.role in ['owner', 'co_owner']:
            return Response({
                'success': False, 'data': None,
                'message': 'Cannot remove owners. Transfer ownership first.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        target.subscription_active = False
        target.save(update_fields=['subscription_active'])

        gym.member_count = db_models.F('member_count') - 1
        gym.save(update_fields=['member_count'])

        return Response({
            'success': True, 'data': None,
            'message': 'Member removed.',
            'errors': None,
            'pagination': None,
        })


class JoinRequestListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'moderator'],
        )

        status_filter = request.query_params.get('status', '')
        qs = JoinRequest.objects.filter(gym=gym).select_related('requester').order_by('-created_at')
        if status_filter:
            qs = qs.filter(status=status_filter)

        serializer = JoinRequestSerializer(qs, many=True)
        return Response({
            'success': True,
            'data': serializer.data,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ManageJoinRequestView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, gym_slug, request_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'moderator'],
        )

        join_request = get_object_or_404(JoinRequest, id=request_id, gym=gym, status='pending')

        serializer = ApproveRejectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        new_status = serializer.validated_data['status']
        join_request.status = new_status
        join_request.reviewed_by = request.user.profile
        join_request.reviewed_at = timezone.now()
        join_request.save(update_fields=['status', 'reviewed_by', 'reviewed_at'])

        if new_status == 'approved':
            existing = GymMembership.objects.filter(
                gym=gym, member=join_request.requester
            ).first()
            if existing:
                existing.subscription_active = True
                existing.save(update_fields=['subscription_active'])
            else:
                GymMembership.objects.create(
                    gym=gym, member=join_request.requester, role='member',
                )
            Gym.objects.filter(id=gym.id).update(
                member_count=db_models.F('member_count') + 1
            )

        return Response({
            'success': True,
            'data': JoinRequestSerializer(join_request).data,
            'message': f'Request {new_status}.',
            'errors': None,
            'pagination': None,
        })


class InviteCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner'],
        )

        serializer = CreateInviteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data.get('username')
        email = serializer.validated_data.get('email')

        if email and not username:
            from django.core.mail import send_mail
            send_mail(
                f"You've been invited to join {gym.name} on BuddyUp!",
                f"{request.user.profile.display_name} has invited you to join their gym: {gym.name}.\n\nSign up and join here: http://localhost:3002/gyms/{gym.handle}",
                settings.DEFAULT_FROM_EMAIL or 'noreply@buddyup.com',
                [email],
                fail_silently=True,
            )
            return Response({
                'success': True,
                'data': None,
                'message': f'Invite sent to {email}.',
                'errors': None,
                'pagination': None,
            })

        from apps.profiles.models import Profile
        target = get_object_or_404(
            Profile, username__iexact=username
        )

        existing = GymMembership.objects.filter(
            gym=gym, member=target, subscription_active=True
        ).exists()
        if existing:
            return Response({
                'success': False, 'data': None,
                'message': 'This user is already a member.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        invite, created = GymInvite.objects.get_or_create(
            gym=gym, invited_user=target,
            defaults={'invited_by': request.user.profile, 'status': 'pending'},
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'An invite has already been sent to this user.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'success': True,
            'data': GymInviteSerializer(invite).data,
            'message': 'Invite sent.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class InviteActionView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, invite_id, action):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        invite = get_object_or_404(
            GymInvite, id=invite_id, gym=gym,
            invited_user=request.user.profile, status='pending',
        )

        if action == 'accept':
            invite.status = 'accepted'
            invite.save(update_fields=['status'])
            existing = GymMembership.objects.filter(
                gym=gym, member=request.user.profile
            ).first()
            if existing:
                existing.subscription_active = True
                existing.save(update_fields=['subscription_active'])
            else:
                GymMembership.objects.create(
                    gym=gym, member=request.user.profile, role='member',
                )
            Gym.objects.filter(id=gym.id).update(
                member_count=db_models.F('member_count') + 1
            )
            message = 'Invite accepted. Welcome to the gym!'

        elif action == 'decline':
            invite.status = 'declined'
            invite.save(update_fields=['status'])
            message = 'Invite declined.'

        else:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid action. Use "accept" or "decline".',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'success': True,
            'data': GymInviteSerializer(invite).data,
            'message': message,
            'errors': None,
            'pagination': None,
        })


class GymSchedulePostListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        posts = gym.schedule_posts.all().select_related('author')
        
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(posts, request)
        serializer = GymSchedulePostSerializer(page, many=True)
        
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

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        membership = get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'trainer', 'moderator']
        )
        
        from .serializers import GymSchedulePostSerializer
        serializer = GymSchedulePostSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        post = serializer.save(gym=gym, author=request.user.profile)
        
        # Automatic creation of Live or Event if attached
        if post.activity_type == 'live_stream':
            from apps.lives.models import BuddyLive
            live = BuddyLive.objects.create(
                host=request.user.profile,
                gym=gym,
                title=post.title or f"{gym.name} Live Session",
                live_type='gym_live',
                category='fitness',
                scheduled_for=post.start_time
            )
            post.linked_live = live
            post.save(update_fields=['linked_live'])
            
        elif post.activity_type == 'event' and post.start_time and post.end_time:
            from apps.marketplace.models import MarketplaceEvent
            MarketplaceEvent.objects.create(
                creator=request.user.profile,
                gym=gym,
                title=post.title or f"{gym.name} Event",
                description=post.content,
                event_type=post.location_mode,
                start_datetime=post.start_time,
                end_datetime=post.end_time,
                timezone=post.timezone,
                capacity=post.max_slots,
                is_free=True
            )
        
        return Response({
            'success': True,
            'data': GymSchedulePostSerializer(post).data,
            'message': 'Schedule post created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymReviewListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        if not gym.is_reviews_enabled:
            return Response({'success': False, 'message': 'Reviews are disabled.'}, status=400)
            
        reviews = gym.reviews.all().select_related('reviewer')
        
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(reviews, request)
        serializer = GymReviewSerializer(page, many=True)
        
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

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        if not gym.is_reviews_enabled:
            return Response({'success': False, 'message': 'Reviews are disabled.'}, status=400)

        get_object_or_404(GymMembership, gym=gym, member=request.user.profile, subscription_active=True)
        
        if gym.reviews.filter(reviewer=request.user.profile).exists():
            return Response({'success': False, 'message': 'You have already reviewed this gym.'}, status=400)

        serializer = GymReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = serializer.save(gym=gym, reviewer=request.user.profile)
        
        return Response({
            'success': True,
            'data': GymReviewSerializer(review).data,
            'message': 'Review created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymDonationCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        if not gym.is_donations_enabled:
            return Response({'success': False, 'message': 'Donations are disabled.'}, status=400)

        amount = request.data.get('amount')
        message = request.data.get('message', '')
        
        try:
            amount = float(amount)
            if amount <= 0:
                raise ValueError
        except (TypeError, ValueError):
            return Response({'success': False, 'message': 'Invalid amount.'}, status=400)

        # Basic simulated artifact transaction
        from apps.wallet.models import ArtifactTransaction
        
        # In a real app we'd deduct from user balance here (assuming they have enough)
        # We simulate the deduction and gym addition
        donation = GymDonation.objects.create(
            gym=gym, donor=request.user.profile, amount=amount, message=message
        )
        
        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='gym_subscription', # fallback for general gym xfer
            artifact_type='gym_donation',
            quantity=1,
            direction='debit',
            fiat_amount=amount,
            status='completed',
            description=f'Donation to {gym.name}'
        )
        
        # Increase gym's wallet balance
        gym_wallet = gym.wallet_balance
        if 'donations_received' not in gym_wallet:
            gym_wallet['donations_received'] = 0.0
        gym_wallet['donations_received'] += amount
        gym.save(update_fields=['wallet_balance'])
        
        return Response({
            'success': True,
            'data': GymDonationSerializer(donation).data,
            'message': 'Donation successful.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymReviewReplyView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, review_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        review = get_object_or_404(GymReview, id=review_id, gym=gym)
        
        # Must be gym admin
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'moderator']
        )
        
        reply_text = request.data.get('reply_text', '').strip()
        if not reply_text:
            return Response({'success': False, 'message': 'Reply text is required.'}, status=400)
            
        from django.utils import timezone
        review.reply_text = reply_text
        review.replied_by = request.user.profile
        review.replied_at = timezone.now()
        review.save(update_fields=['reply_text', 'replied_by', 'replied_at'])
        
        return Response({
            'success': True,
            'data': GymReviewSerializer(review).data,
            'message': 'Reply submitted.',
            'errors': None,
            'pagination': None,
        })


class GymFeedListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        
        from apps.feed.models import Post
        from apps.feed.serializers import PostSerializer
        
        posts = Post.objects.filter(
            gym_tag=gym,
            moderation_status='clean'
        ).select_related('author').prefetch_related('comments', 'reactions').order_by('-is_pinned', '-created_at')
        
        # If gym is private/secret, enforce membership
        if gym.access_type in ['private', 'secret']:
            is_member = GymMembership.objects.filter(gym=gym, member=request.user.profile, subscription_active=True).exists()
            if not is_member:
                return Response({'success': False, 'message': 'Not a member.'}, status=403)
        
        paginator = PageNumberPagination()
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


class SlotEnrollView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, post_id):
        try:
            gym = Gym.objects.get(handle=gym_slug)
            schedule_post = GymSchedulePost.objects.get(id=post_id, gym=gym)
        except (Gym.DoesNotExist, GymSchedulePost.DoesNotExist):
            return Response({'success': False, 'message': 'Not found.'}, status=404)

        profile = request.user.profile
        if not GymMembership.objects.filter(gym=gym, member=profile, subscription_active=True).exists():
            return Response({'success': False, 'message': 'You must be a member to enroll.'}, status=403)

        from .serializers import CreateEnrollmentSerializer, ScheduleSlotEnrollmentSerializer
        from .models import ScheduleSlotEnrollment
        ser = CreateEnrollmentSerializer(data=request.data)
        if not ser.is_valid():
            return Response({'success': False, 'errors': ser.errors}, status=400)

        enrollment, created = ScheduleSlotEnrollment.objects.get_or_create(
            schedule_post=schedule_post,
            member=profile,
            defaults={**ser.validated_data, 'is_active': True}
        )
        if not created:
            # Update existing
            for k, v in ser.validated_data.items():
                setattr(enrollment, k, v)
            enrollment.is_active = True
            enrollment.save()

        # Update slots count
        schedule_post.slots_taken = ScheduleSlotEnrollment.objects.filter(
            schedule_post=schedule_post, is_active=True
        ).count()
        schedule_post.save(update_fields=['slots_taken'])

        return Response({'success': True, 'data': ScheduleSlotEnrollmentSerializer(enrollment).data}, status=201)

    def delete(self, request, gym_slug, post_id):
        try:
            gym = Gym.objects.get(handle=gym_slug)
            schedule_post = GymSchedulePost.objects.get(id=post_id, gym=gym)
            from .models import ScheduleSlotEnrollment
            enrollment = ScheduleSlotEnrollment.objects.get(
                schedule_post=schedule_post, member=request.user.profile
            )
        except Exception:
            return Response({'success': False, 'message': 'Enrollment not found.'}, status=404)

        enrollment.is_active = False
        enrollment.save()
        schedule_post.slots_taken = max(0, schedule_post.slots_taken - 1)
        schedule_post.save(update_fields=['slots_taken'])
        return Response({'success': True, 'message': 'Unenrolled successfully.'})


class MySlotEnrollmentsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        from .models import ScheduleSlotEnrollment
        from .serializers import ScheduleSlotEnrollmentSerializer
        try:
            gym = Gym.objects.get(handle=gym_slug)
        except Gym.DoesNotExist:
            return Response({'success': False, 'message': 'Gym not found.'}, status=404)
        enrollments = ScheduleSlotEnrollment.objects.filter(
            member=request.user.profile,
            schedule_post__gym=gym,
            is_active=True
        ).select_related('schedule_post')
        return Response({'success': True, 'data': ScheduleSlotEnrollmentSerializer(enrollments, many=True).data})


class GymEventsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        try:
            gym = Gym.objects.get(handle=gym_slug)
        except Gym.DoesNotExist:
            return Response({'success': False, 'message': 'Gym not found.'}, status=404)
        from apps.marketplace.models import MarketplaceEvent
        from apps.marketplace.serializers import MarketplaceEventSerializer
        from django.utils import timezone as tz
        qs = MarketplaceEvent.objects.filter(gym=gym, is_published=True, is_cancelled=False)
        upcoming_only = request.query_params.get('upcoming', 'true').lower() == 'true'
        if upcoming_only:
            qs = qs.filter(start_datetime__gte=tz.now())
        return Response({'success': True, 'data': MarketplaceEventSerializer(qs, many=True, context={'request': request}).data})
