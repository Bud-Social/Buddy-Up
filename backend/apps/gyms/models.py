from uuid import uuid4

from django.db import models
from common.models import TimestampedModel, SoftDeleteModel
from common.age_gating import CONTENT_RATING_CHOICES, CONTENT_RATING_DEFAULT


class GymCategory(models.Model):
    name = models.CharField(max_length=50, unique=True)
    display_name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, blank=True, default='')
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gyms_category'
        verbose_name_plural = 'gym categories'

    def __str__(self):
        return self.display_name


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
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    categories = models.ManyToManyField(GymCategory, related_name='gyms', blank=True)
    access_type = models.CharField(max_length=8, choices=ACCESS_CHOICES, default='public')
    subscription_type = models.CharField(max_length=15, choices=SUBSCRIPTION_CHOICES, default='free')
    monthly_fee_artifacts = models.JSONField(null=True, blank=True)
    join_fee_artifacts = models.JSONField(null=True, blank=True)
    wallet_balance = models.JSONField(default=dict)
    is_reviews_enabled = models.BooleanField(default=True)
    is_donations_enabled = models.BooleanField(default=False)
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


class GymCategoryPricing(models.Model):
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='category_pricing')
    category = models.ForeignKey(GymCategory, on_delete=models.CASCADE)
    fee_per_day = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    fee_per_week = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    fee_per_month = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    fee_per_year = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    is_free = models.BooleanField(default=False)

    class Meta:
        db_table = 'gyms_category_pricing'
        unique_together = ('gym', 'category')

    def __str__(self):
        return f'{self.gym.name} - {self.category.display_name}'


class JoinRequest(TimestampedModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='join_requests')
    requester = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_join_requests')
    message = models.TextField(max_length=200, blank=True, default='')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    reviewed_by = models.ForeignKey('profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='reviewed_join_requests')
    reviewed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'gyms_join_request'
        unique_together = ('gym', 'requester', 'status')

    def __str__(self):
        return f'{self.requester.username} -> {self.gym.name} ({self.status})'


class GymInvite(TimestampedModel):
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='invites')
    invited_user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_invites')
    invited_by = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='sent_gym_invites')
    status = models.CharField(max_length=10, choices=[
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined'),
    ], default='pending')

    class Meta:
        db_table = 'gyms_invite'
        unique_together = ('gym', 'invited_user')

    def __str__(self):
        return f'{self.invited_by.username} invited {self.invited_user.username} to {self.gym.name}'


class GymSchedulePost(TimestampedModel):
    ACTIVITY_CHOICES = [
        ('yoga', 'Yoga Class'),
        ('hiit', 'HIIT Session'),
        ('strength', 'Strength & Conditioning'),
        ('cardio', 'Cardio Class'),
        ('live_stream', 'Live Stream'),
        ('workshop', 'Workshop / Seminar'),
        ('event', 'Special Event'),
        ('session', 'Session'),
        ('other', 'Other'),
    ]
    LOCATION_CHOICES = [
        ('in_house', 'In House'),
        ('online', 'Online'),
        ('hybrid', 'Hybrid'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='schedule_posts')
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_schedule_posts')
    title = models.CharField(max_length=150, blank=True)
    content = models.TextField(max_length=2000, blank=True)
    activity_type = models.CharField(max_length=20, choices=ACTIVITY_CHOICES, default='other')
    custom_activity_type = models.CharField(max_length=50, blank=True)
    location_mode = models.CharField(max_length=15, choices=LOCATION_CHOICES, default='in_house')
    start_time = models.DateTimeField(null=True, blank=True)
    end_time = models.DateTimeField(null=True, blank=True)
    recurrence = models.CharField(max_length=10, choices=[
        ('none', 'None'), ('daily', 'Daily'), ('weekly', 'Weekly'),
        ('monthly', 'Monthly'), ('yearly', 'Yearly'),
    ], default='none')
    recurrence_end_date = models.DateField(null=True, blank=True)
    recurrence_days = models.JSONField(default=list)  # list of weekday ints 0=Mon
    max_slots = models.IntegerField(default=0)  # 0 = unlimited
    slots_taken = models.IntegerField(default=0)
    timezone = models.CharField(max_length=60, default='UTC')
    linked_live = models.ForeignKey('lives.BuddyLive', null=True, blank=True, on_delete=models.SET_NULL, related_name='schedule_slots')

    class Meta:
        db_table = 'gyms_schedule_post'
        ordering = ['-created_at']

    def __str__(self):
        return f'Schedule Post in {self.gym.name} by {self.author.username}'


class ScheduleSlotEnrollment(TimestampedModel):
    RECURRENCE_CHOICES = [
        ('none', 'One-time'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
        ('yearly', 'Yearly'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    schedule_post = models.ForeignKey(GymSchedulePost, on_delete=models.CASCADE, related_name='enrollments')
    member = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='slot_enrollments')
    recurrence = models.CharField(max_length=10, choices=RECURRENCE_CHOICES, default='none')
    recurrence_end_date = models.DateField(null=True, blank=True)
    reminder_minutes = models.JSONField(default=list)  # e.g. [30, 15]
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gyms_slot_enrollment'
        unique_together = ('schedule_post', 'member')
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.member.username} enrolled in {self.schedule_post.title}'


class GymReview(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='reviews')
    reviewer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_reviews')
    rating = models.PositiveSmallIntegerField(choices=[(i, str(i)) for i in range(1, 6)])
    comment = models.TextField(max_length=1000, blank=True)
    reply_text = models.TextField(max_length=1000, blank=True)
    replied_by = models.ForeignKey('profiles.Profile', on_delete=models.SET_NULL, null=True, blank=True, related_name='gym_review_replies')
    replied_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'gyms_review'
        unique_together = ('gym', 'reviewer')
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.rating} star by {self.reviewer.username} for {self.gym.name}'


class GymDonation(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='donations')
    donor = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_donations')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    message = models.TextField(max_length=500, blank=True)

    class Meta:
        db_table = 'gyms_donation'
        ordering = ['-created_at']

    def __str__(self):
        return f'Donation of {self.amount} by {self.donor.username} to {self.gym.name}'


class GymMembershipException(TimestampedModel):
    """Owner-granted exception overriding subscription fees for a specific member."""

    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='membership_exceptions')
    member = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='gym_membership_exceptions')
    discount_pct = models.IntegerField(default=100)  # 100 = full discount (free), 0 = no discount
    reason = models.CharField(max_length=200, blank=True, default='')
    created_by = models.ForeignKey(
        'profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL,
        related_name='created_gym_membership_exceptions',
    )
    expires_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gyms_membership_exception'
        unique_together = ('gym', 'member')

    def __str__(self):
        return f'{self.member.username} exception on {self.gym.name} ({self.discount_pct}%)'
