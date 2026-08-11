import uuid
import hashlib
import secrets
import io
import base64
import os
import qrcode
import pyotp
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
from .policy_versions import CURRENT_POLICY_VERSIONS, policy_version
from .serializers import (
    RegisterSerializer, LoginSerializer, OTPSerializer, ResendOTPSerializer,
    ResendRegistrationOTPSerializer,
    PasswordResetRequestSerializer, PasswordResetConfirmSerializer,
    ChangePasswordSerializer, SocialAuthSerializer,
    TOTPSetupSerializer, TOTPVerifySerializer,
    LoginOTPSerializer, RegistrationOTPSerializer,
    TOTPChallengeSerializer, TOTPDisableSerializer, GoogleLoginSerializer,
)
from apps.profiles.models import Profile
from .tasks import (
    send_otp_email, send_otp_sms, sms_delivery_configured,
    send_welcome_email, send_login_alert_email,
)

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


def _generate_temp_token(user, purpose, expiry_minutes=5):
    token = RefreshToken.for_user(user)
    token['purpose'] = purpose
    token.set_exp(lifetime=timedelta(minutes=expiry_minutes))
    return str(token)


def _verify_temp_token(token_str, expected_purpose):
    try:
        token = AccessToken(token_str)
        if token.get('purpose') != expected_purpose:
            return None
        return User.objects.get(id=token['user_id'])
    except Exception:
        return None


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
                    'created_at': user.created_at.isoformat(),
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
            otp = _generate_otp()
            OTPToken.objects.create(
                user=user,
                code=otp,
                channel='email',
                expires_at=timezone.now() + timedelta(minutes=10),
            )
            send_otp_email.delay(str(user.id), otp, 'registration')
            reg_token = _generate_temp_token(user, 'registration', expiry_minutes=10)
            return Response({
                'success': False,
                'data': {
                    'registration_token': reg_token,
                    'email': user.email,
                },
                'message': 'Please verify your email before logging in. Check your inbox for the OTP.',
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
                    'created_at': user.created_at.isoformat(),
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

        _log_event(request.user, '2fa_enabled', request)

        return Response({
            'success': True,
            'data': None,
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
                    'created_at': user.created_at.isoformat(),
                    'is_staff': user.is_staff,
                },
                'profile': profile,
            },
            'message': 'TOTP verified. Login successful.',
            'errors': None,
            'pagination': None,
        })


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
            except Exception as e:
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

        user = None
        try:
            user = User.objects.get(email=email)
            user.google_id = google_id
            user.email_verified = True
            user.save(update_fields=['google_id', 'email_verified'])
        except User.DoesNotExist:
            user = User.objects.create_user(
                email=email,
                password=None,
                google_id=google_id,
                email_verified=True,
                is_adult=True,
                last_login_ip=_get_client_ip(request),
            )
            from apps.profiles.models import Profile
            Profile.objects.create(
                user=user,
                username=email.split('@')[0],
                display_name=name,
                role='user',
                privacy_level='private',
                avatar_url=picture,
            )

        tokens = _get_tokens_for_user(user)
        _create_device_session(user, tokens['refresh'], request)
        _log_event(user, 'login', request, metadata={'method': 'google'})

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
                    'created_at': user.created_at.isoformat(),
                    'is_staff': user.is_staff,
                },
                'profile': profile,
            },
            'message': 'Google login successful.',
            'errors': None,
            'pagination': None,
        })

import jwt
import requests
from jwt.algorithms import RSAAlgorithm

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

        try:
            # Fetch Apple's public keys
            keys_url = 'https://appleid.apple.com/auth/keys'
            apple_keys = requests.get(keys_url).json()['keys']
            
            # Get the key ID from the token header
            header = jwt.get_unverified_header(identity_token)
            kid = header['kid']
            
            # Find the matching public key
            key_data = next((k for k in apple_keys if k['kid'] == kid), None)
            if not key_data:
                raise ValueError("Invalid kid")

            # Construct the public key
            public_key = RSAAlgorithm.from_jwk(key_data)

            # Decode the token
            decoded = jwt.decode(
                identity_token, 
                public_key, 
                algorithms=['RS256'], 
                audience=settings.SOCIAL_AUTH_APPLE_CLIENT_ID if hasattr(settings, 'SOCIAL_AUTH_APPLE_CLIENT_ID') else None,
                options={"verify_aud": hasattr(settings, 'SOCIAL_AUTH_APPLE_CLIENT_ID')}
            )
            email = decoded.get('email', '').lower()
            apple_id = decoded.get('sub', '')
            
            if not email:
                return Response({
                    'success': False, 'data': None,
                    'message': 'Apple account has no email.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_400_BAD_REQUEST)

            user = None
            try:
                user = User.objects.get(email=email)
                user.email_verified = True
                user.save(update_fields=['email_verified'])
            except User.DoesNotExist:
                user = User.objects.create_user(
                    email=email,
                    password=None,
                    email_verified=True,
                    is_adult=True,
                    last_login_ip=_get_client_ip(request),
                )
                from apps.profiles.models import Profile
                Profile.objects.create(
                    user=user,
                    username=email.split('@')[0],
                    display_name=name or email.split('@')[0],
                    role='user',
                    privacy_level='private',
                )

            tokens = _get_tokens_for_user(user)
            _create_device_session(user, tokens['refresh'], request)
            _log_event(user, 'login', request, metadata={'method': 'apple'})

            from apps.profiles.serializers import ProfileSerializer
            profile_data = ProfileSerializer(user.profile).data

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
                        'created_at': user.created_at.isoformat(),
                        'is_staff': user.is_staff,
                    },
                    'profile': profile_data,
                },
                'message': 'Apple login successful.',
                'errors': None,
                'pagination': None,
            })

        except Exception as e:
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
            token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
            session = DeviceSession.objects.filter(
                refresh_token_hash=token_hash,
                is_active=True,
            ).select_related('user').first()
            if not session or not session.user.is_active or session.user.deleted_at:
                return Response({
                    'success': False, 'data': None,
                    'message': 'This session is no longer active. Please sign in again.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_401_UNAUTHORIZED)

            access = str(token.access_token)

            new_refresh = None
            if getattr(settings, 'SIMPLE_JWT', {}).get('ROTATE_REFRESH_TOKENS', True):
                token.blacklist()
                user_id = token.payload.get('user_id')
                try:
                    user = User.objects.get(id=user_id, is_active=True, deleted_at__isnull=True)
                    new_token = RefreshToken.for_user(user)
                    new_token['device_id'] = token.payload.get('device_id', str(uuid.uuid4()))
                    new_refresh = str(new_token)
                except User.DoesNotExist:
                    new_refresh = None

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
            _log_event(user, '2fa_disabled', request,
                       metadata={'reason': 'password_reset'})

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
        # Current access tokens are short lived; revoke every refresh session
        # immediately so a stolen long-lived refresh token cannot survive a
        # password change.
        DeviceSession.objects.filter(user=request.user, is_active=True).update(is_active=False)

        _log_event(request.user, 'password_changed', request)

        return Response({
            'success': True, 'data': None,
            'message': 'Password changed successfully.',
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
        hash_dob_val = hash_dob(dob)

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
        from common.pagination import CursorPagination

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
