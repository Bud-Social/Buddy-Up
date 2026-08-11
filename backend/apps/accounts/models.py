from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from uuid import uuid4
from common.models import TimestampedModel


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
    deletion_type = models.CharField(max_length=20, null=True, blank=True, choices=[('user', 'User'), ('moderation', 'Moderation')])
    created_at = models.DateTimeField(auto_now_add=True)
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    consent_log = models.JSONField(default=dict)
    totp_enabled = models.BooleanField(default=False)
    totp_secret = models.CharField(max_length=64, blank=True)
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


class DeviceSession(TimestampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_sessions')
    refresh_token_hash = models.CharField(max_length=64, unique=True)
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
        ('login_new_device', 'Login from New Device'),
        ('login_new_country', 'Login from New Country'),
        ('password_changed', 'Password Changed'),
        ('email_changed', 'Email Changed'),
        ('2fa_enabled', '2FA Enabled'),
        ('2fa_disabled', '2FA Disabled'),
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
