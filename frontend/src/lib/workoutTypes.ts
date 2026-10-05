/**
 * workoutTypes — the one place that decides which fields a workout type
 * records.
 *
 * The backend owns the taxonomy (GET /analytics/workout-types/, backed by
 * WORKOUT_TYPE_SPECS). We fetch it once per session and cache the promise at
 * module level, so every consumer shares a single request. Until it resolves —
 * and forever if it fails — the static LOCAL_WORKOUT_TYPES copy below drives
 * the forms, which keeps the category pickers and field visibility correct
 * offline.
 *
 * LOCAL_WORKOUT_TYPES mirrors WORKOUT_TYPE_SPECS in backend/apps/analytics/
 * models.py (same keys, same order, same category lists, same measured flags).
 * The workoutTypes test asserts the shape so drift is caught, not guessed.
 */

import { useEffect, useState } from 'react';
import { analyticsApi } from '@/api/analytics';
import { WORKOUT_CATEGORIES, WORKOUT_TYPE_KEYS } from '@/types/analytics';
import type { WorkoutLogInput } from '@/types/analytics';

/** Every field the log form knows how to render. */
export type WorkoutField =
  | 'exercise'
  | 'sets'
  | 'reps'
  | 'weight_kg'
  | 'rounds'
  | 'distance_km'
  | 'calories_burned'
  | 'style'
  | 'focus'
  | 'sport'
  | 'duration_minutes';

/** Render order of the fields inside the form, independent of the spec. */
export const FIELD_ORDER: WorkoutField[] = [
  'exercise', 'sets', 'reps', 'weight_kg', 'rounds',
  'distance_km', 'calories_burned', 'style', 'focus', 'sport', 'duration_minutes',
];

/**
 * The taxonomy speaks in model column names; the form speaks in kilometres.
 * This maps the server's field names onto ours.
 */
const FIELD_ALIASES: Record<string, WorkoutField> = {
  ...Object.fromEntries(FIELD_ORDER.map((f) => [f, f])),
  distance_meters: 'distance_km',
};

/** Labels for every category key in the taxonomy. */
export const CATEGORY_LABELS: Record<string, string> = {
  // strength / hiit
  upper: 'Upper', lower: 'Lower', push: 'Push', pull: 'Pull',
  legs: 'Legs', arms: 'Arms', core: 'Core', full: 'Full', cardio: 'Cardio',
  // yoga / pilates
  flexibility: 'Flexibility', mobility: 'Mobility', balance: 'Balance',
  strength: 'Strength', mindfulness: 'Mindfulness', posture: 'Posture',
  // mobility
  hips: 'Hips', shoulders: 'Shoulders', spine: 'Spine', ankles: 'Ankles',
  // sport
  football: 'Football', basketball: 'Basketball', tennis: 'Tennis', cricket: 'Cricket',
  rugby: 'Rugby', netball: 'Netball', volleyball: 'Volleyball', other: 'Other',
};

/** Mirrors the backend's `category_label()` so offline and online match. */
const labelFor = (key: string): string => key.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

const cats = (...keys: string[]): WorkoutCategoryOption[] =>
  keys.map((key) => ({ key, label: CATEGORY_LABELS[key] ?? labelFor(key) }));

const STRENGTH_CATS = WORKOUT_CATEGORIES.map((c) => c.key);

export interface WorkoutCategoryOption { key: string; label: string }

export interface WorkoutTypeSpec {
  label: string;
  categories: WorkoutCategoryOption[];
  fields: WorkoutField[];
  /** True when the type is tracked with objective metrics, not described. */
  measured: boolean;
}

const type = (
  label: string,
  categories: WorkoutCategoryOption[],
  fields: WorkoutField[],
  measured: boolean,
): WorkoutTypeSpec => ({ label, categories, fields: withDuration(fields), measured });

/**
 * Offline fallback, mirroring WORKOUT_TYPE_SPECS. Types with no categories
 * (cardio, the distance sports, climbing, dance, boxing, martial arts, other)
 * deliberately send `category: ''` — the backend rejects a mismatched one.
 */
export const LOCAL_WORKOUT_TYPES: Record<string, WorkoutTypeSpec> = {
  strength: type('Strength', cats(...STRENGTH_CATS), ['sets', 'reps', 'weight_kg'], true),
  hiit: type('HIIT', cats('full', 'upper', 'lower', 'core', 'cardio'), ['rounds'], true),
  cardio: type('Cardio', [], ['distance_km', 'calories_burned'], true),
  running: type('Running', [], ['distance_km', 'calories_burned'], true),
  walking: type('Walking', [], ['distance_km', 'calories_burned'], true),
  cycling: type('Cycling', [], ['distance_km', 'calories_burned'], true),
  swimming: type('Swimming', [], ['distance_km', 'calories_burned'], true),
  climbing: type('Climbing', [], [], false),
  rowing: type('Rowing', [], [], false),
  dance: type('Dance', [], [], false),
  yoga: type('Yoga', cats('flexibility', 'mobility', 'balance', 'strength', 'mindfulness'), ['style'], false),
  pilates: type('Pilates', cats('core', 'posture', 'flexibility', 'mobility', 'full'), ['style'], false),
  mobility: type('Mobility', cats('hips', 'shoulders', 'spine', 'ankles', 'full'), ['focus'], false),
  sport: type('Sport', cats('football', 'basketball', 'tennis', 'cricket', 'rugby', 'netball', 'volleyball', 'other'), ['sport'], false),
  boxing: type('Boxing', [], ['style'], false),
  martial_arts: type('Martial Arts', [], ['style'], false),
  other: type('Other', [], [], false),
};

