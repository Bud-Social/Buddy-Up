import { useCallback, useMemo, useState } from 'react';
import { BarChart3 } from 'lucide-react';
import type { AnalyticsWindowParams } from '@/api/adminPortal';
import { AnalyticsDateRange, AnalyticsTabBar } from './analytics/shared';
import OverviewTab from './analytics/OverviewTab';
import TrendsTab from './analytics/TrendsTab';
import TrendingTab from './analytics/TrendingTab';
import AiQualityTab from './analytics/AiQualityTab';
import PredictiveTab from './analytics/PredictiveTab';
import ExportTab from './analytics/ExportTab';

/**
 * Platform analytics console — `/admin/analytics`.
 *
 * Six reports over one shared date range. The range is lifted to the page on
 * purpose: the API validates `from`/`to` identically on every endpoint *and* in
 * the export path, so a single control here is what guarantees an export can
 * never cover a different period from the report it was taken from.
 *
 * Empty inputs are sent as nothing rather than as a default the browser picked,
 * leaving the server's own 30-day default in charge.
 */

const TABS = [
  { id: 'overview', label: 'Overview', Component: OverviewTab },
  { id: 'trends', label: 'Trends', Component: TrendsTab },
  { id: 'trending', label: 'Trending', Component: TrendingTab },
  { id: 'ai-quality', label: 'AI quality', Component: AiQualityTab },
  { id: 'predictive', label: 'Predictive', Component: PredictiveTab },
  { id: 'export', label: 'Export', Component: ExportTab },
] as const;

type TabId = (typeof TABS)[number]['id'];

export default function AdminAnalytics() {
  const [tab, setTab] = useState<TabId>('overview');
  const [range, setRange] = useState({ from: '', to: '' });

  // A new object identity per change is what re-runs the tab's load effect, so
  // memoising keeps the dependency on the two strings rather than on identity.
  const windowParams = useMemo<AnalyticsWindowParams>(
    () => ({ from: range.from || undefined, to: range.to || undefined }),
    [range.from, range.to],
  );

  const onRangeChange = useCallback((next: { from: string; to: string }) => setRange(next), []);

  const Active = TABS.find((t) => t.id === tab)?.Component ?? OverviewTab;

  return (
    <div className="space-y-5 pb-8">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="flex items-start gap-2">
          <BarChart3 size={20} className="text-buddy-green mt-1 shrink-0" />
          <div>
            <h2 className="font-display text-xl sm:text-2xl font-extrabold">Platform analytics</h2>
            <p className="text-xs text-buddy-text-secondary mt-0.5">
              Every figure declares its own window and its own source. Nothing here is forecast.
            </p>
          </div>
        </div>
        <AnalyticsDateRange from={range.from} to={range.to} onChange={onRangeChange} />
      </div>

      <AnalyticsTabBar tabs={TABS.map(({ id, label }) => ({ id, label }))} value={tab} onChange={(id) => setTab(id as TabId)} />

      <Active window={windowParams} />
    </div>
  );
}