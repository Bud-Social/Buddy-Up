import { useEffect, useMemo, useRef, useState, useCallback, forwardRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  Play, Pause, Volume2, VolumeX, Maximize, Minimize,
  Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  X, ChevronUp, Loader2, Share2, Eye,
} from 'lucide-react';
import { feedApi } from '@/api/feed';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { PostPhotoCarousel } from '@/components/features/feed/PostPhotoCarousel';
import { RailAction, RAIL_ICON_SIZE, nextReactionState, totalReactions } from '@/components/features/feed/RailAction';
import { AuthorChip } from '@/components/features/feed/AuthorChip';
import { Avatar } from '@/components/ui/Avatar';
import { useAuthStore } from '@/store/authStore';
import { track } from '@/lib/analytics';
import { PostShareSheet } from '@/components/features/feed/PostShareSheet';
import { useRecordPostView } from '@/components/features/feed/useRecordPostView';
import {
  isSwipeLeftToProfile, shouldIgnoreSwipeOrigin,
} from '@/components/features/feed/feedGestures';
import { toEmoji } from '@/utils/emojiUtils';
import { mediaPagesFromPost, postIsPhotoMode } from '@/lib/mediaPages';
import { filterCssAt, adjustCss } from '@/lib/createStudio';
import { CreativeLayer } from '@/components/create/CreativeLayer';
import { FeedTrackAudio } from '@/components/features/feed/FeedTrackAudio';
import type { PostEditMeta, PostCaption } from '@/types';
import type { Post } from '@/types/post';

const VIDEO_EXT = /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i;

function pickVideoItem(post: Post): {
  url: string; poster?: string; editMeta?: PostEditMeta | null; captions?: PostCaption[] | null;
  soundUrl?: string | null; soundVolume?: number | null;
} | null {
  // Prefer structured media (poster + dims + studio edits), fall back to URL sniffing.
  const first = post.media?.[0];
  if (first && first.media_type === 'video') {
    return {
      url: first.url, poster: first.poster_url ?? undefined, editMeta: first.edit_meta ?? null,
      captions: first.captions ?? null, soundUrl: first.sound_audio_url ?? null,
      soundVolume: first.sound_volume ?? null,
    };
  }
  for (const url of post.media_urls || []) {
    if (VIDEO_EXT.test(url)) return { url };
  }
  return null;
}

interface VideoItem {
  post: Post;
  video: {
    url: string; poster?: string; editMeta?: PostEditMeta | null; captions?: PostCaption[] | null;
    soundUrl?: string | null; soundVolume?: number | null;
  } | null;
  photoMode: boolean;
}

const OVERLAY_COLORS_SKIP: Record<string, string> = {};
void OVERLAY_COLORS_SKIP;

function overlaySizePx(size: number): number {
  return [14, 20, 30][size] ?? 20;
}
void overlaySizePx;

/** Full-screen video player that applies create-studio edits
 *  (filter preset + strength, adjustments, playback speed, trim in-point,
 *  timed text overlays, stickers). */
const FeedVideoWithEdits = forwardRef<HTMLVideoElement, {
  video: {
    url: string; poster?: string; editMeta?: PostEditMeta | null; captions?: PostCaption[] | null;
    soundUrl?: string | null; soundVolume?: number | null;
  };
  muted: boolean;
  active: boolean;
  onTime?: (ms: number, durationSec: number) => void;
}>(({ video, muted, active, onTime }, ref) => {
  const [overlayTimeMs, setOverlayTimeMs] = useState(0);
  const edits = video.editMeta;
  const speed = edits?.speed && edits.speed !== 1 ? edits.speed : 1;
  const internalRef = useRef<HTMLVideoElement | null>(null);
  const mergedRef = (el: HTMLVideoElement | null) => {
    internalRef.current = el;
    if (typeof ref === 'function') ref(el);
    else if (ref) (ref as { current: HTMLVideoElement | null }).current = el;
  };
  const filterCss = useMemo(() => {
    const parts = [filterCssAt(edits?.filter, edits?.filter_strength ?? 100), adjustCss(edits?.adjust)];
    return parts.filter(Boolean).join(' ');
  }, [edits]);
  const activeCaption = useMemo(() => {
    const seg = (video.captions ?? []).find((c) => overlayTimeMs >= c.start_ms && overlayTimeMs < c.end_ms);
    return seg ? { text: seg.text } : null;
  }, [video.captions, overlayTimeMs]);

  useEffect(() => {
    const el = internalRef.current;
    if (el) el.playbackRate = speed;
    if (el && !muted) el.volume = Math.min(1, (edits?.volume ?? 100) / 100);
  }, [speed, muted, edits?.volume]);

  return (
    <div className="relative w-full h-full">
      <video
        ref={mergedRef}
        src={video.url}
        poster={video.poster}
        loop
        playsInline
        muted={muted}
        preload="auto"
        style={{ filter: filterCss || undefined }}
        className="w-full h-full object-contain"
        onTimeUpdate={(e) => {
          const v = e.currentTarget;
          if (v.duration) onTime?.(v.currentTime * 1000, v.duration);
          setOverlayTimeMs(v.currentTime * 1000);
        }}
      />
      <CreativeLayer meta={edits} timeMs={overlayTimeMs} activeCaption={activeCaption} />
      <FeedTrackAudio
        getVideo={() => internalRef.current}
        editMeta={edits}
        soundUrl={video.soundUrl}
        soundVolume={video.soundVolume}
        soundPlacement={edits?.sound_placement}
        muted={muted}
        active={active}
      />
    </div>
  );
});

