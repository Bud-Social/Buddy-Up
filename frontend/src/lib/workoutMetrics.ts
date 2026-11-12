/**
 * Workout post metrics.
 *
 * `workout_log_data` is a free-form JSON blob written by several flows, so
 * the shape varies:
 *   - flat log:      { exercise, sets, reps, weight_kg, calories }
 *   - exercise list: { exercises: [{ name, sets, reps, weight }] }
 *   - activity:      { activity_type, distance_km, duration_minutes, calories, steps }
 *   - countdown:     { countdown_reason, count, target_count, countdown_unit }
 *
 * This module normalises all of them so the feed card and the share card
 * always show the same numbers.
 */

export interface WorkoutMetric {
  label: string;
  value: string;
  /** Green for training volume, orange for burn/energy. */
  tone?: 'green' | 'orange';
}

export interface WorkoutMetrics {
  title: string;
  metrics: WorkoutMetric[];
}

function text(value: unknown): string | null {
  if (value === null || value === undefined || value === '') return null;
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) return null;
    return String(Math.round(value * 10) / 10);
  }
  const str = String(value).trim();
  return str || null;
}

/** Normalise a workout payload into a title + up to three metrics. */
export function parseWorkoutMetrics(
  data: Record<string, unknown> | null | undefined,
): WorkoutMetrics | null {
  if (!data || typeof data !== 'object') return null;

  // ── Shape 4: a countdown ──────────────────────────────────────────────────
  const countdownReason = text(data.countdown_reason);
  if (countdownReason) {
    const unit = text(data.countdown_unit) || 'days';
    const count = text(data.count);
    const target = text(data.target_count);
    const streak = text(data.elapsed_units);
    const title = countdownReason;
    const metrics: WorkoutMetric[] = [];
    // "1 / 30" over "Days" — the value carries the goal, the label the unit.
    if (count) {
      metrics.push({
        label: target && Number(target) > 0 ? `${unit} / ${target}` : unit,
        value: count,
        tone: 'green',
      });
    }
    // The streak is the wall-clock length, which moves on its own. It is
    // only worth showing when it says something the count does not.
    if (streak && Number(streak) > 0 && Number(streak) !== Number(count)) {
      metrics.push({ label: 'Streak', value: streak, tone: 'green' });
    }
    if (data.countdown_type === 'automatic') {
      metrics.push({ label: 'Mode', value: 'Automatic', tone: 'orange' });
    }
    return metrics.length ? { title, metrics } : null;
  }

  // ── Shape 2: a list of exercises ──────────────────────────────────────────
  const exercises = Array.isArray(data.exercises)
    ? (data.exercises as Record<string, unknown>[]).filter((e) => e && typeof e === 'object')
    : [];
  if (exercises.length) {
    const first = exercises[0];
    const names = exercises
      .map((e) => text(e.name))
      .filter((n): n is string => !!n);
    const title = names.length > 1 ? `${names[0]} +${names.length - 1} more` : (names[0] || 'Workout');
    const metrics: WorkoutMetric[] = [];
    const sets = text(first.sets);
    if (sets) metrics.push({ label: 'Sets', value: sets, tone: 'green' });
    const reps = text(first.reps);
    if (reps) metrics.push({ label: 'Reps', value: reps, tone: 'green' });
    const weight = text(first.weight ?? first.weight_kg);
    if (weight) metrics.push({ label: 'kg', value: weight, tone: 'orange' });
    return metrics.length ? { title, metrics } : null;
  }

  // ── Shape 1 / 3: flat workout or activity log ────────────────────────────
  const isActivity = !!(text(data.activity_type) || text(data.distance_km));
  const title =
    text(data.exercise) ||
    text(data.activity_type) ||
    text(data.title) ||
    'Workout';
  const metrics: WorkoutMetric[] = [];

  if (isActivity) {
    const distance = text(data.distance_km);
    if (distance) metrics.push({ label: 'km', value: distance, tone: 'green' });
    const duration = text(data.duration_minutes);
    if (duration) metrics.push({ label: 'min', value: duration, tone: 'green' });
    const calories = text(data.calories ?? data.calories_burned);
    if (calories) metrics.push({ label: 'Cal', value: calories, tone: 'orange' });
  } else {
    const sets = text(data.sets);
    if (sets) metrics.push({ label: 'Sets', value: sets, tone: 'green' });
    const reps = text(data.reps);
    if (reps) metrics.push({ label: 'Reps', value: reps, tone: 'green' });
    const weight = text(data.weight_kg ?? data.weight);
    const calories = text(data.calories ?? data.calories_burned);
    if (weight) metrics.push({ label: 'kg', value: weight, tone: 'orange' });
    else if (calories) metrics.push({ label: 'Cal', value: calories, tone: 'orange' });
  }

  return metrics.length ? { title, metrics } : null;
}
