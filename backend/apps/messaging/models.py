from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class Conversation(TimestampedModel):
    id = models.UUIDField(primary_key=True, editable=False)
    participants = models.ManyToManyField('profiles.Profile', related_name='conversations')
    is_group = models.BooleanField(default=False)
    group_name = models.CharField(max_length=100, blank=True)
    group_gym = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='group_chats')
    last_message_text = models.CharField(max_length=200, blank=True)
    last_message_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey('profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='created_conversations')
    sub_channel = models.CharField(max_length=50, blank=True)

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
        ('workout_log', 'Workout Log'),
        ('meal_plan', 'Meal Plan'),
        ('artifact_tip', 'Artifact Tip'),
        ('accountability_ping', 'Accountability Ping'),
    ]

    id = models.UUIDField(primary_key=True, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='sent_messages')
    message_type = models.CharField(max_length=25, choices=MESSAGE_TYPES, default='text')
    body = models.TextField(blank=True)
    media_url = models.URLField(blank=True)
    reply_to = models.ForeignKey('self', null=True, blank=True, on_delete=models.SET_NULL, related_name='replies')
    metadata = models.JSONField(default=dict)
    is_read = models.BooleanField(default=False)

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
