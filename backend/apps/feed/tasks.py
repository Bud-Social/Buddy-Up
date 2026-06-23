from celery import shared_task
from django.utils import timezone
from datetime import timedelta


@shared_task
def generate_feed_cache():
    # TODO: Pre-compute feed rankings in Redis for fast retrieval
    pass


@shared_task
def moderate_content(post_id: str):
    # TODO: Run NSFW detection, profanity filter, health misinformation ML
    # For now, auto-approve all content
    from .models import Post
    Post.objects.filter(id=post_id, moderation_status='clean').update(moderation_status='clean')


@shared_task
def expire_moments():
    from .models import Post
    cutoff = timezone.now() - timedelta(hours=24)
    Post.objects.filter(
        post_type='moment',
        created_at__lt=cutoff,
        is_deleted=False,
    ).update(is_deleted=True, deleted_at=timezone.now())


@shared_task
def cleanup_moment_media():
    from .models import Post
    cutoff = timezone.now() - timedelta(days=7)
    expired = Post.objects.filter(
        post_type='moment',
        deleted_at__lt=cutoff,
    )
    for post in expired:
        # TODO: Delete from Cloudinary
        post.delete()
