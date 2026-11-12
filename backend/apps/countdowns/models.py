"""Countdowns & streaks for sobriety, diet, gym attendance, walking days, etc.

A countdown tracks a streak or days-since counter for a specific reason.
Reasons can be platform templates (sobriety, no artificial sugars, no animal
proteins, gym attendance, walking days, no drugs, etc.) or user-defined
custom reasons.

Each countdown is either:
- ``manual`` — the user checks in / resets it themselves.
- ``automatic`` — derived from another signal (logged activity, GPS gym
  check-in, etc.) and advances without manual intervention.

Every change to a countdown is written to a :class:`CountdownEvent` stream, so
the history of a countdown survives the resets that clear its counter. The
stream is what the analytics page reads.
"""

import uuid
from datetime import timedelta

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
    icon = models.CharField(max_length=40, default='📅', help_text='Emoji icon')
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

    #: How long a unit lasts. A manual countdown can only be checked in once
    #: per unit, so an hourly one unlocks every hour and a daily one every
    #: 24 hours.
    UNIT_SECONDS = {
        'days': 24 * 60 * 60,
        'hours': 60 * 60,
    }

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
    # When the current run began. Null means the run started when the
    # countdown was created; a reset moves it forward and the previous run
    # stays in the event stream.
    last_reset_at = models.DateTimeField(null=True, blank=True)

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

    @property
    def run_started_at(self):
        """When the current streak began."""
        return self.last_reset_at or self.created_at

    @property
    def elapsed_units(self):
        """Whole units completed since the current streak began.

        This is the wall-clock length of the streak, which is not the same
        thing as the counter: a manual countdown's counter only moves when
        the user checks in, and an automatic one only moves when its signal
        fires.
        """
        started = self.run_started_at
        if not started:
            return 0
        delta = timezone.now() - started
        if self.unit == 'hours':
            return int(delta.total_seconds() // 3600)
        return delta.days

    @property
    def run_elapsed_seconds(self):
        started = self.run_started_at
        if not started:
            return 0
        return int((timezone.now() - started).total_seconds())

    def _last_event(self):
        return self.events.order_by('-occurred_at').first()

    def next_checkin_at(self):
        """When the next check-in unlocks, or None when it is already open."""
        if not self.last_checkin_at:
            return None
        interval = self.UNIT_SECONDS.get(self.unit, self.UNIT_SECONDS['days'])
        return self.last_checkin_at + timedelta(seconds=interval)

    def checkin_ready_at(self, now=None):
        """Whether a check-in is unlocked, and when it next opens."""
        now = now or timezone.now()
        unlock = self.next_checkin_at()
        if unlock is None or unlock <= now:
            return True, None
        return False, unlock

    def _write_event(self, event_type, now=None, note=''):
        """Append to the countdown's stream.

        The gap since the previous event is what the cadence analytics reads,
        and the run length is what the "how long did this streak last" chart
        reads.
        """
        now = now or timezone.now()
        previous = self._last_event()
        elapsed = int((now - previous.occurred_at).total_seconds()) if previous else 0
        run_elapsed = int((now - self.run_started_at).total_seconds())
        return CountdownEvent.objects.create(
            countdown=self,
            user=self.user,
            event_type=event_type,
            count_after=self.current_count,
            elapsed_seconds=max(0, elapsed),
            run_elapsed_seconds=max(0, run_elapsed),
            unit=self.unit,
            note=note,
            occurred_at=now,
        )

    def advance(self, amount=1, signal=None, note=''):
        """Advance the countdown by ``amount`` (manual or automatic)."""
        now = timezone.now()
        self.current_count = (self.current_count or 0) + amount
        if signal:
            self.auto_advance_signal = signal
            self.last_auto_advance_at = now
        else:
            self.last_checkin_at = now
        reached_target = bool(
            self.target_count and self.current_count >= self.target_count and not self.completed_at
        )
        if reached_target:
            self.completed_at = now
        self.save(update_fields=[
            'current_count', 'last_checkin_at', 'last_auto_advance_at',
            'auto_advance_signal', 'completed_at', 'updated_at',
        ])
        self._write_event('auto_advance' if signal else 'checkin', now=now, note=note)
        if reached_target:
            self._write_event('complete', now=now)
        return self

    def reset(self, note=''):
        """Reset the counter and start a new run.

        The previous run is not lost: it stays in the event stream, and the
        reset that ended it is recorded there too.
        """
        now = timezone.now()
        self.current_count = 0
        self.completed_at = None
        self.last_checkin_at = None
        self.last_auto_advance_at = None
        self.last_reset_at = now
        self.save(update_fields=[
            'current_count', 'completed_at', 'last_checkin_at',
            'last_auto_advance_at', 'last_reset_at', 'updated_at',
        ])
        self._write_event('reset', now=now, note=note)
        return self


class CountdownEvent(TimestampedModel):
    """One entry in a countdown's stream.

    Every change to a countdown is recorded here — creation, check-ins,
    automatic advances, resets and completions. The stream is what makes a
    reset non-destructive: the counter goes back to zero, but the history of
    how the user got there is still there to analyse.
    """

    EVENT_TYPES = [
        ('create', 'Created'),
        ('checkin', 'Checked in'),
        ('reset', 'Reset'),
        ('auto_advance', 'Advanced automatically'),
        ('complete', 'Completed'),
        ('edit', 'Edited'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    countdown = models.ForeignKey(
        UserCountdown, on_delete=models.CASCADE, related_name='events',
    )
    user = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='countdown_events',
    )
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    #: The counter's value right after this event.
    count_after = models.PositiveIntegerField(default=0)
    #: Seconds since the previous event on this countdown — the gap that
    #: drives the cadence analytics.
    elapsed_seconds = models.IntegerField(default=0)
    #: Seconds since the current streak began — how long this run has lasted.
    run_elapsed_seconds = models.IntegerField(default=0)
    unit = models.CharField(max_length=20, default='days')
    note = models.CharField(max_length=200, blank=True)
    occurred_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = 'countdowns_countdown_event'
        ordering = ['-occurred_at']
        indexes = [
            models.Index(fields=['countdown', '-occurred_at']),
            models.Index(fields=['user', '-occurred_at']),
            models.Index(fields=['user', 'event_type']),
        ]

    def __str__(self):
        return f'{self.countdown_id}: {self.event_type} @ {self.occurred_at}'


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
