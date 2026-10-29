import '@testing-library/jest-dom';
import { vi } from 'vitest';

/**
 * Pin the OAuth client id for the whole suite.
 *
 * `Login.tsx` and `GoogleAuthButton` read `import.meta.env.GOOGLE_CLIENT_ID`
 * at module scope and, when it is missing, render a *disabled* placeholder
 * that still carries the "Continue with Google" accessible name. `Register.tsx`
 * still reads `VITE_GOOGLE_CLIENT_ID`. Any test that drives real Google
 * sign-in therefore passed on a developer machine — where `frontend/.env`
 * supplies the id — and failed in CI, where that untracked file does not
 * exist: the placeholder was clicked, nothing happened, and the test waited
 * out its budget for a consent dialog that could never open.
 *
 * Setup files run before any test module is imported, so this is in place
 * before the module-scope reads happen. A test client id is enough: the flow
 * is stubbed at `window.google`.
 */
vi.stubEnv('GOOGLE_CLIENT_ID', 'test-google-client-id.apps.googleusercontent.com');
vi.stubEnv('VITE_GOOGLE_CLIENT_ID', 'test-google-client-id.apps.googleusercontent.com');

/**
 * jsdom implements neither `ResizeObserver` nor `matchMedia`.
 *
 * recharts' `ResponsiveContainer` measures its parent with `ResizeObserver` on
 * mount, so without this polyfill any component containing a chart throws
 * `ReferenceError: ResizeObserver is not defined` during render — and because
 * the exception escapes the React tree it is reported as an uncaught error that
 * fails whichever test happened to be running, not the one that rendered the
 * chart. No-op callbacks are correct here: the tests assert on the text, tables
 * and provenance notes around a chart, never on its pixel geometry.
 */
if (typeof globalThis.ResizeObserver === 'undefined') {
  globalThis.ResizeObserver = class ResizeObserverStub {
    observe() {}
    unobserve() {}
    disconnect() {}
  } as unknown as typeof globalThis.ResizeObserver;
}

if (typeof globalThis.matchMedia === 'undefined') {
  globalThis.matchMedia = ((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false,
  })) as unknown as typeof globalThis.matchMedia;
}