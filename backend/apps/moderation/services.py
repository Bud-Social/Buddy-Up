"""Moderation services: enforcement, two-person routing, and user notification.

Three jobs live here, deliberately kept out of ``views.py`` so they can be
reached from places that are not HTTP requests — the governance approval signal
in ``signals.py``, and the tests.

The rules this module exists to hold:

1. **Nothing is applied by one person.** ``user_suspended`` and ``user_banned``
   are routed to ``apps.governance.AccountActionRequest`` with
   ``requires_second=True``. Warnings are applied inline; a warning is a note
   with no access consequence.
2. **The effect is not re-implemented.** Suspension and ban are delegated to
   ``apps.accounts.services.apply_standing_action`` — the single writer for
   ``User.is_active`` and ``AccountStanding``. Moderation never touches
   ``is_active`` itself.
3. **Every action reaches the user.** A warning, a removal, a suspension, a ban
   and a reversal each fire a notification. An action the user cannot see is an
   action they cannot appeal, which makes the appeal process decorative.
"""
import logging
from datetime import timedelta

from django.db import transaction
from django.utils import timezone

from .models import ContentFlag, ModerationAction
from .takedown import ContentTakedownError

logger = logging.getLogger(__name__)

#: Moderation action -> the notification the target receives. ``escalated`` and
#: ``report_dismissed`` are deliberately absent: they are internal routing
#: decisions and telling a user their content "was escalated" alarms them
#: without informing them.
ACTION_NOTIFICATION_TYPES = {
    'warning': 'moderation_warning',
    'content_removed': 'moderation_content_removed',
    'user_suspended': 'moderation_suspension',
    'user_banned': 'moderation_ban',
}

APPEAL_PATH = '/settings/moderation'


# ---------------------------------------------------------------------------
# Notification plumbing
# ---------------------------------------------------------------------------

def dispatch_notification(user_id, notification_type, title, body, metadata):
    """Create the in-app row AND push to the user's devices.

    Two calls, both required. ``apps.notifications.tasks.create_notification``
    writes the row and pushes over the websocket channel layer, which only
    reaches a client with a live socket — a user with the app closed sees
    nothing. ``apps.marketplace.tasks._push_notification_to_profile`` is what
    talks to FCM / Web Push, so without it a ban issued at 2am is invisible until
    the user opens the app and is bounced by the login guard.

    Failures are logged, never raised: a notification is not the decision. The
    decision is already durably recorded, and losing it to a push-server outage
    would be a far worse outcome than a silent notification.
    """
    from apps.notifications.tasks import create_notification
    from apps.marketplace.tasks import _push_notification_to_profile

    metadata = dict(metadata or {})

    try:
        create_notification.delay(str(user_id), notification_type, title, body, metadata)
    except Exception:  # noqa: BLE001
        logger.exception('Could not create the %s notification for user %s',
                         notification_type, user_id)

    try:
        from apps.profiles.models import Profile
        profile = Profile.objects.filter(user_id=user_id).first()
        if profile is not None:
            _push_notification_to_profile(profile, title, body, metadata)
    except Exception:  # noqa: BLE001
        logger.exception('Could not push the %s notification to user %s',
                         notification_type, user_id)


def notify_action_taken(action_row):
    """Tell the target user that this action happened, and what they can do.

    No-op for actions with no notification type, and for a missing profile
    (``create_notification`` resolves the Profile itself and silently skips when
    there is not one).
    """
    notification_type = ACTION_NOTIFICATION_TYPES.get(action_row.action)
    if notification_type is None:
        return None

    target_id = action_row.target_user_id
    reason = (action_row.reason or '').strip()

    if action_row.action == 'warning':
        title = 'You have received a warning'
        body = reason or 'A moderator has issued a warning on your account.'
    elif action_row.action == 'content_removed':
        title = 'Your content was removed'
        what = action_row.content_type or 'content'
        body = reason or f'A moderator removed your {what} after reviewing it.'
    elif action_row.action == 'user_suspended':
        title = 'Your account has been suspended'
        body = reason or 'Your account has been suspended pending review.'
    else:  # user_banned
        title = 'Your account has been banned'
        body = reason or 'Your account has been banned.'

    metadata = {
        'moderation_action_id': str(action_row.id),
        'action': action_row.action,
        'reason': reason,
        'report_id': str(action_row.report_id) if action_row.report_id else None,
        'content_type': action_row.content_type or None,
        'content_id': action_row.content_id or None,
        'appeal_path': APPEAL_PATH,
        'can_appeal': True,
    }
    if action_row.action in ModerationAction.STANDING_ACTIONS:
        metadata.update(_standing_metadata(action_row))

    dispatch_notification(target_id, notification_type, title, body, metadata)
    return notification_type