/** Invisible in-section sentinel that records a qualified view via useRecordPostView. */
function ViewRecorder({ postId, active, progress, onRecorded }: {
  postId: string; active: boolean; progress: number; onRecorded: (n: number) => void;
}) {
  const ref = useRecordPostView(postId, { active, progress, onRecorded });
  return <div ref={ref} className="absolute inset-0 pointer-events-none" aria-hidden />;
}

/** Bucket a fullscreen dwell duration for analytics (low-cardinality). */
function bucketDwell(ms: number): string {
  if (ms < 1000) return '<1s';
  if (ms < 3000) return '1-3s';
  if (ms < 10000) return '3-10s';
  return '10s+';
}

/** Repost avatar pop/out keyframes (see PostCard.AvatarPopStyle — same definition). */
function FsAvatarPopStyle() {
  return (
    <style>{`@keyframes budpress-avatar-pop{0%{opacity:0;transform:scale(.2)}60%{opacity:1;transform:scale(1.18)}100%{opacity:1;transform:scale(1)}}@keyframes budpress-avatar-out{from{opacity:1;transform:scale(1)}to{opacity:0;transform:scale(.2)}}`}</style>
  );
}

type FsInteractAction = 'like' | 'comment' | 'repost' | 'save' | 'share' | 'profile_open' | 'cover';

