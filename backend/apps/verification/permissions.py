"""Role permissions that actually check verification.

``common.permissions`` defines ``IsVerifiedTrainer`` and
``IsVerifiedPractitioner``. Both are wrong and neither is imported anywhere:

* They read ``request.user.profile.role`` and nothing else, so "verified" in
  the name was a claim, not a check. Since ``role`` was self-declared at
  registration, ``profile.role == 'trainer'`` was exactly what an unverified
  person could set by sending one extra field to ``/auth/register/``.
* Because nothing imported them, they were also dead code — a trainer-only
  surface was, in practice, gated on nothing at all.

These classes are the corrected versions. They are declared here rather than in
``common.permissions`` because ``common`` is not owned by this app, and leaving
two same-named classes with different behaviour in the tree would be a trap for
 whoever wires them next.

Both check the conjunction ``Profile.is_verified_role()`` establishes:
an elevated role **and** the verification status that certifies it.
"""
from rest_framework import permissions


def _has_verified_role(user, role):
    """True when ``user`` is an authenticated holder of a verified ``role``.

    Defensive about every hop: this runs inside a DRF permission check, before
    the view has touched anything, so an anonymous user, a superuser-created
    account with no ``Profile`` row, or a profile with no role attribute must
    return False rather than raise a 500 from the auth layer.
    """
    if user is None or not getattr(user, 'is_authenticated', False):
        return False

    # getattr, not a direct access: `user.profile` on a User created by
    # `createsuperuser` raises RelatedObjectDoesNotExist, and a permission class
    # that 500s denies the request with a stack trace instead of a 403.
    profile = getattr(user, 'profile', None)
    if profile is None:
        return False

    if getattr(profile, 'role', None) != role:
        return False

    return bool(profile.is_verified_role())


class IsVerifiedTrainer(permissions.BasePermission):
    """Certified, verified personal trainers only."""

    message = 'This action is limited to verified personal trainers.'

    def has_permission(self, request, view):
        return _has_verified_role(request.user, 'trainer')


class IsVerifiedPractitioner(permissions.BasePermission):
    """Certified, verified health practitioners only."""

    message = 'This action is limited to verified health practitioners.'

    def has_permission(self, request, view):
        return _has_verified_role(request.user, 'practitioner')