from uuid import uuid4

from django.db import models
from common.models import TimestampedModel
from common.age_gating import CONTENT_RATING_CHOICES, CONTENT_RATING_DEFAULT


class BuddyLive(TimestampedModel):
    LIVE_TYPES = [
        ('open_sweat', 'Open Sweat'),
        ('buddy_circle', 'Buddy Circle'),
        ('gym_live', 'Gym Live'),
        ('pt_session_live', 'PT Session Live'),
        ('random_drop', 'Random Drop'),
        ('practitioner_live', 'Practitioner Live'),
        ('audio', 'Audio Live'),
    ]
    ACCESS_CHOICES = [
        ('public', 'Public'),
        ('buddies', 'Buddies Only'),
        ('gym_members', 'Gym Members'),
    ]
    STATUS_CHOICES = [
        ('scheduled', 'Scheduled'),
        ('live', 'Live'),
        ('ended', 'Ended'),
    ]
    RECORDING_CONSENT_CHOICES = [
        ('auto_record', 'Auto-record for replays'),
        ('opt_out', 'Opt out of auto-recording'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    host = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='hosted_lives')
    title = models.CharField(max_length=80)
    live_type = models.CharField(max_length=20, choices=LIVE_TYPES)
    category = models.CharField(max_length=50)
    content_rating = models.CharField(
        max_length=10, choices=CONTENT_RATING_CHOICES, default=CONTENT_RATING_DEFAULT,
    )
    access = models.CharField(max_length=15, choices=ACCESS_CHOICES, default='public')
    artifact_fee = models.JSONField(null=True, blank=True)
    gym = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='lives')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='scheduled')
    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    viewer_peak = models.IntegerField(default=0)
    replay_url = models.URLField(blank=True)
    replay_saved = models.BooleanField(default=False)
    agora_channel = models.CharField(max_length=100, blank=True)
    mux_asset_id = models.CharField(max_length=100, blank=True)
    mux_playback_id = models.CharField(max_length=100, blank=True)
    livekit_egress_id = models.CharField(max_length=100, blank=True)
    client_recording_session_id = models.CharField(max_length=100, blank=True)
    co_hosts = models.ManyToManyField('profiles.Profile', blank=True, related_name='co_hosted_lives')
    scheduled_for = models.DateTimeField(null=True, blank=True)
    is_recurring = models.BooleanField(default=False)
    recurrence_rule = models.CharField(max_length=200, blank=True)
    equipment_list = models.JSONField(default=list)
    recording_consent = models.CharField(
        max_length=20, choices=RECORDING_CONSENT_CHOICES, default='auto_record',
    )
    reminders_sent = models.JSONField(default=list)

    class Meta:
        db_table = 'lives_buddy_live'
        indexes = [
            models.Index(fields=['status', 'scheduled_for']),
            models.Index(fields=['live_type']),
            models.Index(fields=['host', '-created_at']),
            models.Index(fields=['gym', 'status']),
        ]


class LiveRSVP(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    live = models.ForeignKey(BuddyLive, on_delete=models.CASCADE, related_name='rsvps')
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='live_rsvps')
    fee_paid = models.JSONField(default=dict)

    class Meta:
        db_table = 'lives_rsvp'
        unique_together = ['live', 'user']


class LiveAttendee(TimestampedModel):
    ROLE_CHOICES = [
        ('host', 'Host'),
        ('co_host', 'Co-Host'),
        ('attendee', 'Attendee'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    live = models.ForeignKey(BuddyLive, on_delete=models.CASCADE, related_name='attendees')
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='live_attendances')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='attendee')
    joined_at = models.DateTimeField(auto_now_add=True)
    left_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'lives_attendee'
        verbose_name = 'Live Attendee'
        verbose_name_plural = 'Live Attendees'
        indexes = [
            models.Index(fields=['live', '-joined_at']),
            models.Index(fields=['user', '-joined_at']),
        ]
