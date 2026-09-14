import { useEffect, useState } from 'react';
import { BarChart3, Eye, Heart, MessageCircle, Repeat2, Bookmark, Share2, Loader2 } from 'lucide-react';
import { feedApi } from '@/api/feed';
import type { CreatorInsightItem } from '@/types';
import { formatCount } from './RailAction';

function num(v: number | undefined): number {
  return typeof v === 'number' && Number.isFinite(v) ? v : 0;
}

function timeAgo(iso?: string): string {
  if (!iso) return '';
  const ms = Date.now() - new Date(iso).getTime();
  if (!Number.isFinite(ms) || ms < 0) return '';
  const days = Math.floor(ms / 86_400_000);
  if (days < 1) return 'today';
  if (days === 1) return 'yesterday';
  if (days < 30) return `${days}d ago`;
  return new Date(iso).toLocaleDateString();
}

/**
 * Owner-only per-post performance table (views / likes / comments / reposts /
 * saves / shares). Tolerant of a missing endpoint: shows an empty/error state
 * and never crashes.
 */
export function CreatorInsights() {
  const [items, setItems] = useState<CreatorInsightItem[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    feedApi.getCreatorInsights()
      .then((res) => {
        if (cancelled) return;
        setItems(Array.isArray(res.data) ? res.data : []);
      })
      .catch(() => {
        if (cancelled) return;
        setError('Insights are unavailable right now.');
        setItems([]);
      });
    return () => { cancelled = true; };
  }, []);

  if (items === null && !error) {
    return (
      <div className="flex items-center justify-center gap-2 py-10 text-buddy-text-secondary" aria-label="Loading insights">
        <Loader2 size={20} className="animate-spin" />
        <span className="text-sm">Loading insights…</span>
      </div>
    );
  }

  if (error || items?.length === 0) {
    return (
      <div className="text-center py-10 px-4" data-testid="insights-empty">
        <BarChart3 size={36} className="mx-auto text-buddy-text-secondary/30 mb-3" />
        <p className="text-buddy-text-secondary text-sm font-medium">No insights yet</p>
        <p className="text-buddy-text-secondary/70 text-xs mt-1">
          {error ?? 'Post something and check back — views, likes and shares will show up here.'}
        </p>
      </div>
    );
  }

  const totals = (items ?? []).reduce(
    (acc, it) => ({
      views: acc.views + num(it.views),
      likes: acc.likes + num(it.likes),
      comments: acc.comments + num(it.comments),
      reposts: acc.reposts + num(it.reposts),
      saves: acc.saves + num(it.saves),
      shares: acc.shares + num(it.shares),
    }),
    { views: 0, likes: 0, comments: 0, reposts: 0, saves: 0, shares: 0 },
  );

  const summary: { key: string; label: string; value: number; icon: typeof Eye }[] = [
    { key: 'views', label: 'Views', value: totals.views, icon: Eye },
    { key: 'likes', label: 'Likes', value: totals.likes, icon: Heart },
    { key: 'comments', label: 'Comments', value: totals.comments, icon: MessageCircle },
    { key: 'reposts', label: 'Reposts', value: totals.reposts, icon: Repeat2 },
    { key: 'saves', label: 'Saves', value: totals.saves, icon: Bookmark },
    { key: 'shares', label: 'Shares', value: totals.shares, icon: Share2 },
  ];

  return (
    <div data-testid="creator-insights">
      <div className="grid grid-cols-3 gap-2 mb-3">
        {summary.map(({ key, label, value, icon: Icon }) => (
          <div key={key} className="bg-buddy-surface-raised rounded-xl py-2.5 px-2 text-center">
            <Icon size={13} className="mx-auto text-buddy-green mb-1" />
            <p className="font-mono font-bold text-base tabular-nums">{formatCount(value)}</p>
            <p className="text-[11px] text-buddy-text-secondary">{label}</p>
          </div>
        ))}
      </div>
      <div className="space-y-2">
        {(items ?? []).map((it) => (
          <div key={it.post_id} className="bg-buddy-surface rounded-xl border border-buddy-surface-raised px-3 py-2.5">
            <div className="flex items-center gap-2 text-[11px] text-buddy-text-secondary mb-1.5">
              <span className="font-mono truncate">Post {it.post_id.slice(0, 8)}…</span>
              {it.visibility && (
                <span className="px-1.5 py-0.5 rounded-full bg-buddy-surface-raised capitalize">{it.visibility}</span>
              )}
              <span className="ml-auto shrink-0">{timeAgo(it.created_at)}</span>
            </div>
            <div className="grid grid-cols-6 gap-1 text-center">
              {[
                { label: 'Views', value: num(it.views) },
                { label: 'Likes', value: num(it.likes) },
                { label: 'Comments', value: num(it.comments) },
                { label: 'Reposts', value: num(it.reposts) },
                { label: 'Saves', value: num(it.saves) },
                { label: 'Shares', value: num(it.shares) },
              ].map(({ label, value }) => (
                <div key={label}>
                  <p className="font-mono font-bold text-sm tabular-nums">{formatCount(value)}</p>
                  <p className="text-[10px] text-buddy-text-secondary">{label}</p>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