/** Duration is recorded for every workout type, so it is never hidden. */
export function withDuration(fields: WorkoutField[]): WorkoutField[] {
  return fields.includes('duration_minutes') ? fields : [...fields, 'duration_minutes'];
}

/** Type picker order: the canonical order, then any server-only additions. */
export function typeOrder(types: Record<string, WorkoutTypeSpec>): string[] {
  const known = WORKOUT_TYPE_KEYS.filter((k) => types[k]);
  const extra = Object.keys(types).filter((k) => !(WORKOUT_TYPE_KEYS as readonly string[]).includes(k));
  return [...known, ...extra];
}

function asOptions(raw: unknown): WorkoutCategoryOption[] | null {
  if (!Array.isArray(raw)) return null;
  return raw
    .map((c) => {
      if (typeof c === 'string') return { key: c, label: CATEGORY_LABELS[c] ?? labelFor(c) };
      const k = (c as { key?: unknown })?.key;
      if (typeof k !== 'string' || !k) return null;
      const l = (c as { label?: unknown })?.label;
      return { key: k, label: typeof l === 'string' && l ? l : (CATEGORY_LABELS[k] ?? labelFor(k)) };
    })
    .filter((c): c is WorkoutCategoryOption => c !== null);
}

function asFields(raw: unknown): WorkoutField[] | null {
  if (!Array.isArray(raw) || raw.length === 0) return null;
  const known = raw
    .map((f) => (typeof f === 'string' ? FIELD_ALIASES[f] : undefined))
    .filter((f): f is WorkoutField => !!f);
  return known.length ? known : null;
}

/**
 * The server spec wins for categories (an empty list is meaningful: those
 * types send `''`). Fields only override when the server actually enumerates
 * them, so a spec that ships `fields: []` cannot strip the duration every log
 * records.
 */
function mergeSpec(key: string, raw: unknown): WorkoutTypeSpec | null {
  if (!raw || typeof raw !== 'object') return null;
  const local = LOCAL_WORKOUT_TYPES[key];
  const r = raw as { label?: unknown; categories?: unknown; fields?: unknown; measured?: unknown };
  return {
    label: typeof r.label === 'string' && r.label ? r.label : local?.label ?? labelFor(key),
    categories: asOptions(r.categories) ?? local?.categories ?? [],
    fields: withDuration(asFields(r.fields) ?? local?.fields ?? []),
    measured: typeof r.measured === 'boolean' ? r.measured : local?.measured ?? false,
  };
}

/** Merge a fetched taxonomy payload over the local fallback. */
export function mergeWorkoutTypes(payload: unknown): Record<string, WorkoutTypeSpec> {
  // The endpoint returns `{ workout_types, categories }`; `types` is accepted
  // as an alias so a contract change on either side can't blank the form.
  const root = payload as Record<string, unknown> | null | undefined;
  const remote = (root?.workout_types ?? root?.types) as Record<string, unknown> | undefined;

  const merged: Record<string, WorkoutTypeSpec> = {};
  for (const key of typeOrder(LOCAL_WORKOUT_TYPES)) {
    merged[key] = mergeSpec(key, remote?.[key]) ?? LOCAL_WORKOUT_TYPES[key];
  }
  if (remote) {
    for (const key of Object.keys(remote)) {
      if (!merged[key]) {
        const spec = mergeSpec(key, remote[key]);
        if (spec) merged[key] = spec;
      }
    }
  }
  return merged;
}

let cached: Promise<Record<string, WorkoutTypeSpec>> | null = null;

/**
 * Fetch the taxonomy once per session. Resolves to the local fallback rather
 * than rejecting when the endpoint is unavailable.
 */
export function loadWorkoutTypes(): Promise<Record<string, WorkoutTypeSpec>> {
  if (!cached) {
    cached = analyticsApi
      .getWorkoutTypes()
      .then((res) => mergeWorkoutTypes(res?.data ?? res))
      .catch(() => LOCAL_WORKOUT_TYPES);
  }
  return cached;
}

/** Test seam — drops the module-level cache so the next load refetches. */
export function resetWorkoutTypesCache(): void {
  cached = null;
}

/** The spec for a type, falling back to a neutral generic entry. */
export function specFor(types: Record<string, WorkoutTypeSpec>, typeKey: string | null | undefined): WorkoutTypeSpec {
  return (typeKey ? types[typeKey] : undefined) ?? types.other ?? LOCAL_WORKOUT_TYPES.other;
}

/** Ordered list of the fields the form should render for a type. */
export function visibleFields(spec: WorkoutTypeSpec): WorkoutField[] {
  const allowed = new Set<string>(withDuration(spec.fields));
  return FIELD_ORDER.filter((f) => allowed.has(f));
}

