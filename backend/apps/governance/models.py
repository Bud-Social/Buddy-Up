"""Staff roles and two-person approvals.

This app owns the two tables that make ``ScopedPlatformAdmin``'s ``scope``
string *mean* something, plus the request queue for the handful of actions that
must never be applied by the person who asked for them.

Two models, no more:

* :class:`StaffRole` — one row per staff user holding a role and its scopes.
* :class:`AccountActionRequest` — a high-risk action waiting for a second pair
  of eyes.

Why one role per user (:class:`StaffRole` is a ``OneToOne``, not a
``StaffRoleGrant`` join table):

* The live DB has exactly one staff user and zero permission groups. A second
  table would be an unexercised abstraction bought at the cost of an extra
  query on every authorisation check — and authorisation runs on all 27 portal
  routes, so that query is the hot path.
* Every role in ``DEFAULT_SCOPES_BY_ROLE`` is a *job*, not a permission bundle
  a person accumulates. Nobody is "half finance, half logistics" here; if the
  shape is ever needed, ``scopes`` on the row already expresses the union
  without a second table.
* ``scopes`` is the escape hatch. ``role`` sets the floor via
  ``DEFAULT_SCOPES_BY_ROLE``, and the stored list adds to it. Adding a scope
  to a person is a column write, not a row insert, so the common case needs no
  schema change.

Effective scopes
----------------
A role's effective scopes are ``DEFAULT_SCOPES_BY_ROLE[role] | set(row.scopes)``
— the defaults are a floor the role definition owns, the stored list is a
per-person override on top. ``DEFAULT_SCOPES_BY_ROLE[role]`` can therefore never
be *narrowed* by deleting from ``scopes``; to narrow a role you change the
mapping in code, which is reviewable.

Back-compat branch
------------------
A staff user with **no** ``StaffRole`` row keeps unrestricted access — see
:func:`apps.governance.services.effective_scopes`. This app is new; the portal's
scopes were metadata only until now, and locking out the existing operator
because nobody had filled in a table yet would break the console on deploy.
Such a user is treated as holding every scope. ``is_superuser`` bypasses the
check outright.
"""
from uuid import uuid4

from django.conf import settings
from django.db import models
from django.utils import timezone

from common.models import TimestampedModel

# ---------------------------------------------------------------------------
# Scopes
# ---------------------------------------------------------------------------

# Every scope string that is actually declared on a portal route, collected from
# the ``ScopedPlatformAdmin.for_scope(...)`` calls in apps/admin_portal/views.py.
#
# Kept as a frozen literal on purpose: it is the back-compat allow-list for
# role-less staff and the value ``role='admin'`` expands to, so it must not be
# computed from the URL table at import time (a typo in one route would silently
# become a privilege). ``apps.admin_portal.tests.ScopeCoverageTests`` fails if a
# route declares a scope missing from here.
ALL_SCOPES = frozenset({
    # Users
    'users',
    'users.read',
    'users.write',
    # Shops & certification
    'shops',
    'shops.read',
    'shops.certifications',
    'shops.certifications.read',
    # Orders & cases
    'orders.read',
    'orders.write',
    'orders.cases.read',
    'orders.cases.write',
    # Gyms
    'gyms',
    'gyms.read',
    # Communities
    'communities.read',
    # Logistics
    'logistics',
    'logistics.read',
    'logistics.applications.read',
    'logistics.applications.write',
    # Wallet
    'wallet.read',
    'wallet.reconcile',
})

# Scopes that are defined and grantable but are not (yet) declared on any route.
#
# Tracked separately from ALL_SCOPES rather than mixed in, because mixing them
# would defeat ALL_SCOPES' job: it is the back-compat allow-list, so every entry
# in it is a privilege handed to a role-less staff user. A scope nothing reads
# has no business widening that.
#
# ``moderation.*`` — the moderation routes live at /api/v1/moderation/ and
# apps/moderation/views.py authorises with a bare ``IsAdminUser``; it declares no
# scopes. Defined here so a moderator role is expressible and so adopting them
# later is not a rename.
MODERATION_SCOPES = (
    'moderation.reports.read',
    'moderation.reports.write',
    'moderation.content_flags.read',
    'moderation.content_flags.write',
    'moderation.appeals.read',
    'moderation.appeals.write',
    'moderation.actions.read',
)

# ``users.write-lite`` — the narrow user-write a support agent needs. No route
# declares it, so today it grants nothing on its own: a support agent reaches the
# routes they were given via ``users.read``, and this scope exists to be the
# thing ``apps.admin_portal`` splits ``users.write`` into once it grows a
# profile-edit route that does not also suspend. Naming it now, while it is
# inert, is cheaper than renaming it later once operators depend on it.
UNROUTED_SCOPES = MODERATION_SCOPES + ('users.write-lite',)

# Everything a role may legitimately hold.
KNOWN_SCOPES = frozenset(ALL_SCOPES) | frozenset(UNROUTED_SCOPES)


