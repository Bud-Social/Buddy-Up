import { useState } from 'react';
import { Activity as ActivityIcon, Dumbbell, Utensils, Scale, FileBarChart2, LayoutDashboard } from 'lucide-react';
import type { AnalyticsPeriod } from '@/types/analytics';
import { OverviewTab } from '@/components/analytics/OverviewTab';
import { ActivityTab } from '@/components/analytics/ActivityTab';
import { WorkoutsTab } from '@/components/analytics/WorkoutsTab';
import { MealsTab } from '@/components/analytics/MealsTab';
import { BodyTab } from '@/components/analytics/BodyTab';
import { ReportTab } from '@/components/analytics/ReportTab';

const PERIODS: { key: AnalyticsPeriod; label: string }[] = [
  { key: 'week', label: 'Week' },
  { key: 'month', label: 'Month' },
  { key: 'quarter', label: 'Quarter' },
  { key: 'year', label: 'Year' },
  { key: 'all', label: 'All Time' },
];

const TABS = [
  { key: 'overview', label: 'Overview', icon: LayoutDashboard },
  { key: 'activity', label: 'Activity', icon: ActivityIcon },
  { key: 'workouts', label: 'Workouts', icon: Dumbbell },
  { key: 'meals', label: 'Nutrition', icon: Utensils },
  { key: 'body', label: 'Body', icon: Scale },
  { key: 'report', label: 'Report', icon: FileBarChart2 },
] as const;

type TabKey = (typeof TABS)[number]['key'];

export default function AnalyticsPage() {
  const [period, setPeriod] = useState<AnalyticsPeriod>('month');
  const [tab, setTab] = useState<TabKey>('overview');

  return (
    <div className="p-4 max-w-6xl mx-auto space-y-4">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Analytics</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Your activity, nutrition, body and spending — in one report.
          </p>
        </div>
        <div className="flex gap-1 bg-buddy-surface rounded-xl p-1 flex-wrap">
          {PERIODS.map((p) => (
            <button
              key={p.key}
              onClick={() => setPeriod(p.key)}
              className={`px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                period === p.key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tabs — wrap to two centred rows on narrow screens */}
      <div className="flex flex-wrap justify-center gap-1 bg-buddy-surface rounded-xl p-1">
        {TABS.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex items-center justify-center gap-1.5 px-3 py-2 text-xs sm:text-sm sm:px-4 font-medium rounded-lg whitespace-nowrap transition-colors ${
              tab === key ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            <Icon size={15} />
            {label}
          </button>
        ))}
      </div>

      {/* Tab content */}
      <div className="pb-8">
        {tab === 'overview' && <OverviewTab period={period} />}
        {tab === 'activity' && <ActivityTab />}
        {tab === 'workouts' && <WorkoutsTab period={period} />}
        {tab === 'meals' && <MealsTab period={period} />}
        {tab === 'body' && <BodyTab />}
        {tab === 'report' && <ReportTab period={period} />}
      </div>
    </div>
  );
}
