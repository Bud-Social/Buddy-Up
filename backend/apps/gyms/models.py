from uuid import uuid4

from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class Gym(TimestampedModel, SoftDeleteModel):
    ACCESS_CHOICES = [
        ('public', 'Public'),
        ('private', 'Private'),
        ('secret', 'Secret'),
    ]
    SUBSCRIPTION_CHOICES = [
        ('free', 'Free'),
        ('members_free', 'Free (Members Only)'),
        ('paid', 'Paid'),
        ('tiered', 'Tiered'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    name = models.CharField(max_length=60, unique=True)
    handle = models.CharField(max_length=60, unique=True)
    description = models.TextField(max_length=500, blank=True)
    logo_url = models.URLField(blank=True)
    cover_url = models.URLField(blank=True)
    category = models.CharField(max_length=50)
    access_type = models.CharField(max_length=8, choices=ACCESS_CHOICES, default='public')
    subscription_type = models.CharField(max_length=15, choices=SUBSCRIPTION_CHOICES, default='free')
    monthly_fee_artifacts = models.JSONField(null=True, blank=True)
    join_fee_artifacts = models.JSONField(null=True, blank=True)
    wallet_balance = models.JSONField(default=dict)
    is_verified = models.BooleanField(default=False)
    rules = models.JSONField(default=list)
    tags = models.JSONField(default=list)
    member_count = models.IntegerField(default=0)
    location_city = models.CharField(max_length=100, blank=True)
    location_country = models.CharField(max_length=100, blank=True)

    class Meta:
        db_table = 'gyms_gym'
        indexes = [
            models.Index(fields=['name']),
            models.Index(fields=['handle']),
            models.Index(fields=['category']),
            models.Index(fields=['access_type']),
            models.Index(fields=['location_city', 'location_country']),
        ]

    def __str__(self):
        return self.name


class GymMembership(TimestampedModel):
    ROLE_CHOICES = [
        ('owner', 'Owner'),
        ('co_owner', 'Co-Owner'),
        ('trainer', 'Trainer'),
        ('moderator', 'Moderator'),
        ('member', 'Member'),
        ('guest', 'Guest'),
    ]

    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='memberships')
    member = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_memberships')
    role = models.CharField(max_length=15, choices=ROLE_CHOICES, default='member')
    subscription_active = models.BooleanField(default=True)
    subscription_expires_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'gyms_gym_membership'
        unique_together = ('gym', 'member')
        indexes = [
            models.Index(fields=['member', 'subscription_active']),
        ]
