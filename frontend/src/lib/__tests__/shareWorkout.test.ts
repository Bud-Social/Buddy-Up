import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  ANALYTICS_PATH,
  analyticsShareUrl,
  buildShareText,
  shareActivity,
} from '../shareWorkout';

const PAYLOAD = { title: 'Strength on BuddyUp', text: 'Strength — 45 min.', url: 'https://app.example/app/analytics' };

function stub(obj: object, key: string, value: unknown) {
  Object.defineProperty(obj, key, { value, configurable: true, writable: true });
}

function cleanup(obj: object, key: string) {
  delete (obj as Record<string, unknown>)[key];
}

beforeEach(() => {
  stub(navigator, 'clipboard', { writeText: vi.fn().mockResolvedValue(undefined) });
});

afterEach(() => {
  cleanup(navigator, 'clipboard');
  cleanup(navigator, 'share');
});

describe('shareActivity', () => {
  it('uses the native share sheet when the platform has one', async () => {
    const share = vi.fn().mockResolvedValue(undefined);
    stub(navigator, 'share', share);

    await expect(shareActivity(PAYLOAD)).resolves.toBe('shared');
    expect(share).toHaveBeenCalledWith({ title: PAYLOAD.title, text: PAYLOAD.text, url: PAYLOAD.url });
    expect(navigator.clipboard.writeText).not.toHaveBeenCalled();
  });

  it('copies the link when there is no native sheet', async () => {
    await expect(shareActivity(PAYLOAD)).resolves.toBe('copied');
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(PAYLOAD.url);
  });

  it('treats a dismissed share sheet as cancelled, not a failure', async () => {
    stub(navigator, 'share', vi.fn().mockRejectedValue(Object.assign(new Error('nope'), { name: 'AbortError' })));
    await expect(shareActivity(PAYLOAD)).resolves.toBe('cancelled');
    expect(navigator.clipboard.writeText).not.toHaveBeenCalled();
  });

  it('falls back to copying when the sheet throws for any other reason', async () => {
    stub(navigator, 'share', vi.fn().mockRejectedValue(new Error('sheet unavailable')));
    await expect(shareActivity(PAYLOAD)).resolves.toBe('copied');
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(PAYLOAD.url);
  });

  it('never throws when the clipboard rejects and the legacy copy fails', async () => {
    (navigator.clipboard.writeText as ReturnType<typeof vi.fn>).mockRejectedValue(new Error('blocked'));
    (document as unknown as { execCommand: () => boolean }).execCommand = () => false;
    await expect(shareActivity(PAYLOAD)).resolves.toBe('failed');
  });

  it('uses the legacy textarea copy when no clipboard API exists', async () => {
    cleanup(navigator, 'clipboard');
    let copied = '';
    (document as unknown as { execCommand: () => boolean }).execCommand = () => {
      copied = document.querySelector('textarea')?.value ?? '';
      return true;
    };
    await expect(shareActivity(PAYLOAD)).resolves.toBe('copied');
    expect(copied).toBe(PAYLOAD.url);
  });
});

describe('buildShareText', () => {
  it('includes category, duration, distance and calories', () => {
    const text = buildShareText({
      label: 'Strength',
      category: 'upper',
      durationMinutes: 45.4,
      distanceKm: 5,
      calories: 320.6,
    });
    expect(text).toBe('Strength · upper — 45 min · 5.0 km · 321 kcal. Logged on BuddyUp.');
  });

  it('omits the metrics a workout type never records', () => {
    expect(buildShareText({ label: 'Yoga', category: 'vinyasa', durationMinutes: 30 }))
      .toBe('Yoga · vinyasa — 30 min. Logged on BuddyUp.');
  });

  it('keeps sub-kilometre distances readable and rounds long ones', () => {
    expect(buildShareText({ label: 'Run', distanceKm: 0.86 })).toContain('0.9 km');
    expect(buildShareText({ label: 'Run', distanceKm: 12.34 })).toContain('12 km');
  });

  it('does not emit empty segments for a bare log', () => {
    expect(buildShareText({ label: 'Other' })).toBe('Other. Logged on BuddyUp.');
  });
});

describe('analyticsShareUrl', () => {
  it('points at the analytics deep link', () => {
    expect(ANALYTICS_PATH).toBe('/app/analytics');
    expect(analyticsShareUrl(undefined, 'https://app.example')).toBe('https://app.example/app/analytics');
  });
});