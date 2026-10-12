"""Scope resolution and the audit writer.

Two concerns, one module, because they are two halves of the same question:
*may* this staff member do it, and *did* they?

:func:`effective_scopes` is what ``apps.admin_portal.permissions`` calls. It is
not reimplemented there — one implementation, one place to audit.

The scope helpers are deliberately total: they answer for *any* user object,
including ``None`` and ``AnonymousUser``, because they are called from a DRF
permission class before the view has done anything else and a ``TypeError``
here would be a 500 on an auth check.
"""
import logging

from .models import ALL_SCOPES, DEFAULT_SCOPES_BY_ROLE, AdminActionLog, StaffRole

logger = logging.getLogger(__name__)


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


# ---------------------------------------------------------------------------
# The audit writer
# ---------------------------------------------------------------------------

# Field names whose values are never written to AdminActionLog.before/after.
#
# Matched on the *key*, case-insensitively and after stripping anything that is
# not a letter or a digit, so ``refresh_token``, ``refreshToken`` and
# ``Refresh-Token`` all hit the same entry. Matching on the key rather than the
# value is deliberate: a secret cannot be recognised as a secret by looking at
# it, and a heuristic that guessed "this looks like a credential" would be wrong
# often enough to be worse than a blunt rule.
#
# This mirrors the privacy contract on ``analytics.AnalyticsEvent`` — no message
# bodies, no credentials or tokens, no TOTP secrets, no raw GPS. Add to this set
# rather than trusting a caller not to pass it: the caller writing the audit row
# is exactly the code under review when something goes wrong.
SENSITIVE_AUDIT_KEYS = frozenset({
    # Secrets and credentials.
    'password', 'newpassword', 'oldpassword', 'passwd', 'passwordhash',
    'token', 'accesstoken', 'refreshtoken', 'idtoken', 'jwt', 'authorization',
    'apikey', 'apisecret', 'secret', 'secretkey', 'clientsecret',
    'credential', 'credentials', 'privatekey', 'signingkey',
    # One-time codes and second factors.
    'otp', 'otpcode', 'otpsecret', 'code', 'totpsecret', 'totpcode', 'pin',
    # Message and post bodies. `body` is the giveaway: nothing that legitimately
    # belongs in a state delta is called "body".
    'body', 'message', 'messagebody', 'text', 'content', 'html', 'plain',
    'commentbody', 'postbody', 'emailbody', 'preview', 'note', 'notes',
    # Raw GPS. Coordinates are not audit data and are personal location data.
    'latitude', 'longitude', 'lat', 'lng', 'lon', 'gps', 'gpscoordinates',
    'gps_track', 'coords', 'coordinates', 'geopoint', 'location',
    'locationlatlng', 'locationcoordinates',
})

# Depth and breadth caps, so a hook that hands over a whole queryset's worth of
# nested dicts cannot quietly write a 400KB JSON blob into every audit row.
_AUDIT_MAX_DEPTH = 4
_AUDIT_MAX_LIST_ITEMS = 50

# Anything longer than this in a JSON value is truncated rather than stored.
# The value is a state delta (a role, a status), not a document.
_AUDIT_MAX_VALUE_CHARS = 500

_REDACTED = '[redacted]'


def _audit_key(name):
    return ''.join(c for c in str(name).lower() if c.isalnum())


def _scrub(value, depth=0):
    """Return a JSON-safe copy of ``value`` with sensitive keys replaced.

    Never raises and never recurses without bound. Unknown types become their
    ``str()``, because a UUID or a ``datetime`` in a state delta is fine but
    would blow up at ``json.dumps`` inside the ORM on the way to Postgres.
    """
    if depth >= _AUDIT_MAX_DEPTH:
        return _REDACTED if isinstance(value, (dict, list, tuple, set)) else value

    if isinstance(value, dict):
        return {
            str(key): (
                _REDACTED if _audit_key(key) in SENSITIVE_AUDIT_KEYS else _scrub(item, depth + 1)
            )
            for key, item in value.items()
        }

    if isinstance(value, (list, tuple, set)):
        return [_scrub(item, depth + 1) for item in list(value)[:_AUDIT_MAX_LIST_ITEMS]]

    if value is None or isinstance(value, (bool, int, float, str)):
        if isinstance(value, str) and len(value) > _AUDIT_MAX_VALUE_CHARS:
            return value[:_AUDIT_MAX_VALUE_CHARS] + '…'
        return value

    return _scrub(str(value), depth + 1)


