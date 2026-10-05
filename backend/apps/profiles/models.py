from django.db import models
from common.models import TimestampedModel
from common.age_gating import CONTENT_RATING_CHOICES, CONTENT_RATING_DEFAULT


class Profile(TimestampedModel):
    ROLE_CHOICES = [
        ('user', 'Regular User'),
        ('trainer', 'Personal Trainer'),
        ('practitioner', 'Health Practitioner'),
    ]
    VERIFICATION_CHOICES = [
        ('none', 'None'),
        ('email', 'Email Verified'),
        ('id', 'ID Verified'),
        ('trainer', 'Certified Trainer'),
        ('practitioner', 'Health Practitioner'),
        ('shop', 'Verified Shop'),
        ('gym', 'Verified Gym'),
    ]
    PRIVACY_CHOICES = [
        ('public', 'Public'),
        ('private', 'Private'),
    ]

    user = models.OneToOneField('accounts.User', on_delete=models.CASCADE, primary_key=True, related_name='profile')
    username = models.CharField(max_length=30, unique=True)
    display_name = models.CharField(max_length=50)
    bio = models.CharField(max_length=200, blank=True)
    avatar_url = models.URLField(blank=True)
    cover_url = models.URLField(blank=True)
    pronouns = models.CharField(max_length=30, blank=True)
    location_city = models.CharField(max_length=100, blank=True)
    location_country = models.CharField(max_length=100, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='user')
    is_anonymous_posting = models.BooleanField(default=False)
    show_active_status = models.BooleanField(default=True)
    streak_days = models.IntegerField(default=0)
    streak_last_activity = models.DateField(null=True, blank=True)
    artifact_balance = models.JSONField(default=dict)
    locked_balance = models.JSONField(default=dict)
    creator_balance = models.JSONField(default=dict)
    creator_display_name = models.CharField(max_length=50, blank=True)
    verification_status = models.CharField(max_length=20, choices=VERIFICATION_CHOICES, default='none')
    privacy_level = models.CharField(max_length=10, choices=PRIVACY_CHOICES, default='public')
    # Onboarding & consent. onboarding_completed defaults True so accounts
    # created before the pipeline existed are never gated; registration and
    # social-provisioning set it False for new users.
    onboarding_completed = models.BooleanField(default=True)
    terms_version = models.CharField(max_length=20, blank=True)
    terms_accepted_at = models.DateTimeField(null=True, blank=True)
    marketing_consent = models.BooleanField(default=False)
    external_link = models.URLField(blank=True)
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    workout_schedule = models.JSONField(null=True, blank=True)
    saved_payment_methods = models.JSONField(default=list, blank=True)
    last_seen = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'profiles_profile'
        indexes = [
            models.Index(fields=['username']),
            models.Index(fields=['role']),
            models.Index(fields=['verification_status']),
            models.Index(fields=['location_city', 'location_country']),
        ]

    def __str__(self):
        return f'@{self.username}'


class BuddyRelationship(TimestampedModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('declined', 'Declined'),
    ]

    from_user = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='buddy_sent')
    to_user = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='buddy_received')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')

    class Meta:
        db_table = 'profiles_buddy_relationship'
        unique_together = ('from_user', 'to_user')
        indexes = [
            models.Index(fields=['from_user', 'status']),
            models.Index(fields=['to_user', 'status']),
        ]


class FollowRelationship(TimestampedModel):
    follower = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='following')
    followee = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='followers')

    class Meta:
        db_table = 'profiles_follow_relationship'
        unique_together = ('follower', 'followee')
        indexes = [
            models.Index(fields=['follower']),
            models.Index(fields=['followee']),
        ]


class BlockRelationship(TimestampedModel):
    blocker = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='blocks_made')
    blocked = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='blocks_received')

    class Meta:
        db_table = 'profiles_block_relationship'
        unique_together = ('blocker', 'blocked')


