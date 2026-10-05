import { describe, it, expect } from 'vitest';
import {
  LOCAL_WORKOUT_TYPES,
  buildWorkoutPayload,
  hasField,
  measuredNotice,
  mergeWorkoutTypes,
  normalizeCategory,
  resetForType,
  specFor,
  typeOrder,
  visibleFields,
  withDuration,
  type WorkoutFormState,
} from '../workoutTypes';
import { WORKOUT_TYPE_KEYS } from '@/types/analytics';

const TYPES = LOCAL_WORKOUT_TYPES;
const fieldsOf = (key: string) => visibleFields(specFor(TYPES, key));

describe('local fallback catalogue', () => {
  it('covers exactly the backend type list, in order', () => {
    // Guards sync with PART 1 of the backend workout-types task.
    expect(Object.keys(LOCAL_WORKOUT_TYPES)).toEqual([...WORKOUT_TYPE_KEYS]);
  });

  it('gives every type a duration field and a label', () => {
    for (const key of WORKOUT_TYPE_KEYS) {
      const spec = specFor(TYPES, key);
      expect(spec.label).toBeTruthy();
      expect(spec.fields).toContain('duration_minutes');
    }
  });

  it('leaves cardio, the distance sports and the described types with no categories', () => {
    for (const key of ['cardio', 'running', 'walking', 'cycling', 'swimming', 'climbing', 'rowing',
      'dance', 'boxing', 'martial_arts', 'other']) {
      expect(specFor(TYPES, key).categories).toEqual([]);
    }
  });

  it('mirrors the taxonomy category lists exactly', () => {
    const keys = (k: string) => specFor(TYPES, k).categories.map((c) => c.key);
    expect(keys('strength')).toEqual(['upper', 'lower', 'push', 'pull', 'legs', 'arms', 'core', 'full']);
    expect(keys('hiit')).toEqual(['full', 'upper', 'lower', 'core', 'cardio']);
    expect(keys('yoga')).toEqual(['flexibility', 'mobility', 'balance', 'strength', 'mindfulness']);
    expect(keys('pilates')).toEqual(['core', 'posture', 'flexibility', 'mobility', 'full']);
    expect(keys('mobility')).toEqual(['hips', 'shoulders', 'spine', 'ankles', 'full']);
    expect(keys('sport')).toEqual(['football', 'basketball', 'tennis', 'cricket', 'rugby', 'netball', 'volleyball', 'other']);
  });

  it('labels every category the way the backend does', () => {
    expect(specFor(TYPES, 'yoga').categories.find((c) => c.key === 'mindfulness')?.label).toBe('Mindfulness');
    expect(specFor(TYPES, 'sport').categories.find((c) => c.key === 'other')?.label).toBe('Other');
  });
});

describe('per-type field visibility', () => {
  it('shows sets, reps and weight for strength', () => {
    expect(fieldsOf('strength')).toEqual(['sets', 'reps', 'weight_kg', 'duration_minutes']);
    expect(specFor(TYPES, 'strength').measured).toBe(true);
    // The taxonomy declares no exercise field for strength.
    expect(hasField(specFor(TYPES, 'strength'), 'exercise')).toBe(false);
  });

  it('shows rounds for hiit and distance for cardio', () => {
    expect(fieldsOf('hiit')).toEqual(['rounds', 'duration_minutes']);
    expect(fieldsOf('cardio')).toEqual(['distance_km', 'calories_burned', 'duration_minutes']);
    // Cardio is measured — by distance and calories, not by reps.
    expect(specFor(TYPES, 'cardio').measured).toBe(true);
  });

  it('shows distance and calories for every GPS distance sport', () => {
    for (const key of ['running', 'walking', 'cycling', 'swimming']) {
      expect(hasField(specFor(TYPES, key), 'distance_km')).toBe(true);
      expect(hasField(specFor(TYPES, key), 'calories_burned')).toBe(true);
    }
    // Rowing and climbing carry no measured fields in the taxonomy.
    expect(fieldsOf('rowing')).toEqual(['duration_minutes']);
    expect(fieldsOf('climbing')).toEqual(['duration_minutes']);
  });

  it('gives yoga and pilates a style and never sets/reps/weight', () => {
    for (const key of ['yoga', 'pilates']) {
      const spec = specFor(TYPES, key);
      expect(visibleFields(spec)).toEqual(['style', 'duration_minutes']);
      expect(hasField(spec, 'sets')).toBe(false);
      expect(hasField(spec, 'reps')).toBe(false);
      expect(hasField(spec, 'weight_kg')).toBe(false);
      expect(hasField(spec, 'exercise')).toBe(false);
    }
  });

  it('gives mobility a focus, sport a sport and the combat types a style', () => {
    expect(fieldsOf('mobility')).toEqual(['focus', 'duration_minutes']);
    expect(fieldsOf('sport')).toEqual(['sport', 'duration_minutes']);
    for (const key of ['boxing', 'martial_arts']) {
      expect(fieldsOf(key)).toEqual(['style', 'duration_minutes']);
    }
    expect(fieldsOf('dance')).toEqual(['duration_minutes']);
    expect(fieldsOf('other')).toEqual(['duration_minutes']);
  });

  it('always keeps duration, even when a spec omits it', () => {
    expect(withDuration([])).toEqual(['duration_minutes']);
    expect(fieldsOf('climbing')).toEqual(['duration_minutes']);
  });
});

