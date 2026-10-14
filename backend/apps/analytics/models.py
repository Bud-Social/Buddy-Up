from uuid import uuid4

from django.db import models
from django.utils import timezone
from common.models import TimestampedModel

# Single source of truth for the workout taxonomy. Clients read this from
# GET /api/v1/analytics/workout-types/ instead of hardcoding type/category
# lists in every app.
#
# categories -> which muscle-group / focus categories are valid for the type.
# fields     -> measured fields the type exposes. Most are real model columns;
#               the ones that are not (rounds/style/focus/sport) are folded
#               into the provenance JSONField by the serializer.
# measured   -> True when the type is tracked with objective metrics
#               (reps/weight/distance/calories) rather than described.
WORKOUT_TYPE_SPECS = {
    'strength': {
        'label': 'Strength',
        'categories': ['upper', 'lower', 'push', 'pull', 'legs', 'arms', 'core', 'full'],
        'fields': ['sets', 'reps', 'weight_kg'],
        'measured': True,
    },
    'hiit': {
        'label': 'HIIT',
        'categories': ['full', 'upper', 'lower', 'core', 'cardio'],
        'fields': ['rounds'],
        'measured': True,
    },
    'cardio': {
        'label': 'Cardio',
        'categories': [],
        'fields': ['distance_meters', 'calories_burned'],
        'measured': True,
    },
    'running': {
        'label': 'Running',
        'categories': [],
        'fields': ['distance_meters', 'calories_burned'],
        'measured': True,
    },
    'walking': {
        'label': 'Walking',
        'categories': [],
        'fields': ['distance_meters', 'calories_burned'],
        'measured': True,
    },
    'cycling': {
        'label': 'Cycling',
        'categories': [],
        'fields': ['distance_meters', 'calories_burned'],
        'measured': True,
    },
    'swimming': {
        'label': 'Swimming',
        'categories': [],
        'fields': ['distance_meters', 'calories_burned'],
        'measured': True,
    },
    'climbing': {
        'label': 'Climbing',
        'categories': [],
        'fields': [],
        'measured': False,
    },
    'rowing': {
        'label': 'Rowing',
        'categories': [],
        'fields': [],
        'measured': False,
    },
    'dance': {
        'label': 'Dance',
        'categories': [],
        'fields': [],
        'measured': False,
    },
    'yoga': {
        'label': 'Yoga',
        'categories': ['flexibility', 'mobility', 'balance', 'strength', 'mindfulness'],
        'fields': ['style'],
        'measured': False,
    },
    'pilates': {
        'label': 'Pilates',
        'categories': ['core', 'posture', 'flexibility', 'mobility', 'full'],
        'fields': ['style'],
        'measured': False,
    },
    'mobility': {
        'label': 'Mobility',
        'categories': ['hips', 'shoulders', 'spine', 'ankles', 'full'],
        'fields': ['focus'],
        'measured': False,
    },
    'sport': {
        'label': 'Sport',
        'categories': [
            'football', 'basketball', 'tennis', 'cricket', 'rugby',
            'netball', 'volleyball', 'other',
        ],
        'fields': ['sport'],
        'measured': False,
    },
    'boxing': {
        'label': 'Boxing',
        'categories': [],
        'fields': ['style'],
        'measured': False,
    },
    'martial_arts': {
        'label': 'Martial Arts',
        'categories': [],
        'fields': ['style'],
        'measured': False,
    },
    'other': {
        'label': 'Other',
        'categories': [],
        'fields': [],
        'measured': False,
    },
}


def category_label(key):
    """Human label for a category key ('flexibility' -> 'Flexibility')."""
    return key.replace('_', ' ').title()


def all_category_keys():
    """Sorted union of every category declared across all workout types."""
    return sorted({c for spec in WORKOUT_TYPE_SPECS.values() for c in spec['categories']})


