/**
 * Pure logic for the create studio (trim clamping, cover poster URLs,
 * publish payload building) — kept framework-free for easy testing.
 */
import type { UploadedMedia } from '@/lib/uploader';

export const MAX_TRIM_MS = 180_000; // TikTok-style 3-minute cap
export const MAX_MEDIA_ITEMS = 12;

export interface TrimSelection {
  start_ms: number;
  end_ms: number;
}

export interface TrimRange extends TrimSelection {
  /** True when the requested trim had to be shortened to fit the cap. */
  clamped: boolean;
}

/**
 * Clamp a trim selection into [0, durationMs], enforcing a positive
 * selection and the ≤180s cap. Handles inverted or oversized inputs.
 */
export function clampTrim(
  startMs: number,
  endMs: number,
  durationMs: number,
  maxLenMs: number = MAX_TRIM_MS,
): TrimRange {
  const dur = Math.max(0, durationMs);
  let start = Math.min(Math.max(0, startMs), dur);
  let end = Math.min(Math.max(0, endMs), dur);
  if (end <= start) {
    const len = Math.min(1000, dur);
    start = Math.max(0, dur - len);
    end = dur;
  }
  let clamped = false;
  if (end - start > maxLenMs) {
    clamped = true;
    if (endMs > dur || startMs < 0) {
      // The selection hit the media bounds — keep the in point.
      end = start + maxLenMs;
    } else {
      // Dragged thumbs too far apart — keep the out point.
      start = end - maxLenMs;
    }
  }
  return { start_ms: Math.round(start), end_ms: Math.round(end), clamped };
}

/**
 * Move one trim thumb to `posMs` while keeping a minimal positive
 * selection and enforcing the ≤180s cap.
 */
export function moveThumb(
  which: 'start' | 'end',
  posMs: number,
  trim: TrimSelection,
  durationMs: number,
  maxLenMs: number = MAX_TRIM_MS,
): TrimRange {
  const dur = Math.max(0, durationMs);
  let start = trim.start_ms;
  let end = trim.end_ms;
  if (which === 'start') {
    start = Math.min(Math.max(0, posMs), Math.max(0, end - 100));
  } else {
    end = Math.max(Math.min(Math.max(0, posMs), dur), Math.min(start + 100, dur));
  }
  let clamped = false;
  if (end - start > maxLenMs) {
    clamped = true;
    if (which === 'start') start = end - maxLenMs;
    else end = start + maxLenMs;
  }
  return { start_ms: Math.round(start), end_ms: Math.round(end), clamped };
}

/** Format seconds as a compact Cloudinary offset ("1.5" → "so_1.5"). */
export function formatCoverOffset(offsetSec: number): string {
  const rounded = Math.round(offsetSec * 100) / 100;
  return `so_${rounded}`;
}

/** "65400" → "1:05.4" for trim/cover readouts. */
export function formatMs(ms: number): string {
  const total = Math.max(0, ms) / 1000;
  const m = Math.floor(total / 60);
  const s = total - m * 60;
  return `${m}:${s < 10 ? '0' : ''}${s.toFixed(1)}`;
}

/**
 * Poster override for a custom cover frame: append the Cloudinary start
 * offset (`?so_<seconds>`) to the media URL. Returns undefined when there
 * is nothing to append.
 */
export function coverPosterUrl(url: string | undefined | null, offsetSec?: number | null): string | undefined {
  if (!url || offsetSec == null || !Number.isFinite(offsetSec) || offsetSec < 0) return undefined;
  return `${url}?${formatCoverOffset(offsetSec)}`;
}

/** Serializable slice of a studio item used to build the publish payload. */
export interface PublishableMediaItem {
  kind: 'image' | 'video';
  media: UploadedMedia;
  trim_start_ms?: number | null;
  trim_end_ms?: number | null;
  sound?: { id: string; volume: number } | null;
  alt_text?: string | null;
  coverOffsetSec?: number | null;
}

export interface MediaPayloadItem {
  url: string;
  media_type: 'image' | 'video';
  width?: number;
  height?: number;
  duration_ms?: number;
  poster_url?: string;
  trim_start_ms?: number;
  trim_end_ms?: number;
  sound_id?: string;
  sound_volume?: number;
  alt_text?: string;
}

/** Build the `media` JSON array sent to POST /feed/create/ (max 12 items). */
export function buildMediaPayload(items: PublishableMediaItem[]): MediaPayloadItem[] {
  return items.slice(0, MAX_MEDIA_ITEMS).map((item) => {
    const out: MediaPayloadItem = {
      url: item.media.url,
      media_type: item.kind,
    };
    if (item.media.width != null) out.width = item.media.width;
    if (item.media.height != null) out.height = item.media.height;
    if (item.kind === 'video' && item.media.duration_ms != null) out.duration_ms = item.media.duration_ms;
    const poster = coverPosterUrl(item.media.url, item.coverOffsetSec) ?? item.media.poster_url;
    if (poster) out.poster_url = poster;
    if (item.kind === 'video') {
      if (item.trim_start_ms != null && item.trim_start_ms > 0) out.trim_start_ms = item.trim_start_ms;
      if (item.trim_end_ms != null && item.trim_end_ms > 0) out.trim_end_ms = item.trim_end_ms;
      if (item.sound) {
        out.sound_id = item.sound.id;
        out.sound_volume = item.sound.volume;
      }
    }
    if (item.alt_text) out.alt_text = item.alt_text;
    return out;
  });
}

