from django.db import models
from common.models import TimestampedModel, SoftDeleteModel


class Community(TimestampedModel, SoftDeleteModel):
    """A community — a topical hub with its own feed of posts."""

    id = models.UUIDField(primary_key=True, default=models.UUIDField.default, editable=False)
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    description_short = models.CharField(max_length=200, blank=True)
    cover_url = models.URLField(blank=True)
    avatar_url = models.URLField(blank=True)
    creator = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='communities_created'
    )
    members = models.ManyToManyField(
        'profiles.Profile', related_name='communities_joined', blank=True
    )
    member_count = models.PositiveIntegerField(default=1)
    is_private = models.BooleanField(default=False)
    is_nsfw = models.BooleanField(default=False)
    category = models.CharField(max_length=50, blank=True)
    tags = models.JSONField(default=list, blank=True)
    post_count = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'communities_community'
        indexes = [
            models.Index(fields=['slug']),
            models.Index(fields=['category']),
            models.Index(fields=['-member_count']),
            models.Index(fields=['-post_count']),
        ]

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = self.name.lower().replace(' ', '-')
        super().save(*args, **kwargs)


class CommunityPost(TimestampedModel, SoftDeleteModel):
    """Links a Post to a Community so posts can be filtered by community."""

    id = models.UUIDField(primary_key=True, default=models.UUIDField.default, editable=False)
    community = models.ForeignKey(
        Community, on_delete=models.CASCADE, related_name='community_posts'
    )
    post = models.ForeignKey(
        'feed.Post', on_delete=models.CASCADE, related_name='community_links'
    )
    added_by = models.ForeignKey(
        'profiles.Profile', on_delete=models.CASCADE, related_name='community_post_links'
    )

    class Meta:
        db_table = 'communities_community_post'
        unique_together = ('community', 'post')
        indexes = [
            models.Index(fields=['community', '-created_at']),
            models.Index(fields=['post']),
        ]

    def __str__(self):
        return f'{self.community.name} / {self.post_id}'
