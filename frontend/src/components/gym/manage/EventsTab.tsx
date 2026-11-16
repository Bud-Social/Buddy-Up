import { useEffect, useState } from 'react';
import { Tag, Plus, ShieldCheck, MapPin, Users, Trash2, Pencil } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Toggle } from '@/components/ui/Toggle';
import { Modal } from '@/components/ui/Modal';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi } from '@/api';
import type { MarketplaceEvent } from '@/api/marketplace';
import { EVENT_CATEGORIES } from '@/config/eventCategories';
import { LocationPicker, type PickedLocation } from '@/components/features/feed/LocationPicker';

interface EventsTabProps {
  slug: string;
  gymId: string;
  gymName: string;
  canManage: boolean;
  /** Owner/co-owner only — the activate toggle itself. */
  canActivate: boolean;
  /** Gym model flag mirrored from the manage page (PATCH /gyms/:slug/). */
  isEventsEnabled: boolean;
  onToggleActivate: (next: boolean) => Promise<void>;
}

const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

const EMPTY_FORM = {
  title: '',
  description: '',
  category: 'fitness',
  event_type: 'in_person' as 'in_person' | 'online' | 'hybrid',
  location: '',
  onlineUrl: '',
  latitude: null as number | null,
  longitude: null as number | null,
  building: '',
  startDate: '',
  startTime: '18:00',
  endDate: '',
  endTime: '21:00',
  capacity: '0',
  isFree: true,
  memberPrice: PRICE_ARTIFACTS.reduce((acc, t) => ({ ...acc, [t]: 0 }), {} as Record<string, number>),
  nonMemberPrice: PRICE_ARTIFACTS.reduce((acc, t) => ({ ...acc, [t]: 0 }), {} as Record<string, number>),
  price: PRICE_ARTIFACTS.reduce((acc, t) => ({ ...acc, [t]: 0 }), {} as Record<string, number>),
  visibility: 'gym_members' as 'public' | 'gym_members' | 'hidden',
};

/**
 * Events for the gym.
 *
 * "Activate organiser" flips `gym.is_events_enabled` — enabling that finally
 * gives a gym the same create/manage surface the marketplace has for events,
 * with member/non-member pricing and a venue picker that knows buildings.
 * Visibility: `gym_members` is visible in-place on the gym but hidden from
 * the marketplace events roll; `public` is also shown on the marketplace;
 * `hidden` keeps it draft-only for the gym.
 */
