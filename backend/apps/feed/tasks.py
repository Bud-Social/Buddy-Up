import logging

import math
import requests
import redis
from celery import shared_task
from django.conf import settings
from django.db.models import Count, OuterRef, Subquery
from django.utils import timezone
from datetime import timedelta

from apps.ai.audit import audit_ai_call

logger = logging.getLogger(__name__)


@shared_task
def generate_feed_cache():
    from .models import Post, Reaction, Comment, Save

    now = timezone.now()
    cutoff = now - timedelta(days=7)
    half_life_hours = 24.0
    weight_reaction = 3.0
    weight_comment = 2.0
    weight_save = 4.0
    weight_repost = 5.0
    recency_base = 10.0

    reaction_count = Reaction.objects.filter(
        post=OuterRef('pk'),
    ).values('post').annotate(count=Count('pk')).values('count')

    posts = Post.objects.filter(
        created_at__gte=cutoff,
        is_deleted=False,
        moderation_status='clean',
        visibility='public',
    ).annotate(
        reaction_score=Subquery(reaction_count, output_field=Count('pk')),
    ).only('pk', 'created_at', 'is_repost')

    client = redis.Redis.from_url(settings.REDIS_URL)
    pipeline = client.pipeline()
    pipeline.delete('feed:ranked')

    for post in posts:
        hours_ago = max((now - post.created_at).total_seconds() / 3600, 0.001)
        recency = recency_base * math.exp(-hours_ago / half_life_hours)

        rcount = post.reaction_score or 0
        ccount = Comment.objects.filter(post=post).count()
        scount = Save.objects.filter(post=post).count()
        repost_bonus = weight_repost if post.is_repost else 0.0

        score = (
            rcount * weight_reaction
            + ccount * weight_comment
            + scount * weight_save
            + repost_bonus
            + recency
        )
        pipeline.zadd('feed:ranked', {str(post.pk): score})

    pipeline.expire('feed:ranked', 900)
    pipeline.execute()
    client.close()