describe('normalizeCategory', () => {
  it('rejects a category that belongs to another type', () => {
    // 'upper' is a strength category; sending it on a yoga log is a 400.
    expect(normalizeCategory(specFor(TYPES, 'strength'), 'upper')).toBe('upper');
    expect(normalizeCategory(specFor(TYPES, 'yoga'), 'upper')).toBe('');
    expect(normalizeCategory(specFor(TYPES, 'yoga'), 'balance')).toBe('balance');
    // 'strength' is a yoga category but not a valid *workout type* list member
    // of hiit's — each type validates independently.
    expect(normalizeCategory(specFor(TYPES, 'hiit'), 'cardio')).toBe('cardio');
    expect(normalizeCategory(specFor(TYPES, 'hiit'), 'balance')).toBe('');
  });

  it('collapses to empty for types with no categories at all', () => {
    expect(normalizeCategory(specFor(TYPES, 'running'), '')).toBe('');
    expect(normalizeCategory(specFor(TYPES, 'running'), 'full')).toBe('');
  });
});

describe('buildWorkoutPayload', () => {
  it('never sends a stale rep count on a yoga log', () => {
    const form: WorkoutFormState = {
      workout_type: 'yoga',
      category: 'balance',
      exercise: 'Sun salutation',
      sets: 4,
      reps: 12,
      weight_kg: 40,
      duration_minutes: 45,
    };
    const payload = buildWorkoutPayload(form, TYPES);
    expect(payload).toEqual({ workout_type: 'yoga', category: 'balance', duration_minutes: 45 });
    expect(payload).not.toHaveProperty('reps');
    expect(payload).not.toHaveProperty('sets');
    expect(payload).not.toHaveProperty('weight_kg');
    expect(payload).not.toHaveProperty('exercise');
  });

  it('keeps strength numbers and converts distance km to meters', () => {
    const payload = buildWorkoutPayload({
      workout_type: 'strength',
      category: 'lower',
      sets: 4,
      reps: 8,
      weight_kg: 60,
      duration_minutes: 45,
    }, TYPES);
    expect(payload).toEqual({
      workout_type: 'strength', category: 'lower', sets: 4, reps: 8, weight_kg: 60, duration_minutes: 45,
    });

    const run = buildWorkoutPayload({
      workout_type: 'running', category: 'upper', distance_km: 5.25, calories_burned: 400, duration_minutes: 30,
    }, TYPES);
    expect(run).toEqual({
      workout_type: 'running', category: '', distance_meters: 5250,
      calories_burned: 400, duration_minutes: 30,
    });
  });

  it('passes the type-specific extras through top-level', () => {
    expect(buildWorkoutPayload({ workout_type: 'hiit', category: 'full', rounds: 8, duration_minutes: 20 }, TYPES))
      .toEqual({ workout_type: 'hiit', category: 'full', rounds: 8, duration_minutes: 20 });
    expect(buildWorkoutPayload({ workout_type: 'mobility', focus: 'Hips', duration_minutes: 15 }, TYPES))
      .toEqual({ workout_type: 'mobility', category: '', focus: 'Hips', duration_minutes: 15 });
    expect(buildWorkoutPayload({ workout_type: 'sport', category: 'tennis', sport: 'Doubles', duration_minutes: 60 }, TYPES))
      .toEqual({ workout_type: 'sport', category: 'tennis', sport: 'Doubles', duration_minutes: 60 });
    expect(buildWorkoutPayload({ workout_type: 'boxing', category: 'shadow', style: 'Sparring', duration_minutes: 25 }, TYPES))
      .toEqual({ workout_type: 'boxing', category: '', style: 'Sparring', duration_minutes: 25 });
  });

  it('drops a distance that is not positive', () => {
    const payload = buildWorkoutPayload({ workout_type: 'swimming', distance_km: 0, duration_minutes: 40 }, TYPES);
    expect(payload).not.toHaveProperty('distance_meters');
  });
});

