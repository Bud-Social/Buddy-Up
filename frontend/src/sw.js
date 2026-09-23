/*
 * BuddyUp Fit service worker — hand-written, bundled via vite-plugin-pwa
 * injectManifest (the manifest is injected at self.__WB_MANIFEST).
 *
 * Why hand-written instead of generateSW: generateSW registers its
 * NavigationRoute BEFORE all runtime routes, and workbox serves from the
 * first matching route. With index.html deliberately excluded from the
 * precache, every navigation matched the NavigationRoute and was answered
 * with the precached offline.html without ever touching the network — the
 * whole site appeared permanently offline until site data was cleared.
 * (Also note: workbox RegExpRoute tests patterns against the FULL url.href,
 * so same-origin path-anchored regexes never match on cross-origin-style
 * hrefs — path-based routing here uses explicit callback matchers instead.)
 *
 * Route order below is load-bearing, first match wins:
 *   1. precache          — hashed build assets (cache-first, revisoned)
 *   2. fonts / images    — cache-first runtime caches
 *   3. /api/ GET         — network-first, short TTL cache
 *   4. same-origin GET   — network-first: navigations get fresh HTML when
 *                          online, cached shell on slow networks, and the
 *                          precached offline.html ONLY as the last resort
 *                          (network failed AND nothing cached) via
 *                          setCatchHandler.
 */
import { clientsClaim } from 'workbox-core';
import {
  cleanupOutdatedCaches,
  createHandlerBoundToURL,
  precacheAndRoute,
} from 'workbox-precaching';
import { registerRoute, setCatchHandler } from 'workbox-routing';
import { CacheFirst, NetworkFirst } from 'workbox-strategies';
import { CacheableResponsePlugin } from 'workbox-cacheable-response';
import { ExpirationPlugin } from 'workbox-expiration';

// Web-push handlers (push / notificationclick / pushsubscriptionchange) live
// in /service-worker-push.js — loaded inside this worker, same as before.
self.importScripts('/service-worker-push.js');

precacheAndRoute(self.__WB_MANIFEST);
cleanupOutdatedCaches();

// Apply updates as soon as they're installed: the new worker takes control
// immediately instead of waiting for every tab to close.
self.skipWaiting();
clientsClaim();

const cacheable = () => new CacheableResponsePlugin({ statuses: [0, 200] });

registerRoute(
  ({ url }) => url.origin === 'https://fonts.googleapis.com' || url.origin === 'https://fonts.gstatic.com',
  new CacheFirst({
    cacheName: 'google-fonts-cache',
    plugins: [new ExpirationPlugin({ maxEntries: 30, maxAgeSeconds: 60 * 60 * 24 * 30 }), cacheable()],
  }),
);

registerRoute(
  ({ url, request }) =>
    request.method === 'GET' && /^https:\/\/.*\.(png|jpg|jpeg|webp|avif|gif|svg)(\?.*)?$/i.test(url.href),
  new CacheFirst({
    // -v2 name: existing visitors' old runtime cache is orphaned on activate
    // instead of continuing to serve week-old images.
    cacheName: 'image-cache-v2',
    plugins: [new ExpirationPlugin({ maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 }), cacheable()],
  }),
);

registerRoute(
  ({ url, request }) =>
    request.method === 'GET' && url.origin === self.location.origin && url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-cache-v3',
    networkTimeoutSeconds: 10,
    plugins: [new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 60 * 5 }), cacheable()],
  }),
);

// Navigations (and any other same-origin GET not claimed above): network
// first with a generous timeout so slow mobile networks never trip the
// offline page while online; the cache is a fallback-only HTML shell with a
// short TTL so a cached page never outlives an hour.
registerRoute(
  ({ url, request }) =>
    request.method === 'GET' && url.origin === self.location.origin,
  new NetworkFirst({
    cacheName: 'navigation-cache-v3',
    networkTimeoutSeconds: 10,
    plugins: [new ExpirationPlugin({ maxEntries: 20, maxAgeSeconds: 60 * 60 }), cacheable()],
  }),
);

// Last resort — network threw AND the runtime cache had nothing: serve the
// branded offline shell for navigations, error out everything else. This is
// the ONLY path that can produce offline.html.
const offlineHandler = createHandlerBoundToURL('/offline.html');
setCatchHandler(async ({ event }) => {
  if (event.request.mode === 'navigate') {
    return offlineHandler({ event, request: event.request });
  }
  return Response.error();
});