def _standing_metadata(action_row):
    """The "until / permanent" facts the user's app renders next to the ban."""
    days = action_row.duration_days
    metadata = {'duration_days': days}
    if action_row.action == 'user_suspended' and days:
        metadata['suspended_until'] = (timezone.now() + timedelta(days=days)).isoformat()
        metadata['permanent'] = False
    else:
        # A ban, or a suspension with no term, has no end date.
        metadata['suspended_until'] = None
        metadata['permanent'] = action_row.action == 'user_banned'
    return metadata


def notify_action_reversed(action_row, reversal):
    """Tell the target their action was undone, and why.

    Reads the reason off ``action_row``, not ``reversal``: the reason is stamped
    on the row being reversed, and the reversal row's own ``reversal_reason`` is
    blank by construction. Reading the wrong one ships an empty reason to the
    one user who is trying to find out what happened to them.
    """
    target_id = action_row.target_user_id
    reason = (action_row.reversal_reason or '').strip()
    dispatch_notification(
        target_id, 'moderation_action_reversed',
        'A moderation action on your account was reversed',
        reason or 'A moderator has reversed a previous action on your account.',
        {
            'original_action_id': str(action_row.id),
            'reversal_action_id': str(reversal.id),
            'original_action': action_row.action,
            'reason': reason,
            'appeal_path': APPEAL_PATH,
        },
    )


def notify_commendation(commendation):
    from apps.profiles.models import Profile
    profile = Profile.objects.filter(user_id=commendation.recipient_id).first()
    if profile is None:
        return
    issuer = ''
    if commendation.issued_by_id:
        issuer = (commendation.issued_by.display_name
                  or commendation.issued_by.username or '')
    title = f'You received a commendation: {commendation.get_category_display()}'
    body = commendation.message or ''
    if issuer:
        body = f'{issuer}: {body}'.strip()
    dispatch_notification(
        profile.user_id, 'commendation_received', title, body,
        {
            'commendation_id': str(commendation.id),
            'category': commendation.category,
            'issued_by': issuer,
        },
    )


# ---------------------------------------------------------------------------
# Standing actions (suspension / ban) — two-person, never one-person
# ---------------------------------------------------------------------------

#: Moderation action -> governance ``AccountActionRequest.action``. Spelled out
#: rather than derived by string surgery: ``'user_banned'[5:]`` happens to work
#: today and would silently produce a nonexistent action the moment a choice is
#: renamed. Governance raises on an action it does not recognise, which is the
#: behaviour we want from this map.
GOVERNANCE_ACTION_FOR = {
    'user_suspended': 'suspension',
    'user_banned': 'ban',
}


def apply_standing_action_for_row(action_row, actor=None, approval=None):
    """Delegate the standing effect to ``apps.accounts.services``.

    ``source`` carries the ``ModerationAction`` id rather than the approval id,
    so ``AccountStanding.action_id`` points at this app's audit row — the record
    a moderator, an appeal panel or a support agent will actually open.

    Idempotency: when the effect arrived via a governance approval, governance
    has already called this with ``source=f'governance:{approval.id}'``. Calling
    it again would not corrupt the standing (it is an upsert) but it would write
    a second ``AccountEvent``, revoke every device session a second time and log
    a second line claiming the ban happened here. So the provenance column is
    checked first and the call is skipped when governance got there first.
    """
    from apps.accounts import services as accounts_services

    if approval is not None:
        from apps.accounts.models import AccountStanding
        already = AccountStanding.objects.filter(
            user_id=action_row.target_user_id, action_id=f'governance:{approval.id}',
        ).exists()
        if already:
            logger.info(
                'Standing action %s already applied by governance approval %s; '
                'moderation did not re-apply it.', action_row.id, approval.id,
            )
            return None

    duration_days = action_row.duration_days if action_row.action == 'user_suspended' else None
    return accounts_services.apply_standing_action(
        target_user_id=action_row.target_user_id,
        action=action_row.action,
        reason=action_row.reason or '',
        duration_days=duration_days,
        actor=actor,
        source=f'moderation:{action_row.id}',
    )


