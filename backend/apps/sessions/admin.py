from django.contrib import admin
from .models import (
    TrainerProfile, Availability, BookingSession, Review,
    AsyncProgramme, ProgrammeWeek, ProgrammeEnrollment,
)


@admin.register(TrainerProfile)
class TrainerProfileAdmin(admin.ModelAdmin):
    list_display = ['profile', 'years_experience', 'average_rating', 'review_count', 'total_sessions_completed']
    search_fields = ['profile__username', 'profile__display_name']
    list_select_related = ['profile']


@admin.register(Availability)
class AvailabilityAdmin(admin.ModelAdmin):
    list_display = ['trainer', 'day_of_week', 'start_time', 'end_time', 'is_active']
    list_filter = ['day_of_week', 'is_active']


@admin.register(BookingSession)
class BookingSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'client', 'trainer', 'session_type', 'status', 'scheduled_at', 'duration_minutes']
    list_filter = ['status', 'session_type', 'created_at']
    search_fields = ['client__username', 'trainer__username']
    list_select_related = ['client', 'trainer']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ['session', 'client', 'trainer', 'rating', 'created_at']
    list_filter = ['rating']
    list_select_related = ['session', 'client', 'trainer']


@admin.register(AsyncProgramme)
class AsyncProgrammeAdmin(admin.ModelAdmin):
    list_display = ['title', 'trainer', 'duration_weeks', 'is_active', 'enrolled_count']
    list_filter = ['is_active']
    search_fields = ['title', 'trainer__username']


@admin.register(ProgrammeWeek)
class ProgrammeWeekAdmin(admin.ModelAdmin):
    list_display = ['programme', 'week_number', 'title']
    list_filter = ['programme']
    ordering = ['programme', 'week_number']


@admin.register(ProgrammeEnrollment)
class ProgrammeEnrollmentAdmin(admin.ModelAdmin):
    list_display = ['client', 'programme', 'progress_pct', 'created_at']
    list_select_related = ['client', 'programme']
