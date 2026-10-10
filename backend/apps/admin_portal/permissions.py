"""Staff-only permissions for the admin portal.

``IsPlatformAdmin`` is unchanged: any ``is_staff`` user.

``ScopedPlatformAdmin`` *enforces* the scope its route declares. The scope used
to be metadata — declared on 27 routes and read by nothing — which meant a
support agent with no business touching payouts could do exactly that. It is now
an allow-list check, resolved by ``apps.governance.services`` rather than
reimplemented here.

Three ways a caller gets through:

* ``is_superuser`` — always. The platform owner is never narrowed by a role row.
* Holds a ``governance.StaffRole`` — allowed on the routes whose scope is in
  ``effective_scopes(user)``, everything else 403 with the missing scope and the
  role named so the operator can ask for it.
* Staff with *no* ``StaffRole`` row — allowed everywhere, which is the
  pre-governance behaviour. See the back-compat branch in
  ``governance.services.effective_scopes``; it exists so landing this app does
  not lock the existing operator out of the console.
"""
from rest_framework import permissions
from rest_framework.exceptions import PermissionDenied

from apps.governance.services import effective_scopes


class IsPlatformAdmin(permissions.IsAdminUser):
    """Any active staff user.

    Thin alias over DRF's ``IsAdminUser`` so the portal has one name to grep
    for. Behaviour is identical: authenticated + ``is_staff``. Anonymous callers
    get 401, authenticated non-staff get 403.

    ``is_active`` is deliberately *not* re-checked here. ``IsAdminUser`` does not
    test it, and duplicating that check here would diverge from the other
    staff-only apps (moderation, verification, the ML dashboard). It is already
    enforced one layer down: Django's auth backend refuses to authenticate an
    inactive account, so a suspended staff member cannot obtain or use a token.
    """


class ScopedPlatformAdmin(IsPlatformAdmin):
    """``IsPlatformAdmin`` restricted to one declared scope, e.g. ``'users.write'``.

    Usage::

        permission_classes = [ScopedPlatformAdmin.for_scope('orders.write')]

    ``for_scope`` returns a subclass carrying the scope, because DRF
    instantiates permission classes with no arguments.

    The check runs *after* :class:`IsPlatformAdmin`, so an anonymous caller
    still gets 401 and a non-staff caller still gets 403 with no scope detail
    leaked — a user who cannot staff the console learns nothing about what the
    scopes are.
    """

    required_scope = None

    def __init__(self, scope=None):
        super().__init__()
        self.scope = scope or self.required_scope
        if not self.scope:
            raise ValueError(
                'ScopedPlatformAdmin requires a scope. Declare it with '
                "ScopedPlatformAdmin.for_scope('domain.action') or pass scope= to __init__."
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

        raise PermissionDenied(
            f'Your staff role ({_role_label(user)}) does not include the '
            f'{self.scope!r} scope, so this action is not available to you. '
            f'Ask an administrator to grant it, or use a different route.'
        )


def _role_label(user):
    """The role name for a 403 message, or a description of the status quo.

    Never raises and never returns a bare id — the message is read by a human
    deciding whether to escalate.
    """
    row = getattr(user, 'staff_role', None)
    if row is None:
        return 'none'
    if getattr(row, 'revoked_at', None) is not None:
        return f'{row.role} (revoked)'
    return row.role
