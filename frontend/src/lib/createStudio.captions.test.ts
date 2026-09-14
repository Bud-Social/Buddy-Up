/** Multiclip caption ownership, partitioning, rebase planning + history. */
import { describe, expect, it } from 'vitest';
import {
  cleanCaptionSegments,
  cloneCaptionSegments,
  countCaptions,
  fingerprintFile,
  newCaptionId,
  partitionCaptionsForSplit,
  planCaptionsForItems,
  splitTrim,
  trimCacheKeyFor,
  UndoStack,
} from './createStudio';

describe('cleanCaptionSegments', () => {
  it('drops empty text and inverted ranges, rounds and trims', () => {
    const out = cleanCaptionSegments([
      { start_ms: 1000.4, end_ms: 2000.6, text: '  hi  ' },
      { start_ms: 0, end_ms: 0, text: '' },
      { start_ms: 5, end_ms: 5, text: 'x' },
      { start_ms: 3000, end_ms: 2000, text: 'backwards' },
    ]);
    expect(out).toEqual([{ start_ms: 1000, end_ms: 2001, text: 'hi' }]);
  });

  it('caps text length at 500 chars', () => {
    const out = cleanCaptionSegments([{ start_ms: 0, end_ms: 100, text: 'a'.repeat(600) }]);
    expect(out[0].text).toHaveLength(500);
  });
});

describe('planCaptionsForItems', () => {
  it('keeps non-exported clips untouched and rebases exported ones', () => {
    const out = planCaptionsForItems(
      {
        a: [{ id: 's1', start_ms: 1000, end_ms: 2000, text: 'hey' }],
        b: [{ id: 's2', start_ms: 6000, end_ms: 8000, text: 'yo' }],
      },
      new Map([
        ['a', { offsetMs: 0, durationMs: 5000, exported: false }],
        ['b', { offsetMs: 5000, durationMs: 10000, exported: true }],
      ]),
    );
    expect(out.a).toEqual([{ start_ms: 1000, end_ms: 2000, text: 'hey' }]);
    expect(out.b).toEqual([{ start_ms: 1000, end_ms: 3000, text: 'yo' }]);
  });

  it('omits clips whose captions rebase to nothing or are empty', () => {
    const out = planCaptionsForItems(
      {
        empty: [],
        outside: [{ id: 's', start_ms: 50_000, end_ms: 60_000, text: 'gone' }],
      },
      { outside: { offsetMs: 0, durationMs: 10_000, exported: true } },
    );
    expect(out).toEqual({});
  });
});

describe('split partitioning', () => {
  it('partitions captions by midpoint like overlays', () => {
    const [left, right] = splitTrim({ start_ms: 0, end_ms: 4000 });
    const [l, r] = partitionCaptionsForSplit(
      [
        { id: 'early', start_ms: 0, end_ms: 1000, text: 'a' },
        { id: 'late', start_ms: 3000, end_ms: 4000, text: 'b' },
        { id: 'span', start_ms: 1000, end_ms: 3000, text: 'midpoint lands right' },
      ],
      left,
      right,
    );
    expect(l.map((s) => s.id)).toEqual(['early']);
    expect(r.map((s) => s.id).sort()).toEqual(['late', 'span']);
  });
});

describe('cloneCaptionSegments', () => {
  it('copies content with fresh ids', () => {
    const src = [{ id: 'orig', start_ms: 10, end_ms: 20, text: 'x' }];
    const cloned = cloneCaptionSegments(src);
    expect(cloned).toHaveLength(1);
    expect(cloned[0]).toMatchObject({ start_ms: 10, end_ms: 20, text: 'x' });
    expect(cloned[0].id).not.toBe('orig');
  });
});

describe('countCaptions / newCaptionId', () => {
  it('counts per item and tolerates missing maps', () => {
    expect(countCaptions({ a: [{ id: '1', start_ms: 0, end_ms: 1, text: 't' }] }, 'a')).toBe(1);
    expect(countCaptions({}, 'a')).toBe(0);
    expect(countCaptions(null, 'a')).toBe(0);
  });

  it('mints unique ids', () => {
    expect(newCaptionId()).not.toBe(newCaptionId());
  });
});

describe('fingerprintFile / trimCacheKeyFor', () => {
  const file = { name: 'clip.mp4', size: 123, type: 'video/mp4', lastModified: 7 };

  it('is stable for the same bytes and sensitive to size/trim', () => {
    expect(fingerprintFile(file)).toBe(fingerprintFile({ ...file }));
    expect(fingerprintFile({ ...file, size: 124 })).not.toBe(fingerprintFile(file));
    const fp = fingerprintFile(file);
    expect(trimCacheKeyFor(fp, 0, 1000)).not.toBe(trimCacheKeyFor(fp, 0, 2000));
    expect(trimCacheKeyFor(fp, 0, 1000)).toBe(trimCacheKeyFor(fp, 0, 1000));
  });
});

describe('UndoStack', () => {
  it('undoes and redoes in order', () => {
    const h = new UndoStack<number>();
    expect(h.canUndo).toBe(false);
    h.push(1);
    h.push(2);
    expect(h.undo(3)).toBe(2);
    expect(h.canRedo).toBe(true);
    expect(h.redo(3)).toBe(3);
    expect(h.canRedo).toBe(false);
  });

  it('clears redo on a fresh push and caps depth', () => {
    const h = new UndoStack<number>(3);
    h.push(1);
    h.push(2);
    h.undo(3);
    h.push(4);
    expect(h.canRedo).toBe(false);
    h.push(5);
    h.push(6);
    expect(h.depth).toBe(3);
  });

  it('returns null when there is nothing to undo/redo', () => {
    const h = new UndoStack<number>();
    expect(h.undo(1)).toBeNull();
    expect(h.redo(1)).toBeNull();
  });
});
