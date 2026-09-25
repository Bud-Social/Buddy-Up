#!/usr/bin/env node
/**
 * CORS preflight guardrail for the production API host.
 *
 * Browsers refuse to follow redirects on CORS preflight (OPTIONS)
 * responses. If the API host (snapdeploy/Cloudflare) answers OPTIONS with
 * a 301/302/307/308 — e.g. an apex→www or http→https redirect rule — every
 * cross-origin apiClient call fails with an opaque CORS error even though
 * the backend itself is healthy (this is what previously forced the
 * contact/suggestion forms onto same-origin Vercel serverless functions).
 *
 * Usage:
 *   npm run check:preflight -- https://api.buddyup.app
 *   API_BASE_URL=https://api.buddyup.app npm run check:preflight
 *
 * Exits 0 only when the preflight returns 2xx with the expected CORS
 * headers; exits 1 on a redirect/CORS failure; exits 2 on bad usage.
 */

const WEB_ORIGIN = 'https://buddyupfit.com';
const PROBE_PATH = '/api/v1/auth/token/refresh/';

const base = process.argv[2] || process.env.API_BASE_URL || process.env.VITE_API_BASE_URL || '';
if (!base) {
  console.error('Usage: node scripts/check-api-preflight.mjs <https://api-host>');
  process.exit(2);
}

const url = base.replace(/\/+$/, '') + (base.replace(/\/+$/, '').endsWith('/api/v1') ? PROBE_PATH.slice('/api/v1'.length) : PROBE_PATH);

let res;
try {
  res = await fetch(url, {
    method: 'OPTIONS',
    redirect: 'manual', // Node/undici exposes the raw 3xx; browsers would fail harder
    headers: {
      Origin: WEB_ORIGIN,
      'Access-Control-Request-Method': 'POST',
      'Access-Control-Request-Headers': 'content-type,x-device-id',
    },
  });
} catch (err) {
  console.error(`FAIL: could not reach ${url} (${err.message})`);
  process.exit(1);
}

const fail = (msg) => {
  console.error(`FAIL (${res.status}): ${msg}`);
  process.exit(1);
};

if (res.status >= 300 && res.status < 400) {
  const location = res.headers.get('location') || '(none)';
  fail(
    `preflight was redirected (${res.status} → ${location}). Browsers refuse to ` +
      'follow redirects on CORS preflights, so all cross-origin API calls break. ' +
      `Remedy: make the host serve OPTIONS directly (Cloudflare proxy rule, not a ` +
      `redirect), or point VITE_API_BASE_URL at the redirect target "${new URL(location, url).origin}".`,
  );
}

if (res.status < 200 || res.status >= 300) fail('preflight did not return 2xx');

const allowOrigin = res.headers.get('access-control-allow-origin') || '';
const allowHeaders = (res.headers.get('access-control-allow-headers') || '').toLowerCase();
const allowMethods = (res.headers.get('access-control-allow-methods') || '').toUpperCase();

if (!allowOrigin) fail('missing Access-Control-Allow-Origin on preflight');
if (allowOrigin !== '*' && allowOrigin !== WEB_ORIGIN) {
  fail(`Access-Control-Allow-Origin "${allowOrigin}" does not cover ${WEB_ORIGIN}`);
}
if (!allowHeaders.includes('x-device-id')) {
  fail('preflight Access-Control-Allow-Headers does not include x-device-id (needed for cookie-based refresh)');
}
if (!allowMethods.includes('POST')) fail('preflight Access-Control-Allow-Methods does not include POST');

console.log(`OK: ${url} answers CORS preflight with ${res.status}`);
console.log(`    allow-origin: ${allowOrigin}`);
console.log(`    allow-headers includes x-device-id: true`);
