"""Reusable block-check helpers for messaging.

`is_blocked_pair` is the single source of truth for "these two profiles must
not interact", symmetric in direction: a block in either direction counts.

apps/profiles owns the block create/delete endpoints (BlockUserView). It should
import `is_blocked_pair` from here rather than re-implementing the Q filter, so
block enforcement stays consistent across apps.
"""
from django.db.models import Q


def is_blocked_pair(a, b) -> bool:
    """Return True when either `a` or `b` has blocked the other."""
    if a is None or b is None:
        return False
    if getattr(a, 'pk', None) is None or getattr(b, 'pk', None) is None:
        return False
    if a.pk == b.pk:
        return False

    from apps.profiles.models import BlockRelationship

    return BlockRelationship.objects.filter(
        Q(blocker=a, blocked=b) | Q(blocker=b, blocked=a),
    ).exists()


def any_blocked_with_others(profile_id, other_ids) -> bool:
    """Bulk variant of is_blocked_pair for known profile ids (one query)."""
    from apps.profiles.models import BlockRelationship

    other_ids = [oid for oid in other_ids if oid != profile_id]
    if not profile_id or not other_ids:
        return False
    return BlockRelationship.objects.filter(
        Q(blocker_id=profile_id, blocked_id__in=other_ids)
        | Q(blocker_id__in=other_ids, blocked_id=profile_id),
    ).exists()


def other_participant(conversation, profile):
    """Return the single other participant of a 2-person conversation, else None."""
    participants = list(conversation.participants.all())
    others = [p for p in participants if p.pk != getattr(profile, 'pk', None)]
    if len(participants) != 2 or len(others) != 1:
        return None
    return others[0]


def is_conversation_blocked(conversation, profile) -> bool:
    """Return True when `profile` is blocked by, or is blocking, the DM partner.

    Group/community conversations have no single counterpart and are unaffected.
    """
    other = other_participant(conversation, profile)
    if other is None:
        return False
    return is_blocked_pair(profile, other)
