/** Trim-export cache, finalize helper and chunked-upload planning. */
import { describe, expect, it } from 'vitest';
import {
  clearTrimExportCache,
  finalizeStudioItem,
  formatContentRange,
  getCachedTrimExport,
  getOrExportTrimmedVideo,
  planUploadChunks,
  setCachedTrimExport,
  trimExportCacheSize,
  UPLOAD_CHUNK_BYTES,
} from './uploader';

describe('planUploadChunks', () => {
  it('returns no chunks for empty files', () => {
    expect(planUploadChunks(0)).toEqual([]);
  });

  it('splits into inclusive ranges covering the whole file', () => {
    const chunks = planUploadChunks(UPLOAD_CHUNK_BYTES * 2 + 100);
    expect(chunks).toHaveLength(3);
    expect(chunks[0]).toMatchObject({ index: 0, count: 3, start: 0, end: UPLOAD_CHUNK_BYTES - 1 });
    expect(chunks[2].end).toBe(UPLOAD_CHUNK_BYTES * 2 + 99);
    // Contiguous coverage, no gaps or overlaps.
    for (let i = 1; i < chunks.length; i++) {
      expect(chunks[i].start).toBe(chunks[i - 1].end + 1);
    }
  });

  it('emits a single chunk for small files', () => {
    expect(planUploadChunks(100)).toEqual([{ index: 0, count: 1, start: 0, end: 99, total: 100 }]);
  });
});

describe('formatContentRange', () => {
  it('formats inclusive ranges', () => {
    expect(formatContentRange(0, 99, 100)).toBe('bytes 0-99/100');
  });
});

describe('trim-export cache', () => {
  it('stores, hits and clears entries', () => {
    clearTrimExportCache();
    const file = new File(['x'], 'a.mp4', { type: 'video/mp4' });
    expect(getCachedTrimExport('k')).toBeNull();
    setCachedTrimExport('k', { file, duration_ms: 100 });
    expect(getCachedTrimExport('k')?.file).toBe(file);
    clearTrimExportCache();
    expect(trimExportCacheSize()).toBe(0);
  });

  it('evicts the oldest entries past capacity', () => {
    clearTrimExportCache();
    const file = new File(['x'], 'a.mp4', { type: 'video/mp4' });
    for (let i = 0; i < 12; i++) setCachedTrimExport(`k${i}`, { file, duration_ms: i });
    expect(trimExportCacheSize()).toBeLessThanOrEqual(8);
    expect(getCachedTrimExport('k0')).toBeNull();
    expect(getCachedTrimExport('k11')?.duration_ms).toBe(11);
    clearTrimExportCache();
  });
});

describe('getOrExportTrimmedVideo', () => {
  it('passes images through without touching the DOM', async () => {
    const file = new File(['x'], 'a.png', { type: 'image/png' });
    const res = await getOrExportTrimmedVideo(file, 0, 1000, { durationMs: 5000 });
    expect(res.file).toBe(file);
    expect(res.trimmed).toBe(false);
  });

  it('skips export for full-length selections', async () => {
    const file = new File(['x'], 'a.mp4', { type: 'video/mp4' });
    const res = await getOrExportTrimmedVideo(file, 0, 60_000, { durationMs: 60_000 });
    expect(res.trimmed).toBe(false);
    expect(res.file).toBe(file);
  });

  it('serves cached exports without re-encoding', async () => {
    clearTrimExportCache();
    const src = new File(['x'], 'clip.mp4', { type: 'video/mp4' });
    const out = new File(['y'], 'clip-trim.mp4', { type: 'video/mp4' });
    const { fingerprintFile, trimCacheKeyFor } = await import('./createStudio');
    setCachedTrimExport(trimCacheKeyFor(fingerprintFile(src), 1000, 2000), { file: out, duration_ms: 1000 });
    const res = await getOrExportTrimmedVideo(src, 1000, 2000, { durationMs: 60_000 });
    expect(res.trimmed).toBe(true);
    expect(res.file).toBe(out);
    clearTrimExportCache();
  });
});

describe('finalizeStudioItem', () => {
  it('passes small images through (compressor skips them)', async () => {
    const file = new File(['x'], 'a.png', { type: 'image/png' });
    const res = await finalizeStudioItem({ file, kind: 'image', durationMs: 0 });
    expect(res.file).toBe(file);
    expect(res.exported).toBe(false);
  });

  it('keeps parametric offsets when no export is warranted', async () => {
    const file = new File(['x'], 'a.mp4', { type: 'video/mp4' });
    const res = await finalizeStudioItem({
      file, kind: 'video', trimStartMs: 0, trimEndMs: 60_000, durationMs: 60_000,
    });
    expect(res.exported).toBe(false);
    expect(res.offsetMs).toBe(0);
  });
});
