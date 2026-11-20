/**
 * Workout route geometry.
 *
 * A shared activity carries its GPS track in `workout_log_data.route` as
 * `[lat, lng, timestamp]` triples. The feed card and the share card both need
 * the same path, so the projection lives here instead of in either renderer.
 *
 * The path is drawn as vector geometry rather than map tiles: it renders
 * offline, needs no tile requests or API key, and cannot taint the canvas
 * that produces the downloadable/shareable card.
 */

export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface XYPoint {
  x: number;
  y: number;
}

/** Read a route out of a workout payload, rejecting anything malformed. */
export function extractWorkoutRoute(
  data: Record<string, unknown> | null | undefined,
): GeoPoint[] {
  if (!data || typeof data !== 'object') return [];
  const raw = (data as { route?: unknown }).route;
  if (!Array.isArray(raw)) return [];
  const points: GeoPoint[] = [];
  for (const entry of raw) {
    if (!Array.isArray(entry) || entry.length < 2) continue;
    const lat = Number(entry[0]);
    const lng = Number(entry[1]);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
    points.push({ lat, lng });
  }
  return points;
}

export function hasWorkoutRoute(data: Record<string, unknown> | null | undefined): boolean {
  return extractWorkoutRoute(data).length > 0;
}

export interface RouteProjection {
  points: XYPoint[];
  /** Normalised 0…1 progress of every point, for a gradient stroke. */
  progress: number[];
  /** True when the route is a single point (a stationary session). */
  isPoint: boolean;
}

/**
 * Project lat/lng into a width × height box, preserving aspect ratio.
 *
 * Uses an equirectangular projection scaled by the mean latitude — accurate
 * enough at the size of a phone screen, and cheap enough to run per render.
 */
export function projectRoute(
  route: GeoPoint[],
  width: number,
  height: number,
  padding = 16,
): RouteProjection {
  if (!route.length) return { points: [], progress: [], isPoint: false };

  const meanLat = route.reduce((sum, p) => sum + p.lat, 0) / route.length;
  const cosLat = Math.cos((meanLat * Math.PI) / 180);
  const raw = route.map((p) => ({ x: p.lng * cosLat, y: -p.lat }));

  let minX = Infinity;
  let maxX = -Infinity;
  let minY = Infinity;
  let maxY = -Infinity;
  for (const p of raw) {
    minX = Math.min(minX, p.x);
    maxX = Math.max(maxX, p.x);
    minY = Math.min(minY, p.y);
    maxY = Math.max(maxY, p.y);
  }

  const spanX = maxX - minX;
  const spanY = maxY - minY;
  const innerW = Math.max(1, width - padding * 2);
  const innerH = Math.max(1, height - padding * 2);
  const isPoint = spanX < 1e-12 && spanY < 1e-12;

  // A stationary session gets a centred pin instead of a divide-by-zero.
  const scale = isPoint ? 0 : Math.min(
    spanX > 0 ? innerW / spanX : Infinity,
    spanY > 0 ? innerH / spanY : Infinity,
  );

  const offsetX = padding + (innerW - spanX * scale) / 2;
  const offsetY = padding + (innerH - spanY * scale) / 2;

  const points = raw.map((p) => ({
    x: offsetX + (p.x - minX) * scale,
    y: offsetY + (p.y - minY) * scale,
  }));
  if (isPoint) {
    points[0] = { x: width / 2, y: height / 2 };
  }

  const progress = points.map((_, index) =>
    points.length === 1 ? 1 : index / (points.length - 1),
  );

  return { points, progress, isPoint };
}

/** An SVG path for the projected route (used by the feed card). */
export function routeSvgPath(
  route: GeoPoint[],
  width: number,
  height: number,
  padding = 16,
): string {
  const { points } = projectRoute(route, width, height, padding);
  if (!points.length) return '';
  return points
    .map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(2)},${p.y.toFixed(2)}`)
    .join(' ');
}
