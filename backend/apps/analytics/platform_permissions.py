"""Staff scopes for platform analytics.

Why this app defines its own permission class
---------------------------------------------
``apps.admin_portal.permissions.ScopedPlatformAdmin`` is the right shape for
this — staff only, then one allow-listed scope — and this module reuses it for
the authorisation half. What it cannot do yet is *resolve* the two new scopes:
``ScopedPlatformAdmin`` asks ``governance.services.effective_scopes``, which
returns ``ALL_SCOPES``, and ``ALL_SCOPES`` is a frozen literal in an app this
one does not own.

So the gap is handled explicitly instead of silently:

* A superuser always passes.
* A staff user whose effective scopes include the scope passes.
* **Pending registration:** a staff user with no usable role row still passes,
  and one warning is logged naming the scopes governance must add to
  ``ALL_SCOPES``. This is the bridge that stops ``analytics.read`` from locking
  every existing operator out of a new console section on the day it ships. It
  is deliberately loud and deliberately temporary: once the entries below are in
  ``ALL_SCOPES``, the branch is unreachable and
  ``test_registered_scope_is_enforced`` pins the switchover.
* Anyone else gets the same 403 message shape the portal uses everywhere else —
  naming the missing scope and the staff role — and no information about the
  scopes themselves.

The scope strings are defined *here*, not in governance, so there is exactly one
place to read them and one entry to paste into ``ALL_SCOPES``:

    # analytics
    'analytics.read',
    'analytics.export',

Add them to ``apps/governance/models.py::ALL_SCOPES`` and to the
``DEFAULT_SCOPES_BY_ROLE`` floors that should hold them (``finance`` for both,
``support`` for ``read``). ``role='admin'`` picks up ``ALL_SCOPES``
automatically.
"""
import logging

from rest_framework.exceptions import PermissionDenied

from apps.admin_portal.permissions import IsPlatformAdmin, ScopedPlatformAdmin
from apps.governance.services import effective_scopes

logger = logging.getLogger(__name__)

#: Read the analytics sections (overview, timeseries, trending, AI quality,
#: predictive signals). No data leaves the platform.
ANALYTICS_READ_SCOPE = 'analytics.read'

#: Download a report as CSV or XLSX. Separate from ``read`` because an export
#: is the one analytics action that moves platform data off-platform, and the
#: two should be grantable to different people.
ANALYTICS_EXPORT_SCOPE = 'analytics.export'

ANALYTICS_SCOPES = (ANALYTICS_READ_SCOPE, ANALYTICS_EXPORT_SCOPE)

_warned = set()


def registered_scopes():
    """The analytics scopes ``governance.ALL_SCOPES`` already knows about.

    Read from the module (not imported by value) so a test can simulate
    governance landing the entries without monkeypatching a frozenset in three
    places.
    """
    from apps.governance import models as governance_models
    return {scope for scope in ANALYTICS_SCOPES if scope in governance_models.ALL_SCOPES}


class IsAnalyticsStaff(ScopedPlatformAdmin):
    """``is_staff`` plus one declared analytics scope.

    ``IsPlatformAdmin`` is DRF's ``IsAdminUser``, so the 401/403 split is
    inherited: anonymous gets 401, authenticated non-staff gets 403, and neither
    leaks scope detail.
    """

    required_scope = None

    def __init__(self, scope=None):
        super().__init__()
        self.scope = scope or self.required_scope
        if not self.scope:
            raise ValueError(
                'IsAnalyticsStaff requires a scope. Use '
                "IsAnalyticsStaff.for_scope(ANALYTICS_READ_SCOPE) or pass scope=."
            )

    @classmethod
    def for_scope(cls, scope):
        if not scope or not isinstance(scope, str):
            raise ValueError(f'Scope must be a non-empty string, got {scope!r}.')
        return type(f'{cls.__name__}[{scope}]', (cls,), {'required_scope': scope})

    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        user = request.user
        if getattr(user, 'is_superuser', False):
            return True

        scopes = effective_scopes(user)
        if self.scope in scopes:
            return True

        if self.scope not in registered_scopes():
            # Governance has not landed the scope yet. Rather than 403 every
            # operator on a route that shipped today, allow staff and say so
            # once per process.
            if self.scope not in _warned:
                _warned.add(self.scope)
                logger.warning(
                    'analytics_scope_unregistered scope=%s — add it to '
                    'apps.governance.models.ALL_SCOPES; until then any staff '
                    'member reaches this route',
                    self.scope,
                )
            return True

        raise PermissionDenied(
            f'Your staff role ({_role_label(user)}) does not include the '
            f'{self.scope!r} scope, so this action is not available to you. '
            f'Ask an administrator to grant it, or use a different route.'
        )


def _role_label(user):
    row = getattr(user, 'staff_role', None)
    if row is None:
        return 'none'
    if getattr(row, 'revoked_at', None) is not None:
        return f'{row.role} (revoked)'
    return row.role


class CanReadAnalytics(IsAnalyticsStaff):
    """Convenience alias bound to ``analytics.read``."""

    required_scope = ANALYTICS_READ_SCOPE


class CanExportAnalytics(IsAnalyticsStaff):
    """Convenience alias bound to ``analytics.export``.

    Export views declare this *only*. It is not a superset of ``read`` on
    purpose: someone who may export may also read, so granting only the export
    scope must be enough — otherwise every export route would need both scopes
    and the distinction between them would be theatre.
    """

    required_scope = ANALYTICS_EXPORT_SCOPE