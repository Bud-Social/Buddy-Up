import { useNavigate } from 'react-router-dom';
import { Users, Star, Lock, Globe, EyeOff, MapPin, Dumbbell } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { VerifiedGymBadge } from '@/components/gym/VerifiedGymBadge';
import { formatDistance } from '@/lib/geo';
import type { Gym } from '@/types';

interface GymCardProps {
  gym: Gym;
  /** False on virtual-only surfaces where a distance would be misleading. */
  showDistance?: boolean;
  onClick?: () => void;
}

const accessIcon = (type: string) => {
  if (type === 'private') return <Lock size={12} />;
  if (type === 'secret') return <EyeOff size={12} />;
  return <Globe size={12} />;
};

function locationLabel(gym: Gym) {
  const summary = gym.location_summary;
  const nearest =
    summary?.nearest_km ?? (typeof gym.distance_km === 'number' ? gym.distance_km : null);
  const count = summary?.venue_count ?? 0;
  const cities = summary?.cities ?? (gym.location_city ? [gym.location_city] : []);

  if (count > 1) {
    const where = cities.length ? cities.slice(0, 2).join(' · ') : `${count} locations`;
    return {
      icon: <MapPin size={12} />,
      text: `${where}${nearest !== null ? ` · nearest ${formatDistance(nearest)}` : ''}`,
      highlight: nearest !== null,
    };
  }
  if (cities.length) {
    return {
      icon: <MapPin size={12} />,
      text: cities[0],
      highlight: false,
    };
  }
  return null;
}

/**
 * The shared gym card used by Gyms, Discover and profile rails.
 *
 * Keeps the social signal (which of the people you follow are members) on the
 * right end of the card, and the physical-location signal next to the member
 * count, so a multi-location gym reads as multi-location rather than as a
 * single city.
 */
export function GymCard({ gym, showDistance = true, onClick }: GymCardProps) {
  const navigate = useNavigate();
  const go = onClick ?? (() => navigate(`/gyms/${gym.handle}`));
  const followed = gym.followed_members ?? [];
  const followedCount = gym.followed_members_count ?? followed.length;
  const location = locationLabel(gym);
  const nearest = gym.location_summary?.nearest_km ?? gym.distance_km;

  return (
    <Card
      className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
      onClick={go}
    >
      <div className="flex items-start gap-3">
        <div className="w-14 h-14 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0 text-buddy-green overflow-hidden">
          {gym.logo_url ? (
            <img src={gym.logo_url} alt="" className="w-full h-full object-cover" loading="lazy" />
          ) : (
            <Dumbbell size={26} />
          )}
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="font-heading font-semibold text-sm truncate">{gym.name}</h3>
            <VerifiedGymBadge verified={gym.is_verified} />
            {gym.subscription_type === 'paid' && <Badge variant="gold" label="Paid" size="sm" />}
            {gym.registration_status === 'verified' && (
              <Badge variant="blue" label="Registered" size="sm" />
            )}
          </div>
          <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">
            @{gym.handle} · {gym.category.replace('_', ' ')}
          </p>

          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1.5 text-xs text-buddy-text-secondary">
            <span className="flex items-center gap-1">
              <Users size={12} /> {gym.member_count}
            </span>
            {gym.is_reviews_enabled && gym.average_rating !== undefined && gym.average_rating > 0 && (
              <span className="flex items-center gap-1 text-yellow-500">
                <Star size={12} className="fill-current" /> {gym.average_rating.toFixed(1)}
                {gym.review_count ? ` (${gym.review_count})` : ''}
              </span>
            )}
            <span className="flex items-center gap-1">
              {accessIcon(gym.access_type)} {gym.access_type}
            </span>
            {gym.delivery_modes?.includes('virtual') && (
              <Badge variant="gold" label="Virtual" size="sm" />
            )}
            {gym.delivery_modes?.includes('hybrid') && (
              <Badge variant="green" label="Hybrid" size="sm" />
            )}
          </div>

          {(location || (showDistance && nearest !== undefined && nearest !== null)) && (
            <div className="flex items-center gap-3 mt-1 text-xs text-buddy-text-secondary">
              {location && (
                <span
                  className={`flex items-center gap-1 min-w-0 ${
                    location.highlight ? 'text-buddy-green font-medium' : ''
                  }`}
                >
                  {location.icon}
                  <span className="truncate">{location.text}</span>
                </span>
              )}
              {!location && showDistance && nearest !== undefined && nearest !== null && (
                <span className="flex items-center gap-1 text-buddy-green font-medium">
                  <MapPin size={12} /> {formatDistance(nearest)}
                </span>
              )}
            </div>
          )}
        </div>

        {followedCount > 0 && (
          <div className="flex flex-col items-end flex-shrink-0 self-center max-w-[38%]">
            <div className="flex items-center -space-x-2">
              {followed.slice(0, 4).map((member) => (
                <Avatar
                  key={member.user_id}
                  src={member.avatar_url}
                  alt={member.display_name || member.username}
                  size="xs"
                  className="ring-2 ring-buddy-surface"
                />
              ))}
              {followedCount > followed.slice(0, 4).length && (
                <span className="w-6 h-6 rounded-full bg-buddy-surface-raised text-buddy-text-secondary text-[10px] font-medium flex items-center justify-center ring-2 ring-buddy-surface">
                  +{followedCount - followed.slice(0, 4).length}
                </span>
              )}
            </div>
            <p className="text-[10px] text-buddy-text-secondary mt-1 text-right truncate max-w-full">
              {followed[0]?.display_name || followed[0]?.username}
              {followedCount > 1 ? ` +${followedCount - 1} others` : ''}
            </p>
          </div>
        )}
      </div>
    </Card>
  );
}

export default GymCard;