class RecommendationFeedback(TimestampedModel):
    FEEDBACK_CHOICES = [
        ('not_interested', 'Not Interested'),
        ('irrelevant', 'Irrelevant'),
        ('already_connected', 'Already Connected'),
        ('helpful', 'Helpful'),
    ]

    viewer = models.ForeignKey(
        Profile, on_delete=models.CASCADE, related_name='recommendation_feedback_given'
    )
    target = models.ForeignKey(
        Profile, on_delete=models.CASCADE, related_name='recommendation_feedback_received'
    )
    feedback = models.CharField(max_length=20, choices=FEEDBACK_CHOICES)
    # Append-only history of {feedback, at} — the current value must never
    # erase what the user said before (needed for ranking evaluation).
    history = models.JSONField(default=list, blank=True)

    class Meta:
        db_table = 'profiles_recommendation_feedback'
        constraints = [
            models.UniqueConstraint(
                fields=['viewer', 'target'], name='unique_profile_recommendation_feedback'
            ),
            models.CheckConstraint(
                condition=~models.Q(viewer=models.F('target')),
                name='recommendation_feedback_not_self',
            ),
        ]
        indexes = [models.Index(fields=['viewer', 'feedback'], name='profiles_re_viewer__4ce10b_idx')]


class AccountabilityPing(TimestampedModel):
    from_user = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='pings_sent')
    to_user = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='pings_received')
    message = models.CharField(max_length=100, default="How's your workout going? 💪")
    responded = models.BooleanField(default=False)

    class Meta:
        db_table = 'profiles_accountability_ping'
        indexes = [
            models.Index(fields=['to_user', '-created_at']),
        ]


class SharedGoal(TimestampedModel):
    title = models.CharField(max_length=100)
    description = models.CharField(max_length=300, blank=True)
    target = models.CharField(max_length=100)
    buddies = models.ManyToManyField(Profile, related_name='shared_goals')
    created_by = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='goals_created')
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'profiles_shared_goal'


class BuddySearchProfile(TimestampedModel):
    """Opt-in 'looking for a buddy' profile (walk/run/gym/hike/...).

    Location is radius-only: lat/lng are stored for distance computation but
    never exposed for other users — APIs return banded distance_km only.
    Dating/romance intents are intentionally excluded (deferred).
    """

    INTENT_CHOICES = [
        'walk', 'run', 'gym', 'hike', 'cycle', 'swim', 'football', 'other',
        'live_cohost', 'trainer', 'coach', 'book_club', 'friend',
    ]
    MODE_CHOICES = ['virtual', 'hybrid', 'in_person', 'neighbourhood']
    VISIBILITY_CHOICES = [
        ('public', 'Public'),
        ('buddies', 'Buddies only'),
        ('hidden', 'Hidden'),
    ]

    profile = models.OneToOneField(
        Profile, on_delete=models.CASCADE, primary_key=True, related_name='search_profile'
    )
    intents = models.JSONField(default=list, blank=True)
    display_name = models.CharField(max_length=50, blank=True)
    custom_intent = models.CharField(max_length=100, blank=True)
    modes = models.JSONField(default=list, blank=True)
    bio = models.CharField(max_length=140, blank=True)
    goals = models.JSONField(default=list, blank=True)
    # Opt-in age only: hashed DOB + derived 3-5y band label (no raw date stored).
    dob_hash = models.CharField(max_length=64, blank=True)
    age_band = models.CharField(max_length=10, blank=True)
    photos = models.JSONField(default=list, blank=True)
    neighbourhood = models.CharField(max_length=100, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location_updated_at = models.DateTimeField(null=True, blank=True)
    # Null = auto (5 km dense / 10 km sparse, see common.geo).
    search_radius_km = models.FloatField(null=True, blank=True)
    available_now = models.BooleanField(default=False)
    available_until = models.DateTimeField(null=True, blank=True)
    pace = models.CharField(max_length=20, blank=True)
    visibility = models.CharField(max_length=10, choices=VISIBILITY_CHOICES, default='public')
    incognito = models.BooleanField(default=False)

    class Meta:
        db_table = 'profiles_buddy_search_profile'
        indexes = [
            models.Index(fields=['available_now']),
            models.Index(fields=['latitude', 'longitude']),
        ]

    def __str__(self):
        return f'search:{self.profile.username}'
