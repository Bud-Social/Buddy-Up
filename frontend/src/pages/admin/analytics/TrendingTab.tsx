import { useCallback, useEffect, useState } from 'react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { Ban } from 'lucide-react';
import { AXIS_TICK, CHART_TOOLTIP, COLORS, GRID_STROKE } from '@/components/analytics/chartConfig';
import {
  adminPortalApi,
  type AnalyticsTrending,
  type AnalyticsTrendingItem,
  type AnalyticsTrendingKind,
  type AnalyticsWindowParams,
} from '@/api/adminPortal';
import { Card } from '@/components/ui/Card';
import {
  formatCount, formatDelta, formatPercent, text, TRENDING_KIND_LABELS, TRENDING_KINDS,
} from './format';
import { NothingToShow, ReportWindowLine } from './shared';

/**
 * Trending — top items for a kind.
 *
 * **Item fields differ per kind**, so the columns are declared per kind rather
 * than inferred. A hashtag row has no `title` and a post row has no `tag`;
 * rendering one union shape across all five kinds would produce five columns of
 * em dashes.
 *
 * `kind=pages` is the one kind the server cannot answer. It returns
 * `available: false` with a `reason` explaining that no client emits a
 * route-change or screen-view event. That is rendered as a panel carrying the
 * reason, not as an empty chart: "no data" and "this instrument does not exist
 * yet" are different findings and an empty chart conflates them.
 */

interface Column {
  key: string;
  label: string;
  render: (item: AnalyticsTrendingItem) => string;
  numeric?: boolean;
}

const COLUMNS: Record<string, Column[]> = {
  posts: [
    { key: 'rank', label: '#', render: (i) => text(i.rank), numeric: true },
    { key: 'author_username', label: 'Author', render: (i) => text(i.author_username) },
    { key: 'post_type', label: 'Type', render: (i) => text(i.post_type) },
    { key: 'body_excerpt', label: 'Post', render: (i) => text(i.body_excerpt, '') },
    { key: 'reactions', label: 'Reactions', render: (i) => formatCount(i.reactions), numeric: true },
    { key: 'comments', label: 'Comments', render: (i) => formatCount(i.comments), numeric: true },
    { key: 'engagement', label: 'Engagement', render: (i) => formatCount(i.engagement), numeric: true },
    { key: 'view_count', label: 'Views', render: (i) => formatCount(i.view_count), numeric: true },
    { key: 'share_count', label: 'Shares', render: (i) => formatCount(i.share_count), numeric: true },
  ],
  services: [
    { key: 'rank', label: '#', render: (i) => text(i.rank), numeric: true },
    { key: 'kind', label: 'Kind', render: (i) => text(i.kind).replace(/_/g, ' ') },
    { key: 'title', label: 'Title', render: (i) => text(i.title) },
    { key: 'creator', label: 'Creator', render: (i) => text(i.creator) },
    { key: 'purchases_in_window', label: 'Purchases in window', render: (i) => formatCount(i.purchases_in_window), numeric: true },
    { key: 'purchase_count_total', label: 'Purchases ever', render: (i) => formatCount(i.purchase_count_total), numeric: true },
    { key: 'average_rating', label: 'Rating', render: (i) => (i.average_rating == null ? '—' : i.average_rating.toFixed(2)), numeric: true },
    { key: 'review_count', label: 'Reviews', render: (i) => formatCount(i.review_count), numeric: true },
    { key: 'is_published', label: 'Published', render: (i) => (i.is_published ? 'Yes' : 'No') },
  ],
  events: [
    { key: 'rank', label: '#', render: (i) => text(i.rank), numeric: true },
    { key: 'title', label: 'Event', render: (i) => text(i.title) },
    { key: 'category', label: 'Category', render: (i) => text(i.category) },
    { key: 'event_type', label: 'Type', render: (i) => text(i.event_type) },
    { key: 'shop', label: 'Shop', render: (i) => text(i.shop) },
    { key: 'gym', label: 'Gym', render: (i) => text(i.gym) },
    { key: 'tickets_in_window', label: 'Tickets in window', render: (i) => formatCount(i.tickets_in_window), numeric: true },
    { key: 'sold_tickets_in_window', label: 'Sold', render: (i) => formatCount(i.sold_tickets_in_window), numeric: true },
    { key: 'attendee_count', label: 'Attendees', render: (i) => formatCount(i.attendee_count), numeric: true },
    { key: 'starts_at', label: 'Starts', render: (i) => (i.starts_at ? new Date(i.starts_at).toLocaleString() : '—') },
  ],
  hashtags: [
    { key: 'rank', label: '#', render: (i) => text(i.rank), numeric: true },
    { key: 'tag', label: 'Tag', render: (i) => text(i.tag) },
    { key: 'posts_in_window', label: 'Posts in window', render: (i) => formatCount(i.posts_in_window), numeric: true },
    { key: 'posts_in_previous_window', label: 'Previous window', render: (i) => formatCount(i.posts_in_previous_window), numeric: true },
    { key: 'delta', label: 'Change', render: (i) => formatDelta(i.delta), numeric: true },
    { key: 'pct_change', label: '% change', render: (i) => formatPercent(i.pct_change), numeric: true },
    { key: 'total_posts_ever', label: 'Posts ever', render: (i) => formatCount(i.total_posts_ever), numeric: true },
  ],
};

