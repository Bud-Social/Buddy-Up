from rest_framework import permissions


class IsVerifiedTrainer(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.profile.role == 'trainer'


class IsVerifiedPractitioner(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.profile.role == 'practitioner'


class IsGymOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        from apps.gyms.models import GymMembership
        return GymMembership.objects.filter(
            gym=obj, member=request.user.profile, role__in=['owner', 'co_owner']
        ).exists()


class IsGymModerator(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        from apps.gyms.models import GymMembership
        return GymMembership.objects.filter(
            gym=obj, member=request.user.profile, role__in=['owner', 'co_owner', 'moderator']
        ).exists()


class AreBuddies(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        from apps.profiles.models import BuddyRelationship
        return BuddyRelationship.objects.filter(
            from_user=request.user.profile, to_user=obj, status='confirmed'
        ).exists() or BuddyRelationship.objects.filter(
            from_user=obj, to_user=request.user.profile, status='confirmed'
        ).exists()


class IsAdult(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_adult


class CanAccessMatureContent(permissions.BasePermission):
    """Allow authenticated users old enough to view the mature category.

    The threshold is country-aware: 18+ by default, 16+ only where local law
    permits. Because age is only persisted as an 18+ flag (``User.is_adult``)
    and a 16+ consent flag, an 18+ threshold is satisfied by ``is_adult``; a
    16+ threshold falls back to the user's 16+ consent flag. Unauthenticated
    users can never access mature content.
    """

    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        from common.age_gating import mature_content_min_age

        country = None
        if hasattr(request.user, 'profile'):
            country = request.user.profile.location_country or None
        min_age = mature_content_min_age(country)
        if min_age >= 18:
            return request.user.is_adult
        return request.user.consent_log.get('is_16_plus', False)
