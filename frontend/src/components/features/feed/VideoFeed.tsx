/**
 * VideoFeed – TikTok/Reels-style vertical snap-scroll video player.
 *
 * Used inline inside the Bud Press tab (variant = fyp | following).
 * Only the active video plays; everything else pauses. Starts muted,
 * loops, autoplays — engagement actions (like/repost/save/comment) are
 * wired through feedApi so behaviour matches PostCard.
 *
 * Multi-media / photo posts render as swipeable photo-mode carousel
 * pages; single-video posts use post.media[0] (+ poster) when available.
 * Cursor-paginates via `pagination.next`.
 */
import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  Volume2, VolumeX, Loader2, Share2, Eye,
} from 'lucide-react';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { ErrorBanner } from '@/components/ui/ErrorBanner';
import { PostPhotoCarousel } from '@/components/features/feed/PostPhotoCarousel';
import { RailAction } from '@/components/features/feed/RailAction';
import { AuthorChip } from '@/components/features/feed/AuthorChip';
import { PostShareSheet } from '@/components/features/feed/PostShareSheet';
import { FeedTrackAudio } from '@/components/features/feed/FeedTrackAudio';
import { useRecordPostView } from '@/components/features/feed/useRecordPostView';
import { toEmoji } from '@/utils/emojiUtils';
import { feedApi } from '@/api';
import { mediaPagesFromPost, postIsPhotoMode, firstVideoPage } from '@/lib/mediaPages';
import type { Post } from '@/types';

interface VideoFeedProps {
  variant?: 'fyp' | 'following';
}

const totalReactions = (counts?: Record<string, number> | null) =>
  Object.values(counts || {}).reduce((a, b) => a + b, 0);

