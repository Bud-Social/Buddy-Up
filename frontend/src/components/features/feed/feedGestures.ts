/**
 * Swipe-left-to-profile gesture helpers for the fullscreen video feed.
 *
 * A swipe is deliberate when it travels far enough left (dx < -threshold)
 * AND is horizontally dominant (|dx| exceeds |dy| by a ratio). Gestures that
 * start inside interactive surfaces (carousels, sliders, buttons, sheets)
 * are ignored by the caller via {@link SWIPE_IGNORE_SELECTOR}.
 */

export const SWIPE_DX_THRESHOLD = -80;
export const SWIPE_DOMINANCE_RATIO = 1.2;

/** Selectors whose touches must never trigger profile navigation. */
export const SWIPE_IGNORE_SELECTOR = [
  'button',
  'a',
  'input',
  'textarea',
  'select',
  '[role="dialog"]',
  '[role="slider"]',
  '[data-no-swipe]',
  '[data-carousel]',
  '.overflow-x-auto',
].join(', ');

/** Pure predicate, unit-tested. Deliberate = travels left past the threshold
 *  AND is horizontally dominant. */
export function isSwipeLeftToProfile(
  dx: number,
  dy: number,
  threshold = SWIPE_DX_THRESHOLD,
): boolean {
  if (dx >= threshold) return false;
  return Math.abs(dx) > Math.abs(dy) * SWIPE_DOMINANCE_RATIO;
}

/** True when the touch origin is inside an interactive surface. Pure helper. */
export function shouldIgnoreSwipeOrigin(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false;
  return target.closest(SWIPE_IGNORE_SELECTOR) !== null;
}
