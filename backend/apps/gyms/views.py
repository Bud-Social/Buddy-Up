import csv
import io
import logging
import os
import uuid
from datetime import timedelta

from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from django.conf import settings
from django.http import HttpResponse


from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

import requests

from common.pagination import PageNumberPagination
from common.age_gating import gate_mature_queryset, can_view_content
from .models import (
    Gym, GymMembership, GymCategory, GymOnboardingChecklist,
    JoinRequest, GymInvite, GymMembershipException, VenueLocation,
    AttendanceRecord, GymMedia, GymOnlineCoach, GymTrainerEndorsement,
    RegisteredGymProfile,
)
from .serializers import (
    GymSerializer, GymDetailSerializer, CreateGymSerializer, GymMembershipSerializer,
    GymCategorySerializer, JoinRequestSerializer, CreateJoinRequestSerializer,
    ApproveRejectSerializer, GymInviteSerializer, CreateInviteSerializer,
    DonationInputSerializer, ReviewReplyInputSerializer, ManageMemberRoleSerializer,
    HandleCheckSerializer, GymRoutinePostSerializer, GymReviewSerializer, GymDonationSerializer,
    GymMembershipExceptionSerializer, CreateMembershipExceptionSerializer, MembershipCheckoutSerializer,
    AttendanceRecordSerializer, GymOnboardingChecklistSerializer, VenueLocationSerializer,
    GymMediaSerializer, RegisteredGymProfileSerializer, SubmitRegistrationSerializer,
    GymOnlineCoachSerializer, OnlineCoachingUpdateSerializer, AddOnlineCoachSerializer,
    GymTrainerEndorsementSerializer, CreateEndorsementSerializer, GymAnnouncementSerializer,
)
from .models import GymRoutinePost, GymReview, GymDonation
from apps.wallet.utils import deduct_artifacts
from apps.wallet.serializers import ARTIFACT_VALUES
from apps.marketplace.models import DiscountCode, DiscountUsage

logger = logging.getLogger(__name__)


PARTNER_ROLES = ['owner', 'co_owner', 'moderator']


def _require_partner_staff(gym, profile):
    return get_object_or_404(GymMembership, gym=gym, member=profile, role__in=PARTNER_ROLES)


