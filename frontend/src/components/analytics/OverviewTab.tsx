import { useEffect, useMemo, useState } from 'react';
import {
  Activity as ActivityIcon, Dumbbell, Utensils, Scale, Flame, Wallet, Radio, Clock,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { StatCard } from '@/components/analytics/StatCard';
import { CHART_TOOLTIP, AXIS_TICK, GRID_STROKE, COLORS } from '@/components/analytics/chartConfig';
import { formatDuration, formatKm, formatNumber, titleCase } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsSummaryData } from '@/types/analytics';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line, CartesianGrid, PieChart, Pie, Cell, Legend } from 'recharts';

interface Props { period: AnalyticsPeriod; }

export function OverviewTab({ period }: Props) {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setLoading(true);
    setError(null);
    analyticsApi.getSummary(period)
      .then((res) => setSummary(res.data))
      .catch(() => setError('Failed to load analytics summary.'))
      .finally(() => setLoading(false));
  }, [period]);

  const chartData = useMemo(() => {
    if (!summary) return [];
    return summary.activity.by_type.map((t) => ({ name: t.label, km: t.distance_km ?? 0 }));
  }, [summary]);

  const workoutData = useMemo(() => {
    if (!summary) return [];
    return summary.workouts.by_type.slice(0, 6).map((t) => ({ name: t.label, count: t.count }));
  }, [summary]);

  const weightData = useMemo(() => {
    if (!summary) return [];
    return summary.body.series.map((p) => ({
      date: p.measured_at ? p.measured_at.slice(0, 10) : '',
      kg: p.weight_kg,
    }));
  }, [summary]);

  const macroData = useMemo(() => {
    if (!summary) return [];
    const n = summary.nutrition;
    return [
      { name: 'Protein', value: Math.round(n.total_protein_g), color: COLORS[0] },
      { name: 'Carbs', value: Math.round(n.total_carbs_g), color: COLORS[1] },
      { name: 'Fat', value: Math.round(n.total_fat_g), color: COLORS[2] },
    ];
  }, [summary]);

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {Array.from({ length: 4 }).map((_, i) => <div key={i} className="h-24 bg-buddy-surface rounded-2xl" />)}
        </div>
        <div className="h-64 bg-buddy-surface rounded-2xl" />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div className="h-56 bg-buddy-surface rounded-2xl" />
          <div className="h-56 bg-buddy-surface rounded-2xl" />
        </div>
      </div>
    );
  }

  if (error || !summary) {
    return (
      <Card className="p-6 text-center text-buddy-text-secondary">
        <p>{error || 'No data available yet.'}</p>
      </Card>
    );
  }

  const { activity, workouts, nutrition, body, spending, lives, programmes } = summary;
  const weightChange = body.weight_change_kg ?? 0;

  return (
    <div className="space-y-4">
      {/* Stat cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Distance" value={`${formatKm(activity.total_distance_km)} km`} sub={`${activity.count} activities`} icon={<ActivityIcon size={18} />} />
        <StatCard label="Workouts" value={formatNumber(workouts.count)} sub={workouts.most_trained ? `${titleCase(workouts.most_trained)} most trained` : 'No workouts yet'} icon={<Dumbbell size={18} />} />
        <StatCard label="Calories Logged" value={formatNumber(nutrition.total_calories)} sub={`${formatNumber(nutrition.count)} meals`} icon={<Utensils size={18} />} />
        <StatCard label="Weight" value={body.latest_weight_kg ? `${body.latest_weight_kg} kg` : '—'} sub={`${weightChange >= 0 ? '+' : ''}${weightChange} kg this period`} icon={<Scale size={18} />} />
      </div>

      {/* Second row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Active Calories" value={formatNumber(activity.total_calories_burned + workouts.total_calories_burned)} sub="Walked + trained" icon={<Flame size={18} />} />
        <StatCard label="Time Active" value={formatDuration(activity.total_duration_seconds)} sub={`${lives.joined_count} lives joined`} icon={<Clock size={18} />} />
        <StatCard label="Spent (Artifacts)" value={formatNumber(spending.total_artifacts_spent)} sub={`${spending.total_transactions} transactions`} icon={<Wallet size={18} />} />
        <StatCard label="Programmes" value={programmes.programmes_purchased} sub={`${programmes.active_enrolments} in progress`} icon={<Radio size={18} />} />
      </div>

      {/* Activity distance chart */}
      <Card className="p-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-heading font-semibold">Distance by Activity Type</h3>
        </div>
        {chartData.length > 0 ? (
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="name" tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <YAxis tick={AXIS_TICK} axisLine={false} tickLine={false} />
                <Tooltip {...CHART_TOOLTIP} cursor={{ fill: 'rgba(255,255,255,0.04)' }} />
                <Bar dataKey="km" name="km" fill={COLORS[0]} radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <EmptyState text="Log a walk or run to see distance trends." />
        )}
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {/* Workout type distribution */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Workout Types</h3>
          {workoutData.length > 0 ? (
            <div className="h-56">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={workoutData} dataKey="count" nameKey="name" cx="50%" cy="50%" innerRadius={50} outerRadius={80} paddingAngle={3}>
                    {workoutData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Pie>
                  <Tooltip {...CHART_TOOLTIP} />
                  <Legend wrapperStyle={{ fontSize: 11, color: '#A0A0A0' }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState text="Complete workouts to see type distribution." />
          )}
        </Card>

        {/* Weight trend */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Weight Trend</h3>
          {weightData.length >= 2 ? (
            <div className="h-56">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={weightData} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                  <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="date" tick={AXIS_TICK} axisLine={false} tickLine={false} />
                  <YAxis domain={['auto', 'auto']} tick={AXIS_TICK} axisLine={false} tickLine={false} />
                  <Tooltip {...CHART_TOOLTIP} />
                  <Line type="monotone" dataKey="kg" stroke={COLORS[2]} strokeWidth={2} dot={{ r: 3, fill: COLORS[2] }} name="kg" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState text="Log your weight on the Body tab to see your trend." />
          )}
        </Card>
      </div>

      {/* Nutrition macros */}
      <Card className="p-4">
        <h3 className="font-heading font-semibold mb-3">Nutrition — Macro Totals</h3>
        <div className="flex flex-wrap gap-3">
          {macroData.map((m) => (
            <div key={m.name} className="flex-1 min-w-[140px] bg-buddy-surface-raised rounded-xl p-3">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full" style={{ background: m.color }} />
                <span className="text-xs text-buddy-text-secondary">{m.name}</span>
              </div>
              <p className="text-xl font-display font-bold mt-1">{m.value} g</p>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

function EmptyState({ text }: { text: string }) {
  return (
    <div className="h-40 flex items-center justify-center rounded-xl bg-buddy-surface-raised/50 text-sm text-buddy-text-secondary">
      {text}
    </div>
  );
}
