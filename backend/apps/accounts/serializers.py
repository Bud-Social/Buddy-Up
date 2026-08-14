from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from common.utils import calculate_age
from .models import User
from apps.profiles.models import Profile


class RegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    phone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    password = serializers.CharField(write_only=True, min_length=8)
    dob = serializers.DateField()
    username = serializers.CharField(min_length=3, max_length=30)
    display_name = serializers.CharField(min_length=1, max_length=50)
    role = serializers.ChoiceField(choices=Profile.ROLE_CHOICES, default='user')
    accepted_terms = serializers.BooleanField()
    accepted_privacy = serializers.BooleanField()
    accepted_guidelines = serializers.BooleanField()
    is_16_plus = serializers.BooleanField()
    referral_code = serializers.CharField(max_length=20, required=False, allow_blank=True)

    # Parental co-owner (required when the account belongs to a 16–17 year old).
    guardian_name = serializers.CharField(max_length=120, required=False, allow_blank=True)
    guardian_email = serializers.EmailField(required=False, allow_blank=True)
    guardian_phone = serializers.CharField(max_length=20, required=False, allow_blank=True)

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('An account with this email already exists.')
        return value.lower()

    def validate_username(self, value):
        if Profile.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError('This username is already taken.')
        if not value.replace('_', '').isalnum():
            raise serializers.ValidationError('Username may only contain letters, numbers, and underscores.')
        return value.lower()

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate_is_16_plus(self, value):
        if not value:
            raise serializers.ValidationError('You must confirm you are 16 or older.')
        return value

    def validate(self, data):
        age = calculate_age(data['dob'])
        if age < 16:
            raise serializers.ValidationError({'dob': 'BuddyUp is for users aged 16 and over. You cannot create an account at this time.'})
        data['age'] = age

        # 16–17 year olds must provide a verified parental co-owner.
        if 16 <= age < 18:
            if not (data.get('guardian_name') or data.get('guardian_email') or data.get('guardian_phone')):
                raise serializers.ValidationError({
                    'guardian': 'Users aged 16–17 must provide a parent or guardian co-owner (name, email, or phone).',
                })
            data['requires_parental_coowner'] = True
        else:
            data['requires_parental_coowner'] = False
        return data


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    remember_me = serializers.BooleanField(default=False)


class OTPSerializer(serializers.Serializer):
    otp = serializers.CharField(min_length=6, max_length=6)
    channel = serializers.ChoiceField(choices=['email', 'phone'])


class ResendOTPSerializer(serializers.Serializer):
    channel = serializers.ChoiceField(choices=['email', 'phone'])


class ResendRegistrationOTPSerializer(serializers.Serializer):
    registration_token = serializers.CharField()
    channel = serializers.ChoiceField(choices=['email', 'phone'])


class PasswordResetRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetConfirmSerializer(serializers.Serializer):
    email = serializers.EmailField()
    token = serializers.CharField()
    new_password = serializers.CharField(min_length=8)

    def validate_new_password(self, value):
        validate_password(value)
        return value


class ChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_new_password(self, value):
        validate_password(value)
        return value


class SocialAuthSerializer(serializers.Serializer):
    access_token = serializers.CharField()
    id_token = serializers.CharField(required=False, allow_blank=True)


class TOTPSetupSerializer(serializers.Serializer):
    code = serializers.CharField(min_length=6, max_length=6)
    secret = serializers.CharField()


class TOTPVerifySerializer(serializers.Serializer):
    code = serializers.CharField(min_length=6, max_length=6)
    secret = serializers.CharField(required=False, allow_blank=True)


class RegistrationOTPSerializer(serializers.Serializer):
    registration_token = serializers.CharField()
    otp = serializers.CharField(min_length=6, max_length=6)


class LoginOTPSerializer(serializers.Serializer):
    login_token = serializers.CharField()
    otp = serializers.CharField(min_length=6, max_length=6)
    remember_me = serializers.BooleanField(default=False)


class TOTPChallengeSerializer(serializers.Serializer):
    temp_token = serializers.CharField()
    code = serializers.CharField(min_length=6, max_length=6)


class TOTPDisableSerializer(serializers.Serializer):
    password = serializers.CharField(write_only=True)


class GoogleLoginSerializer(serializers.Serializer):
    credential = serializers.CharField()


class AppleLoginSerializer(serializers.Serializer):
    identity_token = serializers.CharField()
    authorization_code = serializers.CharField(required=False, allow_blank=True)
    first_name = serializers.CharField(required=False, allow_blank=True)
    last_name = serializers.CharField(required=False, allow_blank=True)


class DeviceSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id']
