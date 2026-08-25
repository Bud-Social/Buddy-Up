import { useState, useEffect } from 'react';
import { Loader, Lock, Trophy } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { achievementsApi, achievementTierStyle } from '@/api/achievements';
import type { AchievementItem } from '@/api/achievements';

function AchievementCard({ item }: { item: AchievementItem }) {
  const tier = achievementTierStyle(item.tier);
  return (
    <Card className={`p-4 flex flex-col items-center text-center gap-2 border ${item.earned ? `${tier.ring} ${tier.bg}` : 'border-buddy-surface-raised opacity-70'}`}>
      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl ${item.earned ? tier.bg : 'bg-buddy-surface-raised grayscale'}`}>
        {item.earned ? <span aria-hidden>{item.icon}</span> : <Lock size={18} className="text-buddy-text-secondary" />}
      </div>
      <p className="font-heading font-semibold text-sm leading-tight">{item.title}</p>
      <p className="text-xs text-buddy-text-secondary leading-snug">{item.description}</p>
      {item.earned ? (
        <span className={`text-xs font-medium ${tier.text}`}>{tier.label} · Earned</span>
      ) : (
        <div className="w-full mt-1">
          <div className="h-1.5 rounded-full bg-buddy-surface-raised overflow-hidden">
            <div
              className={`h-full rounded-full ${tier.text.replace('text-', 'bg-')}`}
              style={{ width: `${Math.min(100, item.progress_pct)}%` }}
            />
          </div>
          <p className="text-[11px] text-buddy-text-secondary mt-1">
            {item.progress_pct >= 100 ? 'Ready to claim' : `${Math.floor(item.progress_pct)}%`}
            {' · '}{Math.min(item.progress, item.threshold)} / {item.threshold} {item.metric_label}
          </p>
        </div>
      )}
    </Card>
  );
}

const PERIODS = [
  { key: 'daily', label: 'Daily' },
  { key: 'weekly', label: 'Weekly' },
  { key: 'monthly', label: 'Monthly' },
  { key: 'quarterly', label: 'Quarterly' },
  { key: 'yearly', label: 'Yearly' },
] as const;

export function AchievementsTab() {
  const [items, setItems] = useState<AchievementItem[]>([]);
  const [summary, setSummary] = useState<{ total: number; earned: number } | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [period, setPeriod] = useState<string>('weekly');

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    achievementsApi.list(period)
      .then((res) => {
        if (cancelled) return;
        setItems(res.data?.items || []);
        setSummary(res.data?.summary || null);
      })
      .catch(() => !cancelled && setError(true))
      .finally(() => !cancelled && setLoading(false));
    return () => { cancelled = true; };
  }, [period]);

  if (loading) {
    return (
      <div className="col-span-3 flex items-center justify-center py-20">
        <Loader size={24} className="animate-spin text-buddy-text-secondary" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="col-span-3 text-center py-20">
        <Trophy size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
        <p className="text-buddy-text-secondary">Could not load achievements</p>
      </div>
    );
  }

  const earned = items.filter((i) => i.earned);
  const locked = items.filter((i) => !i.earned);

  return (
    <div className="col-span-3 space-y-6">
      <div className="flex flex-wrap justify-center gap-1 bg-buddy-surface rounded-xl p-1">
        {PERIODS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setPeriod(key)}
            className={`flex-1 min-w-[72px] px-3 py-2 text-xs sm:text-sm font-medium rounded-lg transition-colors ${
              period === key ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            {label}
          </button>
        ))}
      </div>
      {summary && (
        <Card className="p-4 flex items-center gap-3">
          <Trophy size={20} className="text-buddy-gold" />
          <div>
            <p className="font-semibold text-sm">{summary.earned} of {summary.total} unlocked</p>
            <div className="h-1.5 w-44 rounded-full bg-buddy-surface-raised overflow-hidden mt-1.5">
              <div className="h-full bg-buddy-gold rounded-full" style={{ width: `${summary.total ? (100 * summary.earned) / summary.total : 0}%` }} />
            </div>
          </div>
        </Card>
      )}

      {items.length === 0 ? (
        <Card className="p-8 text-center text-buddy-text-secondary text-sm">No achievements available yet.</Card>
      ) : (
        <>
          {earned.length > 0 && (
            <>
              <h3 className="font-heading font-semibold text-sm text-buddy-text-secondary">Earned</h3>
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
                {earned.map((item) => <AchievementCard key={item.id} item={item} />)}
              </div>
            </>
          )}
          {locked.length > 0 && (
            <>
              <h3 className="font-heading font-semibold text-sm text-buddy-text-secondary">Locked</h3>
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
                {locked.map((item) => <AchievementCard key={item.id} item={item} />)}
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
}
