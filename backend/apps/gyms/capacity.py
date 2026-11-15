"""Tier capacity limits and common gym-funding moves.

The tier a gym has sets how many paying/active members it may serve. The
leader reverses the direction the usual membership flow runs in: instead of
checking caps after somebody pays, we check before approval and before
joining creates a row.
"""

from django.utils import timezone

TIER_MEMBER_CAP = {
    'regular': 50,
    'midlevel': 500,
    'executive': None,  # unlimited
}


def member_cap_for_tier(tier: str) -> int | None:
    return TIER_MEMBER_CAP.get(tier, TIER_MEMBER_CAP['regular'])


def active_member_count(gym) -> int:
    return gym.memberships.filter(subscription_active=True).count()


def capacity_status(gym) -> dict:
    cap = member_cap_for_tier(gym.tier)
    current = gym.member_count or 0
    if cap is None:
        remaining = None
    else:
        remaining = max(0, cap - current)
    return {
        'tier': gym.tier,
        'cap': cap,
        'current': current,
        'remaining': remaining,
        'at_cap': cap is not None and current >= cap,
    }


class CapacityExceeded(Exception):
    """Raised when a gym is already at its tier's member cap."""

    def __init__(self, retry_after_upgrade: bool = True):
        super().__init__('Gym is at its member capacity for this tier.')
        self.retry_after_upgrade = retry_after_upgrade


def assert_capacity_available(gym) -> None:
    """Raise ``CapacityExceeded`` if the gym may not seat another member.

    Existing members keep their membership — this only blocks *new* joins,
    matching the downgrade policy (lapsed tier hides badge/privileges for
    newcomers but nobody gets kicked out).
    """
    cap = member_cap_for_tier(gym.tier)
    if cap is not None and (gym.member_count or 0) >= cap:
        raise CapacityExceeded()


def credit_gym_wallet(gym, artifact_type: str, quantity: int, *, kind: str,
                      reference_id: str = '', note: str = '') -> None:
    """Record a credit into the gym's artifact purse and its ledger."""
    if quantity <= 0:
        return
    from .models import GymWallet, GymWalletEntry

    wallet, _ = GymWallet.objects.get_or_create(gym=gym, defaults={'balance': {}})
    balance = dict(wallet.balance or {})
    balance[artifact_type] = balance.get(artifact_type, 0) + quantity
    wallet.balance = balance
    wallet.save(update_fields=['balance', 'updated_at'])
    GymWalletEntry.objects.create(
        wallet=wallet,
        artifact_type=artifact_type,
        quantity=quantity,
        direction=GymWalletEntry.CREDIT,
        kind=kind,
        reference_id=reference_id or '',
        note=note or '',
    )


def debit_gym_wallet(gym, artifact_type: str, quantity: int, *, kind: str,
                     reference_id: str = '', note: str = '') -> bool:
    """Debit a gym's purse; returns False if it could not be fully covered."""
    if quantity <= 0:
        return True
    from .models import GymWallet, GymWalletEntry

    wallet, _ = GymWallet.objects.get_or_create(gym=gym, defaults={'balance': {}})
    balance = dict(wallet.balance or {})
    if balance.get(artifact_type, 0) < quantity:
        return False
    balance[artifact_type] = balance.get(artifact_type, 0) - quantity
    if balance[artifact_type] <= 0:
        balance.pop(artifact_type)
    wallet.balance = balance
    wallet.save(update_fields=['balance', 'updated_at'])
    GymWalletEntry.objects.create(
        wallet=wallet,
        artifact_type=artifact_type,
        quantity=quantity,
        direction=GymWalletEntry.DEBIT,
        kind=kind,
        reference_id=reference_id or '',
        note=note or '',
    )
    return True


def tier_subscription_for(gym):
    """Return the gym's tier subscription, or an active regular fallback."""
    from .models import GymTierSubscription

    try:
        return gym.tier_subscription
    except GymTierSubscription.DoesNotExist:
        return None


def current_tier(gym) -> str:
    """The tier whose benefits the gym currently has.

    A gym that just upgraded gets the paid tier immediately on verify; a gym
    that lapsed goes back to regular (cap re-imposed for new joiners only).
    """
    sub = tier_subscription_for(gym)
    if sub and sub.status in ('active', 'grace'):
        return sub.tier
    return 'regular'


def sync_gym_tier_with_subscription(gym) -> str:
    """Make ``Gym.tier`` match the subscription state; returns the set tier."""
    sub = tier_subscription_for(gym)
    if sub and sub.status in ('active', 'grace'):
        tier = sub.tier
    else:
        tier = 'regular'
    if gym.tier != tier:
        gym.tier = tier
        gym.save(update_fields=['tier', 'updated_at'])
    return tier


def usd_estimate(balance: dict) -> float:
    from apps.wallet.serializers import ARTIFACT_VALUES

    return round(sum(ARTIFACT_VALUES.get(k, 0) * qty for k, qty in (balance or {}).items()), 2)


def aware_now():
    return timezone.now()
