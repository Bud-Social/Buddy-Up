from django.db import models
from common.models import TimestampedModel


class BuddyLive(TimestampedModel):
    LIVE_TYPES = [
        ('open_sweat', 'Open Sweat'),
        ('buddy_circle', 'Buddy Circle'),
        ('gym_live', 'Gym Live'),
        ('pt_session_live', 'PT Session Live'),
        ('random_drop', 'Random Drop'),
        ('practitioner_live', 'Practitioner Live'),
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

    id = models.UUIDField(primary_key=True, editable=False)
    host = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='hosted_lives')
    title = models.CharField(max_length=80)
    live_type = models.CharField(max_length=20, choices=LIVE_TYPES)
    category = models.CharField(max_length=50)
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
    co_hosts = models.ManyToManyField('profiles.Profile', blank=True, related_name='co_hosted_lives')
    scheduled_for = models.DateTimeField(null=True, blank=True)
    is_recurring = models.BooleanField(default=False)
    recurrence_rule = models.CharField(max_length=200, blank=True)
    equipment_list = models.JSONField(default=list)

    class Meta:
        db_table = 'lives_buddy_live'
        indexes = [
            models.Index(fields=['status', 'scheduled_for']),
            models.Index(fields=['live_type']),
            models.Index(fields=['host', '-created_at']),
            models.Index(fields=['gym', 'status']),
        ]
