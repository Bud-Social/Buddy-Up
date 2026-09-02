"""Backfill PostMedia rows from legacy Post.media_urls (Bud Press).

Every post with non-empty media_urls gets one PostMedia row per URL,
preserving order. media_type is inferred from the URL extension (video
extensions first, then audio, defaulting to image).
"""
from django.db import migrations

VIDEO_EXTS = ('mp4', 'mov', 'webm', 'm4v', 'mpeg', 'mkv')
AUDIO_EXTS = ('mp3', 'wav', 'ogg', 'm4a', 'aac')


def guess_media_type(url):
    ext = str(url).split('?', 1)[0].lower().rsplit('.', 1)[-1] if url else ''
    if ext in VIDEO_EXTS:
        return 'video'
    if ext in AUDIO_EXTS:
        return 'audio'
    return 'image'


def backfill_post_media(apps, schema_editor):
    Post = apps.get_model('feed', 'Post')
    PostMedia = apps.get_model('feed', 'PostMedia')
    for post in Post.objects.exclude(media_urls=[]).exclude(media_urls__isnull=True).iterator():
        urls = post.media_urls or []
        for order, url in enumerate(urls):
            if not url:
                continue
            PostMedia.objects.get_or_create(
                post=post,
                order=order,
                defaults={'media_type': guess_media_type(url), 'url': url},
            )


def unbackfill_post_media(apps, schema_editor):
    # No-op: legacy media_urls remain the source of truth on the Post row.
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0014_post_comments_disabled_sound_postmedia_and_more'),
    ]

    operations = [
        migrations.RunPython(backfill_post_media, unbackfill_post_media),
    ]
