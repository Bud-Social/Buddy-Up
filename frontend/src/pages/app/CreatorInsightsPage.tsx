import { useEffect, useMemo, useState } from 'react';
import {
  ArrowDownAZ, ArrowUpAZ, BarChart3, Eye, Heart, MessageCircle, Repeat2,
  Bookmark, Share2, Loader2, Zap, Clock3, Timer, TrendingUp, Image as ImageIcon,
  Video, Type, ChevronRight,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { feedApi } from '@/api/feed';
import { formatCount } from '@/components/features/feed/RailAction';
import { formatDuration } from '@/components/features/feed/CreatorInsights';
import type { CreatorInsightItem, CreatorInsightSummary } from '@/types';

function num(value: number | undefined): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
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

const POST_TYPE_META: Record<string, { label: string; icon: typeof ImageIcon }> = {
  photo: { label: 'Photo', icon: ImageIcon },
  short_video: { label: 'Video', icon: Video },
  long_video: { label: 'Video', icon: Video },
  text: { label: 'Text', icon: Type },
  workout_log: { label: 'Workout', icon: Zap },
  moment: { label: 'Story', icon: ImageIcon },
  countdown: { label: 'Countdown', icon: Timer },
  poll: { label: 'Poll', icon: TrendingUp },
};

function postTypeMeta(postType?: string) {
  return (postType && POST_TYPE_META[postType]) || { label: postType || 'Post', icon: Type };
}

type SortKey = 'views' | 'interactions' | 'engagement' | 'recent';
const SORT_OPTIONS: { key: SortKey; label: string }[] = [
  { key: 'views', label: 'Views' },
  { key: 'interactions', label: 'Interactions' },
  { key: 'recent', label: 'Most recent' },
];

export default function CreatorInsightsPage() {
  const [items, setItems] = useState<CreatorInsightItem[] | null>(null);
  const [summary, setSummary] = useState<CreatorInsightSummary | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [sort, setSort] = useState<SortKey>('views');
  const [ascending, setAscending] = useState(false);

  useEffect(() => {
    let cancelled = false;
    feedApi.getCreatorInsights()
      .then((res) => {
        if (cancelled) return;
        if (Array.isArray(res.data)) {
          setItems(res.data as unknown as CreatorInsightItem[]);
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

  const allItems = items ?? [];

  const sortedItems = useMemo(() => {
    const rows = [...allItems];
    const score = (it: CreatorInsightItem) => {
      if (sort === 'views') return num(it.views);
      if (sort === 'interactions') return num(it.interactions);
      return new Date(it.created_at || 0).getTime();
    };
    rows.sort((a, b) => score(b) - score(a));
    return ascending ? rows.reverse() : rows;
  }, [allItems, sort, ascending]);

  const topPosts = useMemo(
    () => [...allItems]
      .filter((it) => num(it.views) > 0)
      .sort((a, b) => num(b.views) - num(a.views))
      .slice(0, 3),
    [allItems],
  );

  if (items === null && !error) {
    return (
      <div className="p-8 flex items-center justify-center gap-2 text-buddy-text-secondary">
        <Loader2 size={20} className="animate-spin" />
        <span className="text-sm">Loading insights…</span>
      </div>
    );
  }

  if (error || items?.length === 0) {
    return (
      <div className="p-8 max-w-lg mx-auto text-center">
        <BarChart3 size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
        <h1 className="font-display text-xl font-bold">Creator Insights</h1>
        <p className="text-buddy-text-secondary text-sm mt-2">
          {error ?? 'Post something and check back — views, likes and watch time will show up here.'}
        </p>
      </div>
    );
  }

  const totalViews = allItems.reduce((sum, it) => sum + num(it.views), 0);
  const totalInteractions = allItems.reduce((sum, it) => sum + num(it.interactions), 0);
  const totalWatchMs = allItems.reduce((sum, it) => sum + num(it.watch_ms), 0);
  const totalFocusSessions = allItems.reduce((sum, it) => sum + num(it.focus_sessions), 0);
  const avgFocusMs = totalFocusSessions > 0
    ? Math.round(allItems.reduce((sum, it) => sum + num(it.total_focus_ms), 0) / totalFocusSessions)
    : 0;

  const rollup = (key: keyof CreatorInsightSummary, fallback: number): number =>
    num(summary?.[key] as number | undefined) || fallback;

  const tiles = [
    { key: 'views', label: 'Views', value: formatCount(rollup('views', totalViews)), icon: Eye },
    { key: 'engagement', label: 'Engagement', value: `${rollup('engagement_rate_pct', 0).toFixed(1)}%`, icon: TrendingUp },
    { key: 'interactions', label: 'Interactions', value: formatCount(rollup('interactions', totalInteractions)), icon: Zap },
    { key: 'watch', label: 'Watch time', value: formatDuration(rollup('watch_ms', totalWatchMs)), icon: Clock3 },
    { key: 'avg_focus', label: 'Avg focus', value: formatDuration(num(summary?.avg_focus_ms) || avgFocusMs), icon: Timer },
    { key: 'posts', label: 'Posts analyzed', value: formatCount(num(summary?.posts) || allItems.length), icon: BarChart3 },
  ];

  return (
    <div className="p-4 max-w-6xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <h1 className="font-display text-2xl font-bold">Creator Insights</h1>
        <p className="text-sm text-buddy-text-secondary mt-0.5">
          How your posts are performing — reach, engagement and attention, per post.
        </p>
      </div>

      {/* Account rollup */}
      <div className="grid grid-cols-2 md:grid-cols-6 gap-3">
        {tiles.map(({ key, label, value, icon: Icon }) => (
          <Card key={key} className="p-3 text-center">
            <Icon size={16} className="mx-auto text-buddy-green mb-1" />
            <p className="font-mono font-bold text-lg tabular-nums leading-tight">{value}</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">{label}</p>
          </Card>
        ))}
      </div>

      {/* Top posts */}
      {topPosts.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-2">
            <h2 className="font-heading font-semibold">Top posts</h2>
            <span className="text-xs text-buddy-text-secondary">Ranked by views</span>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {topPosts.map((post, index) => {
              const meta = postTypeMeta(post.post_type);
              const Icon = meta.icon;
              return (
                <Card key={post.post_id} className="overflow-hidden">
                  <div className="relative aspect-video bg-buddy-surface-raised">
                    {post.media_url ? (
                      post.post_type?.includes('video') ? (
                        <video
                          src={post.media_url}
                          poster={post.poster_url || undefined}
                          className="w-full h-full object-cover"
                          muted
                          playsInline
                        />
                      ) : (
                        <img src={post.media_url} alt="" className="w-full h-full object-cover" loading="lazy" />
                      )
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Icon size={36} className="text-buddy-green/60" />
                      </div>
                    )}
                    <span className="absolute top-2 left-2 inline-flex items-center gap-1 text-[10px] font-semibold bg-black/70 text-white px-2 py-0.5 rounded-full">
                      <ChevronRight size={10} className="rotate-45" /> #{index + 1} · {meta.label}
                    </span>
                  </div>
                  <div className="p-3 space-y-2">
                    <p className="text-xs text-buddy-text-secondary line-clamp-2 min-h-[2rem]">
                      {post.body || '(no caption)'}
                    </p>
                    <div className="flex items-center gap-3 text-xs text-buddy-text-secondary">
                      <span className="flex items-center gap-1"><Eye size={12} /> {formatCount(num(post.views))}</span>
                      <span className="flex items-center gap-1"><Heart size={12} /> {formatCount(num(post.likes))}</span>
                      <span className="flex items-center gap-1"><MessageCircle size={12} /> {formatCount(num(post.comments))}</span>
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </section>
      )}

      {/* All posts */}
      <section>
        <div className="flex items-center justify-between gap-2 mb-2">
          <h2 className="font-heading font-semibold">Per-post performance ({allItems.length})</h2>
          <div className="flex items-center gap-2">
            {SORT_OPTIONS.map(({ key, label }) => (
              <button
                key={key}
                type="button"
                onClick={() => setSort(key)}
                className={`px-2.5 py-1.5 rounded-full text-xs transition-colors ${
                  sort === key ? 'bg-buddy-green text-buddy-black font-semibold' : 'bg-buddy-surface text-buddy-text-secondary'
                }`}
              >
                {label}
              </button>
            ))}
            <button
              type="button"
              aria-label={ascending ? 'Sort descending' : 'Sort ascending'}
              onClick={() => setAscending((value) => !value)}
              className="p-1.5 rounded-lg bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary"
            >
              {ascending ? <ArrowUpAZ size={14} /> : <ArrowDownAZ size={14} />}
            </button>
          </div>
        </div>

        <div className="space-y-2">
          {sortedItems.map((post, index) => {
            const meta = postTypeMeta(post.post_type);
            const Icon = meta.icon;
            const views = num(post.views);
            const interactions = num(post.interactions);
            const engagement = views > 0 ? (100 * interactions) / views : 0;
            return (
              <Card key={post.post_id} className="p-3 flex items-start gap-3">
                <div className="w-20 h-20 rounded-xl overflow-hidden bg-buddy-surface-raised shrink-0 flex items-center justify-center">
                  {post.media_url ? (
                    post.post_type?.includes('video') ? (
                      <video src={post.media_url} poster={post.poster_url || undefined} className="w-full h-full object-cover" muted playsInline />
                    ) : (
                      <img src={post.media_url} alt="" className="w-full h-full object-cover" loading="lazy" />
                    )
                  ) : (
                    <Icon size={26} className="text-buddy-green/60" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <Badge variant="silver" label={meta.label} />
                    {post.visibility && (
                      <Badge variant="blue" label={post.visibility.replace('_', ' ')} />
                    )}
                    <span className="text-[10px] text-buddy-text-secondary/70">{timeAgo(post.created_at)}</span>
                    {index === 0 && <span className="text-[10px] text-buddy-gold font-semibold">Best performer</span>}
                  </div>
                  <p className="text-sm text-buddy-text-primary line-clamp-1 mt-1">
                    {post.body || '(no caption)'}
                  </p>
                  <div className="flex items-center gap-3 mt-1.5 text-xs text-buddy-text-secondary flex-wrap">
                    <span className="flex items-center gap-1" title="Views"><Eye size={12} /> {formatCount(views)}</span>
                    <span className="flex items-center gap-1" title="Likes"><Heart size={12} /> {formatCount(num(post.likes))}</span>
                    <span className="flex items-center gap-1" title="Comments"><MessageCircle size={12} /> {formatCount(num(post.comments))}</span>
                    <span className="flex items-center gap-1" title="Reposts"><Repeat2 size={12} /> {formatCount(num(post.reposts))}</span>
                    <span className="flex items-center gap-1" title="Saves"><Bookmark size={12} /> {formatCount(num(post.saves))}</span>
                    <span className="flex items-center gap-1" title="Shares"><Share2 size={12} /> {formatCount(num(post.shares))}</span>
                    <span className="flex items-center gap-1" title="Watch time"><Clock3 size={12} /> {formatDuration(num(post.watch_ms))}</span>
                    <span className="flex items-center gap-1 text-buddy-green" title="Engagement rate">
                      <TrendingUp size={12} /> {engagement.toFixed(1)}%
                    </span>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      </section>
    </div>
  );
}
