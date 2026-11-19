import { beforeEach, describe, expect, it, vi } from 'vitest';

const createActivity = vi.fn();

vi.mock('@/api/analytics', () => ({
  analyticsApi: { createActivity: (...args: unknown[]) => createActivity(...args) },
}));

import {
  countQueuedActivities,
  enqueueActivity,
  flushActivityQueue,
  getQueuedActivities,
  removeQueuedActivity,
} from '@/lib/offlineActivities';
import type { ActivityRecordInput } from '@/types/analytics';

const payload: ActivityRecordInput = {
  activity_type: 'run',
  duration_seconds: 1800,
  distance_meters: 5000,
  route: [[-1.29, 36.82, 1], [-1.28, 36.83, 2]],
};

describe('offline activity queue', () => {
  beforeEach(() => {
    localStorage.clear();
    createActivity.mockReset();
  });

  it('keeps the full payload, including route points, and adds an idempotency key', async () => {
    const record = await enqueueActivity(payload, 'user-1');

    expect(record.payload.source_event_id).toBe(record.clientId);
    expect(record.payload.route).toEqual(payload.route);

    const stored = await getQueuedActivities('user-1');
    expect(stored).toHaveLength(1);
    expect(stored[0].payload.route).toEqual(payload.route);
  });

  it('scopes pending work to the signed-in account', async () => {
    await enqueueActivity(payload, 'user-1');
    await enqueueActivity(payload, 'user-2');

    expect(await countQueuedActivities('user-1')).toBe(1);
    expect(await countQueuedActivities('user-2')).toBe(1);

    createActivity.mockResolvedValue({ success: true, data: { id: 'remote-1' } });
    const result = await flushActivityQueue('user-1');

    expect(result.synced).toBe(1);
    expect(result.remaining).toBe(0);
    expect(await countQueuedActivities('user-2')).toBe(1);
  });

  it('replays a queued session and removes it once accepted', async () => {
    const record = await enqueueActivity(payload, 'user-1');
    createActivity.mockResolvedValue({ success: true, data: { id: 'remote-1' } });

    const result = await flushActivityQueue('user-1');

    expect(result).toEqual({ synced: 1, failed: 0, remaining: 0 });
    expect(createActivity).toHaveBeenCalledWith(record.payload);
    expect(await countQueuedActivities('user-1')).toBe(0);
  });

  it('keeps the session when the network is still down', async () => {
    await enqueueActivity(payload, 'user-1');
    createActivity.mockRejectedValue(new Error('Network Error'));

    const result = await flushActivityQueue('user-1');

    expect(result.synced).toBe(0);
    expect(result.remaining).toBe(1);
    expect(await countQueuedActivities('user-1')).toBe(1);
  });

  it('keeps the session when auth is temporarily unavailable', async () => {
    await enqueueActivity(payload, 'user-1');
    createActivity.mockRejectedValue({ response: { status: 401 } });

    const result = await flushActivityQueue('user-1');

    expect(result.synced).toBe(0);
    expect(result.remaining).toBe(1);
  });

  it('drops a payload the server will never accept, so the queue cannot wedge', async () => {
    await enqueueActivity(payload, 'user-1');
    createActivity.mockRejectedValue({ response: { status: 400 } });

    const result = await flushActivityQueue('user-1');

    expect(result.failed).toBe(1);
    expect(result.remaining).toBe(0);
  });

  it('can remove a queued session before it syncs', async () => {
    const record = await enqueueActivity(payload, 'user-1');
    await removeQueuedActivity(record.clientId);

    expect(await countQueuedActivities('user-1')).toBe(0);
  });
});
