/**
 * MiniLeafletMap – lazily-loaded interactive map used inside PostCard.
 * Renders marker + tiles with automatic provider failover. Interactions
 * are disabled so scrolling the feed is never hijacked by the map.
 */
import { MapContainer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';
import { TileLayerWithFallback } from './mapProviders';

L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl });

export default function MiniLeafletMap({ lat, lng, label }: { lat: number; lng: number; label?: string }) {
  return (
    <MapContainer
      center={[lat, lng]}
      zoom={15}
      scrollWheelZoom={false}
      doubleClickZoom={false}
      dragging={false}
      touchZoom={false}
      zoomControl={false}
      attributionControl={false}
      className="w-full h-full"
    >
      <TileLayerWithFallback />
      <Marker position={[lat, lng]}>
        <Popup>{label || `${lat.toFixed(5)}, ${lng.toFixed(5)}`}</Popup>
      </Marker>
    </MapContainer>
  );
}
