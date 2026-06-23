import { useState, useEffect, useCallback, useRef } from 'react';
import { Plus, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { PostCard } from '@/components/features/feed/PostCard';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { CreatePostSheet } from '@/components/features/feed/CreatePostSheet';
import { feedApi } from '@/api';
import type { Post, ApiResponse } from '@/types';

type FeedTab = 'for_you' | 'following' | 'nearby';

export default function Feed() {
  const [activeTab, setActiveTab] = useState<FeedTab>('for_you');
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isCreating, setIsCreating] = useState(false);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const cursorRef = useRef<string | undefined>(undefined);
  const [hasMore, setHasMore] = useState(true);
  const observerRef = useRef<HTMLDivElement | null>(null);

  const tabs: { key: FeedTab; label: string }[] = [
    { key: 'for_you', label: 'For You' },
    { key: 'following', label: 'Following' },
    { key: 'nearby', label: 'Nearby' },
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
      cursorRef.current = res.pagination?.next ? new URLSearchParams(res.pagination.next.split('?')[1]).get('cursor') || undefined : undefined;
      setHasMore(!!res.pagination?.next);
    } catch {} finally {
      setIsLoading(false);
    }
  }, []);

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

  const handleSave = async (postId: string) => {
    try { await feedApi.save(postId); } catch {}
  };

  return (
    <div className="max-w-lg mx-auto">
      <div className="sticky top-0 z-10 bg-buddy-black/95 backdrop-blur-lg border-b border-buddy-surface px-4 py-3">
        <div className="flex gap-1 bg-buddy-surface rounded-xl p-1">
          {tabs.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setActiveTab(key)}
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

      <div className="px-4 py-3">
        <button
          onClick={() => setIsCreating(true)}
          className="w-full flex items-center gap-2 bg-buddy-surface hover:bg-buddy-surface-raised rounded-xl px-4 py-3 text-buddy-text-secondary text-sm transition-colors"
        >
          <Plus size={18} className="text-buddy-green" />
          Share your workout, meal, or progress...
        </button>
      </div>

      <div className="px-4 space-y-4 pb-8">
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
            onSave={handleSave}
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

      <CreatePostSheet
        isOpen={isCreating}
        onClose={() => setIsCreating(false)}
      />
    </div>
  );
}
