import type { GymTier } from '@/types/gym';
import { Dumbbell } from 'lucide-react';

interface VerifiedGymBadgeProps {
  /** Renders nothing when the gym has not been verified. */
  verified: boolean;
  /** Badge colour fill. Regular = white, midlevel = blue, executive = gold. */
  tier?: GymTier;
  size?: 'sm' | 'md';
  className?: string;
}

const TIER_STYLE: Record<GymTier, { box: string; icon: string }> = {
  regular: {
    box: 'bg-white',
    icon: 'text-buddy-black',
  },
  midlevel: {
    box: 'bg-buddy-blue',
    icon: 'text-white',
  },
  executive: {
    box: 'bg-buddy-gold',
    icon: 'text-buddy-black',
  },
};

const SIZE = {
  sm: { box: 'w-6 h-6', dumbbell: 12 },
  md: { box: 'w-8 h-8', dumbbell: 16 },
};

/**
 * The verified-gym mark.
 *
 * Filled circles — regular white, mid-level blue, executive gold — dumbbell
 * inside. Deliberately distinct from the person-level trainer/practitioner
 * badges: a verified gym is a business claim, not a professional one.
 */
export function VerifiedGymBadge({ verified, tier = 'regular', size = 'sm', className }: VerifiedGymBadgeProps) {
  if (!verified) return null;
  const style = TIER_STYLE[tier] ?? TIER_STYLE.regular;
  const { box, dumbbell } = SIZE[size];

  return (
    <span
      className={`inline-flex items-center justify-center rounded-full ${box} ${style.box} ${className || ''}`}
      title={`${tier} gym`}
      aria-label={`${tier} verified gym`}
    >
      <Dumbbell size={dumbbell} strokeWidth={2.4} className={style.icon} />
    </span>
  );
}

export default VerifiedGymBadge;
