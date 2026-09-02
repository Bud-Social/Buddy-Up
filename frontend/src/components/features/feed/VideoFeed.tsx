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
  Heart, MessageCircle, Repeat2, Bookmark,
  Volume2, VolumeX, Loader2,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { ErrorBanner } from '@/components/ui/ErrorBanner';
import { PostPhotoCarousel } from '@/components/features/feed/PostPhotoCarousel';
import { feedApi } from '@/api';
import { mediaPagesFromPost, postIsPhotoMode, firstVideoPage } from '@/lib/mediaPages';
import type { Post } from '@/types';

interface VideoFeedProps {
  variant?: 'fyp' | 'following';
}

export function VideoFeed({ variant = 'fyp' }: VideoFeedProps) {
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [fetchError, setFetchError] = useState('');
  const [reloadKey, setReloadKey] = useState(0);
  const [activeIndex, setActiveIndex] = useState(0);
  const [isMuted, setIsMuted] = useState(true);
  const [likedIds, setLikedIds] = useState<Set<string>>(new Set());
  const [savedIds, setSavedIds] = useState<Set<string>>(new Set());
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const lastItemRef = useRef<HTMLDivElement | null>(null);
  const cursorRef = useRef<string | undefined>(undefined);
  const hasMoreRef = useRef(true);
  const loadingMoreLockRef = useRef(false);
  const videoRefs = useRef<(HTMLVideoElement | null)[]>([]);

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

  // Play only the active index.
  useEffect(() => {
    videoRefs.current.forEach((el, i) => {
      if (!el) return;
      if (i === activeIndex) {
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

  const toggleLike = async (postId: string) => {
    const next = new Set(likedIds);
    try {
      if (next.has(postId)) {
        next.delete(postId);
        await feedApi.unreact(postId);
      } else {
        next.add(postId);
        await feedApi.react(postId, 'like');
      }
      setLikedIds(new Set(next));
    } catch {}
  };

  const toggleSave = async (postId: string) => {
    const next = new Set(savedIds);
    try {
      if (next.has(postId)) {
        next.delete(postId);
        await feedApi.unsave(postId);
      } else {
        next.add(postId);
        await feedApi.save(postId);
      }
      setSavedIds(new Set(next));
    } catch {}
  };

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
        className="h-[calc(100dvh-14rem)] md:h-[calc(100dvh-12rem)] overflow-y-scroll snap-y snap-mandatory rounded-2xl"
      >
        {posts.map((post, i) => {
          const pages = mediaPagesFromPost(post);
          const photoMode = postIsPhotoMode(pages);
          const videoPage = firstVideoPage(pages);
          const videoUrl = videoPage?.url
            ?? post.media_urls?.find((u) => /\.(mp4|webm|mov|m4v)(\?|$)/i.test(u))
            ?? post.media_urls?.[0];
          const posterUrl = videoPage?.poster_url ?? undefined;
          const liked = likedIds.has(post.id);
          const saved = savedIds.has(post.id);
          const isActive = i === activeIndex;
          return (
            <div
              key={post.id}
              ref={i === posts.length - 1 ? lastItemRef : undefined}
              className="relative h-full w-full snap-start snap-always bg-black"
            >
              {photoMode ? (
                <PostPhotoCarousel post={post} className="absolute inset-0" />
              ) : videoUrl ? (
                <video
                  ref={(el) => { videoRefs.current[i] = el; }}
                  src={videoUrl}
                  poster={posterUrl}
                  loop
                  playsInline
                  muted={isMuted}
                  preload={isActive ? 'auto' : 'none'}
                  className="absolute inset-0 w-full h-full object-contain"
                />
              ) : (
                <div className="absolute inset-0 flex items-center justify-center text-buddy-text-secondary text-sm">
                  Unsupported media
                </div>
              )}

              {/* Right rail actions */}
              <div className="absolute right-3 bottom-20 flex flex-col items-center gap-4 z-10">
                <button onClick={() => toggleLike(post.id)} className="flex flex-col items-center gap-0.5">
                  <Heart size={26} className={liked ? 'text-buddy-red fill-buddy-red' : 'text-white'} />
                </button>
                <button onClick={() => setCommentPostId(post.id)} className="flex flex-col items-center gap-0.5 text-white">
                  <MessageCircle size={26} />
                </button>
                <button onClick={() => feedApi.repost(post.id).catch(() => {})} className="text-white">
                  <Repeat2 size={28} />
                </button>
                <button onClick={() => toggleSave(post.id)}>
                  <Bookmark size={25} className={saved ? 'text-buddy-gold fill-buddy-gold' : 'text-white'} />
                </button>
              </div>

              {/* Bottom-left author info */}
              <div className="absolute left-3 bottom-20 right-16 z-10 pointer-events-none">
                <div className="flex items-center gap-2 mb-1">
                  <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name ?? ''} size="xs" />
                  <span className="text-white text-sm font-bold drop-shadow">
                    @{post.author_data?.username ?? 'unknown'}
                  </span>
                </div>
                {!photoMode && post.body && (
                  <p className="text-white/90 text-xs line-clamp-2 drop-shadow">{post.body}</p>
                )}
              </div>

              {/* Mute toggle (single-video posts only — photo-mode videos unmute on tap) */}
              {!photoMode && (
                <button
                  onClick={() => setIsMuted((m) => !m)}
                  className="absolute right-3 top-3 p-2 rounded-full bg-black/50 text-white z-10"
                  title={isMuted ? 'Unmute' : 'Mute'}
                >
                  {isMuted ? <VolumeX size={18} /> : <Volume2 size={18} />}
                </button>
              )}
            </div>
          );
        })}
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
