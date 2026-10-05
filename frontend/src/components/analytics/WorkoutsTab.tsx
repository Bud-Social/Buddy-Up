import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Dumbbell, Timer, Flame, Share2, Check, PlayCircle, Send } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { StatCard } from '@/components/analytics/StatCard';
import { formatNumber, titleCase, formatDateTime } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import { useToast } from '@/components/ui/Toast';
import {
  buildWorkoutPayload,
  hasField,
  measuredNotice,
  resetForType,
  specFor,
  typeOrder,
  useWorkoutTypes,
  type WorkoutFormState,
} from '@/lib/workoutTypes';
import { analyticsShareUrl, buildShareText, shareActivity } from '@/lib/shareWorkout';
import type { AnalyticsPeriod, AnalyticsSummaryData } from '@/types/analytics';
import { WORKOUT_DURATION_PRESETS } from '@/types/analytics';

interface Props { period: AnalyticsPeriod; }

interface WorkoutRow {
  id: string;
  workout_type: string;
  category?: string;
  exercise: string;
  sets?: number | null;
  reps?: number | null;
  weight_kg?: number | null;
  rounds?: number | null;
  style?: string;
  focus?: string;
  sport?: string;
  distance_meters?: number | null;
  distance_km?: number | null;
  duration_minutes?: number | null;
  calories_burned?: number | null;
  performed_at: string;
}

const EMPTY_FORM: WorkoutFormState = {
  workout_type: 'strength',
  category: '',
  exercise: '',
  sets: null,
  reps: null,
  weight_kg: null,
  rounds: null,
  distance_km: null,
  calories_burned: null,
  style: '',
  focus: '',
  sport: '',
  duration_minutes: 45,
};

const num = (v: string): number | null => (v === '' ? null : Number(v));
const str = (v: string): string => v;

/** One-line summary of what a history row actually records for its type. */
function rowDetail(r: WorkoutRow): string {
  const km = r.distance_km ?? (r.distance_meters ? r.distance_meters / 1000 : null);
  const parts = [
    [r.sets, r.reps].filter((v) => v != null).join('×'),
    r.rounds != null ? `${r.rounds} rounds` : '',
    km ? `${km.toFixed(2)} km` : '',
    r.duration_minutes ? `${r.duration_minutes} min` : '',
  ].filter(Boolean);
  const head = parts.join(' · ') || '—';
  return r.weight_kg ? `${head} @ ${r.weight_kg} kg` : head;
}

