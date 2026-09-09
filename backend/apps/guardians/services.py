import hashlib

from apps.guardians.models import GuardianLink


def _as_user(value):
    """Normalise a User or Profile argument to the underlying User."""
    if value is None:
        return None
    if hasattr(value, 'is_adult'):
        return value
    return getattr(value, 'user', None)


def hash_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode()).hexdigest()


def is_minor(user) -> bool:
    resolved = _as_user(user)
    return resolved is not None and not resolved.is_adult


def active_link_for_teen(user):
    """The ACTIVE GuardianLink where the user is the teen, or None."""
    resolved = _as_user(user)
    if resolved is None:
        return None
    return (
        GuardianLink.objects
        .filter(teen=resolved, status='active')
        .select_related('guardian', 'teen')
        .first()
    )


def guardian_blocks_spends(user) -> bool:
    if not is_minor(user):
        return False
    link = active_link_for_teen(user)
    return link is not None and link.permissions.get('allow_spends') is False


def guardian_blocks_new_dms(user) -> bool:
    if not is_minor(user):
        return False
    link = active_link_for_teen(user)
    return link is not None and link.permissions.get('allow_direct_messages') is False


def guardian_display_name(user) -> str:
    resolved = _as_user(user)
    if resolved is None:
        return 'Your guardian'
    try:
        display_name = resolved.profile.display_name
    except Exception:  # noqa: BLE001 — profile may not exist yet
        display_name = ''
    return display_name or (resolved.email or 'Your guardian').split('@')[0]
