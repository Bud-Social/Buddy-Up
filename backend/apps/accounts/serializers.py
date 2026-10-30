from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from common.utils import calculate_age
from .models import User
from apps.profiles.models import Profile


class RegisterSerializer(serializers.Serializer):
    # Where an elevated role is actually obtained. Named in the error message
    # below so a caller who sent role="trainer" is told the real path rather
    # than left guessing.
    CATEGORY_APPLICATION_PATH = '/api/v1/verification/category-applications/'

    email = serializers.EmailField()
    phone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    password = serializers.CharField(write_only=True, min_length=8)
    dob = serializers.DateField()
    # Optional: the new onboarding pipeline collects the real username/display
    # name. When omitted, the view derives collision-safe values from the
    # email (same strategy as social sign-up).
    username = serializers.CharField(min_length=3, max_length=30, required=False, allow_blank=True)
    display_name = serializers.CharField(min_length=1, max_length=50, required=False, allow_blank=True)
    # NOT a ChoiceField over ROLE_CHOICES.
    #
    # This used to be `ChoiceField(choices=Profile.ROLE_CHOICES, default='user')`,
    # which validated the value and then let ``accounts.views.RegisterView``
    # write it straight onto ``Profile.role``. That made a professional role
    # self-declared: POST /auth/register/ with {"role": "trainer"} produced a
    # trainer, and ``IsVerifiedTrainer`` — which checks role and nothing else —
    # then treated them as one.
    #
    # It is a plain CharField with a rejecting ``validate_role`` instead of a
    # ChoiceField because a ChoiceField's failure message is "not a valid
    # choice", which tells the caller nothing. Every registration now creates a
    # plain `user`; `trainer` / `practitioner` are granted only when a
    # verification decision is approved by two members of staff. Accepting the
    # key and dropping it silently would be worse still — the caller would see a
    # 201 and believe they had applied.
    role = serializers.CharField(required=False, default='user')
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

    def validate_role(self, value):
        """Registration cannot grant a professional role.

        ``user`` (or an omitted/blank value) is accepted and normalised, because
        the web and Flutter clients both still send ``role: "user"`` explicitly
        and breaking them would be gratuitous. Anything else is refused with the
        route that actually grants the role.
        """
        if value in (None, '', 'user'):
            return 'user'
        raise serializers.ValidationError(
            f'"{value}" cannot be chosen at registration. Trainer and practitioner '
            f'roles are granted after review, not self-declared: register with '
            f'role "user", then submit an application to '
            f'{self.CATEGORY_APPLICATION_PATH}.',
        )

    def validate(self, data):
        age = calculate_age(data['dob'])
        if age < 16:
            raise serializers.ValidationError({'dob': 'BuddyUp Fit is for users aged 16 and over. You cannot create an account at this time.'})
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
    # Opt-in reactivation: logging into a deactivated / scheduled-for-deletion
    # account only restores it when the client explicitly asks for it.
    reactivate = serializers.BooleanField(required=False)


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


class SetPasswordSerializer(serializers.Serializer):
    """For social sign-ups that have no password yet.

    When the account already has a usable password the current one is
    required — this endpoint never becomes a password-change bypass.
    """
    current_password = serializers.CharField(write_only=True, required=False, allow_blank=True)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate(self, attrs):
        user = self.context['request'].user
        if user.has_usable_password() and not attrs.get('current_password'):
            raise serializers.ValidationError(
                {'current_password': 'Your account already has a password — enter it to set a new one.'})
        return attrs

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


class ActivationTokenSerializer(serializers.Serializer):
    activation_token = serializers.CharField()


class LoginOTPSerializer(serializers.Serializer):
    login_token = serializers.CharField()
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)
    otp = serializers.CharField(min_length=6, max_length=6, required=False, allow_blank=True)
    remember_me = serializers.BooleanField(default=False)

    def validate(self, attrs):
        """Exactly one of password or otp must be supplied, or neither
        when the client explicitly requests to skip the password step
        via the 'confirm with OTP' path.

        Validation rules:
          password + otp → error (ambiguous; must be one step at a time)
          password only  → password-verification phase
          otp only       → OTP-verification phase
          neither        → OTP-resend phase (client clicked "Confirm with OTP")
        """
        password = (attrs.get('password') or '').strip()
        otp = (attrs.get('otp') or '').strip()
        if password and otp:
            raise serializers.ValidationError(
                'Provide either a password or an OTP code, not both.'
            )
        attrs['password'] = password
        attrs['otp'] = otp
        return attrs


class TOTPChallengeSerializer(serializers.Serializer):
    """Exactly one of `code` or `recovery_code`.

    `code` used to be required=True while the view's recovery branch read
    `recovery_code` from raw request.data — so a recovery-only request died in
    validation and the documented recovery path could never run. Both are
    optional here and `validate` requires exactly one, which also rejects an
    ambiguous request carrying a valid code *and* a bogus recovery code.
    """

    temp_token = serializers.CharField()
    code = serializers.CharField(min_length=6, max_length=6, required=False, allow_blank=True)
    recovery_code = serializers.CharField(required=False, allow_blank=True, write_only=True)

    def validate(self, attrs):
        code = (attrs.get('code') or '').strip()
        recovery = (attrs.get('recovery_code') or '').strip()
        if bool(code) == bool(recovery):
            raise serializers.ValidationError(
                'Provide exactly one of: an authenticator code, or a recovery code.'
            )
        attrs['code'] = code
        attrs['recovery_code'] = recovery
        return attrs


class TOTPDisableSerializer(serializers.Serializer):
    password = serializers.CharField(write_only=True)


class GoogleLoginSerializer(serializers.Serializer):
    credential = serializers.CharField()
    # Explicit data-access consent collected by the frontend consent gate
    # before the credential is exchanged. Persisted to user.consent_log.
    data_access_consent = serializers.BooleanField(required=False, default=False)


class AppleLoginSerializer(serializers.Serializer):
    identity_token = serializers.CharField()
    authorization_code = serializers.CharField(required=False, allow_blank=True)
    first_name = serializers.CharField(required=False, allow_blank=True)
    last_name = serializers.CharField(required=False, allow_blank=True)


class PasskeyRenameSerializer(serializers.Serializer):
    device_name = serializers.CharField(min_length=1, max_length=120)


class PasskeyRevokeSerializer(serializers.Serializer):
    password = serializers.CharField(required=False, write_only=True, allow_blank=True)
    code = serializers.CharField(required=False, write_only=True, allow_blank=True)
    recovery_code = serializers.CharField(required=False, write_only=True, allow_blank=True)


class ConsentSerializer(serializers.Serializer):
    accepted_terms = serializers.BooleanField()
    accepted_privacy = serializers.BooleanField()
    accepted_guidelines = serializers.BooleanField()
    accepted_cookie_policy = serializers.BooleanField(required=False, default=True)
    accepted_medical_disclaimer = serializers.BooleanField(required=False, default=True)
    accepted_sponsorship_policy = serializers.BooleanField(required=False, default=True)
    accepted_adult_content_policy = serializers.BooleanField(required=False, default=True)


class DeviceSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id']