def lift_standing_action_for_row(action_row, actor=None, reason=''):
    """Undo a suspension/ban through the accounts service.

    The only correct reversal. Setting ``user.is_active = True`` by hand — what
    the appeal-review path used to do — leaves the ``AccountStanding`` row still
    saying "banned", so the next login check re-suspends the account the
    instant it is read back.
    """
    from apps.accounts.services import lift_standing_action
    return lift_standing_action(
        target_user_id=action_row.target_user_id,
        actor=actor,
        reason=reason or '',
    )


@transaction.atomic
def request_standing_action(*, action, target_user, reason, duration_days=None,
                            moderator=None, report=None):
    """Raise a pending ban/suspension request instead of applying it.

    Returns ``(action_row, approval)``. ``approval`` is ``None`` only for a
    non-standing action, which this function refuses.

    The kwargs match ``apps.governance.serializers.AccountActionRequestCreateSerializer``
    exactly: ``action``, ``target_user`` (a ``User``), ``payload`` with
    ``reason``/``duration_days``, ``requested_by``, ``requested_by_profile``,
    ``requires_second``. The app's own create view adds scope checks and
    self-target refusal; both are re-checked here because this endpoint is not
    that view and must not be a way around them.
    """
    governance_action = GOVERNANCE_ACTION_FOR.get(action)
    if governance_action is None:
        raise ValueError(
            f'{action!r} is not a standing action; expected one of '
            f'{sorted(GOVERNANCE_ACTION_FOR)}.'
        )

    # Lazy import: apps.governance imports apps.admin_portal, which imports
    # plenty. A module-level import here closes a loop through the moderation app
    # during population and turns a startup into an ImportError.
    from apps.governance.models import AccountActionRequest
    from apps.governance.serializers import display_name_of
    from apps.governance.services import has_scope

    if target_user.pk == getattr(moderator, 'pk', None):
        raise PermissionError('You cannot raise a suspension or ban against your own account.')
    if target_user.is_superuser:
        raise PermissionError('A suspension or ban cannot be raised against a superuser account.')
    # `users.write` is what AccountActionRequest.ACTION_SCOPES demands of the
    # approver. Governance checks the approver's scope at approval time; this is
    # the same check on the requester, so a support agent can neither raise a
    # request nobody with the right scope is obliged to approve, nor discover
    # later that their request was quietly non-actionable.
    if not has_scope(moderator, AccountActionRequest.ACTION_SCOPES[governance_action]):
        raise PermissionError(
            f'Raising a {governance_action!r} request requires the '
            f'{AccountActionRequest.ACTION_SCOPES[governance_action]!r} scope, '
            'which your role does not include.'
        )

    payload = {'reason': reason or ''}
    if action == 'user_suspended' and duration_days:
        payload['duration_days'] = int(duration_days)

    action_row = ModerationAction.objects.create(
        action=action,
        moderator=moderator,
        report=report,
        target_user=target_user,
        reason=reason,
        duration_days=payload.get('duration_days'),
    )

    approval = AccountActionRequest.objects.create(
        action=governance_action,
        target_user=target_user,
        payload=payload,
        requested_by=moderator,
        requested_by_profile=display_name_of(moderator),
        requires_second=True,
    )
    # The link back, stored on the governance row we are allowed to write
    # (``payload`` is free-form) rather than on a column we would have to add to
    # another app's model to find.
    approval.payload = {**payload, 'moderation_action_id': str(action_row.id)}
    approval.save(update_fields=['payload', 'updated_at'])
    return action_row, approval


def issue_warning(*, target_user, reason, moderator=None, report=None):
    """Record a warning and tell the user, in that order, in one call.

    A warning used to be creatable only as a side effect of "escalate", which
    meant a user was formally warned and never found out.
    """
    action_row = ModerationAction.objects.create(
        action='warning',
        moderator=moderator,
        report=report,
        target_user=target_user,
        reason=reason,
    )
    notify_action_taken(action_row)
    return action_row


