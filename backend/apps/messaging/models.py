from uuid import uuid4
from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class Conversation(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    participants = models.ManyToManyField('profiles.Profile', related_name='conversations')
    is_group = models.BooleanField(default=False)
    group_name = models.CharField(max_length=100, blank=True)
    group_avatar_url = models.URLField(blank=True)
    group_gym = models.ForeignKey(
        'gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='group_chats'
    )
    last_message_text = models.CharField(max_length=200, blank=True)
    last_message_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(
        'profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='created_conversations'
    )
    sub_channel = models.CharField(max_length=50, blank=True)
    # A flag set while a call is active in this DM
    call_in_progress = models.BooleanField(default=False)

    class Meta:
        db_table = 'messaging_conversation'
        indexes = [
            models.Index(fields=['is_group', 'last_message_at']),
            models.Index(fields=['group_gym']),
        ]


class Message(TimestampedModel, SoftDeleteModel):
    MESSAGE_TYPES = [
        ('text', 'Text'),
        ('photo', 'Photo'),
        ('video', 'Video'),
        ('voice', 'Voice Note'),
        ('document', 'Document'),
        ('location', 'Location'),
        ('poll', 'Poll'),
        ('event', 'Event'),
        ('workout_log', 'Workout Log'),
        ('meal_plan', 'Meal Plan'),
        ('artifact_tip', 'Artifact Tip'),
        ('accountability_ping', 'Accountability Ping'),
        ('call_log', 'Call Log'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='sent_messages')
    message_type = models.CharField(max_length=25, choices=MESSAGE_TYPES, default='text')
    body = models.TextField(blank=True)
    media_url = models.URLField(blank=True, max_length=1000)
    media_mime = models.CharField(max_length=100, blank=True)  # e.g. image/jpeg
    file_name = models.CharField(max_length=255, blank=True)
    reply_to = models.ForeignKey('self', null=True, blank=True, on_delete=models.SET_NULL, related_name='replies')
    metadata = models.JSONField(default=dict)
    is_read = models.BooleanField(default=False)
    # Per-user soft delete: list of user_ids who have deleted this message for themselves
    deleted_for = models.JSONField(default=list)

    class Meta:
        db_table = 'messaging_message'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['conversation', '-created_at']),
            models.Index(fields=['sender']),
        ]


class MessageReaction(TimestampedModel):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='message_reactions')
    emoji = models.CharField(max_length=10)

    class Meta:
        db_table = 'messaging_message_reaction'
        unique_together = ('message', 'user', 'emoji')


class CallLog(TimestampedModel):
    CALL_TYPES = [('audio', 'Audio'), ('video', 'Video')]
    CALL_STATUS = [
        ('initiated', 'Initiated'),
        ('ringing', 'Ringing'),
        ('answered', 'Answered'),
        ('declined', 'Declined'),
        ('missed', 'Missed'),
        ('ended', 'Ended'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='call_logs')
    caller = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='calls_made'
    )
    callee = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='calls_received'
    )
    call_type = models.CharField(max_length=10, choices=CALL_TYPES, default='audio')
    status = models.CharField(max_length=15, choices=CALL_STATUS, default='initiated')
    duration_seconds = models.IntegerField(default=0)
    ended_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'messaging_call_log'
        indexes = [
            models.Index(fields=['conversation', '-created_at']),
            models.Index(fields=['caller']),
            models.Index(fields=['callee']),
        ]
