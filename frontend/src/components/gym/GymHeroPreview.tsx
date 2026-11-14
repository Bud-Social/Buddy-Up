import { Dumbbell, MapPin, ShieldCheck, Users } from 'lucide-react';
import type { GymCategory, GymTier } from '@/types/gym';
import { VerifiedGymBadge } from '@/components/gym/VerifiedGymBadge';

interface GymHeroPreviewProps {
  name: string;
  handle: string;
  coverUrl: string;
  logoUrl: string;
  categories: GymCategory[];
  accessType: string;
  subscriptionType: string;
  tier?: GymTier;
  /** Visitors don't see an unverified badge until the gym is registered. */
  verified?: boolean;
  memberCount?: number;
  /** How many members the gym can coach online; 0 = unspecified. */
  onlineCapacity?: number;
  /** How many members the gym can hold physically; 0 = unspecified. */
  physicalCapacity?: number;
  /** How many members the gym already serves on the floor. */
  currentlyServing?: number;
  /** City of the primary venue, if one has been added. */
  locationLabel?: string;
}

/**
 * What a non-member sees for this gym, rendered as a static mock.
 *
 * Shown while the wizard owner is still choosing assets, so "does this logo
 * and cover work together?" is answered before the gym is live instead of
 * after. Deliberately mirrors the gym detail hero instead of inventing a
 * new layout.
 */
export function GymHeroPreview({
  name,
  handle,
  coverUrl,
  logoUrl,
  categories,
  accessType,
  subscriptionType,
  tier = 'regular',
  verified = false,
  memberCount = 0,
  onlineCapacity = 0,
  physicalCapacity = 0,
  currentlyServing = 0,
  locationLabel,
}: GymHeroPreviewProps) {
  const displayName = name.trim() || 'Your gym';
  const displayHandle = handle.trim() || 'yourhandle';

  return (
    <div
      className="overflow-hidden rounded-2xl border border-buddy-surface-raised bg-buddy-surface"
      aria-label="Gym preview"
    >
      <p className="px-3 pt-2 text-[10px] font-semibold uppercase tracking-wider text-buddy-text-secondary">
        Preview — how visitors will see your gym
      </p>

      {/* Cover + overlapping logo, mirroring the gym detail hero. */}
      <div className="relative h-28 bg-gradient-to-b from-buddy-surface to-buddy-black">
        {coverUrl ? (
          <img src={coverUrl} alt="" className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-buddy-text-secondary/30">
            <Dumbbell size={32} />
          </div>
        )}
        <div className="absolute bottom-3 left-4 flex items-end gap-2.5">
          <div className="w-14 h-14 rounded-xl bg-buddy-green/10 border-2 border-buddy-black flex items-center justify-center overflow-hidden">
            {logoUrl ? (
              <img src={logoUrl} alt="" className="w-full h-full object-cover" />
            ) : (
              <Dumbbell size={26} className="text-buddy-green" />
            )}
          </div>
          <div className="pb-0.5">
            <div className="flex items-center gap-1.5">
              <p className="font-heading font-semibold text-sm leading-tight">{displayName}</p>
              <VerifiedGymBadge verified={verified} tier={tier} size="sm" />
            </div>
            <p className="text-[10px] text-buddy-text-secondary">@{displayHandle} · {tier}</p>
          </div>
        </div>
      </div>

      {/* Meta row: members · rating · access · categories. */}
      <div className="p-3 space-y-2">
        <div className="flex items-center gap-3 text-[11px] text-buddy-text-secondary flex-wrap">
          <span className="flex items-center gap-1"><Users size={12} /> {memberCount} members</span>
          <span className="flex items-center gap-1 capitalize"><ShieldCheck size={12} /> {accessType}</span>
          <span>{subscriptionType === 'paid' ? 'Paid' : 'Free'}</span>
          {(onlineCapacity > 0 || physicalCapacity > 0 || currentlyServing > 0) && (
            <span className="text-[10px] text-buddy-text-secondary/80">
              ·{' '}
              {onlineCapacity > 0 ? `${onlineCapacity} online` : ''}
              {onlineCapacity > 0 && physicalCapacity > 0 ? ' · ' : ''}
              {physicalCapacity > 0 ? `${physicalCapacity} seats` : ''}
              {currentlyServing > 0 ? ` · ${currentlyServing} serving` : ''}
            </span>
          )}
        </div>
        <div className="flex flex-wrap items-center gap-1">
          {categories.length > 0
            ? categories.map((c) => (
                <span key={c.id} className="text-[10px] bg-buddy-green/10 text-buddy-green px-2 py-0.5 rounded-full">
                  {c.display_name}
                </span>
              ))
            : <span className="text-[10px] text-buddy-text-secondary/60">No categories selected</span>}
          {locationLabel && (
            <span className="inline-flex items-center gap-1 text-[10px] bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full">
              <MapPin size={9} /> {locationLabel}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

export default GymHeroPreview;
