import { useState, useEffect, useCallback, useRef } from 'react';
import { X, Send, Heart, Flag, MoreHorizontal, UserPlus, MessageCircle, Smile, Image as ImageIcon, Video as VideoIcon, Link2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { RichText } from '@/components/ui/RichText';
import { feedApi } from '@/api';
import { messagingApi } from '@/api/messaging';
import { profilesApi } from '@/api/profiles';
import { track } from '@/lib/analytics';
import { isProfanityFilterEnabled, maskProfanity } from '@/lib/profanity';
import type { Comment } from '@/types';

interface CommentSheetProps {
  postId: string;
  communityId?: string;
  isOpen: boolean;
  onClose: () => void;
}

const LIKE_REACTION = '❤️';

const likeCount = (comment: Comment) => comment.reaction_counts?.[LIKE_REACTION] || 0;

export function CommentSheet({ postId, communityId, isOpen, onClose }: CommentSheetProps) {
  const [comments, setComments] = useState<Comment[]>([]);
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [sort, setSort] = useState<'newest' | 'oldest' | 'top'>('newest');
  const [moreOptionsOpen, setMoreOptionsOpen] = useState<string | null>(null);
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [replyBody, setReplyBody] = useState('');
  const [replyMedia, setReplyMedia] = useState<{ type: 'image' | 'video' | 'gif' | 'sticker'; url: string } | null>(null);
  const [uploadingMedia, setUploadingMedia] = useState(false);
  const [stickerPickerOpen, setStickerPickerOpen] = useState(false);
  const [likedComments, setLikedComments] = useState<Set<string>>(new Set());
  const replyFileRef = useRef<HTMLInputElement>(null);
  const replyFileType = useRef<'image' | 'video' | 'gif'>('image');
  const scrollRef = useRef<HTMLDivElement>(null);

  const fetchComments = useCallback(() => {
    if (communityId) {
      messagingApi.getPostComments(communityId, postId).then((res) => {
        const rows = res as unknown as Comment[];
        setComments(rows);
        setLikedComments(new Set(rows.filter((c) => c.user_reaction).map((c) => c.id)));
      }).catch(() => {});
    } else {
      feedApi.getComments(postId).then((res) => {
        const rows = res.data || [];
        setComments(rows);
        setLikedComments(new Set(rows.filter((c) => c.user_reaction).map((c) => c.id)));
      }).catch(() => {});
    }
  }, [communityId, postId]);

  useEffect(() => {
    if (!isOpen) return;
    fetchComments();
  }, [isOpen, postId, communityId, fetchComments]);

  // Lock background scroll while the sheet is open
  useEffect(() => {
    if (!isOpen) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prev;
    };
  }, [isOpen]);

  const handleSubmit = async () => {
    if (!body.trim()) return;
    setIsLoading(true);
    try {
      let newComment: Comment | null = null;
      if (communityId) {
        const res = await messagingApi.addPostComment(communityId, postId, body.trim());
        // messagingApi already unwraps the envelope; map it to the comment shape.
        newComment = res as unknown as Comment;
      } else {
        newComment = (await feedApi.comment(postId, { body: body.trim() })) as unknown as Comment;
      }
      if (newComment) {
        setComments((prev) => [newComment, ...prev]);
      }
      setBody('');
      track('feed.comment_submit', { surface: 'feed', object_type: 'post', object_id: postId });
    } catch {} finally { setIsLoading(false); }
  };

  const handleReplySubmit = async (commentId: string) => {
    if ((!replyBody.trim() && !replyMedia) || uploadingMedia) return;
    const media = replyMedia
      ? {
          media_type: replyMedia.type,
          media_url: replyMedia.type === 'sticker' ? '' : replyMedia.url,
          sticker_pack: replyMedia.type === 'sticker' ? 'emoji' : '',
        }
      : undefined;
    const text = replyBody.trim() || (replyMedia?.type === 'sticker' ? replyMedia.url : '');
    try {
      let newComment: Comment | null = null;
      if (communityId) {
        const res = await messagingApi.addPostComment(communityId, postId, text, commentId, media);
        newComment = res as unknown as Comment;
      } else {
        newComment = (await feedApi.comment(postId, {
          body: text,
          parent_id: commentId,
          ...media,
        })) as unknown as Comment;
      }
      if (newComment) {
        setComments((prev) => {
          const updated = prev.map((c) => c.id === commentId ? { ...c, reply_count: (c.reply_count || 0) + 1 } : c);
          // The community endpoint returns replies inline, so show the new
          // reply immediately. Feed comments only list top-level rows.
          return communityId ? [newComment as Comment, ...updated] : updated;
        });
      }
      setReplyBody('');
      setReplyMedia(null);
      setReplyingTo(null);
    } catch {}
  };

  const openReplyFilePicker = (type: 'image' | 'video' | 'gif') => {
    replyFileType.current = type;
    replyFileRef.current?.click();
  };

  const handleReplyFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    setUploadingMedia(true);
    try {
      const res = await feedApi.uploadCommentMedia(file);
      setReplyMedia({ type: replyFileType.current, url: res.url });
    } catch {} finally {
      setUploadingMedia(false);
    }
  };

  const STICKER_EMOJIS = ['💪', '🔥', '❤️', '👏', '😂', '🤝', '🏋️', '🥇'];

  const toggleCommentLike = async (commentId: string, e?: React.MouseEvent) => {
    e?.stopPropagation();
    const wasLiked = likedComments.has(commentId);
    setLikedComments((prev) => {
      const next = new Set(prev);
      if (wasLiked) next.delete(commentId); else next.add(commentId);
      return next;
    });
    // Optimistic like count update
    setComments((prev) => prev.map((c) => {
      if (c.id !== commentId) return c;
      const currentLikes = c.reaction_counts?.[LIKE_REACTION] || 0;
      return { ...c, reaction_counts: { ...c.reaction_counts, [LIKE_REACTION]: wasLiked ? Math.max(0, currentLikes - 1) : currentLikes + 1 } };
    }));

    try {
      if (communityId) {
        const res = await messagingApi.toggleCommunityCommentLike(communityId, postId, commentId);
        setComments((prev) => prev.map((c) => c.id === commentId
          ? { ...c, reaction_counts: res.reaction_counts, user_reaction: res.user_reaction }
          : c));
        setLikedComments((prev) => {
          const next = new Set(prev);
          if (res.is_liked) next.add(commentId); else next.delete(commentId);
          return next;
        });
      } else {
        const res = wasLiked
          ? await feedApi.unreactComment(postId, commentId)
          : await feedApi.reactComment(postId, commentId, LIKE_REACTION);
        setComments((prev) => prev.map((c) => c.id === commentId
          ? { ...c, reaction_counts: res.data || {}, user_reaction: wasLiked ? null : LIKE_REACTION }
          : c));
      }
    } catch {
      // Restore server truth if the request failed.
      fetchComments();
    }
  };

  const handleFollowCommenter = async (username: string) => {
    try {
      await profilesApi.follow(username);
      setMoreOptionsOpen(null);
      track('feed.comment_follow', { object_id: username, properties: { post_id: postId } });
    } catch {}
  };

  const handleReportComment = async (comment: Comment) => {
    try {
      await feedApi.submitReport({
        target_user: comment.author_id,
        reason: 'other',
        description: `Comment ${comment.id} on post ${postId} — ${comment.body.slice(0, 200)}`,
      });
      setMoreOptionsOpen(null);
      track('feed.comment_report', { object_id: comment.id, properties: { post_id: postId } });
    } catch {}
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-end">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-buddy-black/40 backdrop-blur-sm" onClick={onClose} />
      
      {/* Sheet Content */}
      <div className="relative w-full h-[70vh] bg-buddy-surface rounded-t-3xl flex flex-col shadow-[0_-10px_40px_rgba(0,0,0,0.5)] border-t border-buddy-surface-raised animate-in slide-in-from-bottom duration-300">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-12 h-1.5 bg-buddy-surface-raised rounded-full" />
        </div>
        
        <div className="flex items-center justify-between px-4 pb-2">
          <h2 className="font-heading font-semibold text-lg">Comments <span className="text-buddy-text-secondary text-sm font-normal ml-1">({comments.length})</span></h2>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface-raised text-buddy-text-secondary">
            <X size={20} />
          </button>
        </div>

        <div className="flex gap-2 px-4 py-2 border-b border-buddy-surface-raised">
          {(['newest', 'oldest', 'top'] as const).map((s) => (
            <button key={s} onClick={() => setSort(s)}
              className={`text-xs px-3 py-1.5 rounded-full capitalize transition-colors ${sort === s ? 'bg-buddy-green text-buddy-black font-medium' : 'text-buddy-text-secondary hover:bg-buddy-surface-raised hover:text-buddy-text-primary'}`}
            >{s}</button>
          ))}
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3 space-y-4" ref={scrollRef}>
          {comments.length === 0 ? (
            <div className="text-center py-12 text-buddy-text-secondary">No comments yet. Be the first!</div>
          ) : (
            [...comments]
              .sort((a, b) => {
                if (sort === 'oldest') return a.created_at.localeCompare(b.created_at);
                if (sort === 'top') return likeCount(b) - likeCount(a);
                return b.created_at.localeCompare(a.created_at);
              })
              .map((c) => (
              <div key={c.id} className="flex gap-3 relative group">
                <Avatar src={c.author_data?.avatar_url} alt={c.author_data?.display_name || 'User'} size="sm" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm">
                    <span className="font-medium">{c.author_data?.display_name}</span>
                    <span className="text-buddy-text-secondary text-xs ml-1">@{c.author_data?.username}</span>
                  </p>
                  <p className={`text-sm mt-0.5 cursor-pointer select-text ${c.media_type === 'sticker' ? 'text-2xl leading-tight' : ''}`}
                    onDoubleClick={() => toggleCommentLike(c.id)}
                  >
                    <RichText text={isProfanityFilterEnabled() ? maskProfanity(c.body) : c.body} />
                  </p>
                  {c.media_url && c.media_type === 'video' && (
                    <video src={c.media_url} controls className="mt-2 max-h-60 w-full rounded-lg bg-black" />
                  )}
                  {c.media_url && c.media_type !== 'video' && (
                    <img
                      src={c.media_url}
                      alt={c.media_type === 'gif' ? 'GIF' : c.media_type === 'sticker' ? 'Sticker' : 'Comment attachment'}
                      className="mt-2 max-h-60 rounded-lg object-cover"
                      loading="lazy"
                    />
                  )}
                  <div className="flex items-center justify-between mt-2">
                    <div className="flex items-center gap-3">
                      <span className="text-xs text-buddy-text-secondary">{new Date(c.created_at).toLocaleDateString()}</span>
                      {/* Like button — right side of comment text */}
                      <button
                        onClick={(e) => toggleCommentLike(c.id, e)}
                        className={`flex items-center gap-1 text-xs transition-colors ${
                          likedComments.has(c.id) ? 'text-buddy-electric' : 'text-buddy-text-secondary hover:text-buddy-electric'
                        }`}
                        title={likedComments.has(c.id) ? 'Unlike' : 'Like'}
                      >
                        <Heart size={12} className={`${likedComments.has(c.id) ? 'fill-buddy-electric' : ''}`} />
                        <span className="ml-0.5">{likeCount(c)}</span>
                      </button>
                      <button className="text-xs text-buddy-text-secondary hover:text-buddy-text-primary">
                        <MessageCircle size={12} />
                        <span className="ml-0.5">{c.reply_count || 0}</span>
                      </button>
                      <div className="relative">
                        <button
                          onClick={(e) => { e.stopPropagation(); setMoreOptionsOpen(c.id); }}
                          className="w-6 h-6 rounded-lg bg-buddy-surface hover:bg-buddy-surface/80 flex items-center justify-center text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
                          aria-label="More options"
                        >
                          <MoreHorizontal size={14} />
                        </button>
                        {moreOptionsOpen === c.id && (
                          <div className="absolute right-0 mt-2 w-48 bg-buddy-surface rounded-xl border border-buddy-border shadow-xl py-2 z-50">
                            <button
                              onClick={() => { setReplyingTo(c.id); setMoreOptionsOpen(null); }}
                              className="w-full text-left px-3 py-2 text-sm text-buddy-text-secondary hover:bg-buddy-green/10 hover:text-buddy-green transition-colors flex items-center gap-2"
                            >
                              <MessageCircle size={14} className="mr-2" /> Reply
                            </button>
                            {c.author_id && (
                              <button
                                onClick={() => { handleFollowCommenter(c.author_data?.username || ''); }}
                                className="w-full text-left px-3 py-2 text-sm text-buddy-text-secondary hover:bg-buddy-green/10 hover:text-buddy-green transition-colors flex items-center gap-2"
                              >
                                <UserPlus size={14} className="mr-2" /> Follow {c.author_data?.display_name || 'user'}
                              </button>
                            )}
                            <button
                              onClick={() => { handleReportComment(c); }}
                              className="w-full text-left px-3 py-2 text-sm text-buddy-text-secondary hover:bg-buddy-red/10 hover:text-buddy-red transition-colors flex items-center gap-2"
                            >
                              <Flag size={14} className="mr-2" /> Report Comment
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Reply input */}
                  {replyingTo === c.id && (
                    <div className="mt-2 px-3 py-2 bg-buddy-surface-raised rounded-xl">
                      <div className="flex gap-2 items-end">
                        <div className="flex-1 min-w-0 space-y-1.5">
                          <input
                            type="text"
                            value={replyBody}
                            onChange={(e) => setReplyBody(e.target.value)}
                            placeholder="Write a reply…"
                            className="w-full bg-buddy-surface rounded-lg px-3 py-2 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
                            onKeyDown={(e) => e.key === 'Enter' && handleReplySubmit(c.id)}
                          />
                          <input
                            ref={replyFileRef}
                            type="file"
                            className="hidden"
                            onChange={handleReplyFile}
                          />
                          {/* Media attachment bar */}
                          <div className="flex items-center gap-1">
                            <button
                              onClick={() => setStickerPickerOpen((open) => !open)}
                              className="w-6 h-6 rounded-lg bg-buddy-surface hover:bg-buddy-green/10 text-buddy-text-secondary hover:text-buddy-green flex items-center justify-center transition-colors"
                              title="Add sticker"
                            >
                              <Smile size={14} />
                            </button>
                            <button
                              onClick={() => openReplyFilePicker('image')}
                              className="w-6 h-6 rounded-lg bg-buddy-surface hover:bg-buddy-green/10 text-buddy-text-secondary hover:text-buddy-green flex items-center justify-center transition-colors"
                              title="Add image"
                            >
                              <ImageIcon size={14} />
                            </button>
                            <button
                              onClick={() => openReplyFilePicker('video')}
                              className="w-6 h-6 rounded-lg bg-buddy-surface hover:bg-buddy-green/10 text-buddy-text-secondary hover:text-buddy-green flex items-center justify-center transition-colors"
                              title="Add video"
                            >
                              <VideoIcon size={14} />
                            </button>
                            <button
                              onClick={() => openReplyFilePicker('gif')}
                              className="w-6 h-6 rounded-lg bg-buddy-surface hover:bg-buddy-green/10 text-buddy-text-secondary hover:text-buddy-green flex items-center justify-center transition-colors"
                              title="Add gif"
                            >
                              <Link2 size={14} />
                            </button>
                            {uploadingMedia && (
                              <span className="text-[11px] text-buddy-text-secondary">Uploading…</span>
                            )}
                          </div>
                          {stickerPickerOpen && (
                            <div className="flex flex-wrap gap-1 p-2 bg-buddy-surface rounded-lg border border-buddy-border">
                              {STICKER_EMOJIS.map((emoji) => (
                                <button
                                  key={emoji}
                                  onClick={() => { setReplyMedia({ type: 'sticker', url: emoji }); setStickerPickerOpen(false); }}
                                  className="text-xl leading-none hover:scale-110 transition-transform"
                                  title={`Sticker ${emoji}`}
                                >
                                  {emoji}
                                </button>
                              ))}
                            </div>
                          )}
                        </div>
                        <Button size="sm" onClick={() => handleReplySubmit(c.id)} disabled={(!replyBody.trim() && !replyMedia) || uploadingMedia}>
                          Reply
                        </Button>
                        <button
                          onClick={() => { setReplyingTo(null); setReplyMedia(null); setStickerPickerOpen(false); }}
                          className="p-1 text-buddy-text-secondary hover:text-buddy-text-primary"
                        >
                          <X size={14} />
                        </button>
                      </div>
                      {replyMedia && (
                        <div className="mt-1 flex items-center gap-2 px-2 py-1 bg-buddy-green/5 rounded-lg border border-buddy-green/20">
                          <span className="text-xs text-buddy-green">
                            {replyMedia.type === 'sticker' ? `Sticker ${replyMedia.url}` : `${replyMedia.type} attached`}
                          </span>
                          <button
                            onClick={() => setReplyMedia(null)}
                            className="text-xs text-buddy-text-secondary hover:text-buddy-red"
                          >
                            Remove
                          </button>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
              ))
          )}
        </div>

        <div className="p-4 border-t border-buddy-surface-raised bg-buddy-surface">
          <div className="flex gap-3 items-center">
            <input
              type="text"
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="Add a comment…"
              className="flex-1 bg-buddy-surface-raised rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
              onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
            />
            <Button size="sm" onClick={handleSubmit} isLoading={isLoading} disabled={!body.trim()}>
              <Send size={14} />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
