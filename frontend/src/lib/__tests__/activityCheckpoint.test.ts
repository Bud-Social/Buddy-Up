import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  ACTIVITY_CHECKPOINT_KEY,
  CHECKPOINT_MAX_AGE_MS,
  CHECKPOINT_MAX_POINTS,
  checkpointAgeLabel,
  clearActivityCheckpoint,
  loadActivityCheckpoint,
  saveActivityCheckpoint,
  type ActivityCheckpoint,
} from '../activityCheckpoint';

/**
 * A session that survives a dead tab has to be trustworthy: scoped to the
 * account that recorded it, expiring so an abandoned walk cannot resurface
 * weeks later, and never throwing when storage is unavailable.
 */

function checkpoint(overrides: Partial<ActivityCheckpoint> = {}): ActivityCheckpoint {
  return {
    version: 1,
    ownerId: 'user-a',
    type: 'run',
    startedAt: '2026-11-20T06:00:00.000Z',
    elapsed: 754,
    distanceM: 2410,
    steps: 0,
    points: [
      { lat: -1.2921, lng: 36.8219, ts: 1_700_000_000_000 },
      { lat: -1.2925, lng: 36.8224, ts: 1_700_000_010_000 },
    ],
    lastUpdated: 1_700_000_010_000,
    ...overrides,
  };
}

describe('activity checkpoint', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('round-trips the live session including the route', () => {
    saveActivityCheckpoint(checkpoint());
    const loaded = loadActivityCheckpoint('user-a');
    expect(loaded).not.toBeNull();
    expect(loaded?.elapsed).toBe(754);
    expect(loaded?.distanceM).toBe(2410);
    expect(loaded?.points).toHaveLength(2);
    expect(loaded?.points[1]).toEqual({ lat: -1.2925, lng: 36.8224, ts: 1_700_000_010_000 });
  });

  it('never offers another account the previous account\'s route', () => {
    saveActivityCheckpoint(checkpoint({ ownerId: 'user-a' }));
    expect(loadActivityCheckpoint('user-b')).toBeNull();
    expect(loadActivityCheckpoint('user-a')).not.toBeNull();
  });

  it('expires a checkpoint after half a day', () => {
    saveActivityCheckpoint(checkpoint());
    const fresh = loadActivityCheckpoint('user-a');
    expect(fresh).not.toBeNull();
    const stale = loadActivityCheckpoint('user-a', Date.now() + CHECKPOINT_MAX_AGE_MS + 1);
    expect(stale).toBeNull();
    // Expiry removes the stale entry rather than leaving it for next time.
    expect(localStorage.getItem(ACTIVITY_CHECKPOINT_KEY)).toBeNull();
  });

  it('clearing only removes a checkpoint owned by the caller', () => {
    saveActivityCheckpoint(checkpoint({ ownerId: 'user-a' }));
    clearActivityCheckpoint('user-b');
    expect(loadActivityCheckpoint('user-a')).not.toBeNull();
    clearActivityCheckpoint('user-a');
    expect(localStorage.getItem(ACTIVITY_CHECKPOINT_KEY)).toBeNull();
  });

  it('caps the persisted route so large sessions fit in storage', () => {
    const points = Array.from({ length: CHECKPOINT_MAX_POINTS + 25 }, (_, i) => ({
      lat: -1.29 + i / 100_000,
      lng: 36.82,
      ts: i,
    }));
    saveActivityCheckpoint(checkpoint({ points }));
    const loaded = loadActivityCheckpoint('user-a');
    expect(loaded?.points).toHaveLength(CHECKPOINT_MAX_POINTS);
    // The newest points are the ones kept.
    expect(loaded?.points.at(-1)?.ts).toBe(CHECKPOINT_MAX_POINTS + 24);
  });

  it('ignores corrupt storage', () => {
    localStorage.setItem(ACTIVITY_CHECKPOINT_KEY, '{not json');
    expect(loadActivityCheckpoint('user-a')).toBeNull();
    expect(localStorage.getItem(ACTIVITY_CHECKPOINT_KEY)).toBeNull();
  });

  it('labels how long ago the session was checkpointed', () => {
    const cp = checkpoint({ lastUpdated: 1_000_000 });
    expect(checkpointAgeLabel(cp, 1_000_000)).toBe('just now');
    expect(checkpointAgeLabel(cp, 1_000_000 + 120_000)).toBe('2 min ago');
    expect(checkpointAgeLabel(cp, 1_000_000 + 2 * 60 * 60 * 1000)).toBe('2 hr ago');
  });

  it('does not throw when storage refuses writes', () => {
    const spy = vi.spyOn(Storage.prototype, 'setItem').mockImplementation(() => {
      throw new Error('QuotaExceededError');
    });
    expect(() => saveActivityCheckpoint(checkpoint())).not.toThrow();
    spy.mockRestore();
  });
});