export function hasField(spec: WorkoutTypeSpec, field: WorkoutField): boolean {
  return visibleFields(spec).includes(field);
}

/** '' whenever the type has no categories or the pick isn't in its list. */
export function normalizeCategory(spec: WorkoutTypeSpec, category: string | null | undefined): string {
  if (!category) return '';
  return spec.categories.some((c) => c.key === category) ? category : '';
}

const DESCRIPTORS: { field: WorkoutField; label: string }[] = [
  { field: 'style', label: 'style' },
  { field: 'focus', label: 'focus' },
  { field: 'sport', label: 'sport' },
];

/**
 * Copy for types the platform describes rather than measures. Without it the
 * form looks broken — sets/reps simply never appear for a yoga class.
 */
export function measuredNotice(spec: WorkoutTypeSpec): string | null {
  if (spec.measured) return null;
  const descriptor = DESCRIPTORS.find((d) => hasField(spec, d.field));
  const what = hasField(spec, 'distance_km') ? 'time and distance' : 'time';
  return `${spec.label} isn't tracked in sets or reps. Log the ${what}${
    descriptor ? ` and add a ${descriptor.label} to label it` : ''
  }.`;
}

export interface WorkoutFormState {
  workout_type: string;
  category?: string;
  exercise?: string;
  sets?: number | null;
  reps?: number | null;
  weight_kg?: number | null;
  rounds?: number | null;
  distance_km?: number | null;
  calories_burned?: number | null;
  style?: string;
  focus?: string;
  sport?: string;
  duration_minutes?: number | null;
  notes?: string;
}

const isBlank = (v: unknown): boolean => v === null || v === undefined || v === '';

/**
 * Turn form state into an API payload: anything the selected type doesn't
 * record is dropped, so a stale rep count never rides along on a yoga log.
 */
export function buildWorkoutPayload(form: WorkoutFormState, types: Record<string, WorkoutTypeSpec>): WorkoutLogInput {
  const spec = specFor(types, form.workout_type);
  const visible = new Set<string>(visibleFields(spec));
  const payload: WorkoutLogInput = { workout_type: form.workout_type, category: normalizeCategory(spec, form.category) };

  if (visible.has('exercise') && !isBlank(form.exercise)) payload.exercise = String(form.exercise).trim();
  if (visible.has('sets') && !isBlank(form.sets)) payload.sets = Number(form.sets);
  if (visible.has('reps') && !isBlank(form.reps)) payload.reps = Number(form.reps);
  if (visible.has('weight_kg') && !isBlank(form.weight_kg)) payload.weight_kg = Number(form.weight_kg);
  if (visible.has('rounds') && !isBlank(form.rounds)) payload.rounds = Number(form.rounds);
  // The form collects kilometres; the API stores meters.
  if (visible.has('distance_km') && !isBlank(form.distance_km)) {
    const km = Number(form.distance_km);
    if (Number.isFinite(km) && km > 0) payload.distance_meters = Math.round(km * 1000);
  }
  if (visible.has('calories_burned') && !isBlank(form.calories_burned)) payload.calories_burned = Number(form.calories_burned);
  if (visible.has('style') && !isBlank(form.style)) payload.style = String(form.style).slice(0, 60);
  if (visible.has('focus') && !isBlank(form.focus)) payload.focus = String(form.focus).slice(0, 60);
  if (visible.has('sport') && !isBlank(form.sport)) payload.sport = String(form.sport).slice(0, 60);
  if (!isBlank(form.duration_minutes)) payload.duration_minutes = Number(form.duration_minutes);
  if (!isBlank(form.notes)) payload.notes = String(form.notes).trim();
  return payload;
}

/** Drop the fields a type change makes irrelevant so they can't be submitted. */
export function resetForType(form: WorkoutFormState, types: Record<string, WorkoutTypeSpec>): WorkoutFormState {
  const spec = specFor(types, form.workout_type);
  const visible = new Set<string>(visibleFields(spec));
  const source = form as unknown as Record<string, unknown>;
  const next: WorkoutFormState = { workout_type: form.workout_type, category: normalizeCategory(spec, form.category) };
  for (const f of FIELD_ORDER) {
    if (f === 'duration_minutes') continue;
    if (visible.has(f)) (next as unknown as Record<string, unknown>)[f] = source[f];
  }
  next.duration_minutes = form.duration_minutes;
  if (form.notes) next.notes = form.notes;
  return next;
}

/**
 * Taxonomy for the forms. Renders the fallback immediately and swaps in the
 * server copy when the cached request resolves.
 */
export function useWorkoutTypes(): { types: Record<string, WorkoutTypeSpec>; ready: boolean } {
  const [types, setTypes] = useState<Record<string, WorkoutTypeSpec>>(LOCAL_WORKOUT_TYPES);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    let alive = true;
    loadWorkoutTypes()
      .then((t) => { if (alive) { setTypes(t); setReady(true); } })
      .catch(() => { if (alive) setReady(true); });
    return () => { alive = false; };
  }, []);
  return { types, ready };
}