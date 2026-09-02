import { describe, it, expect } from 'vitest';
import {
  clampTrim,
  moveThumb,
  coverPosterUrl,
  formatCoverOffset,
  formatMs,
  buildMediaPayload,
  MAX_TRIM_MS,
} from './createStudio';
import type { PublishableMediaItem } from './createStudio';

describe('clampTrim', () => {
  it('keeps a valid selection untouched', () => {
    const r = clampTrim(1000, 5000, 60_000);
    expect(r).toEqual({ start_ms: 1000, end_ms: 5000, clamped: false });
  });

  it('clamps out-of-range bounds to [0, duration]', () => {
    const r = clampTrim(-500, 999_999, 30_000);
    expect(r.start_ms).toBe(0);
    expect(r.end_ms).toBe(30_000);
  });

  it('resets an inverted selection to the last second', () => {
    const r = clampTrim(10_000, 2_000, 30_000);
    expect(r.start_ms).toBe(29_000);
    expect(r.end_ms).toBe(30_000);
  });

  it('caps selections longer than 180s, keeping the out point', () => {
    const r = clampTrim(0, 200_000, 300_000);
    expect(r.end_ms).toBe(200_000);
    expect(r.start_ms).toBe(200_000 - MAX_TRIM_MS);
    expect(r.clamped).toBe(true);
  });

  it('resets a selection that degenerates at the media bounds', () => {
    // start == end after clamping to the duration → falls back to the final second
    const r = clampTrim(500_000, 800_000, 500_000, 100_000);
    expect(r.start_ms).toBe(499_000);
    expect(r.end_ms).toBe(500_000);
  });
});

describe('moveThumb', () => {
  const base = { start_ms: 1000, end_ms: 10_000 };

  it('moves the start thumb and keeps a positive selection', () => {
    const r = moveThumb('start', 9_980, base, 60_000);
    expect(r.start_ms).toBe(9_900);
    expect(r.end_ms).toBe(10_000);
  });

  it('keeps the end thumb inside the duration', () => {
    const r = moveThumb('end', 999_999, base, 20_000);
    expect(r.end_ms).toBe(20_000);
  });

  it('caps the length when dragging the end thumb', () => {
    const r = moveThumb('end', 400_000, { start_ms: 0, end_ms: 1000 }, 500_000);
    expect(r.end_ms).toBe(MAX_TRIM_MS);
    expect(r.clamped).toBe(true);
  });
});

describe('coverPosterUrl', () => {
  it('appends the cloudinary so_ offset', () => {
    expect(coverPosterUrl('https://res.cloudinary.com/x/video/upload/v.mp4', 1.5))
      .toBe('https://res.cloudinary.com/x/video/upload/v.mp4?so_1.5');
  });

  it('rounds offsets to 2 decimals', () => {
    expect(formatCoverOffset(1.23456)).toBe('so_1.23');
    expect(coverPosterUrl('u.mp4', 0)).toBe('u.mp4?so_0');
  });

  it('returns undefined without url or offset', () => {
    expect(coverPosterUrl(undefined, 1)).toBeUndefined();
    expect(coverPosterUrl('u.mp4', null)).toBeUndefined();
    expect(coverPosterUrl('u.mp4', -1)).toBeUndefined();
  });
});

describe('formatMs', () => {
  it('formats minutes and tenths', () => {
    expect(formatMs(65_400)).toBe('1:05.4');
    expect(formatMs(400)).toBe('0:00.4');
  });
});

describe('buildMediaPayload', () => {
  const base: PublishableMediaItem = {
    kind: 'image',
    media: { url: 'https://cdn/img.webp', width: 1000, height: 800, bytes: 12_345 },
  };

  it('maps a simple image item', () => {
    const [out] = buildMediaPayload([base]);
    expect(out).toEqual({
      url: 'https://cdn/img.webp',
      media_type: 'image',
      width: 1000,
      height: 800,
    });
  });

  it('maps a trimmed video with sound, cover and alt text', () => {
    const [out] = buildMediaPayload([{
      kind: 'video',
      media: { url: 'https://cdn/v.mp4', duration_ms: 30_000, poster_url: 'https://cdn/v-poster.jpg' },
      trim_start_ms: 1000,
      trim_end_ms: 15_000,
      sound: { id: 's1', volume: 60 },
      alt_text: 'Deadlift PR',
      coverOffsetSec: 2.5,
    }]);
    expect(out).toEqual({
      url: 'https://cdn/v.mp4',
      media_type: 'video',
      duration_ms: 30_000,
      poster_url: 'https://cdn/v.mp4?so_2.5',
      trim_start_ms: 1000,
      trim_end_ms: 15_000,
      sound_id: 's1',
      sound_volume: 60,
      alt_text: 'Deadlift PR',
    });
  });

  it('prefers the auto poster when no cover offset is set', () => {
    const [out] = buildMediaPayload([{
      kind: 'video',
      media: { url: 'https://cdn/v.mp4', poster_url: 'https://cdn/auto.jpg' },
    }]);
    expect(out.poster_url).toBe('https://cdn/auto.jpg');
  });

  it('omits zero trims and ignores sound on images', () => {
    const [out] = buildMediaPayload([{
      ...base,
      kind: 'image',
      trim_start_ms: 0,
      sound: { id: 's1', volume: 50 },
    }]);
    expect(out.trim_start_ms).toBeUndefined();
    expect(out.sound_id).toBeUndefined();
  });

  it('caps the payload at 12 items', () => {
    const many = Array.from({ length: 15 }, () => ({ ...base }));
    expect(buildMediaPayload(many)).toHaveLength(12);
  });
});
