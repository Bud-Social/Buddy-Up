import { useEffect, useState } from 'react';
import { BarChart3, Eye, Heart, MessageCircle, Repeat2, Bookmark, Share2, Loader2, Timer, Clock3, Zap } from 'lucide-react';
import { feedApi } from '@/api/feed';
import type { CreatorInsightItem, CreatorInsightSummary } from '@/types';
import { formatCount } from './RailAction';

function num(v: number | undefined): number {
  return typeof v === 'number' && Number.isFinite(v) ? v : 0;
}

/** Human duration for focus/watch metrics: "1m 23s" / "12s" / "0s". */
export function formatDuration(ms: number): string {
  const total = Math.max(0, Math.round(ms / 1000));
  const m = Math.floor(total / 60);
  const s = total % 60;
  if (m === 0) return `${s}s`;
  return `${m}m ${s}s`;
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
 * saves / shares) plus attention metrics: interactions, watch time and average
 * focus time. Tolerant of a missing endpoint: shows an empty/error state and
 * never crashes.
 */
export function CreatorInsights() {
  const [items, setItems] = useState<CreatorInsightItem[] | null>(null);
  const [summary, setSummary] = useState<CreatorInsightSummary | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    feedApi.getCreatorInsights()
      .then((res) => {
        if (cancelled) return;
        // Defensive: the payload may be {items, summary} (current) or a bare
        // array (older deploys of the endpoint).
        if (Array.isArray(res.data)) {
          setItems(res.data);
          setSummary(null);
        } else if (res.data && typeof res.data === 'object') {
          setItems(Array.isArray(res.data.items) ? res.data.items : []);
          setSummary(res.data.summary ?? null);
        } else {
          setItems([]);
        }
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
      interactions: acc.interactions + num(it.interactions),
      watch_ms: acc.watch_ms + num(it.watch_ms),
      total_focus_ms: acc.total_focus_ms + num(it.total_focus_ms),
      focus_sessions: acc.focus_sessions + num(it.focus_sessions),
    }),
    {
      views: 0, likes: 0, comments: 0, reposts: 0, saves: 0, shares: 0,
      interactions: 0, watch_ms: 0, total_focus_ms: 0, focus_sessions: 0,
    },
  );

  // Prefer the server rollup; fall back to client-side aggregation.
  const rollup = (key: keyof CreatorInsightSummary, fallback: number): number =>
    num(summary?.[key] as number | undefined) || fallback;

  const avgFocus = rollup('avg_focus_ms', 0)
    || (totals.focus_sessions > 0 ? Math.round(totals.total_focus_ms / totals.focus_sessions) : 0);

  const summaryTiles: { key: string; label: string; value: string; icon: typeof Eye }[] = [
    { key: 'views', label: 'Views', value: formatCount(rollup('views', totals.views)), icon: Eye },
    { key: 'interactions', label: 'Interactions', value: formatCount(rollup('interactions', totals.interactions)), icon: Zap },
    { key: 'watch', label: 'Watch time', value: formatDuration(rollup('watch_ms', totals.watch_ms)), icon: Clock3 },
    { key: 'avg_focus', label: 'Avg focus', value: formatDuration(avgFocus), icon: Timer },
    { key: 'likes', label: 'Likes', value: formatCount(rollup('likes', totals.likes)), icon: Heart },
    { key: 'comments', label: 'Comments', value: formatCount(rollup('comments', totals.comments)), icon: MessageCircle },
    { key: 'reposts', label: 'Reposts', value: formatCount(rollup('reposts', totals.reposts)), icon: Repeat2 },
    { key: 'saves', label: 'Saves', value: formatCount(rollup('saves', totals.saves)), icon: Bookmark },
    { key: 'shares', label: 'Shares', value: formatCount(rollup('shares', totals.shares)), icon: Share2 },
  ];

  return (
    <div data-testid="creator-insights">
      <div className="grid grid-cols-3 gap-2 mb-3">
        {summaryTiles.map(({ key, label, value, icon: Icon }) => (
          <div key={key} className="bg-buddy-surface-raised rounded-xl py-2.5 px-2 text-center" data-testid={`insights-${key}`}>
            <Icon size={13} className="mx-auto text-buddy-green mb-1" />
            <p className="font-mono font-bold text-base tabular-nums">{value}</p>
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
            <div className="grid grid-cols-8 gap-1 text-center">
              {[
                { label: 'Views', value: formatCount(num(it.views)) },
                { label: 'Likes', value: formatCount(num(it.likes)) },
                { label: 'Comments', value: formatCount(num(it.comments)) },
                { label: 'Reposts', value: formatCount(num(it.reposts)) },
                { label: 'Saves', value: formatCount(num(it.saves)) },
                { label: 'Shares', value: formatCount(num(it.shares)) },
                { label: 'Focus', value: formatDuration(num(it.avg_focus_ms)) },
                { label: 'Watch', value: formatDuration(num(it.watch_ms)) },
              ].map(({ label, value }) => (
                <div key={label}>
                  <p className="font-mono font-bold text-sm tabular-nums">{value}</p>
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
