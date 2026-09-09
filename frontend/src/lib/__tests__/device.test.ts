import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { getDeviceId } from '@/lib/device';

const DEVICE_ID_KEY = 'bu_device_id';

describe('getDeviceId', () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  afterEach(() => {
    window.localStorage.clear();
  });

  it('creates and persists a UUID-shaped id on first call', () => {
    const id = getDeviceId();
    expect(id).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i);
    expect(window.localStorage.getItem(DEVICE_ID_KEY)).toBe(id);
  });

  it('is stable across calls (same id returned)', () => {
    const first = getDeviceId();
    expect(getDeviceId()).toBe(first);
  });

  it('returns the stored id instead of generating a new one', () => {
    window.localStorage.setItem(DEVICE_ID_KEY, 'existing-id');
    expect(getDeviceId()).toBe('existing-id');
  });
});
