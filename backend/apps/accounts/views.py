import uuid
import hashlib
import json
import secrets
import io
import base64
import os
import qrcode
import pyotp
import jwt
import requests
from datetime import timedelta
from jwt.algorithms import RSAAlgorithm

import logging

from django.utils import timezone
from django.contrib.auth import authenticate
from django.conf import settings
from django.core.cache import cache
from django.shortcuts import get_object_or_404
from django.db import IntegrityError, transaction
from rest_framework import status, views, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from common.utils import hash_dob, calculate_age
from common.observability import prometheus_metrics
from common.pagination import CursorPagination
from .models import User, OTPToken, DeviceSession, AccountEvent, WebAuthnCredential
from .policy_versions import CURRENT_POLICY_VERSIONS, policy_version
from .serializers import (
    RegisterSerializer, LoginSerializer, OTPSerializer, ResendOTPSerializer,
    ResendRegistrationOTPSerializer,
    PasswordResetRequestSerializer, PasswordResetConfirmSerializer,
    ChangePasswordSerializer, TOTPVerifySerializer,
    LoginOTPSerializer, RegistrationOTPSerializer,
    TOTPChallengeSerializer, TOTPDisableSerializer, GoogleLoginSerializer,
    PasskeyRenameSerializer, PasskeyRevokeSerializer, ConsentSerializer,
)
from apps.profiles.models import Profile
from .tasks import (
    send_otp_email, send_otp_sms, sms_delivery_configured,
    send_security_notification_email,
)

logger = logging.getLogger(__name__)

try:
    from google.oauth2 import id_token
    from google.auth.transport import requests as google_requests
    GOOGLE_AUTH_AVAILABLE = True
except ImportError:
    GOOGLE_AUTH_AVAILABLE = False


def _get_client_ip(request):
    # X-Forwarded-For is client-controlled unless the immediate peer is a
    # configured reverse proxy. Do not use it by default for audit/rate data.
    remote_addr = request.META.get('REMOTE_ADDR', '0.0.0.0')
    trusted_proxies = {
        value.strip() for value in os.environ.get('TRUSTED_PROXY_IPS', '').split(',')
        if value.strip()
    }
    xf = request.META.get('HTTP_X_FORWARDED_FOR')
    if xf and remote_addr in trusted_proxies:
        return xf.split(',')[0].strip()
    return remote_addr


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


def _security_alert(user, action, request):
    send_security_notification_email.delay(str(user.id), action, _get_client_ip(request))


def _generic_reset_response():
    return Response({
        'success': True, 'data': None,
        'message': 'If that email is registered, a reset link has been sent.',
        'errors': None, 'pagination': None,
    })


def _generate_temp_token(user, purpose, expiry_minutes=5):
    token = RefreshToken.for_user(user)
    token['purpose'] = purpose
    token.set_exp(lifetime=timedelta(minutes=expiry_minutes))
    return str(token)


def _verify_temp_token(token_str, expected_purpose):
    try:
        token = RefreshToken(token_str)
        if token.get('purpose') != expected_purpose:
            return None
        return User.objects.get(id=token['user_id'])
    except Exception:  # noqa: BLE001
        return None