class GymOnboardingChecklistView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        checklist, _ = GymOnboardingChecklist.objects.get_or_create(gym=gym)
        return Response({'success': True, 'data': GymOnboardingChecklistSerializer(checklist).data})

    def patch(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        checklist, _ = GymOnboardingChecklist.objects.get_or_create(gym=gym)
        serializer = GymOnboardingChecklistSerializer(checklist, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        checklist = serializer.save()
        required = {'profile', 'venue', 'schedule', 'invite_members'}
        checklist.completed_at = timezone.now() if required.issubset(set(checklist.completed_steps)) else None
        checklist.save(update_fields=['completed_at'])
        return Response({'success': True, 'data': GymOnboardingChecklistSerializer(checklist).data})


class VenueLocationListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        GymMembership.objects.get(gym=gym, member=request.user.profile, subscription_active=True)
        return Response({'success': True, 'data': VenueLocationSerializer(gym.venues.filter(is_active=True), many=True).data})

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        serializer = VenueLocationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if serializer.validated_data.get('is_primary'):
            gym.venues.update(is_primary=False)
        venue = serializer.save(gym=gym)
        return Response({'success': True, 'data': VenueLocationSerializer(venue).data}, status=status.HTTP_201_CREATED)


class VenueLocationDetailView(views.APIView):
    """Edit or retire a single venue (add/remove locations after creation)."""

    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, gym_slug, venue_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        venue = get_object_or_404(VenueLocation, id=venue_id, gym=gym)
        serializer = VenueLocationSerializer(venue, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        if serializer.validated_data.get('is_primary'):
            gym.venues.exclude(id=venue.id).update(is_primary=False)
        venue = serializer.save()
        return Response({'success': True, 'data': VenueLocationSerializer(venue).data})

    def delete(self, request, gym_slug, venue_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        venue = get_object_or_404(VenueLocation, id=venue_id, gym=gym)
        venue.is_active = False
        venue.save(update_fields=['is_active'])
        if not gym.venues.filter(is_active=True).exists():
            gym.location_city = ''
            gym.location_country = ''
            gym.save(update_fields=['location_city', 'location_country'])
        return Response({'success': True, 'data': None, 'message': 'Location removed.'})


class AttendanceListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        records = gym.attendance_records.select_related('member').order_by('-checked_in_at')[:500]
        return Response({'success': True, 'data': AttendanceRecordSerializer(records, many=True).data})

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        serializer = AttendanceRecordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        member = serializer.validated_data['member']
        if not GymMembership.objects.filter(gym=gym, member=member, subscription_active=True).exists():
            return Response({'success': False, 'message': 'Member does not have an active gym membership.'}, status=400)
        record = serializer.save(
            gym=gym,
            checked_in_at=serializer.validated_data.get('checked_in_at') or timezone.now(),
        )
        # A gym visit is what a "gym attendance" countdown waits for.
        _raise_gym_checkin(member)
        return Response({'success': True, 'data': AttendanceRecordSerializer(record).data}, status=status.HTTP_201_CREATED)


def _raise_gym_checkin(profile):
    """Advance the countdowns that follow gym visits."""
    from apps.countdowns.services import advance_matching_countdowns

    try:
        advance_matching_countdowns(profile, 'gym_checkin')
    except Exception:  # noqa: BLE001 — a countdown must never fail the check-in
        logger.warning('could not advance gym countdowns for %s', profile, exc_info=True)


class GymCheckInView(views.APIView):
    """Check yourself in at a gym.

    Only an active member can check in, and only once a day — a gym
    visit is what a "gym attendance" countdown follows.
    """
    permission_classes = [permissions.IsAuthenticated]

    #: How long a member must wait between check-ins.
    CHECK_IN_INTERVAL = timedelta(hours=20)

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        profile = request.user.profile

        membership = GymMembership.objects.filter(
            gym=gym, member=profile, subscription_active=True,
        ).first()
        if membership is None:
            return Response({
                'success': False, 'data': None,
                'message': 'You need an active membership to check in here.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        now = timezone.now()
        last = gym.attendance_records.filter(
            member=profile, checked_in_at__isnull=False,
        ).order_by('-checked_in_at').first()
        if last and last.checked_in_at and now - last.checked_in_at < self.CHECK_IN_INTERVAL:
            wait = self.CHECK_IN_INTERVAL - (now - last.checked_in_at)
            hours = int(wait.total_seconds() // 3600)
            minutes = int((wait.total_seconds() % 3600) // 60)
            return Response({
                'success': False, 'data': None,
                'message': (
                    f'You already checked in. You can check in again in '
                    f'{hours}h {minutes}m.'
                ),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_409_CONFLICT)

        record = AttendanceRecord.objects.create(
            member=profile,
            gym=gym,
            status='checked_in',
            checked_in_at=now,
            source='member',
        )
        _raise_gym_checkin(profile)

        return Response({
            'success': True,
            'data': AttendanceRecordSerializer(record).data,
            'message': f'Checked in at {gym.name}.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)

    def get(self, request, gym_slug):
        """Whether I can check in here, and when I last did."""
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        profile = request.user.profile
        membership = GymMembership.objects.filter(
            gym=gym, member=profile, subscription_active=True,
        ).first()
        last = gym.attendance_records.filter(
            member=profile, checked_in_at__isnull=False,
        ).order_by('-checked_in_at').first()
        next_at = None
        if last and last.checked_in_at:
            candidate = last.checked_in_at + self.CHECK_IN_INTERVAL
            if candidate > timezone.now():
                next_at = candidate.isoformat()
        return Response({
            'success': True,
            'data': {
                'can_check_in': bool(membership) and next_at is None,
                'is_member': bool(membership),
                'last_check_in_at': last.checked_in_at.isoformat() if last and last.checked_in_at else None,
                'next_check_in_at': next_at,
            },
            'message': 'Check-in status.', 'errors': None, 'pagination': None,
        })


class PartnerMetricsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        since = timezone.now() - timedelta(days=30)
        active_members = gym.memberships.filter(subscription_active=True).count()
        checked_in = gym.attendance_records.filter(checked_in_at__gte=since)
        unique_attendees = checked_in.values('member').distinct().count()
        check_ins = checked_in.count()
        new_members = gym.memberships.filter(created_at__gte=since).count()
        churned = gym.memberships.filter(
            subscription_active=False, updated_at__gte=since,
        ).count()
        posts = gym.routine_posts.filter(start_time__gte=since)
        posts_with_capacity = posts.filter(max_slots__gt=0)
        capacity_total = posts_with_capacity.aggregate(
            total=db_models.Sum('max_slots'),
        )['total'] or 0
        capacity_taken = posts_with_capacity.aggregate(
            total=db_models.Sum('slots_taken'),
        )['total'] or 0
        return Response({'success': True, 'data': {
            'active_members': active_members,
            'new_members_30d': new_members,
            'churned_30d': churned,
            'retention_rate_30d': round(
                active_members / (active_members + churned) * 100, 1
            ) if (active_members + churned) else 0,
            'check_ins_30d': check_ins,
            'avg_check_ins_per_day_30d': round(check_ins / 30, 1),
            'unique_attendees_30d': unique_attendees,
            'activation_rate_30d': round(unique_attendees / active_members * 100, 1) if active_members else 0,
            'scheduled_activities_30d': posts.count(),
            'capacity_utilization_30d': round(capacity_taken / capacity_total * 100, 1) if capacity_total else 0,
            'online_coaches': gym.online_coaches.filter(is_available=True).count(),
            'offers_online_coaching': gym.offers_online_coaching,
            'registration_status': _registration_status(gym),
            'subscription_revenue': sum(
                int(v or 0) for k, v in (gym.wallet_balance or {}).items()
                if k.startswith('monthly_fee_')
            ),
        }})


def _registration_status(gym):
    try:
        return gym.registered_profile.status
    except RegisteredGymProfile.DoesNotExist:
        return 'unverified'


class GymMemberCSVView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename="{gym.handle}-members.csv"'
        writer = csv.writer(response)
        writer.writerow(['username', 'email', 'display_name', 'role', 'subscription_active'])
        for membership in gym.memberships.select_related('member__user').order_by('member__username'):
            writer.writerow([membership.member.username, membership.member.user.email,
                             membership.member.display_name, membership.role, membership.subscription_active])
        return response

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        upload = request.FILES.get('file')
        if not upload:
            return Response({'success': False, 'message': 'A CSV file is required.'}, status=400)
        try:
            rows = csv.DictReader(io.StringIO(upload.read().decode('utf-8-sig')))
        except (UnicodeDecodeError, csv.Error):
            return Response({'success': False, 'message': 'Invalid UTF-8 CSV file.'}, status=400)
        from apps.profiles.models import Profile
        created = 0
        errors = []
        for line, row in enumerate(rows, start=2):
            profile = Profile.objects.filter(db_models.Q(username__iexact=(row.get('username') or '').strip()) |
                                             db_models.Q(user__email__iexact=(row.get('email') or '').strip())).first()
            role = (row.get('role') or 'member').strip()
            if not profile or role not in dict(GymMembership.ROLE_CHOICES) or role in ('owner', 'co_owner'):
                errors.append({'line': line, 'error': 'Unknown member or unsupported role.'})
                continue
            _, was_created = GymMembership.objects.update_or_create(
                gym=gym, member=profile,
                defaults={'role': role, 'subscription_active': True},
            )
            created += int(was_created)
        gym.member_count = gym.memberships.filter(subscription_active=True).count()
        gym.save(update_fields=['member_count'])
        return Response({'success': True, 'data': {'created': created, 'errors': errors}})


class GymListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        q = request.query_params.get('q', '')
        category = request.query_params.get('category', '')
        city = request.query_params.get('city', '').strip()
        country = request.query_params.get('country', '').strip()
        verified_only = request.query_params.get('verified') == 'true'
        delivery = (request.query_params.get('delivery') or 'any').strip().lower()
        ordering = (request.query_params.get('ordering') or 'members').strip().lower()
        my_gyms = request.query_params.get('my') == 'true'
        radius_km = request.query_params.get('radius_km', '')

        try:
            min_rating = float(request.query_params.get('min_rating', '') or 0)
        except (TypeError, ValueError):
            min_rating = 0

        lat = lng = None
        try:
            if request.query_params.get('lat') not in (None, ''):
                lat = float(request.query_params.get('lat'))
            if request.query_params.get('lng') not in (None, ''):
                lng = float(request.query_params.get('lng'))
        except (TypeError, ValueError):
            lat = lng = None
        radius_explicit = str(radius_km).strip() != ''
        try:
            radius_km = float(radius_km or 25)
        except (TypeError, ValueError):
            radius_km = 25
            radius_explicit = False
        radius_km = min(max(radius_km, 1), 200)

        # Adaptive default: 5 km in dense areas, 10 km in sparse ones when
        # the user didn't pick a radius. Explicit radius always wins.
        geo_auto = False
        geo_density = None
        geo_count_in_near = None
        if lat is not None and lng is not None and not radius_explicit:
            from common.geo import (
                NEAR_RADIUS_KM,
                count_within_latlng,
                pick_adaptive_radius,
            )

            geo_count_in_near = count_within_latlng(
                VenueLocation.objects.filter(is_active=True), lat, lng, NEAR_RADIUS_KM
            )
            radius_km, geo_density = pick_adaptive_radius(geo_count_in_near)
            geo_auto = True

        if my_gyms:
            gym_ids = GymMembership.objects.filter(
                member=request.user.profile, subscription_active=True
            ).values_list('gym_id', flat=True)
            queryset = Gym.objects.filter(id__in=gym_ids)
        else:
            queryset = Gym.objects.filter(access_type__in=['public', 'private'])

        if q:
            from django.db.models import Q
            queryset = queryset.filter(
                Q(name__icontains=q) | Q(description__icontains=q) | Q(tags__icontains=q)
            )

        if category:
            queryset = queryset.filter(categories__name=category)

        if city:
            from django.db.models import Q
            queryset = queryset.filter(
                Q(location_city__icontains=city)
                | Q(venues__city__icontains=city, venues__is_active=True)
            )

        if country:
            from django.db.models import Q
            queryset = queryset.filter(
                Q(location_country__icontains=country)
                | Q(venues__country__icontains=country, venues__is_active=True)
            )

        if verified_only:
            queryset = queryset.filter(is_verified=True)

        # Delivery facets: a gym is physical when it has an active venue and
        # virtual when it runs online/hybrid schedule posts. Hybrid = both.
        queryset = queryset.annotate(
            has_physical=db_models.Exists(
                VenueLocation.objects.filter(gym=db_models.OuterRef('pk'), is_active=True)
            ),
            has_virtual=db_models.Exists(
                GymRoutinePost.objects.filter(
                    gym=db_models.OuterRef('pk'), location_mode__in=['online', 'hybrid'],
                )
            ),
            avg_rating=db_models.Avg('reviews__rating'),
        )
        if delivery == 'physical':
            queryset = queryset.filter(has_physical=True)
        elif delivery == 'virtual':
            queryset = queryset.filter(has_virtual=True)
        elif delivery == 'hybrid':
            queryset = queryset.filter(has_physical=True, has_virtual=True)

        if min_rating > 0:
            queryset = queryset.filter(avg_rating__gte=min_rating)

        if lat is not None and lng is not None:
            import math
            lat_delta = radius_km / 111.0
            lng_delta = radius_km / max(111.0 * abs(math.cos(math.radians(lat))), 1e-6)
            queryset = queryset.filter(
                venues__is_active=True,
                venues__latitude__isnull=False,
                venues__longitude__isnull=False,
                venues__latitude__gte=lat - lat_delta,
                venues__latitude__lte=lat + lat_delta,
                venues__longitude__gte=lng - lng_delta,
                venues__longitude__lte=lng + lng_delta,
            )

        queryset = queryset.distinct()
        queryset = gate_mature_queryset(request, queryset)
        queryset = queryset.select_related('registered_profile').prefetch_related(
            'venues', 'categories', 'category_pricing',
        )

        if ordering == 'rating':
            queryset = queryset.order_by('-avg_rating', '-member_count')
        elif ordering == 'newest':
            queryset = queryset.order_by('-created_at')
        else:
            queryset = queryset.order_by('-member_count')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)

        # Distance annotation (no PostGIS): min haversine over active venues.
        # Computed before serialization so the location summary can use it.
        distance_by_gym = {}
        if lat is not None and lng is not None and page:
            from common.geo import adaptive_message, haversine_km

            venue_rows = (
                VenueLocation.objects.filter(gym_id__in=[g.pk for g in page], is_active=True)
                .exclude(latitude__isnull=True)
                .exclude(longitude__isnull=True)
                .values('gym_id', 'latitude', 'longitude')
            )
            for row in venue_rows:
                try:
                    d = haversine_km(lat, lng, float(row['latitude']), float(row['longitude']))
                except (TypeError, ValueError):
                    continue
                gid = str(row['gym_id'])
                if gid not in distance_by_gym or d < distance_by_gym[gid]:
                    distance_by_gym[gid] = d

        serializer = GymSerializer(page, many=True, context={
            'request': request,
            'distance_km_by_gym': {k: round(v, 1) for k, v in distance_by_gym.items()},
            'viewer_lat': lat,
            'viewer_lng': lng,
        })
        data = list(serializer.data)

        if lat is not None and lng is not None and data:
            for g in data:
                d = distance_by_gym.get(str(g.get('id')))
                g['distance_km'] = round(d, 1) if d is not None else None
            if ordering == 'nearest':
                data.sort(key=lambda g: (g['distance_km'] is None, g['distance_km'] or 0))
        elif ordering == 'nearest':
            # Requested nearest without GPS: fall back to members ordering.
            ordering = 'members'

        geo = None
        if lat is not None and lng is not None:
            from common.geo import adaptive_message

            message = None
            if geo_auto:
                message = adaptive_message(radius_km, geo_density or 'sparse', geo_count_in_near or 0)
            geo = {
                'lat': lat,
                'lng': lng,
                'radius_km': radius_km,
                'auto': geo_auto,
                'density': geo_density,
                'count_in_near': geo_count_in_near,
                'message': message,
            }

        return Response({
            'success': True,
            'data': data,
            'message': 'OK',
            'errors': None,
            'geo': geo,
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

        output = GymDetailSerializer(gym, context={'request': request})
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

        if not can_view_content(request, gym):
            return Response({
                'success': False, 'data': None,
                'message': 'Not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        viewer_lat = viewer_lng = None
        try:
            if request.query_params.get('lat') not in (None, ''):
                viewer_lat = float(request.query_params.get('lat'))
            if request.query_params.get('lng') not in (None, ''):
                viewer_lng = float(request.query_params.get('lng'))
        except (TypeError, ValueError):
            viewer_lat = viewer_lng = None

        serializer = GymDetailSerializer(gym, context={
            'request': request,
            'viewer_lat': viewer_lat,
            'viewer_lng': viewer_lng,
        })
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
            'location_city', 'location_country', 'content_rating',
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
        get_object_or_404(
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
            if gym.subscription_type in ('paid', 'tiered') and any(
                int(v or 0) > 0 for v in (gym.monthly_fee_artifacts or {}).values()
            ):
                return Response({
                    'success': False, 'data': None,
                    'message': 'This gym requires a paid subscription. Complete membership checkout to join.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)

            role = 'member'
            if gym.join_fee_artifacts:
                gym_wallet = dict(gym.wallet_balance) if gym.wallet_balance else {}
                for at, qty in gym.join_fee_artifacts.items():
                    if not deduct_artifacts(request.user.profile, at, qty):
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Insufficient {at} balance to pay the join fee.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_402_PAYMENT_REQUIRED)
                    fee_key = f'join_fee_{at}'
                    gym_wallet[fee_key] = gym_wallet.get(fee_key, 0) + qty
                Gym.objects.filter(id=gym.id).update(wallet_balance=gym_wallet)
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


class GymMembershipCheckoutView(views.APIView):
    """Charge the member (wallet artifacts) for joining a subscription gym.

    Combines join fee + first-month subscription fee, applying any owner
    exception first, then an optional discount code owned by the gym's owner.
    """
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
        if existing and existing.subscription_active:
            return Response({
                'success': False, 'data': None,
                'message': 'You are already a member of this gym.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = MembershipCheckoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        discount_code = (serializer.validated_data.get('discount_code') or '').strip() or None

        # ---- Phase 1: base fee (join fee + monthly subscription fee) ----
        base_artifacts = {}
        for fee_map in (gym.join_fee_artifacts, gym.monthly_fee_artifacts):
            if not fee_map:
                continue
            for k, v in fee_map.items():
                qty = int(v or 0)
                if qty > 0:
                    base_artifacts[k] = base_artifacts.get(k, 0) + qty

        # ---- Phase 2: owner exception (full/partial discount for this member) ----
        exception = GymMembershipException.objects.filter(
            gym=gym, member=request.user.profile, is_active=True,
        ).filter(
            db_models.Q(expires_at__isnull=True) | db_models.Q(expires_at__gt=timezone.now())
        ).first()
        if exception:
            if exception.discount_pct >= 100:
                base_artifacts = {}
            elif exception.discount_pct > 0:
                factor = exception.discount_pct / 100.0
                for k in list(base_artifacts):
                    base_artifacts[k] = max(1, int(base_artifacts[k] * (1 - factor)))

        # ---- Phase 3: discount code (must belong to an owner of this gym) ----
        discount = None
        pct_applied = 0
        savings_artifacts = {}
        discounted_artifacts = dict(base_artifacts)
        if discount_code:
            discount = DiscountCode.objects.filter(code__iexact=discount_code, is_active=True).first()
            if not discount:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Invalid discount code.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            owner_ids = set(
                GymMembership.objects.filter(gym=gym, role__in=['owner', 'co_owner'])
                .values_list('member_id', flat=True)
            )
            if discount.creator_id not in owner_ids:
                return Response({
                    'success': False, 'data': None,
                    'message': 'This discount code does not apply to this gym.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if discount.creator == request.user.profile:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Cannot use your own discount code.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if discount.valid_from and discount.valid_from > timezone.now():
                return Response({
                    'success': False, 'data': None,
                    'message': 'Discount code is not yet valid.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if discount.valid_until and discount.valid_until < timezone.now():
                return Response({
                    'success': False, 'data': None,
                    'message': 'Discount code has expired.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if discount.usage_limit > 0 and discount.times_used >= discount.usage_limit:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Discount code usage limit reached.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            if discount.max_uses_per_user > 0:
                user_uses = DiscountUsage.objects.filter(discount=discount, user=request.user.profile).count()
                if user_uses >= discount.max_uses_per_user:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'You have already used this code the maximum number of times.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
            if discount.min_purchase_artifacts and any(int(v or 0) > 0 for v in discount.min_purchase_artifacts.values()):
                for at, needed in discount.min_purchase_artifacts.items():
                    needed = int(needed or 0)
                    if needed > 0 and base_artifacts.get(at, 0) < needed:
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Minimum purchase of {needed} {at} required for this code.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_400_BAD_REQUEST)

            if discount.discount_type == 'percentage' and discount.discount_pct > 0:
                pct_applied = discount.discount_pct
                factor = pct_applied / 100.0
                for k in base_artifacts:
                    discounted = max(1, int(base_artifacts[k] * (1 - factor)))
                    savings_artifacts[k] = base_artifacts[k] - discounted
                    discounted_artifacts[k] = discounted
            elif discount.discount_type == 'fixed_artifacts' and discount.discount_artifacts:
                for k, v in discount.discount_artifacts.items():
                    if k in base_artifacts:
                        discounted = max(1, base_artifacts[k] - int(v or 0))
                        savings_artifacts[k] = base_artifacts[k] - discounted
                        discounted_artifacts[k] = discounted

        # ---- Phase 4: charge the member ----
        gym_wallet = dict(gym.wallet_balance) if gym.wallet_balance else {}
        for at, qty in discounted_artifacts.items():
            if qty <= 0:
                continue
            if not deduct_artifacts(request.user.profile, at, qty):
                return Response({
                    'success': False, 'data': None,
                    'message': f'Insufficient {at} balance to pay the subscription fee.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)
            fee_key = f'monthly_fee_{at}'
            gym_wallet[fee_key] = gym_wallet.get(fee_key, 0) + qty
        Gym.objects.filter(id=gym.id).update(wallet_balance=gym_wallet)

        if discount and savings_artifacts:
            DiscountUsage.objects.create(
                discount=discount,
                user=request.user.profile,
                order_artifacts=dict(base_artifacts),
                discount_pct_applied=pct_applied,
                discount_artifacts_applied={},
                savings_artifacts=savings_artifacts,
            )
            DiscountCode.objects.filter(id=discount.id).update(
                times_used=db_models.F('times_used') + 1
            )

        # ---- Phase 5: activate membership ----
        expires_at = timezone.now() + timedelta(days=30)
        if existing:
            existing.subscription_active = True
            existing.subscription_expires_at = expires_at
            existing.save(update_fields=['subscription_active', 'subscription_expires_at'])
        else:
            GymMembership.objects.create(
                gym=gym, member=request.user.profile, role='member',
                subscription_active=True, subscription_expires_at=expires_at,
            )
            Gym.objects.filter(id=gym.id).update(
                member_count=db_models.F('member_count') + 1
            )

        return Response({
            'success': True,
            'data': {
                'role': 'member',
                'charged_artifacts': discounted_artifacts,
                'savings_artifacts': savings_artifacts,
                'discount_code': discount.code if discount else None,
                'subscription_expires_at': expires_at.isoformat(),
            },
            'message': 'Welcome to the gym! Your membership is active.',
            'errors': None, 'pagination': None,
        })


class GymMembershipExceptionsListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _require_staff(self, gym, request):
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner'],
        )

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        self._require_staff(gym, request)
        qs = GymMembershipException.objects.filter(gym=gym).select_related('member').order_by('-created_at')
        serializer = GymMembershipExceptionSerializer(qs, many=True)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        self._require_staff(gym, request)

        serializer = CreateMembershipExceptionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        member_id = serializer.validated_data.get('member_id')
        username = serializer.validated_data.get('username', '').strip()
        target = None
        if member_id:
            from apps.profiles.models import Profile
            target = Profile.objects.filter(user_id=member_id).first()
        elif username:
            from apps.profiles.models import Profile
            target = Profile.objects.filter(username__iexact=username).first()
        if not target:
            return Response({
                'success': False, 'data': None,
                'message': 'Member not found.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_404_NOT_FOUND)

        exception, created = GymMembershipException.objects.update_or_create(
            gym=gym, member=target,
            defaults={
                'discount_pct': serializer.validated_data.get('discount_pct', 100),
                'reason': serializer.validated_data.get('reason', ''),
                'expires_at': serializer.validated_data.get('expires_at'),
                'is_active': serializer.validated_data.get('is_active', True),
                'created_by': request.user.profile,
            },
        )

        return Response({
            'success': True,
            'data': GymMembershipExceptionSerializer(exception).data,
            'message': 'Created exception.' if created else 'Updated exception.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


class GymMembershipExceptionDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, gym_slug, exception_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner'],
        )
        exception = get_object_or_404(GymMembershipException, id=exception_id, gym=gym)
        exception.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Exception removed.',
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


def _notify_gym_role_change(gym, membership, previous_role, actor):
    from apps.notifications.tasks import create_notification

    label = dict(GymMembership.ROLE_CHOICES).get(membership.role, membership.role)
    create_notification.delay(
        recipient_id=str(membership.member.user_id),
        notification_type='gym_role_changed',
        title=f'You are now a {label} at {gym.name}',
        body=(
            f'{actor.display_name} changed your role at {gym.name} '
            f'from {previous_role} to {membership.role}.'
        ),
        metadata={
            'gym_handle': gym.handle,
            'gym_name': gym.name,
            'previous_role': previous_role,
            'new_role': membership.role,
            'changed_by': str(actor.user_id),
        },
        # One row per role change, not one per repeated click.
        dedupe_key=f'gym-role-{membership.id}-{previous_role}-{membership.role}',
    )


def _notify_gym_removal(gym, membership, actor):
    from apps.notifications.tasks import create_notification

    create_notification.delay(
        recipient_id=str(membership.member.user_id),
        notification_type='gym_removed',
        title=f'You were removed from {gym.name}',
        body=f'{actor.display_name} removed you from {gym.name}.',
        metadata={
            'gym_handle': gym.handle,
            'gym_name': gym.name,
            'removed_by': str(actor.user_id),
        },
        dedupe_key=f'gym-removed-{membership.id}-{membership.id}',
    )


class ManageMemberView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug, user_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(GymMembership, gym=gym, member=request.user.profile, role__in=['owner', 'co_owner', 'moderator'])

        target = get_object_or_404(GymMembership, gym=gym, member_id=user_id)
        serializer = ManageMemberRoleSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        new_role = serializer.validated_data.get('role')

        # Symmetric with the removal guard below. Without it the lowest tier of
        # gym staff could demote the owner, and an owner demoted to 'member'
        # can no longer restore themselves -- a permanent lockout of the gym.
        if target.role in ['owner', 'co_owner']:
            return Response({
                'success': False, 'data': None,
                'message': (
                    'Cannot change the role of an owner or co-owner. '
                    'Transfer ownership first.'
                ),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        previous_role = target.role
        if new_role and new_role in dict(GymMembership.ROLE_CHOICES):
            if new_role in ['owner', 'co_owner']:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Use transfer ownership to change to owner/co-owner.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            target.role = new_role
            target.save(update_fields=['role'])
            # Silent demotions are the failure mode here: the member keeps
            # showing a moderator badge and quietly loses the permissions.
            _notify_gym_role_change(gym, target, previous_role, request.user.profile)

        return Response({
            'success': True, 'data': None,
            'message': f'Member role updated to {target.role}.',
            'errors': None,
            'pagination': None,
        })

    def delete(self, request, gym_slug, user_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        get_object_or_404(GymMembership, gym=gym, member=request.user.profile, role__in=['owner', 'co_owner', 'moderator'])

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

        _notify_gym_removal(gym, target, request.user.profile)

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
            # The applicant is waiting on this; approving silently leaves them
            # refreshing a page that never says yes.
            from apps.notifications.tasks import create_notification

            create_notification.delay(
                recipient_id=str(join_request.requester.user_id),
                notification_type='gym_joined',
                title=f'Welcome to {gym.name}',
                body=(
                    f'{request.user.profile.display_name} approved your request to '
                    f'join {gym.name}.'
                ),
                metadata={
                    'gym_handle': gym.handle,
                    'gym_name': gym.name,
                    'approved_by': str(request.user.profile.user_id),
                },
                dedupe_key=f'gym-joined-{join_request.id}-approved',
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
                f"You've been invited to join {gym.name} on BuddyUp Fit!",
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


class GymRoutinePostListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        posts = gym.routine_posts.all().select_related('author')
        
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(posts, request)
        serializer = GymRoutinePostSerializer(page, many=True)
        
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
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'trainer', 'moderator']
        )
        
        from .serializers import GymRoutinePostSerializer
        serializer = GymRoutinePostSerializer(data=request.data)
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
            'data': GymRoutinePostSerializer(post).data,
            'message': 'Schedule post created.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymRoutinePostDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, gym_slug, post_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        post = get_object_or_404(GymRoutinePost, id=post_id, gym=gym)
        get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'trainer', 'moderator'],
        )
        allowed = ['title', 'content', 'activity_type', 'custom_activity_type',
                    'location_mode', 'start_time', 'end_time', 'recurrence',
                    'recurrence_end_date', 'recurrence_days', 'max_slots', 'timezone']
        for k in allowed:
            if k in request.data:
                setattr(post, k, request.data[k])
        post.save(update_fields=[k for k in allowed if k in request.data])
        return Response({
            'success': True,
            'data': GymRoutinePostSerializer(post, context={'request': request}).data,
            'message': 'Schedule post updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, gym_slug, post_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        post = get_object_or_404(GymRoutinePost, id=post_id, gym=gym)
        membership = get_object_or_404(
            GymMembership, gym=gym, member=request.user.profile,
            role__in=['owner', 'co_owner', 'trainer', 'moderator'],
        )
        # PATCH above already lets the same roles edit anybody's schedule post,
        # so DELETE being narrower meant a moderator could rewrite a member's
        # post and then could not remove it. Deletion authority now matches the
        # other gym moderation surfaces: the author, or a partner-staff member.
        # `trainer` keeps edit-but-not-delete, which is the deliberate gap.
        if post.author != request.user.profile and membership.role not in PARTNER_ROLES:
            return Response({
                'success': False, 'data': None,
                'message': (
                    'Only the author or a gym owner, co-owner or moderator can '
                    'delete schedule posts.'
                ),
                'errors': None, 'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)
        post.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Schedule post deleted.',
            'errors': None, 'pagination': None,
        })


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

        serializer = DonationInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        artifact_type = data['artifact_type']
        quantity = data.get('quantity')
        message = data.get('message', '')

        if not quantity or quantity <= 0:
            return Response({
                'success': False, 'data': None,
                'message': 'Donation amount (quantity) is required and must be positive.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not deduct_artifacts(request.user.profile, artifact_type, quantity):
            return Response({
                'success': False, 'data': None,
                'message': f'Insufficient {artifact_type} balance.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_402_PAYMENT_REQUIRED)

        from apps.wallet.models import ArtifactTransaction

        fiat_value = round(ARTIFACT_VALUES.get(artifact_type, 0) * quantity, 2)

        donation = GymDonation.objects.create(
            gym=gym, donor=request.user.profile, amount=fiat_value, message=message
        )

        ArtifactTransaction.objects.create(
            user=request.user.profile,
            transaction_type='gym_subscription',
            artifact_type=artifact_type,
            quantity=quantity or 1,
            direction='debit',
            fiat_amount=fiat_value,
            status='completed',
            description=f'Donation to {gym.name}',
        )

        gym_wallet = dict(gym.wallet_balance) if gym.wallet_balance else {}
        gym_wallet['donations_received'] = gym_wallet.get('donations_received', 0.0) + fiat_value
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
        
        serializer = ReviewReplyInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        reply_text = serializer.validated_data['reply_text'].strip()
            
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
            routine_post = GymRoutinePost.objects.get(id=post_id, gym=gym)
        except (Gym.DoesNotExist, GymRoutinePost.DoesNotExist):
            return Response({'success': False, 'message': 'Not found.'}, status=404)

        profile = request.user.profile
        if not GymMembership.objects.filter(gym=gym, member=profile, subscription_active=True).exists():
            return Response({'success': False, 'message': 'You must be a member to enroll.'}, status=403)

        from .serializers import CreateEnrollmentSerializer, RoutineSlotEnrollmentSerializer
        from .models import RoutineSlotEnrollment
        ser = CreateEnrollmentSerializer(data=request.data)
        if not ser.is_valid():
            return Response({'success': False, 'errors': ser.errors}, status=400)

        enrollment, created = RoutineSlotEnrollment.objects.get_or_create(
            routine_post=routine_post,
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
        routine_post.slots_taken = RoutineSlotEnrollment.objects.filter(
            routine_post=routine_post, is_active=True
        ).count()
        routine_post.save(update_fields=['slots_taken'])

        return Response({'success': True, 'data': RoutineSlotEnrollmentSerializer(enrollment).data}, status=201)

    def delete(self, request, gym_slug, post_id):
        try:
            gym = Gym.objects.get(handle=gym_slug)
            routine_post = GymRoutinePost.objects.get(id=post_id, gym=gym)
            from .models import RoutineSlotEnrollment
            enrollment = RoutineSlotEnrollment.objects.get(
                routine_post=routine_post, member=request.user.profile
            )
        except Exception:  # noqa: BLE001
            return Response({'success': False, 'message': 'Enrollment not found.'}, status=404)

        enrollment.is_active = False
        enrollment.save()
        routine_post.slots_taken = max(0, routine_post.slots_taken - 1)
        routine_post.save(update_fields=['slots_taken'])
        return Response({'success': True, 'message': 'Unenrolled successfully.'})


class MySlotEnrollmentsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        from .models import RoutineSlotEnrollment
        from .serializers import RoutineSlotEnrollmentSerializer
        try:
            gym = Gym.objects.get(handle=gym_slug)
        except Gym.DoesNotExist:
            return Response({'success': False, 'message': 'Gym not found.'}, status=404)
        enrollments = RoutineSlotEnrollment.objects.filter(
            member=request.user.profile,
            routine_post__gym=gym,
            is_active=True
        ).select_related('routine_post')
        return Response({'success': True, 'data': RoutineSlotEnrollmentSerializer(enrollments, many=True).data})


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


# ---------------------------------------------------------------------------
# Phase A: business registration, gallery, online coaching, endorsements
# ---------------------------------------------------------------------------

REGISTRATION_DOCUMENT_TYPES = frozenset({
    'certification', 'proof_of_address', 'other',
})


def _require_verified_registration(gym):
    """Return the registered profile when the gym is a verified business."""
    try:
        profile = gym.registered_profile
    except RegisteredGymProfile.DoesNotExist:
        return None
    if profile.status != 'verified':
        return None
    return profile


class GymRegistrationView(views.APIView):
    """Read or edit the gym's business-registration metadata."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        profile, _ = RegisteredGymProfile.objects.get_or_create(gym=gym)
        return Response({'success': True, 'data': RegisteredGymProfileSerializer(profile).data})

    def patch(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        profile, _ = RegisteredGymProfile.objects.get_or_create(gym=gym)
        serializer = SubmitRegistrationSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        if profile.status in ('verified', 'pending'):
            return Response({
                'success': False, 'data': None,
                'message': 'Registration details cannot change while under review or verified.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_409_CONFLICT)
        profile = serializer.save()
        return Response({'success': True, 'data': RegisteredGymProfileSerializer(profile).data,
                         'message': 'Registration details saved.'})

    def post(self, request, gym_slug):
        """Submit (or resubmit) the gym for business verification."""
        from apps.verification.models import VerificationSubmission, VerificationDocument

        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        profile, _ = RegisteredGymProfile.objects.get_or_create(gym=gym)

        serializer = SubmitRegistrationSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        profile = serializer.save()

        if not profile.legal_name.strip() or not profile.registration_number.strip():
            return Response({
                'success': False, 'data': None,
                'message': 'Legal name and registration number are required to submit.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        document_ids = request.data.get('document_ids') or []
        if isinstance(document_ids, str):
            document_ids = [document_ids]
        documents = VerificationDocument.objects.filter(
            id__in=document_ids, profile=request.user.profile,
        ).distinct()
        if not documents.exists():
            return Response({
                'success': False, 'data': None,
                'message': 'Attach at least one registration document before submitting.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        submission = (
            VerificationSubmission.objects
            .filter(gym=gym, verification_type='gym')
            .exclude(status__in=['approved', 'rejected'])
            .order_by('-created_at')
            .first()
        )
        if submission is None:
            submission = VerificationSubmission.objects.create(
                profile=request.user.profile,
                gym=gym,
                verification_type='gym',
                status='submitted',
                submitted_at=timezone.now(),
            )
        else:
            submission.profile = request.user.profile
            submission.status = 'submitted'
            submission.submitted_at = timezone.now()
            submission.save(update_fields=['profile', 'status', 'submitted_at', 'updated_at'])
        submission.documents.set(documents)

        profile.status = 'pending'
        profile.submitted_at = timezone.now()
        profile.rejection_reason = ''
        profile.save(update_fields=['status', 'submitted_at', 'rejection_reason', 'updated_at'])

        return Response({
            'success': True,
            'data': RegisteredGymProfileSerializer(profile).data,
            'message': 'Submitted for verification. Review usually takes a few days.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GymVerificationStatusView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        profile, _ = RegisteredGymProfile.objects.get_or_create(gym=gym)
        data = RegisteredGymProfileSerializer(profile).data
        data['is_verified'] = gym.is_verified
        data['can_submit'] = profile.status in ('unverified', 'rejected')
        return Response({'success': True, 'data': data})


class GymMediaView(views.APIView):
    """Public gym gallery: photos and videos."""

    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        kind = request.query_params.get('kind', '')
        qs = gym.media.all()
        if kind in ('photo', 'video'):
            qs = qs.filter(kind=kind)
        return Response({'success': True, 'data': GymMediaSerializer(qs[:60], many=True).data})

    def post(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        uploads = request.FILES.getlist('file') or request.FILES.getlist('media')
        if not uploads:
            return Response({'success': False, 'message': 'No file provided.'}, status=400)

        kind = request.data.get('kind', 'photo')
        if kind not in ('photo', 'video'):
            kind = 'photo'
        caption = (request.data.get('caption') or '').strip()[:240]

        created = []
        for upload in uploads:
            if upload.size > 60 * 1024 * 1024:
                return Response({
                    'success': False,
                    'message': f'{upload.name} is larger than 60 MB.',
                }, status=400)
            ext = os.path.splitext(upload.name)[1].lower()
            saved_name = default_storage.save(
                f'gyms/{gym.id}/media/{uuid.uuid4().hex}{ext}',
                ContentFile(upload.read()),
            )
            created.append(GymMedia.objects.create(
                gym=gym,
                kind=kind,
                file_url=default_storage.url(saved_name),
                caption=caption,
                uploaded_by=request.user.profile,
            ))
        return Response({
            'success': True,
            'data': GymMediaSerializer(created, many=True).data,
            'message': 'Media uploaded.',
        }, status=status.HTTP_201_CREATED)


class GymMediaDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, gym_slug, media_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        item = get_object_or_404(GymMedia, id=media_id, gym=gym)
        item.delete()
        return Response({'success': True, 'data': None, 'message': 'Media removed.'})


class GymOnlineCoachingView(views.APIView):
    """Whether the gym sells online coaching, and which types it offers."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        coaches = gym.online_coaches.select_related('coach')
        return Response({'success': True, 'data': {
            'offers_online_coaching': gym.offers_online_coaching,
            'coaching_types': gym.coaching_types or [],
            'coaches': GymOnlineCoachSerializer(coaches, many=True).data,
        }})

    def patch(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        serializer = OnlineCoachingUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        for field in ('offers_online_coaching', 'coaching_types'):
            if field in serializer.validated_data:
                setattr(gym, field, serializer.validated_data[field])
        gym.save(update_fields=['offers_online_coaching', 'coaching_types', 'updated_at'])
        return Response({'success': True, 'data': {
            'offers_online_coaching': gym.offers_online_coaching,
            'coaching_types': gym.coaching_types or [],
        }, 'message': 'Online coaching updated.'})


class GymOnlineCoachListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        from apps.profiles.models import Profile

        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        serializer = AddOnlineCoachSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        target = None
        if serializer.validated_data.get('user_id'):
            target = Profile.objects.filter(user_id=serializer.validated_data['user_id']).first()
        elif serializer.validated_data.get('username'):
            target = Profile.objects.filter(
                username__iexact=serializer.validated_data['username'].strip(),
            ).first()
        if target is None:
            return Response({'success': False, 'message': 'Member not found.'}, status=404)

        if not GymMembership.objects.filter(
            gym=gym, member=target, subscription_active=True,
        ).exists():
            return Response({
                'success': False,
                'message': 'Only an active member can be listed as an online coach.',
            }, status=400)

        row, created = GymOnlineCoach.objects.update_or_create(
            gym=gym, coach=target,
            defaults={
                'specialties': serializer.validated_data.get('specialties', []),
                'is_available': serializer.validated_data.get('is_available', True),
                'note': serializer.validated_data.get('note', ''),
                'added_by': request.user.profile,
            },
        )
        return Response({
            'success': True,
            'data': GymOnlineCoachSerializer(row).data,
            'message': 'Coach added.' if created else 'Coach updated.',
        }, status=201 if created else 200)

    def delete(self, request, gym_slug, coach_id):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        row = get_object_or_404(GymOnlineCoach, id=coach_id, gym=gym)
        row.delete()
        return Response({'success': True, 'data': None, 'message': 'Coach removed.'})


class GymEndorsementListView(views.APIView):
    """Endorse an existing member trainer/practitioner for fast-track review."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, gym_slug):
        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        rows = gym.endorsements.select_related('trainer').filter(is_active=True)
        return Response({'success': True, 'data': {
            'can_endorse': _require_verified_registration(gym) is not None,
            'endorsements': GymTrainerEndorsementSerializer(rows, many=True).data,
        }})

    def post(self, request, gym_slug):
        from apps.profiles.models import Profile
        from apps.verification.models import VerificationSubmission

        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        if _require_verified_registration(gym) is None:
            return Response({
                'success': False,
                'message': 'Only a verified registered gym can endorse trainers.',
            }, status=403)

        serializer = CreateEndorsementSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        target = None
        if serializer.validated_data.get('user_id'):
            target = Profile.objects.filter(user_id=serializer.validated_data['user_id']).first()
        elif serializer.validated_data.get('username'):
            target = Profile.objects.filter(
                username__iexact=serializer.validated_data['username'].strip(),
            ).first()
        if target is None:
            return Response({'success': False, 'message': 'Trainer not found.'}, status=404)

        if not GymMembership.objects.filter(
            gym=gym, member=target, subscription_active=True,
        ).exists():
            return Response({
                'success': False,
                'message': 'Only an active member of this gym can be endorsed.',
            }, status=400)

        row, created = GymTrainerEndorsement.objects.update_or_create(
            gym=gym, trainer=target,
            defaults={
                'endorsed_by': request.user.profile,
                'note': serializer.validated_data.get('note', ''),
                'is_active': True,
            },
        )

        # Fast-track any reviewable submission the trainer already has. A
        # later submission picks this up from ``perform_create`` instead.
        submission = VerificationSubmission.objects.filter(
            profile=target,
            verification_type__in=['trainer', 'practitioner'],
            status__in=['submitted', 'under_review'],
        ).order_by('-created_at').first()
        if submission is not None:
            submission.fast_track = True
            submission.endorsed_by_gym = gym
            submission.save(update_fields=['fast_track', 'endorsed_by_gym', 'updated_at'])

        return Response({
            'success': True,
            'data': GymTrainerEndorsementSerializer(row).data,
            'message': 'Endorsed. Their verification is now fast-tracked.',
        }, status=201 if created else 200)

    def delete(self, request, gym_slug, endorsement_id):
        from apps.verification.models import VerificationSubmission

        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        row = get_object_or_404(GymTrainerEndorsement, id=endorsement_id, gym=gym)
        VerificationSubmission.objects.filter(
            endorsed_by_gym=gym, profile=row.trainer,
            status__in=['submitted', 'under_review'],
        ).update(fast_track=False, endorsed_by_gym=None)
        row.is_active = False
        row.save(update_fields=['is_active'])
        return Response({'success': True, 'data': None, 'message': 'Endorsement withdrawn.'})


class GymAnnounceView(views.APIView):
    """Post an announcement to the gym feed and notify members."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, gym_slug):
        from apps.feed.models import Post
        from apps.notifications.tasks import create_notification

        gym = get_object_or_404(Gym, handle__iexact=gym_slug)
        _require_partner_staff(gym, request.user.profile)
        serializer = GymAnnouncementSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        post = Post.objects.create(
            author=request.user.profile,
            post_type='text',
            body=serializer.validated_data['body'],
            gym_tag=gym,
            visibility='gym_members',
            is_pinned=True,
        )

        notified = 0
        if serializer.validated_data.get('notify_members', True):
            members = GymMembership.objects.filter(
                gym=gym, subscription_active=True,
            ).exclude(member=request.user.profile).select_related('member')
            for membership in members:
                try:
                    create_notification.delay(
                        recipient_id=str(membership.member.user_id),
                        notification_type='gym_announcement',
                        title=serializer.validated_data['title'],
                        body=serializer.validated_data['body'][:280],
                        metadata={
                            'gym_handle': gym.handle,
                            'gym_name': gym.name,
                            'post_id': str(post.id),
                        },
                        dedupe_key=f'gym-announcement-{post.id}-{membership.member.user_id}',
                    )
                    notified += 1
                except Exception:  # noqa: BLE001 — notification must not drop the post
                    logger.warning('gym announcement notification failed', exc_info=True)

        return Response({
            'success': True,
            'data': {'post_id': str(post.id), 'notified': notified},
            'message': 'Announcement posted.',
        }, status=status.HTTP_201_CREATED)
