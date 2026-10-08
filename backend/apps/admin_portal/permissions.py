"""Staff-only permissions for the admin portal.

Admin capability on this platform is modelled *only* by Django's
``is_staff`` / ``is_superuser`` (accounts/models.py). There are no permission
groups in use and no per-domain role table, so these classes deliberately do
not invent one: ``ScopedPlatformAdmin`` records which domain a route touches
and authorises exactly like ``IsAdminUser`` does today.
"""
from rest_framework import permissions


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
    """``IsPlatformAdmin`` with a recorded scope, e.g. ``'users.write'``.

    The scope is *metadata only*. Nothing reads it to grant or deny anything
    today — authorisation is exactly ``IsAdminUser``. It exists so every route
    in ``urls.py`` declares the domain it can mutate, which is what a future
    per-domain grant would key off. Adding the check later is a one-line
    change here rather than an audit of the URL table.

    Usage::

        permission_classes = [ScopedPlatformAdmin.for_scope('orders.write')]

    ``for_scope`` returns a subclass carrying the scope, because DRF
    instantiates permission classes with no arguments.
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
