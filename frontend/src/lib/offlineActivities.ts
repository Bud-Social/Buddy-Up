import { analyticsApi } from '@/api/analytics';
import type { ActivityRecordInput } from '@/types/analytics';

/**
 * Durable queue for activities recorded while the device is offline.
 *
 * The server already dedupes on `source_event_id` (unique per user), so a
 * replay is safe: the same activity can be sent twice and only one row is
 * written. The queue keeps the full payload — route points included — on the
 * device until the API accepts it, then removes it.
 *
 * Storage is IndexedDB because an hour-long GPS route is far past the
 * localStorage budget. If IndexedDB is unavailable (private windows in some
 * browsers), the same records fall back to localStorage so a short session is
 * still not lost.
 */

export const ACTIVITY_QUEUE_CHANGED = 'buddyup:activity-queue-changed';
export const ACTIVITY_QUEUE_SYNCED = 'buddyup:activity-queue-synced';

const DB_NAME = 'buddyup-offline';
const DB_VERSION = 1;
const STORE = 'activities';
const FALLBACK_KEY = 'buddyup-offline-activities';

export interface QueuedActivity {
  clientId: string;
  ownerId: string;
  queuedAt: number;
  payload: ActivityRecordInput & { source_event_id: string };
}

export interface FlushResult {
  synced: number;
  failed: number;
  remaining: number;
}

let dbPromise: Promise<IDBDatabase> | null = null;

function openDb(): Promise<IDBDatabase> {
  if (dbPromise) return dbPromise;
  dbPromise = new Promise((resolve, reject) => {
    if (typeof indexedDB === 'undefined') {
      reject(new Error('IndexedDB unavailable'));
      return;
    }
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(STORE)) {
        db.createObjectStore(STORE, { keyPath: 'clientId' });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('Could not open IndexedDB'));
    request.onblocked = () => reject(new Error('IndexedDB blocked'));
  });
  return dbPromise;
}

function readFallback(): QueuedActivity[] {
  try {
    const raw = localStorage.getItem(FALLBACK_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? (parsed as QueuedActivity[]) : [];
  } catch {
    return [];
  }
}

function writeFallback(items: QueuedActivity[]): void {
  try {
    localStorage.setItem(FALLBACK_KEY, JSON.stringify(items));
  } catch {
    // Quota exceeded — nothing else we can do on this device.
  }
}

async function readAll(): Promise<QueuedActivity[]> {
  try {
    const db = await openDb();
    return await new Promise<QueuedActivity[]>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readonly');
      const request = tx.objectStore(STORE).getAll();
      request.onsuccess = () => resolve((request.result as QueuedActivity[]) ?? []);
      request.onerror = () => reject(request.error ?? new Error('Could not read the queue'));
    });
  } catch {
    return readFallback();
  }
}

async function putRecord(record: QueuedActivity): Promise<void> {
  try {
    const db = await openDb();
    await new Promise<void>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).put(record);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error ?? new Error('Could not queue the activity'));
      tx.onabort = () => reject(tx.error ?? new Error('Queue write aborted'));
    });
  } catch {
    const items = readFallback().filter((r) => r.clientId !== record.clientId);
    items.push(record);
    writeFallback(items);
  }
}

async function deleteRecord(clientId: string): Promise<void> {
  try {
    const db = await openDb();
    await new Promise<void>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).delete(clientId);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error ?? new Error('Could not remove the queued activity'));
      tx.onabort = () => reject(tx.error ?? new Error('Queue delete aborted'));
    });
  } catch {
    writeFallback(readFallback().filter((r) => r.clientId !== clientId));
  }
}

function notifyChanged(): void {
  if (typeof window === 'undefined') return;
  window.dispatchEvent(new CustomEvent(ACTIVITY_QUEUE_CHANGED));
}

/** A client-generated id that also de-dupes an offline replay server-side. */
export function newActivityClientId(): string {
  const c = globalThis.crypto as Crypto | undefined;
  if (c?.randomUUID) return c.randomUUID();
  return `act-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

export async function getQueuedActivities(ownerId: string | null): Promise<QueuedActivity[]> {
  if (!ownerId) return [];
  const items = await readAll();
  return items
    .filter((r) => r.ownerId === ownerId)
    .sort((a, b) => a.queuedAt - b.queuedAt);
}

export async function countQueuedActivities(ownerId: string | null): Promise<number> {
  return (await getQueuedActivities(ownerId)).length;
}

/** Persist an activity locally. Returns the record that will be replayed. */
export async function enqueueActivity(
  payload: ActivityRecordInput,
  ownerId: string,
): Promise<QueuedActivity> {
  const clientId = payload.source_event_id ?? newActivityClientId();
  const record: QueuedActivity = {
    clientId,
    ownerId,
    queuedAt: Date.now(),
    payload: { ...payload, source_event_id: clientId },
  };
  await putRecord(record);
  notifyChanged();
  return record;
}

export async function removeQueuedActivity(clientId: string): Promise<void> {
  await deleteRecord(clientId);
  notifyChanged();
}

/**
 * Errors worth retrying: the request never reached a server, the server is
 * unavailable, rate-limited, or auth is temporarily unavailable.
 *
 * A 4xx that is not auth/rate-limit is a payload problem — retrying forever
 * would wedge the queue, so it is dropped and reported as a failure.
 */
export function isRetryableActivityError(error: unknown): boolean {
  const status = (error as { response?: { status?: number } })?.response?.status;
  if (!status) return true;
  if (status >= 500) return true;
  return status === 401 || status === 403 || status === 408 || status === 429;
}

let inFlight: { ownerId: string; promise: Promise<FlushResult> } | null = null;

async function runFlush(ownerId: string): Promise<FlushResult> {
  const pending = await getQueuedActivities(ownerId);
  let synced = 0;
  let failed = 0;

  for (const record of pending) {
    try {
      await analyticsApi.createActivity(record.payload);
      await deleteRecord(record.clientId);
      synced += 1;
    } catch (error) {
      if (isRetryableActivityError(error)) break;
      await deleteRecord(record.clientId);
      failed += 1;
    }
  }

  const remaining = await countQueuedActivities(ownerId);
  if (synced || failed) {
    notifyChanged();
    if (synced && typeof window !== 'undefined') {
      window.dispatchEvent(
        new CustomEvent(ACTIVITY_QUEUE_SYNCED, { detail: { synced, failed } }),
      );
    }
  }
  return { synced, failed, remaining };
}

/** Replay every queued activity for this account, oldest first. */
export function flushActivityQueue(ownerId: string | null): Promise<FlushResult> {
  if (!ownerId) return Promise.resolve({ synced: 0, failed: 0, remaining: 0 });
  if (inFlight) {
    if (inFlight.ownerId === ownerId) return inFlight.promise;
    // A different account is flushing: wait for it, then run ours so one
    // account's session can never consume another's progress.
    return inFlight.promise.then(() => flushActivityQueue(ownerId));
  }
  const promise = runFlush(ownerId).finally(() => {
    inFlight = null;
  });
  inFlight = { ownerId, promise };
  return promise;
}
