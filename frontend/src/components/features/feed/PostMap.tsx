import { lazy, Suspense } from 'react';
import { MapPin, ExternalLink } from 'lucide-react';
import 'leaflet/dist/leaflet.css';
import { StaticMapImage } from './mapProviders';

const MiniLeafletMap = lazy(() => import('./MiniLeafletMap'));

function openGoogleMaps(lat: number, lng: number) {
  window.open(`https://www.google.com/maps/search/?api=1&query=${lat},${lng}`, '_blank', 'noopener,noreferrer');
}

function openAppleMaps(lat: number, lng: number) {
  window.open(`https://maps.apple.com/?ll=${lat},${lng}&q=${encodeURIComponent('Pinned location')}`, '_blank', 'noopener,noreferrer');
}

function openOSM(lat: number, lng: number) {
  window.open(`https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=16/${lat}/${lng}`, '_blank', 'noopener,noreferrer');
}

export function PostMap({ lat, lng, label }: { lat: number; lng: number; label?: string }) {
  return (
    <div className="mt-3 rounded-xl overflow-hidden border border-buddy-surface">
      <a
        href={`https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=16/${lat}/${lng}`}
        target="_blank"
        rel="noreferrer"
        onClick={(e) => e.stopPropagation()}
        className="relative block h-32 bg-buddy-surface-raised overflow-hidden group"
      >
        {/* Interactive Leaflet map (lazy) with static raster fallback chain */}
        <Suspense fallback={<StaticMapImage lat={lat} lng={lng} />}>
          <MiniLeafletMap lat={lat} lng={lng} label={label} />
        </Suspense>
        <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/70 to-transparent p-2 flex items-center gap-1.5 pointer-events-none">
          <MapPin size={13} className="text-buddy-green shrink-0" />
          <span className="text-xs text-white truncate">{label || `${lat.toFixed(5)}, ${lng.toFixed(5)}`}</span>
        </div>
      </a>
      <div className="flex divide-x divide-buddy-surface bg-buddy-surface">
        <button onClick={(e) => { e.stopPropagation(); openGoogleMaps(lat, lng); }}
          className="flex-1 flex items-center justify-center gap-1 py-1.5 text-[11px] text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface-raised transition-colors">
          <ExternalLink size={11} /> Google Maps
        </button>
        <button onClick={(e) => { e.stopPropagation(); openAppleMaps(lat, lng); }}
          className="flex-1 flex items-center justify-center gap-1 py-1.5 text-[11px] text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface-raised transition-colors">
          <ExternalLink size={11} /> Apple Maps
        </button>
        <button onClick={(e) => { e.stopPropagation(); openOSM(lat, lng); }}
          className="flex-1 flex items-center justify-center gap-1 py-1.5 text-[11px] text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface-raised transition-colors">
          <ExternalLink size={11} /> OpenStreetMap
        </button>
      </div>
    </div>
  );
}