/** One fullscreen slide: shared rail, share sheet, view + track-audio wiring. */
function VideoFeedSlide({
  post, active, muted, last, onPatch, onComment, registerVideo, lastItemRef,
}: {
  post: Post;
  active: boolean;
  muted: boolean;
  last: boolean;
  onPatch: (id: string, patch: Partial<Post>) => void;
  onComment: (id: string) => void;
  registerVideo: (id: string, el: HTMLVideoElement | null) => void;
  lastItemRef: (el: HTMLDivElement | null) => void;
}) {
  const [shareOpen, setShareOpen] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const viewRef = useRecordPostView(post.id, {
    active: active && isPlaying,
    progress,
    onRecorded: (n) => onPatch(post.id, { view_count: n }),
  });

  const pages = mediaPagesFromPost(post);
  const photoMode = postIsPhotoMode(pages);
  const videoPage = firstVideoPage(pages);
  const videoUrl = videoPage?.url
    ?? post.media_urls?.find((u) => /\.(mp4|webm|mov|m4v)(\?|$)/i.test(u))
    ?? post.media_urls?.[0];
  const posterUrl = videoPage?.poster_url ?? undefined;

  const handleLike = async () => {
    const current = post.user_reaction ? toEmoji(post.user_reaction) : null;
    const emoji = '💪';
    if (current === emoji) {
      onPatch(post.id, { user_reaction: null });
      try {
        await feedApi.unreact(post.id);
      } catch {
        onPatch(post.id, { user_reaction: post.user_reaction });
      }
    } else {
      const prev = post.user_reaction;
      const counts = { ...(post.reaction_counts || {}) };
      if (prev) counts[prev] = Math.max(0, (counts[prev] || 1) - 1);
      counts[emoji] = (counts[emoji] || 0) + 1;
      onPatch(post.id, { user_reaction: emoji, reaction_counts: counts });
      try {
        await feedApi.react(post.id, emoji);
      } catch {
        onPatch(post.id, { user_reaction: prev });
      }
    }
  };

  const handleRepost = async () => {
    const was = !!post.is_reposted_by_me;
    onPatch(post.id, {
      is_reposted_by_me: !was,
      repost_count: Math.max(0, (post.repost_count || 0) + (was ? -1 : 1)),
    });
    try {
      const res = await feedApi.repost(post.id);
      if (res.data) onPatch(post.id, { is_reposted_by_me: res.data.action === 'reposted', repost_count: res.data.repost_count });
    } catch {
      onPatch(post.id, { is_reposted_by_me: was });
    }
  };

  const handleSave = async () => {
    const next = !post.is_saved;
    onPatch(post.id, { is_saved: next });
    try {
      if (next) await feedApi.save(post.id);
      else await feedApi.unsave(post.id);
    } catch {
      onPatch(post.id, { is_saved: !next });
    }
  };

  return (
    <div
      key={post.id}
      ref={last ? lastItemRef : undefined}
      className="relative h-full w-full snap-start snap-always bg-black"
    >
      {photoMode ? (
        <PostPhotoCarousel post={post} className="absolute inset-0" />
      ) : videoUrl ? (
        <>
          <video
            ref={(el) => registerVideo(post.id, el)}
            src={videoUrl}
            poster={posterUrl}
            loop
            playsInline
            muted={muted}
            preload={active ? 'auto' : 'none'}
            className="absolute inset-0 w-full h-full object-contain"
            onPlay={() => setIsPlaying(true)}
            onPause={() => setIsPlaying(false)}
            onTimeUpdate={(e) => {
              const v = e.currentTarget;
              if (v.duration > 0) setProgress(v.currentTime / v.duration);
            }}
          />
          <FeedTrackAudio
            getVideo={() => document.querySelector(`video[src="${CSS.escape(videoUrl)}"]`) as HTMLVideoElement | null}
            editMeta={videoPage?.edit_meta}
            soundUrl={videoPage?.sound_audio_url}
            soundVolume={videoPage?.sound_volume}
            soundPlacement={videoPage?.edit_meta?.sound_placement}
            trimStartMs={videoPage?.trim_start_ms}
            muted={muted}
            active={active && isPlaying}
          />
        </>
      ) : (
        <div className="absolute inset-0 flex items-center justify-center text-buddy-text-secondary text-sm">
          Unsupported media
        </div>
      )}

      {/* Qualified-view recorder */}
      <span ref={viewRef} className="absolute inset-0 pointer-events-none" aria-hidden />

      {/* Right rail actions */}
      <div className="absolute right-3 bottom-20 flex flex-col items-center gap-1 z-10">
        <RailAction
          tone="onDark"
          label={post.user_reaction ? 'Liked' : 'Like with flexed biceps'}
          icon={<Heart size={30} className={post.user_reaction ? 'text-buddy-green fill-current drop-shadow' : 'drop-shadow'} />}
          count={totalReactions(post.reaction_counts)}
          active={!!post.user_reaction}
          onClick={() => void handleLike()}
        />
        <RailAction
          tone="onDark"
          label="Comments"
          icon={<MessageCircle size={30} className="drop-shadow" />}
          count={post.comment_count ?? 0}
          onClick={() => onComment(post.id)}
        />
        <RailAction
          tone="onDark"
          label={post.is_reposted_by_me ? 'Undo repost' : 'Repost'}
          icon={<Repeat2 size={30} className="drop-shadow" />}
          count={post.repost_count ?? 0}
          active={!!post.is_reposted_by_me}
          activeClassName="text-buddy-electric"
          onClick={() => void handleRepost()}
        />
        <RailAction
          tone="onDark"
          label={post.is_saved ? 'Saved' : 'Save'}
          icon={post.is_saved
            ? <BookmarkCheck size={30} className="text-buddy-green drop-shadow" />
            : <Bookmark size={30} className="drop-shadow" />}
          count={post.save_count ?? 0}
          active={!!post.is_saved}
          onClick={() => void handleSave()}
        />
        <RailAction
          tone="onDark"
          label="Share"
          icon={<Share2 size={30} className="drop-shadow" />}
          count={post.share_count ?? 0}
          onClick={() => setShareOpen(true)}
        />
        <RailAction
          tone="onDark"
          label="Views"
          icon={<Eye size={30} className="drop-shadow" />}
          count={post.view_count ?? 0}
        />
      </div>

      {/* Bottom-left author info */}
      <div className="absolute left-3 bottom-20 right-16 z-10 pointer-events-none">
        <div className="pointer-events-auto max-w-full">
          <AuthorChip author={post.author_data} tone="onDark" />
        </div>
        {!photoMode && post.body && (
          <p className="text-white/90 text-xs line-clamp-2 drop-shadow">{post.body}</p>
        )}
      </div>

      <PostShareSheet
        post={post}
        isOpen={shareOpen}
        onClose={() => setShareOpen(false)}
        isSaved={!!post.is_saved}
        onToggleSave={() => void handleSave()}
        isReposted={!!post.is_reposted_by_me}
        onRepost={() => void handleRepost()}
        onShared={(n: number) => onPatch(post.id, { share_count: n })}
      />
    </div>
  );
}

