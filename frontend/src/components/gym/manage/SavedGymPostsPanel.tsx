import { useEffect, useState } from 'react';
import { Loader2, Bookmark } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { PostCard } from '@/components/features/feed/PostCard';
import { gymFeedApi } from '@/api/gyms';
import { feedApi } from '@/api/feed';
import type { Post } from '@/types';

interface Props {
  slug: string;
  gymName: string;
}

/**
 * The gym's saved posts — the posts the gym bookmarked as engagement material
 * or reference. Same public cards as the home feed, but only the gym's
 * curator is toggling them.
 */
export function SavedGymPostsPanel({ slug, gymName }: Props) {
  const [posts, setPosts] = useState<Post[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!slug) return;
    setLoading(true);
    gymFeedApi.saved(slug)
      .then((res) => {
        const items = res?.items ?? [];
        setPosts(items as Post[]);
      })
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load saved posts.'))
      .finally(() => setLoading(false));
  }, [slug]);

  const unsave = async (postId: string) => {
    setPosts((prev) => prev?.filter((p) => p.id !== postId) ?? prev);
    try { await gymFeedApi.save(slug, postId); } catch { /* */ }
  };

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        {Array.from({ length: 3 }).map((_, i) => <div key={i} className="h-32 bg-buddy-surface rounded-2xl" />)}
      </div>
    );
  }

  return (
    <section className="space-y-2">
      <p className="text-[9px] uppercase text-buddy-text-secondary flex items-center gap-1.5">
        <Bookmark size={12} className="text-buddy-green" /> Posts saved by <span className="text-buddy-green">{gymName}</span>
      </p>
      {error && <p className="text-[10px] text-buddy-red bg-buddy-red/5 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{error}</p>}
      {posts?.length === 0 ? (
        <Card className="p-6 text-center">
          <Bookmark size={20} className="mx-auto mb-2 text-buddy-text-secondary/50" />
          <p className="text-xs font-semibold">Nothing saved yet</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">Save posts from your gym's home feed to keep them here for programming reference.</p>
        </Card>
      ) : (
        posts?.map((post) => (
          <PostCard
            key={post.id}
            post={post}
            onSave={(id) => unsave(id)}
            onLike={(id) => { gymFeedApi.react(slug, id, '💪').catch(() => {}); }}
            onReact={(id, reaction) => { gymFeedApi.react(slug, id, reaction).catch(() => {}); }}
            onRepost={(id) => { gymFeedApi.repost(slug, id).catch(() => {}); }}
          />
        ))
      )}
    </section>
  );
}
