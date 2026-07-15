import logging

import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def moderate_image_url(self, content_type: str, content_id: str, image_url: str):
    from .models import ContentFlag

    try:
        resp = requests.get(image_url, timeout=10)
        if resp.status_code != 200:
            logger.warning('Could not fetch image %s for moderation', image_url)
            return

        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/moderation/image',
            files={'file': ('image.jpg', resp.content, resp.headers.get('content-type', 'image/jpeg'))},
            timeout=30,
        )
        ai_resp.raise_for_status()
        result = ai_resp.json()
    except requests.RequestException as exc:
        logger.warning('AI moderation service unavailable: %s', exc)
        try:
            self.retry(exc=exc)
        except self.MaxRetriesExceededError:
            pass
        return

    if result.get('is_nsfw'):
        ContentFlag.objects.create(
            flag_reason='nsfw',
            severity='high' if result['confidence'] > 0.8 else 'medium',
            confidence=result['confidence'],
            source='ai_service',
            content_type=content_type,
            content_id=content_id,
            content_preview=image_url[:500],
            is_actioned=False,
        )
        logger.info('Flagged %s %s as NSFW (confidence=%.2f)', content_type, content_id, result['confidence'])


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def moderate_text_content(self, content_type: str, content_id: str, text: str):
    from .models import ContentFlag

    try:
        ai_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/moderation/text',
            data={'text': text},
            timeout=15,
        )
        ai_resp.raise_for_status()
        result = ai_resp.json()
    except requests.RequestException as exc:
        logger.warning('AI moderation service unavailable for text: %s', exc)
        try:
            self.retry(exc=exc)
        except self.MaxRetriesExceededError:
            pass
        return

    if result.get('is_toxic'):
        severity = 'critical' if result['toxicity_score'] > 0.9 else 'high' if result['toxicity_score'] > 0.7 else 'medium'
        ContentFlag.objects.create(
            flag_reason='toxic',
            severity=severity,
            confidence=result['toxicity_score'],
            source='ai_service',
            content_type=content_type,
            content_id=content_id,
            content_preview=text[:500],
            is_actioned=False,
        )
        logger.info('Flagged %s %s as toxic (score=%.2f)', content_type, content_id, result['toxicity_score'])


@shared_task
def auto_flag_expired_reports():
    from .models import ModerationReport
    from django.utils import timezone
    from datetime import timedelta

    cutoff = timezone.now() - timedelta(days=7)
    stale = ModerationReport.objects.filter(
        status='open',
        created_at__lt=cutoff,
    )
    stale.update(status='dismissed', resolution_note='Auto-dismissed after 7 days of inactivity')
