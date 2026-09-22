import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  X, Link2, Repeat2, Bookmark, BookmarkCheck, User, Check,
  MessageCircle, Twitter, Facebook, Send,
} from 'lucide-react';
import { feedApi } from '@/api/feed';
import { Avatar } from '@/components/ui/Avatar';
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

/** Append the sharer's referral code so opens attribute back to them. */
export function trackedShareUrl(base: string, code: string): string {
  return `${base}${base.includes('?') ? '&' : '?'}ref=${encodeURIComponent(code)}`;
}

type Sharer = {
  username: string;
  display_name: string;
  avatar_url: string;
  channel: string;
  shared_at: string;
  followed_by_viewer: boolean;
};

const SOCIAL_TARGETS = [
  {
    id: 'whatsapp',
    label: 'WhatsApp',
    icon: <MessageCircle size={18} className="text-[#25D366] shrink-0" />,
    href: (url: string, text: string) =>
      `https://wa.me/?text=${encodeURIComponent(`${text} ${url}`)}`,
  },
  {
    id: 'x',
    label: 'X',
    icon: <Twitter size={18} className="text-buddy-text-primary shrink-0" />,
    href: (url: string, text: string) =>
      `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`,
  },
  {
    id: 'facebook',
    label: 'Facebook',
    icon: <Facebook size={18} className="text-[#1877F2] shrink-0" />,
    href: (url: string) =>
      `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
  },
  {
    id: 'telegram',
    label: 'Telegram',
    icon: <Send size={18} className="text-[#229ED9] shrink-0" />,
    href: (url: string, text: string) =>
      `https://t.me/share/url?url=${encodeURIComponent(url)}&text=${encodeURIComponent(text)}`,
  },
] as const;

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
  /** Anchor rect for desktop popover mode; bottom sheet when absent/small screen. */
  anchorRect?: { top: number; left: number; bottom: number } | null;
}

