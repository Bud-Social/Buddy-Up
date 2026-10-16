"""Staff onboarding: turning an accepted invitation into a usable staff account.

This module is the only place in the codebase that sets ``User.is_staff``. That
is not a design flourish -- it is the gap that made staff onboarding impossible.
``StaffRoleWriteSerializer`` refuses a role for anyone who is not already
``is_staff``, and with nothing setting that flag the role table could never be
reached through the product. The one real staff account was made by hand in the
database and still has no ``StaffRole`` row.

So the rule is now:

* the *only* supported way an account becomes ``is_staff`` is accepting a
  :class:`~apps.governance.models.StaffInvitation` (or an explicit, audited
  operator grant via ``manage.py grant_staff_role``);
* ``is_staff`` alone grants nothing -- it opens the console shell, and every
  read and write behind it is still checked against the ``StaffRole`` scopes, so
  an account that is staff with no role row sees an empty console rather than a
  working one.

Kept in its own module because both the public accept view and the operator
grant command need it, and neither should be importing the other.
"""
import logging

from django.db import transaction
from django.utils import timezone

from .models import StaffInvitation, StaffRole

logger = logging.getLogger(__name__)


class InvitationError(Exception):
    """Refusal with a message intended for the person holding the link."""

    def __init__(self, message, status_code=400):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def invitation_state(token):
    """What the accept screen needs to know, without granting anything.

    Deliberately does not disclose whether the address already has an account
    to anyone but the eventual holder of the token -- and the token is the
    secret, so that is acceptable. It returns the minimum needed to render an
    honest screen: valid, expired, revoked, already used.
    """
    invitation = StaffInvitation.objects.filter(token=token).first()
    if invitation is None:
        raise InvitationError('This invitation link is not valid.', status_code=404)

    invitation.mark_expired_if_stale()

    return {
        'invitation': invitation,
        'email': invitation.email,
        'role': invitation.role,
        'status': invitation.status,
        'is_live': invitation.is_live,
    }


@transaction.atomic
def accept_invitation(token, user):
    """Apply an invitation to ``user`` and return the granted :class:`StaffRole`.

    Requires that ``user`` is already registered. Creating the account is left to
    the ordinary registration path (which sends an email OTP and enforces the
    age and terms gates) rather than reimplemented here -- one way to make an
    account, with one set of rules, is worth more than a shortcut.

    The email must match. Without that check the token alone would be a
    credential: anyone it leaked to could register a fresh address and mint
    themselves an administrator.
    """
    invitation = StaffInvitation.objects.select_for_update().filter(token=token).first()
    if invitation is None:
        raise InvitationError('This invitation link is not valid.', status_code=404)

    # Expiry is checked *before* the status word so a lapsed offer answers 410
    # ("ask for a new one") rather than 409 ("already used"), which would send
    # the reader looking for a second invitation they were never given.
    if invitation.status == 'pending' and invitation.expires_at <= timezone.now():
        invitation.mark_expired_if_stale()
        raise InvitationError(
            'This invitation has expired. Ask for a new one.', status_code=410,
        )
    if invitation.status != 'pending':
        raise InvitationError(
            f'This invitation is {invitation.status} and cannot be accepted again.',
            status_code=409,
        )

    if (user.email or '').strip().lower() != invitation.email.strip().lower():
        # Said plainly rather than as a 404: this is the one case where the
        # person holding the link needs to know the fix, which is to sign in as
        # the address the invitation was sent to.
        raise InvitationError(
            'This invitation was sent to a different email address. Sign in as '
            f'{invitation.email} to accept it.',
            status_code=403,
        )

    was_staff = user.is_staff
    if not was_staff:
        user.is_staff = True
        user.save(update_fields=['is_staff'])

    role, created = StaffRole.objects.update_or_create(
        user=user,
        defaults={
            'role': invitation.role,
            'scopes': list(invitation.scopes or []),
            'notes': (invitation.notes or '') + (
                f'\n[granted by invitation {invitation.id}]' if invitation.notes else
                f'[granted by invitation {invitation.id}]'
            ),
            'granted_by': invitation.invited_by,
            'granted_at': timezone.now(),
            'revoked_at': None,
        },
    )

    invitation.status = 'accepted'
    invitation.accepted_at = timezone.now()
    invitation.accepted_by = user
    invitation.accepted_user_email = user.email
    invitation.save(update_fields=['status', 'accepted_at', 'accepted_by', 'accepted_user_email', 'updated_at'])

    _notify(user, invitation, role, created=created, was_staff=was_staff)

    logger.info(
        'staff invitation accepted email=%s role=%s invited_by=%s',
        user.email, role.role, invitation.invited_by_email or 'system',
    )
    return role


def _notify(user, invitation, role, *, created, was_staff):
    """Tell the new staff member what they now hold.

    Uses the ``staff_role_granted`` type rather than a new one: accepting an
    invitation and being granted a role are the same event from the holder's
    side, and two types for one notification means two preferences to configure
    and two push toggles to get wrong.
    """
    from apps.notifications.tasks import create_notification

    scope_list = list(role.scopes or [])
    create_notification.delay(
        recipient_id=str(user.pk),
        notification_type='staff_role_granted',
        title=f'You now have the {role.role} role on Buddy Up',
        body=(
            f'{invitation.invited_by_email or "An administrator"} invited you and you '
            f'accepted. You can sign in to the admin console now.'
        ),
        metadata={
            'role': role.role,
            'scopes': scope_list,
            'previous_role': None if not was_staff else role.role,
            'granted_by': str(getattr(invitation.invited_by, 'pk', '') or ''),
            'via': 'staff_invitation',
        },
        dedupe_key=f'staff-invitation-accepted-{invitation.id}',
    )


def expire_lapsed_invitations():
    """Flip lapsed pending invitations to ``expired``. Returns the count.

    Exposed for a management command and a beat schedule. Correctness does not
    depend on it -- ``is_live`` is computed, not stored -- so a missed run shows
    stale rows in a list, never a grantable link.
    """
    now = timezone.now()
    return StaffInvitation.objects.filter(status='pending', expires_at__lte=now).update(
        status='expired', updated_at=now,
    )
