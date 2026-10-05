/** Shared GPS + adaptive-radius helpers (mirrors backend/common/geo.py). */

export interface GeoMeta {
  lat: number;
  lng: number;
  radius_km: number;
  auto: boolean;
  density: 'dense' | 'sparse' | null;
  count_in_near: number | null;
  message: string | null;
}

export interface Coords {
  lat: number;
  lng: number;
}

export const NEAR_RADIUS_KM = 5;
export const WIDE_RADIUS_KM = 10;

/** One-shot GPS fix (8s timeout, high accuracy). Rejects with a short code. */
export function requestLocation(timeoutMs = 8000): Promise<Coords> {
  return new Promise((resolve, reject) => {
    if (!('geolocation' in navigator)) {
      reject(new Error('unsupported'));
      return;
    }
    const timer = window.setTimeout(() => reject(new Error('timeout')), timeoutMs);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        window.clearTimeout(timer);
        resolve({ lat: pos.coords.latitude, lng: pos.coords.longitude });
      },
      (err) => {
        window.clearTimeout(timer);
        reject(new Error(err.code === err.PERMISSION_DENIED ? 'denied' : 'unavailable'));
      },
      { enableHighAccuracy: true, timeout: timeoutMs, maximumAge: 60_000 },
    );
  });
}

export function formatDistance(km: number | null | undefined): string | null {
  if (km === null || km === undefined) return null;
  if (km < 1) return `${Math.max(100, Math.round(km * 1000 / 100) * 100)} m away`;
  return `${km.toFixed(km < 10 ? 1 : 0)} km away`;
}
