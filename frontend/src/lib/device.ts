const DEVICE_ID_KEY = 'bu_device_id';

/** Stable per-device identifier sent as X-Device-Id on every API call so the
 * backend can mark the current session correctly. */
export function getDeviceId(): string {
  try {
    const existing = window.localStorage.getItem(DEVICE_ID_KEY);
    if (existing) return existing;
    const id = typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function'
      ? crypto.randomUUID()
      : 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
          const r = (Math.random() * 16) | 0;
          const v = c === 'x' ? r : (r & 0x3) | 0x8;
          return v.toString(16);
        });
    window.localStorage.setItem(DEVICE_ID_KEY, id);
    return id;
  } catch {
    // Storage unavailable (private mode) — fall back to an ephemeral id.
    return 'ephemeral-device';
  }
}
