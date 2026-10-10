"""Account standing: the single writer for moderation-enforced access state.

``apply_standing_action`` is the counterpart to ``admin_portal``'s suspend
button and to the governance approval flow. Both flip ``User.is_active``;
neither can express *why*, and that is the hole this module closes — an
``is_active=False`` row is indistinguishable from a user's own deactivation,
which the login flow is explicitly built to reverse.

Import contract: ``apply_standing_action`` and ``lift_standing_action`` are
imported by other apps (governance approves an action and calls into here).
Signatures below are a public API — keyword-only, and changing them breaks a
caller in another app.
"""
import logging
from datetime import timedelta

from django.db import transaction
from django.utils import timezone

from .models import AccountEvent, AccountStanding, DeviceSession, User

logger = logging.getLogger(__name__)

#: The only two actions that change authentication. Anything else is a bug in
#: the caller, not a runtime condition, so it raises rather than degrading.
STANDING_ACTIONS = {
    'user_suspended': AccountStanding.STATE_SUSPENDED,
    'user_banned': AccountStanding.STATE_BANNED,
}


def get_standing(user):
    """The user's AccountStanding row, or None. Never raises.

    Uses ``values().first()`` rather than the reverse descriptor so a missing
    row is a plain None instead of ``RelatedObjectDoesNotExist`` — this is
    called from the authentication path, where an exception on every
    unenrolled account would be a 500 storm.
    """
    if user is None or not getattr(user, 'pk', None):
        return None
    return AccountStanding.objects.filter(user_id=user.pk).values().first()


def _hydrate(standing_dict) -> AccountStanding:
    return AccountStanding(**standing_dict)


def get_standing_object(user):
    """As ``get_standing`` but returns a real model instance.

    An expired temporary suspension is cleared here, on read, so the lapse
    takes effect without a background job: the row is flipped to ``clear``
    exactly once (the conditional UPDATE is the guard against two concurrent
    requests both "clearing" and clobbering a re-issued action).
    """
    row = get_standing(user)
    if row is None:
        return None
    standing = _hydrate(row)
    if not standing.is_expired:
        return standing
    cleared = AccountStanding.objects.filter(
        pk=standing.pk, state=AccountStanding.STATE_SUSPENDED,
        suspended_until__lte=timezone.now(),
    ).update(state=AccountStanding.STATE_CLEAR, suspended_until=None, permanent=False)
    if cleared:
        # The account was switched off when the suspension was applied; a
        # lapsed suspension must hand the account back, not leave it dark.
        User.objects.filter(pk=user.pk, is_active=False, deleted_at__isnull=True).update(
            is_active=True,
        )
        # The caller is mid-request with this instance in hand (the login view
        # branches on user.is_active a few lines later), so the in-memory flag
        # has to follow the row we just updated.
        if user.deleted_at is None:
            user.is_active = True
        logger.info('Temporary suspension lapsed for user %s; standing cleared', user.pk)
    standing.state = AccountStanding.STATE_CLEAR
    standing.suspended_until = None
    standing.permanent = False
    return standing


def standing_blocks_authentication(user) -> bool:
    """True when this user may not authenticate right now."""
    standing = get_standing_object(user)
    return bool(standing and standing.blocks_authentication())


def standing_payload(user) -> dict:
    """The ``standing`` block returned with every rejection."""
    standing = get_standing_object(user)
    if standing is None:
        return {
            'state': AccountStanding.STATE_CLEAR,
            'reason': '',
            'until': None,
            'permanent': False,
        }
    return standing.as_payload()


def _resolve_actor(actor):
    """Accept a User instance or a primary key; anything else is ignored.

    Callers hand us ``request.user`` in practice, but a queued job may only
    have the id. Silently dropping an unresolvable actor is deliberate: the
    decision itself still stands, and ``reason`` / ``action_id`` keep the
    audit trail intact.
    """
    if isinstance(actor, User):
        return actor
    if actor:
        return User.objects.filter(pk=actor).first()
    return None


def _validate_duration(duration_days):
    if duration_days is None:
        return None
    try:
        days = int(duration_days)
    except (TypeError, ValueError):
        raise ValueError(f'duration_days must be an integer, got {duration_days!r}')
    if days <= 0:
        raise ValueError(f'duration_days must be positive, got {days}')
    return days


