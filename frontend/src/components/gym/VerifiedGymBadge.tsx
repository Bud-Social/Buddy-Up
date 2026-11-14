import { BadgeCheck, Dumbbell } from 'lucide-react';

interface VerifiedGymBadgeProps {
  /** Renders nothing when the gym has not been verified. */
  verified: boolean;
  size?: 'sm' | 'md';
  className?: string;
}

/**
 * The verified-gym mark: a dumbbell with a blue tick.
 *
 * Deliberately distinct from the person-level trainer/practitioner badges —
 * a verified gym is a business claim, not a professional one.
 */
export function VerifiedGymBadge({ verified, size = 'sm', className }: VerifiedGymBadgeProps) {
  if (!verified) return null;
  const box = size === 'sm' ? 'w-6 h-6' : 'w-8 h-8';
  const dumbbell = size === 'sm' ? 12 : 16;
  const tick = size === 'sm' ? 11 : 14;

  return (
    <span
      className={`relative inline-flex items-center justify-center rounded-full bg-buddy-blue/15 text-buddy-blue ${box} ${className || ''}`}
      title="Verified gym"
      aria-label="Verified gym"
    >
      <Dumbbell size={dumbbell} strokeWidth={2.4} />
      <BadgeCheck
        size={tick}
        className="absolute -bottom-1 -right-1 text-buddy-blue fill-buddy-black stroke-buddy-blue"
        strokeWidth={2.6}
      />
    </span>
  );
}

export default VerifiedGymBadge;
