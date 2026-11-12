import { describe, it, expect } from 'vitest';
import {
  activityLabel, activityMetrics, formatDurationShort, formatKm, formatPace,
} from '../activityMetrics';

describe('activityMetrics', () => {
  it('leads with the steps for a walk', () => {
    const metrics = activityMetrics({
      activity_type: 'walk',
      steps: 6200,
      distance_meters: 4800,
      duration_seconds: 2700,
      avg_pace: 560,
    });
    expect(metrics.map((m) => m.label)).toEqual(['Steps', 'Distance', 'Pace', 'Time']);
    expect(metrics[0].value).toBe('6200');
    expect(metrics[1].value).toBe('4.8 km');
    expect(metrics[2].value).toBe('9:20');
  });

  it('leads with the pace for a run', () => {
    const metrics = activityMetrics({
      activity_type: 'run',
      distance_meters: 5000,
      duration_seconds: 1500,
      avg_pace: 300,
      avg_speed_kmh: 12,
      calories_burned: 320,
    });
    expect(metrics.map((m) => m.label)).toEqual(['Pace', 'Speed', 'Distance', 'Cal']);
    expect(metrics[0].value).toBe('5:00');
    expect(metrics[1].value).toBe('12 km/h');
    expect(metrics[3].value).toBe('320');
  });

  it('leads with the climb for a hike', () => {
    const metrics = activityMetrics({
      activity_type: 'hike',
      distance_meters: 8200,
      duration_seconds: 9000,
      elevation_gain_m: 460,
      avg_pace: 1098,
    });
    expect(metrics.map((m) => m.label)).toEqual(['Ascent', 'Distance', 'Pace', 'Time']);
    expect(metrics[0].value).toBe('460 m');
  });

  it('leads with the speed for a cycle', () => {
    const metrics = activityMetrics({
      activity_type: 'cycle',
      distance_meters: 24000,
      duration_seconds: 3600,
      avg_speed_kmh: 24,
      calories_burned: 720,
    });
    expect(metrics.map((m) => m.label)).toEqual(['Speed', 'Distance', 'Cal', 'Time']);
    expect(metrics[0].value).toBe('24 km/h');
  });

  it('derives the pace when the tracker did not record one', () => {
    const metrics = activityMetrics({
      activity_type: 'run',
      distance_meters: 2000,
      duration_seconds: 600,
    });
    const pace = metrics.find((m) => m.label === 'Pace');
    expect(pace?.value).toBe('5:00');
  });

  it('drops the metrics that have no value', () => {
    const metrics = activityMetrics({
      activity_type: 'run',
      distance_meters: 0,
      duration_seconds: 0,
    });
    expect(metrics).toEqual([]);
  });

  it('never shows more than the limit', () => {
    const metrics = activityMetrics({
      activity_type: 'run',
      distance_meters: 5000,
      duration_seconds: 1500,
      avg_pace: 300,
      avg_speed_kmh: 12,
      calories_burned: 320,
    }, 2);
    expect(metrics).toHaveLength(2);
  });
});

describe('formatters', () => {
  it('formats a distance', () => {
    expect(formatKm(4820)).toBe('4.8 km');
    expect(formatKm(0)).toBeNull();
    expect(formatKm(null)).toBeNull();
  });

  it('formats a duration', () => {
    expect(formatDurationShort(2700)).toBe('45m');
    expect(formatDurationShort(3900)).toBe('1h 05m');
    expect(formatDurationShort(9)).toBe('9s');
    expect(formatDurationShort(0)).toBeNull();
  });

  it('formats a pace', () => {
    expect(formatPace(300)).toBe('5:00');
    expect(formatPace(590)).toBe('9:50');
    expect(formatPace(0)).toBeNull();
  });
});

describe('activityLabel', () => {
  it('names each kind', () => {
    expect(activityLabel('walk')).toBe('Walking');
    expect(activityLabel('hike')).toBe('Hiking');
    expect(activityLabel('nonsense')).toBe('Activity');
  });
});
