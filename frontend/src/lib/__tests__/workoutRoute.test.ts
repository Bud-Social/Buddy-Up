import { describe, expect, it } from 'vitest';
import {
  extractWorkoutRoute,
  hasWorkoutRoute,
  projectRoute,
  routeSvgPath,
} from '../workoutRoute';

describe('extractWorkoutRoute', () => {
  it('reads [lat, lng, ts] triples', () => {
    const route = extractWorkoutRoute({
      route: [[-1.29, 36.82, 1_700_000_000_000], [-1.295, 36.825, 1_700_000_010_000]],
    });
    expect(route).toEqual([
      { lat: -1.29, lng: 36.82 },
      { lat: -1.295, lng: 36.825 },
    ]);
  });

  it('drops malformed points instead of failing the card', () => {
    expect(extractWorkoutRoute({
      route: [null, ['x', 'y'], [1], [-1.3, 36.8], { lat: 1 }],
    })).toEqual([{ lat: -1.3, lng: 36.8 }]);
  });

  it('rejects out-of-range coordinates and missing payloads', () => {
    expect(extractWorkoutRoute({ route: [[200, 36.8]] })).toEqual([]);
    expect(extractWorkoutRoute(null)).toEqual([]);
    expect(hasWorkoutRoute({ route: [[-1.3, 36.8]] })).toBe(true);
    expect(hasWorkoutRoute({ route: [] })).toBe(false);
  });
});

describe('projectRoute', () => {
  const route = [
    { lat: -1.300, lng: 36.800 },
    { lat: -1.300, lng: 36.802 }, // east
    { lat: -1.302, lng: 36.802 }, // south
  ];

  it('keeps every point inside the box and keeps order', () => {
    const { points } = projectRoute(route, 400, 200, 20);
    expect(points).toHaveLength(3);
    for (const p of points) {
      expect(p.x).toBeGreaterThanOrEqual(20);
      expect(p.x).toBeLessThanOrEqual(380);
      expect(p.y).toBeGreaterThanOrEqual(20);
      expect(p.y).toBeLessThanOrEqual(180);
    }
    // East is right, south is down.
    expect(points[1].x).toBeGreaterThan(points[0].x);
    expect(points[2].y).toBeGreaterThan(points[1].y);
  });

  it('centres a stationary session as a single pin', () => {
    const { points, isPoint } = projectRoute([{ lat: -1.3, lng: 36.8 }], 400, 200, 20);
    expect(isPoint).toBe(true);
    expect(points[0]).toEqual({ x: 200, y: 100 });
  });

  it('builds a path string with one move and the rest lines', () => {
    const path = routeSvgPath(route, 400, 200, 20);
    expect(path.startsWith('M')).toBe(true);
    expect(path.match(/L/g)).toHaveLength(2);
  });

  it('returns nothing for an empty route', () => {
    expect(projectRoute([], 400, 200).points).toEqual([]);
    expect(routeSvgPath([], 400, 200)).toBe('');
  });
});
