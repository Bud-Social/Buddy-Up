"""Countdowns & streaks for sobriety, diet, gym attendance, walking days, etc.

A countdown tracks a streak or days-since counter for a specific reason.
Reasons can be platform templates (sobriety, no artificial sugars, no animal
proteins, gym attendance, walking days, no drugs, etc.) or user-defined
custom reasons.

Each countdown is either:
- ``manual`` — the user checks in / resets it themselves.
- ``automatic`` — derived from another signal (logged activity, GPS gym
  check-in, etc.) and advances without manual intervention.
"""

import uuid

from django.db import models
from django.utils import timezone
from common.models import TimestampedModel


class CountdownTemplate(TimestampedModel):
    """A predefined countdown reason offered to all users."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code = models.CharField(max_length=40, unique=True, help_text='Machine slug, e.g. sobriety, no_artificial_sugars')
    title = models.CharField(max_length=100, help_text='Human-readable reason, e.g. "Sobriety"')
    description = models.TextField(blank=True, help_text='What this countdown tracks')
    unit = models.CharField(
        max_length=20,
        choices=[('days', 'Days'), ('hours', 'Hours')],
        default='days',
    )
    default_target = models.PositiveIntegerField(
        default=0, help_text='Target value (0 = indefinite streak / days since)'
    )
    icon = models.CharField(max_length=10, default='📅', help_text='Emoji icon')
    color = models.CharField(max_length=20, default='#6366f1', help_text='Hex color for UI')
    is_active = models.BooleanField(default=True)
    sort_order = models.IntegerField(default=0)

    class Meta:
        db_table = 'countdowns_template'
        ordering = ['sort_order', 'title']

    def __str__(self):
        return self.title


def default_start_date():
    """Default start date for a new countdown: today's date."""
    return timezone.now().date()


class UserCountdown(TimestampedModel):
    """A user's active countdown for a specific reason."""

    COUNTDOWN_TYPES = [
        ('manual', 'Manual'),
        ('automatic', 'Automatic'),
    ]

    UNIT_CHOICES = [
        ('days', 'Days'),
        ('hours', 'Hours'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='user_countdowns',
    )
    template = models.ForeignKey(
        CountdownTemplate, null=True, blank=True, on_delete=models.SET_NULL,
        related_name='user_instances',
        help_text='Null for fully custom countdowns.',
    )
    custom_reason = models.CharField(
        max_length=120, blank=True,
        help_text='Free-text reason when template is null.',
    )
    countdown_type = models.CharField(max_length=15, choices=COUNTDOWN_TYPES, default='manual')
    unit = models.CharField(max_length=20, choices=UNIT_CHOICES, default='days')
    current_count = models.PositiveIntegerField(default=0, help_text='Current streak / days counter')
    target_count = models.PositiveIntegerField(default=0, help_text='Goal target (0 = no fixed target)')
    start_date = models.DateField(default=default_start_date, help_text='Day counting began')
    last_checkin_at = models.DateTimeField(null=True, blank=True, help_text='Last manual check-in')
    last_auto_advance_at = models.DateTimeField(
        null=True, blank=True, help_text='Last time an automatic signal advanced this countdown'
    )
    auto_advance_signal = models.CharField(
        max_length=40, blank=True,
        help_text='Signal key for automatic advance, e.g. activity_walk, gym_checkin',
    )
    is_active = models.BooleanField(default=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'countdowns_user_countdown'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_active']),
            models.Index(fields=['user', 'countdown_type']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'template'], name='countdowns_user_template_unique',
                condition=models.Q(template__isnull=False),
            ),
        ]

    def __str__(self):
        label = self.custom_reason or (self.template.title if self.template else 'Countdown')
        return f'{label}: {self.current_count} {self.unit}'

    @property
    def display_reason(self):
        return self.custom_reason or (self.template.title if self.template else 'Custom Countdown')

    @property
    def display_icon(self):
        return self.template.icon if self.template else '📅'

    @property
    def days_since_start(self):
        if not self.start_date:
            return 0
        return (timezone.now().date() - self.start_date).days

    def advance(self, amount=1, signal=None):
        """Advance the countdown by ``amount`` (manual or automatic)."""
        self.current_count = (self.current_count or 0) + amount
        if signal:
            self.auto_advance_signal = signal
            self.last_auto_advance_at = timezone.now()
        else:
            self.last_checkin_at = timezone.now()
        if self.target_count and self.current_count >= self.target_count and not self.completed_at:
            self.completed_at = timezone.now()
        self.save(update_fields=[
            'current_count', 'last_checkin_at', 'last_auto_advance_at',
            'auto_advance_signal', 'completed_at', 'updated_at',
        ])
        return self

    def reset(self):
        """Reset the countdown to zero and clear completion."""
        self.current_count = 0
        self.completed_at = None
        self.last_checkin_at = None
        self.last_auto_advance_at = None
        self.save(update_fields=['current_count', 'completed_at', 'last_checkin_at', 'last_auto_advance_at', 'updated_at'])
        return self


class Routine(TimestampedModel):
    """A recurring habit routine (walk, run, cycle, hike, workout)."""

    ROUTINE_TYPES = [
        ('walk', 'Walking'),
        ('run', 'Running'),
        ('cycle', 'Cycling'),
        ('hike', 'Hiking'),
        ('workout', 'Workout'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='routines',
    )
    type = models.CharField(max_length=15, choices=ROUTINE_TYPES)
    name = models.CharField(max_length=120)
    target = models.PositiveIntegerField(default=30, help_text='Target value per session')
    unit = models.CharField(max_length=20, default='min', help_text='steps, km, min')
    days = models.JSONField(default=list, help_text='Active days of week [0-6, 0=Sunday]')
    streak = models.PositiveIntegerField(default=0)
    completed_today = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'countdowns_routine'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_active']),
        ]

    def __str__(self):
        return f'{self.name}: {self.target} {self.unit}'
