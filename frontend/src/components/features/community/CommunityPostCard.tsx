import { useState } from 'react';
import {
  Heart, RotateCcw, Bookmark, MessageCircle, Share2, Pin,
  Users,
} from 'lucide-react';
import { messagingApi } from '@/api/messaging';

function timeAgo(iso: string): string {
  const seconds = Math.floor((Date.now() - new Date(iso).getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const mins = Math.floor(seconds / 60);
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d`;
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

interface CommunityPostCardProps {
  post: {
    id: string;
    body: string;
    media_url?: string;
    is_pinned?: boolean;
    like_count?: number;
    comment_count?: number;
    is_liked?: boolean;
    created_at: string;
    author_data: {
      user_id?: string;
      username: string;
      display_name: string;
      avatar_url: string;
    };
    community_id?: string;
    community_name?: string;
    repost_count?: number;
    save_count?: number;
    share_count?: number;
    reaction_counts?: { [key: string]: number };
    is_reposted_by_me?: boolean;
    is_saved_by_me?: boolean;
  };
  communityId?: string;
  onLike?: () => void;
  onRepost?: () => void;
  onSave?: () => void;
  onReact?: (reaction: string) => void;
  onShare?: () => void;
}

export function CommunityPostCard({ post, communityId, onLike, onRepost, onSave, onReact, onShare }: CommunityPostCardProps) {
  const [isLiked, setIsLiked] = useState(post.is_liked);
  const [likeCount, setLikeCount] = useState(post.like_count ?? 0);

  const handleLike = async () => {
    if (!communityId) return;
    try {
      await messagingApi.togglePostLike(communityId, post.id);
      setIsLiked(!isLiked);
      setLikeCount(isLiked ? likeCount - 1 : likeCount + 1);
      onLike?.();
    } catch { /* noop */ }
  };

  return (
    <div className="bg-buddy-surface rounded-xl border border-buddy-border overflow-hidden transition-colors hover:border-buddy-green/50">
      <div className="p-4">
        <div className="flex items-start justify-between gap-2 mb-3">
          <div className="flex items-center gap-2.5 min-w-0">
            {post.author_data.avatar_url ? (
              <img src={post.author_data.avatar_url} alt="" className="w-9 h-9 rounded-full object-cover" />
            ) : (
              <div className="w-9 h-9 rounded-full bg-buddy-surface-raised flex items-center justify-center">
                <Users size={16} className="text-buddy-green" />
              </div>
            )}
            <div className="min-w-0">
              <div className="flex items-center gap-1.5">
                <p className="font-semibold text-sm">{post.author_data.display_name}</p>
                {post.is_pinned && <Pin size={12} className="text-buddy-gold shrink-0" />}
              </div>
              <p className="text-xs text-buddy-text-secondary">
                @{post.author_data.username} · {timeAgo(post.created_at)}
              </p>
            </div>
          </div>
        </div>

        {post.body && <p className="mt-1 mb-3 text-sm whitespace-pre-wrap text-buddy-text-primary leading-relaxed">{post.body}</p>}
        {post.media_url && (
          <img src={post.media_url} alt="" className="mt-2 rounded-xl w-full object-cover max-h-96" />
        )}

        <div className="flex items-center gap-4 mt-4 pt-3 border-t border-buddy-surface">
          <button
            onClick={handleLike}
            className={`flex items-center gap-1.5 text-xs font-medium transition-colors ${isLiked ? 'text-buddy-red' : 'text-buddy-text-secondary hover:text-buddy-red'}`}
          >
            <Heart size={15} fill={isLiked ? 'currentColor' : 'none'} />{likeCount}
          </button>
          <button
            onClick={() => onRepost?.()}
            className={`flex items-center gap-1.5 text-xs font-medium transition-colors text-buddy-text-secondary hover:text-buddy-green`}
          >
            <RotateCcw size={15} />{post.repost_count || 0}
          </button>
          <button
            onClick={() => onSave?.()}
            className={`flex items-center gap-1.5 text-xs font-medium transition-colors text-buddy-text-secondary hover:text-buddy-green`}
          >
            <Bookmark size={15} />{post.save_count || 0}
          </button>
          <button
            onClick={() => {
              const reactions = Object.keys(post.reaction_counts ?? {});
              if (reactions.length > 0) onReact?.(reactions[0]);
              else onLike?.();
            }}
            className={`flex items-center gap-1.5 text-xs font-medium transition-colors text-buddy-text-secondary hover:text-buddy-green`}
          >
            <MessageCircle size={15} />{post.comment_count || 0}
          </button>
          <button onClick={onShare} className={`flex items-center gap-1.5 text-xs font-medium transition-colors text-buddy-text-secondary hover:text-buddy-purple`}>
            <Share2 size={15} />Share
          </button>
          {post.community_name && (
            <span className="ml-auto text-[10px] text-buddy-text-secondary/60 bg-buddy-surface-raised px-2 py-0.5 rounded-full">
              {post.community_name}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
