import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { profilesApi } from '@/api';
import { useAuthStore } from '@/store/authStore';
import type { AuthorData } from '@/types';

const VERIFICATION_BADGES: Record<string, { label: string; className: string }> = {
  trainer: { label: 'Trainer', className: 'bg-buddy-green/20 text-buddy-green' },
  practitioner: { label: 'Practitioner', className: 'bg-buddy-gold/20 text-buddy-gold' },
  shop: { label: 'Shop', className: 'bg-buddy-electric/20 text-buddy-electric' },
  gym: { label: 'Gym', className: 'bg-buddy-green/20 text-buddy-green' },
};

export function VerificationBadge({ status, dark = false }: { status?: string; dark?: boolean }) {
  if (!status) return null;
  const badge = VERIFICATION_BADGES[status];
  if (!badge) return null;
  return (
    <span
      className={`text-[10px] px-1.5 py-0.5 rounded-full font-medium leading-tight shrink-0 ${badge.className} ${
        dark ? 'ring-1 ring-white/20' : ''
      }`}
    >
      {badge.label}
    </span>
  );
}

interface AuthorChipProps {
  author: AuthorData;
  /** Show follow/unfollow (hidden automatically for your own profile). */
  showFollow?: boolean;
  /** Known follow state; when omitted the button starts as "Follow". */
  initialFollowing?: boolean;
  tone?: 'default' | 'onDark';
  compact?: boolean;
  onFollowChange?: (following: boolean) => void;
  /** View count rendered between the name block and the follow button. */
  viewCount?: number | null;
}

/**
 * Shared author identity: avatar + display name + @username + verification
 * badge + follow/unfollow (never rendered for your own profile).
 */
export function AuthorChip({
  author,
  showFollow = true,
  initialFollowing,
  tone = 'default',
  compact = false,
  onFollowChange,
  viewCount,
}: AuthorChipProps) {
  const navigate = useNavigate();
  const ownUsername = useAuthStore((s) => s.profile?.username);
  const [following, setFollowing] = useState(initialFollowing ?? false);
  const [pending, setPending] = useState(false);

  const dark = tone === 'onDark';
  const isOwn = !!ownUsername && !!author?.username && ownUsername === author.username;
  const nameCls = dark ? 'text-white' : 'text-buddy-text-primary';
  const subCls = dark ? 'text-white/70' : 'text-buddy-text-secondary';

  const goToProfile = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (author?.username) navigate(`/${author.username}`);
  };

  const toggleFollow = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!author?.username || pending) return;
    const prev = following;
    setFollowing(!prev);
    setPending(true);
    try {
      if (prev) await profilesApi.unfollow(author.username);
      else await profilesApi.follow(author.username);
      onFollowChange?.(!prev);
    } catch {
      setFollowing(prev);
      onFollowChange?.(prev);
    } finally {
      setPending(false);
    }
  };

  return (
    <div className="flex items-center gap-2.5 min-w-0" data-testid="author-chip">
      <button onClick={goToProfile} className="flex-shrink-0" aria-label={`View ${author?.display_name || 'author'} profile`}>
        <Avatar
          src={author?.avatar_url}
          alt={author?.display_name || 'User'}
          size={compact ? 'sm' : 'md'}
          verificationStatus={author?.verification_status}
        />
      </button>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-1.5 min-w-0">
          <button
            onClick={goToProfile}
            className={`font-semibold text-sm truncate leading-tight transition-colors ${
              dark ? 'text-white' : `hover:text-buddy-green ${nameCls}`
            }`}
          >
            {author?.display_name}
          </button>
          <VerificationBadge status={author?.verification_status} dark={dark} />
        </div>
        {!compact && (
          <p className={`text-xs leading-tight truncate ${subCls}`}>@{author?.username}</p>
        )}
      </div>
      {viewCount != null && (
        <span
          className={`shrink-0 inline-flex items-center gap-1 text-[11px] font-medium tabular-nums ${dark ? 'text-white/70' : 'text-buddy-text-secondary'}`}
          title={`${viewCount} views`}
          aria-label={`${viewCount} views`}
        >
          <Eye size={13} /> {viewCount >= 1000 ? `${(viewCount / 1000).toFixed(1)}k` : viewCount}
        </span>
      )}
      {showFollow && !isOwn && author?.username && (
        <button
          type="button"
          onClick={toggleFollow}
          disabled={pending}
          aria-label={following ? `Unfollow ${author.username}` : `Follow ${author.username}`}
          aria-pressed={following}
          className={`shrink-0 text-xs font-semibold px-3 py-1.5 rounded-full transition-colors disabled:opacity-50 ${
            following
              ? dark
                ? 'bg-white/15 text-white hover:bg-white/25'
                : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'
              : 'bg-buddy-green text-buddy-black hover:bg-buddy-green/90'
          }`}
        >
          {following ? 'Following' : 'Follow'}
        </button>
      )}
    </div>
  );
}
