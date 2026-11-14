import { lazy, Suspense, useEffect, useState } from 'react';
import { MapPin, Pencil, Plus, Star, Trash2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { VenueDraftEditor } from '@/components/gym/VenueDraftEditor';
import { emptyVenueDraft, type VenueDraft } from '@/components/gym/venueDraft';
import { gymsApi } from '@/api/gyms';
import type { VenueLocation } from '@/types';

const MiniLeafletMap = lazy(() => import('@/components/features/feed/MiniLeafletMap'));

interface VenuesTabProps {
  slug: string;
  canManage: boolean;
}

function toDraft(venue: VenueLocation): VenueDraft {
  return {
    key: venue.id,
    name: venue.name,
    address: venue.address,
    city: venue.city,
    country: venue.country,
    latitude: venue.latitude === null || venue.latitude === '' ? null : Number(venue.latitude),
    longitude: venue.longitude === null || venue.longitude === '' ? null : Number(venue.longitude),
    instructions: venue.instructions || '',
    is_primary: venue.is_primary,
  };
}

/**
 * Venue CRUD for a gym's management console.
 *
 * A gym can have one location or many; this is the only place they are edited
 * after creation. Distance in the gym list is derived from these pins, so a
 * missing coordinate here is a missing "2.4 km away" on the card.
 */
export function VenuesTab({ slug, canManage }: VenuesTabProps) {
  const [venues, setVenues] = useState<VenueLocation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState<{ venueId: string | null; draft: VenueDraft } | null>(null);
  const [busy, setBusy] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<VenueLocation | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await gymsApi.getVenues(slug);
      setVenues(res.data || []);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load locations.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [slug]); // eslint-disable-line react-hooks/exhaustive-deps

  const startAdd = () => setEditing({ venueId: null, draft: emptyVenueDraft(venues.length === 0) });
  const startEdit = (venue: VenueLocation) => setEditing({ venueId: venue.id, draft: toDraft(venue) });

  const save = async () => {
    if (!editing || !editing.draft.name.trim()) return;
    setBusy(true);
    setError(null);
    const payload = {
      name: editing.draft.name.trim(),
      address: editing.draft.address,
      city: editing.draft.city,
      country: editing.draft.country,
      latitude: editing.draft.latitude,
      longitude: editing.draft.longitude,
      instructions: editing.draft.instructions,
      is_primary: editing.draft.is_primary,
    };
    try {
      if (editing.venueId) {
        const res = await gymsApi.updateVenue(slug, editing.venueId, payload);
        setVenues((prev) => prev.map((v) => (v.id === editing.venueId ? res.data : v)));
      } else {
        const res = await gymsApi.createVenue(slug, payload);
        setVenues((prev) => [
          ...(payload.is_primary ? prev.map((v) => ({ ...v, is_primary: false })) : prev),
          res.data,
        ]);
      }
      setEditing(null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not save that location.');
    } finally {
      setBusy(false);
    }
  };

  const remove = async (venue: VenueLocation) => {
    setBusy(true);
    setError(null);
    try {
      await gymsApi.deleteVenue(slug, venue.id);
      setVenues((prev) => prev.filter((v) => v.id !== venue.id));
      setDeleteTarget(null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not remove that location.');
    } finally {
      setBusy(false);
    }
  };

  const mapped = venues.filter(
    (v) => v.latitude !== null && v.latitude !== '' && v.longitude !== null && v.longitude !== '',
  );
  const focus = mapped.find((v) => v.is_primary) ?? mapped[0];

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">
          Locations ({venues.length})
        </h2>
        {canManage && (
          <Button size="sm" onClick={startAdd}>
            <Plus size={12} className="mr-1" /> Add location
          </Button>
        )}
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">
          {error}
        </div>
      )}

      {focus && (
        <Card className="overflow-hidden">
          <div className="h-40 bg-buddy-surface">
            <Suspense fallback={<div className="h-full w-full animate-pulse bg-buddy-surface-raised" />}>
              <MiniLeafletMap
                lat={Number(focus.latitude)}
                lng={Number(focus.longitude)}
                label={focus.name}
              />
            </Suspense>
          </div>
          <p className="px-3 py-2 text-xs text-buddy-text-secondary">
            {focus.name} · {mapped.length} pinned location{mapped.length === 1 ? '' : 's'}
          </p>
        </Card>
      )}

      {loading ? (
        <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
      ) : venues.length === 0 ? (
        <Card className="p-8 text-center text-buddy-text-secondary text-sm">
          No locations yet. Add the first one so members can find you.
        </Card>
      ) : (
        <div className="space-y-2">
          {venues.map((venue) => (
            <Card key={venue.id} className="p-3 flex items-start gap-3">
              <MapPin size={16} className={venue.is_primary ? 'text-buddy-green mt-0.5' : 'text-buddy-text-secondary mt-0.5'} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="text-sm font-medium truncate">{venue.name}</p>
                  {venue.is_primary && (
                    <span className="text-[10px] text-buddy-gold flex items-center gap-0.5">
                      <Star size={10} className="fill-current" /> Primary
                    </span>
                  )}
                  {venue.latitude !== null && venue.latitude !== '' && (
                    <span className="text-[10px] text-buddy-green">Pinned</span>
                  )}
                </div>
                <p className="text-xs text-buddy-text-secondary truncate">
                  {[venue.address, venue.city, venue.country].filter(Boolean).join(', ') || 'No address'}
                </p>
                {venue.instructions && (
                  <p className="text-[11px] text-buddy-text-secondary/70 mt-0.5">{venue.instructions}</p>
                )}
              </div>
              {canManage && (
                <div className="flex items-center gap-1 flex-shrink-0">
                  <Button size="sm" variant="ghost" aria-label={`Edit ${venue.name}`} onClick={() => startEdit(venue)}>
                    <Pencil size={14} />
                  </Button>
                  <Button size="sm" variant="ghost" aria-label={`Remove ${venue.name}`} onClick={() => setDeleteTarget(venue)}>
                    <Trash2 size={14} />
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}

      <Modal
        isOpen={!!editing}
        onClose={() => setEditing(null)}
        title={editing?.venueId ? 'Edit location' : 'Add location'}
        size="lg"
      >
        {editing && (
          <div className="space-y-3 max-h-[70vh] overflow-y-auto">
            <VenueDraftEditor
              venues={[editing.draft]}
              onChange={(next) => next[0] && setEditing({ ...editing, draft: next[0] })}
            />
            <div className="flex gap-2">
              <Button className="flex-1" isLoading={busy} disabled={!editing.draft.name.trim()} onClick={save}>
                Save location
              </Button>
              <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            </div>
          </div>
        )}
      </Modal>

      <Modal isOpen={!!deleteTarget} onClose={() => setDeleteTarget(null)} title="Remove location">
        <p className="text-sm text-buddy-text-secondary">
          Remove {deleteTarget?.name}? Members will no longer see this branch, and
          the gym's distance in listings is recalculated from the remaining pins.
        </p>
        <div className="flex gap-2 mt-4">
          <Button
            className="flex-1"
            variant="destructive"
            isLoading={busy}
            onClick={() => deleteTarget && remove(deleteTarget)}
          >
            Remove
          </Button>
          <Button variant="ghost" onClick={() => setDeleteTarget(null)}>Cancel</Button>
        </div>
      </Modal>
    </section>
  );
}

export default VenuesTab;
