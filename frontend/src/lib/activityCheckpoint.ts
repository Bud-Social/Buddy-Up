/**
 * Live activity checkpoint.
 *
 * A browser tab can be closed, crash, or be evicted while a session is
 * running — and on mobile the OS may freeze a background tab and never
 * resume it. The tracker therefore writes its live state to `localStorage`
 * every few seconds and whenever the page is hidden, so the session can be
 * resumed exactly where it stopped instead of being lost.
 *
 * Checkpoints are scoped by owner id: a shared device cannot hand one
 * account's route to the next person who signs in. Stale checkpoints expire
 * after half a day so an abandoned walk never resurfaces weeks later.
 */

export type CheckpointActivityType = 'walk' | 'run' | 'hike' | 'cycle';

export interface ActivityCheckpointPoint {
  lat: number;
  lng: number;
  ts: number;
}

export interface ActivityCheckpoint {
  version: 1;
  ownerId: string;
  type: CheckpointActivityType;
  /** ISO timestamp of when the session began. */
  startedAt: string;
  elapsed: number;
  distanceM: number;
  steps: number;
  points: ActivityCheckpointPoint[];
  /** Epoch milliseconds of the last write. */
  lastUpdated: number;
}

export const ACTIVITY_CHECKPOINT_KEY = 'buddyup.activity.checkpoint.v1';

/** Half a day: long enough to resume after a dead battery, short enough to expire. */
export const CHECKPOINT_MAX_AGE_MS = 12 * 60 * 60 * 1000;

/** Keep the persisted route bounded — a 5MB localStorage quota is shared. */
export const CHECKPOINT_MAX_POINTS = 20_000;

const TYPES: CheckpointActivityType[] = ['walk', 'run', 'hike', 'cycle'];

function storage(): Storage | null {
  if (typeof window === 'undefined') return null;
  try {
    return window.localStorage;
  } catch {
    // Safari private mode and hardened browsers can throw on access.
    return null;
  }
}

function isPoint(value: unknown): value is ActivityCheckpointPoint {
  if (!value || typeof value !== 'object') return false;
  const p = value as Partial<ActivityCheckpointPoint>;
  return Number.isFinite(p.lat) && Number.isFinite(p.lng) && Number.isFinite(p.ts);
}

/** Validate untrusted storage before it reaches the tracker. */
function parse(raw: string): ActivityCheckpoint | null {
  try {
    const value = JSON.parse(raw) as Partial<ActivityCheckpoint> | null;
    if (!value || value.version !== 1) return null;
    if (typeof value.ownerId !== 'string' || !value.ownerId) return null;
    if (!TYPES.includes(value.type as CheckpointActivityType)) return null;
    if (typeof value.startedAt !== 'string') return null;
    const elapsed = Number(value.elapsed);
    const distanceM = Number(value.distanceM);
    const steps = Number(value.steps);
    const lastUpdated = Number(value.lastUpdated);
    if (![elapsed, distanceM, steps, lastUpdated].every(Number.isFinite)) return null;
    const points = Array.isArray(value.points) ? value.points.filter(isPoint) : [];
    return {
      version: 1,
      ownerId: value.ownerId,
      type: value.type as CheckpointActivityType,
      startedAt: value.startedAt,
      elapsed: Math.max(0, Math.round(elapsed)),
      distanceM: Math.max(0, Math.round(distanceM)),
      steps: Math.max(0, Math.round(steps)),
      points,
      lastUpdated,
    };
  } catch {
    return null;
  }
}

/** Write the live session. Never throws — storage may be full or denied. */
export function saveActivityCheckpoint(checkpoint: ActivityCheckpoint): void {
  const store = storage();
  if (!store) return;
  const points = checkpoint.points.length > CHECKPOINT_MAX_POINTS
    ? checkpoint.points.slice(-CHECKPOINT_MAX_POINTS)
    : checkpoint.points;
  try {
    store.setItem(ACTIVITY_CHECKPOINT_KEY, JSON.stringify({
      ...checkpoint,
      points,
      lastUpdated: Date.now(),
    }));
  } catch {
    // Quota exceeded or storage disabled: the in-memory session still works.
  }
}

/**
 * Read this owner's checkpoint. A checkpoint belonging to another account,
 * or one older than {@link CHECKPOINT_MAX_AGE_MS}, is ignored (and cleaned
 * up) rather than offered for resume.
 */
export function loadActivityCheckpoint(
  ownerId: string | null | undefined,
  now: number = Date.now(),
): ActivityCheckpoint | null {
  if (!ownerId) return null;
  const store = storage();
  if (!store) return null;
  let raw: string | null = null;
  try {
    raw = store.getItem(ACTIVITY_CHECKPOINT_KEY);
  } catch {
    return null;
  }
  if (!raw) return null;
  const checkpoint = parse(raw);
  if (!checkpoint) {
    clearActivityCheckpoint();
    return null;
  }
  if (checkpoint.ownerId !== ownerId) return null;
  if (now - checkpoint.lastUpdated > CHECKPOINT_MAX_AGE_MS) {
    clearActivityCheckpoint(ownerId);
    return null;
  }
  return checkpoint;
}

/**
 * Drop the checkpoint. Passing an owner id only removes it when it belongs
 * to that owner, so signing out never deletes someone else's live session.
 */
export function clearActivityCheckpoint(ownerId?: string | null): void {
  const store = storage();
  if (!store) return;
  try {
    if (ownerId) {
      const existing = store.getItem(ACTIVITY_CHECKPOINT_KEY);
      if (existing) {
        const checkpoint = parse(existing);
        if (checkpoint && checkpoint.ownerId !== ownerId) return;
      }
    }
    store.removeItem(ACTIVITY_CHECKPOINT_KEY);
  } catch {
    // Nothing to do — a leftover checkpoint will expire on its own.
  }
}

/** Human-friendly "saved 2 min ago" for the resume prompt. */
export function checkpointAgeLabel(checkpoint: ActivityCheckpoint, now: number = Date.now()): string {
  const seconds = Math.max(0, Math.round((now - checkpoint.lastUpdated) / 1000));
  if (seconds < 60) return 'just now';
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.round(minutes / 60);
  return `${hours} hr ago`;
}
