/**
 * Per-kind activity metrics.
 *
 * What matters depends on what you did: a walk is about steps, a run about
 * pace, a hike about the climb, a ride about speed. The tracker records the
 * same handful of numbers for every kind, so this picks the ones that
 * actually say something and drops the ones that would read as "—".
 */

export type ActivityKind = 'walk' | 'run' | 'hike' | 'cycle';

export interface ActivityMetric {
  label: string;
  value: string;
  /** Green for the headline effort, orange for energy burnt. */
  tone?: 'green' | 'orange';
}

/** The numbers a tracker session can produce. */
export interface ActivityFacts {
  activity_type?: string | null;
  duration_seconds?: number | null;
  distance_meters?: number | null;
  avg_pace?: number | null;
  avg_speed_kmh?: number | null;
  calories_burned?: number | null;
  steps?: number | null;
  elevation_gain_m?: number | null;
}

const UNIT_SECONDS = 3600;

function round1(n: number): string {
  return String(Math.round(n * 10) / 10);
}

/** "1.2 km" */
export function formatKm(meters: number | null | undefined): string | null {
  if (meters == null || !Number.isFinite(meters) || meters <= 0) return null;
  return `${round1(meters / 1000)} km`;
}

/** "45m" / "1h 05m" / "9s" */
export function formatDurationShort(seconds: number | null | undefined): string | null {
  if (seconds == null || !Number.isFinite(seconds) || seconds <= 0) return null;
  if (seconds < 60) return `${Math.round(seconds)}s`;
  const h = Math.floor(seconds / UNIT_SECONDS);
  const m = Math.round((seconds % UNIT_SECONDS) / 60);
  if (h > 0) return `${h}h ${String(m).padStart(2, '0')}m`;
  return `${m}m`;
}

/** "5:30" — minutes per kilometre. */
export function formatPace(secPerKm: number | null | undefined): string | null {
  if (secPerKm == null || !Number.isFinite(secPerKm) || secPerKm <= 0) return null;
  const m = Math.floor(secPerKm / 60);
  const s = Math.round(secPerKm % 60);
  return `${m}:${String(s).padStart(2, '0')}`;
}

/**
 * The metrics that matter for each kind of activity.
 *
 * Ordered by how much they say about the session, so the ones that carry
 * no value are simply not shown.
 */
const METRIC_SETS: Record<ActivityKind, Array<{
  key: keyof ActivityFacts | 'derived_pace' | 'derived_speed';
  label: string;
  tone?: 'green' | 'orange';
}>> = {
  walk: [
    { key: 'steps', label: 'Steps', tone: 'green' },
    { key: 'distance_meters', label: 'Distance', tone: 'green' },
    { key: 'derived_pace', label: 'Pace', tone: 'green' },
    { key: 'duration_seconds', label: 'Time', tone: 'green' },
  ],
  run: [
    { key: 'derived_pace', label: 'Pace', tone: 'green' },
    { key: 'derived_speed', label: 'Speed', tone: 'green' },
    { key: 'distance_meters', label: 'Distance', tone: 'green' },
    { key: 'calories_burned', label: 'Cal', tone: 'orange' },
    { key: 'duration_seconds', label: 'Time', tone: 'green' },
  ],
  hike: [
    { key: 'elevation_gain_m', label: 'Ascent', tone: 'green' },
    { key: 'distance_meters', label: 'Distance', tone: 'green' },
    { key: 'derived_pace', label: 'Pace', tone: 'green' },
    { key: 'duration_seconds', label: 'Time', tone: 'green' },
  ],
  cycle: [
    { key: 'derived_speed', label: 'Speed', tone: 'green' },
    { key: 'distance_meters', label: 'Distance', tone: 'green' },
    { key: 'calories_burned', label: 'Cal', tone: 'orange' },
    { key: 'duration_seconds', label: 'Time', tone: 'green' },
  ],
};

/** The metric set for a kind, falling back to a walk's for anything unknown. */
export function metricsFor(kind: string | null | undefined): typeof METRIC_SETS.walk {
  return METRIC_SETS[(kind as ActivityKind)] ?? METRIC_SETS.walk;
}

/**
 * The metrics worth showing for an activity, in order.
 *
 * Only the ones with a real value are included — an empty tile reading "—"
 * says nothing.
 */
export function activityMetrics(facts: ActivityFacts, limit = 4): ActivityMetric[] {
  const out: ActivityMetric[] = [];

  const derivedPace = (): number | null => {
    if (facts.avg_pace && facts.avg_pace > 0) return facts.avg_pace;
    const km = (facts.distance_meters ?? 0) / 1000;
    if (km > 0 && (facts.duration_seconds ?? 0) > 0) {
      return (facts.duration_seconds as number) / km;
    }
    return null;
  };

  const derivedSpeed = (): number | null => {
    if (facts.avg_speed_kmh && facts.avg_speed_kmh > 0) return facts.avg_speed_kmh;
    const km = (facts.distance_meters ?? 0) / 1000;
    if (km > 0 && (facts.duration_seconds ?? 0) > 0) {
      return (km / ((facts.duration_seconds as number) / UNIT_SECONDS));
    }
    return null;
  };

  for (const def of metricsFor(facts.activity_type)) {
    let value: string | null = null;
    switch (def.key) {
      case 'steps':
        value = facts.steps && facts.steps > 0 ? String(Math.round(facts.steps)) : null;
        break;
      case 'distance_meters':
        value = formatKm(facts.distance_meters);
        break;
      case 'duration_seconds':
        value = formatDurationShort(facts.duration_seconds);
        break;
      case 'calories_burned':
        value = facts.calories_burned && facts.calories_burned > 0
          ? String(Math.round(facts.calories_burned))
          : null;
        break;
      case 'elevation_gain_m':
        value = facts.elevation_gain_m && facts.elevation_gain_m > 0
          ? `${Math.round(facts.elevation_gain_m)} m`
          : null;
        break;
      case 'derived_pace':
        value = formatPace(derivedPace());
        break;
      case 'derived_speed':
        value = derivedSpeed() ? `${round1(derivedSpeed() as number)} km/h` : null;
        break;
      default:
        value = null;
    }
    if (!value) continue;
    out.push({ label: def.label, value, tone: def.tone });
    if (out.length >= limit) break;
  }

  return out;
}

/** The heading for an activity kind. */
export function activityLabel(kind: string | null | undefined): string {
  const labels: Record<string, string> = {
    walk: 'Walking',
    run: 'Running',
    hike: 'Hiking',
    cycle: 'Cycling',
  };
  return labels[kind ?? ''] ?? 'Activity';
}
