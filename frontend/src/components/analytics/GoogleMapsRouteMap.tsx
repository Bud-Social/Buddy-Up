import { useMemo } from 'react';
import { APIProvider, Map, Polyline } from '@vis.gl/react-google-maps';

interface GoogleMapsRouteMapProps {
  route: number[][];
  height?: number;
  mapsKey: string;
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

export function GoogleMapsRouteMap({ route, height = 220, mapsKey }: GoogleMapsRouteMapProps) {
  const points = useMemo(() => toLatLngs(route), [route]);

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
      <APIProvider apiKey={mapsKey}>
        <Map
          className="w-full h-full"
          defaultCenter={center}
          defaultZoom={Math.max(10, Math.min(17, Math.log2(360 / Math.max(dLat, dLng))))}
          mapId="buddyup-analytics-route"
          fullscreenControl={false}
          streetViewControl={false}
          mapTypeControl={false}
        >
          <Polyline path={points} strokeColor="#00C896" strokeOpacity={1.0} strokeWeight={4} />
        </Map>
      </APIProvider>
    </div>
  );
}
