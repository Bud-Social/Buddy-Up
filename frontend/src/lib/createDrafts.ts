/**
 * Local draft persistence for the create studio (IndexedDB, no deps).
 *
 * One record under key 'studio-draft' holds the whole in-progress creation:
 * caption/meta plus the picked media as Blobs so editing survives a refresh.
 * Everything degrades to an in-memory fallback when IndexedDB is missing or
 * fails (private mode, quota, jsdom) — callers never see a throw.
 */

export const DRAFT_KEY = 'studio-draft';
const DB_NAME = 'buddyup-create-drafts';
const STORE_NAME = 'drafts';

export interface DraftSound {
  id: string;
  name: string;
  artist: string;
  volume: number;
}

export interface DraftMediaItem {
  id: string;
  kind: 'image' | 'video';
  name: string;
  type: string;
  size: number;
  blob: Blob;
  width?: number;
  height?: number;
  duration_ms?: number;
  trim_start_ms?: number;
  trim_end_ms?: number;
  sound?: DraftSound;
  alt_text?: string;
  cover_offset_sec?: number | null;
}

export interface StudioDraft {
  savedAt: number;
  text: string;
  hashtags: string;
  visibility: string;
  commentsDisabled: boolean;
  items: DraftMediaItem[];
}

// In-memory fallback when IndexedDB is unavailable (or a call fails).
let memoryDraft: StudioDraft | null = null;

function idbAvailable(): boolean {
  try {
    return typeof indexedDB !== 'undefined' && indexedDB !== null;
  } catch {
    return false;
  }
}

/** Hand-rolled ~20-line openDB (single store, version 1). */
function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => {
      if (!req.result.objectStoreNames.contains(STORE_NAME)) {
        req.result.createObjectStore(STORE_NAME);
      }
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error ?? new Error('IndexedDB open failed.'));
  });
}

async function withStore<T>(
  mode: IDBTransactionMode,
  run: (store: IDBObjectStore) => IDBRequest | void,
): Promise<T> {
  const db = await openDb();
  try {
    return await new Promise<T>((resolve, reject) => {
      const tx = db.transaction(STORE_NAME, mode);
      const request = run(tx.objectStore(STORE_NAME));
      let result: unknown;
      if (request) {
        request.onsuccess = () => {
          result = request.result;
        };
      }      tx.oncomplete = () => resolve(result as T);
      tx.onerror = () => reject(tx.error ?? new Error('IndexedDB transaction failed.'));
      tx.onabort = () => reject(tx.error ?? new Error('IndexedDB transaction aborted.'));
    });
  } finally {
    db.close();
  }
}

/** Accept only records that look like a StudioDraft (tolerates old shapes). */
function normalizeDraft(raw: unknown): StudioDraft | null {
  if (!raw || typeof raw !== 'object') return null;
  const d = raw as Partial<StudioDraft>;
  if (!Array.isArray(d.items)) return null;
  return {
    savedAt: typeof d.savedAt === 'number' ? d.savedAt : 0,
    text: typeof d.text === 'string' ? d.text : '',
    hashtags: typeof d.hashtags === 'string' ? d.hashtags : '',
    visibility: typeof d.visibility === 'string' ? d.visibility : 'public',
    commentsDisabled: d.commentsDisabled === true,
    items: d.items as DraftMediaItem[],
  };
}

/** Persist the draft; falls back to memory (and never throws). */
export async function saveStudioDraft(draft: StudioDraft): Promise<void> {
  memoryDraft = draft;
  if (!idbAvailable()) return;
  try {
    await withStore('readwrite', (store) => store.put(draft, DRAFT_KEY));
  } catch {
    // Memory copy already holds the draft.
  }
}

/** Load the draft, or null when there is nothing (valid) stored. */
export async function loadStudioDraft(): Promise<StudioDraft | null> {
  if (!idbAvailable()) return memoryDraft;
  try {
    const raw = await withStore<unknown>('readonly', (store) => store.get(DRAFT_KEY));
    const draft = normalizeDraft(raw);
    if (draft) memoryDraft = draft;
    return draft;
  } catch {
    return memoryDraft;
  }
}

/** Remove the stored draft (after publish or explicit discard). */
export async function clearStudioDraft(): Promise<void> {
  memoryDraft = null;
  if (!idbAvailable()) return;
  try {
    await withStore('readwrite', (store) => {
      store.delete(DRAFT_KEY);
    });
  } catch {
    // Nothing sensible to do — the memory copy is already cleared.
  }
}
