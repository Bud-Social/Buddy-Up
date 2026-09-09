import re
import secrets
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import permissions, status, views
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle

from apps.analytics.models import WorkoutLog
from apps.feed.models import Post
from apps.profiles.models import Profile
from apps.sessions.models import BookingSession
from common.utils import calculate_age, hash_dob

from . import tasks
from .models import GuardianLink
from .serializers import (
    GuardianAcceptInviteInputSerializer,
    GuardianInviteInputSerializer,
    GuardianLinkSerializer,
    GuardianPermissionsInputSerializer,
)
from .services import guardian_display_name, hash_token

User = get_user_model()


def _generate_invite_token() -> str:
    return secrets.token_urlsafe(32)


def _generate_username(base: str) -> str:
    """Collision-safe username from an email local part (accounts-style)."""
    base = re.sub(r'[^a-zA-Z0-9_]', '', base).lower()[:24] or 'buddy'
    if not Profile.objects.filter(username=base).exists():
        return base
    for i in range(2, 100):
        candidate = f'{base}{i}'
        if not Profile.objects.filter(username=candidate).exists():
            return candidate
    return f'{base}_{secrets.token_hex(2)}'


def _frontend_url() -> str:
    from django.conf import settings

    return getattr(settings, 'PUBLIC_FRONTEND_URL', 'https://buddyup.app').rstrip('/')


def _error(message, code=status.HTTP_400_BAD_REQUEST, errors=None):
    return Response({
        'success': False, 'data': None, 'message': message,
        'errors': errors, 'pagination': None,
    }, status=code)


