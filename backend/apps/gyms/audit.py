"""Helper to record a GymActionLog row.

Never throws; an audit write must never make a successful mutation look
failed. Returns the row or None.
"""

from .models import GymActionLog


def log_gym_action(*, gym, actor=None, action, summary, target_type='',
                   target_id='', before=None, after=None):
    try:
        actor_instance = actor if getattr(actor, 'pk', None) else None
        return GymActionLog.objects.create(
            gym=gym,
            actor=actor_instance,
            actor_username=getattr(actor_instance, 'username', '') or '',
            action=action,
            summary=str(summary)[:500],
            target_type=target_type,
            target_id=str(target_id) if target_id is not None else '',
            before=before,
            after=after,
        )
    except Exception:
        return None
