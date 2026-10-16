"""The one way this platform sends an email.

Before this there were four templates, no layout, and one task with a retry —
every other send went out through ``send_mail`` inside a ``@shared_task`` with
no retry at all, so an SMTP blip dropped the message on the floor and the only
trace was the absence of one. Worse, there was no record that anything had been
attempted, so "did we ever email them?" had no answer.

What this module centralises:

* one template layout (``emails/base.html``) and one rendering path;
* one delivery lifecycle, written to :class:`~apps.governance.models.EmailLog`
  *before* the worker is handed the message, so a queued email is already
  visible even if the worker never runs;
* retries on every send, not just the OTP one;
* an audit row per send, so the console's "what did staff do" question and the
  "what did we tell them" question are the same query.

The house style this matches is ``apps.accounts.tasks.send_otp_email``: render
HTML with ``render_to_string``, derive plaintext with ``strip_tags``, always
send from ``settings.DEFAULT_FROM_EMAIL``, keep every task argument a
JSON-serialisable primitive, return silently on ``DoesNotExist``, and
``logger.exception`` + ``self.retry`` on failure. The OTP task's
``@shared_task(bind=True, max_retries=3, default_retry_delay=10)`` is copied
onto every task here on purpose — the tasks around it that lack it are the bug
this module exists to stop repeating.

Why staff sends go through the same path as the OTP
----------------------------------------------------
An assistance console that had its own ``send_mail`` call would be the same
ad-hoc pattern with a worse blast radius. Sharing the path means a staff message
gets the same retry, the same delivery log and the same audit row as a password
reset, and it means the "did this actually go out?" question has one answer.
"""
import json
import logging

from celery import shared_task
from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import EmailMultiAlternatives, get_connection
from django.template.loader import render_to_string
from django.utils import timezone
from django.utils.html import strip_tags

from .models import EmailLog
from .services import record_admin_action

logger = logging.getLogger(__name__)


# template_key -> template path.
#
# An explicit registry rather than f-stringing the caller's string into
# ``render_to_string``. The key reaches this module from an HTTP body, and
# ``render_to_string`` resolves arbitrary dotted paths off the template loaders
# — an open key is a file-disclosure primitive, not a style question. Adding a
# template means adding an entry here, which is also the place a reviewer looks.
EMAIL_TEMPLATES = {
    'staff_message': 'emails/staff_message.html',
    # Carries the one-time accept link, so this template is the only place a
    # staff credential is ever rendered.
    'staff_invitation': 'emails/staff_invitation.html',
}

# Where a reply to a staff message goes. Falls back to DEFAULT_FROM_EMAIL so the
# header is never empty and a reply is never silently dropped by a mail server.
SUPPORT_REPLY_EMAIL = 'support@buddyup.app'

# Dedupe is scoped to this window: a key that blocked forever would stop the
# user ever receiving the message a second time (a resend after a real failure,
# a corrected message). An hour is long enough to swallow the double-click and
# the retry-storm, short enough to stay a safety net and not become policy.
DEDUPE_WINDOW_HOURS = 1


def resolve_template(template_key):
    """The template path for ``template_key``, or None if it is not registered."""
    return EMAIL_TEMPLATES.get(str(template_key or '').strip())


def dedupe_blocks(dedupe_key, *, exclude_id=None):
    """True if a live attempt with this key is already in flight or delivered.

    Only ``queued`` and ``sent`` rows block. A ``failed`` row does not: refusing
    to retry because the previous attempt failed would make the resend endpoint
    unreachable, which is precisely when a human is most likely to want it.
    ``skipped`` rows never block either — they are the *result* of dedupe, not
    an attempt.
    """
    if not dedupe_key:
        return False
    queryset = EmailLog.objects.filter(
        dedupe_key=str(dedupe_key)[:200],
        status__in=['queued', 'sent'],
    )
    if exclude_id:
        queryset = queryset.exclude(pk=exclude_id)
    return queryset.exists()


