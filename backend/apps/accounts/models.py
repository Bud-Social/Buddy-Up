from django.db import models
from django.conf import settings
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.utils import timezone
from uuid import uuid4
from common.models import TimestampedModel
from .crypto import decrypt_value, encrypt_value


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class EncryptedCharField(models.CharField):
    """CharField whose value is Fernet-encrypted at rest (see ``crypto.py``).

    Call sites are unchanged: assign plaintext, read plaintext. Encryption
    happens in ``get_prep_value`` (every write, including ``save(update_fields
    =[...])`` and ``QuerySet.update``) and decryption in ``from_db_value``
    (every read, including ``refresh_from_db`` and ``values_list``).

    Caveat, deliberate: Fernet ciphertext is non-deterministic, so a lookup on
    this column can never match — filtering on it is unsupported. Nothing in
    the codebase does, and ``totp_secret`` has no business being queried.
    """

    def from_db_value(self, value, expression, connection):
        return decrypt_value(value)

    def get_prep_value(self, value):
        return encrypt_value(super().get_prep_value(value) or '')


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    phone_verified = models.BooleanField(default=False)
    email_verified = models.BooleanField(default=False)
    dob_hash = models.CharField(max_length=64)
    is_adult = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    # When set (login-initiated deletion), the sweep hard-deletes the row at
    # or after this instant. Cancelling the deletion clears it.
    hard_delete_at = models.DateTimeField(null=True, blank=True)
    deletion_type = models.CharField(max_length=20, null=True, blank=True, choices=[('user', 'User'), ('moderation', 'Moderation')])
    created_at = models.DateTimeField(auto_now_add=True)
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    consent_log = models.JSONField(default=dict)
    totp_enabled = models.BooleanField(default=False)
    # Fernet ciphertext is ~140 chars for a 16-byte seed, hence 255 not 64.
    # Never rendered in the admin: a TOTP seed displayed in a change form is
    # a stolen second factor.
    totp_secret = EncryptedCharField(max_length=255, blank=True)
    # Brute-force damping for the password / OTP / TOTP login steps. Reset on
    # any successful authentication; deliberately NOT touched by the
    # forgot-password flow so a locked-out user can still recover their
    # password by mail.
    failed_login_count = models.IntegerField(default=0)
    locked_until = models.DateTimeField(null=True, blank=True)
    google_id = models.CharField(max_length=100, blank=True)
    apple_id = models.CharField(max_length=100, blank=True)
    preferences = models.JSONField(default=dict, blank=True)

    # Parental co-owner (mandatory for users aged 16–17 per platform policy).
    guardian_name = models.CharField(max_length=120, blank=True)
    guardian_email = models.EmailField(blank=True)
    guardian_phone = models.CharField(max_length=20, blank=True)
    guardian_verified = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    class Meta:
        db_table = 'accounts_user'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['phone']),
            models.Index(fields=['is_active', 'deleted_at']),
        ]

    def __str__(self):
        return self.email


class AccountStanding(TimestampedModel):
    """The enforcement record for a moderation decision on one account.

    ``User.is_active = False`` alone cannot express a ban: the login flow
    deliberately re-authenticates inactive accounts so a user can reactivate
    one they deactivated themselves, which means an ``is_active`` flip by a
    moderator was self-reversible on the very next login. This row is what
    makes the two cases distinguishable:

    * ``is_moderation_action = True`` + ``state`` in ``(suspended, banned)``
      -> the login flow refuses to reactivate and points at support/appeal.
      Only ``lift_standing_action`` clears it.
    * No row (or ``state='clear'``) -> a self-deactivation, which login may
      still reverse with ``reactivate: true``.

    Enforcement points are DRF authentication, the login flows and token
    refresh; ``services.apply_standing_action`` is the only writer.
    """

    STATE_CLEAR = 'clear'
    STATE_WARNED = 'warned'
    STATE_SUSPENDED = 'suspended'
    STATE_BANNED = 'banned'

    STATE_CHOICES = [
        (STATE_CLEAR, 'Clear'),
        (STATE_WARNED, 'Warned'),
        (STATE_SUSPENDED, 'Suspended'),
        (STATE_BANNED, 'Banned'),
    ]
    #: States that stop authentication outright. ``warned`` is deliberately
    #: absent: a warning annotates the account, it does not lock the user out.
    BLOCKING_STATES = (STATE_SUSPENDED, STATE_BANNED)

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='account_standing',
    )
    state = models.CharField(max_length=16, choices=STATE_CHOICES, default=STATE_CLEAR)
    reason = models.TextField(blank=True)
    # Correlation id supplied by the calling system (``governance:<uuid>``)
    # so a support ticket maps back to the decision that produced it.
    action_id = models.CharField(max_length=64, blank=True)
    # Set only for a temporary suspension; ``None`` means "indefinite until
    # lifted" for a suspension and "forever" for a ban.
    suspended_until = models.DateTimeField(null=True, blank=True)
    permanent = models.BooleanField(default=False)
    # The flag that separates a moderation action from a self-deactivation.
    is_moderation_action = models.BooleanField(default=False)
    issued_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='account_standing_actions_issued',
    )
    issued_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = 'accounts_account_standing'
        indexes = [
            models.Index(fields=['state', '-issued_at']),
        ]
        ordering = ['-issued_at']

    def __str__(self):
        return f'{self.user} — {self.state}'

    @property
    def is_blocking(self) -> bool:
        """True when this standing forbids authentication."""
        return self.state in self.BLOCKING_STATES

    @property
    def is_expired(self) -> bool:
        """True for a temporary suspension whose window has passed."""
        return bool(
            self.state == self.STATE_SUSPENDED
            and not self.permanent
            and self.suspended_until
            and self.suspended_until <= timezone.now()
        )

    def blocks_authentication(self) -> bool:
        """Blocking right now — an expired temporary suspension does not."""
        return self.is_blocking and not self.is_expired

    def as_payload(self) -> dict:
        """The client-facing shape returned by every standing rejection."""
        return {
            'state': self.state,
            'reason': self.reason,
            'until': self.suspended_until.isoformat() if self.suspended_until else None,
            'permanent': self.permanent,
        }


