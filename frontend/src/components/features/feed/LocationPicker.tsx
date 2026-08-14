import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMap, useMapEvents } from 'react-leaflet';
import { LatLng } from 'leaflet';
import { MapPin, Locate, Search, Loader2, X } from 'lucide-react';
import 'leaflet/dist/leaflet.css';
// Fix default leaflet marker icons under bundlers
import L from 'leaflet';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';

L.Icon.Default.mergeOptions({ iconUrl, iconRetinaUrl, shadowUrl });

const OSM_TILE = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const DEFAULT_CENTER: [number, number] = [9.0192, 38.7525];

export interface PickedLocation {
  lat: number;
  lng: number;
  label: string;
}

interface SearchResult {
  lat: number;
  lng: number;
  label: string;
}

function nominatimSearch(q: string): Promise<SearchResult[]> {
  return fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=5&q=${encodeURIComponent(q)}`)
    .then((r) => r.json())
    .then((rows: Array<{ lat: string; lon: string; display_name: string }>) =>
      rows.map((r) => ({ lat: parseFloat(r.lat), lng: parseFloat(r.lon), label: r.display_name })),
    );
}

function nominatimReverse(lat: number, lng: number): Promise<string> {
  return fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`)
    .then((r) => r.json())
    .then((j: { display_name?: string }) => j.display_name || '')
    .catch(() => '');
}

function FlyTo({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  useEffect(() => {
    map.flyTo([lat, lng], Math.max(map.getZoom(), 15));
  }, [lat, lng, map]);
  return null;
}

function ClickToPan({ onPick }: { onPick: (ll: { lat: number; lng: number }) => void }) {
  useMapEvents({
    click(e) { onPick({ lat: e.latlng.lat, lng: e.latlng.lng }); },
  });
  return null;
}

interface LocationPickerProps {
  initial?: { lat: number; lng: number; label?: string } | null;
  onPick: (loc: PickedLocation) => void;
  onClose?: () => void;
}

export function LocationPicker({ initial, onPick, onClose }: LocationPickerProps) {
  const [center, setCenter] = useState<[number, number]>([initial?.lat ?? DEFAULT_CENTER[0], initial?.lng ?? DEFAULT_CENTER[1]]);
  const [marker, setMarker] = useState<LatLng | null>(initial ? new LatLng(initial.lat, initial.lng) : null);
  const [label, setLabel] = useState(initial?.label ?? '');
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [geocoding, setGeocoding] = useState(false);
  const [locating, setLocating] = useState(false);

  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const pick = useCallback((lat: number, lng: number) => {
    setMarker(new LatLng(lat, lng));
    setCenter([lat, lng]);
    setGeocoding(true);
    nominatimReverse(lat, lng).then((name) => {
      setLabel(name || `(${lat.toFixed(5)}, ${lng.toFixed(5)})`);
      setGeocoding(false);
      onPick({ lat, lng, label: name || `(${lat.toFixed(5)}, ${lng.toFixed(5)})` });
    });
  }, [onPick]);

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    if (query.trim().length < 3) { setResults([]); return; }
    debounceRef.current = setTimeout(() => {
      setSearching(true);
      nominatimSearch(query).then((rows) => { setResults(rows); setSearching(false); }).catch(() => setSearching(false));
    }, 450);
    return () => { if (debounceRef.current) clearTimeout(debounceRef.current); };
  }, [query]);

  const locate = () => {
    if (!navigator.geolocation) return;
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => { pick(pos.coords.latitude, pos.coords.longitude); setLocating(false); },
      () => setLocating(false),
      { enableHighAccuracy: true, timeout: 8000 },
    );
  };

  const tileAttribution = useMemo(() => '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>', []);

  return (
    <div className="rounded-xl overflow-hidden bg-buddy-surface border border-buddy-surface-raised">
      <div className="flex items-center gap-2 p-2 border-b border-buddy-surface">
        <div className="flex-1 relative">
          <Search size={14} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search place or address…"
            className="w-full bg-buddy-surface-raised rounded-lg pl-8 pr-2 py-2 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
          />
          {results.length > 0 && (
            <div className="absolute top-full left-0 right-0 z-30 mt-1 bg-buddy-surface rounded-xl border border-buddy-surface-raised overflow-hidden shadow-2xl max-h-40 overflow-y-auto">
              {results.map((r, i) => (
                <button key={i} onMouseDown={(e) => { e.preventDefault(); pick(r.lat, r.lng); setQuery(''); setResults([]); }}
                  className="w-full px-3 py-2 text-left text-xs text-buddy-text-primary hover:bg-buddy-surface-raised truncate">
                  <MapPin size={12} className="inline mr-1 text-buddy-green" /> {r.label}
                </button>
              ))}
            </div>
          )}
          {searching && <Loader2 size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-buddy-green animate-spin" />}
        </div>
        <button onClick={locate} disabled={locating}
          className="p-2 rounded-lg bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-surface transition-colors shrink-0" title="Use my location">
          {locating ? <Loader2 size={16} className="animate-spin" /> : <Locate size={16} />}
        </button>
        {onClose && (
          <button onClick={onClose} className="p-2 rounded-lg bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary transition-colors shrink-0" title="Close">
            <X size={16} />
          </button>
        )}
      </div>

      <div className="h-56 relative z-10">
        <MapContainer center={center} zoom={initial ? 15 : 6} style={{ height: '100%', width: '100%' }} className="z-0">
          <TileLayer attribution={tileAttribution} url={OSM_TILE} />
          <FlyTo lat={center[0]} lng={center[1]} />
          <ClickToPan onPick={(ll) => pick(ll.lat, ll.lng)} />
          {marker && (
            <Marker
              position={marker}
              draggable
              eventHandlers={{
                dragend: (e: L.DragEndEvent) => {
                  const ll = (e.target as L.Marker).getLatLng();
                  pick(ll.lat, ll.lng);
                },
              }}
            />
          )}
        </MapContainer>
      </div>

      <div className="p-2 border-t border-buddy-surface">
        <div className="flex items-center gap-2">
          <MapPin size={14} className="text-buddy-green shrink-0" />
          <input
            value={label}
            onChange={(e) => setLabel(e.target.value)}
            placeholder="Location name (editable)"
            className="flex-1 bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none min-w-0"
          />
          {geocoding && <Loader2 size={14} className="text-buddy-green animate-spin shrink-0" />}
          <button
            onClick={() => onPick({ lat: marker?.lat ?? center[0], lng: marker?.lng ?? center[1], label })}
            disabled={!marker}
            className="px-3 py-1.5 rounded-full bg-buddy-green text-buddy-black text-xs font-bold shrink-0 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-buddy-green/90 transition-colors"
          >
            Use location
          </button>
        </div>
      </div>
    </div>
  );
}