class StaffRole(TimestampedModel):
    """A staff user's role, and the scopes it grants.

    ``scopes`` is stored *in addition to* the role's defaults, not instead of
    them — see the module docstring. It exists for the occasional extra domain
    (a support lead who also reads logistics) and defaults to empty.
    """

    ROLE_CHOICES = [
        ('admin', 'Administrator'),
        ('moderator', 'Moderator'),
        ('support', 'Support Agent'),
        ('gym_relations', 'Gym Relations'),
        ('supplier_relations', 'Supplier Relations'),
        ('logistics', 'Logistics'),
        ('finance', 'Finance'),
        ('verification_regulator', 'Verification Regulator'),
    ]

    # UUID primary key, matching AccountActionRequest and the repo's convention
    # for staff-facing tables: ids appear in URLs and admin URLs, and a guessable
    # sequential id on the role table would let an unauthenticated prober
    # enumerate how many staff accounts exist.
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='staff_role',
    )
    role = models.CharField(max_length=32, choices=ROLE_CHOICES)
    scopes = models.JSONField(default=list, blank=True)
    granted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='staff_roles_granted',
    )
    granted_at = models.DateTimeField(default=timezone.now)
    notes = models.TextField(blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'governance_staff_role'
        indexes = [
            models.Index(fields=['role']),
            models.Index(fields=['revoked_at']),
        ]

    def __str__(self):
        return f'{self.user} as {self.role}'

    @property
    def is_active(self):
        """A revoked row grants nothing. It is kept for the audit trail."""
        return self.revoked_at is None


# The role -> default scope floor. See the module docstring for how ``scopes``
# combines with this.
DEFAULT_SCOPES_BY_ROLE = {
    # Everything the portal exposes. The back-compat role-less staff user is
    # equivalent to this.
    'admin': set(ALL_SCOPES),

    # Report/flag/appeal triage. Deliberately excludes users.write: a moderator
    # can decide content, not accounts.
    'moderator': {
        'moderation.reports.read',
        'moderation.reports.write',
        'moderation.content_flags.read',
        'moderation.content_flags.write',
        'moderation.appeals.read',
        'moderation.appeals.write',
        'moderation.actions.read',
    },

    'support': {
        'users.read',
        'orders.read',
        # A support agent can freeze a session, correct a profile field and read
        # an order — not ban, not pay, not approve money.
        'users.write-lite',
    },

    'gym_relations': {
        'gyms',
        'gyms.read',
        'users.read',
    },

    'supplier_relations': {
        'shops',
        'shops.read',
        'orders.read',
        'users.read',
    },

    'logistics': {
        'logistics',
        'logistics.read',
        'logistics.applications.read',
        'logistics.applications.write',
        'orders.read',
    },

    'finance': {
        'wallet.read',
        'wallet.reconcile',
        'orders.read',
        'orders.write',
    },

    # Certifies shops. Note it gets ``shops.certifications`` (the deciding scope)
    # but not plain ``shops`` — a regulator settles a certification queue, it
    # does not rewrite a shop's handle or category.
    'verification_regulator': {
        'shops.certifications',
        'shops.certifications.read',
        'users.read',
    },
}

# Sanity: every choice must have defaults, and every default a role must be
# declared in the choices list. This is cheap and turns a typo into an
# import-time failure rather than a staff member silently holding no scopes.
assert set(DEFAULT_SCOPES_BY_ROLE) == {c[0] for c in StaffRole.ROLE_CHOICES}, (
    'DEFAULT_SCOPES_BY_ROLE and StaffRole.ROLE_CHOICES disagree'
)


# ---------------------------------------------------------------------------
# Two-person approvals
# ---------------------------------------------------------------------------

class AccountActionRequest(TimestampedModel):
    """A high-risk account action awaiting a second, independent approver.

    The point is separation of duties. A requester can *ask* for a ban; they
    cannot grant it, even though they hold the scope it needs. The invariant is
    enforced in the view (:meth:`apps.governance.views.ApprovalViewSet._decide`),
    not here, because it needs the acting user.

    ``requested_by_profile`` is a denormalised snapshot of the requester's
    display name taken at request time. ``requested_by`` is ``SET_NULL``, so
    deleting the actor would otherwise erase who asked — exactly the row you
    most want to still be able to audit.
    """

    ACTION_CHOICES = [
        ('ban', 'Ban Account'),
        ('suspension', 'Suspend Account'),
        ('verification_decision', 'Verification Decision'),
        ('payout', 'Payout'),
        ('staff_role_grant', 'Grant Staff Role'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('cancelled', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    action = models.CharField(max_length=32, choices=ACTION_CHOICES)
    target_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='governance_action_requests',
    )
    payload = models.JSONField(default=dict, blank=True)
    status = models.CharField(max_length=16, choices=STATUS_CHOICES, default='pending')
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='governance_requests_raised',
    )
    requested_by_profile = models.CharField(max_length=120, blank=True)
    decided_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='governance_requests_decided',
    )
    decided_at = models.DateTimeField(null=True, blank=True)
    decision_note = models.TextField(blank=True)
    requires_second = models.BooleanField(default=True)
    applied_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'governance_account_action_request'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', '-created_at']),
            models.Index(fields=['target_user', '-created_at']),
        ]

    def __str__(self):
        return f'{self.action} on {self.target_user} ({self.status})'

    # -- scope each action needs from the *approver* -------------------------
    #
    # The requester needs it too (otherwise they could not raise the request),
    # but it is checked on the approve call: a stale grant must not let a
    # request that was queued before a revocation through.
    ACTION_SCOPES = {
        'ban': 'users.write',
        'suspension': 'users.write',
        'payout': 'orders.write',
        'staff_role_grant': 'users',
        # Certifying a shop is the regulator's call, not an order or a user.
        'verification_decision': 'shops.certifications',
    }

    @property
    def is_open(self):
        return self.status == 'pending'

    @property
    def requires_scope(self):
        """The scope an approver must hold, or None for an unknown action."""
        return self.ACTION_SCOPES.get(self.action)