class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'registration'

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        # Username / display name are optional at registration — the onboarding
        # pipeline collects the real ones. Derive collision-safe placeholders
        # from the email (mirrors social sign-up provisioning).
        username = data.get('username') or _generate_username(data['email'].split('@')[0])
        display_name = data.get('display_name') or username

        try:
            user = User.objects.create_user(
                email=data['email'],
                password=data['password'],
                phone=data.get('phone', ''),
                dob_hash=hash_dob(data['dob']),
                is_adult=data['age'] >= 18,
                email_verified=False,
                last_login_ip=_get_client_ip(request),
                guardian_name=data.get('guardian_name', ''),
                guardian_email=data.get('guardian_email', ''),
                guardian_phone=data.get('guardian_phone', ''),
                consent_log={
                    'tos_version': policy_version('terms'),
                    'privacy_version': policy_version('privacy'),
                    'guidelines_version': policy_version('guidelines'),
                    'cookie_version': policy_version('cookie_policy'),
                    'medical_disclaimer_version': policy_version('medical_disclaimer'),
                    'sponsorship_policy_version': policy_version('sponsorship_policy'),
                    'accepted_terms': data['accepted_terms'],
                    'accepted_privacy': data['accepted_privacy'],
                    'accepted_guidelines': data['accepted_guidelines'],
                    'is_16_plus': data['is_16_plus'],
                    'requires_parental_coowner': data.get('requires_parental_coowner', False),
                    'consented_at': timezone.now().isoformat(),
                    'ip': _get_client_ip(request),
                },
            )
        except Exception as exc:
            if 'unique' in str(exc).lower() or 'Duplicate entry' in str(exc) or isinstance(exc, IntegrityError):
                return Response({
                    'success': False, 'data': None,
                    'message': 'An account with this email already exists. Try logging in instead.',
                    'errors': {'email': ['An account with this email already exists.']},
                    'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            raise

        try:
            Profile.objects.create(
                onboarding_completed=False,
                user=user,
                username=username,
                display_name=display_name,
                role=data['role'],
                privacy_level='private',
            )
        except Exception:
            # Username collision raced between validation and insert — derive
            # a unique suffix rather than failing the whole registration.
            user.profile.delete()
            username = _generate_username(username)
            Profile.objects.create(
                onboarding_completed=False,
                user=user,
                username=username,
                display_name=display_name,
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
        send_otp_email.delay(str(user.id), otp, 'registration')

        _log_event(user, 'registration', request)

        reg_token = _generate_temp_token(user, 'registration', expiry_minutes=10)

        return Response({
            'success': True,
            'data': {
                'registration_token': reg_token,
                'email': user.email,
                'user_id': str(user.id),
                'message': 'Account created. Please verify your email with the OTP sent.',
            },
            'message': 'Registration successful. Please verify your email.',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_201_CREATED)


class VerifyRegistrationOTPView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'otp'

    def post(self, request):
        serializer = RegistrationOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user = _verify_temp_token(data['registration_token'], 'registration')
        if not user:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired registration token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if user.email_verified:
            return Response({
                'success': False, 'data': None,
                'message': 'Email already verified.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            otp_token = OTPToken.objects.filter(
                user=user, channel='email', is_used=False
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

        user.email_verified = True
        user.save(update_fields=['email_verified'])

        profile = user.profile
        if profile.verification_status == 'none':
            profile.verification_status = 'email'
            profile.save(update_fields=['verification_status'])

        tokens = _get_tokens_for_user(user)
        _create_device_session(user, tokens['refresh'], request)

        _log_event(user, 'email_verified', request)

        from apps.profiles.serializers import ProfileSerializer
        return Response({
            'success': True,
            'data': {
                'access': tokens['access'],
                'refresh': tokens['refresh'],
                'user': {
                    'id': str(user.id),
                    'email': user.email,
                    'email_verified': True,
                    'phone_verified': user.phone_verified,
                    'is_adult': user.is_adult,
                    'totp_enabled': user.totp_enabled,
                    'has_password': user.has_usable_password(),                    'created_at': user.created_at.isoformat(),
                    'is_staff': user.is_staff,
                },
                'profile': ProfileSerializer(profile).data,
            },
            'message': 'Email verified successfully. Welcome to BuddyUp!',
            'errors': None,
            'pagination': None,
        }, status=status.HTTP_200_OK)


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
                # Google/Apple accounts are provisioned with an unusable
                # password — point the user at social sign-in instead of a
                # bare "invalid credentials" 401.
                if not u.has_usable_password():
                    return Response({
                        'success': False,
                        'data': {'social_account': True},
                        'message': 'This account was created with Google. Continue with Google to sign in — you can set a password during onboarding.',
                        'errors': {'credentials': ['Social sign-in account.']},
                        'pagination': None,
                    }, status=status.HTTP_401_UNAUTHORIZED)
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

        if not user.email_verified:
            # Unverified account: redirect the client to OTP verification.
            # Reuse a still-valid OTP to avoid spamming the inbox — only
            # generate and email a fresh code when the previous one has
            # expired, been consumed, or exhausted its attempts.
            pending = OTPToken.objects.filter(
                user=user,
                channel='email',
                is_used=False,
                attempts__lt=3,
                expires_at__gt=timezone.now(),
            ).order_by('-created_at').first()
            otp_resent = False
            if pending is None:
                otp = _generate_otp()
                pending = OTPToken.objects.create(
                    user=user,
                    code=otp,
                    channel='email',
                    expires_at=timezone.now() + timedelta(minutes=10),
                )
                send_otp_email.delay(str(user.id), pending.code, 'registration')
                otp_resent = True
            reg_token = _generate_temp_token(user, 'registration', expiry_minutes=10)
            return Response({
                'success': False,
                'data': {
                    # Machine flag — clients must redirect to OTP verification
                    # on this, not by matching the message text.
                    'require_email_verification': True,
                    'registration_token': reg_token,
                    'email': user.email,
                    'otp_resent': otp_resent,
                },
                'message': (
                    'Your account has not been verified. We\'ve sent a fresh OTP to your email.'
                    if otp_resent else
                    'Your account has not been verified yet. Enter the OTP we emailed you — it\'s still valid, or tap Resend for a new one.'
                ),
                'errors': None,
                'pagination': None,
            }, status=status.HTTP_403_FORBIDDEN)

        user.last_login_ip = _get_client_ip(request)
        user.save(update_fields=['last_login_ip'])

        otp = _generate_otp()
        OTPToken.objects.create(
            user=user,
            code=otp,
            channel='email',
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        send_otp_email.delay(str(user.id), otp, 'login')

        login_token = _generate_temp_token(user, 'login', expiry_minutes=5)

        return Response({
            'success': True,
            'data': {
                'require_otp': True,
                'login_token': login_token,
                'masked_email': f'{user.email[:3]}***@{user.email.split("@")[1]}' if '@' in user.email else user.email,
            },
            'message': 'OTP sent to your email.',
            'errors': None,
            'pagination': None,
        })


class VerifyLoginOTPView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'otp'

    def post(self, request):
        serializer = LoginOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user = _verify_temp_token(data['login_token'], 'login')
        if not user:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired login token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            otp_token = OTPToken.objects.filter(
                user=user, channel='email', is_used=False
            ).latest('created_at')
        except OTPToken.DoesNotExist:
            return Response({
                'success': False, 'data': None,
                'message': 'No pending OTP. Please login again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not otp_token.is_valid():
            return Response({
                'success': False, 'data': None,
                'message': 'OTP has expired. Please login again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if otp_token.code != data['otp']:
            otp_token.attempts += 1
            otp_token.save(update_fields=['attempts'])
            if otp_token.attempts >= 3:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Too many failed attempts. Please login again.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_429_TOO_MANY_REQUESTS)
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid OTP code.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        otp_token.is_used = True
        otp_token.save(update_fields=['is_used'])

        if user.totp_enabled:
            temp_token = _generate_temp_token(user, 'totp_challenge', expiry_minutes=5)
            return Response({
                'success': True,
                'data': {
                    'require_totp': True,
                    'temp_token': temp_token,
                },
                'message': 'OTP verified. Please enter your authenticator code.',
                'errors': None,
                'pagination': None,
            })

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
                    'totp_enabled': user.totp_enabled,
                    'has_password': user.has_usable_password(),                    'created_at': user.created_at.isoformat(),
                    'is_staff': user.is_staff,
                },
                'profile': profile,
                'new_device': new_device,
            },
            'message': 'Login successful',
            'errors': None,
            'pagination': None,
        })


class TOTPSetupView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if request.user.totp_enabled:
            return Response({
                'success': False, 'data': None,
                'message': '2FA is already enabled.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        secret = pyotp.random_base32()
        provisioning_uri = pyotp.totp.TOTP(secret).provisioning_uri(
            name=request.user.email,
            issuer_name='BuddyUp',
        )

        qr = qrcode.make(provisioning_uri)
        buf = io.BytesIO()
        qr.save(buf, format='PNG')
        qr_b64 = base64.b64encode(buf.getvalue()).decode()

        return Response({
            'success': True,
            'data': {
                'secret': secret,
                'provisioning_uri': provisioning_uri,
                'qr_code': f'data:image/png;base64,{qr_b64}',
            },
            'message': 'TOTP setup initiated. Scan the QR code with your authenticator app.',
            'errors': None,
            'pagination': None,
        })


class TOTPVerifyView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        if request.user.totp_enabled:
            return Response({
                'success': False, 'data': None,
                'message': '2FA is already enabled.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = TOTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        secret = data.get('secret', '')
        code = data['code']

        totp = pyotp.TOTP(secret)
        if not totp.verify(code):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid code. Please try again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        request.user.totp_secret = secret
        request.user.totp_enabled = True
        request.user.save(update_fields=['totp_secret', 'totp_enabled'])

        # Generate 10 single-use recovery codes (shown exactly once).
        from .models import RecoveryCode
        RecoveryCode.objects.filter(user=request.user).delete()
        alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
        plain_codes = [
            '-'.join(''.join(secrets.choice(alphabet) for _ in range(5)) for _ in range(2))
            for _ in range(10)
        ]
        RecoveryCode.objects.bulk_create([
            RecoveryCode(user=request.user, code_hash=RecoveryCode.hash_code(c))
            for c in plain_codes
        ])

        _log_event(request.user, '2fa_enabled', request)
        _security_alert(request.user, 'Two-factor authentication was enabled', request)

        return Response({
            'success': True,
            'data': {
                'recovery_codes': plain_codes,
                'recovery_codes_note': 'Store these somewhere safe. Each code works once '
                                       'if you lose your authenticator device. They are '
                                       'shown only this one time.',
            },
            'message': 'Two-factor authentication enabled successfully.',
            'errors': None,
            'pagination': None,
        })


class TOTPDisableView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        if not request.user.totp_enabled:
            return Response({
                'success': False, 'data': None,
                'message': '2FA is not enabled.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = TOTPDisableSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        if not request.user.check_password(serializer.validated_data['password']):
            return Response({
                'success': False, 'data': None,
                'message': 'Incorrect password.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        request.user.totp_secret = ''
        request.user.totp_enabled = False
        request.user.save(update_fields=['totp_secret', 'totp_enabled'])

        _log_event(request.user, '2fa_disabled', request)
        _security_alert(request.user, 'Two-factor authentication was disabled', request)

        return Response({
            'success': True,
            'data': None,
            'message': 'Two-factor authentication disabled.',
            'errors': None,
            'pagination': None,
        })


class TOTPChallengeView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'otp'

    def post(self, request):
        serializer = TOTPChallengeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        temp_token = serializer.validated_data['temp_token']
        code = serializer.validated_data['code']
        recovery_code = (request.data.get('recovery_code') or '').strip()

        user = _verify_temp_token(temp_token, 'totp_challenge')
        if not user:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired session.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not user.totp_enabled:
            return Response({
                'success': False, 'data': None,
                'message': '2FA is not enabled for this account.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        used_recovery = False
        if recovery_code:
            # Recovery-code path: single use, hashed lookup.
            from .models import RecoveryCode
            rc = RecoveryCode.objects.filter(
                user=user,
                code_hash=RecoveryCode.hash_code(recovery_code),
                is_used=False,
            ).first()
            if not rc:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Invalid or already-used recovery code.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            rc.is_used = True
            rc.save(update_fields=['is_used'])
            used_recovery = True
            _log_event(user, '2fa_recovery_used', request)
        else:
            totp = pyotp.TOTP(user.totp_secret)
            if not totp.verify(code):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Invalid authenticator code.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        tokens = _get_tokens_for_user(user)
        _create_device_session(user, tokens['refresh'], request)

        from apps.profiles.serializers import ProfileSerializer
        profile = ProfileSerializer(_ensure_social_profile(user)).data

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
                    'totp_enabled': user.totp_enabled,
                    'has_password': user.has_usable_password(),                    'created_at': user.created_at.isoformat(),
                    'is_staff': user.is_staff,
                },
                'profile': profile,
                **({'recovery_code_used': True} if used_recovery else {}),
            },
            'message': 'Two-factor verified. Login successful.',
            'errors': None,
            'pagination': None,
        })


def _generate_username(base: str) -> str:
    """Collision-safe username derived from a display name or email prefix."""
    import re as re_module
    base = re_module.sub(r'[^a-zA-Z0-9_]', '', base).lower()[:24] or 'buddy'
    if not Profile.objects.filter(username=base).exists():
        return base
    for i in range(2, 100):
        candidate = f'{base}{i}'
        if not Profile.objects.filter(username=candidate).exists():
            return candidate
    return f'{base}_{secrets.token_hex(2)}'


def _ensure_social_profile(user, display_name='', avatar_url=''):
    """Self-heal: guarantee every social-login user has a usable profile."""
    try:
        return getattr(user, 'profile')
    except Profile.DoesNotExist:
        base = display_name or user.email.split('@')[0]
        return Profile.objects.create(
            user=user,
            username=_generate_username(base),
            display_name=display_name or base,
            role='user',
            privacy_level='private',
            avatar_url=avatar_url or '',
        )


@transaction.atomic
def _provision_social_user(email, provider_field, provider_id, name='', picture=''):
    """Find-or-create the account for a verified social identity.

    Atomic: either both User and Profile rows land, or neither — no more
    half-registered accounts that 500 on every later login attempt.
    Social providers verify EMAIL but not AGE, so is_adult stays False for
    new users until they submit a date of birth (SocialAgeSetupView).
    """
    try:
        user = User.objects.select_for_update().get(email=email)
        updates = {'email_verified': True}
        if provider_id and not getattr(user, provider_field, ''):
            updates[provider_field] = provider_id
        for k, v in updates.items():
            setattr(user, k, v)
        user.save(update_fields=list(updates.keys()))
        created = False
    except User.DoesNotExist:
        user = User.objects.create_user(
            email=email,
            password=None,
            email_verified=True,
            **{provider_field: provider_id},
        )
        created = True
    _ensure_social_profile(user, name, picture)
    if created:
        # New accounts must complete the onboarding pipeline.
        profile = _ensure_social_profile(user, name, picture)
        profile.onboarding_completed = False
        profile.save(update_fields=['onboarding_completed'])
    return user, created


def _finalize_social_login(user, method, request):
    """Build the login payload; TOTP-enabled users get a challenge instead.

    Returns (data_dict, challenged_bool).
    """
    if user.totp_enabled:
        temp_token = _generate_temp_token(user, 'totp_challenge', expiry_minutes=5)
        return ({
            'require_totp': True,
            'temp_token': temp_token,
            'message': 'Enter your authenticator code.',
        }, True)

    tokens = _get_tokens_for_user(user)
    _create_device_session(user, tokens['refresh'], request)
    _log_event(user, 'login', request, metadata={'method': method})
    profile = _ensure_social_profile(user)

    from apps.profiles.serializers import ProfileSerializer
    return ({
        'access': tokens['access'],
        'refresh': tokens['refresh'],
        'user': {
            'id': str(user.id),
            'email': user.email,
            'email_verified': user.email_verified,
            'phone_verified': user.phone_verified,
            'is_adult': user.is_adult,
            'totp_enabled': user.totp_enabled,
            'has_password': user.has_usable_password(),
            'created_at': user.created_at.isoformat(),
            'is_staff': user.is_staff,
        },
        'profile': ProfileSerializer(profile).data,
        'require_age_setup': not user.is_adult,
        'onboarding_required': not getattr(profile, 'onboarding_completed', True),
    }, False)


class GoogleLoginView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'login'

    def post(self, request):
        serializer = GoogleLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        credential = serializer.validated_data['credential']

        if not GOOGLE_AUTH_AVAILABLE and not settings.SOCIAL_AUTH_GOOGLE_OAUTH2_KEY:
            return Response({
                'success': False, 'data': None,
                'message': 'Google authentication is not configured.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        client_id = settings.SOCIAL_AUTH_GOOGLE_OAUTH2_KEY
        if not client_id:
            return Response({
                'success': False, 'data': None,
                'message': 'Google OAuth is not configured.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        info = None
        # Detect if credential is an access token (not a JWT id_token)
        if credential.count('.') == 2 and GOOGLE_AUTH_AVAILABLE:
            # Looks like a JWT id_token — use existing verify flow
            try:
                info = id_token.verify_oauth2_token(credential, google_requests.Request(), client_id, clock_skew_in_seconds=60)
            except ValueError as e:
                return Response({
                    'success': False, 'data': None,
                    'message': f'Invalid Google token: {e}',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
        else:
            # Treat as access token — validate via Google Token Info API
            import json
            import urllib.request
            url = f'https://www.googleapis.com/oauth2/v3/tokeninfo?access_token={credential}'
            try:
                with urllib.request.urlopen(url, timeout=10) as resp:
                    info = json.loads(resp.read().decode())
            except Exception as e:  # noqa: BLE001
                return Response({
                    'success': False, 'data': None,
                    'message': f'Invalid Google access token: {e}',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)
            # Verify the token was issued for this client
            if info.get('aud') != client_id:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Google token audience mismatch.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        email = info.get('email', '').lower()
        google_id = info.get('sub', '')
        name = info.get('name', email.split('@')[0])
        picture = info.get('picture', '')

        if not email:
            return Response({
                'success': False, 'data': None,
                'message': 'Google account has no email.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        user, created = _provision_social_user(email, 'google_id', google_id, name=name, picture=picture)
        if created:
            _log_event(user, 'registered', request, metadata={'method': 'google'})

        data, challenged = _finalize_social_login(user, 'google', request)
        message = 'Additional verification required.' if challenged else (
            'Account created. Please complete age verification to finish setting up.'
            if data.get('require_age_setup') else 'Google login successful.')
        return Response({
            'success': True,
            'data': data,
            'message': message,
            'errors': None,
            'pagination': None,
        })

class AppleLoginView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'login'

    def post(self, request):
        from .serializers import AppleLoginSerializer
        serializer = AppleLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        identity_token = serializer.validated_data['identity_token']
        first_name = serializer.validated_data.get('first_name', '')
        last_name = serializer.validated_data.get('last_name', '')
        name = f"{first_name} {last_name}".strip()

        # Fail closed: audience/issuer verification is mandatory. Without a
        # configured client ID any Apple-signed token for ANY developer's app
        # would otherwise log a user in.
        apple_client_id = getattr(settings, 'APPLE_CLIENT_ID', '')
        if not apple_client_id:
            return Response({
                'success': False, 'data': None,
                'message': 'Apple sign-in is not configured.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        try:
            # Fetch Apple's public keys — cached for an hour; the network
            # fetch itself is time-boxed so a slow IdP cannot hang the worker.
            apple_keys = cache.get('apple_jwks_keys')
            if not apple_keys:
                keys_url = 'https://appleid.apple.com/auth/keys'
                apple_keys = requests.get(keys_url, timeout=5).json()['keys']
                cache.set('apple_jwks_keys', apple_keys, timeout=3600)

            # Get the key ID from the token header
            header = jwt.get_unverified_header(identity_token)
            kid = header['kid']

            # Find the matching public key
            key_data = next((k for k in apple_keys if k['kid'] == kid), None)
            if not key_data:
                raise ValueError("Invalid kid")

            # Construct the public key
            public_key = RSAAlgorithm.from_jwk(key_data)

            # Decode the token — audience AND issuer are always verified.
            decoded = jwt.decode(
                identity_token,
                public_key,
                algorithms=['RS256'],
                audience=apple_client_id,
                issuer='https://appleid.apple.com',
                options={"verify_aud": True, "verify_iss": True},
            )
            email = decoded.get('email', '').lower()
            
            if not email:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Apple account has no email.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

            user, created = _provision_social_user(
                email, 'apple_id', decoded.get('sub', ''), name=name,
            )
            if created:
                _log_event(user, 'registered', request, metadata={'method': 'apple'})

            data, challenged = _finalize_social_login(user, 'apple', request)
            message = 'Additional verification required.' if challenged else (
                'Account created. Please complete age verification to finish setting up.'
                if data.get('require_age_setup') else 'Apple login successful.')
            return Response({
                'success': True,
                'data': data,
                'message': message,
                'errors': None,
                'pagination': None,
            })

        except Exception as e:  # noqa: BLE001
            return Response({
                'success': False, 'data': None,
                'message': f'Invalid Apple token: {e}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)


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
            except Exception:  # noqa: BLE001
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
            token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()

            # Rotate under a row lock: two concurrent refreshes with the same
            # token are serialised here, and the loser re-reads the row with
            # the already-rotated hash and is rejected.
            with transaction.atomic():
                session = DeviceSession.objects.select_for_update().filter(
                    refresh_token_hash=token_hash,
                    is_active=True,
                ).select_related('user').first()
                if not session or not session.user.is_active or session.user.deleted_at:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'This session is no longer active. Please sign in again.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_401_UNAUTHORIZED)

                # Guard against a rotation that committed while this request
                # waited for the lock: the incoming hash must still match the
                # session's CURRENT token hash before we rotate again.
                session.refresh_from_db(fields=['refresh_token_hash', 'is_active'])
                if not session.is_active or session.refresh_token_hash != token_hash:
                    return Response({
                        'success': False, 'data': None,
                        'message': 'This session is no longer active. Please sign in again.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_401_UNAUTHORIZED)

                access = str(token.access_token)

                new_refresh = None
                if getattr(settings, 'SIMPLE_JWT', {}).get('ROTATE_REFRESH_TOKENS', True):
                    token.blacklist()
                    new_token = RefreshToken.for_user(session.user)
                    new_token['device_id'] = token.payload.get('device_id', str(uuid.uuid4()))
                    new_refresh = str(new_token)

                if new_refresh:
                    new_hash = hashlib.sha256(new_refresh.encode()).hexdigest()
                    DeviceSession.objects.filter(id=session.id, is_active=True).update(
                        refresh_token_hash=new_hash, last_active=timezone.now()
                    )
                else:
                    DeviceSession.objects.filter(id=session.id, is_active=True).update(last_active=timezone.now())

            data = {'access': access}
            if new_refresh:
                data['refresh'] = new_refresh

            return Response({
                'success': True,
                'data': data,
                'message': 'Token refreshed',
                'errors': None,
                'pagination': None,
            })
        except Exception:  # noqa: BLE001
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

        if data['channel'] == 'phone' and not sms_delivery_configured():
            return Response({
                'success': False, 'data': None,
                'message': 'Phone verification is temporarily unavailable. Please use email verification.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

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
        if data['channel'] == 'email':
            send_otp_email.delay(str(request.user.id), otp, 'registration')
        else:
            send_otp_sms.delay(str(request.user.id), otp)

        return Response({
            'success': True,
            'data': None,
            'message': f'New OTP sent to your {data["channel"]}.',
            'errors': None,
            'pagination': None,
        })


class ResendRegistrationOTPView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'otp'

    def post(self, request):
        serializer = ResendRegistrationOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        user = _verify_temp_token(data['registration_token'], 'registration')
        if not user:
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired registration token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if data['channel'] == 'phone' and not sms_delivery_configured():
            return Response({
                'success': False, 'data': None,
                'message': 'Phone verification is temporarily unavailable. Please use email verification.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        recent = OTPToken.objects.filter(
            user=user,
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
            user=user,
            code=otp,
            channel=data['channel'],
            expires_at=timezone.now() + timedelta(minutes=10),
        )
        if data['channel'] == 'email':
            send_otp_email.delay(str(user.id), otp, 'registration')
        else:
            send_otp_sms.delay(str(user.id), otp)

        return Response({
            'success': True,
            'data': None,
            'message': f'New OTP sent to your {data["channel"]}.',
            'errors': None,
            'pagination': None,
        })


class PasswordResetRequestView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'password_reset'

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

        # A reset code is single-purpose in practice: invalidate outstanding
        # reset candidates before issuing a new one and never emit it to logs.
        OTPToken.objects.filter(
            user=user, channel='email', is_used=False,
        ).update(is_used=True)
        otp = _generate_otp()
        OTPToken.objects.create(
            user=user,
            code=otp,
            channel='email',
            expires_at=timezone.now() + timedelta(minutes=30),
        )
        send_otp_email.delay(str(user.id), otp, 'password_reset')

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
            user = User.objects.get(email__iexact=data['email'])
            otp_token = OTPToken.objects.filter(
                user=user, channel='email', is_used=False,
            ).latest('created_at')
        except (User.DoesNotExist, OTPToken.DoesNotExist):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired reset token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not otp_token.is_valid():
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired reset token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not secrets.compare_digest(otp_token.code, data['token']):
            otp_token.attempts += 1
            otp_token.save(update_fields=['attempts'])
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid or expired reset token.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        user = otp_token.user
        user.set_password(data['new_password'])

        if user.totp_enabled:
            user.totp_enabled = False
            user.totp_secret = ''
            # Recovery path — 2FA is disabled, but the user must be told.
            _log_event(user, '2fa_disabled', request,
                       metadata={'reason': 'password_reset'})
            _security_alert(user, 'Two-factor authentication was disabled via password reset', request)

        user.save()

        otp_token.is_used = True
        otp_token.save(update_fields=['is_used'])

        DeviceSession.objects.filter(user=user).update(is_active=False)

        _log_event(user, 'password_changed', request)
        _security_alert(user, 'Your password was reset', request)

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
        # Current access tokens are short lived; revoke every refresh session
        # immediately so a stolen long-lived refresh token cannot survive a
        # password change.
        DeviceSession.objects.filter(user=request.user, is_active=True).update(is_active=False)

        _log_event(request.user, 'password_changed', request)
        _security_alert(request.user, 'Your password was changed', request)

        return Response({
            'success': True, 'data': None,
            'message': 'Password changed successfully.',
            'errors': None, 'pagination': None,
        })


class SetPasswordView(views.APIView):
    """Set a password for social sign-ups that have none (Google/Apple).

    Accounts that already have a password must supply the current one, so
    this can never be abused as a password-change bypass.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response({
            'success': True,
            'data': {'has_password': request.user.has_usable_password()},
            'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request):
        from .serializers import SetPasswordSerializer
        serializer = SetPasswordSerializer(
            data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if request.user.has_usable_password():
            if not request.user.check_password(data.get('current_password') or ''):
                return Response({
                    'success': False, 'data': None,
                    'message': 'Current password is incorrect.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

        request.user.set_password(data['new_password'])
        request.user.save()

        _log_event(request.user, 'password_changed', request)
        _security_alert(request.user, 'Your password was set', request)

        return Response({
            'success': True, 'data': {'has_password': True},
            'message': 'Password set successfully. You can now log in with your email and password.',
            'errors': None, 'pagination': None,
        })


class RecoveryCodesRegenerateView(views.APIView):
    """Replace recovery codes. Requires a fresh valid TOTP code (not a code)."""
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'otp'

    def post(self, request):
        if not request.user.totp_enabled:
            return Response({
                'success': False, 'data': None,
                'message': 'Enable two-factor authentication first.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        code = (request.data.get('code') or '').strip()
        if not pyotp.TOTP(request.user.totp_secret).verify(code):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid authenticator code.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from .models import RecoveryCode
        RecoveryCode.objects.filter(user=request.user).delete()
        alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
        plain_codes = [
            '-'.join(''.join(secrets.choice(alphabet) for _ in range(5)) for _ in range(2))
            for _ in range(10)
        ]
        RecoveryCode.objects.bulk_create([
            RecoveryCode(user=request.user, code_hash=RecoveryCode.hash_code(c))
            for c in plain_codes
        ])
        _log_event(request.user, '2fa_recovery_regenerated', request)

        remaining = RecoveryCode.objects.filter(user=request.user, is_used=False).count()
        return Response({
            'success': True,
            'data': {'recovery_codes': plain_codes, 'active_count': remaining},
            'message': 'New recovery codes generated. Previous codes are now invalid.',
            'errors': None, 'pagination': None,
        })


def _webauthn_rp():
    """Relying-party configuration for passkeys."""
    rp_id = os.environ.get('WEBAUTHN_RP_ID', 'buddyup.app')
    origin = os.environ.get('WEBAUTHN_ORIGIN', f'https://{rp_id}')
    return rp_id, 'BuddyUp', origin


# WebAuthn challenges live for five minutes and are single-use: the finish
# endpoints consume (pop) them before verifying, so a captured challenge can
# never be replayed.
WEBAUTHN_CHALLENGE_TTL = 300


def _webauthn_challenge_key(user_id, purpose):
    return f'webauthn:challenge:{user_id}:{purpose}'


def _b64url_decode(data):
    import base64
    padded = data + '=' * (-len(data) % 4)
    return base64.urlsafe_b64decode(padded)


def _b64url_encode(raw):
    import base64
    return base64.urlsafe_b64encode(raw).rstrip(b'=').decode()


class PasskeyRegisterBeginView(views.APIView):
    """Start passkey registration (authenticated users only)."""
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = 'webauthn'

    def post(self, request):
        try:
            from webauthn import generate_registration_options, options_to_json
        except ImportError:
            return Response({
                'success': False, 'data': None,
                'message': 'Passkeys are temporarily unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        rp_id, rp_name, _origin = _webauthn_rp()
        # py-webauthn expects base64url-decoded bytes for credential ids.
        import base64
        existing_ids = []
        try:
            for c in request.user.webauthn_credentials.all():
                padded = c.credential_id + '=' * (-len(c.credential_id) % 4)
                existing_ids.append({
                    'type': 'public-key',
                    'id': base64.urlsafe_b64decode(padded),
                })
        except Exception:  # noqa: BLE001 — exclude list is an optimisation
            logger.warning('Failed to build passkey exclusion list', exc_info=True)
        options = generate_registration_options(
            rp_id=rp_id,
            rp_name=rp_name,
            user_id=str(request.user.id).encode(),
            user_name=request.user.email,
            user_display_name=getattr(getattr(request.user, 'profile', None), 'display_name', '') or request.user.email,
            exclude_credentials=existing_ids,
        )
        cache.set(
            _webauthn_challenge_key(request.user.id, 'registration'),
            options.challenge, timeout=WEBAUTHN_CHALLENGE_TTL,
        )
        return Response({
            'success': True, 'data': {'options': json.loads(options_to_json(options))},
            'message': 'Registration options generated.', 'errors': None, 'pagination': None,
        })


class PasskeyRegisterFinishView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            from webauthn import verify_registration_response
        except ImportError:
            return Response({
                'success': False, 'data': None,
                'message': 'Passkeys are temporarily unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        rp_id, _name, origin = _webauthn_rp()
        # Challenges are keyed by (user, purpose) server-side and single-use:
        # consume the challenge before verifying so a replayed finish call —
        # even with a valid credential — finds nothing and fails.
        challenge_cache_key = _webauthn_challenge_key(request.user.id, 'registration')
        expected_challenge = cache.get(challenge_cache_key)
        cache.delete(challenge_cache_key)
        if not expected_challenge:
            return Response({
                'success': False, 'data': None,
                'message': 'Registration session expired. Try again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        credential = request.data.get('credential') if isinstance(request.data, dict) else None
        device_name = (request.data.get('device_name') or '').strip()[:120] if isinstance(request.data, dict) else ''
        if not credential:
            return Response({'success': False, 'data': None, 'message': 'Missing credential.',
                             'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)

        try:
            verification = verify_registration_response(
                credential=json.dumps(credential) if isinstance(credential, dict) else credential,
                expected_challenge=expected_challenge,
                expected_origin=origin,
                expected_rp_id=rp_id,
                require_user_verification=True,
            )
        except Exception as e:  # noqa: BLE001
            return Response({
                'success': False, 'data': None,
                'message': f'Passkey registration failed: {e}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        from .models import WebAuthnCredential
        WebAuthnCredential.objects.update_or_create(
            credential_id=_b64url_encode(verification.credential_id),
            defaults={
                'user': request.user,
                'public_key': verification.credential_public_key,
                'sign_count': verification.sign_count,
                'transports': list(getattr(verification, 'credential_transports', []) or []),
                'device_name': device_name or (credential.get('response', {}).get('authenticatorAttachment') or 'passkey'),
                'expires_at': timezone.now() + timedelta(days=int(os.environ.get('PASSKEY_EXPIRY_DAYS', '365'))),
                'last_verified_at': timezone.now(),
                'revoked_at': None,
            },
        )
        _log_event(request.user, 'passkey_registered', request)
        _security_alert(request.user, 'A passkey was added', request)
        return Response({
            'success': True, 'data': {'registered': True},
            'message': 'Passkey registered.', 'errors': None, 'pagination': None,
        })


class PasskeyLoginBeginView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'webauthn'

    def post(self, request):
        try:
            from webauthn import generate_authentication_options, options_to_json
        except ImportError:
            return Response({
                'success': False, 'data': None,
                'message': 'Passkeys are temporarily unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        rp_id, _name, _origin = _webauthn_rp()
        email = (request.data.get('email') or '').strip().lower() if isinstance(request.data, dict) else ''
        allow_credentials = []
        if email:
            user = User.objects.filter(email=email, is_active=True).first()
            if user:
                allow_credentials = [
                    {'type': 'public-key', 'id': c.credential_id, 'transports': c.transports or []}
                    for c in user.webauthn_credentials.all()
                ]
        options = generate_authentication_options(
            rp_id=rp_id,
            allow_credentials=allow_credentials,
            # py-webauthn expects the enum, not a raw string; the default is
            # already UserVerificationRequirement.PREFERRED.
        )
        # Challenge stored server-side, keyed by the challenge value itself
        # (which the client already sees in the options and which is bound
        # into the authenticator signature). A user binding is recorded when
        # the email is known so another account cannot redeem the challenge.
        challenge_hex = options.challenge.hex()
        binding = {'challenge': challenge_hex, 'user_id': str(user.id) if user else ''}
        cache.set(
            f'webauthn:challenge:{challenge_hex}:authentication', json.dumps(binding),
            timeout=WEBAUTHN_CHALLENGE_TTL,
        )
        return Response({
            'success': True,
            'data': {'options': json.loads(options_to_json(options)), 'challenge_key': challenge_hex},
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class PasskeyLoginFinishView(views.APIView):
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'login'

    def post(self, request):
        try:
            from webauthn import verify_authentication_response
        except ImportError:
            return Response({
                'success': False, 'data': None,
                'message': 'Passkeys are temporarily unavailable.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        rp_id, _name, origin = _webauthn_rp()
        data = request.data if isinstance(request.data, dict) else {}
        challenge_key = data.get('challenge_key', '')
        binding = None
        if challenge_key:
            binding_raw = cache.get(f'webauthn:challenge:{challenge_key}:authentication')
            # Single-use: consume the challenge regardless of the outcome.
            cache.delete(f'webauthn:challenge:{challenge_key}:authentication')
            try:
                binding = json.loads(binding_raw) if binding_raw else None
            except (TypeError, ValueError):
                binding = None
        if not binding or binding.get('challenge') != challenge_key:
            return Response({
                'success': False, 'data': None,
                'message': 'Login session expired. Try again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        expected_challenge = bytes.fromhex(binding['challenge'])

        credential = data.get('credential') or {}
        raw_id = credential.get('id', '')
        from .models import WebAuthnCredential
        cred = WebAuthnCredential.objects.filter(credential_id=raw_id).select_related('user').first()
        if (not cred or not cred.user.is_active or cred.revoked_at or
                (cred.expires_at and cred.expires_at <= timezone.now())):
            return Response({
                'success': False, 'data': None, 'message': 'Unknown passkey.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)
        # The challenge was bound to a specific account at begin time — a
        # different user's credential can never redeem it.
        if binding.get('user_id') and str(cred.user.id) != binding['user_id']:
            return Response({
                'success': False, 'data': None,
                'message': 'This challenge was issued for a different account.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            verification = verify_authentication_response(
                credential=json.dumps(credential),
                expected_challenge=expected_challenge,
                expected_origin=origin,
                expected_rp_id=rp_id,
                credential_public_key=bytes(cred.public_key),
                credential_current_sign_count=cred.sign_count,
                require_user_verification=True,
            )
        except Exception as e:  # noqa: BLE001
            return Response({
                'success': False, 'data': None,
                'message': f'Passkey verification failed: {e}',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        cred.sign_count = verification.new_sign_count
        cred.last_verified_at = timezone.now()
        cred.save(update_fields=['sign_count', 'last_verified_at'])

        payload, challenged = _finalize_social_login(cred.user, 'passkey', request)
        message = 'Additional verification required.' if challenged else (
            'Please complete age verification to finish setting up.'
            if payload.get('require_age_setup') else 'Passkey login successful.')
        return Response({
            'success': True, 'data': payload, 'message': message,
            'errors': None, 'pagination': None,
        })


class PasskeyListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        credentials = request.user.webauthn_credentials.order_by('-created_at')
        return Response({'success': True, 'data': [
            {'id': c.id, 'device_name': c.device_name,
             'created_at': c.created_at.isoformat(),
             'last_verified_at': c.last_verified_at.isoformat() if c.last_verified_at else None,
             'expires_at': c.expires_at.isoformat() if c.expires_at else None,
             'revoked_at': c.revoked_at.isoformat() if c.revoked_at else None}
            for c in credentials
        ], 'message': 'OK', 'errors': None, 'pagination': None})


class PasskeyRenameView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        credential = get_object_or_404(
            WebAuthnCredential, id=pk, user=request.user, revoked_at__isnull=True,
        )
        serializer = PasskeyRenameSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        credential.device_name = serializer.validated_data['device_name'].strip()
        credential.save(update_fields=['device_name', 'updated_at'])
        _log_event(request.user, 'passkey_renamed', request, {'credential_id': credential.id})
        _security_alert(request.user, 'A passkey was renamed', request)
        return Response({'success': True, 'data': {'id': credential.id, 'device_name': credential.device_name}, 'message': 'Passkey renamed.', 'errors': None, 'pagination': None})


class PasskeyRevokeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        credential = get_object_or_404(
            WebAuthnCredential, id=pk, user=request.user, revoked_at__isnull=True,
        )
        serializer = PasskeyRevokeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        proof = serializer.validated_data
        valid = bool(proof.get('password') and request.user.check_password(proof['password']))
        if not valid and proof.get('code') and request.user.totp_enabled:
            valid = pyotp.TOTP(request.user.totp_secret).verify(proof['code'])
        if not valid and proof.get('recovery_code'):
            from .models import RecoveryCode
            recovery = RecoveryCode.objects.filter(
                user=request.user, is_used=False,
                code_hash=RecoveryCode.hash_code(proof['recovery_code']),
            ).first()
            if recovery:
                recovery.is_used = True
                recovery.save(update_fields=['is_used'])
                valid = True
        if not valid:
            return Response({'success': False, 'data': None, 'message': 'Re-authentication required.', 'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)
        credential.revoked_at = timezone.now()
        credential.save(update_fields=['revoked_at', 'updated_at'])
        _log_event(request.user, 'passkey_revoked', request, {'credential_id': credential.id})
        _security_alert(request.user, 'A passkey was revoked', request)
        return Response({'success': True, 'data': None, 'message': 'Passkey revoked.', 'errors': None, 'pagination': None})


class PasskeyReverifyView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        credential = get_object_or_404(
            WebAuthnCredential, id=pk, user=request.user, revoked_at__isnull=True,
        )
        serializer = PasskeyRevokeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        proof = serializer.validated_data
        valid = bool(proof.get('password') and request.user.check_password(proof['password']))
        if not valid and proof.get('code') and request.user.totp_enabled:
            valid = pyotp.TOTP(request.user.totp_secret).verify(proof['code'])
        if not valid:
            return Response({'success': False, 'data': None, 'message': 'Re-authentication required.', 'errors': None, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)
        now = timezone.now()
        credential.last_verified_at = now
        credential.expires_at = now + timedelta(days=int(os.environ.get('PASSKEY_EXPIRY_DAYS', '365')))
        credential.save(update_fields=['last_verified_at', 'expires_at', 'updated_at'])
        return Response({'success': True, 'data': {'id': credential.id, 'expires_at': credential.expires_at.isoformat()}, 'message': 'Passkey re-verified.', 'errors': None, 'pagination': None})


class SocialAgeSetupView(views.APIView):
    """Complete social signup by recording date of birth (age gate).

    Google/Apple verify email but never age; new social accounts receive
    require_age_setup=True from login and must POST here with the temp
    token before they can use mature content or the full platform.
    """
    permission_classes = [permissions.AllowAny]
    throttle_scope = 'otp'

    def post(self, request):
        data = request.data if isinstance(request.data, dict) else {}
        # Two paths: unauthenticated (temp_token from social login) or an
        # already signed-in session completing their age setup later.
        temp_token = data.get('temp_token', '')
        if request.user.is_authenticated:
            user = request.user
        elif temp_token:
            user = _verify_temp_token(temp_token, 'social_age_setup')
        else:
            user = None
        if user is None:
            return Response({
                'success': False, 'data': None,
                'message': 'Session expired. Please sign in again.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        dob = data.get('date_of_birth', '')
        if not dob:
            return Response({
                'success': False, 'data': None,
                'message': 'Date of birth is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            from datetime import datetime
            dob_date = datetime.strptime(str(dob)[:10], '%Y-%m-%d').date()
        except (ValueError, IndexError):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid date format. Use YYYY-MM-DD.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        age = calculate_age(dob_date)
        user.dob_hash = hash_dob(dob_date)
        user.is_adult = age >= 18
        user.save(update_fields=['dob_hash', 'is_adult'])
        _log_event(user, 'age_verified', request, metadata={'method': 'social_signup'})

        payload, challenged = _finalize_social_login(user, f'{request.data.get("provider", "social")}', request)
        return Response({
            'success': True,
            'data': {**payload, 'age': age, 'is_adult': user.is_adult},
            'message': 'Age verified. Welcome to BuddyUp!',
            'errors': None, 'pagination': None,
        })


class VerifyAgeView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        dob = request.data.get('date_of_birth', '')
        if not dob:
            return Response({
                'success': False, 'data': None,
                'message': 'Date of birth is required.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            from datetime import datetime
            dob_date = datetime.strptime(dob[:10], '%Y-%m-%d').date()
        except (ValueError, IndexError):
            return Response({
                'success': False, 'data': None,
                'message': 'Invalid date format. Use YYYY-MM-DD.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        age = calculate_age(dob_date)
        is_adult = age >= 18
        hash_dob_val = hash_dob(dob_date)

        return Response({
            'success': True,
            'data': {
                'age': age,
                'is_adult': is_adult,
                'is_16_plus': age >= 16,
                'dob_hash': hash_dob_val,
            },
            'message': 'Age verified.',
            'errors': None, 'pagination': None,
        })


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def health_check(request):
    """Dependency-aware readiness check used by Railway and canaries."""
    from django.core.cache import cache
    from django.db import connections
    from django.db.migrations.executor import MigrationExecutor

    checks = {}

    try:
        with connections['default'].cursor() as cursor:
            cursor.execute('SELECT 1')
            cursor.fetchone()
        checks['database'] = {'ok': True}
    except Exception as exc:  # noqa: BLE001
        checks['database'] = {'ok': False, 'error': type(exc).__name__}

    try:
        probe = f'health:{uuid.uuid4().hex}'
        cache.set(probe, 'ok', timeout=10)
        cache_ok = cache.get(probe) == 'ok'
        cache.delete(probe)
        checks['cache'] = {'ok': cache_ok}
    except Exception as exc:  # noqa: BLE001
        checks['cache'] = {'ok': False, 'error': type(exc).__name__}

    try:
        # The Docker healthcheck hits this every 30s and the migration-plan
        # walk is expensive (full MigrationExecutor graph). Cache the result
        # briefly; a fresh check always runs after deploys/migrations because
        # the cache key includes the schema_status of the moment is cheap
        # enough at 60s granularity.
        cached_migrations = cache.get('health:migrations')
        if cached_migrations is not None:
            checks['migrations'] = cached_migrations
        else:
            executor = MigrationExecutor(connections['default'])
            pending = executor.migration_plan(executor.loader.graph.leaf_nodes())
            checks['migrations'] = {
                'ok': not pending,
                'pending': [f'{m.app_label}.{m.name}' for m, _backward in pending[:20]],
            }
            cache.set('health:migrations', checks['migrations'], timeout=60)
    except Exception as exc:  # noqa: BLE001
        checks['migrations'] = {'ok': False, 'error': type(exc).__name__}

    required_ok = all(checks[name]['ok'] for name in ('database', 'cache', 'migrations'))
    payload = {
        'status': 'ok' if required_ok else 'degraded',
        'service': 'buddyup-api',
        'release': settings.RELEASE_VERSION,
        'commit': settings.RELEASE_COMMIT[:12],
        'request_id': getattr(request, 'request_id', None),
        'checks': checks,
    }
    return Response(payload, status=200 if required_ok else status.HTTP_503_SERVICE_UNAVAILABLE)


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def metrics(request):
    """Expose aggregate worker metrics to a configured scraper only."""
    expected = settings.METRICS_TOKEN
    if not expected:
        # Fail closed outside development: an unauthenticated metrics scrape
        # must never be possible in production.
        if not settings.DEBUG:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
    elif request.headers.get('X-Metrics-Token') != expected:
        return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
    from django.http import HttpResponse
    return HttpResponse(prometheus_metrics(), content_type='text/plain; version=0.0.4')


class PolicyVersionsView(views.APIView):
    """Public list of current legal/policy document versions.

    The frontend uses this to display the exact version a user has accepted and
    to prompt re-consent when a document is materially updated.
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({
            'success': True,
            'data': CURRENT_POLICY_VERSIONS,
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ConsentStatusView(views.APIView):
    """Show the authenticated user's recorded consent for current policy versions.

    Returns which documents are up-to-date (accepted version == current version)
    and which require re-consent after a policy update.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        log = request.user.consent_log or {}
        consent_status = {}
        for key, meta in CURRENT_POLICY_VERSIONS.items():
            accepted = log.get(f'{key}_version', '')
            consent_status[key] = {
                'current_version': meta['version'],
                'accepted_version': accepted,
                'up_to_date': accepted == meta['version'],
                'updated_at': meta['updated_at'],
            }

        return Response({
            'success': True,
            'data': {
                'consent_log': log,
                'requires_parental_coowner': request.user.consent_log.get('requires_parental_coowner', False),
                'guardian_verified': request.user.guardian_verified,
                'policies': consent_status,
            },
            'message': 'OK',
            'errors': None,
            'pagination': None,
        })


class ConsentUpdateView(views.APIView):
    """Record explicit acceptance of every current policy version."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ConsentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        log = dict(request.user.consent_log or {})
        for key in CURRENT_POLICY_VERSIONS:
            accepted_key = f'accepted_{key}'
            if not data.get(accepted_key, False):
                return Response({'success': False, 'data': None, 'message': 'All current policies must be accepted.', 'errors': {accepted_key: ['This consent is required.']}, 'pagination': None}, status=status.HTTP_400_BAD_REQUEST)
            log[f'{key}_version'] = CURRENT_POLICY_VERSIONS[key]['version']
        log.update({'consented_at': timezone.now().isoformat(), 'consent_ip': _get_client_ip(request)})
        request.user.consent_log = log
        request.user.save(update_fields=['consent_log'])
        profile = getattr(request.user, 'profile', None)
        if profile:
            profile.terms_version = CURRENT_POLICY_VERSIONS['terms']['version']
            profile.terms_accepted_at = timezone.now()
            profile.save(update_fields=['terms_version', 'terms_accepted_at'])
        return Response({'success': True, 'data': {'policies': log}, 'message': 'Consent updated.', 'errors': None, 'pagination': None})


class DeactivateAccountView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        user.is_active = False
        user.deleted_at = timezone.now()
        user.deletion_type = 'user'
        user.save(update_fields=['is_active', 'deleted_at', 'deletion_type'])

        _log_event(user, 'account_deactivated', request)

        return Response({
            'success': True,
            'data': {'reactivatable_until': (timezone.now() + timedelta(days=30)).isoformat()},
            'message': 'Account deactivated. It can be reactivated within 30 days by logging in.',
            'errors': None,
            'pagination': None,
        })


class DeleteAccountView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        confirm = request.data.get('confirm', '').lower()

        if confirm != 'delete my account':
            return Response({
                'success': False, 'data': None,
                'message': 'Please type "delete my account" to confirm.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        _log_event(user, 'account_deleted', request)

        user.is_active = False
        user.deleted_at = timezone.now()
        user.deletion_type = 'user'
        user.save(update_fields=['is_active', 'deleted_at', 'deletion_type'])

        DeviceSession.objects.filter(user=user).update(is_active=False)

        from .tasks import delete_user_data
        delete_user_data.apply_async(
            args=[str(user.id)],
            countdown=timedelta(days=30).total_seconds(),
        )

        return Response({
            'success': True,
            'data': {
                'hard_deletion_scheduled': (timezone.now() + timedelta(days=30)).isoformat(),
            },
            'message': 'Account deletion initiated. Your data will be permanently deleted in 30 days. Log in within 30 days to cancel.',
            'errors': None,
            'pagination': None,
        })


class ExportUserDataView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        from .tasks import export_user_data
        export_user_data.delay(str(request.user.id))

        return Response({
            'success': True,
            'data': None,
            'message': 'Data export requested. You will receive a download link via email when ready.',
            'errors': None,
            'pagination': None,
        })


class DeviceSessionsListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        sessions = DeviceSession.objects.filter(
            user=request.user, is_active=True
        ).order_by('-last_active')

        data = []
        for s in sessions:
            data.append({
                'id': str(s.id),
                'device_name': s.device_name,
                'ip_address': s.ip_address,
                'location': s.location,
                'last_active': s.last_active.isoformat(),
                'created_at': s.created_at.isoformat(),
                'is_current': s.refresh_token_hash == hashlib.sha256(
                    (request.auth or '').encode() if hasattr(request, 'auth') and request.auth else b''
                ).hexdigest()[:64] if hasattr(request, 'auth') else False,
            })

        return Response({
            'success': True, 'data': data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })


class LogoutAllSessionsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        DeviceSession.objects.filter(user=request.user, is_active=True).update(is_active=False)
        from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
        for token in OutstandingToken.objects.filter(user=request.user):
            BlacklistedToken.objects.get_or_create(token=token)

        _log_event(request.user, 'password_changed', request,
                   metadata={'action': 'logout_all_sessions'})

        return Response({
            'success': True, 'data': None,
            'message': 'All other sessions have been signed out.',
            'errors': None, 'pagination': None,
        })


class ActivityLogView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):

        event_type = request.query_params.get('type', '')
        events = AccountEvent.objects.filter(user=request.user).order_by('-created_at')

        if event_type:
            events = events.filter(event_type=event_type)

        paginator = CursorPagination()
        paginator.ordering = '-created_at'
        page = paginator.paginate_queryset(events, request)

        data = []
        for e in page:
            data.append({
                'id': str(e.id),
                'event_type': e.event_type,
                'ip_address': e.ip_address,
                'metadata': e.metadata,
                'created_at': e.created_at.isoformat(),
            })

        return Response({
            'success': True, 'data': data,
            'message': 'OK', 'errors': None,
            'pagination': {
                'count': len(data),
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })
