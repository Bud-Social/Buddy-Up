"""One authorization policy for live media and interaction endpoints."""

from apps.gyms.models import GymMembership
from apps.profiles.models import BuddyRelationship


INTERACTIVE_LIVE_TYPES = {'buddy_circle', 'random_drop'}


def is_host_or_cohost(live, profile):
    return profile == live.host or live.co_hosts.filter(id=profile.id).exists()


def can_access_live(live, profile):
    """Return whether a profile is eligible to enter the live, excluding payment."""
    if live.status == 'ended':
        return False
    if is_host_or_cohost(live, profile) or live.live_type == 'random_drop':
        return True
    if live.access == 'public':
        return True
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
