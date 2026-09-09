/**
 * Reduced-motion accessibility preference (Settings → Appearance).
 * Device-level: persisted in localStorage and applied as a `reduce-motion`
 * class on <html> which collapses all animations/transitions via CSS.
 */
export const REDUCED_MOTION_KEY = 'bu_reduced_motion';
export const REDUCED_MOTION_CLASS = 'reduce-motion';

export function isReducedMotionEnabled(): boolean {
  try {
    return window.localStorage.getItem(REDUCED_MOTION_KEY) === 'on';
  } catch {
    return false;
  }
}

export function setReducedMotionEnabled(enabled: boolean): void {
  try {
    window.localStorage.setItem(REDUCED_MOTION_KEY, enabled ? 'on' : 'off');
  } catch {
    // Storage unavailable — still apply the class for this page view.
  }
  document.documentElement.classList.toggle(REDUCED_MOTION_CLASS, enabled);
}

/** Apply the persisted preference on app boot. */
export function initReducedMotion(): void {
  document.documentElement.classList.toggle(REDUCED_MOTION_CLASS, isReducedMotionEnabled());
}
