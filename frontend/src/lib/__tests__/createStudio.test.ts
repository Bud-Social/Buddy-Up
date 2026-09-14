/** Bud Press pure-logic tests: sanitization, filters, split partitioning. */
import { describe, expect, it } from 'vitest';
import {
  clampTrim, moveThumb,
  sanitizeEditMeta, filterCssAt, adjustCss,
  defaultEditMeta, splitTrim, partitionTimedElements,
  normalizeTrimExport, shouldExportTrimmedVideo, trimmedVideoBitrate,
  trimmedVideoFilename, rebaseTimedSegments, rebaseEditMetaForTrimmedVideo,
  rebaseCoverOffsetSeconds,
  type EditMeta,
} from '../createStudio';

const baseMeta = (): EditMeta => ({
  ...defaultEditMeta(),
  textOverlays: [{
    id: 'ov1', text: 'hi', start_ms: 100, end_ms: 500, y: 10, size: 1, color: 'white',
  }],
});

describe('clampTrim / moveThumb', () => {
  it('clamps selections past the cap keeping the out-point', () => {
    const r = clampTrim(0, 200_000, 300_000);
    expect(r.start_ms).toBe(20_000);
    expect(r.end_ms).toBe(200_000);
    expect(r.clamped).toBe(true);
  });

  it('moveThumb keeps thumbs valid', () => {
    const r = moveThumb('end', 50, { start_ms: 1000, end_ms: 2000 }, 300_000);
    expect(r.end_ms).toBe(1100);
  });
});

describe('sanitizeEditMeta', () => {
  it('returns undefined for default meta (no-ops dropped)', () => {
    expect(sanitizeEditMeta(defaultEditMeta())).toBeUndefined();
  });

  it('keeps creative-layer ids and emits seeded overlay fields', () => {
    const out = sanitizeEditMeta(baseMeta()) as Record<string, unknown>;
    expect(out.text_overlays).toEqual([{
      id: 'ov1', text: 'hi', start_ms: 100, end_ms: 500, y: 10, size: 1, color: 'white',
    }]);
  });

  it('passes extended overlay styling with ids intact', () => {
    const meta = baseMeta();
    meta.textOverlays[0] = {
      ...meta.textOverlays[0],
      x: 30, rotation: 5, font: 'neon', bg: 'pill', bg_color: '#111', animation: 'pop',
    };
    const out = sanitizeEditMeta(meta) as { text_overlays: Record<string, unknown>[] };
    expect(out.text_overlays[0]).toEqual({
      id: 'ov1',
      text: 'hi', start_ms: 100, end_ms: 500, y: 10, size: 1, color: 'white',
      x: 30, rotation: 5, font: 'neon', bg: 'pill', bg_color: '#111', animation: 'pop',
    });
  });

  it('emits stickers, tracks, adjust, aspect and caption style', () => {
    const meta = baseMeta();
    meta.adjust = { brightness: 80, contrast: 50, saturation: 20, vignette: 30 };
    meta.aspect = '4:5';
    meta.audioTracks = [{ id: 't1', kind: 'voiceover', url: 'https://res.cloudinary.com/x.mp3', volume: 120, start_ms: 0 }];
    meta.stickers = [{ id: 's1', kind: 'countdown', content: '', x: 50, y: 20, start_ms: 0, end_ms: 900, scale: 1 }];
    meta.captions_style = { preset: 'pop', size: 1.2 };
    const out = sanitizeEditMeta(meta) as Record<string, Record<string, unknown>>;
    expect(out.adjust).toEqual({ brightness: 80, saturation: 20, vignette: 30 });
    expect(out.aspect).toBe('4:5');
    expect(out.audio_tracks[0]).toMatchObject({ kind: 'voiceover', volume: 120, url: 'https://res.cloudinary.com/x.mp3' });
    expect(out.stickers[0]).toMatchObject({ kind: 'countdown' });
    expect(out.captions_style).toMatchObject({ preset: 'pop', size: 1.2 });
    expect(out.volume).toBeUndefined();
  });

  it('raciness guard: drops invalid stickers and empty overlays', () => {
    const meta = baseMeta();
    meta.textOverlays[0].text = '   ';
    meta.stickers = [{ id: 'bad', kind: 'percy', content: 'x', x: 0, y: 0, start_ms: 0, end_ms: 0, scale: 9 }];
    expect(sanitizeEditMeta(meta)).toBeUndefined();
  });
});

describe('filterCssAt strengths', () => {
  it('strength 0 is neutral and 100 is the full recipe', () => {
    expect(filterCssAt('vivid', 0)).toBe('');
    expect(filterCssAt('vivid', 100)).toBe('saturate(1.500) contrast(1.100)');
    expect(filterCssAt('vivid', 50)).toBe('saturate(1.250) contrast(1.050)');
  });

  it('unknown presets render empty', () => {
    expect(filterCssAt('??', 100)).toBe('');
  });
});