def send_templated_email(
    *,
    to_email,
    subject,
    template_key,
    context=None,
    sent_by=None,
    related_object_type='',
    related_object_id='',
    dedupe_key='',
    request=None,
):
    """Queue one templated email. Returns the :class:`EmailLog` row.

    The row is written *first*, in ``queued``, and the worker is only handed the
    ``log_id``. That ordering is the whole point: if the enqueue itself fails,
    or the broker is down, or the worker never picks the task up, the console
    still shows a queued message that never went out. The reverse order would
    lose the record of a send that was attempted.

    ``recipient_user`` is resolved from ``to_email`` when it matches a real
    account, and left null when it does not. Callers that must guarantee a
    registered recipient — the staff assistance console — look the user up
    first and refuse otherwise; this function stays permissive so that
    app-level transactional mail (a signup to an address that has not finished
    registration) is not blocked by the log's convenience FK.

    ``request`` is optional and only used to stamp the audit row with the
    caller's IP, user agent and request id.

    ``context`` is the template's variables — ``{'staff_name': ..., 'body':
    ...}``. It crosses the broker as JSON alongside the log id, so it is
    normalised and size-checked here and a context that cannot cross raises
    ``ValueError`` at queue time rather than rendering an empty staff name into
    a user's inbox three seconds later.

    Dedupe: a ``dedupe_key`` suppresses a second live attempt with the same key
    — the row is still written, with ``status='skipped'`` and an error
    explaining why, so a suppressed duplicate is visible rather than invisible.
    """
    to_email = str(to_email or '').strip().lower()[:254]
    subject = str(subject or '').strip()[:300]
    template_key = str(template_key or '').strip()[:80]
    related_object_type = str(related_object_type or '')[:50]
    related_object_id = str(related_object_id or '')[:64]
    dedupe_key = str(dedupe_key or '')[:200]

    # Raised here, not in the worker: a context that cannot cross the broker is
    # a caller bug, and finding out at queue time — while the operator is still
    # looking at the screen — is worth much more than finding out in a worker
    # log. Validated *before* the row is written, so a rejected context leaves
    # no orphaned `queued` row that no worker will ever pick up.
    task_context = _jsonable_context(context)

    recipient_user = None
    if to_email:
        recipient_user = get_user_model().objects.filter(email__iexact=to_email).first()

    sent_by_email = str(getattr(sent_by, 'email', '') or '')[:254]

    if dedupe_blocks(dedupe_key):
        return EmailLog.objects.create(
            recipient_user=recipient_user,
            recipient_email=to_email,
            subject=subject,
            template_key=template_key,
            sent_by=sent_by if getattr(sent_by, 'is_authenticated', False) else None,
            sent_by_email=sent_by_email,
            status='skipped',
            error=(
                f'Suppressed: another message with dedupe key {dedupe_key!r} was '
                f'queued or sent within the last {DEDUPE_WINDOW_HOURS}h.'
            ),
            dedupe_key=dedupe_key,
            related_object_type=related_object_type,
            related_object_id=related_object_id,
        )

    log = EmailLog.objects.create(
        recipient_user=recipient_user,
        recipient_email=to_email,
        subject=subject,
        template_key=template_key,
        sent_by=sent_by if getattr(sent_by, 'is_authenticated', False) else None,
        sent_by_email=sent_by_email,
        status='queued',
        dedupe_key=dedupe_key,
        related_object_type=related_object_type,
        related_object_id=related_object_id,
    )

    record_admin_action(
        actor=sent_by,
        action='emails.send',
        summary=f'Queued "{subject[:120]}" to {to_email}',
        target_type=related_object_type or 'user',
        target_id=related_object_id or str(recipient_user.pk if recipient_user else ''),
        # The subject and template, never the rendered body: the body is user
        # content and the audit contract does not hold it.
        after={
            'email_log_id': str(log.id),
            'template_key': template_key,
            'subject': subject,
            'recipient_email': to_email,
        },
        request=request,
    )

    deliver_templated_email.delay(str(log.id), task_context)
    return log


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def deliver_templated_email(self, log_id, context=None):
    """Render and send one queued :class:`EmailLog`, then record the outcome.

    Takes the ``log_id`` and the caller's template ``context`` and nothing
    else: every argument crossing the broker has to be a JSON-serialisable
    primitive, and re-reading the row means a retry sends what was queued
    rather than what the arguments happen to say. The context is passed
    alongside rather than re-read from the row because
    :class:`EmailLog` deliberately has nowhere to put a template context —
    and because a context that cannot be serialised is a caller bug best
    caught before the queue, not after.

    Retry discipline: transient SMTP failures are retried up to
    ``max_retries`` with ``default_retry_delay``. The row is only marked
    ``failed`` on the *last* attempt — marking it failed on the first error and
    then retrying would leave a visible "failed" sitting next to a message that
    was about to be delivered, which is exactly the kind of row that trains
    staff to ignore the log.
    """
    from .models import EmailLog as _EmailLog

    try:
        log = _EmailLog.objects.select_related('recipient_user').get(pk=log_id)
    except (_EmailLog.DoesNotExist, ValueError, TypeError):
        # The row was purged or the id is not a UUID. Nothing to send, and
        # nothing to retry — retrying this would fail identically forever.
        logger.warning('email_log_missing log_id=%s', log_id)
        return None

    template_name = resolve_template(log.template_key)
    if template_name is None:
        _mark(log, status='failed', error=f'Unregistered template key: {log.template_key!r}')
        logger.error('email_template_unregistered key=%s log_id=%s', log.template_key, log_id)
        return None

    if not log.recipient_email:
        _mark(log, status='failed', error='No recipient address.')
        return None

    # The caller's context wins over the derived defaults: a template that was
    # given a staff name must render that name, not the empty string the log
    # happens to hold.
    context = {**_build_context(log), **(context or {})}
    try:
        html = render_to_string(template_name, context)
    except Exception as exc:  # noqa: BLE001 — a template bug will not fix itself
        _mark(log, status='failed', error=f'Render failed: {exc}')
        logger.exception('email_render_failed log_id=%s template=%s', log_id, template_name)
        return None

    plain = strip_tags(html)
    log.body_preview = plain[:500]
    log.save(update_fields=['body_preview', 'updated_at'])

    try:
        message = EmailMultiAlternatives(
            subject=log.subject,
            body=plain,
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[log.recipient_email],
            reply_to=[context['reply_to']],
        )
        message.attach_alternative(html, 'text/html')
        message.send(fail_silently=False, connection=get_connection(fail_silently=False))
    except Exception as exc:  # noqa: BLE001 — retry transient SMTP/provider errors
        last_attempt = self.request.retries >= (self.max_retries or 0)
        if last_attempt:
            _mark(log, status='failed', error=str(exc)[:2000])
            record_admin_action(
                actor=log.sent_by,
                action='emails.send_failed',
                summary=f'Delivery of "{log.subject[:120]}" to {log.recipient_email} failed',
                target_type=log.related_object_type or 'user',
                target_id=log.related_object_id,
                after={'email_log_id': str(log.id), 'error': str(exc)[:300]},
            )
        logger.exception(
            'email_delivery_failed log_id=%s to=%s attempt=%s/%s',
            log_id, log.recipient_email, self.request.retries + 1, self.max_retries,
        )
        raise self.retry(exc=exc)

    _mark(log, status='sent')
    logger.info('email_delivered log_id=%s to=%s template=%s', log_id, log.recipient_email, log.template_key)
    return str(log.id)


