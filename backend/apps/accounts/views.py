import uuid
import hashlib
import secrets
from datetime import timedelta

from django.utils import timezone
from django.contrib.auth import authenticate
from django.conf import settings
from rest_framework import status, views, permissions, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken

from common.utils import hash_dob, calculate_age
from common.pagination import CursorPagination
from .models import User, OTPToken, DeviceSession, AccountEvent
from .serializers import (
    RegisterSerializer, LoginSerializer, OTPSerializer,
    ResendOTPSerializer, PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer, ChangePasswordSerializer,
    SocialAuthSerializer, TOTPSetupSerializer, TOTPVerifySerializer,
)
from apps.profiles.models import Profile


def _get_client_ip(request):
    xf = request.META.get('HTTP_X_FORWARDED_FOR')
    if xf:
        return xf.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR', '0.0.0.0')


def _get_user_agent(request):
    return request.META.get('HTTP_USER_AGENT', '')


def _generate_otp():
    return str(secrets.randbelow(10 ** 6)).zfill(6)


def _get_tokens_for_user(user, remember_me=False):
    refresh = RefreshToken.for_user(user)
    refresh['device_id'] = str(uuid.uuid4())
    if remember_me:
        refresh.set_exp(lifetime=timedelta(days=30))
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'expires_in': int(refresh.access_token.lifetime.total_seconds()),
    }


def _create_device_session(user, refresh_token, request):
    token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
    DeviceSession.objects.create(
        user=user,
        refresh_token_hash=token_hash,
        device_name=_get_user_agent(request)[:200],
        ip_address=_get_client_ip(request),
        location='',
    )


def _log_event(user, event_type, request, metadata=None):
    AccountEvent.objects.create(
        user=user,
        event_type=event_type,
        ip_address=_get_client_ip(request),
        user_agent=_get_user_agent(request),
        metadata=metadata or {},
    )


