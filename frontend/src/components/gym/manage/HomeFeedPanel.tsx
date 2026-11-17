import { useEffect, useState } from 'react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { PostCard } from '@/components/features/feed/PostCard';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import { Loader2, Dumbbell } from 'lucide-react';
import { feedApi } from '@/api/feed';
import { gymFeedApi } from '@/api/gyms';
import type { Post } from '@/types';

interface HomeFeedPanelProps {
  /** When set, the console engages with the home feed *as the gym*. */
  gymSlug?: string;
  gymName?: string;
}

/**
 * Read-only view of the public home feed from inside the gym console.
 *
 * Passed a gym identity it stops being read-only: liking, reacting,
 * reposting and commenting act as the gym (via /gyms/:slug/feed/* endpoints)
 * instead of as the acting staff member's personal account.
 */
export function HomeFeedPanel({ gymSlug, gymName }: HomeFeedPanelProps) {
  const engageAs = gymSlug || null;
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [cursor, setCursor] = useState<string | undefined>(undefined);
  const [hasMore, setHasMore] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await feedApi.getFeed('for_you');
      const items = (res.data as Post[] | { results?: Post[] } | undefined) ?? [];
      const list = Array.isArray(items) ? items : (items.results ?? []);
      setPosts(list);
      setHasMore(list.length >= 20);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load the home feed.');
      setPosts([]);
      setHasMore(false);
    } finally {
      setIsLoading(false);
    }
  };

  const loadMore = async () => {
    if (!hasMore || isLoadingMore) return;
    setIsLoadingMore(true);
    try {
      const res = await feedApi.getFeed('for_you', cursor);
      const items = (res.data as Post[] | { results?: Post[] } | undefined) ?? [];
      const list = Array.isArray(items) ? items : (items.results ?? []);
      setPosts((prev) => [...prev, ...list]);
      setCursor(list.length >= 20 ? 'more' : undefined);
      setHasMore(list.length >= 20);
    } catch {
      setHasMore(false);
    } finally {
      setIsLoadingMore(false);
    }
  };

  useEffect(() => { load(); }, []);

  return (
    <section className="space-y-2">
      <p className="text-[9px] uppercase text-buddy-text-secondary">
        {engageAs && gymName ? (
          <span className="flex items-center gap-1.5"><Dumbbell size={11} className="text-buddy-green" /><span>Interacting as <span className="text-buddy-green">{gymName}</span> — your like, reply and repost appear as the gym</span></span>
        ) : 'Public home feed · read-only from the gym console'}
      </p>
      {error && <p className="text-[10px] text-buddy-red bg-buddy-red/5 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{error}</p>}

      {isLoading ? (
        <Card className="h-24 animate-pulse bg-buddy-surface-raised" />
      ) : posts.length === 0 ? (
        <Card className="p-8 text-center text-buddy-text-secondary text-xs">
          No posts on the home feed yet.
        </Card>
      ) : (
        <>
          {posts.map((post) => (
            <PostCard
              key={post.id}
              post={post}
              onComment={engageAs ? (id) => setCommentPostId(id) : undefined}
              onLike={engageAs ? (id) => { gymFeedApi.react(engageAs, id, '💪').catch(() => {}); } : undefined}
              onReact={engageAs ? (id, reaction) => { gymFeedApi.react(engageAs, id, reaction).catch(() => {}); } : undefined}
              onRepost={engageAs ? (id) => { gymFeedApi.repost(engageAs, id).catch(() => {}); } : undefined}
            />
          ))}
          {hasMore && (
            <div className="flex justify-center pt-1">
              <Button size="sm" variant="outline" isLoading={isLoadingMore} onClick={loadMore}>
                {isLoadingMore ? <Loader2 size={13} className="animate-spin" /> : <span className="text-xs">Load more</span>}
              </Button>
            </div>
          )}
        </>
      )}

      {engageAs && (
        <CommentSheet
          postId={commentPostId ?? ''}
          gymSlug={engageAs}
          gymName={gymName}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
      )}
    </section>
  );
}
