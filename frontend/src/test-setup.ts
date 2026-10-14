import '@testing-library/jest-dom';

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