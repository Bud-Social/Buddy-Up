import { describe, expect, it } from 'vitest';
import { parseWorkoutMetrics } from '../workoutMetrics';

describe('parseWorkoutMetrics', () => {
  it('reads the flat exercise log shape', () => {
    const parsed = parseWorkoutMetrics({
      exercise: 'OHP',
      sets: 4,
      reps: 8,
      weight_kg: 91.9,
      calories: 320,
      source: 'workout_share',
    });
    expect(parsed).not.toBeNull();
    expect(parsed!.title).toBe('OHP');
    expect(parsed!.metrics).toEqual([
      { label: 'Sets', value: '4', tone: 'green' },
      { label: 'Reps', value: '8', tone: 'green' },
      { label: 'kg', value: '91.9', tone: 'orange' },
    ]);
  });

  it('reads the exercises-list shape used by seeded posts', () => {
    const parsed = parseWorkoutMetrics({
      exercises: [{ name: 'OHP', reps: 8, sets: 4, weight: 91.9 }],
    });
    expect(parsed).not.toBeNull();
    expect(parsed!.title).toBe('OHP');
    expect(parsed!.metrics.map((m) => m.label)).toEqual(['Sets', 'Reps', 'kg']);
    expect(parsed!.metrics[2].value).toBe('91.9');
  });

  it('summarises multiple exercises in the title', () => {
    const parsed = parseWorkoutMetrics({
      exercises: [
        { name: 'Squat', reps: 5, sets: 3, weight: 100 },
        { name: 'Row', reps: 10, sets: 3, weight: 60 },
      ],
    });
    expect(parsed!.title).toBe('Squat +1 more');
    expect(parsed!.metrics).toHaveLength(3);
  });

  it('reads the activity shape', () => {
    const parsed = parseWorkoutMetrics({
      activity_type: 'run',
      distance_km: 5.2,
      duration_minutes: 30,
      calories: 410,
      steps: 6200,
    });
    expect(parsed!.title).toBe('run');
    expect(parsed!.metrics.map((m) => m.label)).toEqual(['km', 'min', 'Cal']);
  });

  it('returns null when there is nothing to show', () => {
    expect(parseWorkoutMetrics(null)).toBeNull();
    expect(parseWorkoutMetrics(undefined)).toBeNull();
    expect(parseWorkoutMetrics({})).toBeNull();
    expect(parseWorkoutMetrics({ exercises: [] })).toBeNull();
  });
});
