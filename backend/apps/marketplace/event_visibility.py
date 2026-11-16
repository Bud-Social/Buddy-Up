"""Single source of truth for event visibility.

Import from views — never ORM-fork this logic again. Ownership beats
membership beats public.
"""

from django.db.models import Q

from apps.gyms.models import GymMembership


def event_visibility_q(request):
    """Events this viewer may see.

    public        → everyone
    gym_members   → active members of the attached gym, plus the gym's owners
    hidden        → the gym's owners / co-owners only
    """

    if not (request and request.user and request.user.is_authenticated):
        return Q(visibility='public')

    profile = request.user.profile
    member_gym_ids = list(
        GymMembership.objects.filter(member=profile, subscription_active=True)
        .values_list('gym_id', flat=True)
    )
    owner_gym_ids = list(
        GymMembership.objects.filter(member=profile, role__in=['owner', 'co_owner'])
        .values_list('gym_id', flat=True)
    )
    return (
        Q(visibility='public')
        | Q(visibility='gym_members', gym_id__in=member_gym_ids)
        | Q(visibility__in=['gym_members', 'hidden'], gym_id__in=owner_gym_ids)
        | Q(creator=profile)
    )
