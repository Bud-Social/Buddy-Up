import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import path from 'path';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      // offline.html is precached explicitly (it is the navigateFallback, and
      // workbox throws non-precached-url at SW install when the fallback is
      // missing from the precache manifest). index.html stays OUT of the
      // precache deliberately — see globPatterns note below.
      includeAssets: ['icons/*.svg', 'favicon-*.png', 'offline.html'],
      manifest: {
        name: 'BuddyUp Fit',
        short_name: 'BuddyUp Fit',
        description: 'Health & fitness social platform — train with buddies, join live workouts, eat better.',
        theme_color: '#0A0A0A',
        background_color: '#0A0A0A',
        display: 'standalone',
        start_url: '/',
        scope: '/',
        icons: [
          { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
          { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
          { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
      workbox: {
        // Web-push handlers live here (loaded inside the generated SW).
        // There must be exactly ONE service worker: the generated /sw.js.
        importScripts: ['/service-worker-push.js'],
        // NOTE: deliberately NO 'html' in globPatterns. Precaching index.html
        // made the precache route short-circuit navigations and serve stale
        // builds to returning visitors — updates never appeared until a
        // double reload. Navigations now go network-first via the navigation
        // runtime rule below; offline.html is still auto-precached as the
        // navigateFallback for offline visits.
        globPatterns: ['**/*.{js,css,svg,png,ico,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: { maxEntries: 30, maxAgeSeconds: 60 * 60 * 24 * 30 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: { maxEntries: 30, maxAgeSeconds: 60 * 60 * 24 * 30 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: /^https:\/\/.*\.(png|jpg|jpeg|webp|avif|gif|svg)(\?.*)?$/i,
            handler: 'CacheFirst',
            options: {
              // -v2 names: existing visitors' old runtime caches are orphaned
              // on activate instead of continuing to serve week-old images.
              cacheName: 'image-cache-v2',
              expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: /^\/api\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache-v2',
              expiration: { maxEntries: 50, maxAgeSeconds: 60 * 5 },
              networkTimeoutSeconds: 10,
              cacheableResponse: { statuses: [0, 200] },
            },
          },
          {
            urlPattern: /^\/.*/i,
            handler: 'NetworkFirst',
            options: {
              // Fallback-only HTML cache: short timeout so online visitors
              // always get the fresh deployment, short TTL so a cached page
              // never outlives an hour.
              cacheName: 'navigation-cache-v2',
              expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 },
              networkTimeoutSeconds: 3,
              cacheableResponse: { statuses: [0, 200] },
            },
          },
        ],
        navigateFallback: '/offline.html',
        navigateFallbackDenylist: [/\/api\//],
      },
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3002,
    strictPort: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
  },
});
