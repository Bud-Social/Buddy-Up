import { useEffect, useState } from 'react';
import { Dumbbell, Timer, Flame } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { StatCard } from '@/components/analytics/StatCard';
import { formatNumber, titleCase, formatDateTime } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { AnalyticsPeriod, AnalyticsSummaryData, WorkoutLogInput } from '@/types/analytics';

interface Props { period: AnalyticsPeriod; }

const TYPES: { key: WorkoutLogInput['workout_type']; label: string }[] = [
  { key: 'strength', label: 'Strength' },
  { key: 'cardio', label: 'Cardio' },
  { key: 'hiit', label: 'HIIT' },
  { key: 'yoga', label: 'Yoga' },
  { key: 'mobility', label: 'Mobility' },
  { key: 'sport', label: 'Sport' },
  { key: 'other', label: 'Other' },
];

interface WorkoutRow {
  id: string;
  workout_type: string;
  exercise: string;
  sets?: number | null;
  reps?: number | null;
  weight_kg?: number | null;
  duration_minutes?: number | null;
  calories_burned?: number | null;
  performed_at: string;
}

const EMPTY: WorkoutLogInput = {
  workout_type: 'strength',
  exercise: '',
  sets: null,
  reps: null,
  weight_kg: null,
  duration_minutes: 45,
  calories_burned: null,
  performed_at: undefined,
};

export function WorkoutsTab({ period }: Props) {
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [history, setHistory] = useState<WorkoutRow[]>([]);
  const [form, setForm] = useState<WorkoutLogInput>(EMPTY);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    analyticsApi.getSummary(period)
      .then((res) => setSummary(res.data))
      .catch(() => {});
  }, [period]);

  useEffect(() => {
    analyticsApi.getWorkouts()
      .then((res) => setHistory((res.data as WorkoutRow[]) || []))
      .catch(() => {});
  }, []);

  const submit = async () => {
    setSaving(true);
    setError(null);
    try {
      await analyticsApi.createWorkout(form);
      setForm(EMPTY);
      analyticsApi.getSummary(period).then((res) => setSummary(res.data)).catch(() => {});
      analyticsApi.getWorkouts().then((res) => setHistory((res.data as WorkoutRow[]) || [])).catch(() => {});
    } catch {
      setError('Failed to save workout.');
    } finally {
      setSaving(false);
    }
  };

  const w = summary?.workouts;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard label="Workouts" value={formatNumber(w?.count ?? 0)} icon={<Dumbbell size={18} />} />
        <StatCard label="Calories Burned" value={formatNumber(w?.total_calories_burned ?? 0)} icon={<Flame size={18} />} />
        <StatCard label="Time" value={w ? `${w.recent.reduce((s, r) => s + (r.duration_minutes || 0), 0)}m` : '0m'} icon={<Timer size={18} />} />
        <StatCard label="Volume" value={`${formatNumber(w?.total_volume ?? 0)} kg`} sub={w?.most_trained ? `${titleCase(w.most_trained)} top exercise` : undefined} icon={<Dumbbell size={18} />} />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Log form */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Log a Workout</h3>
          <div className="space-y-3">
            <div>
              <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Type</p>
              <div className="flex flex-wrap gap-1.5">
                {TYPES.map((t) => (
                  <button
                    key={t.key}
                    onClick={() => setForm((f) => ({ ...f, workout_type: t.key }))}
                    className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                      form.workout_type === t.key
                        ? 'bg-buddy-green text-buddy-black font-medium'
                        : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                    }`}
                  >
                    {t.label}
                  </button>
                ))}
              </div>
            </div>
            <Input
              label="Exercise"
              placeholder="e.g. Squat, Bench Press"
              value={form.exercise ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, exercise: e.target.value }))}
            />
            <div className="grid grid-cols-3 gap-2">
              <Input label="Sets" type="number" min={0} placeholder="0" value={form.sets ?? ''} onChange={(e) => setForm((f) => ({ ...f, sets: e.target.value === '' ? null : Number(e.target.value) }))} />
              <Input label="Reps" type="number" min={0} placeholder="0" value={form.reps ?? ''} onChange={(e) => setForm((f) => ({ ...f, reps: e.target.value === '' ? null : Number(e.target.value) }))} />
              <Input label="Weight kg" type="number" min={0} placeholder="0" value={form.weight_kg ?? ''} onChange={(e) => setForm((f) => ({ ...f, weight_kg: e.target.value === '' ? null : Number(e.target.value) }))} />
            </div>
            <div className="grid grid-cols-2 gap-2">
              <Input label="Duration (min)" type="number" min={0} value={form.duration_minutes ?? ''} onChange={(e) => setForm((f) => ({ ...f, duration_minutes: e.target.value === '' ? undefined : Number(e.target.value) }))} />
              <Input label="Calories" type="number" min={0} placeholder="0" value={form.calories_burned ?? ''} onChange={(e) => setForm((f) => ({ ...f, calories_burned: e.target.value === '' ? null : Number(e.target.value) }))} />
            </div>
            {error && <p className="text-sm text-buddy-red">{error}</p>}
            <Button onClick={submit} isLoading={saving} className="w-full">
              Save Workout
            </Button>
          </div>
        </Card>

        {/* Recent history */}
        <div>
          <h3 className="font-heading font-semibold mb-3">Recent Workouts</h3>
          {history.length === 0 ? (
            <Card className="p-6 text-center text-buddy-text-secondary text-sm">
              No workouts logged yet.
            </Card>
          ) : (
            <div className="space-y-2.5 max-h-[420px] overflow-y-auto pr-1">
              {history.map((r) => (
                <Card key={r.id} className="p-3 flex items-center justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-sm font-medium truncate">{titleCase(r.exercise || r.workout_type)}</p>
                    <p className="text-xs text-buddy-text-secondary">
                      {titleCase(r.workout_type)} · {formatDateTime(r.performed_at)}
                    </p>
                    <p className="text-xs text-buddy-text-secondary mt-0.5">
                      {[r.sets, r.reps].filter((v) => v != null).join('×') || `${r.duration_minutes ?? '—'} min`}
                      {r.weight_kg ? ` @ ${r.weight_kg} kg` : ''}
                    </p>
                  </div>
                  {r.calories_burned != null && r.calories_burned > 0 && (
                    <span className="flex-shrink-0 text-xs font-medium text-buddy-green">{Math.round(r.calories_burned)} kcal</span>
                  )}
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
