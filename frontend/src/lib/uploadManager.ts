/**
 * UploadManager — background upload queue for Bud Press publishes.
 *
 * A module-level singleton, so uploads survive route changes while the SPA
 * is alive: CreateStudio enqueues a job and subscribes to snapshots instead
 * of owning the finalize → upload → create loop itself. Navigating away
 * never aborts a running job.
 *
 * Guarantees:
 * - Sequential: one job (and one item inside it) uploads at a time.
 * - Resumable: pause/resume/retry continue from the first unfinished item;
 *   finished items keep their media URLs and are never re-uploaded.
 * - No duplicate posts: one idempotency key per job (persisted), reused
 *   across retries; createPost is guarded so it runs at most once per job
 *   after all uploads succeed — and the local draft is cleared ONLY on
 *   post-create success, never on failure/cancel/pause.
 * - Durable sessions: lightweight records (ids, fingerprints, bytes done,
 *   retry counts, last errors, idempotency key, post payload — never blobs)
 *   persist to localStorage so an interrupted job can be reported/retried.
 *   Quota failures degrade to memory-only; work is never discarded.
 *
 * Limits (be honest about them):
 * - SPA-alive only: closing/reloading the tab aborts in-flight XHR. The
 *   persisted session survives and can resume once the picked files are
 *   re-attached (drafts keep the blobs in IndexedDB), but bytes already sent
 *   are re-uploaded — resume is item-level, not byte-level, except inside a
 *   single chunked video upload while the page stays alive.
 * - No OS-level background upload (no Service Worker / Background Sync):
 *   mobile browsers may suspend timers/XHR when the tab is hidden.
 */

import { feedApi } from '@/api/feed';
import {
  buildMediaPayload,
  defaultEditMeta,
  fingerprintFile,
  planCaptionsForItems,
  rebaseCoverOffsetSeconds,
  rebaseEditMetaForTrimmedVideo,
  type CaptionsStyle,
  type EditMeta,
  type PublishableCaption,
  type TrimOffsetInfo,
} from './createStudio';
import {
  finalizeStudioItem,
  uploadFileWithResume,
  type FinalizedItem,
  type UploadedMedia,
  type UploadOptions,
} from './uploader';
import { clearStudioDraft } from './createDrafts';

export type JobStatus =
  | 'queued'
  | 'finalizing'
  | 'uploading'
  | 'creating'
  | 'paused'
  | 'failed'
  | 'done'
  | 'canceled';

export type JobItemStatus = 'pending' | 'finalizing' | 'uploading' | 'done' | 'error';

export interface ManagedUploadItem {
  id: string;
  kind: 'image' | 'video';
  name: string;
  file: File;
  durationMs?: number | null;
  trimStartMs?: number | null;
  trimEndMs?: number | null;
  editMeta?: EditMeta | null;
  captions?: PublishableCaption[] | null;
  captionsStyle?: CaptionsStyle | null;
  sound?: { id: string; volume: number; start_ms?: number | null; fade_in_ms?: number | null; fade_out_ms?: number | null } | null;
  altText?: string | null;
  coverOffsetSec?: number | null;
}

export interface EnqueueSpec {
  body: string;
  visibility: string;
  postType: 'short_video' | 'photo';
  commentsDisabled: boolean;
  autoCaptions: boolean;
  items: ManagedUploadItem[];
  /** Reused across retries when provided; otherwise generated once per job. */
  idempotencyKey?: string;
}

export interface JobItemState {
  id: string;
  name: string;
  kind: 'image' | 'video';
  status: JobItemStatus;
  loadedBytes: number;
  totalBytes: number;
  fingerprint: string;
  retries: number;
  lastError?: string;
  media?: UploadedMedia;
}

export interface JobSnapshot {
  jobId: string;
  status: JobStatus;
  idempotencyKey: string;
  items: JobItemState[];
  overallPct: number;
  loadedBytes: number;
  totalBytes: number;
  error: string | null;
  createdAt: number;
  updatedAt: number;
}

