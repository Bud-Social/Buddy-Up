import { useEffect, useState } from 'react';
import { MapPin, X, Info } from 'lucide-react';
import type { GeoMeta } from '@/lib/geo';

/**
 * Slide-down notice explaining the adaptive nearby radius:
 * 5 km in dense areas, 10 km where users/venues are sparse.
 */
export function NearbyNotice({ geo, kind = 'places' }: { geo: GeoMeta | null; kind?: string }) {
  const [visible, setVisible] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    setDismissed(false);
    if (geo?.auto && geo.message) {
      const t = requestAnimationFrame(() => setVisible(true));
      return () => cancelAnimationFrame(t);
    }
    setVisible(false);
    return undefined;
  }, [geo?.radius_km, geo?.message, geo?.auto]);

  if (!geo?.auto || !geo.message || dismissed) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className={`overflow-hidden transition-all duration-500 ease-out ${visible ? 'max-h-24 opacity-100 mb-3' : 'max-h-0 opacity-0'}`}
    >
      <div className="flex items-start gap-2.5 rounded-xl bg-buddy-green/10 border border-buddy-green/25 px-3.5 py-2.5">
        <MapPin size={15} className="text-buddy-green mt-0.5 flex-shrink-0" />
        <div className="flex-1 min-w-0">
          <p className="text-xs font-medium text-buddy-text-primary">
            Nearby: {geo.radius_km} km
            <span className="font-normal text-buddy-text-secondary">
              {' '}· {geo.density === 'dense' ? 'lots around you' : 'fewer around you'}
            </span>
          </p>
          <p className="text-[11px] text-buddy-text-secondary mt-0.5 flex items-start gap-1">
            <Info size={11} className="mt-[1px] flex-shrink-0" />
            <span>{geo.message} Applies to {kind} near you.</span>
          </p>
        </div>
        <button
          onClick={() => { setVisible(false); setDismissed(true); }}
          aria-label="Dismiss nearby notice"
          className="p-1 rounded-lg text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface-raised transition-colors"
        >
          <X size={14} />
        </button>
      </div>
    </div>
  );
}