def _client_ip(request):
    """The caller's IP for the audit row, or None.

    ``X-Forwarded-For`` is client-controlled unless the immediate peer is a
    trusted proxy, so it is only read when ``REMOTE_ADDR`` is listed in
    ``TRUSTED_PROXY_IPS``. Same rule as ``apps.accounts.views._get_client_ip`` —
    a forged header in an audit row is worse than no header.

    An unparseable value returns None rather than raising: a bad
    ``REMOTE_ADDR`` must not cost us the audit row itself.
    """
    import os

    from django.core.exceptions import ValidationError
    from django.core.validators import validate_ipv46_address

    if request is None:
        return None
    meta = getattr(request, 'META', None)
    if not isinstance(meta, dict):
        return None

    remote_addr = (meta.get('REMOTE_ADDR') or '').strip()
    trusted = {
        value.strip()
        for value in os.environ.get('TRUSTED_PROXY_IPS', '').split(',')
        if value.strip()
    }
    forwarded = (meta.get('HTTP_X_FORWARDED_FOR') or '').strip()
    candidate = forwarded.split(',')[0].strip() if (forwarded and remote_addr in trusted) else remote_addr

    if not candidate:
        return None
    # Strip a ``host:port`` suffix and IPv6 brackets; REMOTE_ADDR is bare but
    # a proxy or test harness may not be.
    if candidate.startswith('['):
        candidate = candidate[1:candidate.find(']')] if ']' in candidate else candidate[1:]
    elif candidate.count(':') == 1:
        candidate = candidate.split(':', 1)[0]

    try:
        validate_ipv46_address(candidate)
    except ValidationError:
        return None
    return candidate


def record_admin_action(
    *,
    actor=None,
    action,
    summary,
    target_type='',
    target_id='',
    before=None,
    after=None,
    request=None,
):
    """Append one :class:`~apps.governance.models.AdminActionLog` row.

    This is the only supported way to write to the audit trail. It is
    deliberately cheap and total: cheap because it is called from hot paths and
    from every mutating portal request, total because a staff action that
    applied but crashed the request that reported it is exactly the kind of
    thing an audit trail exists to catch.

    ``actor``, ``actor_email``, ``request_id``, ``ip_address`` and
    ``user_agent`` are all derived — the caller supplies the *facts* of the
    action, not the request metadata, so no call site can forget it.

    ``request_id`` comes from ``RequestIdMiddleware``, which stamps
    ``request.request_id`` and echoes it as ``X-Request-ID``. That is the join
    key from an audit row to the request log, and to an operator's complaint.

    ``before`` / ``after`` are scrubbed by key name against
    :data:`SENSITIVE_AUDIT_KEYS` before they reach the database. See
    :class:`~apps.governance.models.AdminActionLog` for the privacy contract
    this upholds.

    Returns the saved row, or ``None`` if the write itself failed. The failure
    is logged with a traceback and swallowed on purpose: the alternative is a
    500 on a mutation that already applied, which is a worse outcome than a
    known gap in the trail.
    """
    try:
        return AdminActionLog.objects.create(
            actor=actor if getattr(actor, 'is_authenticated', False) else None,
            # Snapshot, so the row survives the actor's account being deleted.
            actor_email=str(getattr(actor, 'email', '') or '')[:254],
            action=str(action or '')[:80],
            target_type=str(target_type or '')[:50],
            target_id=str(target_id or '')[:64],
            summary=str(summary or '')[:300],
            before=_scrub(before) if before is not None else None,
            after=_scrub(after) if after is not None else None,
            request_id=str(getattr(request, 'request_id', '') or '')[:64],
            ip_address=_client_ip(request),
            user_agent=str(getattr(request, 'META', {}).get('HTTP_USER_AGENT', '') or '')[:300],
        )
    except Exception:  # noqa: BLE001 — an audit gap must not 500 a real mutation
        logger.exception(
            'admin_audit_write_failed action=%s actor=%s target=%s:%s',
            action, getattr(actor, 'pk', None), target_type, target_id,
        )
        return None
