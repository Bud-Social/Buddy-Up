import logging

import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone
from apps.ai.client import ai_get, ai_post

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
        resp = ai_get(image_url, timeout=10)
        if resp.status_code != 200:
            logger.warning('Could not fetch image %s for moderation', image_url)
            return

        ai_resp = ai_post(
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
        ai_resp = ai_post(
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
            # The model's own account of the decision. Stored, not recomputed:
            # a reviewer must see the reasoning that applied *at flag time*, and
            # the checkpoint may be retrained before they get to it.
            ai_explanation=result.get('explanation') or '',
            ai_method=result.get('method') or '',
            bias_assessed=bool(result.get('bias_assessed', False)),
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
        claims_resp = ai_post(
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
        sponsor_resp = ai_post(
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


# ── Retention ──────────────────────────────────────────────────────────────────
#
# A takedown hides; it does not destroy. The content stays readable by staff and
# by its creator for the whole appeal window, and everyone else sees a
# tombstone. `purge_expired_takedowns` is the only thing in the codebase
# permitted to actually delete moderated content, and it does so in exactly one
# situation: the appeal window has closed and nobody appealed.
#
# The appeal interaction is the part that has to be right. Filing an appeal
# pushes `purge_after` out again, so a contested takedown can never be deleted
# out from under the appeal being argued. An appeal that is *denied* is finished
# with, so it stops extending the window -- otherwise one denial would buy
# another full term.

#: Environment override so a deployment can shorten the window in an emergency
#: without a code change. Clamped at 1 day: a zero would delete content the
#: instant a moderator pressed Remove.
DEFAULT_APPEAL_DAYS = 90


def appeal_window_days():
    import os

    try:
        days = int(os.environ.get('MODERATION_APPEAL_WINDOW_DAYS', DEFAULT_APPEAL_DAYS))
    except ValueError:
        logger.warning('MODERATION_APPEAL_WINDOW_DAYS is not an integer; using %s',
                       DEFAULT_APPEAL_DAYS)
        return DEFAULT_APPEAL_DAYS
    return max(1, days)


def extend_for_appeal(takedown):
    """Push a takedown's deadline out because an appeal was filed against it."""
    takedown.purge_after = timezone.now() + timezone.timedelta(days=appeal_window_days())
    takedown.save(update_fields=['purge_after', 'updated_at'])
    return takedown.purge_after


def has_open_appeal(takedown):
    """True while an appeal is live against this takedown.

    `submitted` and `under_review` are open. `approved` and `denied` are both
    terminal -- an approved appeal reverses the takedown outright (which clears
    `lifted_at`), and a denied one has been answered.
    """
    if takedown.action_id is None:
        return False
    from apps.moderation.models import ModerationAppeal

    return ModerationAppeal.objects.filter(
        action_id=takedown.action_id,
        status__in=('submitted', 'under_review'),
    ).exists()


@shared_task(name='apps.moderation.tasks.purge_expired_takedowns')
def purge_expired_takedowns(limit=100):
    """Delete content whose takedown has outlived its appeal window.

    Returns a small dict so the beat log says what happened rather than just
    that the task ran.
    """
    from apps.moderation.models import ContentTakedown
    from apps.moderation.takedown import ContentTakedownError, hard_delete_content

    now = timezone.now()
    due = (
        ContentTakedown.objects
        .filter(purge_after__lte=now, purged_at__isnull=True, lifted_at__isnull=True)
        .order_by('purge_after')[:limit]
    )

    deleted = deferred = skipped = 0
    failures = []

    for takedown in due:
        if has_open_appeal(takedown):
            # Someone is contesting this. Give them the full window again.
            extend_for_appeal(takedown)
            deferred += 1
            continue
        try:
            hard_delete_content(takedown.content_type, takedown.content_id)
        except ContentTakedownError as exc:
            # The row is already gone -- the creator deleted it, or a previous
            # run beat us to it. Close the takedown out rather than retrying it
            # every night forever.
            logger.info('moderation_purge already_gone %s %s (%s)',
                        takedown.content_type, takedown.content_id, exc)
            takedown.purged_at = now
            takedown.save(update_fields=['purged_at', 'updated_at'])
            skipped += 1
            continue
        except Exception:  # noqa: BLE001
            # A genuine error. Leave `purged_at` alone so tomorrow retries, and
            # keep going so one bad row cannot wedge the batch.
            logger.exception('moderation_purge failed %s %s',
                             takedown.content_type, takedown.content_id)
            failures.append((takedown.content_type, takedown.content_id))
            continue

        takedown.purged_at = now
        takedown.save(update_fields=['purged_at', 'updated_at'])
        deleted += 1

    result = {'deleted': deleted, 'deferred': deferred, 'skipped': skipped,
              'failed': len(failures), 'window_days': appeal_window_days()}
    logger.info('moderation_purge completed=%s', result)
    return result
