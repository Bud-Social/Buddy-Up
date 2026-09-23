import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import path from 'path';

export default defineConfig({
  // Baked-in build stamp for triage: console + update flow can report
  // exactly which build a stuck client is running.
  define: {
    __BUILD_TIME__: JSON.stringify(new Date().toISOString()),
  },
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      // Custom service worker (src/sw.js) instead of generateSW: the generated
      // SW registers its NavigationRoute BEFORE runtime routes, so every
      // navigation was answered with the precached offline.html without ever
      // touching the network — the whole site looked permanently offline.
      // src/sw.js implements network-first navigations with offline.html as
      // a true last-resort only. See the route-order notes there.
      strategies: 'injectManifest',
      filename: 'sw.js',
      srcDir: 'src',
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
      injectManifest: {
        // NOTE: deliberately NO 'html' in globPatterns — index.html must not
        // be precached (serving the app shell from precache made updates
        // never appear until a double reload). Navigations go network-first
        // via the route in src/sw.js; offline.html is precached explicitly
        // below as the last-resort fallback. Bump its revision whenever
        // offline.html changes.
        globPatterns: ['**/*.{js,css,svg,png,ico,woff2}'],
        additionalManifestEntries: [
          { url: '/offline.html', revision: 'offline-rescue-2026-09-23' },
        ],
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
