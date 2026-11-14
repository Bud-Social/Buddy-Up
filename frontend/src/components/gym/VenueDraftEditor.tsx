import { useState } from 'react';
import { MapPin, Plus, Star, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { LocationPicker, type PickedLocation } from '@/components/features/feed/LocationPicker';
import { emptyVenueDraft, type VenueDraft } from './venueDraft';

interface VenueDraftEditorProps {
  venues: VenueDraft[];
  onChange: (venues: VenueDraft[]) => void;
}

/**
 * Location editor shared by gym creation and the manage dashboard.
 *
 * A gym with one location and a gym with five use the same control: add a
 * venue, search or drop a pin on the OpenStreetMap picker, and mark which one
 * is the primary address. Coordinates are stored per venue so the gym list can
 * show the distance to the nearest branch.
 */
export function VenueDraftEditor({ venues, onChange }: VenueDraftEditorProps) {
  const [openPicker, setOpenPicker] = useState<string | null>(null);

  const update = (key: string, patch: Partial<VenueDraft>) => {
    onChange(venues.map((v) => (v.key === key ? { ...v, ...patch } : v)));
  };

  const addVenue = () => onChange([...venues, emptyVenueDraft(venues.length === 0)]);
  const removeVenue = (key: string) => {
    const next = venues.filter((v) => v.key !== key);
    if (next.length && !next.some((v) => v.is_primary)) next[0] = { ...next[0], is_primary: true };
    onChange(next);
  };
  const makePrimary = (key: string) =>
    onChange(venues.map((v) => ({ ...v, is_primary: v.key === key })));

  const pickLocation = (key: string) => (loc: PickedLocation) => {
    const parts = loc.label.split(',').map((p) => p.trim()).filter(Boolean);
    const country = parts.length > 1 ? parts[parts.length - 1] : '';
    const city = parts.length > 2 ? parts[parts.length - 2] : '';
    update(key, {
      address: loc.label,
      latitude: loc.lat,
      longitude: loc.lng,
      city: venues.find((v) => v.key === key)?.city || city,
      country: venues.find((v) => v.key === key)?.country || country,
    });
    setOpenPicker(null);
  };

  return (
    <div className="space-y-3">
      {venues.length === 0 && (
        <div className="rounded-xl border border-dashed border-buddy-surface-raised p-4 text-center">
          <MapPin size={22} className="mx-auto text-buddy-text-secondary/40 mb-1" />
          <p className="text-xs text-buddy-text-secondary">
            No locations yet. A physical gym needs at least one.
          </p>
        </div>
      )}

      {venues.map((venue, index) => (
        <div key={venue.key} className="rounded-xl bg-buddy-surface p-3 space-y-2">
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-medium text-buddy-text-secondary w-5">
              {index + 1}
            </span>
            <div className="flex-1">
              <Input
                value={venue.name}
                onChange={(e) => update(venue.key, { name: e.target.value })}
                placeholder={venues.length > 1 ? 'Branch name (e.g. Westlands)' : 'Location name'}
              />
            </div>
            <button
              type="button"
              onClick={() => makePrimary(venue.key)}
              className={`p-2 rounded-lg transition-colors ${
                venue.is_primary
                  ? 'text-buddy-gold bg-buddy-gold/10'
                  : 'text-buddy-text-secondary/50 hover:text-buddy-gold'
              }`}
              title={venue.is_primary ? 'Primary location' : 'Make primary'}
            >
              <Star size={15} className={venue.is_primary ? 'fill-current' : ''} />
            </button>
            <button
              type="button"
              onClick={() => removeVenue(venue.key)}
              className="p-2 rounded-lg text-buddy-text-secondary/50 hover:text-buddy-red"
              title="Remove location"
            >
              <Trash2 size={15} />
            </button>
          </div>

          <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
            <MapPin size={13} className={venue.latitude !== null ? 'text-buddy-green' : ''} />
            <span className="flex-1 truncate">
              {venue.address || 'No pin yet'}
            </span>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setOpenPicker(openPicker === venue.key ? null : venue.key)}
            >
              {openPicker === venue.key ? 'Close map' : venue.latitude !== null ? 'Change pin' : 'Pick on map'}
            </Button>
          </div>

          {openPicker === venue.key && (
            <LocationPicker
              initial={
                venue.latitude !== null && venue.longitude !== null
                  ? { lat: venue.latitude, lng: venue.longitude, label: venue.address }
                  : null
              }
              onPick={pickLocation(venue.key)}
              onClose={() => setOpenPicker(null)}
            />
          )}

          <div className="grid grid-cols-2 gap-2">
            <Input
              value={venue.city}
              onChange={(e) => update(venue.key, { city: e.target.value })}
              placeholder="City"
            />
            <Input
              value={venue.country}
              onChange={(e) => update(venue.key, { country: e.target.value })}
              placeholder="Country"
            />
          </div>
          <Input
            value={venue.instructions}
            onChange={(e) => update(venue.key, { instructions: e.target.value })}
            placeholder="Getting there / parking (optional)"
          />
        </div>
      ))}

      <Button type="button" variant="outline" size="sm" className="w-full" onClick={addVenue}>
        {venues.length === 0 ? <Plus size={14} className="mr-1" /> : <Plus size={14} className="mr-1" />}
        Add {venues.length === 0 ? 'location' : 'another location'}
      </Button>
    </div>
  );
}

export default VenueDraftEditor;