@shared_task(bind=True, max_retries=2, default_retry_delay=30)
def moderate_content(self, post_id: str):
    from .models import Post
    try:
        post = Post.objects.get(id=post_id)
    except Post.DoesNotExist:
        return

    if post.moderation_status != 'clean':
        return

    analysis = dict(post.ai_analysis or {})
    is_flagged = False
    is_gated_mature = post.content_rating == 'mature'

    # Text moderation — persist positive results so the UI can surface them.
    if post.body and post.body.strip():
        try:
            ai_resp = requests.post(
                f'{settings.AI_SERVICE_URL}/api/v1/moderation/text',
                data={'text': post.body},
                timeout=20,
            )
            if ai_resp.status_code == 200:
                result = ai_resp.json()
                audit_ai_call(
                    'text_moderation',
                    input_data={'post_id': str(post.id), 'text_preview': post.body[:200]},
                    output_data=result,
                )
                if result.get('is_toxic'):
                    post.moderation_status = 'flagged'
                    is_flagged = True
                else:
                    analysis['text'] = {
                        'toxicity_score': result.get('toxicity_score', 0.0),
                        'label': result.get('label', 'not_toxic'),
                        'method': result.get('method', 'model'),
                    }
            else:
                logger.warning('AI text moderation returned %s for %s', ai_resp.status_code, post.id)
        except requests.RequestException as exc:
            logger.warning('AI text moderation call failed for %s: %s', post.id, exc)
            audit_ai_call('text_moderation', input_data={'post_id': str(post.id)}, error_message=str(exc))

    # Policy guardrails: health-claim scope-of-practice + sponsorship disclosure.
    if post.body and post.body.strip():
        try:
            from apps.moderation.tasks import moderate_policy_text
            author_is_practitioner = post.author.verification_status == 'practitioner'
            moderate_policy_text.delay(
                'feed.post',
                post_id,
                post.body,
                author_is_practitioner=author_is_practitioner,
            )
        except Exception as exc:  # noqa: BLE001
            logger.warning('Policy moderation dispatch failed for %s: %s', post.id, exc)


    image_results = []
    for url in post.media_urls or []:
        try:
            resp = requests.get(url, timeout=10)
            if resp.status_code != 200 or not resp.headers.get('content-type', '').startswith('image/'):
                continue

            ai_resp = requests.post(
                f'{settings.AI_SERVICE_URL}/api/v1/moderation/image',
                files={'file': ('image.jpg', resp.content, resp.headers['content-type'])},
                timeout=30,
            )
            if ai_resp.status_code == 200:
                result = ai_resp.json()
                audit_ai_call(
                    'image_moderation',
                    input_data={'url': url},
                    output_data=result,
                )
                if result.get('is_nsfw'):
                    if is_gated_mature:
                        analysis['images'] = analysis.get('images', []) + [{
                            'url': url,
                            'is_nsfw': True,
                            'confidence': result.get('confidence', 0.0),
                            'labels': result.get('labels', ['nsfw']),
                            'method': result.get('method', 'model'),
                            'gated': True,
                        }]
                    else:
                        post.moderation_status = 'flagged'
                        is_flagged = True
                    break
                image_results.append({
                    'url': url,
                    'is_nsfw': False,
                    'confidence': result.get('confidence', 0.0),
                    'labels': result.get('labels', ['clean']),
                    'method': result.get('method', 'model'),
                })
            else:
                logger.warning('AI moderation returned %s for %s', ai_resp.status_code, url)

        except requests.RequestException as exc:
            logger.warning('AI moderation call failed for %s: %s', url, exc)
            audit_ai_call('image_moderation', input_data={'url': url}, error_message=str(exc))
            try:
                self.retry(exc=exc)
            except self.MaxRetriesExceededError:
                continue

    if is_flagged:
        post.save(update_fields=['moderation_status'])
        from apps.moderation.models import ContentFlag
        ContentFlag.objects.create(
            flag_reason='adult_ungated',
            severity='medium',
            confidence=0.0,
            source='ai_service (feed)',
            content_type='feed.post',
            content_id=post_id,
            content_preview=(post.media_urls or [''])[0][:500],
            is_actioned=False,
        )

        from apps.notifications.models import Notification
        Notification.objects.create(
            recipient=post.author,
            notification_type='post_reaction',
            title='Content flagged',
            body='Your post has been flagged for review. It may contain sensitive content.',
            metadata={'post_id': str(post.id)},
        )
    elif is_gated_mature and (post.media_urls or []):
        # Mature posts are allowed but remain behind the age gate.
        from apps.moderation.models import ContentFlag
        ContentFlag.objects.create(
            flag_reason='nsfw',
            severity='low',
            confidence=0.0,
            source='ai_service (feed)',
            content_type='feed.post',
            content_id=post_id,
            content_preview=(post.media_urls or [''])[0][:500],
            is_actioned=True,
            action_taken='gated_mature',
        )
        post.save(update_fields=['ai_analysis'])
    else:
        if image_results:
            analysis['images'] = image_results
        post.ai_analysis = analysis
        post.save(update_fields=['ai_analysis'])


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
def send_mention_notifications(post_id: str, author_profile_id: str):
    """Send in-app notifications to all @-mentioned users in a post."""
    try:
        from .models import Post
        from apps.notifications.models import Notification

        post = Post.objects.select_related('author').get(id=post_id)
        author = post.author
        mentioned = post.mentioned_profiles.exclude(user_id=author_profile_id)

        for profile in mentioned:
            Notification.objects.create(
                recipient=profile,
                notification_type='post_reaction',  # reuse closest type; extend later
                title=f'{author.display_name} mentioned you in a post',
                body=post.body[:200],
                metadata={'post_id': str(post.id), 'author_username': author.username},
            )
    except Exception:  # noqa: BLE001
        pass


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
