/**
 * Connectivity verification. `navigator.onLine` false-positives (captive
 * portals, WebViews, startup races), so never render persistent offline UI
 * on its word alone — confirm with a real same-origin request first.
 */

const HEARTBEAT_URL = '/offline.html';
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
