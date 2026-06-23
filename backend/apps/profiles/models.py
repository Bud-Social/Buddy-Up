from django.db import models
from common.models import TimestampedModel


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
    verification_status = models.CharField(max_length=20, choices=VERIFICATION_CHOICES, default='none')
    privacy_level = models.CharField(max_length=10, choices=PRIVACY_CHOICES, default='public')
    external_link = models.URLField(blank=True)
    workout_schedule = models.JSONField(null=True, blank=True)

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
        constraints = [
            models.UniqueConstraint(
                fields=['from_user', 'to_user'],
                condition=models.Q(created_at__date=models.functions.Now()),
                name='one_ping_per_buddy_per_day',
            ),
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