export function WorkoutsTab({ period }: Props) {
  const navigate = useNavigate();
  const { toast } = useToast();
  const { types } = useWorkoutTypes();
  const [summary, setSummary] = useState<AnalyticsSummaryData | null>(null);
  const [history, setHistory] = useState<WorkoutRow[]>([]);
  const [form, setForm] = useState<WorkoutFormState>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  const spec = specFor(types, form.workout_type);
  const order = useMemo(() => typeOrder(types), [types]);

  /** Change type and immediately drop the fields the new type can't record. */
  const selectType = (key: string) => {
    setForm((f) => resetForType({ ...f, workout_type: key }, types));
    setError(null);
  };

  /** Share-to-feed stays; the OS share sheet is the primary row action. */
  const shareToFeed = async (id: string) => {
    try {
      const res = await analyticsApi.shareActivity('workout', id);
      toast('success', 'Shared to feed!');
      if (res.data?.post_id) navigate(`/feed?post=${res.data.post_id}`);
    } catch {
      toast('error', 'Could not share workout.');
    }
  };

  const onShare = async (r: WorkoutRow) => {
    const outcome = await shareActivity({
      title: `${titleCase(r.workout_type)} on BuddyUp`,
      text: buildShareText({
        label: titleCase(r.workout_type),
        category: r.category,
        durationMinutes: r.duration_minutes,
        distanceKm: r.distance_km ?? (r.distance_meters ? r.distance_meters / 1000 : null),
        calories: r.calories_burned,
        detail: [r.exercise, r.style, r.focus, r.sport].filter(Boolean).join(' · ') || null,
      }),
      url: analyticsShareUrl(),
    });
    if (outcome === 'copied') {
      setCopied(r.id);
      toast('success', 'Link copied');
      window.setTimeout(() => setCopied((c) => (c === r.id ? null : c)), 2000);
    } else if (outcome === 'failed') {
      toast('error', 'Could not share this workout.');
    }
  };

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
      await analyticsApi.createWorkout(buildWorkoutPayload(form, types));
      setForm(EMPTY_FORM);
      analyticsApi.getSummary(period).then((res) => setSummary(res.data)).catch(() => {});
      analyticsApi.getWorkouts().then((res) => setHistory((res.data as WorkoutRow[]) || [])).catch(() => {});
      toast('success', 'Workout logged.');
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

      {/* Start workout — record now, no typing */}
      <Card className="p-4 flex flex-col sm:flex-row sm:items-center gap-3">
        <div className="flex-1">
          <h3 className="font-heading font-semibold">Start workout</h3>
          <p className="text-sm text-buddy-text-secondary">
            Pick a type and hit record — camera or timer only, nothing to type.
          </p>
        </div>
        <Button onClick={() => navigate('/workout-form?start=1')} className="w-full sm:w-auto gap-2">
          <PlayCircle size={18} /> Start workout
        </Button>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Log form — only the fields this workout type records */}
        <Card className="p-4">
          <h3 className="font-heading font-semibold mb-3">Log a Workout</h3>
          <div className="space-y-3">
            <div>
              <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Type</p>
              <div className="flex flex-wrap gap-1.5">
                {order.map((key) => {
                  const s = specFor(types, key);
                  return (
                    <button
                      key={key}
                      onClick={() => selectType(key)}
                      aria-pressed={form.workout_type === key}
                      className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                        form.workout_type === key
                          ? 'bg-buddy-green text-buddy-black font-medium'
                          : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                      }`}
                    >
                      {s.label}
                    </button>
                  );
                })}
              </div>
            </div>

            {hasField(spec, 'exercise') && (
              <Input
                label="Exercise"
                placeholder="e.g. Squat, Bench Press"
                value={form.exercise ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, exercise: str(e.target.value) }))}
              />
            )}
            {hasField(spec, 'style') && (
              <Input
                label="Style"
                placeholder="e.g. Vinyasa, Kickboxing"
                value={form.style ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, style: str(e.target.value) }))}
              />
            )}
            {hasField(spec, 'focus') && (
              <Input
                label="Focus"
                placeholder="e.g. Hips, Shoulders"
                value={form.focus ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, focus: str(e.target.value) }))}
              />
            )}
            {hasField(spec, 'sport') && (
              <Input
                label="Sport"
                placeholder="e.g. Football, Tennis"
                value={form.sport ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, sport: str(e.target.value) }))}
              />
            )}

            {spec.categories.length > 0 && (
              <div>
                <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Category</p>
                <div className="flex flex-wrap gap-1.5">
                  {spec.categories.map((c) => (
                    <button
                      key={c.key}
                      onClick={() => setForm((f) => ({ ...f, category: f.category === c.key ? '' : c.key }))}
                      aria-pressed={form.category === c.key}
                      className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                        form.category === c.key
                          ? 'bg-buddy-green text-buddy-black font-medium'
                          : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                      }`}
                    >
                      {c.label}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {hasField(spec, 'sets') && (
              <div className="grid grid-cols-3 gap-2">
                <Input label="Sets" type="number" min={0} placeholder="0" value={form.sets ?? ''} onChange={(e) => setForm((f) => ({ ...f, sets: num(e.target.value) }))} />
                <Input label="Reps" type="number" min={0} placeholder="0" value={form.reps ?? ''} onChange={(e) => setForm((f) => ({ ...f, reps: num(e.target.value) }))} />
                <Input label="Weight kg" type="number" min={0} placeholder="0" value={form.weight_kg ?? ''} onChange={(e) => setForm((f) => ({ ...f, weight_kg: num(e.target.value) }))} />
              </div>
            )}
            {hasField(spec, 'rounds') && (
              <Input
                label="Rounds"
                type="number"
                min={0}
                placeholder="0"
                value={form.rounds ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, rounds: num(e.target.value) }))}
              />
            )}
            {hasField(spec, 'distance_km') && (
              <div className="grid grid-cols-2 gap-2">
                <Input
                  label="Distance km"
                  type="number"
                  min={0}
                  step="0.01"
                  placeholder="0.00"
                  value={form.distance_km ?? ''}
                  onChange={(e) => setForm((f) => ({ ...f, distance_km: num(e.target.value) }))}
                />
                {hasField(spec, 'calories_burned') && (
                  <Input
                    label="Calories"
                    type="number"
                    min={0}
                    placeholder="0"
                    value={form.calories_burned ?? ''}
                    onChange={(e) => setForm((f) => ({ ...f, calories_burned: num(e.target.value) }))}
                  />
                )}
              </div>
            )}
            {hasField(spec, 'calories_burned') && !hasField(spec, 'distance_km') && (
              <Input
                label="Calories"
                type="number"
                min={0}
                placeholder="0"
                value={form.calories_burned ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, calories_burned: num(e.target.value) }))}
              />
            )}

            <Input
              label="Duration (min)"
              type="number"
              min={0}
              value={form.duration_minutes ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, duration_minutes: e.target.value === '' ? null : Number(e.target.value) }))}
            />
            <div>
              <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Duration preset</p>
              <div className="flex flex-wrap gap-1.5">
                {WORKOUT_DURATION_PRESETS.map((m) => (
                  <button
                    key={m}
                    onClick={() => setForm((f) => ({ ...f, duration_minutes: m }))}
                    aria-pressed={form.duration_minutes === m}
                    className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                      form.duration_minutes === m
                        ? 'bg-buddy-green text-buddy-black font-medium'
                        : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                    }`}
                  >
                    {m} min
                  </button>
                ))}
              </div>
            </div>

            {!spec.measured && (
              <p className="text-xs text-buddy-text-secondary bg-buddy-surface-raised rounded-lg px-3 py-2">
                {measuredNotice(spec)}
              </p>
            )}

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
              {history.map((r) => {
                const rowSpec = specFor(types, r.workout_type);
                return (
                  <Card key={r.id} className="p-3 flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-sm font-medium truncate">{titleCase(r.exercise || r.style || r.workout_type)}</p>
                      <p className="text-xs text-buddy-text-secondary">
                        {titleCase(r.workout_type)}{r.category ? ` · ${titleCase(r.category)}` : ''} · {formatDateTime(r.performed_at)}
                      </p>
                      <p className="text-xs text-buddy-text-secondary mt-0.5">{rowDetail(r)}</p>
                      {!rowSpec.measured && (
                        <p className="text-[11px] text-buddy-text-secondary/70 mt-0.5">Not measured — time and distance only</p>
                      )}
                    </div>
                    <div className="flex-shrink-0 flex items-center gap-1">
                      {r.calories_burned != null && r.calories_burned > 0 && (
                        <span className="text-xs font-medium text-buddy-green mr-1">{Math.round(r.calories_burned)} kcal</span>
                      )}
                      <button onClick={() => shareToFeed(r.id)} title="Post to feed" aria-label={`Post ${titleCase(r.workout_type)} to feed`}
                        className="p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10 transition-colors">
                        <Send size={14} />
                      </button>
                      <button onClick={() => onShare(r)} title="Share"
                        aria-label={copied === r.id ? 'Link copied' : `Share ${titleCase(r.workout_type)} workout`}
                        className="p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10 transition-colors">
                        {copied === r.id ? <Check size={14} className="text-buddy-green" /> : <Share2 size={14} />}
                      </button>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}