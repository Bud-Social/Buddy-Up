import { useEffect, useMemo, useState } from 'react';
import {
  Timer, Flame, RefreshCw, CheckCircle2, Clock, Zap, TrendingUp, History,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { StatCard } from '@/components/analytics/StatCard';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE, COLORS } from '@/components/analytics/chartConfig';
import { formatDuration, formatNumber } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsSummaryData } from '@/types/analytics';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, CartesianGrid,
} from 'recharts';

interface Props { period: AnalyticsPeriod; }

/**
 * Countdown analytics — the streaks, the cadence and the resets.
 *
 * The counters alone only tell you where you are now; the event stream
 * tells you how you got here, how regularly you show up, and how many
 * times you have started over.
 */
export function CountdownTab({ period }: Props) {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    setError(null);
    analyticsApi.getSummary(period)
      .then((res) => setSummary(res.data))
      .catch(() => setError('Failed to load countdown analytics.'))
      .finally(() => setLoading(false));
  }, [period]);

  const countdowns = summary?.countdowns;

  /** Each countdown's current streak against its longest — the shape of the work. */
  const streakData = useMemo(() => {
    if (!countdowns) return [];
    return countdowns.by_countdown.map((c) => ({
      name: c.reason.length > 14 ? `${c.reason.slice(0, 13)}…` : c.reason,
      current: c.elapsed_units,
      longest: c.longest_run_units,
      checkins: c.checkins,
    }));
  }, [countdowns]);

  /** The count through time — each event's counter value, oldest first. */
  const timelineData = useMemo(() => {
    if (!countdowns) return [];
    const events = [...countdowns.recent_events].reverse();
    return events.map((e, i) => ({
      i: i + 1,
      count: e.count_after,
      elapsed: Math.round(e.run_elapsed_seconds / 3600),
      type: e.event_type,
    }));
  }, [countdowns]);

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-24 bg-buddy-surface rounded-2xl" />)}
        </div>
        <div className="h-64 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  if (error) {
    return <div className="text-sm text-buddy-red">{error}</div>;
  }

  if (!countdowns || countdowns.count === 0) {
    return (
      <Card className="p-8 text-center">
        <Timer size={40} className="mx-auto text-buddy-text-secondary/40 mb-3" />
        <p className="text-buddy-text-secondary">
          No countdowns yet. Start one and its streaks, cadence and resets will show up here.
        </p>
      </Card>
    );
  }

  const { cadence } = countdowns;

  return (
    <div className="space-y-6">
      {/* Headline numbers */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard
          label="Active countdowns"
          value={countdowns.active_count}
          sub={`${countdowns.count} in total`}
          icon={<Timer size={20} />}
        />
        <StatCard
          label="Check-ins"
          value={formatNumber(countdowns.total_checkins)}
          sub="manual and automatic"
          icon={<CheckCircle2 size={20} />}
        />
        <StatCard
          label="Longest streak"
          value={`${countdowns.longest_streak_units}`}
          sub="units, any countdown"
          icon={<Flame size={20} />}
        />
        <StatCard
          label="Resets"
          value={countdowns.total_resets}
          sub="times you started over"
          icon={<RefreshCw size={20} />}
        />
      </div>

      {/* Cadence */}
      <Card className="p-4">
        <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
          <Clock size={16} className="text-buddy-green" /> Check-in cadence
        </h3>
        <p className="text-xs text-buddy-text-secondary mb-3">
          How regularly you show up. A check-in counts as on time when it lands within the
          countdown&apos;s own unit.
        </p>
        <div className="grid grid-cols-3 gap-3 text-center">
          <div className="rounded-xl bg-buddy-surface/50 p-3">
            <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Median gap</p>
            <p className="mt-1 text-lg font-bold text-buddy-text-primary">
              {cadence.median_gap_seconds ? formatDuration(cadence.median_gap_seconds) : '—'}
            </p>
          </div>
          <div className="rounded-xl bg-buddy-surface/50 p-3">
            <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">On time</p>
            <p className="mt-1 text-lg font-bold text-buddy-green">{cadence.on_time_checkins}</p>
          </div>
          <div className="rounded-xl bg-buddy-surface/50 p-3">
            <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Late</p>
            <p className="mt-1 text-lg font-bold text-buddy-orange">{cadence.late_checkins}</p>
          </div>
        </div>
      </Card>

      {/* Per-countdown streaks */}
      {streakData.length > 0 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
            <TrendingUp size={16} className="text-buddy-green" /> Streaks by countdown
          </h3>
          <p className="text-xs text-buddy-text-secondary mb-3">
            The current streak against the longest one you have run.
          </p>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={streakData} margin={{ top: 8, right: 8, bottom: 0, left: -18 }}>
                <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                <XAxis dataKey="name" tick={AXIS_TICK} stroke={GRID_STROKE} />
                <YAxis tick={AXIS_TICK} stroke={GRID_STROKE} allowDecimals={false} />
                <Tooltip {...CHART_TOOLTIP} />
                <Bar dataKey="longest" fill={COLORS[1]} radius={[4, 4, 0, 0]} name="Longest" />
                <Bar dataKey="current" fill={COLORS[0]} radius={[4, 4, 0, 0]} name="Current" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {/* The counter through time */}
      {timelineData.length > 1 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
            <Zap size={16} className="text-buddy-green" /> Counter over time
          </h3>
          <p className="text-xs text-buddy-text-secondary mb-3">
            The counter after each event, and how long the streak had run by then.
          </p>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={timelineData} margin={{ top: 8, right: 8, bottom: 0, left: -18 }}>
                <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                <XAxis dataKey="i" tick={AXIS_TICK} stroke={GRID_STROKE} />
                <YAxis tick={AXIS_TICK} stroke={GRID_STROKE} allowDecimals={false} />
                <Tooltip {...CHART_TOOLTIP} />
                <Line
                  type="monotone"
                  dataKey="count"
                  stroke={COLORS[0]}
                  strokeWidth={2}
                  dot={{ r: 3 }}
                  name="Counter"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {/* The resets */}
      <Card className="p-4">
        <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
          <RefreshCw size={16} className="text-buddy-red" /> Resets
        </h3>
        <p className="text-xs text-buddy-text-secondary mb-3">
          Every time a streak restarted, and how long the run it ended had lasted.
        </p>
        {countdowns.resets.length === 0 ? (
          <p className="text-sm text-buddy-text-secondary">No resets — every streak is still running.</p>
        ) : (
          <ul className="space-y-2">
            {countdowns.resets.map((r) => (
              <li
                key={r.id}
                className="flex items-center gap-3 rounded-lg border border-buddy-border bg-buddy-surface/40 px-3 py-2"
              >
                <RefreshCw size={14} className="text-buddy-red shrink-0" />
                <span className="text-sm text-buddy-text-primary">{r.reason || 'Countdown'}</span>
                <span className="text-xs text-buddy-text-secondary">
                  ran {r.run_elapsed_units} {r.count_after > 0 ? '' : ''}
                </span>
                <span className="ml-auto text-xs text-buddy-text-secondary/70 whitespace-nowrap">
                  {new Date(r.occurred_at).toLocaleString()}
                </span>
              </li>
            ))}
          </ul>
        )}
      </Card>

      {/* The stream */}
      <Card className="p-4">
        <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
          <History size={16} className="text-buddy-green" /> Event stream
        </h3>
        <p className="text-xs text-buddy-text-secondary mb-3">
          Every check-in, automatic advance and reset, newest first.
        </p>
        {countdowns.recent_events.length === 0 ? (
          <p className="text-sm text-buddy-text-secondary">Nothing recorded in this period.</p>
        ) : (
          <ul className="space-y-1.5 max-h-96 overflow-y-auto">
            {countdowns.recent_events.map((e) => {
              const owner = countdowns.by_countdown.find((c) => c.id === e.countdown_id);
              return (
                <li key={e.id} className="flex items-center gap-2 text-xs">
                  <span
                    className={`w-1.5 h-1.5 rounded-full shrink-0 ${
                      e.event_type === 'reset'
                        ? 'bg-buddy-red'
                        : e.event_type === 'auto_advance'
                          ? 'bg-buddy-electric'
                          : e.event_type === 'complete'
                            ? 'bg-buddy-gold'
                            : 'bg-buddy-green'
                    }`}
                  />
                  <span className="text-buddy-text-primary capitalize">
                    {e.event_type.replace('_', ' ')}
                  </span>
                  {owner && (
                    <span className="text-buddy-text-secondary truncate">{owner.reason}</span>
                  )}
                  <span className="text-buddy-text-secondary">→ {e.count_after} {e.unit}</span>
                  <span className="ml-auto text-buddy-text-secondary/60 whitespace-nowrap">
                    {new Date(e.occurred_at).toLocaleString()}
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </Card>
    </div>
  );
}
