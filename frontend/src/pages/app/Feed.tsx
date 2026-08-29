import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate, useLocation, useSearchParams } from 'react-router-dom';
import {
  Loader2, Users, ArrowRight, ArrowUp, Plus, Search, Flame, UserCheck, PenLine, ChevronUp,
} from 'lucide-react';
import { PostCard } from '@/components/features/feed/PostCard';
import { PostComposer } from '@/components/features/feed/PostComposer';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { VideoFeed } from '@/components/features/feed/VideoFeed';
import { Card } from '@/components/ui/Card';
import { ErrorBanner } from '@/components/ui/ErrorBanner';
import { feedApi } from '@/api';
import { messagingApi, type Community } from '@/api/messaging';
import { track } from '@/lib/analytics';
import type { FeedTab } from '@/api/feed';
import type { Post } from '@/types';

const TAB_ROUTES: Record<string, FeedTab> = {
  '/feed': 'for_you',
  '/feed/following': 'following',
  '/feed/communities': 'communities',
  '/feed/bud-press': 'videos',
  '/feed/meals': 'meals',
  '/feed/progress': 'progress',
};

const NEW_POSTS_POLL_MS = 45_000;

export default function Feed() {
  const navigate = useNavigate();
  const location = useLocation();
  const [activeTab, setActiveTab] = useState<FeedTab>(TAB_ROUTES[location.pathname] || 'for_you');
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [myCommunities, setMyCommunities] = useState<Community[]>([]);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const [fetchError, setFetchError] = useState<{ msg: string; reset: boolean } | null>(null);

  // Bud Press
  const [videoVariant, setVideoVariant] = useState<'fyp' | 'following'>('fyp');

  // The collapsed prompt expands IN PLACE into the full composer — no page,
  // no overlay. Works identically on phone, tablet and desktop.
  const [composerExpanded, setComposerExpanded] = useState(false);
  const composerRef = useRef<HTMLDivElement | null>(null);

  // "New posts" pill (X-style) — never auto-inserts while the user reads.
  const [newPostsCount, setNewPostsCount] = useState(0);
  const [pendingNewPosts, setPendingNewPosts] = useState<Post[]>([]);
  const feedTopRef = useRef<HTMLDivElement | null>(null);

  const cursorRef = useRef<string | undefined>(undefined);
  const loadingPageRef = useRef(false);
  const [hasMore, setHasMore] = useState(true);
  const observerRef = useRef<HTMLDivElement | null>(null);
  const knownIdsRef = useRef<Set<string>>(new Set());
  const postsCountRef = useRef(0);
  useEffect(() => { postsCountRef.current = posts.length; }, [posts.length]);

  useEffect(() => {
    messagingApi.getCommunities()
      .then((data) => setMyCommunities(data.mine || []))
      .catch(() => {});
  }, []);

  // Deep-link: Bud Press "Create" expands the inline composer on /feed.
  useEffect(() => {
    const st = location.state as { expandComposer?: boolean } | null;
    if (st?.expandComposer && location.pathname === '/feed') {
      setComposerExpanded(true);
      requestAnimationFrame(() =>
        composerRef.current?.scrollIntoView({ behavior: 'smooth', block: 'nearest' }),
      );
    }
  }, [location]);

  // Meal prefill coming from the Food Scanner ("Share as Meal Post")
  const locationState = location.state as { mealData?: { food_name?: string; calories?: number; protein_g?: number; carbs_g?: number; fat_g?: number; meal_type?: string } } | null;
  const mealPrefill = locationState?.mealData ?? null;
  const [initialMeal] = useState(mealPrefill);
  const [initialMealPhoto] = useState(() => {
    try { return sessionStorage.getItem('buddyup-meal-photo'); } catch { return null; }
  });

  const tabs: { key: FeedTab; label: string; to: string }[] = [
    { key: 'for_you', label: 'For You', to: '/feed' },
    { key: 'following', label: 'Following', to: '/feed/following' },
    ...(myCommunities.length > 0 ? [{ key: 'communities' as FeedTab, label: 'Communities', to: '/feed/communities' }] : []),
    { key: 'videos', label: 'Bud Press', to: '/feed/bud-press' },
    { key: 'meals', label: 'Meals', to: '/feed/meals' },
    { key: 'progress', label: 'Progress', to: '/feed/progress' },
  ];

  const fetchOpts = useCallback((tab: FeedTab) => (
    tab === 'for_you' ? { excludePostTypes: ['meal'] } : undefined
  ), []);

  const fetchPosts = useCallback(async (tab: FeedTab, reset = false) => {
    if (loadingPageRef.current && !reset) return;
    loadingPageRef.current = true;
    // Silent loading: when we already have content, refresh in the background
    // (slim top bar only) instead of flashing a spinner and blanking the list.
    const hasContent = postsCountRef.current > 0;
    if (!hasContent || !reset) setIsLoading(true);
    else setIsRefreshing(true);
    setFetchError(null);

    const c = reset ? undefined : cursorRef.current;
    try {
      const res = await feedApi.getFeed(tab, c, fetchOpts(tab));
      const newPosts = res.data || [];
      if (reset) {
        setPosts(newPosts);
        knownIdsRef.current = new Set(newPosts.map(p => p.id));
      } else {
        const unseenPosts = newPosts.filter(p => !knownIdsRef.current.has(p.id));
        unseenPosts.forEach(p => knownIdsRef.current.add(p.id));
        setPosts((prev) => [...prev, ...unseenPosts]);
      }
      cursorRef.current = res.pagination?.next
        ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined
        : undefined;
      setHasMore(!!res.pagination?.next);
      if (reset) {
        track('feed.loaded', {
          surface: 'feed',
          properties: { feed_tab: tab, count: newPosts.length },
        });
      }
    } catch {
      // A failed continuation must not leave the observer in an automatic retry loop.
      if (!reset) setHasMore(false);
      setFetchError({
        msg: reset ? 'Could not load your feed. Check your connection.' : 'Could not load more posts.',
        reset,
      });
    } finally {
      loadingPageRef.current = false;
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, [fetchOpts]);

  useEffect(() => {
    setActiveTab(TAB_ROUTES[location.pathname] || 'for_you');
  }, [location.pathname]);

  useEffect(() => {
    cursorRef.current = undefined;
    setPendingNewPosts([]);
    setNewPostsCount(0);
    fetchPosts(activeTab === 'videos' ? 'for_you' : activeTab, true);
  }, [activeTab, fetchPosts]);

  // Deep-link from notifications: /feed?post=:id opens that post's comments.
  const [searchParams, setSearchParams] = useSearchParams();
  useEffect(() => {
    const postId = searchParams.get('post');
    if (!postId) return;
    setSearchParams({}, { replace: true });
    feedApi.getPost(postId)
      .then((res) => {
        const post = res.data;
        if (!post) return;
        knownIdsRef.current.add(post.id);
        setPosts((prev) => (prev.some((p) => p.id === post.id) ? prev : [post, ...prev]));
        setCommentPostId(post.id);
      })
      .catch(() => {});
  }, [searchParams, setSearchParams]);

  // ── Silent polling for fresh posts (text tabs only) ────────────────────────
  const isVideoTab = activeTab === 'videos';
  useEffect(() => {
    if (isVideoTab || activeTab === 'communities') return;
    const interval = setInterval(async () => {
      try {
        const res = await feedApi.getFeed(activeTab, undefined, fetchOpts(activeTab));
        const incoming = (res.data || []).filter(p => !knownIdsRef.current.has(p.id));
        if (incoming.length > 0) {
          setPendingNewPosts(prev => {
            const seen = new Set([...prev.map(p => p.id)]);
            return [...prev, ...incoming.filter(p => !seen.has(p.id))];
          });
          setNewPostsCount(count => count + incoming.length);
        }
      } catch {}
    }, NEW_POSTS_POLL_MS);
    return () => clearInterval(interval);
  }, [activeTab, isVideoTab, fetchOpts]);

  const showNewPosts = () => {
    const incoming = pendingNewPosts;
    setPosts(prev => [...incoming.filter(p => !prev.some(x => x.id === p.id)), ...prev]);
    incoming.forEach(p => knownIdsRef.current.add(p.id));
    setPendingNewPosts([]);
    setNewPostsCount(0);
    feedTopRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  useEffect(() => {
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !isLoading && !isVideoTab && activeTab !== 'communities') {
          fetchPosts(activeTab, false);
        }
      },
      { threshold: 0.1 },
    );
    if (observerRef.current) obs.observe(observerRef.current);
    return () => obs.disconnect();
  }, [hasMore, isLoading, activeTab, isVideoTab, fetchPosts]);

  // ── Post impression tracking (50% visible for ≥1s, once per post) ──────────
  const activeTabRef = useRef(activeTab);
  activeTabRef.current = activeTab;
  const visibleSinceRef = useRef(new Map<string, number>());
  const firedImpressionsRef = useRef(new Set<string>());
  const impressionObserverRef = useRef<IntersectionObserver | null>(null);

  useEffect(() => {
    const obs = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        const postId = (entry.target as HTMLElement).dataset.postId;
        if (!postId || firedImpressionsRef.current.has(postId)) continue;
        if (entry.intersectionRatio >= 0.5) {
          if (!visibleSinceRef.current.has(postId)) {
            visibleSinceRef.current.set(postId, Date.now());
            window.setTimeout(() => {
              const since = visibleSinceRef.current.get(postId);
              if (since && Date.now() - since >= 900) {
                firedImpressionsRef.current.add(postId);
                track('feed.post_impression', {
                  surface: 'feed',
                  object_type: 'post',
                  object_id: postId,
                  properties: { feed_tab: activeTabRef.current },
                });
              }
            }, 1000);
          }
        } else {
          visibleSinceRef.current.delete(postId);
        }
      }
    }, { threshold: [0.5] });
    impressionObserverRef.current = obs;
    return () => obs.disconnect();
  }, []);

  const registerPostCard = useCallback((el: HTMLDivElement | null) => {
    if (el?.dataset.postId) impressionObserverRef.current?.observe(el);
  }, []);

  const handleNewPost = (post: Post) => {
    knownIdsRef.current.add(post.id);
    setPosts(prev => [post, ...prev]);
    setComposerExpanded(false);
    setPendingNewPosts([]); // our own post IS the fresh content
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto">
      {/* Tab bar */}
      <div className="sticky top-12 lg:top-0 z-10 bg-buddy-black border-b border-buddy-surface px-4 py-3">
        <div className="flex gap-1 bg-buddy-surface rounded-xl p-1 overflow-x-auto scrollbar-none">
          {tabs.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => {
                if (key !== activeTab) {
                  track('feed.tab_selected', { surface: 'feed', properties: { feed_tab: key } });
                }
                navigate(tabs.find(t => t.key === key)!.to);
              }}
              className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors whitespace-nowrap px-3 ${
                activeTab === key
                  ? 'bg-buddy-green text-buddy-black'
                  : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {activeTab === 'communities' ? (
        <div className="px-4 space-y-3 pb-8 pt-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-buddy-text-primary">Your Communities ({myCommunities.length})</h2>
            <button
              onClick={() => navigate('/communities')}
              className="text-xs text-buddy-green font-semibold hover:underline flex items-center gap-1"
            >
              Discover More <ArrowRight size={12} />
            </button>
          </div>
          <div className="grid gap-3">
            {myCommunities.map((c) => (
              <Card
                key={c.id}
                onClick={() => navigate(`/communities/${c.id}`)}
                className="p-4 flex items-center justify-between gap-3 hover:border-buddy-green/50 cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3 min-w-0">
                  {c.group_avatar_url ? (
                    <img src={c.group_avatar_url} alt="" className="w-11 h-11 rounded-full object-cover" />
                  ) : (
                    <div className="w-11 h-11 rounded-full bg-buddy-surface-raised flex items-center justify-center">
                      <Users size={20} className="text-buddy-green" />
                    </div>
                  )}
                  <div className="min-w-0">
                    <p className="font-semibold text-sm truncate">{c.group_name || 'Community'}</p>
                    <p className="text-xs text-buddy-text-secondary truncate">
                      {c.description || c.last_message?.body || 'Open community feed & chat'}
                    </p>
                  </div>
                </div>
                <div className="flex items-center text-xs text-buddy-green font-medium shrink-0">
                  Open <ArrowRight size={14} className="ml-1" />
                </div>
              </Card>
            ))}
          </div>
        </div>
      ) : activeTab === 'videos' ? (
        /* ── Bud Press — TikTok-style with FYP/Following switch ── */
        <div className="px-4 pt-3 pb-8">
          {/* Create + search row */}
          <div className="flex items-center gap-2 mb-3">
            <button
              onClick={() => navigate('/feed', { state: { expandComposer: true } })}
              className="flex items-center gap-1.5 px-3.5 py-2 rounded-full bg-buddy-green text-buddy-black text-sm font-bold hover:bg-buddy-green/90 transition-colors"
              title="Create a video post"
            >
              <Plus size={16} strokeWidth={3} />
              Create
            </button>
            <button
              onClick={() => navigate('/discover')}
              className="p-2 rounded-full bg-buddy-surface text-buddy-text-secondary hover:text-buddy-green transition-colors"
              title="Discover creators and videos"
            >
              <Search size={17} />
            </button>
            <div className="ml-auto flex items-center bg-buddy-surface rounded-xl p-1">
              <button
                onClick={() => setVideoVariant('fyp')}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors ${
                  videoVariant === 'fyp' ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'
                }`}
                title="For You Page — personalised video feed"
              >
                <Flame size={13} /> For You
              </button>
              <button
                onClick={() => setVideoVariant('following')}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors ${
                  videoVariant === 'following' ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'
                }`}
                title="Videos from people you follow"
              >
                <UserCheck size={13} /> Following
              </button>
            </div>
          </div>

          <VideoFeed variant={videoVariant} />

        </div>
      ) : (
        <>
          {/* Composer: collapsed prompt expands in place — never a separate page */}
          <div className="px-4 pt-4 pb-2" ref={composerRef}>
            {composerExpanded ? (
              <div className="animate-in fade-in slide-in-from-top-2 duration-200 relative">
                <button
                  onClick={() => setComposerExpanded(false)}
                  className="absolute right-3 top-3 z-10 p-1.5 rounded-full bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
                  title="Collapse composer"
                >
                  <ChevronUp size={16} />
                </button>
                <PostComposer
                  placeholder="Share your workout, meal, or progress..."
                  onPost={handleNewPost}
                  initialMeal={initialMeal}
                  initialMealPhotoDataUrl={initialMealPhoto}
                  onClose={() => setComposerExpanded(false)}
                />
              </div>
            ) : (
              <button
                onClick={() => {
                  setComposerExpanded(true);
                  requestAnimationFrame(() =>
                    composerRef.current?.scrollIntoView({ behavior: 'smooth', block: 'nearest' }),
                  );
                }}
                className="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl bg-buddy-surface text-buddy-text-secondary hover:bg-buddy-surface-raised transition-all hover:ring-1 hover:ring-buddy-green/30"
              >
                <span className="p-1.5 rounded-full bg-buddy-green/15 text-buddy-green">
                  <PenLine size={16} />
                </span>
                Share your workout, meal, or progress...
              </button>
            )}
          </div>

          {/* Background-refresh indicator */}
          {isRefreshing && (
            <div className="sticky top-[7.25rem] lg:top-[3.75rem] z-20 h-0.5 overflow-hidden">
              <div className="h-full w-1/3 bg-buddy-green animate-pulse" style={{ animation: 'slide 1s ease-in-out infinite alternate' }} />
            </div>
          )}

          {/* New posts pill (X-style) */}
          <div ref={feedTopRef} />
          {newPostsCount > 0 && (
            <div className="sticky top-[7.25rem] lg:top-[3.75rem] z-20 flex justify-center pointer-events-none">
              <button
                onClick={showNewPosts}
                className="pointer-events-auto -mt-2 mb-2 flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-buddy-green text-buddy-black text-xs font-bold shadow-lg shadow-buddy-green/30 hover:bg-buddy-green/90 transition-colors animate-in fade-in slide-in-from-top-2"
              >
                <ArrowUp size={13} strokeWidth={3} />
                {newPostsCount >= 10 ? '10+' : newPostsCount} new post{newPostsCount !== 1 ? 's' : ''}
              </button>
            </div>
          )}

          {/* Feed */}
          <div className="px-4 space-y-3 pb-8 pt-2">
            {!isLoading && fetchError && (
              <ErrorBanner
                message={fetchError.msg}
                onRetry={() => fetchPosts(activeTab, fetchError.reset)}
              />
            )}

            {posts.length === 0 && !isLoading && !fetchError && (
              <div className="text-center py-20">
                <p className="text-buddy-text-secondary text-lg">
                  {activeTab === 'meals' ? 'No meal posts yet' : activeTab === 'progress' ? 'No progress posts yet' : 'No posts yet'}
                </p>
                <p className="text-buddy-text-secondary/50 text-sm mt-1">
                  Buddy up with some people to see their posts here.
                </p>
              </div>
            )}

            {posts.map((post) => (
              <div key={post.id} data-post-id={post.id} ref={registerPostCard}>
                <PostCard
                  post={post}
                  onComment={(id) => {
                    track('feed.post_opened', {
                      surface: 'feed',
                      object_type: 'post',
                      object_id: id,
                      properties: { feed_tab: activeTab, via: 'comments' },
                    });
                    setCommentPostId(id);
                  }}
                />
              </div>
            ))}

            {isLoading && (
              <div className="flex justify-center py-8">
                <Loader2 size={24} className="animate-spin text-buddy-green" />
              </div>
            )}

            <div ref={observerRef} className="h-4" />
          </div>
        </>
      )}

      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
      )}
    </div>
  );
}
