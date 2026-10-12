"""``GovernanceAuditMixin`` — blanket audit coverage for a DRF view.

The audit trail is only useful if it is *complete*. A table that records the
handful of actions somebody remembered to instrument answers "what did staff do
on Tuesday" with "the three things we thought to log", which is worse than no
answer because it is trusted. So coverage is structural, not voluntary: mix
this in and every mutating request that succeeds is recorded, whether or not
whoever wrote the view thought about auditing it.

Adopting it is one line per view::

    class UserSuspendView(GovernanceAuditMixin, PortalView):
        audit_action = 'users.suspend'

Optional, when the defaults are not enough:

``audit_action``
    The dotted verb. Required in practice; see
    :meth:`GovernanceAuditMixin._resolve_action` for the fallbacks.
``audit_target_type`` / ``audit_target_id``
    Constants, or ``audit_target_id_param`` (default ``'pk'``) to read the id
    out of the URL kwargs.
``audit_summary(request, response)``
    Callable returning the one-line human summary. Defaults to
    ``"<verb> <method> <path>"`` — accurate but dull; override it wherever the
    view can say what actually changed.
``audit_before(request, response)`` / ``audit_after(request, response)``
    Callables returning the state delta. Scrubbed by
    :func:`apps.governance.services.record_admin_action` before storage.

What it records, and what it deliberately does not:

* Only successful requests. A 4xx never changed anything, so logging it would
  bury the real events in noise; a 5xx may have changed something, but that is
  a crash the error handler already reports, and guessing at partial state is
  worse than recording nothing.
* Only non-GET. A ``GET`` is a read. Reading the audit trail does not grow it.
* Only staff. An anonymous or non-staff caller cannot reach these views at all —
  ``ScopedPlatformAdmin`` has already 401'd or 403'd — and if one somehow did,
  the row it produced would be an unattributed action, which is noise.

The mixin writes through :func:`record_admin_action`, so the privacy contract on
``before``/``after`` holds here exactly as it does everywhere else.

Mixin ordering: put this **first** in the bases, as in the example above. It is
written to work in either position, but first is the DRF convention and the one
that keeps working if a view later adds a mixin that also wraps
``finalize_response``.
"""
import logging

from rest_framework.permissions import SAFE_METHODS

from .services import record_admin_action

logger = logging.getLogger(__name__)


class GovernanceAuditMixin:
    """Record an :class:`~apps.governance.models.AdminActionLog` row per mutation."""

    # -- declare these on the view ------------------------------------------

    audit_action = None
    audit_target_type = ''
    audit_target_id_param = 'pk'
    audit_target_id = None

    # -- or override these ---------------------------------------------------

    def audit_summary(self, request, response):
        return f'{self._resolve_action(request)} {request.method} {request.path}'[:300]

    def audit_before(self, request, response):
        return None

    def audit_after(self, request, response):
        return None

    def audit_target(self, request, response):
        """``(target_type, target_id)`` for the row. Defaults to the class attrs."""
        target_id = self.audit_target_id
        if target_id is None and self.audit_target_id_param:
            target_id = (getattr(request, 'parser_context', None) or {}).get(
                'kwargs', {}
            ).get(self.audit_target_id_param)
        return self.audit_target_type, str(target_id or '')[:64]

    # -- plumbing ------------------------------------------------------------

    def _resolve_action(self, request):
        """The dotted verb for this request.

        Falls back to ``<audit_prefix>.<url_name>`` and then to
        ``<path-derived>`` rather than raising, so a view that forgets
        ``audit_action`` still produces a row — a coarsely-named one is worth
        far more than a 500 on a mutation that already applied. A view that
        forgets it should be noticed in review; the mixin making that failure
        loud at request time would be worse.
        """
        if self.audit_action:
            return str(self.audit_action)[:80]

        prefix = getattr(self, 'audit_prefix', None)
        url_name = ''
        match = getattr(request, 'resolver_match', None)
        if match is not None:
            url_name = match.url_name or ''

        if prefix and url_name:
            verb = f'{prefix}.{url_name}'.lower()
            parts = [p for p in verb.replace('-', '_').split('.') if p]
            if parts and all(p.replace('_', '').isalnum() for p in parts):
                return '.'.join(parts)[:80]

        path = str(getattr(request, 'path', '') or '').strip('/').replace('/', '.')
        return (path or request.method.lower())[:80]

    def _should_audit(self, request, response):
        if request.method in SAFE_METHODS:
            return False
        status_code = getattr(response, 'status_code', 0) or 0
        if status_code >= 400:
            return False
        user = getattr(request, 'user', None)
        return bool(getattr(user, 'is_authenticated', False) and getattr(user, 'is_staff', False))

    def finalize_response(self, request, response, *args, **kwargs):
        response = super().finalize_response(request, response, *args, **kwargs)
        if self._should_audit(request, response):
            try:
                target_type, target_id = self.audit_target(request, response)
                record_admin_action(
                    actor=request.user,
                    action=self._resolve_action(request),
                    summary=self.audit_summary(request, response),
                    target_type=target_type,
                    target_id=target_id,
                    before=self.audit_before(request, response),
                    after=self.audit_after(request, response),
                    request=request,
                )
            except Exception:  # noqa: BLE001 — never 500 a mutation that applied
                # record_admin_action already swallows its own write failures;
                # this covers a hook on the view raising.
                logger.exception(
                    'admin_audit_hook_failed view=%s path=%s',
                    type(self).__name__, getattr(request, 'path', ''),
                )
        return response