class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'registration'

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user = User.objects.create_user(
            email=data['email'],
            password=data['password'],
            phone=data.get('phone', ''),
            dob_hash=hash_dob(data['dob']),
            is_adult=data['age'] >= 18,
            last_login_ip=_get_client_ip(request),
            consent_log={
                'tos_version': '1.0',
                'privacy_version': '1.0',
                'guidelines_version': '1.0',
                'accepted_terms': data['accepted_terms'],
                'accepted_privacy': data['accepted_privacy'],
                'accepted_guidelines': data['accepted_guidelines'],
                'is_16_plus': data['is_16_plus'],
                'consented_at': timezone.now().isoformat(),
                'ip': _get_client_ip(request),
            },
        )

        Profile.objects.create(
            user=user,
            username=data['username'],
            display_name=data['display_name'],
            role=data['role'],
            privacy_level='private',
        )

        otp = _generate_otp()
        OTPToken.objects.create(
            user=user,
            code=otp,
            channel='email',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        # TODO: send OTP via SendGrid
        print(f"[DEV] OTP for {user.email}: {otp}")

        _log_event(user, 'login', request)

        tokens = _get_tokens_for_user(user)
        _create_device_session(user, tokens['refresh'], request)

        return Response({
            'success': True,
            'data': {
                'access': tokens['access'],
                'refresh': tokens['refresh'],
                'user': {
                    'id': str(user.id),
                    'email': user.email,
                    'email_verified': user.email_verified,
                    'phone_verified': user.phone_verified,
                    'is_adult': user.is_adult,
                    'created_at': user.created_at.isoformat(),
                },
                'profile': {
                    'user_id': str(user.id),
                    'username': data['username'],
                    'display_name': data['display_name'],
                    'bio': '',
                    'avatar_url': '',
                    'cover_url': '',
                    'pronouns': '',
                    'location_city': '',
                    'location_country': '',
                    'role': data['role'],
                    'verification_status': 'none',
                    'privacy_level': 'private',
                    'streak_days': 0,
                    'artifact_balance': {},
                    'buddy_count': 0,
                    'following_count': 0,
                    'follower_count': 0,
                    'gym_count': 0,
                    'post_count': 0,
                    'show_active_status': True,
                    'is_anonymous_posting': False,
                    'external_link': '',
                    'workout_schedule': None,
                    'created_at': timezone.now().isoformat(),
                    'updated_at': timezone.now().isoformat(),
                    'is_buddy': False,
                    'is_following': False,
                    'buddy_status': None,
                    'is_blocked': False,
                },
                'message': 'Account created. Please verify your email.',
            },
            'message': 'Registration successful',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class LoginView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'login'

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user = authenticate(request, email=data['email'], password=data['password'])

        if user is None:
            try:
                u = User.objects.get(email__iexact=data['email'])
                _log_event(u, 'login_failed', request)
            except User.DoesNotExist:
                pass
            return Response({
                'success': False,
                'data': None,
                'message': 'Invalid email or password.',
                'errors': {'credentials': ['Invalid email or password.']},
                'pagination': None,
            }, status=status.HTTP_401_UNAUTHORIZED)

        if not user.is_active:
            return Response({
                'success': False,
                'data': None,
                'message': 'This account has been deactivated.',
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        if user.deleted_at:
            return Response({
                'success': False,
                'data': None,
                'message': 'This account has been deleted.',
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        user.last_login_ip = _get_client_ip(request)
        user.save(update_fields=['last_login_ip'])

        tokens = _get_tokens_for_user(user, remember_me=data.get('remember_me', False))
        _create_device_session(user, tokens['refresh'], request)

        new_device = False
        existing_ips = DeviceSession.objects.filter(
            user=user, is_active=True
        ).values_list('ip_address', flat=True).distinct()
        if _get_client_ip(request) not in existing_ips and existing_ips:
            new_device = True

        _log_event(user, 'login' if not new_device else 'login_new_device', request,
                   metadata={'new_device': new_device})

        from apps.profiles.serializers import ProfileSerializer
        profile = ProfileSerializer(user.profile).data

        return Response({
            'success': True,
            'data': {
                'access': tokens['access'],
                'refresh': tokens['refresh'],
                'user': {
                    'id': str(user.id),
                    'email': user.email,
                    'email_verified': user.email_verified,
                    'phone_verified': user.phone_verified,
                    'is_adult': user.is_adult,
                    'created_at': user.created_at.isoformat(),
                },
                'profile': profile,
                'new_device': new_device,
            },
            'message': 'Login successful',
            'errors': None,
            'pagination': None,
        })


class LogoutView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if refresh_token:
            token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
            DeviceSession.objects.filter(
                user=request.user, refresh_token_hash=token_hash
            ).update(is_active=False)
            try:
                token = RefreshToken(refresh_token)
                token.blacklist()
            except Exception:
                pass

        return Response({
            'success': True,
            'data': None,
            'message': 'Logged out successfully',
            'errors': None,
            'pagination': None,
        })


class TokenRefreshView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({
                'success': False, 'data': None,
                'message': 'Refresh token is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            token = RefreshToken(refresh_token)
            access = str(token.access_token)
            token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
            DeviceSession.objects.filter(
                refresh_token_hash=token_hash
            ).update(last_active=timezone.now())

            return Response({
                'success': True,
                'data': {'access': access},
                'message': 'Token refreshed',
                'errors': None,
                'pagination': None,
            })
        except Exception:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired refresh token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_401_UNAUTHORIZED)


class VerifyOTPView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = OTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            otp_token = OTPToken.objects.filter(
                user=request.user,
                channel=data['channel'],
                is_used=False,
            ).latest('created_at')
        except OTPToken.DoesNotExist:
            return Response({
                'success': False, 'data': None,
                'message': 'No pending verification. Please request a new OTP.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not otp_token.is_valid():
            return Response({
                'success': False, 'data': None,
                'message': 'OTP has expired or been used.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if otp_token.code != data['otp']:
            otp_token.attempts += 1
            otp_token.save(update_fields=['attempts'])
            if otp_token.attempts >= 3:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Too many failed attempts. Please request a new OTP after 30 minutes.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_429_TOO_MANY_REQUESTS)
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid OTP code.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        otp_token.is_used = True
        otp_token.save(update_fields=['is_used'])

        if data['channel'] == 'email':
            request.user.email_verified = True
        else:
            request.user.phone_verified = True
        request.user.save(update_fields=['email_verified', 'phone_verified'])

        profile = request.user.profile
        if profile.verification_status == 'none':
            profile.verification_status = 'email'
            profile.save(update_fields=['verification_status'])

        from apps.profiles.serializers import ProfileSerializer
        return Response({
            'success': True,
            'data': {'profile': ProfileSerializer(profile).data},
            'message': f'{data["channel"].title()} verified successfully.',
            'errors': None,
            'pagination': None,
        })


class ResendOTPView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'otp'

    def post(self, request):
        serializer = ResendOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        recent = OTPToken.objects.filter(
            user=request.user,
            channel=data['channel'],
            created_at__gte=timezone.now() - timedelta(seconds=60),
        ).exists()
        if recent:
            return Response({
                'success': False, 'data': None,
                'message': 'Please wait 60 seconds before requesting a new OTP.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_429_TOO_MANY_REQUESTS)

        otp = _generate_otp()
        OTPToken.objects.create(
            user=request.user,
            code=otp,
            channel=data['channel'],
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        # TODO: send OTP via SendGrid/SMS
        print(f"[DEV] OTP for {request.user.email}: {otp}")

        return Response({
            'success': True,
            'data': None,
            'message': f'New OTP sent to your {data["channel"]}.',
            'errors': None,
            'pagination': None,
        })


class PasswordResetRequestView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            user = User.objects.get(email__iexact=serializer.validated_data['email'])
        except User.DoesNotExist:
            return Response({
                'success': True, 'data': None,
                'message': 'If that email is registered, a reset link has been sent.',
                'errors': None, 'pagination': None,
            })

        otp = _generate_otp()
        OTPToken.objects.create(
            user=user,
            code=otp,
            channel='email',
            expires_at=timezone.now() + timedelta(minutes=30),
        )
        print(f"[DEV] Password reset OTP for {user.email}: {otp}")

        return Response({
            'success': True, 'data': None,
            'message': 'If that email is registered, a reset link has been sent.',
            'errors': None, 'pagination': None,
        })


class PasswordResetConfirmView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            otp_token = OTPToken.objects.get(
                code=data['token'], channel='email', is_used=False,
                expires_at__gt=timezone.now(),
            )
        except OTPToken.DoesNotExist:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired reset token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        user = otp_token.user
        user.set_password(data['new_password'])
        user.save()

        otp_token.is_used = True
        otp_token.save(update_fields=['is_used'])

        DeviceSession.objects.filter(user=user).update(is_active=False)

        _log_event(user, 'password_changed', request)

        return Response({
            'success': True, 'data': None,
            'message': 'Password reset successfully. Please log in with your new password.',
            'errors': None, 'pagination': None,
        })


class ChangePasswordView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if not request.user.check_password(data['current_password']):
            return Response({
                'success': False, 'data': None,
                'message': 'Current password is incorrect.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        request.user.set_password(data['new_password'])
        request.user.save()

        _log_event(request.user, 'password_changed', request)

        return Response({
            'success': True, 'data': None,
            'message': 'Password changed successfully.',
            'errors': None, 'pagination': None,
        })


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def health_check(request):
    from django.db import connections
    from django.db.utils import OperationalError

    db_ok = True
    try:
        connections['default'].cursor()
    except OperationalError:
        db_ok = False

    return Response({
        'status': 'ok' if db_ok else 'degraded',
        'service': 'buddyup-api',
        'version': '1.0.0',
        'database': 'connected' if db_ok else 'disconnected',
    })
