import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, UserPlus } from 'lucide-react';
import { PostCard, type PostCardProps } from './PostCard';
import { messagingApi } from '@/api';
import { useToast } from '@/components/ui/Toast';

export interface CommunityPostCardProps
  extends Omit<PostCardProps, 'communityId' | 'headerAction' | 'footerSlot'> {
  communityId?: string;
  isMember?: boolean;
}

/**
 * Community flavour of the shared PostCard design.
 *
 * Keeps every community-specific concern (join action, origin-community tag,
 * popover navigation) out of the generic feed card. The visual design is
 * identical because it renders the same PostCard with two slots:
 *
 *  - `headerAction` → Join button next to the view counter (non-members only)
 *  - `footerSlot`   → origin-community tag at the bottom-left of the card
 */
export function CommunityPostCard({
  communityId,
  isMember = false,
  ...postCardProps
}: CommunityPostCardProps) {
  const navigate = useNavigate();
  const { toast } = useToast();
  const { post } = postCardProps;

  const communityName = post.community_name || 'Community';
  const coverUrl = post.community_cover_url || '';

  const [joinedLocally, setJoinedLocally] = useState(false);
  const [joinPending, setJoinPending] = useState(false);
  const [showPopover, setShowPopover] = useState(false);

  // Deterministic hue so a community keeps the same colour across cards.
  const hue = useMemo(() => {
    const key = communityId ?? '';
    let h = 0;
    for (let i = 0; i < key.length; i++) h = (h * 31 + key.charCodeAt(i)) % 360;
    return h;
  }, [communityId]);

  const openCommunity = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowPopover(false);
    if (communityId) navigate(`/communities/${communityId}`);
  };

  const handleJoin = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!communityId || joinPending) return;
    setJoinPending(true);
    try {
      await messagingApi.joinCommunity(communityId);
      setJoinedLocally(true);
      toast('success', 'Joined community');
    } catch {
      toast('error', 'Could not join this community.');
    } finally {
      setJoinPending(false);
    }
  };

  const headerAction = communityId && !isMember && !joinedLocally ? (
    <button
      type="button"
      onClick={handleJoin}
      disabled={joinPending}
      aria-label="Join community"
      className="inline-flex items-center gap-1 shrink-0 text-[11px] font-semibold text-buddy-black bg-buddy-green hover:bg-buddy-green/90 px-2.5 py-1 rounded-full transition-colors disabled:opacity-50"
    >
      <UserPlus size={12} />
      {joinPending ? 'Joining…' : 'Join'}
    </button>
  ) : null;

  const footerSlot = communityId && post.community_name ? (
    <div className="relative mt-3 flex items-center">
      <button
        type="button"
        onClick={(e) => { e.stopPropagation(); setShowPopover((v) => !v); }}
        onDoubleClick={(e) => e.stopPropagation()}
        aria-label={`Community: ${communityName}`}
        aria-expanded={showPopover}
        className="inline-flex items-center gap-1.5 pl-1 pr-2.5 py-1 rounded-full text-[11px] font-semibold transition-colors"
        style={{
          backgroundColor: `hsl(${hue} 65% 50% / 0.15)`,
          color: `hsl(${hue} 80% 68%)`,
        }}
      >
        {coverUrl ? (
          <img
            src={coverUrl}
            alt=""
            className="w-6 h-6 rounded-full object-cover ring-1 ring-white/10 shrink-0"
          />
        ) : (
          <span
            className="w-6 h-6 rounded-full flex items-center justify-center shrink-0"
            style={{ backgroundColor: `hsl(${hue} 65% 50% / 0.3)` }}
          >
            <Users size={12} />
          </span>
        )}
        <span className="truncate max-w-[160px]">{communityName}</span>
      </button>

      {showPopover && (
        <>
          <div
            className="fixed inset-0 z-10"
            onClick={(e) => { e.stopPropagation(); setShowPopover(false); }}
          />
          <div className="absolute left-0 bottom-full mb-2 z-20 w-60 rounded-2xl bg-buddy-surface-raised border border-buddy-surface shadow-2xl overflow-hidden">
            <button
              type="button"
              onClick={openCommunity}
              className="block w-full h-24 overflow-hidden"
              aria-label={`Open ${communityName}`}
            >
              {coverUrl ? (
                <img
                  src={coverUrl}
                  alt={communityName}
                  className="w-full h-full object-cover hover:opacity-90 transition-opacity"
                />
              ) : (
                <div
                  className="w-full h-full flex items-center justify-center"
                  style={{ backgroundColor: `hsl(${hue} 45% 22%)` }}
                >
                  <Users size={26} style={{ color: `hsl(${hue} 80% 70%)` }} />
                </div>
              )}
            </button>
            <div className="p-3">
              <button
                type="button"
                onClick={openCommunity}
                className="flex items-center gap-2 w-full text-left group"
              >
                {coverUrl ? (
                  <img src={coverUrl} alt="" className="w-8 h-8 rounded-lg object-cover shrink-0" />
                ) : (
                  <span
                    className="w-8 h-8 rounded-lg flex items-center justify-center shrink-0"
                    style={{
                      backgroundColor: `hsl(${hue} 65% 50% / 0.3)`,
                      color: `hsl(${hue} 80% 70%)`,
                    }}
                  >
                    <Users size={16} />
                  </span>
                )}
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-buddy-text-primary truncate group-hover:text-buddy-green transition-colors">
                    {communityName}
                  </p>
                  <p className="text-[11px] text-buddy-text-secondary">View community</p>
                </div>
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  ) : null;

  return (
    <PostCard
      {...postCardProps}
      communityId={communityId}
      headerAction={headerAction}
      footerSlot={footerSlot}
    />
  );
}
