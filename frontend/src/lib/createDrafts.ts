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
  /** Offset into the sound where playback starts (ms). */
  start_offset_ms?: number;
  /** Fade in/out lengths in ms (0 = none). */
  fade_in_ms?: number;
  fade_out_ms?: number;
}

export interface DraftCaption {
  start_ms: number;
  end_ms: number;
  text: string;
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
  edit_meta?: import('./createStudio').EditMeta;
  /** Per-clip timed captions in absolute media coordinates. */
  captions?: DraftCaption[];
}

export interface StudioDraft {
  savedAt: number;
  text: string;
  hashtags: string;
  visibility: string;
  commentsDisabled: boolean;
  items: DraftMediaItem[];
  // ── Backward compat: pre-multiclip drafts ──────────────────────────────
  // Old drafts either had no captions at all or a single global list with an
  // owner id. extractCaptionsByItem() below normalizes both shapes into the
  // per-clip map; writers always persist the per-item form.
  /** Legacy single-list captions (absolute coordinates, owner clip below). */
  captions?: DraftCaption[];
  /** Legacy owner clip id for `captions`. */
  caption_item_id?: string | null;
}

export interface SaveDraftResult {
  ok: boolean;
  /** True when the write failed for lack of space — work is kept in memory. */
  quota: boolean;
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
  const items = (d.items as DraftMediaItem[]).filter(
    (it) => it && typeof it.id === 'string' && (it.kind === 'image' || it.kind === 'video'),
  );
  const cleanCaptions = (list: unknown): DraftCaption[] | undefined => {
    if (!Array.isArray(list)) return undefined;
    const out = list
      .filter((s): s is DraftCaption =>
        !!s && typeof (s as DraftCaption).text === 'string' &&
        Number.isFinite((s as DraftCaption).start_ms) && Number.isFinite((s as DraftCaption).end_ms))
      .map((s) => ({
        start_ms: Math.max(0, Math.round(s.start_ms)),
        end_ms: Math.max(0, Math.round(s.end_ms)),
        text: String(s.text).slice(0, 500),
      }))
      .filter((s) => s.text.trim() && s.end_ms > s.start_ms);
    return out.length ? out : undefined;
  };
  return {
    savedAt: typeof d.savedAt === 'number' ? d.savedAt : 0,
    text: typeof d.text === 'string' ? d.text : '',
    hashtags: typeof d.hashtags === 'string' ? d.hashtags : '',
    visibility: typeof d.visibility === 'string' ? d.visibility : 'public',
    commentsDisabled: d.commentsDisabled === true,
    items: items.map((it) => ({ ...it, captions: cleanCaptions(it.captions) })),
    ...(cleanCaptions(d.captions) ? { captions: cleanCaptions(d.captions) } : {}),
    ...(typeof d.caption_item_id === 'string' ? { caption_item_id: d.caption_item_id } : {}),
  };
}

/**
 * Normalize per-clip captions from any draft shape:
 * - new drafts: per-item `captions` win;
 * - legacy drafts: top-level `captions` attach to `caption_item_id`
 *   (or the first video item when the owner is gone).
 * Always returns absolute-coordinate lists; never throws.
 */
export function extractCaptionsByItem(draft: StudioDraft | null | undefined): Record<string, DraftCaption[]> {
  const out: Record<string, DraftCaption[]> = {};
  if (!draft) return out;
  for (const it of draft.items || []) {
    if (it?.kind === 'video' && Array.isArray(it.captions) && it.captions.length > 0) {
      out[it.id] = it.captions;
    }
  }
  if (Object.keys(out).length === 0 && Array.isArray(draft.captions) && draft.captions.length > 0) {
    const owner = (draft.items || []).find((it) => it.id === draft.caption_item_id && it.kind === 'video')
      ?? (draft.items || []).find((it) => it.kind === 'video');
    if (owner) out[owner.id] = draft.captions;
  }
  return out;
}

/** True for IndexedDB/DOM quota errors (storage full) across browsers. */
export function isQuotaError(err: unknown): boolean {
  if (!err || typeof err !== 'object') return false;
  const e = err as { name?: unknown; code?: unknown };
  if (e.name === 'QuotaExceededError' || e.name === 'NS_ERROR_DOM_QUOTA_REACHED') return true;
  // Legacy IE/Edge numeric code.
  if (e.code === 22) return true;
  return false;
}

/**
 * Persist the draft; falls back to memory (and never throws). Returns
 * whether the durable write succeeded so the UI can warn on quota instead
 * of silently keeping memory-only state.
 */
export async function saveStudioDraft(draft: StudioDraft): Promise<SaveDraftResult> {
  memoryDraft = draft;
  if (!idbAvailable()) return { ok: true, quota: false };
  try {
    await withStore('readwrite', (store) => store.put(draft, DRAFT_KEY));
    return { ok: true, quota: false };
  } catch (err) {
    // Memory copy already holds the draft — work is never discarded.
    return { ok: false, quota: isQuotaError(err) };
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
