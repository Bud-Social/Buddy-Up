"""Scope resolution — the single source of truth for staff authorisation.

Both helpers are deliberately total: they answer for *any* user object,
including ``None`` and ``AnonymousUser``, because they are called from a DRF
permission class before the view has done anything else and a ``TypeError``
here would be a 500 on an auth check.

:func:`effective_scopes` is what ``apps.admin_portal.permissions`` calls. It is
not reimplemented there — one implementation, one place to audit.
"""
from .models import ALL_SCOPES, DEFAULT_SCOPES_BY_ROLE, StaffRole


def _is_staff(user):
    return bool(
        user is not None
        and getattr(user, 'is_authenticated', False)
        and getattr(user, 'is_staff', False)
    )


def _stored_scopes(row):
    """The row's ``scopes`` list, defensively.

    ``scopes`` is a JSONField with no schema, so a hand-edited row or a bad
    write can hold anything. Anything unhashable or non-string is dropped rather
    than allowed to raise inside a permission check.
    """
    raw = getattr(row, 'scopes', None) or []
    if not isinstance(raw, (list, tuple, set)):
        return set()
    return {s for s in raw if isinstance(s, str) and s}


def effective_scopes(user):
    """The set of scope strings ``user`` may exercise. Never raises.

    Resolution order:

    1. Not staff (including ``None`` / anonymous) -> empty set. A non-staff user
       is rejected by ``IsAdminUser`` before scopes matter; returning empty
       here keeps this helper safe to call on its own.
    2. ``is_superuser`` -> every scope in ``ALL_SCOPES``. A superuser is the
       platform owner and is not narrowed by a role row.
    3. An active ``StaffRole`` row -> ``DEFAULT_SCOPES_BY_ROLE[role] | scopes``.
    4. A revoked ``StaffRole`` row -> empty set. Revocation must *remove*
       access, so it deliberately does not fall through to branch 5.
    5. Staff with no ``StaffRole`` row -> every scope in ``ALL_SCOPES``.

    Branch 5 is the back-compat concession and the only place this app grants
    anything implicitly. This app is new, the portal's scopes were inert
    metadata until now, and the deployment has existing staff who would be
    locked out of the console the moment it lands. It is a migration path, not
    the steady state: once every operator has a row, deleting the branch is the
    only change needed to make scoping universal.

    A revoked row returning empty (branch 4) is why branch 5 is keyed on the
    *absence of a row* rather than on "no usable scopes" — otherwise revoking
    the only role a person has would silently promote them to full access.
    """
    if not _is_staff(user):
        return set()

    if getattr(user, 'is_superuser', False):
        return set(ALL_SCOPES)

    row = getattr(user, 'staff_role', None)
    if row is None:
        # OneToOne raises RelatedObjectDoesNotExist on the descriptor, which
        # getattr() surfaces as None for the default — correct, but read the
        # row explicitly so a revoked row is distinguishable from a missing one.
        try:
            row = StaffRole.objects.filter(user=user).first()
        except Exception:
            # The table may not exist yet (a fresh migrate mid-deploy). Falling
            # back to the permissive branch keeps the console reachable.
            row = None

    if row is None:
        return set(ALL_SCOPES)

    if row.revoked_at is not None:
        return set()

    defaults = DEFAULT_SCOPES_BY_ROLE.get(row.role, set())
    return set(defaults) | _stored_scopes(row)


def has_scope(user, scope):
    """True if ``user`` may exercise ``scope``. Never raises."""
    if not scope:
        return False
    return scope in effective_scopes(user)


def is_unscoped_backfill(user):
    """True for a staff user relying on the branch-5 back-compat concession.

    Exposed for the approvals API and the tests: it is the difference between
    "this person has not been through role assignment yet" and "this person is
    deliberately unrestricted". Worth reporting on, because the second is a
    standing audit finding.
    """
    if not _is_staff(user) or getattr(user, 'is_superuser', False):
        return False
    try:
        return not StaffRole.objects.filter(user=user).exists()
    except Exception:
        return False