class OTPToken(TimestampedModel):
    CHANNEL_CHOICES = [('email', 'Email'), ('phone', 'Phone')]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='otp_tokens')
    code = models.CharField(max_length=6)
    channel = models.CharField(max_length=5, choices=CHANNEL_CHOICES)
    is_used = models.BooleanField(default=False)
    expires_at = models.DateTimeField()
    attempts = models.IntegerField(default=0)

    class Meta:
        db_table = 'accounts_otp_token'
        indexes = [
            models.Index(fields=['user', 'channel']),
            models.Index(fields=['code', 'is_used']),
        ]

    def is_valid(self):
        from django.utils import timezone
        return not self.is_used and self.attempts < 3 and self.expires_at > timezone.now()


class RecoveryCode(TimestampedModel):
    """Single-use backup code for 2FA recovery. Only the hash is stored."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='recovery_codes')
    code_hash = models.CharField(max_length=64, db_index=True)
    is_used = models.BooleanField(default=False)

    class Meta:
        db_table = 'accounts_recovery_code'
        indexes = [
            models.Index(fields=['user', 'is_used']),
        ]

    @staticmethod
    def hash_code(code: str) -> str:
        import hashlib
        return hashlib.sha256(code.strip().upper().encode()).hexdigest()


class DeviceSession(TimestampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_sessions')
    refresh_token_hash = models.CharField(max_length=64, unique=True)
    # Stable client identifier (X-Device-Id header) used to recognise the
    # current session in the device list. Truncated to 64 chars.
    device_id = models.CharField(max_length=64, blank=True, db_index=True)
    device_name = models.CharField(max_length=200)
    ip_address = models.GenericIPAddressField()
    location = models.CharField(max_length=100, blank=True)
    is_active = models.BooleanField(default=True)
    last_active = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'accounts_device_session'
        indexes = [
            models.Index(fields=['user', 'is_active']),
        ]


class AccountEvent(TimestampedModel):
    EVENT_CHOICES = [
        ('login', 'Login'),
        ('login_failed', 'Login Failed'),
        ('account_suspended', 'Account Suspended'),
        ('account_banned', 'Account Banned'),
        ('account_standing_lifted', 'Account Standing Lifted'),
        ('mfa_enrolment_required', 'MFA Enrolment Required'),
        ('login_new_device', 'Login from New Device'),
        ('login_new_country', 'Login from New Country'),
        ('password_changed', 'Password Changed'),
        ('email_changed', 'Email Changed'),
        ('2fa_enabled', '2FA Enabled'),
        ('2fa_disabled', '2FA Disabled'),
        ('2fa_recovery_used', '2FA Recovery Code Used'),
        ('passkey_registered', 'Passkey Registered'),
        ('passkey_renamed', 'Passkey Renamed'),
        ('passkey_revoked', 'Passkey Revoked'),
        ('security_notification_sent', 'Security Notification Sent'),
        ('account_deactivated', 'Account Deactivated'),
        ('account_reactivated', 'Account Reactivated'),
        ('account_deleted', 'Account Deleted'),
        ('post_created', 'Post Created'),
        ('post_deleted', 'Post Deleted'),
        ('buddy_request_sent', 'Buddy Request Sent'),
        ('buddy_request_accepted', 'Buddy Request Accepted'),
        ('profile_updated', 'Profile Updated'),
        ('avatar_updated', 'Avatar Updated'),
        ('comment_added', 'Comment Added'),
        ('reaction_added', 'Reaction Added'),
        ('live_started', 'Live Started'),
        ('session_booked', 'Session Booked'),
        ('marketplace_purchase', 'Marketplace Purchase'),
        ('wallet_transaction', 'Wallet Transaction'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='events')
    event_type = models.CharField(max_length=30, choices=EVENT_CHOICES)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    metadata = models.JSONField(default=dict)

    class Meta:
        db_table = 'accounts_event'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['event_type']),
        ]


class WebAuthnCredential(TimestampedModel):
    """A registered passkey (WebAuthn platform/roaming authenticator)."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='webauthn_credentials')
    credential_id = models.CharField(max_length=512, unique=True)  # base64url
    public_key = models.BinaryField()
    sign_count = models.BigIntegerField(default=0)
    transports = models.JSONField(default=list)
    device_name = models.CharField(max_length=120, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    last_verified_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'accounts_webauthn_credential'
