import { useEffect, useMemo, useState } from 'react';
import {
  Activity as ActivityIcon, Trophy, Route, CalendarDays, Target, TrendingUp, Mountain,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { StatCard } from '@/components/analytics/StatCard';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE, COLORS } from '@/components/analytics/chartConfig';
import { formatDuration, formatPace, titleCase } from '@/components/analytics/format';
import { RouteMap } from '@/components/analytics/RouteMap';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsSummaryData } from '@/types/analytics';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line,
  CartesianGrid,
} from 'recharts';

interface Props { period: AnalyticsPeriod; }

/**
 * What the activity numbers actually say.
 *
 * The totals are the easy part; the records, the trend and the shape of
 * the sessions are what tell you whether you are getting better.
 */
export function ActivityInsights({ period }: Props) {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    analyticsApi.getSummary(period)
      .then((res) => setSummary(res.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [period]);

  const activity = summary?.activity;

  const weeklyData = useMemo(
    () => (activity?.weekly ?? []).map((w) => ({
      name: w.week.replace(/^\d{4}-/, ''),
      distance: w.distance_km,
      minutes: w.duration_minutes,
      pace: w.avg_pace,
      count: w.count,
    })),
    [activity?.weekly],
  );

  const typeData = useMemo(
    () => (activity?.by_type ?? []).map((t) => ({
      name: t.label,
      km: t.distance_km ?? 0,
      count: t.count,
    })),
    [activity?.by_type],
  );

  // The last 12 weeks of activity, as a heat strip.
  const calendar = activity?.calendar ?? [];

  if (loading) {
    return <div className="h-64 bg-buddy-surface rounded-2xl animate-pulse" />;
  }

  if (!activity || activity.count === 0) {
    return (
      <Card className="p-8 text-center">
        <ActivityIcon size={40} className="mx-auto text-buddy-text-secondary/40 mb-3" />
        <p className="text-buddy-text-secondary">
          No tracked activity yet. Record a walk, run, hike or ride and the trends show up here.
        </p>
      </Card>
    );
  }

  const records = activity.records;
  const goals = activity.goals ?? [];
  const gallery = activity.gallery ?? [];

  return (
    <div className="space-y-5">
      {/* Totals */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard
          label="Distance"
          value={`${activity.total_distance_km} km`}
          sub={`${activity.count} session${activity.count !== 1 ? 's' : ''}`}
          icon={<Route size={20} />}
        />
        <StatCard
          label="Time moving"
          value={formatDuration(activity.total_duration_seconds)}
          sub={`${activity.days_active ?? 0} day${(activity.days_active ?? 0) !== 1 ? 's' : ''} active`}
          icon={<CalendarDays size={20} />}
        />
        <StatCard
          label="Calories"
          value={Math.round(activity.total_calories_burned)}
          sub="burnt"
          icon={<ActivityIcon size={20} />}
        />
        <StatCard
          label="Steps"
          value={activity.total_steps.toLocaleString()}
          sub={activity.total_climb_m ? `${activity.total_climb_m} m climbed` : 'counted'}
          icon={<TrendingUp size={20} />}
        />
      </div>

      {/* Records */}
      {records && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-3 flex items-center gap-2">
            <Trophy size={16} className="text-buddy-gold" /> Personal records
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="bg-buddy-surface-raised rounded-xl p-3">
              <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Longest</p>
              <p className="text-lg font-bold font-mono mt-0.5">{records.longest_distance_km} km</p>
            </div>
            <div className="bg-buddy-surface-raised rounded-xl p-3">
              <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Longest time</p>
              <p className="text-lg font-bold font-mono mt-0.5">{formatDuration(records.longest_duration_seconds)}</p>
            </div>
            <div className="bg-buddy-surface-raised rounded-xl p-3">
              <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Fastest pace</p>
              <p className="text-lg font-bold font-mono mt-0.5">
                {records.fastest_pace ? formatPace(records.fastest_pace) : '—'}
              </p>
            </div>
            <div className="bg-buddy-surface-raised rounded-xl p-3">
              <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Biggest climb</p>
              <p className="text-lg font-bold font-mono mt-0.5">{records.biggest_climb_m} m</p>
            </div>
          </div>
        </Card>
      )}

      {/* Weekly trend */}
      {weeklyData.length > 1 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-1 flex items-center gap-2">
            <TrendingUp size={16} className="text-buddy-green" /> Week by week
          </h3>
          <p className="text-xs text-buddy-text-secondary mb-3">
            Distance and time per week. The pace line is weighted by distance, so a
            short fast run does not outvote a long slow one.
          </p>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={weeklyData} margin={{ top: 8, right: 8, bottom: 0, left: -18 }}>
                <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                <XAxis dataKey="name" tick={AXIS_TICK} stroke={GRID_STROKE} />
                {/* Distance and time are different things, so they get their
                    own scales — otherwise the minutes dwarf the kilometres. */}
                <YAxis yAxisId="km" tick={AXIS_TICK} stroke={GRID_STROKE} />
                <YAxis yAxisId="min" orientation="right" tick={AXIS_TICK} stroke={GRID_STROKE} />
                <Tooltip {...CHART_TOOLTIP} />
                <Bar yAxisId="km" dataKey="distance" fill={COLORS[0]} radius={[4, 4, 0, 0]} name="Distance (km)" />
                <Bar yAxisId="min" dataKey="minutes" fill={COLORS[1]} radius={[4, 4, 0, 0]} name="Minutes" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {/* Pace trend */}
      {weeklyData.some((w) => w.pace) && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-1">Pace trend</h3>
          <p className="text-xs text-buddy-text-secondary mb-3">
            Lower is faster. Weeks without a recorded pace are left out.
          </p>
          <div className="h-52">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart
                data={weeklyData.filter((w) => w.pace)}
                margin={{ top: 8, right: 8, bottom: 0, left: -18 }}
              >
                <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                <XAxis dataKey="name" tick={AXIS_TICK} stroke={GRID_STROKE} />
                <YAxis tick={AXIS_TICK} stroke={GRID_STROKE} />
                <Tooltip {...CHART_TOOLTIP} />
                <Line
                  type="monotone"
                  dataKey="pace"
                  stroke={COLORS[2]}
                  strokeWidth={2}
                  dot={{ r: 3 }}
                  name="Pace (s/km)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {/* By kind, and the shape of the sessions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {typeData.length > 0 && (
          <Card className="p-4">
            <h3 className="font-semibold text-buddy-text-primary mb-3">By activity</h3>
            <div className="h-56">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={typeData} margin={{ top: 8, right: 8, bottom: 0, left: -18 }}>
                  <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                  <XAxis dataKey="name" tick={AXIS_TICK} stroke={GRID_STROKE} />
                  <YAxis tick={AXIS_TICK} stroke={GRID_STROKE} />
                  <Tooltip {...CHART_TOOLTIP} />
                  <Bar dataKey="km" fill={COLORS[0]} radius={[4, 4, 0, 0]} name="Distance (km)" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </Card>
        )}

        {(activity.distribution ?? []).some((d) => d.count > 0) && (
          <Card className="p-4">
            <h3 className="font-semibold text-buddy-text-primary mb-3">Session lengths</h3>
            <div className="h-56">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={(activity.distribution ?? []).filter((d) => d.count > 0)}
                  margin={{ top: 8, right: 8, bottom: 0, left: -18 }}
                >
                  <CartesianGrid stroke={GRID_STROKE} vertical={false} />
                  <XAxis dataKey="band" tick={AXIS_TICK} stroke={GRID_STROKE} />
                  <YAxis tick={AXIS_TICK} stroke={GRID_STROKE} allowDecimals={false} />
                  <Tooltip {...CHART_TOOLTIP} />
                  <Bar dataKey="count" fill={COLORS[3]} radius={[4, 4, 0, 0]} name="Sessions" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </Card>
        )}
      </div>

      {/* Goals */}
      {goals.length > 0 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-3 flex items-center gap-2">
            <Target size={16} className="text-buddy-green" /> Against the daily goals
          </h3>
          <div className="space-y-3">
            {goals.map((g) => (
              <div key={g.activity_type}>
                <div className="flex items-center justify-between mb-1 text-xs">
                  <span className="text-buddy-text-secondary">
                    {g.label} · {g.sessions} session{g.sessions !== 1 ? 's' : ''}
                  </span>
                  <span className={g.pct >= 100 ? 'text-buddy-gold font-medium' : 'text-buddy-text-secondary'}>
                    {g.reached} / {g.target} {g.unit}
                  </span>
                </div>
                <div className="w-full bg-buddy-surface/50 rounded-full h-2 overflow-hidden">
                  <div
                    className={`h-full transition-all duration-500 ${g.pct >= 100 ? 'bg-buddy-gold' : 'bg-buddy-green'}`}
                    style={{ width: `${g.pct}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>
      )}

      {/* The days you were out */}
      {calendar.length > 0 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-3 flex items-center gap-2">
            <CalendarDays size={16} className="text-buddy-green" /> Days active
          </h3>
          <div className="flex flex-wrap gap-1.5">
            {calendar.map((d) => (
              <div
                key={d.date}
                title={`${d.date}: ${d.count} session${d.count !== 1 ? 's' : ''}`}
                className="w-9 h-9 rounded-lg bg-buddy-green/25 flex flex-col items-center justify-center text-[10px]"
              >
                <span className="text-buddy-text-primary font-semibold leading-none">{d.count}</span>
                <span className="text-buddy-text-secondary/70">{d.date.slice(8)}</span>
              </div>
            ))}
          </div>
        </Card>
      )}

      {/* The routes */}
      {gallery.length > 0 && (
        <Card className="p-4">
          <h3 className="font-semibold text-buddy-text-primary mb-3 flex items-center gap-2">
            <Mountain size={16} className="text-buddy-green" /> Your routes
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {gallery.map((g) => (
              <div key={g.id} className="space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-buddy-text-primary font-medium">
                    {titleCase(g.activity_type)}
                  </span>
                  <span className="text-buddy-text-secondary">
                    {g.distance_km} km · {g.duration_minutes} min
                  </span>
                </div>
                <RouteMap route={g.route} height={150} />
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}
