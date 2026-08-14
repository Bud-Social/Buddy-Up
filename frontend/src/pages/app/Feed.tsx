import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { PostCard } from '@/components/features/feed/PostCard';
import { PostComposer } from '@/components/features/feed/PostComposer';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { feedApi } from '@/api';
import type { FeedTab } from '@/api/feed';
import type { Post } from '@/types';

const TAB_ROUTES: Record<string, FeedTab> = {
  '/feed': 'for_you',
  '/feed/following': 'following',
  '/feed/bud-press': 'videos',
  '/feed/meals': 'meals',
};

export default function Feed() {
  const navigate = useNavigate();
  const location = useLocation();
  const [activeTab, setActiveTab] = useState<FeedTab>(TAB_ROUTES[location.pathname] || 'for_you');
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const cursorRef = useRef<string | undefined>(undefined);
  const [hasMore, setHasMore] = useState(true);
  const observerRef = useRef<HTMLDivElement | null>(null);

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
    { key: 'videos', label: 'Bud Press', to: '/feed/bud-press' },
    { key: 'meals', label: 'Meals', to: '/feed/meals' },
  ];

  const fetchPosts = useCallback(async (tab: FeedTab, reset = false) => {
    setIsLoading(true);
    const c = reset ? undefined : cursorRef.current;
    try {
      const res = await feedApi.getFeed(tab, c);
      const newPosts = res.data || [];
      if (reset) {
        setPosts(newPosts);
      } else {
        setPosts((prev) => [...prev, ...newPosts]);
      }
      cursorRef.current = res.pagination?.next
        ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined
        : undefined;
      setHasMore(!!res.pagination?.next);
    } catch {} finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    setActiveTab(TAB_ROUTES[location.pathname] || 'for_you');
  }, [location.pathname]);

  useEffect(() => {
    cursorRef.current = undefined;
    fetchPosts(activeTab, true);
  }, [activeTab, fetchPosts]);

  useEffect(() => {
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !isLoading) {
          fetchPosts(activeTab, false);
        }
      },
      { threshold: 0.1 },
    );
    if (observerRef.current) obs.observe(observerRef.current);
    return () => obs.disconnect();
  }, [hasMore, isLoading, activeTab, fetchPosts]);

  const handleNewPost = (post: Post) => {
    setPosts(prev => [post, ...prev]);
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto">
      {/* Tab bar */}
      <div className="sticky top-12 lg:top-0 z-10 bg-buddy-black border-b border-buddy-surface px-4 py-3">
        <div className="flex gap-1 bg-buddy-surface rounded-xl p-1">
          {tabs.map(({ key, label, to }) => (
            <button
              key={key}
              onClick={() => navigate(to)}
              className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
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

      {/* Composer */}
      <div className="px-4 pt-4 pb-2">
        <PostComposer
          placeholder="Share your workout, meal, or progress..."
          onPost={handleNewPost}
          initialMeal={initialMeal}
          initialMealPhotoDataUrl={initialMealPhoto}
        />
      </div>

      {/* Feed */}
      <div className="px-4 space-y-3 pb-8 pt-2">
        {posts.length === 0 && !isLoading && (
          <div className="text-center py-20">
            <p className="text-buddy-text-secondary text-lg">No posts yet</p>
            <p className="text-buddy-text-secondary/50 text-sm mt-1">
              Buddy up with some people to see their posts here.
            </p>
          </div>
        )}

        {posts.map((post) => (
          <PostCard
            key={post.id}
            post={post}
            onComment={(id) => setCommentPostId(id)}
          />
        ))}

        {isLoading && (
          <div className="flex justify-center py-8">
            <Loader2 size={24} className="animate-spin text-buddy-green" />
          </div>
        )}

        <div ref={observerRef} className="h-4" />
      </div>

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
