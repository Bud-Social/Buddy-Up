import logging

import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def moderate_image_url(
    self,
    content_type: str,
    content_id: str,
    image_url: str,
    *,
    content_rating: str = 'general',
):
    from .models import ContentFlag
    from common.age_gating import AUDIENCE_MATURE

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
        # Adult content is permitted but must live inside the mature category.
        # Inside the mature category it is recorded as an informational flag;
        # outside it, it is a policy violation (`adult_ungated`).
        is_gated = content_rating == AUDIENCE_MATURE
        ContentFlag.objects.create(
            flag_reason='adult_ungated' if not is_gated else 'nsfw',
            severity='low' if is_gated else ('high' if result['confidence'] > 0.8 else 'medium'),
            confidence=result['confidence'],
            source='ai_service',
            content_type=content_type,
            content_id=content_id,
            content_preview=image_url[:500],
            is_actioned=is_gated,
            action_taken='gated_mature' if is_gated else '',
        )
        logger.info(
            'Moderated %s %s: %s (confidence=%.2f)',
            content_type, content_id,
            'gated as mature' if is_gated else 'flagged as adult content outside mature category',
            result['confidence'],
        )


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
    from datetime import timedelta

    cutoff = timezone.now() - timedelta(days=7)
    stale = ModerationReport.objects.filter(
        status='open',
        created_at__lt=cutoff,
    )
    stale.update(status='dismissed', resolution_note='Auto-dismissed after 7 days of inactivity')


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def moderate_policy_text(
    self,
    content_type: str,
    content_id: str,
    text: str,
    *,
    author_is_practitioner: bool = False,
):
    """Enforce platform policy guardrails on user content.

    Two AI-service checks run against `text`:

    1. Health-claims / scope-of-practice check — nutrition & fitness content
       must stay in general-wellness lane. Treatment/cure/condition-managing
       claims from anyone who is not a verified practitioner are flagged.

    2. Sponsorship disclosure check — promotional/gifting content must carry a
       prominent disclosure (per influencer-advertising rules). Promotional
       content without one is flagged.

    Non-practitioners making medical-style claims are the highest-risk case and
    are always flagged regardless of the text result, as the platform requires a
    licensed professional relationship for any medical guidance.
    """
    from .models import ContentFlag

    if not text or not text.strip():
        return

    try:
        claims_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/policy/health-claims',
            data={'text': text},
            timeout=15,
        )
        claims_resp.raise_for_status()
        claims = claims_resp.json()
    except requests.RequestException as exc:
        logger.warning('Policy health-claims service unavailable: %s', exc)
        try:
            self.retry(exc=exc)
        except self.MaxRetriesExceededError:
            pass
        return

    flag = None
    if claims.get('has_medical_claim') and not author_is_practitioner:
        risk = claims.get('risk_level', 'medium')
        severity = 'high' if risk == 'high' else 'medium'
        flag = ContentFlag(
            flag_reason='medical_claim',
            severity=severity,
            confidence=claims.get('confidence', 0.7),
            source='ai_service (policy)',
            content_type=content_type,
            content_id=content_id,
            content_preview=text[:500],
            is_actioned=False,
        )

    # Sponsorship disclosure check (author-agnostic — disclosure duties apply
    # to verified creators too).
    try:
        sponsor_resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/policy/sponsorship',
            data={'text': text},
            timeout=15,
        )
        sponsor_resp.raise_for_status()
        sponsor = sponsor_resp.json()
    except requests.RequestException as exc:
        logger.warning('Policy sponsorship service unavailable: %s', exc)
        sponsor = {'is_promotional': False}

    if sponsor.get('is_promotional') and not sponsor.get('disclosure_compliant'):
        if flag:
            flag.save()
        ContentFlag.objects.create(
            flag_reason='undisclosed_sponsor',
            severity='medium',
            confidence=sponsor.get('confidence', 0.7),
            source='ai_service (policy)',
            content_type=content_type,
            content_id=content_id,
            content_preview=text[:500],
            is_actioned=False,
        )
        logger.info('Flagged %s %s for undisclosed sponsorship', content_type, content_id)
        return

    if flag:
        flag.save()
        logger.info('Flagged %s %s for medical claim (risk=%s)', content_type, content_id, claims.get('risk_level'))
