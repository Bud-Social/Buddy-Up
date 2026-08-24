from uuid import uuid4
from django.db import models
from django.utils import timezone
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
    # Community (community group chat) extras
    is_community = models.BooleanField(default=False)
    description = models.TextField(blank=True)
    cover_url = models.URLField(blank=True)
    invite_code = models.CharField(max_length=12, blank=True, db_index=True)
    is_public = models.BooleanField(default=False)

    class Meta:
        db_table = 'messaging_conversation'
        indexes = [
            models.Index(fields=['is_group', 'last_message_at']),
            models.Index(fields=['group_gym']),
        ]


def _generate_invite_code() -> str:
    """Short, unguessable 6-character uppercase invite code for community joining."""
    import secrets
    alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    for _ in range(100):
        code = ''.join(secrets.choice(alphabet) for _ in range(6))
        if not Conversation.objects.filter(invite_code=code).exists():
            return code
    return ''.join(secrets.choice(alphabet) for _ in range(6))


class ConversationMembership(TimestampedModel):
    ROLE_CHOICES = [
        ('owner', 'Owner'),
        ('admin', 'Admin'),
        ('member', 'Member'),
    ]

    conversation = models.ForeignKey(
        Conversation, on_delete=models.CASCADE, related_name='memberships'
    )
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='conversation_memberships'
    )
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='member')

    class Meta:
        db_table = 'messaging_conversation_membership'
        unique_together = ('conversation', 'profile')

    def __str__(self):
        return f'{self.profile} @ {self.conversation} ({self.role})'


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


class CallSession(TimestampedModel):
    """A multi-party LiveKit call inside a conversation (DM, group, or community).

    One live session per conversation at a time. Any member can join an
    existing ringing/active session instead of starting a second one.
    """
    CALL_TYPES = [('audio', 'Audio'), ('video', 'Video')]
    CALL_STATUS = [
        ('ringing', 'Ringing'),
        ('active', 'Active'),
        ('ended', 'Ended'),
        ('missed', 'Missed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='call_sessions')
    initiated_by = models.ForeignKey(
        'profiles.Profile', null=True, blank=True, on_delete=models.SET_NULL, related_name='initiated_call_sessions'
    )
    call_type = models.CharField(max_length=10, choices=CALL_TYPES, default='audio')
    status = models.CharField(max_length=15, choices=CALL_STATUS, default='ringing')
    # Stable LiveKit room name shared by every participant of this session.
    room_name = models.CharField(max_length=80, blank=True, db_index=True)
    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'messaging_call_session'
        indexes = [
            models.Index(fields=['conversation', '-created_at']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f'Call {self.call_type} in {self.conversation_id} ({self.status})'

    @property
    def duration_seconds(self) -> int:
        if not self.started_at:
            return 0
        end = self.ended_at or timezone.now()
        return max(0, int((end - self.started_at).total_seconds()))


class CallParticipant(TimestampedModel):
    """Membership of a profile in a specific CallSession."""
    session = models.ForeignKey(CallSession, on_delete=models.CASCADE, related_name='participants')
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='call_participations'
    )
    joined_at = models.DateTimeField(null=True, blank=True)
    left_at = models.DateTimeField(null=True, blank=True)
    # Set when this participant declined an invitation while it was ringing.
    declined = models.BooleanField(default=False)

    class Meta:
        db_table = 'messaging_call_participant'
        unique_together = ('session', 'profile')

    def __str__(self):
        return f'{self.profile} in {self.session_id}'


class CommunityPost(TimestampedModel):
    """A post in a community's feed (announcements, updates, discussions)."""

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    conversation = models.ForeignKey(
        Conversation, on_delete=models.CASCADE, related_name='community_posts'
    )
    author = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='community_posts'
    )
    body = models.TextField(blank=True)
    media_url = models.URLField(blank=True, max_length=1000)
    media_mime = models.CharField(max_length=100, blank=True)
    is_pinned = models.BooleanField(default=False)
    # Denormalised for cheap feed sorting/filtering
    like_count = models.PositiveIntegerField(default=0)
    comment_count = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f'Post {self.id} in {self.conversation}'

    class Meta:
        db_table = 'messaging_community_post'
        ordering = ['-is_pinned', '-created_at']
        indexes = [
            models.Index(fields=['conversation', '-created_at']),
            models.Index(fields=['conversation', 'author']),
        ]


class CommunityPostLike(TimestampedModel):
    post = models.ForeignKey(CommunityPost, on_delete=models.CASCADE, related_name='likes')
    profile = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='community_post_likes'
    )

    class Meta:
        db_table = 'messaging_community_post_like'
        unique_together = ('post', 'profile')


class CommunityPostComment(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    post = models.ForeignKey(
        CommunityPost, on_delete=models.CASCADE, related_name='comments'
    )
    author = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='community_post_comments'
    )
    body = models.TextField()
    reply_to = models.ForeignKey(
        'self', null=True, blank=True, on_delete=models.CASCADE, related_name='replies'
    )

    class Meta:
        db_table = 'messaging_community_post_comment'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['post', 'created_at']),
        ]
