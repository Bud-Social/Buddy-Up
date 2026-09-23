/**
 * Connectivity verification. `navigator.onLine` false-positives (captive
 * portals, WebViews, startup races), so never render persistent offline UI
 * on its word alone — confirm with a real same-origin request first.
 *
 * The heartbeat deliberately targets /api/v1/health/ and must NOT be
 * cacheable by the service worker: HEAD bypasses all GET-only workbox
 * routes, so the response can only come from the network. (It used to hit
 * /offline.html, whose precache route answered from cache every time —
 * making verifyOnline() incapable of ever reporting a real outage.)
 */

const HEARTBEAT_URL = '/api/v1/health/';
const HEARTBEAT_TIMEOUT_MS = 8000;

/** True when the device can actually reach our server right now. */
export async function verifyOnline(fetchImpl: typeof fetch = fetch): Promise<boolean> {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), HEARTBEAT_TIMEOUT_MS);
    try {
      const res = await fetchImpl(HEARTBEAT_URL, {
        method: 'HEAD',
        cache: 'no-store',
        signal: controller.signal,
      });
      return res.ok;
    } finally {
      clearTimeout(timeout);
    }
  } catch {
    return false;
  }
}