/**
 * Share popover on desktop (anchored to the share button), bottom sheet on
 * mobile. Social targets open tracked referral links (`?ref=<code>`) so
 * opens attribute back to the sharer; recipients see who shared in
 * "Shared by".
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
  anchorRect,
}: PostShareSheetProps) {
  const navigate = useNavigate();
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recording, setRecording] = useState(false);
  const [sharers, setSharers] = useState<Sharer[]>([]);
  const popRef = useRef<HTMLDivElement>(null);
  const [popTop, setPopTop] = useState<number | null>(null);

  const usePopover =
    !!anchorRect &&
    typeof window !== 'undefined' &&
    window.matchMedia('(min-width: 640px)').matches;

  useEffect(() => {
    if (!isOpen) return;
    setError(null);
    setCopied(false);
    feedApi.getPostShares(post.id)
      .then((res) => setSharers(res.data || []))
      .catch(() => setSharers([]));
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [isOpen, post.id, onClose]);

  // Flip the popover above the anchor when it would overflow the viewport.
  useEffect(() => {
    if (!isOpen || !usePopover || !anchorRect) return;
    const h = popRef.current?.offsetHeight ?? 420;
    const below = anchorRect.bottom + 8 + h <= window.innerHeight - 8;
    setPopTop(below ? anchorRect.bottom + 8 : Math.max(8, anchorRect.top - h - 8));
  }, [isOpen, usePopover, anchorRect, sharers.length]);

  if (!isOpen) return null;

  const link = canonicalPostUrl(post);
  const shareText = post.body ? post.body.slice(0, 120) : `Check out this post by @${post.author_data?.username}`;

  /** Record the outbound share; returns the tracked link (or plain link on failure). */
  const trackedLink = async (channel: string): Promise<string> => {
    if (recording) return link;
    setRecording(true);
    setError(null);
    try {
      const res = await feedApi.sharePost(post.id, channel);
      const count = res.data?.share_count;
      if (typeof count === 'number') onShared?.(count);
      const code = res.data?.code;
      return code ? trackedShareUrl(link, code) : link;
    } catch {
      setError('Could not record share. The link still works.');
      return link;
    } finally {
      setRecording(false);
    }
  };

  const handleNativeShare = async () => {
    const nav = navigator as Navigator & { share?: (d: ShareData) => Promise<void> };
    if (typeof nav.share === 'function') {
      try {
        const url = await trackedLink('native');
        await nav.share({ title: 'BuddyUp Fit', text: shareText, url });
        onClose();
      } catch (err) {
        if (err instanceof DOMException && err.name === 'AbortError') return;
        setError('Share failed. You can copy the link instead.');
      }
    } else {
      await handleCopyLink();
    }
  };

  const handleCopyLink = async () => {
    const url = await trackedLink('copy');
    try {
      await navigator.clipboard.writeText(url);
    } catch {
      const ta = document.createElement('textarea');
      ta.value = url;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
    }
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleSocial = async (id: string, href: (url: string, text: string) => string) => {
    const url = await trackedLink(id);
    window.open(href(url, shareText), '_blank', 'noopener,noreferrer');
  };

  const rowCls =
    'w-full flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-colors hover:bg-buddy-surface-raised text-buddy-text-primary text-left disabled:opacity-50';

  const popStyle: React.CSSProperties | undefined = usePopover && anchorRect && popTop != null
    ? {
        position: 'fixed',
        top: popTop,
        left: Math.max(8, Math.min(anchorRect.left - 140, window.innerWidth - 328)),
        width: 320,
        zIndex: 50,
      }
    : undefined;

  const panelCls = usePopover
    ? 'bg-buddy-surface rounded-2xl shadow-[0_10px_40px_rgba(0,0,0,0.5)] border border-buddy-surface-raised max-h-[70vh] overflow-y-auto'
    : 'relative w-full bg-buddy-surface rounded-t-3xl shadow-[0_-10px_40px_rgba(0,0,0,0.5)] border-t border-buddy-surface-raised animate-in slide-in-from-bottom duration-300';

  return (
    <div
      className={usePopover ? undefined : 'fixed inset-0 z-50 flex flex-col justify-end'}
      role="dialog"
      aria-modal="true"
      aria-label="Share post"
    >
      <div
        className={usePopover ? 'fixed inset-0 z-40' : 'absolute inset-0 bg-buddy-black/40 backdrop-blur-sm'}
        onClick={onClose}
      />
      <div ref={popRef} className={panelCls} style={popStyle} data-testid="share-sheet">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-12 h-1.5 bg-buddy-surface-raised rounded-full" />
        </div>
        <div className="flex items-center justify-between px-4 pb-2">
          <h2 className="font-heading font-semibold text-lg">Share</h2>
          <button
            onClick={onClose}
            className="p-1 rounded-lg hover:bg-buddy-surface-raised text-buddy-text-secondary"
            aria-label="Close share"
          >
            <X size={20} />
          </button>
        </div>

        {/* Social app targets */}
        <div className="flex gap-1 px-4 pb-1 overflow-x-auto">
          {SOCIAL_TARGETS.map((t) => (
            <button
              key={t.id}
              onClick={() => void handleSocial(t.id, t.href)}
              disabled={recording}
              className="shrink-0 flex flex-col items-center gap-1 px-3 py-2 rounded-xl hover:bg-buddy-surface-raised transition-colors disabled:opacity-50"
              aria-label={`Share to ${t.label}`}
            >
              <span className="w-10 h-10 rounded-full bg-buddy-surface-raised flex items-center justify-center">
                {t.icon}
              </span>
              <span className="text-[10px] text-buddy-text-secondary">{t.label}</span>
            </button>
          ))}
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

        {sharers.length > 0 && (
          <div className="px-4 pb-3">
            <p className="text-[11px] font-semibold uppercase tracking-wide text-buddy-text-secondary mb-1.5">
              Shared by
            </p>
            <div className="flex items-center gap-2 overflow-x-auto">
              {sharers.slice(0, 8).map((s) => (
                <button
                  key={s.username}
                  onClick={() => { onClose(); navigate(`/${s.username}`); }}
                  className="shrink-0 flex flex-col items-center gap-0.5 w-14"
                  title={`${s.display_name} (@${s.username})`}
                >
                  <Avatar
                    src={s.avatar_url}
                    alt={s.display_name}
                    size="sm"
                    className={s.followed_by_viewer ? 'ring-2 ring-buddy-green' : undefined}
                  />
                  <span className="text-[10px] text-buddy-text-secondary truncate w-full text-center">
                    {s.followed_by_viewer ? `✓ ${s.display_name}` : s.display_name}
                  </span>
                </button>
              ))}
            </div>
          </div>
        )}

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
