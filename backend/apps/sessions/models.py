from uuid import uuid4

from django.db import models
from common.models import TimestampedModel


class TrainerProfile(TimestampedModel):
    profile = models.OneToOneField('profiles.Profile', on_delete=models.CASCADE, related_name='trainer_profile')
    specialties = models.JSONField(default=list)
    certifications = models.JSONField(default=list)
    years_experience = models.IntegerField(default=0)
    languages = models.JSONField(default=list)
    session_types = models.JSONField(default=list)
    pricing = models.JSONField(default=dict)
    average_rating = models.FloatField(default=0.0)
    review_count = models.IntegerField(default=0)
    total_sessions_completed = models.IntegerField(default=0)

    class Meta:
        db_table = 'sessions_trainer_profile'


class Availability(TimestampedModel):
    trainer = models.ForeignKey(TrainerProfile, on_delete=models.CASCADE, related_name='availability')
    day_of_week = models.IntegerField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    buffer_minutes = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'sessions_availability'
        unique_together = ('trainer', 'day_of_week', 'start_time')


class BookingSession(TimestampedModel):
    SESSION_TYPES = [
        ('1on1_live', '1:1 Live'),
        ('group_live', 'Group Live'),
        ('async', 'Async Programme'),
        ('nutrition', 'Nutrition Consultation'),
        ('in_person', 'In-Person'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled_by_client', 'Cancelled by Client'),
        ('cancelled_by_trainer', 'Cancelled by Trainer'),
        ('disputed', 'Disputed'),
        ('no_show', 'No Show'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    client = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='bookings_as_client')
    trainer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='bookings_as_trainer')
    session_type = models.CharField(max_length=20, choices=SESSION_TYPES)
    status = models.CharField(max_length=25, choices=STATUS_CHOICES, default='pending')
    scheduled_at = models.DateTimeField(null=True, blank=True)
    duration_minutes = models.IntegerField(default=60)
    artifact_fee = models.JSONField(default=dict)
    notes = models.TextField(blank=True, max_length=300)
    escrow_tx_id = models.CharField(max_length=100, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    cancel_reason = models.TextField(blank=True)
    completion_evidence = models.JSONField(default=dict)
    completion_confirmed_by_client = models.BooleanField(default=False)
    completed_by = models.ForeignKey('profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='completed_bookings')
    
    # Recurrence support
    parent_series = models.ForeignKey('self', null=True, blank=True, on_delete=models.CASCADE, related_name='recurring_sessions')
    recurrence_pattern = models.CharField(max_length=20, choices=[('daily', 'Daily'), ('weekly', 'Weekly'), ('monthly', 'Monthly')], blank=True, null=True)
    recurring_charge_status = models.CharField(max_length=20, default='not_applicable')

    class Meta:
        db_table = 'sessions_booking'
        indexes = [
            models.Index(fields=['client', 'status']),
            models.Index(fields=['trainer', 'status']),
            models.Index(fields=['scheduled_at']),
        ]


class Review(TimestampedModel):
    session = models.OneToOneField(BookingSession, on_delete=models.CASCADE, related_name='review')
    client = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='reviews_given')
    trainer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='reviews_received')
    rating = models.IntegerField()
    body = models.TextField(blank=True, max_length=500)

    class Meta:
        db_table = 'sessions_review'
        unique_together = ('session', 'client')
        indexes = [models.Index(fields=['trainer'])]


class AsyncProgramme(TimestampedModel):
    trainer = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='programmes')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    duration_weeks = models.IntegerField()
    price_artifacts = models.JSONField(default=dict)
    is_active = models.BooleanField(default=True)
    enrolled_count = models.IntegerField(default=0)

    class Meta:
        db_table = 'sessions_programme'


class ProgrammeWeek(TimestampedModel):
    programme = models.ForeignKey(AsyncProgramme, on_delete=models.CASCADE, related_name='weeks')
    week_number = models.IntegerField()
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    video_url = models.URLField(blank=True)
    pdf_url = models.URLField(blank=True)
    exercises = models.JSONField(default=list)

    class Meta:
        db_table = 'sessions_programme_week'
        unique_together = ('programme', 'week_number')
        ordering = ['week_number']


class ProgrammeEnrollment(TimestampedModel):
    client = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='enrollments')
    programme = models.ForeignKey(AsyncProgramme, on_delete=models.CASCADE, related_name='enrollments')
    completed_weeks = models.JSONField(default=list)
    progress_pct = models.IntegerField(default=0)

    class Meta:
        db_table = 'sessions_enrollment'
        unique_together = ('client', 'programme')
