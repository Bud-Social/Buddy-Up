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
        ('poll', 'Poll'),
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
    is_pinned = models.BooleanField(default=False)
    moderation_status = models.CharField(max_length=15, choices=MODERATION_CHOICES, default='clean')
    pinned_comment = models.ForeignKey('Comment', null=True, blank=True, on_delete=models.SET_NULL, related_name='pinned_on')
    mentioned_profiles = models.ManyToManyField('profiles.Profile', blank=True, related_name='mention_posts')
    ai_analysis = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'feed_post'
        indexes = [
            models.Index(fields=['author', '-created_at']),
            models.Index(fields=['post_type']),
            models.Index(fields=['visibility', 'moderation_status']),
            models.Index(fields=['gym_tag', '-created_at']),
        ]

class FeedPostManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(gym_tag__isnull=True)

class GymPostManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(gym_tag__isnull=False)

class FeedPost(Post):
    objects = FeedPostManager()

    class Meta:
        proxy = True

class GymPost(Post):
    objects = GymPostManager()

    class Meta:
        proxy = True


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
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='reactions', null=True, blank=True)
    comment = models.ForeignKey(Comment, on_delete=models.CASCADE, related_name='reactions', null=True, blank=True)
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='reactions')
    reaction_type = models.CharField(max_length=20)

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


class Poll(TimestampedModel):
    """A poll attached to a Post (post_type='poll')."""
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    post = models.OneToOneField(Post, on_delete=models.CASCADE, related_name='poll')
    question = models.CharField(max_length=300)
    closes_at = models.DateTimeField(null=True, blank=True)
    allow_multiple = models.BooleanField(default=False)

    class Meta:
        db_table = 'feed_poll'

    @property
    def total_votes(self):
        return self.votes.count()

    @property
    def is_closed(self):
        from django.utils import timezone
        return self.closes_at is not None and self.closes_at <= timezone.now()


class PollOption(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE, related_name='options')
    text = models.CharField(max_length=200)
    order = models.PositiveSmallIntegerField(default=0)

    class Meta:
        db_table = 'feed_poll_option'
        ordering = ['order']


class PollVote(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE, related_name='votes')
    option = models.ForeignKey(PollOption, on_delete=models.CASCADE, related_name='votes')
    voter = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='poll_votes')

    class Meta:
        db_table = 'feed_poll_vote'
        unique_together = ('poll', 'voter', 'option')


class Draft(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    author = models.ForeignKey('profiles.Profile', on_delete=models.CASCADE, related_name='drafts')
    post_type = models.CharField(max_length=20, choices=Post.POST_TYPES, default='text')
    body = models.TextField(blank=True)
    visibility = models.CharField(max_length=15, choices=Post.VISIBILITY_CHOICES, default='public')
    gym_tag = models.ForeignKey('gyms.Gym', null=True, blank=True, on_delete=models.SET_NULL, related_name='drafts')
    location_label = models.CharField(max_length=200, blank=True)
    media_urls = models.JSONField(default=list)
    tags = models.JSONField(default=list)
    poll_question = models.CharField(max_length=300, blank=True)
    poll_options = models.JSONField(default=list)
    poll_allow_multiple = models.BooleanField(default=False)
    mentioned_user_ids = models.JSONField(default=list)
    is_anonymous = models.BooleanField(default=False)

    class Meta:
        db_table = 'feed_draft'
        indexes = [
            models.Index(fields=['author', '-updated_at']),
        ]
