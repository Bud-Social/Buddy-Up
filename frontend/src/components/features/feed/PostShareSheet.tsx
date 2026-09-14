import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { X, Link2, Repeat2, Bookmark, BookmarkCheck, User, Check } from 'lucide-react';
import { feedApi } from '@/api/feed';
import type { Post } from '@/types';

const VIDEO_EXT = /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i;

/** Pure helper, unit-tested. Video posts deep-link into the fullscreen
 *  player; everything else falls back to the feed permalink param. */
export function isVideoPost(post: Pick<Post, 'post_type' | 'media' | 'media_urls'>): boolean {
  if (post.post_type === 'short_video' || post.post_type === 'long_video') return true;
  if (post.media?.some((m) => m.media_type === 'video')) return true;
  return (post.media_urls || []).some((u) => VIDEO_EXT.test(u));
}

/** Canonical share URL for a post. Pure helper, unit-tested. */
export function canonicalPostUrl(
  post: Pick<Post, 'id' | 'post_type' | 'media' | 'media_urls'>,
  origin = typeof window !== 'undefined' ? window.location.origin : '',
): string {
  if (isVideoPost(post)) return `${origin}/videos?start=${post.id}`;
  return `${origin}/feed?post=${post.id}`;
}

interface PostShareSheetProps {
  post: Post;
  isOpen: boolean;
  onClose: () => void;
  /** Current save state (sheet toggles via save/unsave endpoints). */
  isSaved: boolean;
  onToggleSave: () => void;
  /** Repost state + handler owned by the parent rail. */
  isReposted: boolean;
  onRepost: () => void;
  /** Called with the authoritative count after a successful share record. */
  onShared?: (shareCount: number) => void;
}

/**
 * Bottom share sheet: native share (with clipboard fallback), copy link,
 * repost, save/unsave, open creator profile. No report entry — no post-level
 * report surface exists yet (moderation API is queue-only).
 *
 * Outbound shares are recorded via feedApi.sharePost; the count only updates
 * on success, and failures surface an inline error with no stale state.
 */
export function PostShareSheet({
  post,
  isOpen,
  onClose,
  isSaved,
  onToggleSave,
  isReposted,
  onRepost,
  onShared,
}: PostShareSheetProps) {
  const navigate = useNavigate();
  const [copied, setCopied] = useState(false);
  const [shared, setShared] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recording, setRecording] = useState(false);

  if (!isOpen) return null;

  const link = canonicalPostUrl(post);
  const shareText = post.body ? post.body.slice(0, 120) : `Check out this post by @${post.author_data?.username}`;

  const recordShare = async () => {
    if (shared || recording) return true;
    setRecording(true);
    setError(null);
    try {
      const res = await feedApi.sharePost(post.id);
      const count = res.data?.share_count;
      if (typeof count === 'number') onShared?.(count);
      setShared(true);
      return true;
    } catch {
      // No stale state: count is untouched, surface the failure inline.
      setError('Could not record share. Please try again.');
      return false;
    } finally {
      setRecording(false);
    }
  };

  const handleNativeShare = async () => {
    const nav = navigator as Navigator & { share?: (d: ShareData) => Promise<void> };
    if (typeof nav.share === 'function') {
      try {
        await nav.share({ title: 'BuddyUp', text: shareText, url: link });
        await recordShare();
        onClose();
      } catch (err) {
        // User dismissed the native sheet — not an error.
        if (err instanceof DOMException && err.name === 'AbortError') return;
        setError('Share failed. You can copy the link instead.');
      }
    } else {
      await handleCopyLink();
    }
  };

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(link);
    } catch {
      // Clipboard API unavailable (permissions/insecure context): select fallback.
      const ta = document.createElement('textarea');
      ta.value = link;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
    }
    setCopied(true);
    await recordShare();
    setTimeout(() => setCopied(false), 2000);
  };

  const rowCls =
    'w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors hover:bg-buddy-surface-raised text-buddy-text-primary text-left';

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-end" role="dialog" aria-modal="true" aria-label="Share post">
      <div className="absolute inset-0 bg-buddy-black/40 backdrop-blur-sm" onClick={onClose} />
      <div
        className="relative w-full bg-buddy-surface rounded-t-3xl shadow-[0_-10px_40px_rgba(0,0,0,0.5)] border-t border-buddy-surface-raised animate-in slide-in-from-bottom duration-300"
        data-testid="share-sheet"
      >
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-12 h-1.5 bg-buddy-surface-raised rounded-full" />
        </div>
        <div className="flex items-center justify-between px-4 pb-2">
          <h2 className="font-heading font-semibold text-lg">Share</h2>
          <button
            onClick={onClose}
            className="p-1 rounded-lg hover:bg-buddy-surface-raised text-buddy-text-secondary"
            aria-label="Close share sheet"
          >
            <X size={20} />
          </button>
        </div>

        <div className="px-2 pb-2">
          <button className={rowCls} onClick={handleNativeShare} disabled={recording}>
            <Check size={18} className="text-buddy-green shrink-0" />
            <span className="flex-1">Share via…</span>
          </button>
          <button className={rowCls} onClick={handleCopyLink} aria-label="Copy post link">
            {copied ? (
              <Check size={18} className="text-buddy-green shrink-0" />
            ) : (
              <Link2 size={18} className="text-buddy-text-secondary shrink-0" />
            )}
            <span className="flex-1">{copied ? 'Link copied!' : 'Copy link'}</span>
          </button>
          <button
            className={rowCls}
            onClick={() => { onRepost(); }}
            aria-label={isReposted ? 'Undo repost' : 'Repost'}
          >
            <Repeat2 size={18} className={`shrink-0 ${isReposted ? 'text-buddy-electric' : 'text-buddy-text-secondary'}`} />
            <span className="flex-1">{isReposted ? 'Undo repost' : 'Repost'}</span>
          </button>
          <button className={rowCls} onClick={onToggleSave} aria-label={isSaved ? 'Remove from saved' : 'Save post'}>
            {isSaved
              ? <BookmarkCheck size={18} className="text-buddy-green shrink-0" />
              : <Bookmark size={18} className="text-buddy-text-secondary shrink-0" />}
            <span className="flex-1">{isSaved ? 'Saved — tap to unsave' : 'Save'}</span>
          </button>
          <button
            className={rowCls}
            onClick={() => { onClose(); if (post.author_data?.username) navigate(`/${post.author_data.username}`); }}
            aria-label="Open creator profile"
          >
            <User size={18} className="text-buddy-text-secondary shrink-0" />
            <span className="flex-1">Open @{post.author_data?.username} profile</span>
          </button>
        </div>

        {error && (
          <p role="alert" className="mx-4 mb-3 text-xs text-center text-red-400 bg-red-500/10 rounded-lg px-3 py-2">
            {error}
          </p>
        )}
        <div className="h-[env(safe-area-inset-bottom)]" />
      </div>
    </div>
  );
}