// ─── Publish state machine ───────────────────────────────────────────────────
//
// Publish runs as a TikTok-style pipeline: Finalize (prepare local files) →
// Upload (sequential, byte-accurate progress) → Create (POST /feed/create/).
// The reducer is pure so the pipeline can be unit tested without a DOM.

export type PublishStage = 'idle' | 'finalizing' | 'uploading' | 'creating' | 'done';

export interface PublishUploadItem {
  id: string;
  name: string;
  kind: 'image' | 'video';
  status: 'pending' | 'uploading' | 'done' | 'error';
  loadedBytes: number;
  totalBytes: number;
  /** Server-provided failure reason when status === 'error'. */
  message?: string;
}

export interface PublishState {
  stage: PublishStage;
  items: PublishUploadItem[];
  /** Item currently uploading (or the one that failed and awaits retry). */
  activeId: string | null;
  error: string | null;
}

export type PublishAction =
  | { type: 'start' }
  | { type: 'finalized' }
  | { type: 'itemStart'; id: string }
  | { type: 'itemProgress'; id: string; loadedBytes: number; totalBytes: number }
  | { type: 'itemDone'; id: string }
  | { type: 'itemError'; id: string; message: string }
  | { type: 'itemRetry'; id: string }
  | { type: 'cancel' }
  | { type: 'creating' }
  | { type: 'createError'; message: string }
  | { type: 'done' };

export interface PublishPlanItem {
  id: string;
  name: string;
  kind: 'image' | 'video';
  size: number;
}

/** Fresh state for a publish run: every item queued, nothing sent yet. */
export function createPublishState(items: PublishPlanItem[]): PublishState {
  return {
    stage: 'idle',
    items: items.map((it) => ({
      id: it.id,
      name: it.name,
      kind: it.kind,
      status: 'pending' as const,
      loadedBytes: 0,
      totalBytes: it.size,
    })),
    activeId: null,
    error: null,
  };
}

function nextPendingId(items: PublishUploadItem[]): string | null {
  return items.find((it) => it.status === 'pending')?.id ?? null;
}

/** Advance the publish pipeline. Unknown ids on progress actions are no-ops. */
export function publishReducer(state: PublishState, action: PublishAction): PublishState {
  switch (action.type) {
    case 'start':
      return { ...state, stage: 'finalizing', error: null };
    case 'finalized':
      return { ...state, stage: 'uploading', activeId: nextPendingId(state.items) };
    case 'itemStart':
      return {
        ...state,
        stage: 'uploading',
        activeId: action.id,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'uploading', message: undefined } : it,
        ),
      };
    case 'itemProgress':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id
            ? { ...it, loadedBytes: action.loadedBytes, totalBytes: action.totalBytes }
            : it,
        ),
      };
    case 'itemDone':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id
            ? { ...it, status: 'done', loadedBytes: it.totalBytes, message: undefined }
            : it,
        ),
        activeId: nextPendingId(state.items),
      };
    case 'itemError':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'error', message: action.message } : it,
        ),
        activeId: action.id,
        error: action.message,
      };
    case 'itemRetry':
      return {
        ...state,
        error: null,
        activeId: action.id,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'uploading', message: undefined } : it,
        ),
      };
    case 'cancel':
      return createPublishState(
        state.items.map((it) => ({
          id: it.id,
          name: it.name,
          kind: it.kind,
          size: it.totalBytes,
        })),
      );
    case 'creating':
      return { ...state, stage: 'creating', error: null };
    case 'createError':
      return { ...state, stage: 'creating', error: action.message };
    case 'done':
      return { ...state, stage: 'done', error: null };
    default:
      return state;
  }
}

/** Overall publish progress 0–100 from bytes sent across all items. */
export function publishOverallProgress(state: PublishState): number {
  const totalBytes = state.items.reduce((sum, it) => sum + it.totalBytes, 0);
  if (totalBytes <= 0) return state.stage === 'done' ? 100 : 0;
  const loadedBytes = state.items.reduce((sum, it) => sum + it.loadedBytes, 0);
  return Math.min(100, Math.floor((loadedBytes / totalBytes) * 100));
}

/** Per-item percentage 0–100 for the active upload readout. */
export function publishItemPct(item: PublishUploadItem): number {
  if (item.status === 'done') return 100;
  if (item.totalBytes <= 0) return 0;
  return Math.min(100, Math.floor((item.loadedBytes / item.totalBytes) * 100));
}

/** Bytes → "12.4 MB" for the upload readout. */
export function formatMb(bytes: number): string {
  return `${(Math.max(0, bytes) / (1024 * 1024)).toFixed(1)} MB`;
}