describe('resetForType', () => {
  it('clears the fields the new type cannot record', () => {
    const after = resetForType({
      workout_type: 'yoga', category: 'balance', sets: 4, reps: 10, weight_kg: 50, duration_minutes: 60,
    }, TYPES);
    expect(after).toEqual({ workout_type: 'yoga', category: 'balance', duration_minutes: 60 });
  });

  it('keeps shared fields across a type switch', () => {
    const after = resetForType({ workout_type: 'running', duration_minutes: 30, distance_km: 5 }, TYPES);
    expect(after).toEqual({ workout_type: 'running', category: '', distance_km: 5, duration_minutes: 30 });
  });

  it('normalises a category the new type does not allow', () => {
    expect(resetForType({ workout_type: 'running', category: 'upper' }, TYPES).category).toBe('');
  });
});

describe('measuredNotice', () => {
  it('stays quiet for measured types and explains the described ones', () => {
    expect(measuredNotice(specFor(TYPES, 'strength'))).toBeNull();
    expect(measuredNotice(specFor(TYPES, 'hiit'))).toBeNull();
    // Distance sports are measured — no notice needed on a run.
    expect(measuredNotice(specFor(TYPES, 'running'))).toBeNull();

    expect(measuredNotice(specFor(TYPES, 'yoga'))).toContain("Yoga isn't tracked in sets or reps");
    expect(measuredNotice(specFor(TYPES, 'yoga'))).toContain('style');
    expect(measuredNotice(specFor(TYPES, 'mobility'))).toContain('focus');
    expect(measuredNotice(specFor(TYPES, 'rowing'))).toBe("Rowing isn't tracked in sets or reps. Log the time.");
  });
});

describe('mergeWorkoutTypes', () => {
  it('reads the taxonomy envelope the endpoint actually returns', () => {
    const merged = mergeWorkoutTypes({
      workout_types: { strength: { label: 'Weights', categories: ['gym'], fields: ['sets', 'reps'], measured: true } },
      categories: ['gym'],
    });
    expect(merged.strength.label).toBe('Weights');
    expect(merged.strength.categories).toEqual([{ key: 'gym', label: 'Gym' }]);
    expect(visibleFields(merged.strength)).toEqual(['sets', 'reps', 'duration_minutes']);
  });

  it('maps the taxonomy distance_meters field onto the km form field', () => {
    const merged = mergeWorkoutTypes({
      workout_types: { running: { label: 'Running', categories: [], fields: ['distance_meters', 'calories_burned'], measured: true } },
    });
    expect(visibleFields(merged.running)).toEqual(['distance_km', 'calories_burned', 'duration_minutes']);
  });

  it('accepts the `{ types: ... }` alias too', () => {
    const merged = mergeWorkoutTypes({ types: { other: { label: 'Something else', categories: [], fields: [], measured: false } } });
    expect(merged.other.label).toBe('Something else');
  });

  it('honours an empty category list as "this type has none"', () => {
    const merged = mergeWorkoutTypes({ workout_types: { yoga: { label: 'Yoga', categories: [], fields: ['style'], measured: false } } });
    expect(merged.yoga.categories).toEqual([]);
    expect(buildWorkoutPayload({ workout_type: 'yoga', category: 'balance', duration_minutes: 30 }, merged).category).toBe('');
  });

  it('falls back to local fields when the server sends an empty list', () => {
    const merged = mergeWorkoutTypes({ workout_types: { strength: { label: 'Strength', categories: [], fields: [], measured: true } } });
    expect(visibleFields(merged.strength)).toEqual(['sets', 'reps', 'weight_kg', 'duration_minutes']);
  });

  it('maps every taxonomy field name it recognises', () => {
    const merged = mergeWorkoutTypes({
      workout_types: { hiit: { label: 'HIIT', categories: [], fields: ['rounds', 'style', 'distance_meters'], measured: true } },
    });
    expect(visibleFields(merged.hiit)).toEqual(['rounds', 'distance_km', 'style', 'duration_minutes']);
  });

  it('adds server-only types and keeps the canonical order', () => {
    const merged = mergeWorkoutTypes({ workout_types: { breathwork: { label: 'Breathwork', categories: [], fields: [], measured: false } } });
    const order = typeOrder(merged);
    expect(order[0]).toBe('strength');
    expect(order).toContain('breathwork');
    expect(order.indexOf('breathwork')).toBe(order.length - 1);
  });

  it('survives a junk payload', () => {
    expect(mergeWorkoutTypes(null).strength.label).toBe('Strength');
    expect(mergeWorkoutTypes({ workout_types: { strength: 'nope' } }).strength.label).toBe('Strength');
  });
});