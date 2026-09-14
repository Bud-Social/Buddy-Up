import { describe, expect, it } from 'vitest';
import {
  isSwipeLeftToProfile,
  shouldIgnoreSwipeOrigin,
  SWIPE_DX_THRESHOLD,
} from '../feedGestures';

describe('isSwipeLeftToProfile', () => {
  it(`requires dx strictly below ${SWIPE_DX_THRESHOLD}`, () => {
    expect(isSwipeLeftToProfile(-81, 0)).toBe(true);
    expect(isSwipeLeftToProfile(-80, 0)).toBe(false);
    expect(isSwipeLeftToProfile(-79, 0)).toBe(false);
    expect(isSwipeLeftToProfile(50, 0)).toBe(false);
  });

  it('requires horizontal dominance over vertical travel', () => {
    expect(isSwipeLeftToProfile(-100, 50)).toBe(true);
    // Mostly-vertical scroll must not trigger navigation.
    expect(isSwipeLeftToProfile(-100, 90)).toBe(false);
    expect(isSwipeLeftToProfile(-90, -200)).toBe(false);
  });

  it('accepts a custom threshold', () => {
    expect(isSwipeLeftToProfile(-50, 0, -40)).toBe(true);
    expect(isSwipeLeftToProfile(-30, 0, -40)).toBe(false);
  });
});

describe('shouldIgnoreSwipeOrigin', () => {
  it('ignores touches from interactive surfaces', () => {
    const btn = document.createElement('button');
    expect(shouldIgnoreSwipeOrigin(btn)).toBe(true);

    const carouselChild = document.createElement('div');
    const carousel = document.createElement('div');
    carousel.className = 'overflow-x-auto';
    carousel.appendChild(carouselChild);
    document.body.appendChild(carousel);
    expect(shouldIgnoreSwipeOrigin(carouselChild)).toBe(true);
    carousel.remove();

    const dialogChild = document.createElement('span');
    const dialog = document.createElement('div');
    dialog.setAttribute('role', 'dialog');
    dialog.appendChild(dialogChild);
    document.body.appendChild(dialog);
    expect(shouldIgnoreSwipeOrigin(dialogChild)).toBe(true);
    dialog.remove();
  });

  it('allows touches from the plain video surface', () => {
    const surface = document.createElement('div');
    document.body.appendChild(surface);
    expect(shouldIgnoreSwipeOrigin(surface)).toBe(false);
    surface.remove();
    expect(shouldIgnoreSwipeOrigin(null)).toBe(false);
  });
});
