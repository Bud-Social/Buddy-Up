import { useState, useEffect, useRef } from 'react';
import {
  X, Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  Send, MoreHorizontal, Dumbbell, MapPin, ChevronLeft, ChevronRight,
  BarChart2, TrendingUp, Utensils,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api';
import { formatPostDate } from '@/utils/formatDate';
import type { Post, Comment } from '@/types';
import EmojiPicker, { Theme, EmojiStyle } from 'emoji-picker-react';
import { useNavigate } from 'react-router-dom';

interface PostDetailModalProps {
  post: Post;
  onClose: () => void;
  onUpdate?: (post: Post) => void;
}

function MediaSlider({ urls }: { urls: string[] }) {
  const [idx, setIdx] = useState(0);
  if (!urls.length) return null;
  const url = urls[idx];
  const isVideo = /\.(mp4|mov|webm)/i.test(url);
  const isAudio = /\.(mp3|wav|ogg|m4a)/i.test(url);

  return (
    <div className="relative bg-black flex-shrink-0" style={{ maxHeight: '60vh' }}>
      {isVideo ? (
        <video src={url} controls autoPlay muted loop className="w-full h-full object-contain" style={{ maxHeight: '60vh' }} />
      ) : isAudio ? (
        <div className="p-6 flex items-center justify-center min-h-[120px]">
          <audio src={url} controls className="w-full" />
        </div>
      ) : (
        <img src={url} alt="" className="w-full object-contain" style={{ maxHeight: '60vh' }} loading="lazy" />
      )}
      {urls.length > 1 && (
        <>
          <button
            onClick={() => setIdx(i => Math.max(0, i - 1))}
            disabled={idx === 0}
            className="absolute left-2 top-1/2 -translate-y-1/2 p-1.5 bg-black/60 rounded-full text-white disabled:opacity-30 hover:bg-black/80 transition-all"
          >
            <ChevronLeft size={18} />
          </button>
          <button
            onClick={() => setIdx(i => Math.min(urls.length - 1, i + 1))}
            disabled={idx === urls.length - 1}
            className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 bg-black/60 rounded-full text-white disabled:opacity-30 hover:bg-black/80 transition-all"
          >
            <ChevronRight size={18} />
          </button>
          <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1">
            {urls.map((_, i) => (
              <button key={i} onClick={() => setIdx(i)}
                className={`w-1.5 h-1.5 rounded-full transition-all ${i === idx ? 'bg-white w-3' : 'bg-white/40'}`} />
            ))}
          </div>
        </>
      )}
    </div>
  );
}

function CommentRow({ comment, onReply }: { comment: Comment; onReply: (id: string) => void }) {
  const navigate = useNavigate();
  return (
    <div className="flex gap-2 group">
      <button onClick={() => navigate(`/${comment.author_data?.username}`)} className="flex-shrink-0 mt-0.5">
        <Avatar src={comment.author_data?.avatar_url} alt={comment.author_data?.display_name || ''} size="xs" />
      </button>
      <div className="flex-1 min-w-0">
        <div className="bg-buddy-surface-raised rounded-xl px-3 py-2">
          <button
            onClick={() => navigate(`/${comment.author_data?.username}`)}
            className="text-xs font-semibold hover:text-buddy-green transition-colors"
          >
            {comment.author_data?.display_name}
          </button>
          <p className="text-sm leading-relaxed mt-0.5 break-words">{comment.body}</p>
        </div>
        <div className="flex items-center gap-3 mt-1 px-1">
          <span className="text-[10px] text-buddy-text-secondary">{formatPostDate(comment.created_at)}</span>
          <button
            onClick={() => onReply(comment.id)}
            className="text-[10px] font-semibold text-buddy-text-secondary hover:text-buddy-green transition-colors"
          >
            Reply
          </button>
        </div>
      </div>
    </div>
  );
}

export function PostDetailModal({ post: initialPost, onClose, onUpdate }: PostDetailModalProps) {
  const navigate = useNavigate();
  const [post, setPost] = useState<Post>(initialPost);
  const [comments, setComments] = useState<Comment[]>([]);
  const [commentText, setCommentText] = useState('');
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [showReactionPicker, setShowReactionPicker] = useState(false);
  const [isSaved, setIsSaved] = useState(post.is_saved ?? false);
  const [userReaction, setUserReaction] = useState(post.user_reaction);
  const [reactionCounts, setReactionCounts] = useState(post.reaction_counts || {});
  const [commentSubmitting, setCommentSubmitting] = useState(false);
  const commentInputRef = useRef<HTMLInputElement>(null);

  const totalReactions = Object.values(reactionCounts).reduce((a, b) => a + b, 0);
  const reactionsArr = Object.entries(reactionCounts).filter(([_, c]) => c > 0).sort((a, b) => b[1] - a[1]);
  const topReactions = reactionsArr.slice(0, 3);
  const remainingCount = reactionsArr.slice(3).reduce((s, [_, c]) => s + c, 0);

  const displayPost = (post.is_repost && post.original_post_data) ? post.original_post_data : post;
  const displayAuthor = displayPost.author_data;

  useEffect(() => {
    feedApi.getComments(post.id)
      .then(res => setComments(res.data || []))
      .catch(() => {});
  }, [post.id]);

  // Close on Escape
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  const handleReact = async (emojiStr: string) => {
    setShowReactionPicker(false);
    try {
      if (userReaction === emojiStr) {
        await feedApi.unreact(post.id);
        setUserReaction(null);
        setReactionCounts(prev => {
          const next = { ...prev };
          if (next[emojiStr] > 1) next[emojiStr]--;
          else delete next[emojiStr];
          return next;
        });
      } else {
        await feedApi.react(post.id, emojiStr);
        setReactionCounts(prev => {
          const next = { ...prev };
          if (userReaction && next[userReaction]) {
            if (next[userReaction] > 1) next[userReaction]--;
            else delete next[userReaction];
          }
          next[emojiStr] = (next[emojiStr] || 0) + 1;
          return next;
        });
        setUserReaction(emojiStr);
      }
    } catch {}
  };

  const handleComment = async () => {
    if (!commentText.trim() || commentSubmitting) return;
    setCommentSubmitting(true);
    try {
      const res = await feedApi.comment(post.id, { body: commentText.trim(), parent_id: replyingTo || undefined });
      setComments(prev => [...prev, res.data]);
      setCommentText('');
      setReplyingTo(null);
      setPost(prev => ({ ...prev, comment_count: (prev.comment_count || 0) + 1 }));
    } catch {}
    setCommentSubmitting(false);
  };

  const handleSave = async () => {
    setIsSaved(s => !s);
    try { await feedApi.save(post.id); } catch {}
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-black/85 flex items-center justify-center p-2 md:p-4"
      onClick={onClose}
    >
      <div
        className="relative bg-buddy-surface rounded-2xl overflow-hidden flex flex-col md:flex-row w-full max-w-4xl max-h-[95vh] shadow-2xl"
        style={{ minHeight: '400px' }}
        onClick={e => e.stopPropagation()}
      >
        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 z-20 p-1.5 rounded-full bg-buddy-black/70 text-white hover:bg-buddy-black transition-colors md:hidden"
        >
          <X size={18} />
        </button>
        <button
          onClick={onClose}
          className="absolute -top-10 right-0 z-20 p-1.5 rounded-full bg-buddy-black/70 text-white hover:bg-buddy-black transition-colors hidden md:flex items-center gap-1"
        >
          <X size={18} />
        </button>

        {/* Left: Media (if any) */}
        {(displayPost.media_urls && displayPost.media_urls.length > 0) ? (
          <div className="md:w-1/2 bg-black flex items-center justify-center flex-shrink-0">
            <MediaSlider urls={displayPost.media_urls} />
          </div>
        ) : null}

        {/* Right: Content + Comments */}
        <div className={`flex flex-col flex-1 overflow-hidden ${displayPost.media_urls?.length ? '' : 'w-full'}`}>
          {/* Header */}
          <div className="flex items-center gap-3 px-4 py-3 border-b border-buddy-surface-raised flex-shrink-0">
            {post.is_repost && (
              <div className="w-full px-4 py-2 bg-buddy-green/10 border-l-2 border-buddy-green text-xs text-buddy-green flex items-center gap-2">
                <Avatar src={post.author_data?.avatar_url} alt="" size="xs" className="ring-1 ring-buddy-green/40" />
                <span className="font-semibold">{post.author_data?.display_name}</span> reposted
              </div>
            )}
            {!post.is_repost && (
              <>
                <button onClick={() => { navigate(`/${displayAuthor?.username}`); onClose(); }}>
                  <Avatar src={displayAuthor?.avatar_url} alt={displayAuthor?.display_name || ''} size="sm" />
                </button>
                <div className="flex-1 min-w-0">
                  <button
                    onClick={() => { navigate(`/${displayAuthor?.username}`); onClose(); }}
                    className="font-semibold text-sm hover:text-buddy-green transition-colors block truncate"
                  >
                    {displayAuthor?.display_name}
                  </button>
                  <p className="text-xs text-buddy-text-secondary">
                    @{displayAuthor?.username} · {formatPostDate(displayPost.created_at)}
                  </p>
                </div>
                <button className="p-1 text-buddy-text-secondary hover:text-buddy-text-primary flex-shrink-0">
                  <MoreHorizontal size={18} />
                </button>
              </>
            )}
          </div>

          {/* Body text */}
          <div className="flex-1 overflow-y-auto px-4 py-3 space-y-4" style={{ minHeight: 0 }}>
            {displayPost.body && (
              <div className="flex gap-2">
                <button onClick={() => { navigate(`/${displayAuthor?.username}`); onClose(); }} className="flex-shrink-0">
                  <Avatar src={displayAuthor?.avatar_url} alt="" size="xs" />
                </button>
                <div className="bg-buddy-surface-raised rounded-xl px-3 py-2 flex-1">
                  <button
                    onClick={() => { navigate(`/${displayAuthor?.username}`); onClose(); }}
                    className="text-xs font-semibold hover:text-buddy-green transition-colors"
                  >
                    {displayAuthor?.display_name}
                  </button>
                  <p className="text-sm leading-relaxed mt-0.5 break-words whitespace-pre-wrap">{displayPost.body}</p>
                </div>
              </div>
            )}

            {/* Media for mobile (when layout is stacked) */}
            {(displayPost.media_urls && displayPost.media_urls.length > 0) && (
              <div className="md:hidden">
                <MediaSlider urls={displayPost.media_urls} />
              </div>
            )}

            {/* Poll */}
            {(displayPost as any).poll && (
              <div className="bg-buddy-surface-raised rounded-xl p-4 border border-buddy-surface">
                <div className="flex items-center gap-2 mb-3">
                  <BarChart2 size={14} className="text-buddy-electric" />
                  <p className="text-sm font-medium">{(displayPost as any).poll.question}</p>
                </div>
              </div>
            )}

            {/* Comments */}
            <div className="space-y-3 pb-2">
              {comments.map(c => (
                <CommentRow key={c.id} comment={c} onReply={(id) => {
                  setReplyingTo(id);
                  commentInputRef.current?.focus();
                }} />
              ))}
              {comments.length === 0 && (
                <p className="text-sm text-center text-buddy-text-secondary py-4">No comments yet. Be the first!</p>
              )}
            </div>
          </div>

          {/* Action bar */}
          <div className="border-t border-buddy-surface-raised flex-shrink-0">
            <div className="flex items-center justify-between px-4 py-2">
              {/* Reactions */}
              <div className="flex items-center gap-1">
                {/* React */}
                <div className="relative">
                  <button
                    onClick={() => setShowReactionPicker(p => !p)}
                    className={`flex items-center gap-1 p-2 rounded-lg transition-all ${userReaction ? 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}
                  >
                    <Heart size={22} className={userReaction ? 'fill-buddy-green' : ''} />
                  </button>
                  {showReactionPicker && (
                    <>
                      <div className="fixed inset-0 z-30" onClick={() => setShowReactionPicker(false)} />
                      <div className="absolute bottom-full left-0 mb-2 z-40 shadow-2xl">
                        <EmojiPicker
                          theme={Theme.DARK}
                          emojiStyle={EmojiStyle.APPLE}
                          onEmojiClick={(emojiData) => handleReact(emojiData.emoji)}
                          lazyLoadEmojis
                          searchDisabled={false}
                          skinTonesDisabled
                          height={350}
                        />
                      </div>
                    </>
                  )}
                </div>

                {/* Comment */}
                <button
                  onClick={() => commentInputRef.current?.focus()}
                  className="p-2 text-buddy-text-secondary hover:text-buddy-green transition-colors"
                >
                  <MessageCircle size={22} />
                </button>

                {/* Repost */}
                <button className="p-2 text-buddy-text-secondary hover:text-buddy-electric transition-colors">
                  <Repeat2 size={22} />
                </button>
              </div>

              {/* Save */}
              <button onClick={handleSave} className={`p-2 transition-colors ${isSaved ? 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}>
                {isSaved ? <BookmarkCheck size={22} /> : <Bookmark size={22} />}
              </button>
            </div>

            {/* Reactions summary */}
            {totalReactions > 0 && (
              <div className="px-4 pb-2 flex items-center gap-1.5">
                <div className="flex -space-x-1">
                  {topReactions.map(([emoji]) => (
                    <span key={emoji} className="text-base leading-none">{emoji}</span>
                  ))}
                </div>
                <span className="text-xs font-medium text-buddy-text-secondary">
                  {totalReactions} reaction{totalReactions !== 1 ? 's' : ''}
                  {remainingCount > 0 && ` (+${remainingCount} more)`}
                </span>
              </div>
            )}

            {/* Post date */}
            <div className="px-4 pb-1">
              <span className="text-[11px] text-buddy-text-secondary">{formatPostDate(displayPost.created_at)}</span>
            </div>

            {/* Comment input */}
            <div className="border-t border-buddy-surface-raised px-3 py-2 flex items-center gap-2">
              {replyingTo && (
                <div className="flex items-center gap-1 text-xs text-buddy-green bg-buddy-green/10 px-2 py-1 rounded-full">
                  Replying
                  <button onClick={() => setReplyingTo(null)} className="ml-1 hover:text-red-400 transition-colors">
                    <X size={10} />
                  </button>
                </div>
              )}
              <div className="relative flex-shrink-0">
                <button
                  onClick={() => setShowEmojiPicker(p => !p)}
                  className="text-buddy-text-secondary hover:text-buddy-green transition-colors p-1"
                >
                  😊
                </button>
                {showEmojiPicker && (
                  <>
                    <div className="fixed inset-0 z-30" onClick={() => setShowEmojiPicker(false)} />
                    <div className="absolute bottom-full left-0 mb-2 z-40 shadow-2xl">
                      <EmojiPicker
                        theme={Theme.DARK}
                        emojiStyle={EmojiStyle.APPLE}
                        onEmojiClick={(emojiData) => {
                          setCommentText(t => t + emojiData.emoji);
                        }}
                        lazyLoadEmojis
                        height={300}
                      />
                    </div>
                  </>
                )}
              </div>
              <input
                ref={commentInputRef}
                type="text"
                value={commentText}
                onChange={e => setCommentText(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleComment(); } }}
                placeholder="Add a comment..."
                className="flex-1 bg-transparent text-sm outline-none placeholder:text-buddy-text-secondary/50 min-w-0"
              />
              <button
                onClick={handleComment}
                disabled={!commentText.trim() || commentSubmitting}
                className="text-buddy-green font-semibold text-sm disabled:opacity-30 transition-all hover:text-buddy-green/80 flex-shrink-0"
              >
                <Send size={18} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