export type ManagerEventType = 'change' | 'done' | 'failed';
export interface ManagerEvent {
  type: ManagerEventType;
  snapshot: JobSnapshot;
}
export type ManagerListener = (event: ManagerEvent) => void;

// ─── Persisted sessions (no blobs — files re-attach from the draft) ─────────

interface PersistedItemMeta {
  trimStartMs?: number | null;
  trimEndMs?: number | null;
  durationMs?: number | null;
  editMeta?: EditMeta | null;
  captions?: PublishableCaption[] | null;
  captionsStyle?: CaptionsStyle | null;
  sound?: ManagedUploadItem['sound'];
  altText?: string | null;
  coverOffsetSec?: number | null;
}

interface PersistedItem {
  id: string;
  kind: 'image' | 'video';
  name: string;
  fingerprint: string;
  bytesDone: number;
  totalBytes: number;
  retries: number;
  lastError?: string;
  media?: UploadedMedia;
  /** Trim-export coordinates for already-finalized items (caption rebase). */
  offset?: TrimOffsetInfo;
  /** Serializable item meta so a session can resume after a reload. */
  meta?: PersistedItemMeta;
}

export interface PersistedSession {
  jobId: string;
  idempotencyKey: string;
  status: JobStatus;
  post: {
    body: string;
    visibility: string;
    postType: 'short_video' | 'photo';
    commentsDisabled: boolean;
    autoCaptions: boolean;
  };
  items: PersistedItem[];
  createdAt: number;
  updatedAt: number;
  error?: string;
}

const SESSION_STORAGE_KEY = 'buddyup-upload-sessions-v1';
const MAX_PERSISTED_SESSIONS = 5;

export interface SessionStorage {
  load(): PersistedSession[];
  save(sessions: PersistedSession[]): void;
}

function defaultSessionStorage(): SessionStorage {
  let memory: PersistedSession[] = [];
  const read = (): PersistedSession[] => {
    try {
      const raw = localStorage.getItem(SESSION_STORAGE_KEY);
      if (!raw) return memory;
      const parsed = JSON.parse(raw) as unknown;
      if (!Array.isArray(parsed)) return memory;
      return parsed.filter(
        (s): s is PersistedSession =>
          !!s && typeof (s as PersistedSession).jobId === 'string' && Array.isArray((s as PersistedSession).items),
      );
    } catch {
      return memory;
    }
  };
  return {
    load: () => {
      try {
        memory = read();
      } catch {
        // memory fallback stands
      }
      return memory;
    },
    save: (sessions) => {
      memory = sessions;
      try {
        localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(sessions.slice(0, MAX_PERSISTED_SESSIONS)));
      } catch {
        // Quota/private mode — memory copy already holds the sessions.
      }
    },
  };
}

// ─── Injectable deps (tests swap the network) ────────────────────────────────

export interface UploadManagerDeps {
  finalizeItem: (item: ManagedUploadItem, opts?: { signal?: AbortSignal; onProgress?: (ratio: number) => void }) => Promise<FinalizedItem>;
  uploadFile: (file: File, opts?: UploadOptions) => Promise<UploadedMedia>;
  createPost: (formData: FormData, idempotencyKey?: string) => Promise<unknown>;
  clearDraft: () => Promise<void>;
  storage: SessionStorage;
  now: () => number;
  genId: () => string;
}

function defaultDeps(): UploadManagerDeps {
  return {
    finalizeItem: (item, opts) =>
      finalizeStudioItem(
        {
          file: item.file,
          kind: item.kind,
          trimStartMs: item.trimStartMs,
          trimEndMs: item.trimEndMs,
          durationMs: item.durationMs,
        },
        { durationMs: item.durationMs ?? null, signal: opts?.signal, onProgress: opts?.onProgress },
      ),
    uploadFile: (file, opts) => uploadFileWithResume(file, opts),
    createPost: (formData, key) => feedApi.createPost(formData, key),
    clearDraft: () => clearStudioDraft().then(() => undefined),
    storage: defaultSessionStorage(),
    now: () => Date.now(),
    genId: () => {
      try {
        return crypto.randomUUID();
      } catch {
        return `job-${Date.now()}-${Math.floor(Math.random() * 1e9)}`;
      }
    },
  };
}

