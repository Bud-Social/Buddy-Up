from uuid import uuid4

from django.core.validators import MaxValueValidator
from django.db import models
from django.db.models import Q

from common.models import TimestampedModel


def are_buddies(a, b):
    """Canonical buddy check — a confirmed BuddyRelationship either way."""
    from apps.profiles.models import BuddyRelationship

    if a.pk == b.pk:
        return False
    return BuddyRelationship.objects.filter(
        (Q(from_user=a, to_user=b) | Q(from_user=b, to_user=a)),
        status='confirmed',
    ).exists()


def usable_sound_ids(profile):
    """Sound ids a profile may attach to an alarm: owned + accepted shares."""
    owned = AlarmSound.objects.filter(owner=profile).values_list('id', flat=True)
    shared = AlarmShare.objects.filter(
        recipient=profile, status='accepted',
    ).values_list('sound_id', flat=True)
    return set(owned) | set(shared)


class AlarmSound(TimestampedModel):
    SOURCE_CHOICES = [
        ('upload', 'Upload'),
        ('voice_note', 'Voice Note'),
        ('suggestion', 'Suggestion'),
    ]
    VISIBILITY_CHOICES = [
        ('private', 'Private'),
        ('buddies', 'Buddies'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    owner = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarm_sounds',
    )
    name = models.CharField(max_length=120)
    source = models.CharField(max_length=12, choices=SOURCE_CHOICES, default='upload')
    audio = models.FileField(upload_to='alarm_sounds/', blank=True, null=True)
    # External song/sound link when no file was uploaded (JSON create path).
    audio_url = models.URLField(blank=True)
    duration_ms = models.PositiveIntegerField(default=0)
    visibility = models.CharField(max_length=10, choices=VISIBILITY_CHOICES, default='private')

    class Meta:
        db_table = 'alarms_sound'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.name} ({self.owner})'


class Alarm(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    owner = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarms',
    )
    time = models.TimeField()
    # Bitmask Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64 (0 = one-shot).
    days_mask = models.PositiveSmallIntegerField(
        default=0, validators=[MaxValueValidator(127)],
    )
    label = models.CharField(max_length=80, blank=True)
    sound = models.ForeignKey(
        AlarmSound, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='alarms',
    )
    enabled = models.BooleanField(default=True)
    snooze_minutes = models.PositiveSmallIntegerField(default=5)

    class Meta:
        db_table = 'alarms_alarm'
        ordering = ['time']

    def __str__(self):
        return f'{self.time} — {self.label or "Alarm"}'


class AlarmShare(TimestampedModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    sound = models.ForeignKey(AlarmSound, on_delete=models.CASCADE, related_name='shares')
    sender = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarm_shares_sent',
    )
    recipient = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarm_shares_received',
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')

    class Meta:
        db_table = 'alarms_share'
        unique_together = ('sound', 'recipient')
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.sound} → {self.recipient} ({self.status})'


class AlarmSuggestion(TimestampedModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined'),
        ('dismissed', 'Dismissed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    sender = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarm_suggestions_sent',
    )
    recipient = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE,
        related_name='alarm_suggestions_received',
    )
    title = models.CharField(max_length=120)
    note = models.TextField(blank=True)
    url = models.URLField(blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')

    class Meta:
        db_table = 'alarms_suggestion'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.title} → {self.recipient} ({self.status})'
