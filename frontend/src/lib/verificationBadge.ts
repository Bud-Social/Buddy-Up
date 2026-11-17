/**
 * One source of truth for how a verified account is labelled on a post card.
 *
 * Every ID below is one of the statuses written by ``apps.verification`` on
 * approval (see ``VERIFICATION_STATUS_BY_TYPE``), so these strings must stay
 * in lockstep with the backend. A user with no verified role (or an old
 * ``email``-only verification) is a regular account — the badge still tells
 * the reader the person is who they claim to be.
 */
export const VERIFICATION_BADGES: Record<string, { label: string; className: string }> = {
  id: { label: 'Verified', className: 'bg-buddy-blue/20 text-buddy-blue' },
  email: { label: 'Verified', className: 'bg-buddy-blue/20 text-buddy-blue' },
  trainer: { label: 'Trainer', className: 'bg-buddy-green/20 text-buddy-green' },
  practitioner: { label: 'Practitioner', className: 'bg-buddy-gold/20 text-buddy-gold' },
  distributor: { label: 'Distributor', className: 'bg-orange-400/20 text-orange-300' },
  shop: { label: 'Shop', className: 'bg-buddy-electric/20 text-buddy-electric' },
  gym: { label: 'Gym', className: 'bg-buddy-green/20 text-buddy-green' },
  gym_owner: { label: 'Gym', className: 'bg-buddy-green/20 text-buddy-green' },
  shop_owner: { label: 'Shop', className: 'bg-buddy-electric/20 text-buddy-electric' },
  delivery_partner: { label: 'Delivery', className: 'bg-buddy-gold/20 text-buddy-gold' },
};

/** True when a profile carries any verified status at all. */
export function isVerifiedStatus(status?: string | null): boolean {
  return !!status && status !== 'none' && status in VERIFICATION_BADGES;
}
