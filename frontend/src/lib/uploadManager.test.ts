/** UploadManager state machine: queue, resume, retry, no-duplicate-post. */
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createUploadManager, type SessionStorage } from './uploadManager';
import type { FinalizedItem } from './uploader';

vi.mock('@/api/feed', () => ({ feedApi: {} }));
vi.mock('./createDrafts', () => ({ clearStudioDraft: vi.fn(async () => undefined) }));

const makeFile = (name: string, size = 100, type = 'video/mp4') =>
  new File([new Uint8Array(Math.max(1, size))], name, { type });

const memStorage = (): SessionStorage & { saved: unknown[] } => {
  const box: { saved: unknown[]; sessions: never[] } = { saved: [], sessions: [] };
  return {
    saved: box.saved,
    load: () => [],
    save: (sessions) => {
      box.saved.push(structuredCloneSafe(sessions));
    },
  };
};

function structuredCloneSafe<T>(v: T): T {
  return JSON.parse(JSON.stringify(v)) as T;
}

async function waitFor(fn: () => boolean, timeoutMs = 3000): Promise<void> {
  const start = Date.now();
  for (;;) {
    if (fn()) return;
    if (Date.now() - start > timeoutMs) throw new Error('waitFor timed out');
    await new Promise((r) => setTimeout(r, 10));
  }
}

interface Harness {
  mgr: ReturnType<typeof createUploadManager>;
  calls: { finalize: string[]; upload: string[]; createKeys: Array<string | undefined>; creates: number };
  attempts: string[];
  releasers: Array<() => void>;
  cleared: { count: number };
  failUpload: Set<string>;
  failCreate: { times: number };
  releaseUpload: Map<string, () => void>;
  storage: SessionStorage & { saved: unknown[] };
}

function setup(): Harness {
  const h = {} as Harness;
  h.calls = { finalize: [], upload: [], createKeys: [], creates: 0 };
  h.attempts = [];
  h.releasers = [];
  h.cleared = { count: 0 };
  h.failUpload = new Set();
  h.failCreate = { times: 0 };
  h.releaseUpload = new Map();
  h.storage = memStorage();
  let n = 0;
  h.mgr = createUploadManager({
    finalizeItem: async (item): Promise<FinalizedItem> => {
      h.calls.finalize.push(item.id);
      return { file: item.file, exported: false, offsetMs: 0, durationMs: item.durationMs ?? 1000 };
    },
    uploadFile: (file, opts) =>
      new Promise((resolve, reject) => {
        h.attempts.push(file.name);
        const done = () => {
          if (h.failUpload.has(file.name)) {
            reject(new Error(`upload boom: ${file.name}`));
            return;
          }
          h.calls.upload.push(file.name);
          opts?.onProgress?.({ pct: 100, loadedBytes: file.size, totalBytes: file.size });
          resolve({ url: `https://cdn/${file.name}` });
        };
        if (opts?.signal?.aborted) {
          reject(new DOMException('aborted', 'AbortError'));
          return;
        }
        opts?.signal?.addEventListener('abort', () => reject(new DOMException('aborted', 'AbortError')), { once: true });
        // Manual-release files let tests pause mid-upload; others finish async.
        h.releasers.push(done);
        h.releaseUpload.set(file.name, done);
        if (!file.name.startsWith('slow-')) done();
      }),
    createPost: async (_fd, key) => {
      h.calls.creates += 1;
      h.calls.createKeys.push(key);
      if (h.failCreate.times > 0) {
        h.failCreate.times -= 1;
        throw new Error('create boom');
      }
      return { ok: true };
    },
    clearDraft: async () => {
      h.cleared.count += 1;
    },
    storage: h.storage,
    now: () => 1,
    genId: () => `job-${++n}`,
  });
  return h;
}

const specFor = (names: string[]) => ({
  body: 'hello',
  visibility: 'public',
  postType: 'short_video' as const,
  commentsDisabled: false,
  autoCaptions: true,
  items: names.map((name, i) => ({
    id: `item-${i}`,
    kind: 'video' as const,
    name,
    file: makeFile(name),
    durationMs: 1000,
    captions: [{ start_ms: 0, end_ms: 100, text: `cap ${i}` }],
  })),
});

