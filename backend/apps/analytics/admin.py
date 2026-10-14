from django.contrib import admin
from .models import (
    ActivityRecord, WorkoutLog, BodyMetric, AnalyticsReport, AnalyticsEvent,
    DailyPlatformMetric,
)


@admin.register(ActivityRecord)
class ActivityRecordAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'activity_type', 'distance_meters', 'duration_seconds', 'started_at')
    list_filter = ('activity_type', 'source')
    search_fields = ('user__username',)


@admin.register(WorkoutLog)
class WorkoutLogAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'workout_type', 'exercise', 'duration_minutes', 'performed_at')
    list_filter = ('workout_type',)
    search_fields = ('user__username', 'exercise')


@admin.register(BodyMetric)
class BodyMetricAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'weight_kg', 'body_fat_pct', 'measured_at')
    search_fields = ('user__username',)


@admin.register(AnalyticsReport)
class AnalyticsReportAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'period', 'created_at', 'feed_post')
    list_filter = ('period',)
    search_fields = ('user__username',)


@admin.register(AnalyticsEvent)
class AnalyticsEventAdmin(admin.ModelAdmin):
    list_display = ('event_name', 'actor', 'platform', 'surface', 'object_type', 'object_id', 'received_at')
    list_filter = ('event_name', 'platform', 'surface')
    search_fields = ('object_id', 'anonymous_id', 'session_id')
    readonly_fields = [f.name for f in AnalyticsEvent._meta.fields]


@admin.register(DailyPlatformMetric)
class DailyPlatformMetricAdmin(admin.ModelAdmin):
    """Read-only: the rollup task owns this table.

    Exposed so an operator can answer "why is this number what it is" — the
    per-day value and the source_count that produced it — without shell access.
    Deliberately not editable: a hand-edited rollup silently diverges from the
    source tables and the next task run overwrites it anyway.
    """

    list_display = ('metric', 'date', 'value', 'dimension_key', 'source_count', 'computed_at')
    list_filter = ('metric',)
    date_hierarchy = 'date'
    readonly_fields = [f.name for f in DailyPlatformMetric._meta.fields]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