export default function FullScreenVideoFeed() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const startPostId = searchParams.get('start');

  const [items, setItems] = useState<VideoItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [activeIndex, setActiveIndex] = useState(0);
  const [controlsVisible, setControlsVisible] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const [shareIdx, setShareIdx] = useState<number | null>(null);
  const [shareAnchor, setShareAnchor] = useState<{ top: number; left: number; bottom: number } | null>(null);
  const [progress, setProgress] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [showSwipeHint, setShowSwipeHint] = useState(() => {
    try { return !sessionStorage.getItem('buddyup-swipe-hint-seen'); } catch { return true; }
  });

  const containerRef = useRef<HTMLDivElement>(null);
  const startScrolledRef = useRef(false);
  const videoRefs = useRef<(HTMLVideoElement | null)[]>([]);
  const hideTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const isScrollingRef = useRef(false);
  const cursorRef = useRef<string | undefined>(undefined);
  const hasMoreRef = useRef(true);
  const loadingLockRef = useRef(false);
  const touchOriginRef = useRef<{ x: number; y: number } | null>(null);

  // ── Bud Press: repost avatar pop, focus + interaction analytics ──
  const viewerAvatar = useAuthStore((s) => s.profile?.avatar_url);
  const viewerName = useAuthStore((s) => s.profile?.display_name);
  const [avatarPop, setAvatarPop] = useState<Record<string, 'in' | 'out'>>({});
  const avatarTimers = useRef<Record<string, ReturnType<typeof setTimeout>>>({});
  useEffect(() => () => {
    Object.values(avatarTimers.current).forEach((t) => clearTimeout(t));
  }, []);

  const interact = useCallback((postId: string, action: FsInteractAction) => {
    track('feed.post_interact', {
      surface: 'video_feed',
      object_type: 'post',
      object_id: postId,
      properties: { action },
    });
  }, []);

  const showAvatarPop = useCallback((postId: string) => {
    const pending = avatarTimers.current[postId];
    if (pending) {
      clearTimeout(pending);
      delete avatarTimers.current[postId];
    }
    setAvatarPop((p) => ({ ...p, [postId]: 'in' }));
  }, []);

  const hideAvatarPop = useCallback((postId: string) => {
    setAvatarPop((p) => ({ ...p, [postId]: 'out' }));
    const pending = avatarTimers.current[postId];
    if (pending) clearTimeout(pending);
    avatarTimers.current[postId] = setTimeout(() => {
      setAvatarPop((p) => {
        if (!(postId in p)) return p;
        const next = { ...p };
        delete next[postId];
        return next;
      });
      delete avatarTimers.current[postId];
    }, 220);
  }, []);

  const loadVideos = useCallback(async () => {
    if (!hasMoreRef.current || loadingLockRef.current) return;
    loadingLockRef.current = true;
    setIsLoading(true);
    try {
      const res = await feedApi.getVideoFeed('fyp', cursorRef.current);
      cursorRef.current = res.pagination?.next
        ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined
        : undefined;
      hasMoreRef.current = !!res.pagination?.next;
      const list = (res.data || [])
        .map((post) => ({
          post,
          video: pickVideoItem(post),
          photoMode: postIsPhotoMode(mediaPagesFromPost(post)),
        }))
        .filter((v): v is VideoItem => Boolean(v.video) || v.photoMode);
      setItems((prev) => {
        const seen = new Set(prev.map((v) => v.post.id));
        const fresh = list.filter((v) => !seen.has(v.post.id));
        return [...prev, ...fresh];
      });
    } catch {} finally {
      loadingLockRef.current = false;
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { loadVideos(); }, [loadVideos]);

  // Jump to a specific post via ?start=<postId>
  useEffect(() => {
    if (!startPostId || items.length === 0 || startScrolledRef.current) return;
    const idx = items.findIndex((v) => v.post.id === startPostId);
    if (idx === -1) return;
    startScrolledRef.current = true;
    setActiveIndex(idx);
    requestAnimationFrame(() => {
      const el = containerRef.current;
      if (el) el.scrollTop = idx * el.clientHeight;
    });
  }, [startPostId, items]);

  // Play only the active video, pause the rest
  useEffect(() => {
    videoRefs.current.forEach((v, i) => {
      if (!v) return;
      if (i === activeIndex) {
        v.muted = isMuted;
        v.play().catch(() => {});
      } else {
        v.pause();
      }
    });
  }, [activeIndex, isMuted]);

  const scheduleHide = useCallback(() => {
    clearTimeout(hideTimerRef.current);
    hideTimerRef.current = setTimeout(() => setControlsVisible(false), 2600);
  }, []);

  useEffect(() => {
    scheduleHide();
    return () => clearTimeout(hideTimerRef.current);
  }, [activeIndex, scheduleHide]);

  const handleScroll = () => {
    if (isScrollingRef.current) return;
    const el = containerRef.current;
    if (!el) return;
    const idx = Math.round(el.scrollTop / el.clientHeight);
    if (idx !== activeIndex) setActiveIndex(idx);
  };

  // Lazy-load more videos near the bottom (cursor-backed).
  useEffect(() => {
    if (activeIndex >= items.length - 2 && items.length > 0 && hasMoreRef.current) {
      loadVideos();
    }
  }, [activeIndex, items.length, loadVideos]);

  // Slide dwell analytics: feed.post_focus (bucketed) when the active slide
  // changes or the feed unmounts. Single timestamps, no per-frame work.
  const dwellStartRef = useRef<number>(Date.now());
  const dwellIdxRef = useRef(0);
  const itemsRef = useRef(items);
  itemsRef.current = items;
  const reportDwell = useCallback((idx: number) => {
    const post = itemsRef.current[idx]?.post;
    if (!post) return;
    const durationMs = Date.now() - dwellStartRef.current;
    if (durationMs >= 500) {
      track('feed.post_focus', {
        surface: 'video_feed',
        object_type: 'post',
        object_id: post.id,
        properties: { duration_ms: durationMs, duration_bucket: bucketDwell(durationMs) },
      });
    }
  }, []);
  useEffect(() => {
    reportDwell(dwellIdxRef.current);
    dwellIdxRef.current = activeIndex;
    dwellStartRef.current = Date.now();
  }, [activeIndex, reportDwell]);
  useEffect(() => () => {
    reportDwell(dwellIdxRef.current);
  }, [reportDwell]);

  const togglePlay = (idx: number) => {
    const v = videoRefs.current[idx];
    if (!v) return; // photo-mode posts have no single video element
    if (v.paused) v.play().catch(() => {});
    else v.pause();
    setControlsVisible(true);
    scheduleHide();
  };

  /** Engagement targets the ORIGINAL post on repost rows so counts never zero out. */
  const engagementIdOf = (post: Post) =>
    post.is_repost && post.original_post_data ? post.original_post_data.id : post.id;

  /** Engagement source for display: original's counts on repost rows. */
  const engagementSourceOf = (post: Post): Post =>
    post.is_repost && post.original_post_data
      ? { ...post, ...post.original_post_data, id: post.id } as Post
      : post;

  /** Patch row-level engagement AND nested original data on repost rows. */
  const patchEngagement = (
    idx: number,
    patch: Partial<Pick<Post, 'user_reaction' | 'reaction_counts' | 'repost_count' | 'is_reposted_by_me' | 'is_saved' | 'save_count'>>,
  ) =>
    setItems((prev) => prev.map((it, i) => {
      if (i !== idx) return it;
      const post = { ...it.post, ...patch };
      if (post.is_repost && post.original_post_data) {
        post.original_post_data = { ...post.original_post_data, ...patch };
      }
      return { ...it, post };
    }));

  /** One-tap toggles 💪 (optimistic w/ rollback + count switching). */
  const handleLike = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const targetId = engagementIdOf(item.post);
    const src = engagementSourceOf(item.post);
    const prevReaction = src.user_reaction ? toEmoji(src.user_reaction) : null;
    const prevCounts = src.reaction_counts || {};
    const next = nextReactionState(prevCounts, prevReaction, '💪');
    patchEngagement(idx, { user_reaction: next.userReaction, reaction_counts: next.counts });
    interact(item.post.id, 'like');
    try {
      if (next.removed) await feedApi.unreact(targetId);
      else await feedApi.react(targetId, '💪');
    } catch {
      patchEngagement(idx, { user_reaction: prevReaction, reaction_counts: prevCounts });
    }
  };

  const handleSave = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const post = item.post;
    const targetId = engagementIdOf(post);
    const next = !post.is_saved;
    const nextCount = Math.max(0, ((post.is_repost && post.original_post_data
      ? post.original_post_data.save_count
      : post.save_count) || 0) + (next ? 1 : -1));
    patchEngagement(idx, { is_saved: next, save_count: nextCount });
    interact(post.id, 'save');
    try {
      if (next) await feedApi.save(targetId);
      else await feedApi.unsave(targetId);
    } catch {
      patchEngagement(idx, { is_saved: post.is_saved });
    }
  };

  const handleRepost = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const wasReposted = item.post.is_reposted_by_me ?? false;
    const baseCount = (item.post.is_repost && item.post.original_post_data
      ? item.post.original_post_data.repost_count
      : item.post.repost_count) || 0;
    // Optimistic update
    patchEngagement(idx, {
      is_reposted_by_me: !wasReposted,
      repost_count: wasReposted ? Math.max(0, baseCount - 1) : baseCount + 1,
    });
    interact(item.post.id, 'repost');
    if (!wasReposted) showAvatarPop(item.post.id);
    else hideAvatarPop(item.post.id);
    try {
      const res = await feedApi.repost(item.post.id);
      if (res.data) {
        patchEngagement(idx, {
          is_reposted_by_me: res.data!.action === 'reposted',
          repost_count: res.data!.repost_count,
        });
      }
    } catch {
      // Rollback
      if (!wasReposted) hideAvatarPop(item.post.id);
      else showAvatarPop(item.post.id);
      patchEngagement(idx, {
        is_reposted_by_me: wasReposted,
        repost_count: wasReposted ? baseCount + 1 : Math.max(0, baseCount - 1),
      });
    }
  };

  /** Open comments for a slide (tracks focus + interaction for analytics). */
  const openComments = (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const targetId = engagementIdOf(item.post);
    interact(item.post.id, 'comment');
    // The sheet itself is CommentSheet (outside this workstream): opening it
    // is the focus signal; submit tracking needs sheet instrumentation.
    track('feed.comment_focus', {
      surface: 'video_feed',
      object_type: 'post',
      object_id: targetId,
    });
    setCommentPostId(targetId);
  };

  const patchItem = (idx: number, patch: Partial<Post>) =>
    setItems((prev) => prev.map((it, i) => (i === idx ? { ...it, post: { ...it.post, ...patch } } : it)));

  const toggleFullscreen = () => {
    if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    } else {
      containerRef.current?.requestFullscreen().catch(() => {});
    }
  };

  useEffect(() => {
    const onFs = () => setIsFullscreen(Boolean(document.fullscreenElement));
    document.addEventListener('fullscreenchange', onFs);
    return () => document.removeEventListener('fullscreenchange', onFs);
  }, []);

  // Dismiss the swipe hint after a few seconds.
  useEffect(() => {
    if (!showSwipeHint) return;
    const t = setTimeout(() => setShowSwipeHint(false), 6000);
    return () => clearTimeout(t);
  }, [showSwipeHint]);

  const dismissSwipeHint = () => {
    setShowSwipeHint(false);
    try { sessionStorage.setItem('buddyup-swipe-hint-seen', '1'); } catch {}
  };

  // Deliberate horizontal swipe (dx < -80, dominant over dy) navigates to the
  // active post author's profile. Gestures from carousels/sliders/buttons/
  // sheets are ignored; back falls back to /videos?start=<postId> via state.
  const handleTouchStart = (e: React.TouchEvent) => {
    const t = e.touches[0];
    touchOriginRef.current = { x: t.clientX, y: t.clientY };
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    const origin = touchOriginRef.current;
    touchOriginRef.current = null;
    if (!origin || commentPostId !== null || shareIdx !== null) return;
    if (shouldIgnoreSwipeOrigin(e.target)) return;
    const t = e.changedTouches[0];
    const dx = t.clientX - origin.x;
    const dy = t.clientY - origin.y;
    if (!isSwipeLeftToProfile(dx, dy)) return;
    const post = items[activeIndex]?.post;
    const username = post?.author_data?.username;
    if (!username) return;
    dismissSwipeHint();
    if (post) interact(post.id, 'profile_open');
    navigate(`/${username}`, { state: { returnTo: `/videos?start=${post.id}` } });
  };

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      onTouchStart={handleTouchStart}
      onTouchEnd={handleTouchEnd}
      className="h-full w-full overflow-y-scroll snap-y snap-mandatory bg-black"
      style={{ scrollSnapType: 'y mandatory' }}
    >
      <FsAvatarPopStyle />
      {isLoading && items.length === 0 && (
        <div className="h-full w-full flex flex-col items-center justify-center gap-3 text-buddy-text-secondary">
          <Loader2 size={32} className="animate-spin text-buddy-green" />
          <p className="text-sm">Loading videos...</p>
        </div>
      )}

      {!isLoading && items.length === 0 && (
        <div className="h-full w-full flex flex-col items-center justify-center gap-3 text-buddy-text-secondary">
          <Play size={40} className="text-buddy-text-secondary/40" />
          <p className="text-sm">No videos yet — post one to get started!</p>
          <button
            onClick={() => navigate('/create')}
            className="mt-2 px-4 py-2 rounded-full bg-buddy-green text-buddy-black text-sm font-semibold"
          >Create a video</button>
        </div>
      )}

      {items.map((item, idx) => {
        const { post } = item;
        const active = idx === activeIndex;
        // Engagement display follows the ORIGINAL on repost rows.
        const src = engagementSourceOf(post);
        return (
          <section
            key={post.id}
            className="h-full w-full snap-start relative flex items-center justify-center bg-black overflow-hidden"
            onClick={() => togglePlay(idx)}
          >
            {item.photoMode ? (
              <PostPhotoCarousel post={post} className="absolute inset-0" counterClassName="top-16 right-3" />
            ) : (
              <FeedVideoWithEdits
                ref={(el) => { videoRefs.current[idx] = el; }}
                video={item.video!}
                muted={isMuted}
                active={active}
                onTime={(ms, durSec) => {
                  if (active && durSec > 0) setProgress((ms / 1000 / durSec) * 100);
                }}
              />
            )}

            {/* Animated gradient bars on the sides for the TikTok feel */}
            <div className="absolute inset-y-0 left-0 w-8 bg-gradient-to-r from-black/60 to-transparent pointer-events-none" />
            <div className="absolute inset-y-0 right-0 w-8 bg-gradient-to-l from-black/60 to-transparent pointer-events-none" />

            {/* Top bar */}
            {controlsVisible && (
              <div data-no-swipe className="absolute top-0 left-0 right-0 z-20 flex items-center justify-between px-4 pt-4 pb-12 bg-gradient-to-b from-black/70 to-transparent">
                <h1 className="text-white font-bold text-base flex items-center gap-2">
                  <Play size={16} className="text-buddy-green fill-current" /> Videos
                </h1>
                <button
                  onClick={(e) => { e.stopPropagation(); navigate(-1); }}
                  className="p-2 rounded-full bg-black/40 hover:bg-black/60 text-white"
                  aria-label="Close"
                ><X size={18} /></button>
              </div>
            )}

            {/* Qualified-view recorder (in-view + active playback/progress). */}
            <ViewRecorder
              postId={post.id}
              active={active}
              progress={item.photoMode ? 0 : progress / 100}
              onRecorded={(n) => patchItem(idx, { view_count: n })}
            />

            {/* Bottom overlay — author + caption */}
            <div className="absolute bottom-0 left-0 right-0 z-10 px-4 pb-6 pt-16 bg-gradient-to-t from-black/80 to-transparent pointer-events-none">
              {post.is_repost && (
                <p className="animate-in slide-in-from-top-2 fade-in duration-300 text-[11px] font-semibold text-buddy-green mb-1.5 flex items-center gap-1">
                  <Repeat2 size={11} /> {(post as any).reposters?.[0]?.display_name || post.author_data?.display_name} reposted
                  {avatarPop[post.id] && (
                    <span
                      data-testid={`fs-repost-avatar-${post.id}`}
                      title={viewerName || 'You'}
                      className="inline-flex origin-center ml-0.5"
                      style={{
                        animation: avatarPop[post.id] === 'out'
                          ? 'budpress-avatar-out 220ms ease-in forwards'
                          : 'budpress-avatar-pop 320ms cubic-bezier(.34,1.56,.64,1) both',
                      }}
                    >
                      <Avatar src={viewerAvatar} alt={viewerName || 'You'} size="xs" />
                    </span>
                  )}
                </p>
              )}
              <div className="pointer-events-auto max-w-[70%]">
                <AuthorChip author={post.author_data} tone="onDark" viewCount={post.view_count ?? 0} />
              </div>
              {!item.photoMode && post.body && (
                <p className="text-white/90 text-sm mt-2 line-clamp-2">{post.body}</p>
              )}
              {post.gym_tag_name && (
                <p className="text-buddy-green text-xs mt-1 flex items-center gap-1">
                  <ChevronUp size={12} className="rotate-45" /> {post.gym_tag_name}
                </p>
              )}
            </div>

            {/* Right interaction rail */}
            <div data-no-swipe className="absolute right-2 bottom-24 z-20 flex flex-col items-center gap-1">
              <RailAction
                tone="onDark"
                label={src.user_reaction ? `Liked with ${toEmoji(src.user_reaction)}` : 'Like with flexed biceps'}
                icon={<Heart size={RAIL_ICON_SIZE + 4} className={`drop-shadow ${src.user_reaction ? 'fill-current' : ''}`} />}
                count={totalReactions(src.reaction_counts)}
                active={!!src.user_reaction}
                testId={`fs-like-${post.id}`}
                onClick={(e) => { e.stopPropagation(); void handleLike(idx); }}
              />
              <RailAction
                tone="onDark"
                label="Comments"
                icon={<MessageCircle size={RAIL_ICON_SIZE + 4} className="drop-shadow" />}
                count={src.comment_count ?? 0}
                testId={`fs-comment-${post.id}`}
                onClick={(e) => { e.stopPropagation(); openComments(idx); }}
              />
              <RailAction
                tone="onDark"
                label={post.is_reposted_by_me ? 'Undo repost' : 'Repost'}
                icon={<Repeat2 size={RAIL_ICON_SIZE + 4} className="drop-shadow" />}
                count={src.repost_count ?? 0}
                active={!!post.is_reposted_by_me}
                activeClassName="text-buddy-electric"
                testId={`fs-repost-${post.id}`}
                onClick={(e) => { e.stopPropagation(); void handleRepost(idx); }}
              />
              <RailAction
                tone="onDark"
                label={post.is_saved ? 'Unsave' : 'Save'}
                icon={post.is_saved
                  ? <BookmarkCheck size={RAIL_ICON_SIZE + 4} className="drop-shadow" />
                  : <Bookmark size={RAIL_ICON_SIZE + 4} className="drop-shadow" />}
                count={src.save_count}
                active={!!post.is_saved}
                testId={`fs-save-${post.id}`}
                onClick={(e) => { e.stopPropagation(); void handleSave(idx); }}
              />
              <RailAction
                tone="onDark"
                label="Share"
                icon={<Share2 size={RAIL_ICON_SIZE + 4} className="drop-shadow" />}
                count={post.share_count ?? 0}
                testId={`fs-share-${post.id}`}
                onClick={(e) => {
                  e.stopPropagation();
                  interact(post.id, 'share');
                  const r = (e.currentTarget as HTMLElement).getBoundingClientRect();
                  setShareAnchor({ top: r.top, left: r.left, bottom: r.bottom });
                  setShareIdx(idx);
                }}
              />
              <RailAction
                tone="onDark"
                label={`${post.view_count ?? 0} views`}
                icon={<Eye size={RAIL_ICON_SIZE + 4} className="drop-shadow" />}
                count={post.view_count ?? 0}
                testId={`fs-views-${post.id}`}
              />
            </div>

            {/* Center play/pause indicator */}
            {controlsVisible && !active && !item.photoMode && (
              <div className="absolute inset-0 flex items-center justify-center z-10 pointer-events-none">
                <div className="w-16 h-16 rounded-full bg-black/50 flex items-center justify-center">
                  <Play size={28} className="text-white ml-1" />
                </div>
              </div>
            )}

            {/* Video controls bar */}
            {controlsVisible && !item.photoMode && (
              <div data-no-swipe className="absolute bottom-0 left-0 right-0 z-20 px-3 pb-3">
                <div className="flex items-center gap-3 bg-black/50 backdrop-blur rounded-full px-3 py-2">
                  <button onClick={(e) => { e.stopPropagation(); togglePlay(idx); }} className="text-white">
                    {videoRefs.current[idx]?.paused ? <Play size={18} /> : <Pause size={18} />}
                  </button>
                  <div
                    className="flex-1 h-1 bg-white/30 rounded-full relative cursor-pointer"
                    onClick={(e) => {
                      e.stopPropagation();
                      const v = videoRefs.current[idx];
                      if (!v || !v.duration) return;
                      const rect = e.currentTarget.getBoundingClientRect();
                      const ratio = (e.clientX - rect.left) / rect.width;
                      v.currentTime = ratio * v.duration;
                    }}
                  >
                    <div className="absolute inset-y-0 left-0 bg-buddy-green rounded-full" style={{ width: `${progress}%` }} />
                  </div>
                  <button onClick={(e) => { e.stopPropagation(); setIsMuted((m) => !m); }} className="text-white">
                    {isMuted ? <VolumeX size={18} /> : <Volume2 size={18} />}
                  </button>
                  <button onClick={(e) => { e.stopPropagation(); toggleFullscreen(); }} className="text-white">
                    {isFullscreen ? <Minimize size={18} /> : <Maximize size={18} />}
                  </button>
                </div>
              </div>
            )}

            {/* Swipe-left hint */}
            {showSwipeHint && active && (
              <div className="absolute bottom-28 left-1/2 -translate-x-1/2 z-20 pointer-events-none">
                <span className="text-[11px] text-white/80 bg-black/50 rounded-full px-3 py-1.5 backdrop-blur">
                  ← Swipe left to view profile
                </span>
              </div>
            )}
          </section>
        );
      })}

      {isLoading && items.length > 0 && (
        <div className="h-16 flex items-center justify-center text-buddy-text-secondary">
          <Loader2 size={22} className="animate-spin text-buddy-green" />
        </div>
      )}

      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
      )}

      {shareIdx !== null && items[shareIdx] && (
        <PostShareSheet
          post={items[shareIdx].post}
          isOpen={shareIdx !== null}
          onClose={() => { setShareIdx(null); setShareAnchor(null); }}
          isSaved={!!items[shareIdx].post.is_saved}
          onToggleSave={() => void handleSave(shareIdx)}
          isReposted={!!items[shareIdx].post.is_reposted_by_me}
          onRepost={() => void handleRepost(shareIdx)}
          onShared={(n) => patchItem(shareIdx, { share_count: n })}
          anchorRect={shareAnchor}
        />
      )}
    </div>
  );
}
