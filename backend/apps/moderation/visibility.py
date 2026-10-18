"""The one question every read path asks about a takedown.

A takedown is a visibility state, not a deletion (see ``ContentTakedown``). Every
list and detail endpoint therefore needs the same three-way answer:

- **staff** -- may see everything, in full, so moderation can judge what it acted
  on. Without this a moderator cannot review the content they just hid.
- **the creator** -- sees their own content, still removed, so they can read why
  and appeal it. Hiding it from the person who has to appeal it is the failure
  mode here.
- **everyone else** -- sees a tombstone, never the content.

Before this module the answer was scattered and mostly wrong: ``feed.post`` hid
from *everyone* including staff and the author, while ``UserPostsView`` did not
hide it from anyone -- a moderated post was still served in full, body and media,
on the author's public profile.

Content lives in six apps that cannot import each other safely at model import
time, so this is deliberately a plain function over strings rather than a
registry of per-model classes. The handler registry in ``takedown`` does the
mutating side; this does the reading side, and it only ever needs the identity
of the viewer and of the creator.
"""

from django.utils import timezone

#: What a viewer is allowed to see.
VIS_FULL = 'full'          # the real content
VIS_TOMBSTONE = 'tombstone'  # "taken down" placeholder, no content
VIS_HIDDEN = 'hidden'      # nothing at all -- 404


def is_staff_viewer(user):
    """Staff see content in full so they can moderate and audit it."""
    return bool(user and getattr(user, 'is_authenticated', False) and user.is_staff)


def _profile_of(user):
    """The Profile for a user, without raising if it does not exist yet.

    ``Profile`` is keyed by a OneToOne to the user, so ``user.profile`` is the
    attribute -- but it is a reverse accessor, so a request from a user without
    one would raise rather than return None.
    """
    return getattr(user, 'profile', None)


def visibility_for(*, viewer=None, creator=None, takedown):
    """Resolve what ``viewer`` may see of content owned by ``creator``.

    Returns one of ``VIS_FULL`` / ``VIS_TOMBSTONE`` / ``VIS_HIDDEN``.
    """
    if takedown is None or not takedown.is_active:
        return VIS_FULL

    if is_staff_viewer(viewer):
        return VIS_FULL

    viewer_profile = _profile_of(viewer)
    if viewer_profile is not None and takedown.creator_id is not None:
        if str(takedown.creator_id) == str(viewer_profile.pk):
            return VIS_FULL

    # Anyone else still gets the tombstone: they need to know the post is there
    # and that it was moderated, not have it silently vanish. Returning HIDDEN
    # is reserved for surfaces that have no way to render a placeholder.
    return VIS_TOMBSTONE


def creator_sees_removed(viewer, creator):
    """True when ``viewer`` owns ``creator``'s content and may see it still.

    Content that a takedown has removed is hidden from feeds with a
    ``moderation_status='clean'`` style filter -- which also hides it from its
    author. Authors must keep seeing their own removed content: they cannot
    appeal, or understand a decision, against something that is invisible.
    """
    viewer_profile = _profile_of(viewer)
    if viewer_profile is None or creator is None:
        return False
    return str(getattr(viewer_profile, 'pk', '')) == str(getattr(creator, 'pk', ''))


def active_takedown_qs():
    """Base queryset of takedowns currently in force."""
    from apps.moderation.models import ContentTakedown

    return ContentTakedown.objects.filter(lifted_at__isnull=True, purged_at__isnull=True)


def takedown_map(content_type, content_ids):
    """Fetch the standing takedowns for many objects at once.

    Read paths that list dozens of rows must not issue a query per row, so the
    call sites take a ``content_type`` and an iterable of ids and get back a dict
    keyed by the stringified id.
    """
    ids = [str(i) for i in content_ids if i]
    if not ids:
        return {}
    rows = active_takedown_qs().filter(content_type=content_type, content_id__in=ids)
    return {row.content_id: row for row in rows}


def _appeal_days_remaining(takedown):
    """Whole days left to appeal, floored at zero."""
    if takedown.purge_after is None:
        return None
    return max(0, (takedown.purge_after - timezone.now()).days)


def tombstone_payload(takedown):
    """The public shape of a taken-down object.

    Deliberately carries no content: only that it was taken down, when, why, and
    how long an appeal is still open. The moderator's identity lives on the
    ``ModerationAction`` row, which is staff-only.
    """
    if takedown is None or not takedown.is_active:
        return None
    return {
        'taken_down': True,
        'reason': takedown.reason,
        'note': takedown.public_note,
        'taken_down_at': takedown.taken_down_at,
        'purge_after': takedown.purge_after,
        'appeal_window_days': _appeal_days_remaining(takedown),
    }
