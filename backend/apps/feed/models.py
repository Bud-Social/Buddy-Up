from uuid import uuid4

from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class Post(TimestampedModel, SoftDeleteModel):
    POST_TYPES = [
        ('text', 'Text'),
        ('photo', 'Photo'),
        ('short_video', 'Short Video (BuddyClip)'),
        ('long_video', 'Long Video (BuddySession)'),
        ('workout_log', 'Workout Log'),
        ('meal', 'Meal'),
        ('progress', 'Progress'),
        ('moment', 'Moment (Story)'),
    ]
    VISIBILITY_CHOICES = [
        ('public', 'Public'),
        ('buddies', 'Buddies Only'),
        ('gym_members', 'Gym Members'),
        ('private', 'Private'),
    ]
    MODERATION_CHOICES = [
        ('clean', 'Clean'),
        ('flagged', 'Flagged'),
        ('removed', 'Removed'),
        ('reviewed', 'Reviewed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='posts')
    post_type = models.CharField(max_length=20, choices=POST_TYPES)
    body = models.TextField(blank=True)
    is_anonymous = models.BooleanField(default=False)
    gym_tag = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='tagged_posts')
    visibility = models.CharField(max_length=15, choices=VISIBILITY_CHOICES, default='public')
    is_repost = models.BooleanField(default=False)
    original_post = models.ForeignKey('self', null=True, blank=True, on_delete=models.SET_NULL, related_name='reposts')
    quote_body = models.TextField(blank=True)
    location_label = models.CharField(max_length=200, blank=True)
    workout_log_data = models.JSONField(null=True, blank=True)
    meal_data = models.JSONField(null=True, blank=True)
    progress_data = models.JSONField(null=True, blank=True)
    media_urls = models.JSONField(default=list)
    tags = models.JSONField(default=list)
    view_count = models.IntegerField(default=0)
    moderation_status = models.CharField(max_length=15, choices=MODERATION_CHOICES, default='clean')
    pinned_comment = models.ForeignKey('Comment', null=True, blank=True, on_delete=models.SET_NULL, related_name='pinned_on')

    class Meta:
        db_table = 'feed_post'
        indexes = [
            models.Index(fields=['author', '-created_at']),
            models.Index(fields=['post_type']),
            models.Index(fields=['visibility', 'moderation_status']),
            models.Index(fields=['gym_tag', '-created_at']),
        ]


class Comment(TimestampedModel):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='comments')
    body = models.TextField()
    is_anonymous = models.BooleanField(default=False)
    parent = models.ForeignKey('self', null=True, blank=True, on_delete=models.CASCADE, related_name='replies')

    class Meta:
        db_table = 'feed_comment'
        indexes = [
            models.Index(fields=['post', '-created_at']),
        ]


class Reaction(TimestampedModel):
    REACTION_CHOICES = [
        ('pump', 'Pump 💪'),
        ('fire', 'Fire 🔥'),
        ('respect', 'Respect 🤝'),
        ('grind', 'Grind 😤'),
        ('lets_go', "Let's Go 🏋️"),
        ('haha', 'Haha 😂'),
        ('too_hard', 'Too Hard 💀'),
    ]

    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='reactions', null=True, blank=True)
    comment = models.ForeignKey(Comment, on_delete=models.CASCADE, related_name='reactions', null=True, blank=True)
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='reactions')
    reaction_type = models.CharField(max_length=15, choices=REACTION_CHOICES)

    class Meta:
        db_table = 'feed_reaction'
        constraints = [
            models.UniqueConstraint(fields=['post', 'author', 'reaction_type'], name='unique_post_reaction'),
            models.UniqueConstraint(fields=['comment', 'author', 'reaction_type'], name='unique_comment_reaction'),
        ]


class Save(TimestampedModel):
    user = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='saves')
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='saves')
    collection = models.CharField(max_length=100, blank=True)

    class Meta:
        db_table = 'feed_save'
        unique_together = ('user', 'post')
