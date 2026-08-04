import { useState, useEffect, useRef } from 'react';
import {
  Share2, Pin, MoreHorizontal, Dumbbell,
  MapPin, Smile, CornerDownRight, ArrowUp, CornerUpRight
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api/feed';
import { RichText } from '@/components/ui/RichText';
import { EmojiImg } from '@/utils/emojiUtils';
import { useInViewAutoplay } from '@/hooks/useInViewAutoplay';
import { formatPostDate } from '@/utils/formatDate';
import type { Post, Comment } from '@/types';
import EmojiPicker, { Theme, EmojiStyle } from 'emoji-picker-react';

interface GymDiscoursePostProps {
  post: Post;
  isAdmin?: boolean;
  gymName?: string;
  onPin?: (postId: string, pinned: boolean) => void;
}

function MediaGallery({ urls }: { urls: string[] }) {
  const [idx, setIdx] = useState(0);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  useInViewAutoplay(videoRef);
  if (!urls.length) return null;
  const currentUrl = urls[idx];
  const isVideo = /\.(mp4|mov|webm)/i.test(currentUrl);
  const isAudio = /\.(mp3|wav|ogg|m4a)/i.test(currentUrl);
  return (
    <div className="mt-3 rounded-xl overflow-hidden bg-buddy-surface relative">
      {isVideo ? (
        <video ref={videoRef} src={currentUrl} controls muted loop playsInline preload="metadata" className="w-full max-h-80 object-cover" />
      ) : isAudio ? (
        <div className="p-4 bg-buddy-surface-raised w-full">
          <audio src={currentUrl} controls className="w-full" />
        </div>
      ) : (
        <img src={currentUrl} alt="" className="w-full max-h-80 object-cover" loading="lazy" />
      )}
      {urls.length > 1 && (
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1">
          {urls.map((_, i) => (
            <button key={i} onClick={(e) => { e.stopPropagation(); setIdx(i); }}
              className={`w-1.5 h-1.5 rounded-full transition-all ${i === idx ? 'bg-buddy-green w-3' : 'bg-white/40'}`} />
          ))}
        </div>
      )}
    </div>
  );
}

function ReplyCard({ reply, onReact }: { reply: Comment; onReact: (id: string) => void }) {
  const upvotes = reply.reaction_counts?.['💪'] ?? reply.reaction_counts?.pump ?? 0;
  const isUpvoted = reply.user_reaction === '💪' || reply.user_reaction === 'pump';
  return (
    <div className="flex gap-1 pl-2 border-l-2 border-buddy-green/30">
      <div className="flex-1 py-1">
        <div className="flex items-center gap-2 mb-1">
          <Avatar src={reply.author_data?.avatar_url} alt={reply.author_data?.display_name || ''} size="xs" />
          <span className="text-xs font-semibold text-buddy-text-primary">{reply.author_data?.display_name}</span>
          <span className="text-[10px] text-buddy-text-secondary">{formatPostDate(reply.created_at)}</span>
        </div>
        <p className="text-sm text-buddy-text-primary leading-relaxed">
          <RichText text={reply.body} />
        </p>
        <div className="flex items-center gap-4 mt-2 text-buddy-text-secondary text-[11px] font-medium">
          <button className="flex items-center gap-1 hover:text-buddy-green transition-colors">
            <CornerDownRight size={14} className="scale-x-[-1]" /> Reply
          </button>
          <button onClick={() => onReact(reply.id)} className={`flex items-center gap-1 transition-colors ${isUpvoted ? 'text-buddy-green' : 'hover:text-buddy-green'}`}>
            <ArrowUp size={14} /> {upvotes}
          </button>
          <button className="hover:text-buddy-green transition-colors">
            <MoreHorizontal size={14} />
          </button>
        </div>
      </div>
    </div>
  );
}

export function GymDiscoursePost({ post: initialPost, isAdmin, gymName, onPin }: GymDiscoursePostProps) {
  const [post, setPost] = useState<Post>(initialPost);
  const [replies, setReplies] = useState<Comment[]>([]);
  const [showReplies, setShowReplies] = useState(false);
  const [replyText, setReplyText] = useState('');
  const [showReplyInput, setShowReplyInput] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [showReactionPicker, setShowReactionPicker] = useState(false);
  const [heartPop, setHeartPop] = useState<{ show: boolean; x: number; y: number } | null>(null);

  useEffect(() => {
    if (showReplies) {
      feedApi.getComments(post.id).then(res => setReplies(res.data || [])).catch(() => {});
    }
  }, [showReplies, post.id]);

  const totalReactions = Object.values(post.reaction_counts || {}).reduce((a, b) => a + b, 0);
  const userReaction = post.user_reaction; // this is now the emoji string itself

  const reactionsArr = Object.entries(post.reaction_counts || {})
    .filter(([, count]) => count > 0)
    .sort((a, b) => b[1] - a[1]);
  const topReactions = reactionsArr.slice(0, 3);
  const remainingReactions = reactionsArr.slice(3);
  const remainingCount = remainingReactions.reduce((sum, [, count]) => sum + count, 0);

  const handleReact = async (emojiStr: string) => {
    setShowReactionPicker(false);
    try {
      if (userReaction === emojiStr) {
        await feedApi.unreact(post.id);
        setPost(prev => ({
          ...prev, user_reaction: null,
          reaction_counts: { ...prev.reaction_counts, [emojiStr]: Math.max((prev.reaction_counts[emojiStr] || 1) - 1, 0) },
        }));
      } else {
        await feedApi.react(post.id, emojiStr);
        const next = { ...(post.reaction_counts || {}) };
        if (userReaction && next[userReaction]) next[userReaction] = Math.max(next[userReaction] - 1, 0);
        next[emojiStr] = (next[emojiStr] || 0) + 1;
        setPost(prev => ({ ...prev, user_reaction: emojiStr, reaction_counts: next }));
      }
    } catch {}
  };

  const handleReplyReact = async (commentId: string, emojiStr: string = '💪') => {
    setReplies(prev => prev.map(r => {
      if (r.id !== commentId) return r;
      const was = r.user_reaction === emojiStr;
      return {
        ...r,
        user_reaction: was ? null : emojiStr,
        reaction_counts: {
          ...r.reaction_counts,
          [emojiStr]: Math.max((r.reaction_counts?.[emojiStr] || (was ? 1 : 0)) + (was ? -1 : 1), 0),
        },
      };
    }));
    try {
      const r = replies.find(x => x.id === commentId);
      if (r?.user_reaction === emojiStr) await feedApi.unreactComment(post.id, commentId);
      else await feedApi.reactComment(post.id, commentId, emojiStr);

    } catch {}
  };

  const handlePostReply = async () => {
    if (!replyText.trim()) return;
    setActionLoading(true);
    try {
      const res = await feedApi.comment(post.id, { body: replyText.trim() });
      setReplies(prev => [res.data, ...prev]);
      setPost(prev => ({ ...prev, comment_count: (prev.comment_count || 0) + 1 }));
      setReplyText('');
      setShowReplyInput(false);
      setShowReplies(true);
    } catch {}
    setActionLoading(false);
  };

  const handlePin = async () => {
    try {
      const res = await feedApi.pin(post.id);
      const pinned = res.data?.is_pinned ?? !post.is_pinned;
      setPost(prev => ({ ...prev, is_pinned: pinned }));
      onPin?.(post.id, pinned);
    } catch {}
  };

  const handleDoubleClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const emoji = '💪';
    if (userReaction !== emoji) {
      handleReact(emoji);
      const rect = e.currentTarget.getBoundingClientRect();
      setHeartPop({ show: true, x: e.clientX - rect.left, y: e.clientY - rect.top });
      setTimeout(() => setHeartPop(null), 700);
    }
  };

  return (
    <article className="rounded-2xl border border-buddy-surface-raised overflow-hidden bg-buddy-surface hover:border-buddy-green/25 transition-colors relative flex">
      {/* Green accent left stripe */}
      <div className="w-1 bg-buddy-green/60 flex-shrink-0" />

      {/* Main content */}
      <div onDoubleClick={handleDoubleClick} className="relative flex-1 min-w-0 p-4">
        {/* Pinned banner */}
        {post.is_pinned && (
          <div className="flex items-center gap-1.5 text-xs text-buddy-gold font-medium mb-2 bg-buddy-gold/10 rounded-lg px-2 py-1">
            <Pin size={10} /> Pinned post
          </div>
        )}

        {/* Gym context badge */}
        {gymName && (
          <div className="flex items-center gap-1.5 text-[10px] text-buddy-green font-medium mb-2">
            <Dumbbell size={10} /> Posted in {gymName}
          </div>
        )}

        {/* Author header */}
        <div className="flex items-start gap-2.5">
          <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || ''} size="sm" />
          <div className="flex-1 min-w-0 mt-0.5">
            <p className="text-sm text-buddy-text-secondary">
              <span className="font-semibold text-buddy-text-primary mr-2">{post.author_data?.display_name}</span>
              {formatPostDate(post.created_at)}
            </p>
            {post.location_label && (
              <span className="text-[10px] text-buddy-text-secondary flex items-center gap-0.5 mt-0.5">
                <MapPin size={9} /> {post.location_label}
              </span>
            )}
          </div>
          <div className="flex items-center gap-1">
            {isAdmin && (
              <button onClick={handlePin}
                className={`p-1.5 rounded-full transition-colors ${post.is_pinned ? 'text-buddy-gold bg-buddy-gold/10' : 'text-buddy-text-secondary hover:text-buddy-gold hover:bg-buddy-gold/10'}`}
                title={post.is_pinned ? 'Unpin' : 'Pin to top'}>
                <Pin size={14} />
              </button>
            )}
            <button className="p-1 rounded-full text-buddy-text-secondary hover:bg-buddy-surface-raised transition-colors">
              <MoreHorizontal size={16} />
            </button>
          </div>
        </div>

        {/* Post body */}
        {post.body && (
          <p className="mt-3 text-sm leading-relaxed whitespace-pre-wrap text-buddy-text-primary">
            <RichText text={post.body} />
          </p>
        )}

        {/* Media */}
        <MediaGallery urls={post.media_urls || []} />

        {/* Heart pop overlay */}
        {heartPop?.show && (
          <span
            className="absolute pointer-events-none text-3xl select-none animate-heart-pop"
            style={{ left: heartPop.x, top: heartPop.y }}
          >
            💪
          </span>
        )}

        {/* Bottom action bar */}
        <div className="mt-4 pt-4 border-t border-buddy-surface flex items-center justify-between text-xs font-medium">
          <div className="flex items-center gap-2">
            {/* Reply / comments */}
            <button
              onClick={() => { setShowReplyInput(p => !p); if (!showReplies && post.comment_count > 0) setShowReplies(true); }}
              onDoubleClick={(e) => e.stopPropagation()}
              className="flex items-center gap-1.5 p-2 bg-buddy-surface-raised rounded-lg hover:bg-buddy-green/10 hover:text-buddy-green transition-all active:scale-95 text-buddy-text-secondary"
            >
              <CornerDownRight size={14} className="scale-x-[-1]" />
              <span>{post.comment_count}</span>
            </button>

            {/* Upvote / React */}
            <div className="relative" onDoubleClick={(e) => e.stopPropagation()}>
              <button onClick={() => setShowReactionPicker(p => !p)}
                className={`flex items-center gap-1.5 p-2 rounded-lg transition-all active:scale-95 ${userReaction ? 'bg-buddy-green/10 text-buddy-green' : 'bg-buddy-surface-raised text-buddy-text-secondary hover:bg-buddy-green/10 hover:text-buddy-green'}`}>
                <Smile size={16} />
                {totalReactions > 0 && (
                  <div className="flex items-center gap-1 ml-1">
                    <div className="flex -space-x-1">
                      {topReactions.map(([emojiChar]) => (
                        <EmojiImg key={emojiChar} emoji={emojiChar} size={18} className="z-10 rounded-full" />
                      ))}
                    </div>
                    {remainingCount > 0 && <span className="text-[10px] ml-1">+{remainingCount}</span>}
                    <span className="ml-1 text-[11px] font-semibold">{totalReactions}</span>
                  </div>
                )}
              </button>
              {showReactionPicker && (
                <>
                  <div className="fixed inset-0 z-10" onClick={() => setShowReactionPicker(false)} />
                  <div className="absolute bottom-full left-0 mb-2 z-20 shadow-2xl">
                    <EmojiPicker
                      theme={Theme.DARK}
                      emojiStyle={EmojiStyle.APPLE}
                      onEmojiClick={(emojiData) => handleReact(emojiData.emoji)}
                      lazyLoadEmojis
                      searchDisabled
                      skinTonesDisabled
                      width={320}
                      height={350}
                    />
                  </div>
                </>
              )}
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button onDoubleClick={(e) => e.stopPropagation()} className="flex items-center gap-1.5 p-2 bg-buddy-surface-raised rounded-lg hover:bg-buddy-green/10 hover:text-buddy-green transition-all active:scale-95 text-buddy-text-secondary">
              <Share2 size={15} /> Share
            </button>
            <button onDoubleClick={(e) => e.stopPropagation()} className="flex items-center gap-1.5 p-2 bg-buddy-surface-raised rounded-lg hover:bg-buddy-green/10 hover:text-buddy-green transition-all active:scale-95 text-buddy-text-secondary">
              <CornerUpRight size={15} /> Forward
            </button>
          </div>
        </div>

        {/* Reply input */}
        {showReplyInput && (
          <div className="mt-3 flex gap-2 items-end">
            <textarea
              value={replyText}
              onChange={e => setReplyText(e.target.value)}
              placeholder="Write a reply..."
              rows={2}
              className="flex-1 bg-buddy-surface-raised text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 rounded-xl px-3 py-2 outline-none resize-none focus:ring-1 focus:ring-buddy-green/40"
              onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handlePostReply(); } }}
            />
            <button onClick={handlePostReply} disabled={!replyText.trim() || actionLoading}
              className="px-3 py-2 bg-buddy-green text-buddy-black text-xs font-bold rounded-xl disabled:opacity-40 hover:bg-buddy-green/90 transition-colors">
              Reply
            </button>
          </div>
        )}

        {/* Replies thread */}
        {showReplies && replies.length > 0 && (
          <div className="mt-3 space-y-2">
            {replies.map(r => (
              <ReplyCard key={r.id} reply={r} onReact={handleReplyReact} />
            ))}
          </div>
        )}
      </div>
    </article>
  );
}