interface JobRuntime {
  spec: EnqueueSpec;
  status: JobStatus;
  items: JobItemState[];
  finalized: Map<string, { finalized: FinalizedItem; spec: ManagedUploadItem }>;
  controller: AbortController | null;
  running: boolean;
  pauseRequested: boolean;
  cancelRequested: boolean;
  postCreated: boolean;
  error: string | null;
  createdAt: number;
  updatedAt: number;
  idempotencyKey: string;
}

const isAbort = (err: unknown): boolean =>
  (err instanceof DOMException && err.name === 'AbortError') ||
  (typeof err === 'object' && err !== null && (err as { code?: unknown }).code === 'ERR_CANCELED');

function messageOf(err: unknown, fallback: string): string {
  if (err instanceof Error && err.message) return err.message.slice(0, 300);
  if (typeof err === 'string' && err.trim()) return err.slice(0, 300);
  return fallback;
}

export function createUploadManager(overrides: Partial<UploadManagerDeps> = {}) {
  const deps: UploadManagerDeps = { ...defaultDeps(), ...overrides };
  const jobs = new Map<string, JobRuntime>();
  const listeners = new Set<ManagerListener>();

  const snapshot = (jobId: string, job: JobRuntime): JobSnapshot => {
    const totalBytes = job.items.reduce((s, it) => s + it.totalBytes, 0);
    const loadedBytes = job.items.reduce((s, it) => s + Math.min(it.loadedBytes, it.totalBytes), 0);
    return {
      jobId,
      status: job.status,
      idempotencyKey: job.idempotencyKey,
      items: job.items.map((it) => ({ ...it })),
      overallPct: totalBytes > 0 ? Math.min(100, Math.floor((loadedBytes / totalBytes) * 100)) : job.status === 'done' ? 100 : 0,
      loadedBytes,
      totalBytes,
      error: job.error,
      createdAt: job.createdAt,
      updatedAt: job.updatedAt,
    };
  };

  const emit = (jobId: string, job: JobRuntime, type: ManagerEventType): void => {
    const event: ManagerEvent = { type, snapshot: snapshot(jobId, job) };
    listeners.forEach((fn) => {
      try {
        fn(event);
      } catch {
        // A subscriber must never break the queue.
      }
    });
  };

  const persist = (): void => {
    const sessions: PersistedSession[] = Array.from(jobs.entries()).map(([jobId, job]) => ({
      jobId,
      idempotencyKey: job.idempotencyKey,
      status: job.status,
      post: {
        body: job.spec.body,
        visibility: job.spec.visibility,
        postType: job.spec.postType,
        commentsDisabled: job.spec.commentsDisabled,
        autoCaptions: job.spec.autoCaptions,
      },
      items: job.items.map((it) => {
        const specItem = job.spec.items.find((s) => s.id === it.id);
        const fin = job.finalized.get(it.id)?.finalized;
        return {
          id: it.id,
          kind: it.kind,
          name: it.name,
          fingerprint: it.fingerprint,
          bytesDone: it.status === 'done' ? it.totalBytes : it.loadedBytes,
          totalBytes: it.totalBytes,
          retries: it.retries,
          ...(it.lastError ? { lastError: it.lastError } : {}),
          ...(it.media ? { media: it.media } : {}),
          ...(fin ? { offset: { offsetMs: fin.offsetMs, durationMs: fin.durationMs, exported: fin.exported } } : {}),
          ...(specItem
            ? {
              meta: {
                trimStartMs: specItem.trimStartMs,
                trimEndMs: specItem.trimEndMs,
                durationMs: specItem.durationMs,
                editMeta: specItem.editMeta,
                captions: specItem.captions,
                captionsStyle: specItem.captionsStyle,
                sound: specItem.sound,
                altText: specItem.altText,
                coverOffsetSec: specItem.coverOffsetSec,
              },
            }
            : {}),
        };
      }),
      createdAt: job.createdAt,
      updatedAt: job.updatedAt,
      ...(job.error ? { error: job.error } : {}),
    }));
    try {
      deps.storage.save(sessions);
    } catch {
      // Persistence is best-effort; in-memory state is authoritative.
    }
  };

  const setStatus = (jobId: string, job: JobRuntime, status: JobStatus, error: string | null = null): void => {
    job.status = status;
    job.error = error;
    job.updatedAt = deps.now();
    persist();
    emit(jobId, job, status === 'done' ? 'done' : status === 'failed' ? 'failed' : 'change');
  };

  const touch = (jobId: string, job: JobRuntime): void => {
    job.updatedAt = deps.now();
    emit(jobId, job, 'change');
  };

  const activeRunningId = (): string | null => {
    for (const [id, job] of jobs) {
      if (job.running && ['finalizing', 'uploading', 'creating'].includes(job.status)) return id;
    }
    return null;
  };

  const pump = (): void => {
    if (activeRunningId()) return;
    for (const [id, job] of jobs) {
      if (job.status === 'queued') {
        void runJob(id, job);
        return;
      }
    }
  };

  async function runJob(jobId: string, job: JobRuntime): Promise<void> {
    if (job.running || job.postCreated || job.status !== 'queued') return;
    job.running = true;
    job.pauseRequested = false;
    job.cancelRequested = false;
    job.controller = new AbortController();
    const { signal } = job.controller;

    try {
      // ── 1) Finalize pending items (trim-export cache makes this cheap) ──
      const pending = job.items.filter((it) => it.status !== 'done');
      if (pending.length > 0) {
        setStatus(jobId, job, 'finalizing');
        for (const itemState of job.items) {
          if (itemState.status === 'done') continue;
          if (signal.aborted) throw new DOMException('The upload was aborted.', 'AbortError');
          const spec = job.spec.items.find((s) => s.id === itemState.id);
          if (!spec) {
            itemState.status = 'error';
            itemState.lastError = 'Missing file for this item.';
            continue;
          }
          itemState.status = 'finalizing';
          touch(jobId, job);
          const finalized = await deps.finalizeItem(spec, { signal });
          job.finalized.set(itemState.id, { finalized, spec });
          itemState.totalBytes = finalized.file.size;
          itemState.status = 'pending';
        }
      }

      // ── 2) Upload sequentially, skipping finished items (resume) ────────
      setStatus(jobId, job, 'uploading');
      for (const itemState of job.items) {
        if (itemState.status === 'done') continue;
        if (signal.aborted) throw new DOMException('The upload was aborted.', 'AbortError');
        const entry = job.finalized.get(itemState.id);
        if (!entry) {
          itemState.status = 'error';
          itemState.lastError = 'Could not prepare this item.';
          throw new Error(`Could not prepare "${itemState.name}".`);
        }
        itemState.status = 'uploading';
        itemState.lastError = undefined;
        touch(jobId, job);
        try {
          const media = await deps.uploadFile(entry.finalized.file, {
            signal,
            onProgress: (p) => {
              itemState.loadedBytes = p.loadedBytes;
              itemState.totalBytes = p.totalBytes;
              touch(jobId, job);
            },
          });
          itemState.media = media;
          itemState.status = 'done';
          itemState.loadedBytes = itemState.totalBytes;
          itemState.lastError = undefined;
          persist();
          touch(jobId, job);
        } catch (err) {
          if (isAbort(err)) throw err;
          itemState.status = 'error';
          itemState.retries += 1;
          itemState.lastError = messageOf(err, 'Upload failed.');
          persist();
          throw err;
        }
      }

      // ── 3) Create the post exactly once ────────────────────────────────
      if (job.postCreated) return;
      setStatus(jobId, job, 'creating');
      const captionsByItem: Record<string, PublishableCaption[]> = {};
      for (const s of job.spec.items) {
        if (s.captions?.length) captionsByItem[s.id] = s.captions;
      }
      const offsets = new Map<string, TrimOffsetInfo>();
      for (const [id, entry] of job.finalized) {
        offsets.set(id, {
          offsetMs: entry.finalized.offsetMs,
          durationMs: entry.finalized.durationMs,
          exported: entry.finalized.exported,
        });
      }
      // Items finalized before this run (resume) still have offsets recorded.
      const plannedCaptions = planCaptionsForItems(captionsByItem, offsets);
      const mediaJson = buildMediaPayload(
        job.spec.items.map((s) => {
          const entry = job.finalized.get(s.id);
          const itemState = job.items.find((it) => it.id === s.id);
          const media = itemState?.media;
          if (!media) throw new Error(`Missing upload for "${s.name}".`);
          const fin = entry?.finalized;
          const exported = fin?.exported ?? false;
          const durationMs = fin?.durationMs ?? s.durationMs ?? media.duration_ms ?? 0;
          const merged: EditMeta = {
            ...(s.editMeta ?? defaultEditMeta()),
            ...(s.captionsStyle ? { captions_style: s.captionsStyle } : {}),
          };
          const editMeta = exported && fin
            ? rebaseEditMetaForTrimmedVideo(merged, fin.offsetMs, fin.durationMs)
            : merged;
          return {
            kind: s.kind,
            media,
            trim_start_ms: s.kind === 'video' ? (exported ? 0 : (s.trimStartMs ?? 0)) : null,
            trim_end_ms: s.kind === 'video' ? (exported ? durationMs : (s.trimEndMs ?? durationMs ?? 0)) : null,
            editMeta,
            captions: plannedCaptions[s.id] ?? null,
            sound: s.kind === 'video' && s.sound ? s.sound : null,
            alt_text: s.altText || null,
            coverOffsetSec: s.kind === 'video'
              ? exported && fin
                ? rebaseCoverOffsetSeconds(s.coverOffsetSec, fin.offsetMs, fin.durationMs)
                : s.coverOffsetSec
              : null,
          };
        }),
      );
      const formData = new FormData();
      formData.append('body', job.spec.body.trim());
      formData.append('visibility', job.spec.visibility);
      formData.append('post_type', job.spec.postType);
      formData.append('media', JSON.stringify(mediaJson));
      if (job.spec.commentsDisabled) formData.append('comments_disabled', 'true');
      formData.append('auto_captions', String(job.spec.autoCaptions));
      try {
        await deps.createPost(formData, job.idempotencyKey);
      } catch (err) {
        if (isAbort(err)) throw err;
        throw err;
      }
      job.postCreated = true;
      // Draft cleanup ONLY after post-create success — never on failure.
      try {
        await deps.clearDraft();
      } catch {
        // A stale draft is recoverable by the user; the post already exists.
      }
      setStatus(jobId, job, 'done');
    } catch (err) {
      if (isAbort(err)) {
        if (job.cancelRequested) {
          setStatus(jobId, job, 'canceled', 'Upload canceled. Your draft is saved on this device.');
        } else {
          // Abort without explicit cancel → treat as pause (e.g. user hit
          // pause, or the app is backgrounded): progress is kept.
          setStatus(jobId, job, 'paused', null);
        }
      } else {
        const failed = job.items.find((it) => it.status === 'error');
        const msg = failed?.lastError ?? messageOf(err, 'Could not publish. Check your connection and try again.');
        setStatus(jobId, job, 'failed', msg);
      }
    } finally {
      job.running = false;
      job.controller = null;
      persist();
      pump();
    }
  }

  interface SeedDone {
    media: UploadedMedia;
    offset?: TrimOffsetInfo;
    retries?: number;
  }

  const enqueueInternal = (spec: EnqueueSpec, seed?: { idempotencyKey?: string; doneById?: Map<string, SeedDone> }): string => {
    const jobId = deps.genId();
    const idempotencyKey = seed?.idempotencyKey || spec.idempotencyKey || deps.genId();
    const now = deps.now();
    const job: JobRuntime = {
      spec,
      status: 'queued',
      items: spec.items.map((s) => {
        const seeded = seed?.doneById?.get(s.id);
        return {
          id: s.id,
          name: s.name || s.file.name,
          kind: s.kind,
          status: seeded ? ('done' as JobItemStatus) : ('pending' as JobItemStatus),
          loadedBytes: seeded ? s.file.size : 0,
          totalBytes: s.file.size,
          fingerprint: fingerprintFile(s.file),
          retries: seeded?.retries ?? 0,
          lastError: undefined,
          media: seeded?.media,
        };
      }),
      finalized: new Map(),
      controller: null,
      running: false,
      pauseRequested: false,
      cancelRequested: false,
      postCreated: false,
      error: null,
      createdAt: now,
      updatedAt: now,
      idempotencyKey,
    };
    // Pre-seed finalized coordinates for already-uploaded items so the
    // create step can rebase their captions/edit-meta without re-exporting.
    if (seed?.doneById) {
      for (const s of spec.items) {
        const seeded = seed.doneById.get(s.id);
        if (seeded?.offset) {
          job.finalized.set(s.id, {
            spec: s,
            finalized: {
              file: s.file,
              exported: seeded.offset.exported,
              offsetMs: seeded.offset.offsetMs,
              durationMs: seeded.offset.durationMs,
            },
          });
        }
      }
    }
    jobs.set(jobId, job);
    persist();
    emit(jobId, job, 'change');
    pump();
    return jobId;
  };

  return {
    /** Enqueue a publish job; starts immediately when the queue is idle. */
    enqueue(spec: EnqueueSpec): string {
      return enqueueInternal(spec);
    },

    subscribe(listener: ManagerListener): () => void {
      listeners.add(listener);
      return () => {
        listeners.delete(listener);
      };
    },

    getSnapshot(jobId: string): JobSnapshot | null {
      const job = jobs.get(jobId);
      return job ? snapshot(jobId, job) : null;
    },

    getAllSnapshots(): JobSnapshot[] {
      return Array.from(jobs.entries()).map(([id, job]) => snapshot(id, job));
    },

    /** True while any job is queued/finalizing/uploading/creating. */
    hasActiveWork(): boolean {
      for (const job of jobs.values()) {
        if (['queued', 'finalizing', 'uploading', 'creating'].includes(job.status)) return true;
      }
      return false;
    },

    pauseJob(jobId: string): void {
      const job = jobs.get(jobId);
      if (!job) return;
      if (['done', 'failed', 'canceled', 'paused'].includes(job.status)) return;
      if (job.running) {
        job.pauseRequested = true;
        job.controller?.abort();
      } else {
        setStatus(jobId, job, 'paused', null);
      }
    },

    resumeJob(jobId: string): void {
      const job = jobs.get(jobId);
      if (!job || job.postCreated) return;
      if (!['paused', 'failed', 'queued'].includes(job.status)) return;
      job.error = null;
      for (const it of job.items) {
        if (it.status === 'error') it.status = 'pending';
      }
      setStatus(jobId, job, 'queued', null);
      pump();
    },

    /** Retry a failed (or paused) job; reuses the same idempotency key. */
    retryJob(jobId: string): void {
      const job = jobs.get(jobId);
      if (!job || job.postCreated) return;
      if (!['failed', 'paused'].includes(job.status)) return;
      job.error = null;
      for (const it of job.items) {
        if (it.status === 'error') {
          it.status = 'pending';
          it.lastError = undefined;
        }
      }
      setStatus(jobId, job, 'queued', null);
      pump();
    },

    cancelJob(jobId: string): void {
      const job = jobs.get(jobId);
      if (!job) return;
      if (['done', 'canceled'].includes(job.status)) return;
      if (job.running) {
        job.cancelRequested = true;
        job.controller?.abort();
      } else {
        setStatus(jobId, job, 'canceled', 'Upload canceled. Your draft is saved on this device.');
      }
    },

    /** Drop a terminal job from memory (persisted record is pruned too). */
    dismissJob(jobId: string): void {
      const job = jobs.get(jobId);
      if (!job || job.running) return;
      if (!['done', 'failed', 'canceled'].includes(job.status)) return;
      jobs.delete(jobId);
      persist();
    },

    /**
     * Re-attach files to an interrupted persisted session (e.g. after a
     * reload — drafts keep the blobs in IndexedDB) and resume it under a new
     * job id that REUSES the session's idempotency key, so a retried create
     * can never double-post. Already-uploaded items keep their media URLs
     * and are not re-uploaded. Returns the new job id, or null when files
     * or session meta are missing.
     */
    resumeSession(persistedJobId: string, files: Map<string, File>): string | null {
      if (jobs.get(persistedJobId)) {
        const existing = jobs.get(persistedJobId)!;
        if (['paused', 'failed'].includes(existing.status)) this.resumeJob(persistedJobId);
        return persistedJobId;
      }
      let sessions: PersistedSession[] = [];
      try {
        sessions = deps.storage.load();
      } catch {
        sessions = [];
      }
      const session = sessions.find((s) => s.jobId === persistedJobId);
      if (!session || session.status === 'done' || session.status === 'canceled' || session.status === 'creating') {
        // A session stuck in 'creating' may already have a post server-side;
        // surface it for manual retry instead of auto-resuming blindly.
        return null;
      }
      const items: ManagedUploadItem[] = [];
      const doneById = new Map<string, SeedDone>();
      for (const it of session.items) {
        const file = files.get(it.id);
        if (!file) return null; // without the bytes there is nothing to upload
        const meta = it.meta ?? {};
        items.push({
          id: it.id,
          kind: it.kind,
          name: it.name,
          file,
          durationMs: meta.durationMs,
          trimStartMs: meta.trimStartMs,
          trimEndMs: meta.trimEndMs,
          editMeta: meta.editMeta,
          captions: meta.captions,
          captionsStyle: meta.captionsStyle,
          sound: meta.sound,
          altText: meta.altText,
          coverOffsetSec: meta.coverOffsetSec,
        });
        if (it.media) doneById.set(it.id, { media: it.media, offset: it.offset, retries: it.retries });
      }
      if (items.length === 0) return null;
      return enqueueInternal(
        {
          body: session.post.body,
          visibility: session.post.visibility,
          postType: session.post.postType,
          commentsDisabled: session.post.commentsDisabled,
          autoCaptions: session.post.autoCaptions,
          items,
        },
        { idempotencyKey: session.idempotencyKey, doneById },
      );
    },

    /** Interrupted/durable sessions for "resume after reload" UI. */
    getPersistedSessions(): PersistedSession[] {
      try {
        return deps.storage.load();
      } catch {
        return [];
      }
    },

    /** Test/escape hatch: drop all in-memory jobs (persisted copy stands). */
    _resetForTests(): void {
      for (const job of jobs.values()) {
        try {
          job.controller?.abort();
        } catch {
          // ignore
        }
        job.running = false;
      }
      jobs.clear();
    },
  };
}

export type UploadManager = ReturnType<typeof createUploadManager>;

/** App-wide singleton: module state survives route changes while SPA lives. */
export const uploadManager: UploadManager = createUploadManager();