class GuardianInviteView(views.APIView):
    """POST /guardians/invite/ — connect to an existing teen or provision one."""
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'guardian_invite'

    def post(self, request):
        if not request.user.is_adult:
            return _error(
                'Only adult accounts can send guardian invites.',
                code=status.HTTP_403_FORBIDDEN,
            )
        input_serializer = GuardianInviteInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        teen_email = input_serializer.validated_data['teen_email'].lower().strip()
        teen_name = input_serializer.validated_data.get('teen_name', '')
        teen_dob = input_serializer.validated_data.get('teen_dob')

        if teen_email == (request.user.email or '').lower():
            return _error('You cannot invite yourself as a teen.')

        existing = User.objects.filter(email__iexact=teen_email).first()
        if existing is not None:
            link, created = GuardianLink.objects.get_or_create(
                guardian=request.user,
                teen=existing,
                defaults={'status': 'pending', 'invite_email': teen_email},
            )
            if not created:
                link.invite_email = teen_email
                if link.status == 'revoked':
                    link.status = 'pending'
                    link.accepted_at = None
                    link.invite_token_hash = ''
                link.save(update_fields=['invite_email', 'status', 'accepted_at',
                                         'invite_token_hash', 'updated_at'])
            tasks.send_guardian_invite_existing_email.delay(
                str(link.id), guardian_display_name(request.user), teen_email,
            )
            return Response({
                'success': True,
                'data': GuardianLinkSerializer(link, context={'request': request}).data,
                'message': 'Invitation sent.' if created else 'Invitation updated.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)

        if teen_dob is not None and calculate_age(teen_dob) >= 18:
            return _error('Invited teen must be under 18.')

        raw_token = _generate_invite_token()
        with transaction.atomic():
            teen = User.objects.create_user(
                email=teen_email,
                password=None,
                dob_hash=hash_dob(teen_dob) if teen_dob else '',
                is_adult=False,
                email_verified=False,
            )
            username = _generate_username(teen_email.split('@')[0])
            Profile.objects.create(
                user=teen,
                username=username,
                display_name=teen_name or username,
                role='user',
                privacy_level='private',
                onboarding_completed=False,
            )
            link = GuardianLink.objects.create(
                guardian=request.user,
                teen=teen,
                status='pending',
                invite_email=teen_email,
                invite_token_hash=hash_token(raw_token),
            )

        accept_url = f'{_frontend_url()}/settings/family/accept?token={raw_token}'
        tasks.send_guardian_invite_new_email.delay(
            str(link.id), guardian_display_name(request.user), teen_email, accept_url,
        )
        return Response({
            'success': True,
            'data': GuardianLinkSerializer(link, context={'request': request}).data,
            'message': 'Teen account created and invitation sent.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class GuardianLinksListView(views.APIView):
    """GET /guardians/links/ — the requester's links split by role."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        links = (
            GuardianLink.objects
            .filter(Q(guardian=request.user) | Q(teen=request.user))
            .select_related('guardian', 'teen')
            .order_by('-created_at')
        )
        context = {'request': request}
        as_guardian = [link for link in links if link.guardian_id == request.user.id]
        as_teen = [link for link in links if link.teen_id == request.user.id]
        return Response({
            'success': True,
            'data': {
                'as_guardian': GuardianLinkSerializer(as_guardian, many=True, context=context).data,
                'as_teen': GuardianLinkSerializer(as_teen, many=True, context=context).data,
            },
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class GuardianLinkAcceptView(views.APIView):
    """POST /guardians/links/<id>/accept/ — teen accepts a pending link."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, link_id):
        link = get_object_or_404(GuardianLink, id=link_id, teen=request.user)
        if link.status != 'pending':
            return _error('This invitation is not pending.')
        link.status = 'active'
        link.accepted_at = timezone.now()
        link.save(update_fields=['status', 'accepted_at', 'updated_at'])
        if not link.teen.guardian_verified:
            link.teen.guardian_verified = True
            link.teen.save(update_fields=['guardian_verified'])
        return Response({
            'success': True,
            'data': GuardianLinkSerializer(link, context={'request': request}).data,
            'message': 'Family link accepted.',
            'errors': None, 'pagination': None,
        })


class GuardianLinkDeleteView(views.APIView):
    """DELETE /guardians/links/<id>/ — guardian or teen revokes the link."""
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, link_id):
        link = get_object_or_404(
            GuardianLink.objects.select_related('guardian', 'teen'), id=link_id,
        )
        if request.user.id not in (link.guardian_id, link.teen_id):
            return _error(
                'Only the guardian or the teen can manage this link.',
                code=status.HTTP_403_FORBIDDEN,
            )
        link.status = 'revoked'
        link.save(update_fields=['status', 'updated_at'])
        return Response({
            'success': True,
            'data': GuardianLinkSerializer(link, context={'request': request}).data,
            'message': 'Family link revoked.',
            'errors': None, 'pagination': None,
        })


class GuardianLinkPermissionsView(views.APIView):
    """PATCH /guardians/links/<id>/permissions/ — guardian only."""
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, link_id):
        link = get_object_or_404(GuardianLink, id=link_id, guardian=request.user)
        input_serializer = GuardianPermissionsInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        changes = dict(input_serializer.validated_data)
        if not changes:
            return _error('No permission changes provided.')
        permissions_map = dict(link.permissions or {})
        permissions_map.update(changes)
        link.permissions = permissions_map
        link.save(update_fields=['permissions', 'updated_at'])
        return Response({
            'success': True,
            'data': GuardianLinkSerializer(link, context={'request': request}).data,
            'message': 'Permissions updated.',
            'errors': None, 'pagination': None,
        })


class GuardianDashboardView(views.APIView):
    """GET /guardians/dashboard/ — aggregates per active teen link (no content)."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not request.user.is_adult:
            return _error(
                'Only parental co-owners can view the family dashboard.',
                code=status.HTTP_403_FORBIDDEN,
            )
        links = (
            GuardianLink.objects
            .filter(guardian=request.user, status='active')
            .select_related('teen')
        )
        now = timezone.now()
        week_ago = now - timedelta(days=7)
        data = []
        for link in links:
            teen = link.teen
            profile = Profile.objects.filter(pk=teen.id).first()
            data.append({
                'link_id': link.id,
                'teen': {
                    'username': profile.username if profile else '',
                    'display_name': profile.display_name if profile else '',
                    'avatar_url': profile.avatar_url if profile else '',
                },
                'account_age_days': max((now - teen.created_at).days, 0),
                'last_active': profile.last_seen.isoformat()
                if profile and profile.last_seen else None,
                'posts_last_7d': (
                    Post.objects.filter(
                        author_id=teen.id, is_deleted=False, created_at__gte=week_ago,
                    ).count() if profile else 0
                ),
                'workouts_last_7d': (
                    WorkoutLog.objects.filter(
                        user_id=teen.id, created_at__gte=week_ago,
                    ).count() if profile else 0
                ),
                'upcoming_sessions': BookingSession.objects.filter(
                    client_id=teen.id,
                    status__in=['pending', 'confirmed'],
                    scheduled_at__gte=now,
                ).count(),
                'permissions': link.permissions,
            })
        return Response({
            'success': True, 'data': data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class GuardianAcceptInviteView(views.APIView):
    """POST /guardians/accept-invite/ — token + password claims a new teen account."""
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'otp'

    def post(self, request):
        input_serializer = GuardianAcceptInviteInputSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        invite_token = input_serializer.validated_data['invite_token'].strip()
        new_password = input_serializer.validated_data['new_password']

        link = (
            GuardianLink.objects
            .filter(invite_token_hash=hash_token(invite_token), status='pending')
            .select_related('teen')
            .first()
        )
        if link is None or link.teen.has_usable_password():
            return _error('Invalid or expired invite link.')

        teen = link.teen
        try:
            validate_password(new_password, user=teen)
        except DjangoValidationError as exc:
            return _error(
                ' '.join(exc.messages) or 'Password does not meet the requirements.',
                errors={'new_password': list(exc.messages)},
            )

        teen.set_password(new_password)
        teen.email_verified = True
        teen.guardian_verified = True
        teen.save(update_fields=['password', 'email_verified', 'guardian_verified'])
        link.status = 'active'
        link.accepted_at = timezone.now()
        link.invite_token_hash = ''
        link.save(update_fields=['status', 'accepted_at', 'invite_token_hash', 'updated_at'])
        return Response({
            'success': True,
            'data': GuardianLinkSerializer(link, context={'request': request}).data,
            'message': 'Password set. Your BuddyUp account is ready.',
            'errors': None, 'pagination': None,
        })
