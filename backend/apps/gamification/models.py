from uuid import uuid4

from django.db import models

from common.models import TimestampedModel


class AchievementDefinition(TimestampedModel):
    """A platform-wide achievement that users can earn.

    Criteria use a simple metric/threshold model evaluated by
    ``apps.gamification.services`` against live user data:

        {"metric": "activities_total", "threshold": 10}

    Metrics are computed from existing analytics/feed/live tables — no
    third-party dependency.
    """

    TIERS = [
        ('bronze', 'Bronze'),
        ('silver', 'Silver'),
        ('gold', 'Gold'),
        ('platinum', 'Platinum'),
    ]
    CATEGORIES = [
        ('activity', 'Activity & Training'),
        ('nutrition', 'Nutrition'),
        ('social', 'Social & Community'),
        ('live', 'Live & Sessions'),
        ('consistency', 'Consistency'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    code = models.SlugField(max_length=60, unique=True)
    title = models.CharField(max_length=100)
    description = models.CharField(max_length=300)
    icon = models.CharField(max_length=40, default='🏆')
    tier = models.CharField(max_length=10, choices=TIERS, default='bronze')
    category = models.CharField(max_length=15, choices=CATEGORIES, default='activity')
    metric = models.CharField(max_length=50, help_text='Metric key evaluated by services.py')
    threshold = models.FloatField(help_text='Value the metric must reach to unlock')
    sort_order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'gamification_achievement_definition'
        ordering = ['sort_order', 'threshold']
        indexes = [models.Index(fields=['is_active', 'category'])]

    def __str__(self):
        return f'{self.icon} {self.title} ({self.tier})'


class UserAchievement(TimestampedModel):
    """An earned (or in-progress) achievement for a profile."""

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='achievements',
    )
    definition = models.ForeignKey(
        AchievementDefinition, on_delete=models.CASCADE,
        related_name='earned_by',
    )
    progress = models.FloatField(default=0.0, help_text='Metric value at last evaluation')
    earned_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'gamification_user_achievement'
        constraints = [
            models.UniqueConstraint(fields=['profile', 'definition'], name='uniq_profile_achievement'),
        ]
        ordering = ['-earned_at', '-created_at']
        indexes = [models.Index(fields=['profile', '-earned_at'])]

    def __str__(self):
        return f'{self.profile_id}: {self.definition.code}'