class ActivityRecord(TimestampedModel):
    """A walking/running/hiking session with GPS route tracking."""

    ACTIVITY_TYPES = [
        ('walk', 'Walking'),
        ('run', 'Running'),
        ('hike', 'Hiking'),
        ('cycle', 'Cycling'),
    ]
    SOURCE_CHOICES = [
        ('manual', 'Manual'),
        ('gps', 'GPS'),
        ('import', 'Imported'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='activity_records')
    activity_type = models.CharField(max_length=10, choices=ACTIVITY_TYPES, default='run')
    source = models.CharField(max_length=10, choices=SOURCE_CHOICES, default='gps')
    source_event_id = models.CharField(max_length=120, null=True, blank=True)
    provenance = models.JSONField(default=dict, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    duration_seconds = models.IntegerField(default=0)
    distance_meters = models.FloatField(default=0.0)
    avg_pace = models.FloatField(null=True, blank=True, help_text='Seconds per kilometre')
    avg_speed_kmh = models.FloatField(null=True, blank=True)
    calories_burned = models.FloatField(null=True, blank=True)
    steps = models.IntegerField(null=True, blank=True)
    elevation_gain_m = models.FloatField(null=True, blank=True)
    route = models.JSONField(default=list, blank=True, help_text='List of [lat, lng, timestamp] trackpoints')
    notes = models.TextField(blank=True)
    is_paused = models.BooleanField(default=False)
    paused_at = models.DateTimeField(null=True, blank=True)
    total_pause_seconds = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'analytics_activity_record'
        ordering = ['-started_at', '-created_at']
        indexes = [
            models.Index(fields=['user', '-started_at']),
            models.Index(fields=['user', 'activity_type']),
        ]
        constraints = [models.UniqueConstraint(fields=['user', 'source_event_id'], name='analytics_activity_source_event_unique')]

    def __str__(self):
        return f'{self.get_activity_type_display()} {self.distance_meters / 1000:.2f}km'


class WorkoutLog(TimestampedModel):
    """A structured workout entry (strength/cardio/etc.)."""

    WORKOUT_TYPES = [
        (key, spec['label']) for key, spec in WORKOUT_TYPE_SPECS.items()
    ]
    CATEGORY_CHOICES = [
        (key, category_label(key)) for key in all_category_keys()
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='workout_logs')
    source_event_id = models.CharField(max_length=120, null=True, blank=True)
    provenance = models.JSONField(default=dict, blank=True)
    workout_type = models.CharField(max_length=20, choices=WORKOUT_TYPES, default='strength')
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='', blank=True)
    exercise = models.CharField(max_length=120, blank=True)
    sets = models.IntegerField(null=True, blank=True)
    reps = models.IntegerField(null=True, blank=True)
    weight_kg = models.FloatField(null=True, blank=True)
    duration_minutes = models.IntegerField(default=0)
    calories_burned = models.FloatField(null=True, blank=True)
    distance_meters = models.FloatField(null=True, blank=True)
    performed_at = models.DateTimeField(null=True, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'analytics_workout_log'
        ordering = ['-performed_at', '-created_at']
        indexes = [
            models.Index(fields=['user', '-performed_at']),
            models.Index(fields=['user', 'workout_type']),
        ]
        constraints = [models.UniqueConstraint(fields=['user', 'source_event_id'], name='analytics_workout_source_event_unique')]

    def __str__(self):
        return f'{self.get_workout_type_display()} {self.exercise}'


class BodyMetric(TimestampedModel):
    """A weight/body-composition check-in with optional body + scale photos."""

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='body_metrics')
    weight_kg = models.FloatField()
    body_fat_pct = models.FloatField(null=True, blank=True)
    photo_url = models.URLField(blank=True)
    scale_photo_url = models.URLField(blank=True, help_text='Photo of the digital scale display showing the weight')
    notes = models.TextField(blank=True)
    measured_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'analytics_body_metric'
        ordering = ['-measured_at', '-created_at']
        indexes = [
            models.Index(fields=['user', '-measured_at']),
        ]

    def __str__(self):
        return f'{self.weight_kg}kg @ {self.measured_at}'


class AnalyticsReport(TimestampedModel):
    """A generated comprehensive analytics report (downloadable + shareable)."""

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='analytics_reports')
    period = models.CharField(max_length=10, default='all')
    period_start = models.DateField(null=True, blank=True)
    period_end = models.DateField(null=True, blank=True)
    data = models.JSONField(default=dict)
    image_url = models.URLField(blank=True)
    feed_post = models.OneToOneField(
        'feed.Post', null=True, blank=True, on_delete=models.SET_NULL,
        related_name='analytics_report',
    )

    class Meta:
        db_table = 'analytics_report'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
        ]

    def __str__(self):
        return f'Report {self.period} @ {self.created_at:%Y-%m-%d}'


