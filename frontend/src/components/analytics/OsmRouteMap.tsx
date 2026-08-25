/**
 * OsmRouteMap – keyless interactive route renderer for tracked activities.
 * Uses Leaflet + the shared keyless tile failover chain (CARTO → OSM → Esri),
 * so no API key is ever required. Used as the fallback in RouteMap when
 * Google Maps is not configured.
 */
import { useMemo } from 'react';
import { CircleMarker, MapContainer, Polyline } from 'react-leaflet';
import { TileLayerWithFallback } from '@/components/features/feed/mapProviders';
import 'leaflet/dist/leaflet.css';

interface OsmRouteMapProps {
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

export function OsmRouteMap({ route, height = 220 }: OsmRouteMapProps) {
  const points = useMemo(() => toLatLngs(route), [route]);

  const bounds = useMemo(() => {
    const lats = points.map((p) => p.lat);
    const lngs = points.map((p) => p.lng);
    return [
      [Math.min(...lats), Math.min(...lngs)],
      [Math.max(...lats), Math.max(...lngs)],
    ] as [[number, number], [number, number]];
  }, [points]);

  if (points.length === 1) {
    // Zero-movement session — show a pin at the recorded position.
    return (
      <div style={{ height }} className="rounded-xl overflow-hidden border border-buddy-surface-raised">
        <MapContainer center={[points[0].lat, points[0].lng]} zoom={15} scrollWheelZoom={false} className="w-full h-full">
          <TileLayerWithFallback />
          <CircleMarker center={[points[0].lat, points[0].lng]} radius={8} pathOptions={{ color: '#00C896', fillColor: '#00C896', fillOpacity: 0.9 }} />
        </MapContainer>
      </div>
    );
  }

  return (
    <div style={{ height }} className="relative rounded-xl overflow-hidden border border-buddy-surface-raised">
      <MapContainer bounds={bounds} scrollWheelZoom={false} className="w-full h-full">
        <TileLayerWithFallback />
        <Polyline positions={points.map((p) => [p.lat, p.lng] as [number, number])} pathOptions={{ color: '#00C896', weight: 4, opacity: 0.95 }} />
        <CircleMarker center={[points[0].lat, points[0].lng]} radius={6} pathOptions={{ color: '#00C896', fillColor: '#00C896', fillOpacity: 1 }} />
        <CircleMarker
          center={[points[points.length - 1].lat, points[points.length - 1].lng]}
          radius={6}
          pathOptions={{ color: '#FF4757', fillColor: '#FF4757', fillOpacity: 1 }}
        />
      </MapContainer>
      <div className="absolute bottom-0 inset-x-0 px-3 py-1 bg-buddy-surface/90 text-[11px] text-buddy-text-secondary pointer-events-none">
        {points.length} trackpoints · start 🟢 finish 🔴
      </div>
    </div>
  );
}
