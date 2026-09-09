import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import {
  maskProfanity, isProfanityFilterEnabled, setProfanityFilterEnabled, PROFANITY_FILTER_KEY,
} from '@/lib/profanity';

describe('maskProfanity', () => {
  it('returns empty and non-matching text unchanged', () => {
    expect(maskProfanity('')).toBe('');
    expect(maskProfanity('Push day went great, new PR on bench!')).toBe(
      'Push day went great, new PR on bench!',
    );
  });

  it('masks a word keeping the first letter ("hell" → "h***")', () => {
    expect(maskProfanity('what the hell')).toBe('what the h***');
  });

  it('is case-insensitive and preserves original casing of the first letter', () => {
    expect(maskProfanity('What the HELL')).toBe('What the H***');
  });

  it('matches whole words only (no substring hits)', () => {
    expect(maskProfanity('assessment and classic and Shirly')).toBe('assessment and classic and Shirly');
    expect(maskProfanity('a shattered glass')).toBe('a shattered glass');
  });

  it('masks multiple different words in one pass', () => {
    expect(maskProfanity('shit, that damn bar was heavy')).toBe('s***, that d*** bar was heavy');
  });

  it('handles punctuation boundaries', () => {
    expect(maskProfanity('Hell!')).toBe('H***!');
  });
});

describe('profanity filter preference', () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  afterEach(() => {
    window.localStorage.clear();
  });

  it('defaults to enabled when unset', () => {
    expect(isProfanityFilterEnabled()).toBe(true);
  });

  it('persists the on/off state', () => {
    setProfanityFilterEnabled(false);
    expect(window.localStorage.getItem(PROFANITY_FILTER_KEY)).toBe('off');
    expect(isProfanityFilterEnabled()).toBe(false);
    setProfanityFilterEnabled(true);
    expect(window.localStorage.getItem(PROFANITY_FILTER_KEY)).toBe('on');
    expect(isProfanityFilterEnabled()).toBe(true);
  });
});