function NotAvailablePanel({ reason }: { reason?: string }) {
  return (
    <Card className="p-6" data-testid="trending-unavailable">
      <div className="flex items-start gap-3">
        <Ban size={20} className="text-buddy-orange mt-0.5 shrink-0" />
        <div className="min-w-0">
          <p className="text-sm font-semibold">Not available yet</p>
          <p className="text-xs text-buddy-text-secondary mt-1 break-words">
            {reason || 'This report has no data source yet. The platform does not collect the events it would need.'}
          </p>
          <p className="text-[11px] text-buddy-text-secondary/80 mt-2">
            This is not an empty result and not a failed query — nothing is charted here on purpose.
          </p>
        </div>
      </div>
    </Card>
  );
}

export default function TrendingTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [kind, setKind] = useState<AnalyticsTrendingKind>('posts');
  const [limit, setLimit] = useState(10);
  const [data, setData] = useState<AnalyticsTrending | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getAnalyticsTrending({ from, to, kind, limit })
      .then((res) => setData(res.data || null))
      .catch((err: unknown) => {
        const payload = (err as { response?: { data?: { message?: string } } })?.response?.data;
        setError(payload?.message || 'Could not load trending items.');
      })
      .finally(() => setLoading(false));
  }, [from, to, kind, limit]);

  useEffect(() => { load(); }, [load]);

  const items = data?.items || [];
  const columns = COLUMNS[kind] || COLUMNS.posts;
  const chartItems = items
    .map((item, index) => ({
      name: kind === 'hashtags' ? text(item.tag) : text(item.title ?? item.tag ?? item.post_id, `#${index + 1}`),
      value: kind === 'hashtags' ? Number(item.posts_in_window ?? 0) : Number(item.engagement ?? item.purchases_in_window ?? item.tickets_in_window ?? 0),
    }))
    .filter((row) => row.name);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-2">
        {TRENDING_KINDS.map((k) => (
          <button
            key={k}
            type="button"
            aria-pressed={kind === k}
            onClick={() => setKind(k)}
            className={`text-xs px-2.5 py-1 rounded-lg transition-colors ${
              kind === k
                ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
            }`}
          >
            {TRENDING_KIND_LABELS[k]}
          </button>
        ))}
        <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary ml-auto">
          Top
          <input
            type="number"
            min={1}
            max={100}
            value={limit}
            aria-label="Number of items"
            onChange={(e) => setLimit(Math.min(100, Math.max(1, Number(e.target.value) || 1)))}
            className="w-16 bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
          />
        </label>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">
          {error}
        </div>
      )}

      {data && <ReportWindowLine window={data.window} />}

      {data?.rank_basis && (
        <p className="text-[11px] text-buddy-text-secondary">Ranked by: {data.rank_basis}</p>
      )}

      {loading && !data && <Card className="h-40 animate-pulse bg-buddy-surface-raised" />}

      {data?.available === false ? (
        <NotAvailablePanel reason={data.reason} />
      ) : items.length === 0 && data ? (
        <NothingToShow
          title="Nothing matched in this window."
          hint="The query ran and returned no rows — widen the date range or raise the limit."
        />
      ) : (
        <>
          {chartItems.length > 0 && (
            <Card className="p-4">
              <div className="h-56">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartItems} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                    <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                    <XAxis dataKey="name" tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} interval={0} angle={-15} textAnchor="end" height={56} />
                    <YAxis tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} width={44} />
                    <Tooltip {...CHART_TOOLTIP} />
                    <Bar dataKey="value" fill={COLORS[0]} isAnimationActive={false} radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </Card>
          )}

          <Card className="p-4 overflow-x-auto">
            <table className="w-full text-xs">
              <thead>
                <tr className="text-left text-buddy-text-secondary">
                  {columns.map((column) => (
                    <th key={column.key} className="font-medium py-1 pr-3 whitespace-nowrap">
                      {column.label}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {items.map((item, index) => (
                  <tr key={text(item.tag_id) || text(item.post_id) || text(item.id) || index} className="border-t border-buddy-surface">
                    {columns.map((column) => (
                      <td key={column.key} className={`py-1.5 pr-3 ${column.numeric ? 'text-right' : ''}`}>
                        {column.render(item)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </Card>
        </>
      )}
    </div>
  );
}