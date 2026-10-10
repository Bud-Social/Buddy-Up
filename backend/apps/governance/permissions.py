"""Permission classes for the governance API.

A re-export, not a redefinition. The governance app is where scopes are *defined*
(``models.ALL_SCOPES``, ``models.DEFAULT_SCOPES_BY_ROLE``) but the enforcement
has to be literally the same code the admin portal runs, or the two surfaces
drift and the stricter-looking one becomes the weaker one. A subclass or a copy
would be a third implementation to keep in sync.

The scopes used here:

* ``users``        — staff-role management (read and write the role table)
* ``users.read``   — reading the approvals queue and raising requests
* ``users.write``  — required of whoever approves a ban or suspension
* ``orders.write`` — required of whoever approves a payout
* ``shops.certifications`` — required of whoever approves a verification decision
"""
from apps.admin_portal.permissions import ScopedPlatformAdmin

__all__ = ['ScopedPlatformAdmin']