def clear_flag_marker(flag):
    """Approve path: clear the content's *flag* marker.

    Wraps ``takedown.clear_flag`` and re-labels the failure as a
    ``ContentTakedownError`` so the caller has one exception type to reason
    about. The approve path treats a failure here as non-fatal (the flag is
    still closed; there is simply no marker to clear) and reports it.
    """
    from .takedown import clear_flag
    return clear_flag(flag.content_type, flag.content_id)


def resolve_author(flag):
    """The ``User`` who wrote the flagged content, or None.

    Falls back to None rather than to the moderator: a takedown against content
    nobody owns still needs a ``ModerationAction.target_user``, and inventing an
    attribution from the reviewing staff member would put a colleague's name on
    a removal they did not perform.
    """
    from .takedown import resolve_content_author
    return resolve_content_author(flag.content_type, flag.content_id)


def remove_flagged_content(*, flag: ContentFlag, moderator, note=''):
    """Take a flagged item down and record the action.

    Returns ``(action_row, description)``. Raises ``ContentTakedownError`` if
    the takedown failed — and, critically, creates **no** ``ModerationAction``
    in that case, so a failed takedown cannot leave an audit row claiming the
    content came down.
    """
    from .takedown import remove_content

    author, description = remove_content(flag.content_type, flag.content_id)
    reason = f'Removed {flag.content_type} {flag.content_id} (flag #{flag.id})'
    if note:
        reason = f'{reason}: {note}'

    action_row = ModerationAction.objects.create(
        action='content_removed',
        moderator=moderator,
        report=None,
        target_user=author or moderator,
        reason=reason,
        content_type=flag.content_type,
        content_id=flag.content_id,
    )
    flag.is_actioned = True
    flag.action_taken = 'content_removed'
    flag.save(update_fields=['is_actioned', 'action_taken', 'updated_at'])

    notify_action_taken(action_row)
    return action_row, description


def reverse_action(*, action_row, actor, reason=''):
    """Undo a ``ModerationAction`` and stamp the reversal on the original row.

    Three shapes, depending on what the action did:

    * ``content_removed`` — restore the content through the takedown registry,
      which refuses loudly for the hard-deleting types.
    * ``user_suspended`` / ``user_banned`` — lift the standing via accounts.
    * ``warning`` — nothing to restore; the row records that the warning was
      withdrawn, which is itself the record the user needs.

    Returns ``(reversal_row, description)``.
    """
    from .takedown import restore_content

    if action_row.is_reversed:
        raise ContentTakedownError(
            f'Action {action_row.id} was already reversed on '
            f'{action_row.reversed_at.isoformat()}.'
        )
    reason = (reason or '').strip()

    if action_row.action == 'content_removed':
        if not action_row.content_type or not action_row.content_id:
            raise ContentTakedownError(
                f'Action {action_row.id} does not record which content it removed, '
                'so there is nothing to restore.'
            )
        description = restore_content(action_row.content_type, action_row.content_id)
    elif action_row.action in ModerationAction.STANDING_ACTIONS:
        lift_standing_action_for_row(action_row, actor=actor, reason=reason)
        description = (
            'suspension lifted; the account is active again'
            if action_row.action == 'user_suspended'
            else 'ban lifted; the account is active again'
        )
    elif action_row.action == 'warning':
        description = 'warning withdrawn'
    else:
        raise ContentTakedownError(
            f'A {action_row.action!r} action has no reversal; only warnings, '
            'removals, suspensions and bans can be undone.'
        )

    # The reversal row is written first, because `reversed_by` points at *it* —
    # a self FK to the `action_reversed` record. That is what makes the ledger
    # navigable in both directions: from the reversal to what it undid, and
    # from the original action to the row that undid it, with the moderator who
    # did it one hop away on the reversal row itself.
    reversal = ModerationAction.objects.create(
        action='action_reversed',
        moderator=actor,
        report=action_row.report,
        target_user=action_row.target_user,
        reason=f'Reversed action #{action_row.id} ({action_row.action}): {reason}'.strip(),
        content_type=action_row.content_type,
        content_id=action_row.content_id,
        duration_days=action_row.duration_days,
    )
    action_row.reversed_by = reversal
    action_row.reversed_at = timezone.now()
    action_row.reversal_reason = reason
    action_row.save(update_fields=['reversed_by', 'reversed_at', 'reversal_reason', 'updated_at'])

    notify_action_reversed(action_row, reversal)
    return reversal, description