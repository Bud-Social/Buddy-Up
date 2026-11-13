"""One authorization policy for live media and interaction endpoints."""

from apps.gyms.models import GymMembership
from apps.profiles.models import BuddyRelationship


INTERACTIVE_LIVE_TYPES = {'buddy_circle', 'random_drop'}


def is_host_or_cohost(live, profile):
    return profile == live.host or live.co_hosts.filter(pk=profile.pk).exists()


def can_access_live(live, profile):
    """Return whether a profile is eligible to enter the live, excluding payment."""
    if live.status == 'ended':
        return False
    if is_host_or_cohost(live, profile) or live.live_type == 'random_drop':
        return True
    if live.access == 'public':
        return True
    if live.access == 'private':
        # Only Me: the host and co-hosts. Fall through to False.
        return False
    if live.access == 'buddies':
        return BuddyRelationship.objects.filter(
            status='confirmed',
        ).filter(
            from_user__in=[profile, live.host],
            to_user__in=[profile, live.host],
        ).exists()
    if live.access == 'gym_members' and live.gym_id:
        return GymMembership.objects.filter(
            gym_id=live.gym_id,
            member=profile,
            subscription_active=True,
        ).exists()
    return False


def replay_admitted(live, profile):
    """Whether a profile may watch a saved replay.

    Replays inherit the live's visibility: public for everyone, buddies for
    the host's confirmed buddies, gym_members for active members of the
    gym the live was tagged to, private for the host only. Replay listing
    and the serializer use this so an audience-marked live no longer
    publishes its recording to the world.
    """
    if is_host_or_cohost(live, profile):
        return True
    if live.access == 'public':
        return True
    if live.access == 'private':
        return False
    if live.access == 'buddies':
        return BuddyRelationship.objects.filter(
            status='confirmed',
        ).filter(
            from_user__in=[profile, live.host],
            to_user__in=[profile, live.host],
        ).exists()
    if live.access == 'gym_members' and live.gym_id:
        return GymMembership.objects.filter(
            gym_id=live.gym_id,
            member=profile,
            subscription_active=True,
        ).exists()
    return False


def replay_visibility_q(profile):
    """A database-level filter equivalent to replay_admitted, for list queries."""
    from django.db.models import Q
    buddy_host_ids = BuddyRelationship.objects.filter(
        status='confirmed',
    ).filter(
        Q(from_user=profile) | Q(to_user=profile),
    ).values_list('from_user', 'to_user')
    peer_ids = set()
    for a, b in buddy_host_ids:
        # Profile's PK is its user_id; there is no .id on the model.
        peer_ids.add(b if a == profile.pk else a)
    member_gym_ids = GymMembership.objects.filter(
        member=profile, subscription_active=True,
    ).values_list('gym_id', flat=True)
    return (
        Q(access='public')
        | Q(host=profile)
        | Q(co_hosts=profile)
        | (Q(access='buddies') & Q(host_id__in=peer_ids))
        | (Q(access='gym_members') & Q(gym_id__in=list(member_gym_ids)))
    )


def muted_host_ids(profile):
    """Hosts this viewer asked never to be recommended."""
    from .models import LiveHostMute
    return LiveHostMute.objects.filter(user=profile).values_list('host_id', flat=True)


def may_publish_media(live, profile):
    """Public lives are broadcast-only; small circles and random drops are interactive."""
    return is_host_or_cohost(live, profile) or live.live_type in INTERACTIVE_LIVE_TYPES


def has_live_admission(live, profile):
    """Credentials and sockets require a completed admission, including paid entry."""
    if is_host_or_cohost(live, profile):
        return True
    # Admission is permanent for a paid live; leaving only ends the current
    # media presence and must not charge the user again on rejoin.
    return live.attendees.filter(user=profile).exists()
