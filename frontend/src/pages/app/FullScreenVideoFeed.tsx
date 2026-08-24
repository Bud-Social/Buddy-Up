import { useEffect, useRef, useState, useCallback } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  Play, Pause, Volume2, VolumeX, Maximize, Minimize,
  Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  X, ChevronUp, Loader2,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api/feed';
import { useAuthStore } from '@/store/authStore';
import { toEmoji } from '@/utils/emojiUtils';
import type { Post } from '@/types/post';

const VIDEO_EXT = /\.(mp4|mov|webm|m4v|mpeg|mkv)(\?|$)/i;

function pickVideoUrl(post: Post): string | null {
  for (const url of post.media_urls || []) {
    if (VIDEO_EXT.test(url)) return url;
  }
  return null;
}

interface VideoItem {
  post: Post;
  url: string;
}

export default function FullScreenVideoFeed() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const startPostId = searchParams.get('start');
  const profile = useAuthStore((s) => s.profile);

  const [items, setItems] = useState<VideoItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [activeIndex, setActiveIndex] = useState(0);
  const [controlsVisible, setControlsVisible] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [progress, setProgress] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);

  const containerRef = useRef<HTMLDivElement>(null);
  const startScrolledRef = useRef(false);
  const videoRefs = useRef<(HTMLVideoElement | null)[]>([]);
  const hideTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const isScrollingRef = useRef(false);

  const loadVideos = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await feedApi.getVideoFeed();
      const list = (res.data || [])
        .map((post) => ({ post, url: pickVideoUrl(post) }))
        .filter((v): v is VideoItem => Boolean(v.url));
      setItems((prev) => {
        const seen = new Set(prev.map((v) => v.post.id));
        const fresh = list.filter((v) => !seen.has(v.post.id));
        return [...prev, ...fresh];
      });
    } catch {} finally {
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

  // Lazy-load more videos near the bottom
  useEffect(() => {
    if (activeIndex >= items.length - 2 && items.length > 0) {
      loadVideos();
    }
  }, [activeIndex, items.length, loadVideos]);

  const togglePlay = (idx: number) => {
    const v = videoRefs.current[idx];
    if (!v) return;
    if (v.paused) v.play().catch(() => {});
    else v.pause();
    setControlsVisible(true);
    scheduleHide();
  };

  const handleLike = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const { post } = item;
    const current = post.user_reaction ? toEmoji(post.user_reaction) : null;
    const emoji = '💪';
    if (current === emoji) {
      try {
        await feedApi.unreact(post.id);
        post.user_reaction = null;
      } catch {}
    } else {
      try {
        await feedApi.react(post.id, emoji);
        post.user_reaction = emoji;
      } catch {}
    }
    setItems((prev) => prev.map((it, i) => (i === idx ? { ...it, post: { ...post } } : it)));
  };

  const handleSave = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const post = item.post;
    const next = !post.is_saved;
    setItems((prev) => prev.map((it, i) => (i === idx ? { ...it, post: { ...it.post, is_saved: next } } : it)));
    try {
      if (next) await feedApi.save(post.id);
      else await feedApi.unsave(post.id);
    } catch {}
  };

  const handleRepost = async (idx: number) => {
    const item = items[idx];
    if (!item) return;
    const wasReposted = item.post.is_reposted_by_me ?? false;
    // Optimistic update
    setItems((prev) => prev.map((it, i) =>
      i === idx ? { ...it, post: { ...it.post,
        is_reposted_by_me: !wasReposted,
        repost_count: wasReposted ? Math.max(0, (it.post.repost_count || 0) - 1) : (it.post.repost_count || 0) + 1,
      }} : it
    ));
    try {
      const res = await feedApi.repost(item.post.id);
      if (res.data) {
        setItems((prev) => prev.map((it, i) =>
          i === idx ? { ...it, post: { ...it.post,
            is_reposted_by_me: res.data!.action === 'reposted',
            repost_count: res.data!.repost_count,
          }} : it
        ));
      }
    } catch {
      // Rollback
      setItems((prev) => prev.map((it, i) =>
        i === idx ? { ...it, post: { ...it.post,
          is_reposted_by_me: wasReposted,
          repost_count: wasReposted ? (it.post.repost_count || 0) + 1 : Math.max(0, (it.post.repost_count || 0) - 1),
        }} : it
      ));
    }
  };

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

  const totalReactions = (post: Post) =>
    Object.values(post.reaction_counts || {}).reduce((a, b) => a + b, 0);

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      className="h-full w-full overflow-y-scroll snap-y snap-mandatory bg-black"
      style={{ scrollSnapType: 'y mandatory' }}
    >
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
            onClick={() => navigate('/feed')}
            className="mt-2 px-4 py-2 rounded-full bg-buddy-green text-buddy-black text-sm font-semibold"
          >Back to Feed</button>
        </div>
      )}

      {items.map((item, idx) => {
        const { post } = item;
        const active = idx === activeIndex;
        return (
          <section
            key={post.id}
            className="h-full w-full snap-start relative flex items-center justify-center bg-black overflow-hidden"
            onClick={() => togglePlay(idx)}
          >
            <video
              ref={(el) => { videoRefs.current[idx] = el; }}
              src={item.url}
              loop
              playsInline
              preload={active ? 'auto' : 'none'}
              muted={isMuted}
              className="w-full h-full object-contain"
              onTimeUpdate={(e) => {
                const v = e.currentTarget;
                if (v.duration) setProgress((v.currentTime / v.duration) * 100);
              }}
            />

            {/* Animated gradient bars on the sides for the TikTok feel */}
            <div className="absolute inset-y-0 left-0 w-8 bg-gradient-to-r from-black/60 to-transparent pointer-events-none" />
            <div className="absolute inset-y-0 right-0 w-8 bg-gradient-to-l from-black/60 to-transparent pointer-events-none" />

            {/* Top bar */}
            {controlsVisible && (
              <div className="absolute top-0 left-0 right-0 z-20 flex items-center justify-between px-4 pt-4 pb-12 bg-gradient-to-b from-black/70 to-transparent">
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

            {/* Bottom overlay — author + caption */}
            <div className="absolute bottom-0 left-0 right-0 z-10 px-4 pb-6 pt-16 bg-gradient-to-t from-black/80 to-transparent pointer-events-none">
              <div className="flex items-center gap-2">
                <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name} size="sm" className="ring-2 ring-white/30" />
                <button
                  onClick={(e) => { e.stopPropagation(); navigate(`/${post.author_data?.username}`); }}
                  className="text-white font-semibold text-sm pointer-events-auto"
                >@{post.author_data?.username}</button>
                {post.author_data?.verification_status === 'trainer' && (
                  <span className="text-[10px] bg-buddy-green text-buddy-black px-1.5 py-0.5 rounded-full font-medium pointer-events-auto">Trainer</span>
                )}
              </div>
              {post.body && (
                <p className="text-white/90 text-sm mt-2 line-clamp-2">{post.body}</p>
              )}
              {post.gym_tag_name && (
                <p className="text-buddy-green text-xs mt-1 flex items-center gap-1">
                  <ChevronUp size={12} className="rotate-45" /> {post.gym_tag_name}
                </p>
              )}
            </div>

            {/* Right interaction rail */}
            <div className="absolute right-2 bottom-24 z-20 flex flex-col items-center gap-5 pointer-events-none">
              <div className="flex flex-col items-center gap-5 pointer-events-auto">
                <div className="flex flex-col items-center gap-1">
                  <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name} size="md" className="ring-2 ring-white/40 mb-1" onClick={(e) => { e.stopPropagation(); navigate(`/${post.author_data?.username}`); }} />
                  <span className="w-6 h-6 rounded-full bg-buddy-green text-buddy-black flex items-center justify-center -mt-3 cursor-pointer" onClick={(e) => { e.stopPropagation(); handleLike(idx); }}>+</span>
                </div>

                <button onClick={(e) => { e.stopPropagation(); handleLike(idx); }} className="flex flex-col items-center gap-0.5 text-white">
                  <Heart size={26} className={post.user_reaction ? 'text-buddy-green fill-current' : 'drop-shadow'} />
                  <span className="text-[11px] font-medium">{totalReactions(post) || ''}</span>
                </button>

                <button onClick={(e) => { e.stopPropagation(); navigate('/feed'); }} className="flex flex-col items-center gap-0.5 text-white">
                  <MessageCircle size={26} className="drop-shadow" />
                  <span className="text-[11px] font-medium">{post.comment_count || ''}</span>
                </button>

                <button onClick={(e) => { e.stopPropagation(); handleRepost(idx); }} className="flex flex-col items-center gap-0.5 text-white" title={post.is_reposted_by_me ? 'Tap to undo repost' : 'Repost'}>
                  <Repeat2 size={26} className={`drop-shadow ${post.is_reposted_by_me ? 'text-buddy-electric' : ''}`} />
                  <span className="text-[11px] font-medium">{post.repost_count || ''}</span>
                </button>

                <button onClick={(e) => { e.stopPropagation(); handleSave(idx); }} className="flex flex-col items-center gap-0.5 text-white">
                  {post.is_saved ? <BookmarkCheck size={26} className="text-buddy-green drop-shadow" /> : <Bookmark size={26} className="drop-shadow" />}
                </button>
              </div>
            </div>

            {/* Center play/pause indicator */}
            {controlsVisible && !active && (
              <div className="absolute inset-0 flex items-center justify-center z-10 pointer-events-none">
                <div className="w-16 h-16 rounded-full bg-black/50 flex items-center justify-center">
                  <Play size={28} className="text-white ml-1" />
                </div>
              </div>
            )}

            {/* Video controls bar */}
            {controlsVisible && (
              <div className="absolute bottom-0 left-0 right-0 z-20 px-3 pb-3">
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

            {/* Profile chip (bottom-left, above caption when logged in) */}
            <span className="absolute bottom-28 left-3 text-[11px] text-white/50">{profile?.display_name ? 'Swipe up to explore' : ''}</span>
          </section>
        );
      })}

      {isLoading && items.length > 0 && (
        <div className="h-16 flex items-center justify-center text-buddy-text-secondary">
          <Loader2 size={22} className="animate-spin text-buddy-green" />
        </div>
      )}
    </div>
  );
}