describe('adjustCss', () => {
  it('renders manual adjustments around neutral 50', () => {
    expect(adjustCss({ brightness: 50, contrast: 50, saturation: 50 })).toBe('');
    expect(adjustCss({ brightness: 100 })).toBe('brightness(2.400)');
    expect(adjustCss({ saturation: 0 })).toBe('saturate(0.300)');
  });
});

describe('splitting', () => {
  it('splitTrim splits the middle', () => {
    const [a, b] = splitTrim({ start_ms: 0, end_ms: 4000 });
    expect(a.end_ms).toBe(2000);
    expect(b.start_ms).toBe(2000);
  });

  it('partitionTimedElements keeps elements in the right half', () => {
    const els = [
      { text: '', start_ms: 0, end_ms: 1000 },
      { text: 'late', start_ms: 3000, end_ms: 4000 },
    ];
    const [left, right] = partitionTimedElements(els, [
      { start_ms: 0, end_ms: 2000 },
      { start_ms: 2000, end_ms: 4000 },
    ]);
    expect(left).toHaveLength(1);
    expect(right.map((e) => e.text)).toEqual(['late']);
  });
});

describe('trim export planning', () => {
  it('normalizes and detects a meaningful trim', () => {
    const plan = normalizeTrimExport(5_000, 15_000, 60_000);
    expect(plan).toEqual({ start_ms: 5_000, end_ms: 15_000, duration_ms: 10_000 });
    expect(shouldExportTrimmedVideo(plan)).toBe(true);
  });

  it('skips export for full-length selections and invalid ranges', () => {
    expect(shouldExportTrimmedVideo(normalizeTrimExport(0, 60_000, 60_000))).toBe(false);
    expect(normalizeTrimExport(1_000, 1_100, 60_000)).toBeNull();
    expect(normalizeTrimExport(0, 0, 0)).toBeNull();
  });

  it('targets source-like bitrates within sane bounds', () => {
    expect(trimmedVideoBitrate(12_000_000, 10_000, 60_000)).toBe(1_440_000);
    expect(trimmedVideoBitrate(1_000_000_000, 10_000, 60_000)).toBe(8_000_000);
    expect(trimmedVideoBitrate(null, 10_000)).toBe(4_000_000);
  });

  it('names trimmed files for the exported container', () => {
    expect(trimmedVideoFilename('clip.mp4', 'video/webm')).toBe('clip-trim.webm');
    expect(trimmedVideoFilename('clip.mov', 'video/mp4')).toBe('clip-trim.mp4');
  });
});

describe('trim export rebasing', () => {
  it('shifts and clips timed segments into snippet coordinates', () => {
    const out = rebaseTimedSegments([
      { id: 'a', start_ms: 4_000, end_ms: 7_000 },
      { id: 'b', start_ms: 14_000, end_ms: 18_000 },
      { id: 'c', start_ms: 20_000, end_ms: 25_000 },
    ], 5_000, 10_000);
    expect(out).toEqual([
      { id: 'a', start_ms: 0, end_ms: 2_000 },
      { id: 'b', start_ms: 9_000, end_ms: 10_000 },
    ]);
  });

  it('rebases edit metadata tracks and preserves indefinite tracks', () => {
    const meta = baseMeta();
    meta.textOverlays = [{ id: 'ov1', text: 'hi', start_ms: 6_000, end_ms: 8_000, y: 10, size: 1, color: 'white' }];
    meta.audioTracks = [
      { id: 't1', kind: 'voiceover', url: 'https://example.com/a.mp3', volume: 100, start_ms: 4_000 },
      { id: 't2', kind: 'url', url: 'https://example.com/b.mp3', volume: 100, start_ms: 12_000, duration_ms: 5_000 },
      { id: 't3', kind: 'url', url: 'https://example.com/c.mp3', volume: 100, start_ms: 30_000, duration_ms: 1_000 },
    ];
    const out = rebaseEditMetaForTrimmedVideo(meta, 5_000, 10_000);
    expect(out.textOverlays).toEqual([
      { id: 'ov1', text: 'hi', start_ms: 1_000, end_ms: 3_000, y: 10, size: 1, color: 'white' },
    ]);
    expect(out.audioTracks).toEqual([
      { id: 't1', kind: 'voiceover', url: 'https://example.com/a.mp3', volume: 100, start_ms: 0 },
      { id: 't2', kind: 'url', url: 'https://example.com/b.mp3', volume: 100, start_ms: 7_000, duration_ms: 3_000 },
    ]);
  });

  it('rebases cover offsets into snippet coordinates', () => {
    expect(rebaseCoverOffsetSeconds(7.5, 5_000, 10_000)).toBeCloseTo(2.5);
    expect(rebaseCoverOffsetSeconds(null, 5_000, 10_000)).toBeNull();
  });
});
