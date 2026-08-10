from django.contrib import admin
from .models import ActivityRecord, WorkoutLog, MealLog, BodyMetric, AnalyticsReport


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


@admin.register(MealLog)
class MealLogAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'meal_type', 'food_name', 'calories', 'logged_at')
    list_filter = ('meal_type', 'source')
    search_fields = ('user__username', 'food_name')


@admin.register(BodyMetric)
class BodyMetricAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'weight_kg', 'body_fat_pct', 'measured_at')
    search_fields = ('user__username',)


@admin.register(AnalyticsReport)
class AnalyticsReportAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'period', 'created_at', 'feed_post')
    list_filter = ('period',)
    search_fields = ('user__username',)