@transaction.atomic
def apply_standing_action(*, target_user_id, action, reason, duration_days=None,
                          actor=None, source=None):
    """Suspend or ban ``target_user_id`` and make it stick.

    ``action`` must be ``'user_suspended'`` or ``'user_banned'``; anything
    else raises ``ValueError`` — this is called from an approval flow that
    treats ``ValueError`` as "leave the request pending and tell the operator",
    so a silent no-op would be worse than a loud failure.

    Duration semantics:

    * ``user_suspended`` with no ``duration_days`` -> indefinite until lifted
      (``permanent=False``, ``suspended_until=None``). NOT permanent: it can
      still be lifted, and ``is_expired`` correctly reports False.
    * ``user_suspended`` with ``duration_days`` -> ``suspended_until`` set,
      after which the standing self-clears on next read.
    * ``user_banned`` -> ``permanent=True``, ``suspended_until=None``.

    Every device session is revoked so an outstanding refresh token cannot
    mint a new access token: revoking the row alone would leave the ban
    defeatable for the remainder of the token's life.
    """
    if action not in STANDING_ACTIONS:
        raise ValueError(
            f'Unknown standing action {action!r}; expected one of '
            f'{sorted(STANDING_ACTIONS)}.'
        )

    days = _validate_duration(duration_days)
    target = User.objects.get(pk=target_user_id)
    issued_by = _resolve_actor(actor)
    now = timezone.now()

    if action == 'user_banned':
        state = AccountStanding.STATE_BANNED
        permanent, suspended_until = True, None
    elif days is None:
        state = AccountStanding.STATE_SUSPENDED
        permanent, suspended_until = False, None
    else:
        state = AccountStanding.STATE_SUSPENDED
        permanent = False
        suspended_until = now + timedelta(days=days)

    standing, _created = AccountStanding.objects.select_for_update().get_or_create(user=target)
    previous_state = standing.state
    standing.state = state
    standing.reason = reason or ''
    standing.permanent = permanent
    standing.suspended_until = suspended_until
    standing.is_moderation_action = True
    standing.issued_by = issued_by
    standing.issued_at = now
    # Correlates this row back to the decision that produced it (governance
    # passes f'governance:{approval.id}').
    standing.action_id = (source or '')[:64]
    standing.save()

    if target.is_active:
        target.is_active = False
        target.save(update_fields=['is_active'])

    revoked = DeviceSession.objects.filter(user=target, is_active=True).update(is_active=False)

    AccountEvent.objects.create(
        user=target,
        event_type='account_banned' if state == AccountStanding.STATE_BANNED else 'account_suspended',
        metadata={
            'previous_state': previous_state,
            'state': state,
            'reason': reason or '',
            'duration_days': days,
            'permanent': permanent,
            'source': source or '',
            'actor': str(issued_by.pk) if issued_by else '',
            'sessions_revoked': revoked,
        },
    )
    logger.warning(
        'Account standing applied: user=%s action=%s by=%s source=%s',
        target.pk, action, getattr(issued_by, 'pk', None), source,
    )
    return standing


@transaction.atomic
def lift_standing_action(*, target_user_id, actor=None, reason=''):
    """Clear a standing and hand the account back.

    The ONLY path that clears a moderation action. ``LoginView``'s
    ``reactivate: true`` branch is deliberately not one of them — that branch
    exists for self-deactivation and has no way to tell the two apart without
    this row.
    """
    target = User.objects.get(pk=target_user_id)
    issued_by = _resolve_actor(actor)
    now = timezone.now()
    previous_state = None

    standing = AccountStanding.objects.select_for_update().filter(user=target).first()
    if standing is None:
        # No row at all — still persist one so the returned object is always a
        # saved record of what was done, never an unsaved instance the caller
        # might assume is durable.
        standing = AccountStanding(user=target)
    else:
        previous_state = standing.state
    standing.state = AccountStanding.STATE_CLEAR
    standing.suspended_until = None
    standing.permanent = False
    standing.is_moderation_action = False
    standing.reason = reason or ''
    standing.issued_by = issued_by
    standing.issued_at = now
    standing.save()

    if not target.is_active:
        target.is_active = True
        target.save(update_fields=['is_active'])

    if previous_state and previous_state != AccountStanding.STATE_CLEAR:
        AccountEvent.objects.create(
            user=target,
            event_type='account_standing_lifted',
            metadata={
                'previous_state': previous_state,
                'reason': reason or '',
                'actor': str(issued_by.pk) if issued_by else '',
            },
        )
    logger.info('Account standing lifted: user=%s by=%s', target.pk, getattr(issued_by, 'pk', None))
    return standing


@transaction.atomic
def require_totp_enrolment(*, user, reason=''):
    """Record that a staff member was refused a session without a 2nd factor.

    ``totp_enabled`` is the enforcement point, not a flag on this row: an
    operator who cannot enrol (no phone, lost device) is locked out of their
    own account, which is the intended pressure — recovery is via a recovery
    code or a password reset, and both are audited.

    Writes an AccountEvent per refusal. That is deliberate: a staff account
    repeatedly attempting to log in without MFA is the signal worth keeping.
    """
    AccountEvent.objects.create(
        user=user,
        event_type='mfa_enrolment_required',
        metadata={'reason': reason or '', 'email': user.email},
    )
    return user