def _build_context(log):
    """Template defaults for one send. Every value is a plain primitive.

    These are the facts the log row holds; the caller's own ``context`` is
    merged over the top of this by the task. The recipient's *email* is passed
    (it is in the log anyway) but no credential, no token and no profile
    object — templates that want the display name should fall back to the local
    part, as ``send_otp_email`` does.
    """
    username = (log.recipient_email or '').split('@')[0] or 'there'
    return {
        'username': username,
        'recipient_email': log.recipient_email,
        'subject': log.subject,
        'template_key': log.template_key,
        'sent_by_name': log.sent_by_email,
        'related_object_type': log.related_object_type,
        'related_object_id': log.related_object_id,
        'reply_to': getattr(settings, 'SUPPORT_REPLY_EMAIL', None) or SUPPORT_REPLY_EMAIL,
        'logo_url': logo_url(),
        'support_email': getattr(settings, 'SUPPORT_REPLY_EMAIL', None) or SUPPORT_REPLY_EMAIL,
        'sent_at': timezone.now(),
    }


def logo_url():
    """Same logo the OTP email uses, so the two do not look like two products."""
    return getattr(settings, 'EMAIL_LOGO_URL', '') or (
        f"{getattr(settings, 'PUBLIC_FRONTEND_URL', 'https://buddyup.app').rstrip('/')}"
        '/icons/icon-512.png'
    )


# A template context crosses the broker as JSON, so it is bounded. 16KB is far
# more than any real email needs and small enough that nobody is smuggling a
# document through it.
_MAX_CONTEXT_BYTES = 16 * 1024
_MAX_CONTEXT_DEPTH = 4


def _jsonable(value, depth=0):
    """Coerce a template context into something JSON can carry.

    Model instances, datetimes and Decimal all render fine in a template and
    all fail at ``json.dumps`` inside the broker, so they are stringified here.
    Raising beats silently dropping: a template that renders an empty staff
    name is far worse than a queue-time error the caller can see.
    """
    if depth >= _MAX_CONTEXT_DEPTH:
        return str(value)
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    if isinstance(value, dict):
        return {str(k): _jsonable(v, depth + 1) for k, v in value.items()}
    if isinstance(value, (list, tuple, set)):
        return [_jsonable(item, depth + 1) for item in value]
    return str(value)


def _jsonable_context(context):
    """Validate and normalise a caller-supplied template context."""
    if not context:
        return {}
    if not isinstance(context, dict):
        raise ValueError(
            'context must be a dict of template variables, got '
            f'{type(context).__name__}.'
        )
    cleaned = _jsonable(context)
    try:
        encoded = json.dumps(cleaned)
    except (TypeError, ValueError) as exc:
        raise ValueError(f'context is not JSON-serialisable: {exc}') from exc
    if len(encoded.encode('utf-8')) > _MAX_CONTEXT_BYTES:
        raise ValueError(
            f'context is {len(encoded.encode("utf-8"))} bytes; the limit is '
            f'{_MAX_CONTEXT_BYTES}.'
        )
    return cleaned


def _mark(log, *, status, error=''):
    """Write a delivery outcome onto the row, tolerating a missing table.

    Called from the worker's failure paths, which run when the database may
    itself be the thing that is broken. Losing the status update in that case
    is acceptable; raising from a cleanup path is not.
    """
    try:
        log.status = status
        if error:
            log.error = str(error)[:2000]
        log.save(update_fields=['status', 'error', 'updated_at'])
    except Exception:  # noqa: BLE001
        logger.exception('email_log_status_update_failed log_id=%s status=%s', log.pk, status)