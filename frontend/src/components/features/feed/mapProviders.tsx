/**
 * TileLayerWithFallback – Leaflet tile layer that automatically fails over
 * through a chain of free, key-less providers when tiles error out.
 *
 * Order chosen for speed + coverage:
 *   1. CARTO Voyager  – fast, clean, worldwide (recommended default)
 *   2. OSM Standard   – canonical, occasionally rate-limited
 *   3. Esri World     – satellite-style fallback, very reliable
 */
import { useState } from 'react';
import { TileLayer } from 'react-leaflet';

export interface TileProvider {
  id: string;
  url: string;
  attribution: string;
  maxZoom: number;
}

export const TILE_PROVIDERS: TileProvider[] = [
  {
    id: 'carto',
    url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    attribution: '&copy; OpenStreetMap contributors &copy; CARTO',
    maxZoom: 20,
  },
  {
    id: 'osm',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; OpenStreetMap contributors',
    maxZoom: 19,
  },
  {
    id: 'esri',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles &copy; Esri',
    maxZoom: 19,
  },
];

export function TileLayerWithFallback() {
  const [providerIndex, setProviderIndex] = useState(0);
  const provider = TILE_PROVIDERS[Math.min(providerIndex, TILE_PROVIDERS.length - 1)];

  return (
    <TileLayer
      key={provider.id}
      url={provider.url}
      attribution={provider.attribution}
      maxZoom={provider.maxZoom}
      // When the provider fails, advance to the next one in the chain.
      eventHandlers={{
        tileerror: () => {
          setProviderIndex(idx => Math.min(idx + 1, TILE_PROVIDERS.length - 1));
        },
      }}
    />
  );
}

/** Static raster map with the same fallback chain (for previews/embeds). */
export function StaticMapImage({ lat, lng, zoom = 15 }: { lat: number; lng: number; zoom?: number }) {
  const [idx, setIdx] = useState(0);
  const w = 640;
  const h = 260;

  const sources = [
    // OSM staticmap service
    `https://staticmap.openstreetmap.de/staticmap.php?center=${lat},${lng}&zoom=${zoom}&size=${w}x${h}&markers=${lat},${lng},red-pushpin`,
    // Composed single OSM tile fallback (nearest tile at the requested zoom)
    `https://tile.openstreetmap.org/${zoom}/${Math.floor(((lng + 180) / 360) * 2 ** zoom)}/${Math.floor(((
      1 - Math.log(Math.tan((lat * Math.PI) / 180) + 1 / Math.cos((lat * Math.PI) / 180)) / Math.PI
    ) / 2) * 2 ** zoom)}.png`,
    // CARTO raster tile fallback
    (() => {
      const x = Math.floor(((lng + 180) / 360) * 2 ** zoom);
      const y = Math.floor(((1 - Math.log(Math.tan((lat * Math.PI) / 180) + 1 / Math.cos((lat * Math.PI) / 180)) / Math.PI) / 2) * 2 ** zoom);
      return `https://a.basemaps.cartocdn.com/rastertiles/voyager/${zoom}/${x}/${y}.png`;
    })(),
  ];

  if (idx >= sources.length) return null;
  return (
    <img
      src={sources[idx]}
      alt="Location map"
      className="w-full h-full object-cover group-hover:scale-[1.03] transition-transform"
      loading="lazy"
      onError={() => setIdx(i => i + 1)}
    />
  );
}
