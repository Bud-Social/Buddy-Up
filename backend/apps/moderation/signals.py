"""Cross-app signal receivers owned by moderation.

There is exactly one: when a governance ``AccountActionRequest`` for a ban or
suspension that *moderation raised* is approved and applied, moderation
finishes the job.

Why this is needed, given governance already applies the effect:
``apps.governance.views.ApprovalApproveView._apply`` calls
``apply_standing_action`` — so the account is genuinely suspended — and then
stops. It does not know a ``ModerationAction`` row exists, does not notify the
user, and leaves the moderation queue showing a request that will never be
noticed. The user finds out at their next login, when the app refuses them and
tells them nothing about why. That is the exact "decorative moderation" failure
this work exists to close.

The link is ``payload.moderation_action_id``, written by
``services.request_standing_action`` into the free-form ``payload`` dict. No
column is added to another app's model and no governance file is edited.

Ordering note: governance saves ``applied_at`` *after* ``_apply`` has already run,
inside one transaction. So by the time this receiver sees the save, the standing
is in place and a failure here cannot leave an approval that claims to have
applied something it did not.
"""
import logging

from django.db.models.signals import post_save
from django.dispatch import receiver

logger = logging.getLogger(__name__)


@receiver(post_save, sender='governance.AccountActionRequest', dispatch_uid='moderation.account_action_request_saved')
def on_account_action_request_saved(sender, instance, created, **kwargs):
    """Finish a moderation-raised ban/suspension once it is approved.

    No-ops on creation, on non-approved requests, on requests moderation did not
    raise, and on re-saves that carry no new decision.
    """
    if created or instance.status != 'approved' or instance.applied_at is None:
        return

    payload = instance.payload or {}
    moderation_action_id = payload.get('moderation_action_id')
    if not moderation_action_id:
        return

    if instance.action not in ('ban', 'suspension'):
        return

    from apps.moderation.models import ModerationAction
    from apps.moderation.services import apply_standing_action_for_row, notify_action_taken

    try:
        action_row = ModerationAction.objects.select_related('target_user').get(
            pk=moderation_action_id,
        )
    except (ModerationAction.DoesNotExist, ValueError, TypeError):
        logger.warning(
            'Governance approval %s references moderation action %s, which does '
            'not exist. The account standing is unchanged by moderation.',
            instance.pk, moderation_action_id,
        )
        return

    if action_row.is_reversed:
        return

    try:
        # Normally a no-op: governance applied the standing itself and the
        # provenance guard returns early. It matters when the effect has not
        # landed — a partially-migrated row, or a future approval path that
        # records the decision without calling accounts.services.
        apply_standing_action_for_row(action_row, actor=instance.decided_by, approval=instance)
    except Exception:  # noqa: BLE001
        logger.exception(
            'Could not apply the standing for moderation action %s on approval %s',
            action_row.id, instance.pk,
        )
        return

    # The user notification. Deliberately after the effect: a ban notice that
    # arrives before the ban is live tells the user to appeal something that
    # has not happened yet.
    try:
        notify_action_taken(action_row)
    except Exception:  # noqa: BLE001
        logger.exception('Could not notify user %s of moderation action %s',
                         action_row.target_user_id, action_row.id)