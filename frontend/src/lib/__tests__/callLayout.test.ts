import { describe, expect, it } from 'vitest';
import { callLayout } from '../callLayout';

describe('callLayout', () => {
  it('keeps the 1:1 stage for two people', () => {
    expect(callLayout(2, 'video')).toBe('video');
    expect(callLayout(2, 'audio')).toBe('voice');
  });

  it('switches to equal tiles as soon as a third person joins', () => {
    expect(callLayout(3, 'video')).toBe('group-grid');
    expect(callLayout(3, 'audio')).toBe('group-grid');
    expect(callLayout(6, 'video')).toBe('group-grid');
  });
});
