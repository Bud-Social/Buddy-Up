/** Draft caption compat (per-clip vs legacy single-list) + quota reporting. */
import { describe, expect, it } from 'vitest';
import {
  extractCaptionsByItem,
  isQuotaError,
  saveStudioDraft,
  loadStudioDraft,
  clearStudioDraft,
  type StudioDraft,
} from './createDrafts';

const item = (id: string, extra: Record<string, unknown> = {}) => ({
  id,
  kind: 'video' as const,
  name: `${id}.mp4`,
  type: 'video/mp4',
  size: 10,
  blob: new Blob(['x']),
  ...extra,
});

describe('extractCaptionsByItem', () => {
  it('prefers per-item captions', () => {
    const draft: StudioDraft = {
      savedAt: 1, text: '', hashtags: '', visibility: 'public', commentsDisabled: false,
      items: [item('a', { captions: [{ start_ms: 0, end_ms: 100, text: 'hi' }] })],
      captions: [{ start_ms: 0, end_ms: 100, text: 'legacy' }],
      caption_item_id: 'a',
    };
    expect(extractCaptionsByItem(draft)).toEqual({
      a: [{ start_ms: 0, end_ms: 100, text: 'hi' }],
    });
  });

  it('migrates a legacy single list to its owner (or first video)', () => {
    const draft: StudioDraft = {
      savedAt: 1, text: '', hashtags: '', visibility: 'public', commentsDisabled: false,
      items: [item('a'), item('b')],
      captions: [{ start_ms: 0, end_ms: 100, text: 'legacy' }],
      caption_item_id: 'b',
    };
    expect(extractCaptionsByItem(draft)).toEqual({
      b: [{ start_ms: 0, end_ms: 100, text: 'legacy' }],
    });
    const noOwner: StudioDraft = { ...draft, caption_item_id: 'gone' };
    expect(extractCaptionsByItem(noOwner)).toEqual({
      a: [{ start_ms: 0, end_ms: 100, text: 'legacy' }],
    });
  });

  it('returns {} without captions and never throws on junk', () => {
    expect(extractCaptionsByItem(null)).toEqual({});
    expect(extractCaptionsByItem(undefined)).toEqual({});
    expect(extractCaptionsByItem({ items: [] } as unknown as StudioDraft)).toEqual({});
  });
});

describe('isQuotaError', () => {
  it('detects quota errors across browsers', () => {
    expect(isQuotaError({ name: 'QuotaExceededError' })).toBe(true);
    expect(isQuotaError({ name: 'NS_ERROR_DOM_QUOTA_REACHED' })).toBe(true);
    expect(isQuotaError({ code: 22 })).toBe(true);
    expect(isQuotaError(new Error('nope'))).toBe(false);
    expect(isQuotaError(null)).toBe(false);
  });
});

describe('save/load round-trip', () => {
  it('keeps per-item captions and never throws', async () => {
    await clearStudioDraft();
    const draft: StudioDraft = {
      savedAt: 1, text: 'hello', hashtags: '', visibility: 'public', commentsDisabled: false,
      items: [item('a', { captions: [{ start_ms: 0, end_ms: 100, text: 'hi' }] })],
    };
    const res = await saveStudioDraft(draft);
    expect(res.ok).toBe(true);
    const loaded = await loadStudioDraft();
    expect(loaded?.text).toBe('hello');
    expect(loaded?.items[0].captions).toEqual([{ start_ms: 0, end_ms: 100, text: 'hi' }]);
    await clearStudioDraft();
    expect(await loadStudioDraft()).toBeNull();
  });
});