export function EventsTab({ slug, gymId, gymName, canManage, canActivate, isEventsEnabled, onToggleActivate }: EventsTabProps) {
  const [events, setEvents] = useState<MarketplaceEvent[] | null>(null);
  const [activating, setActivating] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [editing, setEditing] = useState<MarketplaceEvent | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [showPicker, setShowPicker] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [generalError, setGeneralError] = useState<string | null>(null);

  const load = async () => {
    if (!isEventsEnabled) { setEvents([]); return; }
    try {
      const gyms = await marketplaceApi.getEvents('all', { gym: slug });
      setEvents(Array.isArray(gyms?.data) ? gyms.data : []);
    } catch {
      setEvents([]);
    }
  };

  useEffect(() => { load(); }, [isEventsEnabled, slug]);

  const toggleActivate = async () => {
    if (!canActivate || activating) return;
    setActivating(true);
    try {
      await onToggleActivate(!isEventsEnabled);
      await load();
    } finally {
      setActivating(false);
    }
  };

  const startEdit = (e: MarketplaceEvent) => {
    const start = new Date(e.start_datetime);
    const end = new Date(e.end_datetime);
    const pad = (n: number) => String(n).padStart(2, '0');
    const priceMap: Record<string, number> = { ...EMPTY_FORM.price, ...((e as any).ticket_price_artifacts || {}) };
    const memberMap: Record<string, number> = { ...EMPTY_FORM.memberPrice, ...((e as any).member_price_artifacts || {}) };
    const nonMemberMap: Record<string, number> = { ...EMPTY_FORM.nonMemberPrice, ...((e as any).non_member_price_artifacts || {}) };
    setForm({
      title: e.title || '',
      description: e.description || '',
      category: e.category || 'fitness',
      event_type: (e.event_type === 'online' || e.event_type === 'hybrid' ? e.event_type : 'in_person') as any,
      location: e.location || '',
      onlineUrl: e.online_url || '',
      latitude: (e as any).location_lat ?? null,
      longitude: (e as any).location_lng ?? null,
      building: (e as any).building_name || '',
      startDate: `${start.getFullYear()}-${pad(start.getMonth() + 1)}-${pad(start.getDate())}`,
      startTime: `${pad(start.getHours())}:${pad(start.getMinutes())}`,
      endDate: `${end.getFullYear()}-${pad(end.getMonth() + 1)}-${pad(end.getDate())}`,
      endTime: `${pad(end.getHours())}:${pad(end.getMinutes())}`,
      capacity: String(e.capacity || 0),
      isFree: e.is_free,
      memberPrice: memberMap,
      nonMemberPrice: nonMemberMap,
      price: priceMap,
      visibility: ((e as any).visibility as any) || 'gym_members',
    });
    setEditing(e);
    setShowForm(true);
  };

  const openCreate = () => {
    const tomorrow = new Date(Date.now() + 86400000 * 2);
    const end = new Date(tomorrow.getTime() + 2 * 3600000);
    const pad = (n: number) => String(n).padStart(2, '0');
    setForm({
      ...EMPTY_FORM,
      startDate: `${tomorrow.getFullYear()}-${pad(tomorrow.getMonth() + 1)}-${pad(tomorrow.getDate())}`,
      startTime: '18:00',
      endDate: `${end.getFullYear()}-${pad(end.getMonth() + 1)}-${pad(end.getDate())}`,
      endTime: `${pad(end.getHours())}:${pad(end.getMinutes())}`,
    });
    setEditing(null);
    setGeneralError(null);
    setShowForm(true);
  };

  const submit = async () => {
    if (!form.title.trim() || !form.startDate || !form.endDate) return;
    setSubmitting(true);
    setGeneralError(null);
    try {
      const payload: Record<string, unknown> = {
        title: form.title.trim(),
        description: form.description.trim(),
        category: form.category,
        event_type: form.event_type,
        location: form.event_type === 'online' ? '' : form.location.trim(),
        location_lat: form.event_type === 'online' ? null : form.latitude,
        location_lng: form.event_type === 'online' ? null : form.longitude,
        online_url: form.event_type === 'in_person' ? '' : form.onlineUrl.trim(),
        start_datetime: new Date(`${form.startDate}T${form.startTime}`).toISOString(),
        end_datetime: new Date(`${form.endDate}T${form.endTime}`).toISOString(),
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
        capacity: Math.max(0, parseInt(form.capacity || '0', 10) || 0),
        is_free: form.isFree,
        ticket_price_artifacts: form.isFree ? {} : Object.fromEntries(Object.entries(form.price).filter(([, v]) => v > 0)),
        member_price_artifacts: form.isFree ? {} : Object.fromEntries(Object.entries(form.memberPrice).filter(([, v]) => v > 0)),
        non_member_price_artifacts: form.isFree ? {} : Object.fromEntries(Object.entries(form.nonMemberPrice).filter(([, v]) => v > 0)),
        gym_id: gymId,
        visibility: form.visibility,
      };
      if (editing?.id) {
        // The marketplace update endpoint handles both create/edit flow
        await marketplaceApi.updateEvent(editing.id, payload);
      } else {
        await marketplaceApi.createEvent(payload);
      }
      setShowForm(false);
      await load();
    } catch (e: any) {
      setGeneralError(e?.response?.data?.message || 'Could not save the event.');
    } finally {
      setSubmitting(false);
    }
  };

  const deleteEvent = async (e: MarketplaceEvent) => {
    if (!window.confirm(`Cancel “${e.title}”? Members will lose any RSVP/tickets they hold.`)) return;
    try {
      await marketplaceApi.deleteEvent(e.id);
      setEvents((prev) => prev?.filter((ev) => ev.id !== e.id) ?? null);
    } catch (err: any) {
      setGeneralError(err?.response?.data?.message || 'Could not cancel the event.');
    }
  };

  const onPick = (loc: PickedLocation) => {
    setForm((f) => ({
      ...f,
      location: loc.label,
      latitude: Number(loc.lat.toFixed(6)),
      longitude: Number(loc.lng.toFixed(6)),
      building: loc.building_name || f.building,
    }));
    setShowPicker(false);
  };

  const visibilityLabel = (v: string) => v === 'gym_members' ? 'Gym members only' : v === 'public' ? 'Marketplace + gym' : 'Hidden (draft)';

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-2">
          <Tag size={14} /> Events ({events?.length ?? 0})
        </h2>
        {canManage && canActivate && (
          <div className="flex items-center gap-2">
            <span className="text-[10px] text-buddy-text-secondary">Activate organiser</span>
            <Toggle checked={isEventsEnabled} onCheckedChange={toggleActivate} label="Activate events organiser for gym" disabled={activating} />
          </div>
        )}
      </div>

      {!isEventsEnabled && (
        <Card className="p-5 text-center">
          <ShieldCheck size={28} className="mx-auto text-buddy-gold mb-2 opacity-70" />
          <p className="text-sm font-semibold">Gym events aren’t open yet</p>
          <p className="text-xs text-buddy-text-secondary mt-1 max-w-md mx-auto">
            Flip <strong>Activate organiser</strong> to let this gym host paid and free events,
            reach members inside the gym feed and sell tickets on the gym profile.
          </p>
          {canManage && canActivate && <Button className="mt-3" size="sm" onClick={toggleActivate} isLoading={activating}>Activate organiser</Button>}
        </Card>
      )}

      {isEventsEnabled && (
        <>
          <div className="flex justify-end">
            <Button size="sm" className="gap-1.5" onClick={openCreate}>
              <Plus size={14} /> New event
            </Button>
          </div>
          {generalError && <p className="text-xs text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{generalError}</p>}

          {events === null ? (
            <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
          ) : events.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-xs">
              No events yet. Create the first one and share it with {gymName}’s members.
            </Card>
          ) : (
            events.map((e) => {
              const start = new Date(e.start_datetime);
              const capacityFull = e.capacity > 0 && (e.attendee_count ?? 0) >= e.capacity;
              return (
                <Card key={e.id} className="p-3 flex gap-3 items-center">
                  <div className="w-16 h-16 rounded-xl bg-buddy-green/10 flex flex-col items-center justify-center text-buddy-green shrink-0">
                    <span className="text-[10px] uppercase leading-none">{start.toLocaleString('en', { month: 'short' })}</span>
                    <span className="text-lg font-extrabold leading-none">{start.getDate()}</span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold truncate">{e.title}</p>
                    <p className="text-[10px] text-buddy-text-secondary truncate">{start.toLocaleString()} · {e.event_type} · {visibilityLabel((e as any).visibility || 'public')}</p>
                    <div className="flex items-center gap-2 mt-0.5 text-[10px] text-buddy-text-secondary">
                      <Users size={10} /> {e.attendee_count ?? 0}{e.capacity ? `/${e.capacity}` : ''} {capacityFull && <span className="text-buddy-red">· full</span>}
                      {e.is_free
                        ? <span className="text-buddy-green font-semibold">Free</span>
                        : <span>{Object.entries(e.ticket_price_artifacts || {}).slice(0, 2).map(([k, v]) => `${v} ${k}`).join(' ')}</span>}
                    </div>
                  </div>
                  {canManage && (
                    <div className="flex items-center gap-1 shrink-0">
                      <Button size="sm" variant="ghost" onClick={() => startEdit(e)} aria-label="Edit event"><Pencil size={14} /></Button>
                      <Button size="sm" variant="ghost" onClick={() => deleteEvent(e)} aria-label="Cancel event"><Trash2 size={14} /></Button>
                    </div>
                  )}
                </Card>
              );
            })
          )}
        </>
      )}

      <Modal isOpen={showForm} onClose={() => setShowForm(false)} title={editing ? 'Edit event' : 'New gym event'} size="lg">
        <div className="space-y-3 max-h-[80vh] overflow-y-auto pr-1">
          <Input label="Title" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} maxLength={200} />
          <div>
            <label className="text-xs text-buddy-text-secondary mb-1 block">Description</label>
            <textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} rows={2} className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none" />
          </div>
          <div className="grid sm:grid-cols-2 gap-2">
            <div>
              <label className="text-xs text-buddy-text-secondary mb-1 block">Category</label>
              <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-xs focus:outline-none focus:border-buddy-green">
                {EVENT_CATEGORIES.map((c) => <option key={c.key} value={c.key}>{c.label}</option>)}
              </select>
            </div>
            <div>
              <label className="text-xs text-buddy-text-secondary mb-1 block">Type</label>
              <select value={form.event_type} onChange={(e) => setForm({ ...form, event_type: e.target.value as any })} className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-xs focus:outline-none focus:border-buddy-green">
                <option value="in_person">In person</option>
                <option value="online">Online</option>
                <option value="hybrid">Hybrid</option>
              </select>
            </div>
          </div>
          {form.event_type !== 'online' && (
            <div>
              <div className="flex items-center justify-between mb-1">
                <label className="text-xs text-buddy-text-secondary">Location</label>
                <Button size="sm" variant="outline" onClick={() => setShowPicker(true)}>Pick on map</Button>
              </div>
              <Input value={form.location} onChange={(e) => setForm({ ...form, location: e.target.value })} placeholder="Tap into map to pin a venue…" />
              {form.building && <p className="text-[10px] text-buddy-green mt-1 flex items-center gap-1"><MapPin size={10} /> {form.building}</p>}
            </div>
          )}
          {form.event_type !== 'in_person' && (
            <Input label="Online URL" value={form.onlineUrl} onChange={(e) => setForm({ ...form, onlineUrl: e.target.value })} placeholder="https://…" />
          )}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <Input label="Start date" type="date" value={form.startDate} onChange={(e) => setForm({ ...form, startDate: e.target.value })} />
            <Input label="Start time" type="time" value={form.startTime} onChange={(e) => setForm({ ...form, startTime: e.target.value })} />
            <Input label="End date" type="date" value={form.endDate} onChange={(e) => setForm({ ...form, endDate: e.target.value })} />
            <Input label="End time" type="time" value={form.endTime} onChange={(e) => setForm({ ...form, endTime: e.target.value })} />
          </div>
          <Input label="Capacity (0 = unlimited)" type="number" min={0} value={form.capacity} onChange={(e) => setForm({ ...form, capacity: e.target.value })} />

          <div className="flex items-center gap-2 pt-1">
            <Toggle checked={form.isFree} onCheckedChange={(v) => setForm({ ...form, isFree: v })} label="Free event" />
            <span className="text-xs text-buddy-text-secondary">{form.isFree ? 'Free event' : 'Paid event — set a price per artifact'}</span>
          </div>

          {!form.isFree && (
            <div className="space-y-2">
              <p className="text-[9px] uppercase text-buddy-text-secondary">Price for gym members</p>
              <PriceRow artifacts={form.memberPrice} onChange={(k, v) => setForm({ ...form, memberPrice: { ...form.memberPrice, [k]: v } })} />
              <p className="text-[9px] uppercase text-buddy-text-secondary">Price for everyone else</p>
              <PriceRow artifacts={form.nonMemberPrice} onChange={(k, v) => setForm({ ...form, nonMemberPrice: { ...form.nonMemberPrice, [k]: v } })} />
            </div>
          )}

          <div>
            <label className="text-xs text-buddy-text-secondary mb-1 block">Visibility</label>
            <div className="flex flex-wrap gap-1.5">
              {([
                ['gym_members', 'Gym members only'],
                ['public', 'Gym + marketplace'],
                ['hidden', 'Hidden (draft)'],
              ] as const).map(([value, label]) => (
                <button key={value} type="button" onClick={() => setForm({ ...form, visibility: value })}
                  className={`px-2.5 py-1 rounded-full text-[11px] border transition-colors ${form.visibility === value ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary'}`}>
                  {label}
                </button>
              ))}
            </div>
          </div>

          <div className="flex gap-2 pt-2">
            <Button variant="ghost" className="flex-1" onClick={() => setShowForm(false)}>Cancel</Button>
            <Button className="flex-1" isLoading={submitting} onClick={submit} disabled={!form.title.trim() || !form.startDate || !form.endDate}>{editing ? 'Save event' : 'Create event'}</Button>
          </div>
        </div>
      </Modal>

      {showPicker && (
        <Modal isOpen={showPicker} onClose={() => setShowPicker(false)} title="Pin venue" size="lg">
          <LocationPicker onPick={onPick} onClose={() => setShowPicker(false)} />
        </Modal>
      )}
    </section>
  );
}

function PriceRow({ artifacts, onChange }: { artifacts: Record<string, number>; onChange: (k: string, qty: number) => void }) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'].map((at) => {
        const qty = artifacts[at] || 0;
        return (
          <div key={at} className={`flex items-center gap-1 rounded-lg border px-1.5 py-1 ${qty > 0 ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface-raised'}`}>
            <ArtifactIcon artifact={at} size={14} />
            <input type="number" min={0} value={qty} onChange={(e) => onChange(at, Math.max(0, parseInt(e.target.value, 10) || 0))} className="w-12 bg-transparent text-xs text-buddy-text-primary outline-none" />
          </div>
        );
      })}
    </div>
  );
}

export default EventsTab;
