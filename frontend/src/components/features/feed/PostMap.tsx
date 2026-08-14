import { MapPin, ExternalLink } from 'lucide-react';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';

L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl });

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
        <img
          src={`https://staticmap.openstreetmap.de/staticmap.php?center=${lat},${lng}&zoom=15&size=640x260&markers=${lat},${lng},red-pushpin`}
          alt={label || 'Location map'}
          className="w-full h-full object-cover group-hover:scale-[1.03] transition-transform"
          loading="lazy"
        />
        <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/70 to-transparent p-2 flex items-center gap-1.5">
          <MapPin size={13} className="text-buddy-green shrink-0" />
          <span className="text-xs text-white truncate">{label || `${lat.toFixed(5)}, ${lng.toFixed(5)}`}</span>
        </div>
        <div className="absolute top-2 right-2 px-2 py-1 rounded-full bg-black/60 text-[10px] text-buddy-green font-medium opacity-0 group-hover:opacity-100 transition-opacity">
          Open map ↗
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