export function VideoFeed({ variant = 'fyp' }: VideoFeedProps) {
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [fetchError, setFetchError] = useState('');
  const [reloadKey, setReloadKey] = useState(0);
  const [activeIndex, setActiveIndex] = useState(0);
  const [isMuted, setIsMuted] = useState(true);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const lastItemRef = useRef<HTMLDivElement | null>(null);
  const cursorRef = useRef<string | undefined>(undefined);
  const hasMoreRef = useRef(true);
  const loadingMoreLockRef = useRef(false);
  const videoEls = useRef(new Map<string, HTMLVideoElement | null>());

  const patchPost = useCallback((id: string, patch: Partial<Post>) => {
    setPosts((prev) => prev.map((p) => (p.id === id ? { ...p, ...patch } : p)));
  }, []);

  const registerVideo = useCallback((id: string, el: HTMLVideoElement | null) => {
    if (el) videoEls.current.set(id, el);
    else videoEls.current.delete(id);
  }, []);

  const loadPosts = useCallback(async (reset: boolean) => {
    if (!reset) {
      if (!hasMoreRef.current || loadingMoreLockRef.current) return;
      loadingMoreLockRef.current = true;
      setIsLoadingMore(true);
    }
    try {
      const res = await feedApi.getVideoFeed(variant, reset ? undefined : cursorRef.current);
      const list = res.data || [];
      cursorRef.current = res.pagination?.next
        ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined
        : undefined;
      hasMoreRef.current = !!res.pagination?.next;
      setPosts((prev) => {
        if (reset) return list;
        const seen = new Set(prev.map((p) => p.id));
        return [...prev, ...list.filter((p) => !seen.has(p.id))];
      });
      setFetchError('');
    } catch {
      if (!reset) hasMoreRef.current = false;
      setFetchError('Could not load videos. Check your connection.');
    } finally {
      loadingMoreLockRef.current = false;
      if (reset) setIsLoading(false);
      else setIsLoadingMore(false);
    }
  }, [variant]);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    setPosts([]);
    setActiveIndex(0);
    cursorRef.current = undefined;
    hasMoreRef.current = true;
    setFetchError('');
    feedApi.getVideoFeed(variant)
      .then((res) => {
        if (cancelled) return;
        setPosts(res.data || []);
        cursorRef.current = res.pagination?.next
          ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined
          : undefined;
        hasMoreRef.current = !!res.pagination?.next;
      })
      .catch(() => { if (!cancelled) setFetchError('Could not load videos. Check your connection.'); })
      .finally(() => { if (!cancelled) setIsLoading(false); });
    return () => { cancelled = true; };
  }, [variant, reloadKey]);

  // Play only the active post's video.
  useEffect(() => {
    const activeId = posts[activeIndex]?.id;
    videoEls.current.forEach((el, id) => {
      if (!el) return;
      if (id === activeId) {
        el.currentTime = el.currentTime || 0;
        el.play().catch(() => {});
      } else {
        el.pause();
      }
    });
  }, [activeIndex, posts]);

  const onScroll = useCallback(() => {
    const el = containerRef.current;
    if (!el) return;
    const idx = Math.round(el.scrollTop / Math.max(el.clientHeight, 1));
    if (idx !== activeIndex && idx >= 0 && idx < posts.length) setActiveIndex(idx);
  }, [activeIndex, posts.length]);

  // Infinite pagination: load the next cursor page when the last item shows.
  useEffect(() => {
    const el = lastItemRef.current;
    const root = containerRef.current;
    if (!el || !root || !hasMoreRef.current) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) void loadPosts(false);
      },
      { root, threshold: 0.5 },
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [posts.length, loadPosts]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-24">
        <Loader2 size={28} className="animate-spin text-buddy-green" />
      </div>
    );
  }

  if (fetchError && posts.length === 0) {
    return <ErrorBanner message={fetchError} onRetry={() => setReloadKey((k) => k + 1)} />;
  }

  if (posts.length === 0) {
    return (
      <div className="text-center py-24 px-6">
        <p className="text-buddy-text-secondary">No videos yet</p>
        <p className="text-buddy-text-secondary/60 text-sm mt-1">
          Tap ＋ Create to post the first clip.
        </p>
      </div>
    );
  }

  return (
    <>
      <div
        ref={containerRef}
        onScroll={onScroll}
        className="relative h-[calc(100dvh-14rem)] md:h-[calc(100dvh-12rem)] overflow-y-scroll snap-y snap-mandatory rounded-2xl"
      >
        <button
          onClick={() => setIsMuted((m) => !m)}
          className="absolute right-3 top-3 p-2 rounded-full bg-black/50 text-white z-20"
          title={isMuted ? 'Unmute' : 'Mute'}
          aria-label={isMuted ? 'Unmute videos' : 'Mute videos'}
        >
          {isMuted ? <VolumeX size={18} /> : <Volume2 size={18} />}
        </button>
        {posts.map((post, i) => (
          <VideoFeedSlide
            key={post.id}
            post={post}
            active={i === activeIndex}
            muted={isMuted}
            last={i === posts.length - 1}
            onPatch={patchPost}
            onComment={setCommentPostId}
            registerVideo={registerVideo}
            lastItemRef={(el) => { lastItemRef.current = el; }}
          />
        ))}
      </div>

      {isLoadingMore && (
        <div className="flex justify-center py-2">
          <Loader2 size={18} className="animate-spin text-buddy-green" />
        </div>
      )}

      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
      )}
    </>
  );
}