class DailyPlatformMetric(TimestampedModel):
    """One row per (metric, day) — the pre-aggregated platform counters.

    Why this exists
    ---------------
    Every "how many posts were there last Tuesday" question was answered by a
    ``TruncDate(created_at)`` aggregate over the live table. That is a sequential
    scan of every row ever written, per request, on a table with no index on
    ``created_at`` (the ``accounts``/``marketplace``/``profiles`` models this app
    reads are owned elsewhere, so this app cannot add the index itself). The
    answer was correct and increasingly expensive.

    Why EAV and not one wide row per day
    ------------------------------------
    A single ``DailyPlatformRollup(date unique, posts_new, orders_gross, ...)``
    row is the faster read, and it was the first design. It was rejected because
    the metric catalogue is expected to grow: the registry lives in code
    (:mod:`apps.analytics.platform_metrics`), the units are heterogeneous
    (counts and money in one table), and a wide table turns every new metric into
    a migration plus a backfill of every historical day. Here, adding
    ``orders.gross_kes`` is one dict entry and one night of backfill — no schema
    change, no data rewrite.

    The costs are accepted knowingly: ``value`` is a ``Decimal`` so integer
    counts arrive as ``Decimal('12.000000')`` (the API layer normalises to
    ``int``/``float``), and there is no per-metric column constraint. The row
    count is small — ``metrics x days``, roughly 16 x 365 = ~5.8k rows/year.

    ``dimensions`` / ``dimension_key``
    ----------------------------------
    Base rows carry ``dimensions = {}`` and ``dimension_key = ''`` — the
    "unbroken" series every chart reads. ``dimension_key`` is a stable hash of
    ``dimensions``, and the uniqueness constraint is on
    ``(metric, date, dimension_key)``, so a future per-dimension rollup (wallet
    transactions split by ``direction``, orders split by ``payment_status``) is
    additive: the same table and index serve it, no migration.

    Idempotency
    -----------
    The writer is ``update_or_create`` on that constraint keyed by the *whole*
    day, never an increment. Re-running a day recomputes it from the source
    tables and overwrites the row, so a re-run, a late-arriving row and a
    corrected backfill all converge on the same numbers instead of double
    counting. See :mod:`apps.analytics.tasks`.
    """

    id = models.BigAutoField(primary_key=True)
    metric = models.CharField(max_length=64)
    date = models.DateField()
    value = models.DecimalField(max_digits=20, decimal_places=6, default=0)
    # Rows scanned to produce the value. Diagnostics only — it makes "why is
    # this number lower than the chart" answerable from the table itself.
    source_count = models.PositiveIntegerField(default=0)
    dimensions = models.JSONField(default=dict, blank=True)
    dimension_key = models.CharField(max_length=64, blank=True, default='')
    computed_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = 'analytics_daily_platform_metric'
        ordering = ['date', 'metric']
        constraints = [
            models.UniqueConstraint(
                fields=['metric', 'date', 'dimension_key'],
                name='analytics_daily_metric_unique',
            ),
        ]
        indexes = [
            # The only read shape the timeseries endpoint issues.
            models.Index(fields=['metric', 'date'], name='analytics_daily_metric_idx'),
        ]

    def __str__(self):
        return f'{self.metric} {self.date} = {self.value}'


class AnalyticsEvent(TimestampedModel):
    """Durable behavioral event for algorithm refinement.

    Privacy contract: never store message bodies, raw search text, GPS
    coordinates, health values, tokens or email addresses here — behavioral
    metadata only (names, ids, ranks, durations, viewport ratios).
    """

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    event_name = models.CharField(max_length=64, db_index=True)
    event_version = models.PositiveSmallIntegerField(default=1)
    occurred_at = models.DateTimeField(null=True, blank=True)
    received_at = models.DateTimeField(auto_now_add=True)
    actor = models.ForeignKey(
        'profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL,
        related_name='analytics_events',
    )
    anonymous_id = models.CharField(max_length=128, blank=True, db_index=True)
    session_id = models.CharField(max_length=64, blank=True)
    platform = models.CharField(max_length=16, blank=True)
    surface = models.CharField(max_length=32, blank=True)
    object_type = models.CharField(max_length=32, blank=True)
    object_id = models.CharField(max_length=64, blank=True, db_index=True)
    properties = models.JSONField(default=dict, blank=True)
    consent = models.JSONField(default=dict, blank=True)
    schema_version = models.PositiveSmallIntegerField(default=1)

    class Meta:
        db_table = 'analytics_event'
        ordering = ['-received_at']
        indexes = [
            models.Index(fields=['event_name', '-received_at']),
            models.Index(fields=['actor', '-received_at']),
        ]

    def __str__(self):
        return f'{self.event_name} @ {self.received_at:%Y-%m-%d %H:%M}'
