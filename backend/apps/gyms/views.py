from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone

from rest_framework import views, permissions, status, generics
from rest_framework.response import Response

from common.pagination import CursorPagination, PageNumberPagination
from .models import Gym, GymMembership
from .serializers import GymSerializer, CreateGymSerializer, GymMembershipSerializer


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
            from django.contrib.postgres.search import SearchVector, SearchQuery
            queryset = queryset.annotate(
                search=SearchVector('name', 'description', 'tags'),
            ).filter(search=SearchQuery(q))

        if category:
            queryset = queryset.filter(category=category)

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


class CreateGymView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CreateGymSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        gym = Gym.objects.create(**serializer.validated_data)

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

        allowed_fields = ['description', 'logo_url', 'cover_url', 'rules', 'tags', 'location_city', 'location_country']
        update_data = {k: v for k, v in request.data.items() if k in allowed_fields}

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
        else:
            role = 'guest'

        if gym.join_fee_artifacts:
            # TODO: Deduct join fee from wallet
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
            'message': 'Welcome to the gym!' if role == 'member' else 'Join request sent. Awaiting approval.',
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
