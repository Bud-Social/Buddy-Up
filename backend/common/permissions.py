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
