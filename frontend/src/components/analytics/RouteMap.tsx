import { useMemo } from 'react';

interface RouteMapProps {
  route: number[][];
  height?: number;
}

interface LatLng {
  lat: number;
  lng: number;
}

function toLatLngs(route: number[][]): LatLng[] {
  return route
    .filter((p) => Array.isArray(p) && p.length >= 2)
    .map((p) => ({ lat: p[0], lng: p[1] }));
}

/**
 * SVG route map used when a Google Maps API key is unavailable.
 * Auto-fits the polyline, applies a grid/streets backdrop, and is fully
 * self-contained (no network, no key). Swapped for Google Maps when the
 * VITE_GOOGLE_MAPS_KEY is configured.
 */
export function SvgRouteMap({ route, height = 220 }: RouteMapProps) {
  const { points, paths } = useMemo(() => {
    const pts = toLatLngs(route);
    if (pts.length < 2) return { points: [] as LatLng[], paths: '' };
    const lats = pts.map((p) => p.lat);
    const lngs = pts.map((p) => p.lng);
    const minLat = Math.min(...lats);
    const maxLat = Math.max(...lats);
    const minLng = Math.min(...lngs);
    const maxLng = Math.max(...lngs);
    const pad = 12;
    const x = (lng: number) => pad + ((lng - minLng) / (maxLng - minLng || 1)) * (640 - pad * 2);
    const y = (lat: number) => pad + ((maxLat - lat) / (maxLat - minLat || 1)) * (height - pad * 2);
    return {
      points: pts,
      paths: pts.map((p, i) => `${i === 0 ? 'M' : 'L'} ${x(p.lng).toFixed(1)} ${y(p.lat).toFixed(1)}`).join(' '),
    };
  }, [route, height]);

  if (points.length < 2) {
    return (
      <div className="flex items-center justify-center h-40 rounded-xl bg-buddy-surface-raised border border-buddy-surface-raised text-sm text-buddy-text-secondary">
        No route recorded for this activity
      </div>
    );
  }

  return (
    <div className="rounded-xl overflow-hidden border border-buddy-surface-raised bg-[#101418]" style={{ height }}>
      <svg viewBox={`0 0 640 ${height}`} preserveAspectRatio="xMidYMid meet" className="w-full h-full">
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1E242B" strokeWidth="1" />
          </pattern>
          <linearGradient id="route" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#7B61FF" />
            <stop offset="100%" stopColor="#00C896" />
          </linearGradient>
        </defs>
        <rect width="640" height={height} fill="#101418" />
        <rect width="640" height={height} fill="url(#grid)" />
        <path d={paths} fill="none" stroke="url(#route)" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round" opacity="0.95" />
        <circle cx={points[0].lng > points[points.length - 1].lng ? 10 : 630} cy={points[0].lat > points[points.length - 1].lat ? 10 : height - 10} r="6" fill="#00C896" stroke="#0A0A0A" strokeWidth="2" />
        <circle cx={points[points.length - 1].lng > points[0].lng ? 630 : 10} cy={points[points.length - 1].lat > points[0].lat ? height - 10 : 10} r="6" fill="#FF4757" stroke="#0A0A0A" strokeWidth="2" />
      </svg>
      <div className="px-3 py-1.5 bg-buddy-surface/95 text-xs text-buddy-text-secondary border-t border-buddy-surface-raised">
        {points.length} trackpoints
      </div>
    </div>
  );
}

/**
 * Google Maps route renderer. Only renders when a real key is configured;
 * otherwise defers to SvgRouteMap.
 */
export function RouteMap({ route, height = 220 }: RouteMapProps) {
  const mapsKey = import.meta.env.VITE_GOOGLE_MAPS_KEY;
  const hasKey = mapsKey && mapsKey.trim() !== '' && mapsKey !== 'xxxxx';

  const points = useMemo(() => toLatLngs(route), [route]);
  if (!hasKey || points.length < 2) {
    return <SvgRouteMap route={route} height={height} />;
  }

  // Lazy-import the Google Maps components only when a key exists.
  const { GoogleMap, Polyline } = require('@vis.gl/react-google-maps') as {
    GoogleMap: React.ComponentType<Record<string, unknown>>;
    Polyline: React.ComponentType<Record<string, unknown>>;
  };

  const bounds = points.reduce(
    (acc, p) => ({
      n: Math.max(acc.n, p.lat), s: Math.min(acc.s, p.lat),
      e: Math.max(acc.e, p.lng), w: Math.min(acc.w, p.lng),
    }),
    { n: -90, s: 90, e: -180, w: 180 },
  );
  const center = { lat: (bounds.n + bounds.s) / 2, lng: (bounds.e + bounds.w) / 2 };
  const dLat = Math.max(bounds.n - bounds.s, 0.001);
  const dLng = Math.max(bounds.e - bounds.w, 0.001);

  return (
    <div className="rounded-xl overflow-hidden border border-buddy-surface-raised" style={{ height }}>
      <GoogleMap
        apiKey={mapsKey}
        center={center}
        zoom={Math.max(10, Math.min(17, Math.log2(360 / Math.max(dLat, dLng))))}
        mapId="buddyup-analytics-route"
        fullscreenControl={false}
        streetViewControl={false}
        mapTypeControl={false}
      >
        <Polyline path={points} strokeColor="#00C896" strokeOpacity={1.0} strokeWeight={4} />
      </GoogleMap>
    </div>
  );
}
