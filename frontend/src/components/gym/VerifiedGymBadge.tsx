import { useState } from 'react';
import type { GymTier } from '@/types/gym';
import { Dumbbell, X, Zap } from 'lucide-react';


interface VerifiedGymBadgeProps {
  /** Renders nothing when the gym has not been verified. */
  verified: boolean;
  /** Badge colour fill. Regular = white, midlevel = blue, executive = gold. */
  tier?: GymTier;
  size?: 'sm' | 'md';
  className?: string;
  /** When supplied, clicking the badge opens the tier explainer popover. */
  capacity?: { tier: GymTier; cap: number | null; current: number };
}

const TIER_STYLE: Record<GymTier, { box: string; icon: string }> = {
  regular:   { box: 'bg-white',     icon: 'text-buddy-black' },
  midlevel:  { box: 'bg-buddy-blue', icon: 'text-white' },
  executive: { box: 'bg-buddy-gold', icon: 'text-buddy-black' },
};

const SIZE = {
  sm: { box: 'w-6 h-6', dumbbell: 11 },
  md: { box: 'w-7 h-7', dumbbell: 14 },
};

const TIER_COPY: Record<GymTier, { label: string; fill: string; blurb: string }> = {
  regular:   { label: 'Regular gym',    fill: 'White badge', blurb: 'Standard verification — the gym exists, is real and is safe to host sessions.' },
  midlevel:  { label: 'Mid-Level gym',  fill: 'Blue badge',   blurb: 'Established gym with a demonstrated track record hosting sessions and selling places.' },
  executive: { label: 'Executive gym',  fill: 'Gold badge',   blurb: 'Flagship operation — top-tier facilities, staff and verification. Unlimited capacity.' },
};

/**
 * The verified-gym mark.
 *
 * Filled circles — regular white, mid-level blue, executive gold — dumbbell
 * inside. Deliberately distinct from the person-level trainer/practitioner
 * badges: a verified gym is a business claim, not a professional one.
 *
 * When `capacity` is supplied, clicking the badge opens a popover explaining
 * what the tier means and how many members the gym is serving against its
 * cap. Without it the badge is a plain non-interactive mark.
 */
export function VerifiedGymBadge({ verified, tier = 'regular', size = 'sm', className, capacity }: VerifiedGymBadgeProps) {
  const [open, setOpen] = useState(false);
  if (!verified) return null;
  const style = TIER_STYLE[tier] ?? TIER_STYLE.regular;
  const { box, dumbbell } = SIZE[size];
  const copy = TIER_COPY[tier] ?? TIER_COPY.regular;

  const inner = <Dumbbell size={dumbbell} strokeWidth={2.25} className={`${style.icon} -rotate-45`} />;

  const trigger = capacity ? (
    <button
      type="button"
      aria-label={`About ${copy.label}`}
      aria-expanded={open}
      onClick={() => setOpen((v) => !v)}
      title={`${copy.label} — click for details`}
      className={`relative inline-flex items-center justify-center rounded-full ${box} ${style.box} ${className || ''} cursor-help hover:ring-2 hover:ring-buddy-green/40 focus:outline-none focus:ring-2 focus:ring-buddy-green`}
    >
      {inner}
    </button>
  ) : (
    <span
      className={`relative inline-flex items-center justify-center rounded-full ${box} ${style.box} ${className || ''}`}
      title={copy.label}
      aria-label={copy.label}
    >
      {inner}
    </span>
  );

  return (
    <div className="relative inline-flex">
      {trigger}
      {capacity && open && (
        <>
          <button className="fixed inset-0 z-40 cursor-default" aria-label="Close" onClick={() => setOpen(false)} />
          <div
            role="dialog"
            aria-modal="true"
            aria-label={`${copy.label} details`}
            className="absolute left-0 top-full z-50 mt-2 w-64 rounded-2xl border border-buddy-surface-raised bg-buddy-surface shadow-2xl p-3 text-left text-xs"
          >
            <div className="flex items-center justify-between gap-2">
              <p className="text-xs font-bold flex items-center gap-1.5">
                <span className={`inline-flex w-4 h-4 rounded-full ${style.box} items-center justify-center`}>
                  <Dumbbell size={10} className={style.icon} />
                </span>
                {copy.label}
              </p>
              <button onClick={() => setOpen(false)} aria-label="Close" className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X size={14} />
              </button>
            </div>
            <p className="mt-2 text-buddy-text-secondary">{copy.blurb}</p>
            <div className="mt-2 rounded-xl bg-buddy-surface-raised p-2">
              <p className="text-[9px] uppercase tracking-wider text-buddy-text-secondary font-semibold flex items-center gap-1">
                <Zap size={10} /> Member capacity
              </p>
              {capacity.cap === null ? (
                <p className="mt-1">Unlimited members</p>
              ) : (
                <p className="mt-1">{capacity.current} of {capacity.cap} slots used</p>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default VerifiedGymBadge;