describe('happy path', () => {
  it('finalizes → uploads → creates once, then clears the draft', async () => {
    const h = setup();
    const events: string[] = [];
    h.mgr.subscribe((ev) => events.push(`${ev.type}:${ev.snapshot.status}`));
    const jobId = h.mgr.enqueue(specFor(['a.mp4', 'b.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    const snap = h.mgr.getSnapshot(jobId)!;
    expect(snap.items.every((it) => it.status === 'done')).toBe(true);
    expect(snap.overallPct).toBe(100);
    expect(h.calls.finalize).toEqual(['item-0', 'item-1']);
    expect(h.calls.upload).toEqual(['a.mp4', 'b.mp4']);
    expect(h.calls.creates).toBe(1);
    expect(h.calls.createKeys[0]).toBe(snap.idempotencyKey);
    expect(h.cleared.count).toBe(1);
    expect(events).toContain('done:done');
  });
});

describe('failure + retry', () => {
  it('fails the job, then resumes without re-uploading finished items', async () => {
    const h = setup();
    h.failUpload.add('b.mp4');
    const jobId = h.mgr.enqueue(specFor(['a.mp4', 'b.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'failed');
    const failed = h.mgr.getSnapshot(jobId)!;
    expect(failed.error).toMatch(/upload boom/);
    expect(h.calls.creates).toBe(0);
    expect(h.cleared.count).toBe(0); // draft kept on failure

    const uploadsBefore = h.calls.upload.length;
    h.failUpload.clear();
    h.mgr.retryJob(jobId);
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    // item-0 was already done: uploaded exactly once across both runs.
    expect(h.calls.upload.filter((n) => n === 'a.mp4')).toHaveLength(1);
    expect(h.calls.upload.length).toBe(uploadsBefore + 1);
    expect(h.calls.creates).toBe(1);
    expect(h.cleared.count).toBe(1);
  });

  it('reuses the idempotency key when create fails and never double-posts', async () => {
    const h = setup();
    h.failCreate.times = 1;
    const jobId = h.mgr.enqueue(specFor(['a.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'failed');
    expect(h.calls.creates).toBe(1);
    const key = h.mgr.getSnapshot(jobId)!.idempotencyKey;
    h.mgr.retryJob(jobId);
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    expect(h.calls.creates).toBe(2);
    expect(h.calls.createKeys).toEqual([key, key]);
    expect(h.cleared.count).toBe(1);
  });

  it('retry after success is a no-op (no duplicate post)', async () => {
    const h = setup();
    const jobId = h.mgr.enqueue(specFor(['a.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    h.mgr.retryJob(jobId);
    h.mgr.resumeJob(jobId);
    await new Promise((r) => setTimeout(r, 50));
    expect(h.calls.creates).toBe(1);
  });
});

describe('pause / resume / cancel', () => {
  it('pauses mid-upload and resumes to done', async () => {
    const h = setup();
    const jobId = h.mgr.enqueue(specFor(['slow-a.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'uploading');
    expect(h.attempts).toEqual(['slow-a.mp4']);
    h.mgr.pauseJob(jobId);
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'paused');
    expect(h.cleared.count).toBe(0);
    h.mgr.resumeJob(jobId);
    // The resumed run re-attempts the unfinished item — release the latest.
    await waitFor(() => h.attempts.length >= 2);
    h.releasers[h.releasers.length - 1]();
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    expect(h.calls.creates).toBe(1);
  });

  it('cancel aborts, keeps the draft, and never creates', async () => {
    const h = setup();
    const jobId = h.mgr.enqueue(specFor(['slow-a.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'uploading');
    h.mgr.cancelJob(jobId);
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'canceled');
    expect(h.calls.creates).toBe(0);
    expect(h.cleared.count).toBe(0);
  });
});

describe('persistence', () => {
  it('persists sessions with fingerprints + idempotency key', async () => {
    const h = setup();
    const jobId = h.mgr.enqueue(specFor(['a.mp4']));
    await waitFor(() => h.mgr.getSnapshot(jobId)?.status === 'done');
    expect(h.storage.saved.length).toBeGreaterThan(0);
    const last = h.storage.saved[h.storage.saved.length - 1] as Array<{
      jobId: string; idempotencyKey: string; status: string; items: Array<{ fingerprint: string; media?: unknown }>;
    }>;
    const session = last.find((s) => s.jobId === jobId)!;
    expect(session.status).toBe('done');
    expect(session.idempotencyKey).toBeTruthy();
    expect(session.items[0].fingerprint).toContain('a.mp4');
    expect(session.items[0].media).toBeTruthy();
  });

  it('resumeSession rebuilds a job reusing the key when files are re-attached', async () => {
    const h = setup();
    // Seed the fake storage with an interrupted session.
    const persisted = [
      {
        jobId: 'old-job',
        idempotencyKey: 'key-123',
        status: 'uploading',
        post: { body: 'hi', visibility: 'public', postType: 'short_video', commentsDisabled: false, autoCaptions: true },
        items: [
          {
            id: 'item-0', kind: 'video', name: 'a.mp4', fingerprint: 'a.mp4|1|video/mp4|0',
            bytesDone: 0, totalBytes: 1, retries: 2, media: undefined,
            meta: { durationMs: 1000, captions: [{ start_ms: 0, end_ms: 100, text: 'cap' }] },
          },
        ],
        createdAt: 1, updatedAt: 1,
      },
    ];
    h.storage.load = () => persisted as never[];
    const files = new Map([['item-0', makeFile('a.mp4', 1)]]);
    const id = h.mgr.resumeSession('old-job', files);
    expect(id).toBeTruthy();
    await waitFor(() => h.mgr.getSnapshot(id!)?.status === 'done');
    expect(h.calls.createKeys).toEqual(['key-123']);
  });

  it('resumeSession refuses without files', () => {
    const h = setup();
    h.storage.load = () => [
      {
        jobId: 'old-job', idempotencyKey: 'k', status: 'failed',
        post: { body: '', visibility: 'public', postType: 'photo', commentsDisabled: false, autoCaptions: false },
        items: [{ id: 'x', kind: 'image', name: 'x.png', fingerprint: 'f', bytesDone: 0, totalBytes: 1, retries: 0 }],
        createdAt: 1, updatedAt: 1,
      },
    ] as never[];
    expect(h.mgr.resumeSession('old-job', new Map())).toBeNull();
  });
});

describe('queueing', () => {
  it('runs jobs sequentially', async () => {
    const h = setup();
    const first = h.mgr.enqueue(specFor(['slow-one.mp4']));
    const second = h.mgr.enqueue(specFor(['two.mp4']));
    await waitFor(() => h.mgr.getSnapshot(second)?.status === 'queued');
    expect(h.mgr.hasActiveWork()).toBe(true);
    h.releaseUpload.get('slow-one.mp4')!();
    await waitFor(() => h.mgr.getSnapshot(first)?.status === 'done');
    await waitFor(() => h.mgr.getSnapshot(second)?.status === 'done');
    expect(h.calls.creates).toBe(2);
    expect(h.mgr.hasActiveWork()).toBe(false);
  });
});

beforeEach(() => {
  vi.clearAllMocks();
});
