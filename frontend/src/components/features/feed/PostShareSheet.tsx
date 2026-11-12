import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  X, Link2, Repeat2, Bookmark, BookmarkCheck, User, Check,
  MessageCircle, Twitter, Facebook, Send, Download, Share2,
} from 'lucide-react';
import { feedApi } from '@/api/feed';
import { messagingApi } from '@/api/messaging';
import { Avatar } from '@/components/ui/Avatar';
import {
  createShareCard,
  downloadShareCard,
  hasVideoMedia,
  renderShareCardLayers,
} from '@/lib/shareCard';
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
  post: Pick<Post, 'id' | 'post_type' | 'media' | 'media_urls'> & { community_id?: string | null },
  origin = typeof window !== 'undefined' ? window.location.origin : '',
): string {
  // Community posts are served by the communities surface, not /feed.
  if (post.community_id) return `${origin}/communities/${post.community_id}?post=${post.id}`;
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
  /** Community ID when the post is a community post (vs. feed post). */
  communityId?: string;
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
  communityId,
}: PostShareSheetProps) {
  const navigate = useNavigate();
  const [copied, setCopied] = useState(false);
  const [downloaded, setDownloaded] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recording, setRecording] = useState(false);
  const [preparingCard, setPreparingCard] = useState(false);
  const [cardStatus, setCardStatus] = useState<string | null>(null);
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
    setDownloaded(false);
    setCardStatus(null);
    if (communityId) {
      messagingApi
        .getPostShares(communityId, post.id)
        .then((res) => setSharers(res || []))
        .catch(() => setSharers([]));
    } else {
      feedApi.getPostShares(post.id)
        .then((res) => setSharers(res.data || []))
        .catch(() => setSharers([]));
    }
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [isOpen, post.id, onClose, communityId]);

  // Flip the popover above the anchor when it would overflow the viewport.
  useEffect(() => {
    if (!isOpen || !usePopover || !anchorRect) return;
    const h = popRef.current?.offsetHeight ?? 420;
    const below = anchorRect.bottom + 8 + h <= window.innerHeight - 8;
    setPopTop(below ? anchorRect.bottom + 8 : Math.max(8, anchorRect.top - h - 8));
  }, [isOpen, usePopover, anchorRect, sharers.length]);

  if (!isOpen) return null;

  // Community posts are served by the communities surface. Prefer the
  // explicit communityId prop: the raw messaging payload does not always
  // carry community_id on the mapped Post.
  const link = communityId
    ? `${typeof window !== 'undefined' ? window.location.origin : ''}/communities/${communityId}?post=${post.id}`
    : canonicalPostUrl(post);
  const shareText = post.body ? post.body.slice(0, 120) : `Check out this post by @${post.author_data?.username}`;

  /** Record the outbound share; returns the tracked link (or plain link on failure). */
  const trackedLink = async (channel: string): Promise<string> => {
    if (recording) return link;
    setRecording(true);
    setError(null);
    try {
      let res;
      if (communityId) {
        res = await messagingApi.shareCommunityPost(communityId, post.id);
        const count = (res as { share_count?: number })?.share_count;
        if (typeof count === 'number') onShared?.(count);
        return link;
      } else {
        res = await feedApi.sharePost(post.id, channel);
      }
      const count = (res as any).data?.share_count;
      if (typeof count === 'number') onShared?.(count);
      const code = (res as any).data?.code;
      return code ? trackedShareUrl(link, code) : link;
    } catch {
      setError('Could not record share. The link still works.');
      return link;
    } finally {
      setRecording(false);
    }
  };

  const copyText = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
    }
  };

  /**
   * Build the branded card.
   *
   * Video posts get a video card: the backend composites the whole clip —
   * sound intact — into the card chrome, so the shared file is the complete
   * video rather than a preview. Everything else is a PNG card.
   */
  const buildCard = async (url: string): Promise<File> => {
    if (hasVideoMedia(post)) {
      try {
        const layers = await renderShareCardLayers(post);
        if (layers) {
          const payload = {
            base: layers.base,
            over: layers.over,
            rect: `${layers.rect.x},${layers.rect.y},${layers.rect.w},${layers.rect.h}`,
            radius: layers.radius,
          };
          const job = communityId
            ? await messagingApi.createCommunityVideoShareCard(communityId, post.id, payload)
            : await feedApi.createVideoShareCard(post.id, payload);
          const blob = await pollForVideoCard(job.job_id);
          return new File([blob], `buddyup-${post.id}.mp4`, {
            type: blob.type || 'video/mp4',
          });
        }
      } catch {
        // Composition unavailable (no ffmpeg, network hiccup): fall back to
        // the still card so the user still gets a shareable file.
      }
    }
    return createShareCard(post, { url });
  };

  /**
   * Wait for the server-side render to finish.
   *
   * The render takes about as long as the clip, so this polls until the job
   * reports the finished file.
   */
  const pollForVideoCard = async (jobId: string): Promise<Blob> => {
    const deadline = Date.now() + 10 * 60 * 1000;
    while (Date.now() < deadline) {
      let blob: Blob;
      try {
        blob = communityId
          ? await messagingApi.getCommunityVideoShareCard(communityId, post.id, jobId)
          : await feedApi.getVideoShareCard(post.id, jobId);
      } catch (err) {
        // A failed job answers with a JSON body; surface its message rather
        // than a generic network error.
        const message = await errorMessage(err);
        if (message) throw new Error(message);
        throw err;
      }
      // A pending job answers 202 with a JSON body, so the content type is
      // what tells "still rendering" apart from "finished".
      if (blob.type.includes('json')) {
        setCardStatus('Rendering the video card…');
        await new Promise((resolve) => setTimeout(resolve, 2000));
        continue;
      }
      return blob;
    }
    throw new Error('Timed out waiting for the video card.');
  };

  /** Pull a human-readable message out of a failed API response. */
  const errorMessage = async (err: unknown): Promise<string | null> => {
    const response = (err as { response?: { data?: Blob } })?.response;
    if (!response?.data || typeof response.data.text !== 'function') return null;
    try {
      const parsed = JSON.parse(await response.data.text());
      return typeof parsed?.message === 'string' ? parsed.message : null;
    } catch {
      return null;
    }
  };

  /**
   * Share the branded card. Native file sharing is how the card reaches
   * WhatsApp Status / Instagram / AirDrop with the watermark intact;
   * browsers without file sharing get the card downloaded plus the link
   * copied so it can be attached manually.
   */
  const handleShareCard = async () => {
    const nav = navigator as Navigator & {
      share?: (d: ShareData) => Promise<void>;
      canShare?: (d: ShareData) => boolean;
    };
    setPreparingCard(true);
    setError(null);
    setDownloaded(false);
    try {
      const url = await trackedLink('native');
      const file = await buildCard(url);
      const payload: ShareData = {
        files: [file],
        title: 'BuddyUp Fit',
        text: `${shareText}\n${url}`,
      };
      if (nav.share && (!nav.canShare || nav.canShare(payload))) {
        await nav.share(payload);
        onClose();
        return;
      }
      // No file sharing: save the card and put the link on the clipboard.
      downloadShareCard(file);
      await copyText(url);
      setDownloaded(true);
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') return;
      setError('Could not build the share card. Try Download card instead.');
    } finally {
      setPreparingCard(false);
      setCardStatus(null);
    }
  };

  const handleDownloadCard = async () => {
    setPreparingCard(true);
    setError(null);
    setDownloaded(false);
    try {
      const file = await buildCard(link);
      downloadShareCard(file);
      setDownloaded(true);
    } catch {
      setError('Could not build the share card.');
    } finally {
      setPreparingCard(false);
      setCardStatus(null);
    }
  };

  const handleDownloadImageCard = async () => {
    setPreparingCard(true);
    setError(null);
    setDownloaded(false);
    try {
      const file = await createShareCard(post, { url: link });
      downloadShareCard(file);
      setDownloaded(true);
    } catch {
      setError('Could not build the share card.');
    } finally {
      setPreparingCard(false);
    }
  };

  const handleCopyLink = async () => {
    const url = await trackedLink('copy');
    await copyText(url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const hasMedia = (post.media_urls?.length || 0) > 0 || (post.media?.length || 0) > 0;
  const isVideo = hasVideoMedia(post);

  const handleDownload = async () => {
    // Download through the backend proxy (avoids CORS, adds watermark).
    setRecording(true);
    setError(null);
    try {
      let res;
      if (communityId) {
        res = await messagingApi.downloadCommunityPostMedia(communityId, post.id);
      } else {
        res = await feedApi.downloadPostMedia(post.id);
      }
      // res.data is a Blob when responseType is 'blob'.
      const blob = res.data as Blob;
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `buddyup_${post.id}.${blob.type === 'image/jpeg' ? 'jpg' : 'mp4'}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
    } catch {
      setError('Failed to download media');
    } finally {
      setRecording(false);
    }
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
          <button className={rowCls} onClick={handleShareCard} disabled={recording || preparingCard}>
            <Share2 size={18} className="text-buddy-green shrink-0" />
            <span className="flex-1">
              {preparingCard
                ? (cardStatus ?? (isVideo ? 'Building video card…' : 'Preparing card…'))
                : (isVideo ? 'Share as video card' : 'Share as card')}
            </span>
          </button>
          <button className={rowCls} onClick={handleCopyLink} aria-label="Copy post link" disabled={recording}>
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
            onClick={handleDownloadCard}
            aria-label={isVideo ? 'Download video card' : 'Download card'}
            disabled={preparingCard}
          >
            {downloaded ? (
              <Check size={18} className="text-buddy-green shrink-0" />
            ) : (
              <Download size={18} className="text-buddy-text-secondary shrink-0" />
            )}
            <span className="flex-1">
              {downloaded
                ? 'Card downloaded!'
                : (isVideo ? 'Download video card' : 'Download card')}
            </span>          </button>
          {isVideo && (
            <button
              className={rowCls}
              onClick={handleDownloadImageCard}
              aria-label="Download card image"
              disabled={preparingCard}
            >
              <Download size={18} className="text-buddy-text-secondary shrink-0" />
              <span className="flex-1">Download card image</span>
            </button>
          )}          {hasMedia && (
            <button
              className={rowCls}
              onClick={handleDownload}
              aria-label="Download original media"
              disabled={recording}
            >
              <Download size={18} className="text-buddy-text-secondary shrink-0" />
              <span className="flex-1">Download original media</span>
            </button>
          )}
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
