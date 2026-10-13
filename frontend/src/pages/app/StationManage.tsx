import { useCallback, useEffect, useMemo, useState } from 'react';
import { useAuthStore } from '@/store/authStore';
import { MapPin, Pencil, Plus, RadioTower, Building2, Clock } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { useToast } from '@/components/ui/Toast';
import { stationsApi, deriveOwnedStations, stationAreaLabel, stationOpeningHoursLabel, isStationsUnavailable, stationsErrorMessage, isPendingApplication, type PickupStation, type StationApplication, type StationOpeningHours, type StationOwnerIdentity, type StationWritePayload } from '@/api/stations';
import { RoleDashboardShell, RoleSectionTitle } from './roles/RoleShell';

const EMPTY_FORM: StationWritePayload = {
  name: '', address: '', city: '', country: '', phone: '',
  latitude: null, longitude: null, is_primary: false,
  owner_type: 'shop',
};

const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] as const;

/**
 * Opening-hours editor.
 *
 * Emits the canonical `{day: {open, close}}` shape the model stores, reading
 * back tolerantly — an existing station may have a plain string per day, so the
 * `08:00-20:00` form is parsed rather than rejected.
 */
function OpeningHoursEditor({
  value,
  onChange,
}: {
  value: StationOpeningHours | null;
  onChange: (next: StationOpeningHours) => void;
}) {
  const readDay = (key: string): { open: string; close: string } => {
    const raw = value?.[key];
    if (typeof raw === 'string') {
      const [open = '', close = ''] = raw.split('-').map((p) => p.trim());
      return { open, close };
    }
    if (raw && typeof raw === 'object') {
      return { open: raw.open || '', close: raw.close || '' };
    }
    return { open: '', close: '' };
  };

  const setDay = (key: string, field: 'open' | 'close', next: string) => {
    const current = readDay(key);
    const merged = { ...current, [field]: next };
    const out: StationOpeningHours = { ...(value ?? {}) };
    if (!merged.open && !merged.close) delete out[key];
    else out[key] = merged;
    onChange(out);
  };

  return (
    <fieldset className="space-y-2">
      <legend className="text-sm font-medium text-buddy-text-secondary mb-1">Opening hours</legend>
      <p className="text-[11px] text-buddy-text-secondary">Leave both fields empty for a closed day.</p>
      {DAYS.map((day) => {
        const current = readDay(day);
        return (
          <div key={day} className="flex items-center gap-2">
            <span className="w-20 text-xs capitalize text-buddy-text-secondary">{day.slice(0, 3)}</span>
            <input
              type="time"
              value={current.open}
              aria-label={`${day} opening time`}
              onChange={(e) => setDay(day, 'open', e.target.value)}
              className="flex-1 bg-buddy-surface border border-buddy-surface-raised rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
            />
            <span className="text-xs text-buddy-text-secondary">–</span>
            <input
              type="time"
              value={current.close}
              aria-label={`${day} closing time`}
              onChange={(e) => setDay(day, 'close', e.target.value)}
              className="flex-1 bg-buddy-surface border border-buddy-surface-raised rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
            />
          </div>
        );
      })}
    </fieldset>
  );
}

/**
 * Station management.
 *
 * `GET /marketplace/stations/` returns every station, each carrying its owning
 * shop or gym. Ownership is therefore *derived* — no extra endpoint, no
 * assumption that the caller owns whatever is on screen — and the page renders
 * only the stations the caller may actually edit.
 */
export default function StationManage() {
  const { toast } = useToast();
  const userId = useAuthStore((s) => s.user?.id);
  const username = useAuthStore((s) => s.profile?.username);

  const identity = useMemo<StationOwnerIdentity>(() => ({ id: userId ?? null, username: username ?? null }), [userId, username]);

  const [stations, setStations] = useState<PickupStation[]>([]);
  const [totalStations, setTotalStations] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [editing, setEditing] = useState<PickupStation | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<StationWritePayload>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const [applying, setApplying] = useState(false);
  const [application, setApplication] = useState<StationApplication | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await stationsApi.list();
      const rows = Array.isArray(res?.data) ? res.data : [];
      setStations(rows);
      setTotalStations(rows.length);
    } catch (e) {
      // The stations endpoints may not be deployed yet — say so plainly rather
      // than rendering an empty "you own nothing" list.
      setError(
        isStationsUnavailable(e)
          ? 'Pickup stations are not available on this server yet.'
          : stationsErrorMessage(e, 'Could not load stations.'),
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  const owned = useMemo(() => deriveOwnedStations(stations, identity), [stations, identity]);

  const openCreate = () => {
    setEditing(null);
    setForm(EMPTY_FORM);
    setFormError(null);
    setModalOpen(true);
  };

  const openEdit = (station: PickupStation) => {
    setEditing(station);
    setForm({
      name: station.name || '',
      address: station.address || '',
      city: station.city || '',
      country: station.country || '',
      phone: station.phone || '',
      latitude: station.latitude ?? null,
      longitude: station.longitude ?? null,
      is_primary: station.is_primary === true,
      owner_type: station.owner_type === 'gym' ? 'gym' : 'shop',
      opening_hours: station.opening_hours ?? null,
    });
    setFormError(null);
    setModalOpen(true);
  };

  const save = async () => {
    if (!form.name.trim()) {
      setFormError('A station name is required.');
      return;
    }
    setSaving(true);
    setFormError(null);
    try {
      const payload: StationWritePayload = {
        ...form,
        name: form.name.trim(),
        address: form.address?.trim() || undefined,
        city: form.city?.trim() || undefined,
        country: form.country?.trim() || undefined,
        phone: form.phone?.trim() || undefined,
        latitude: form.latitude === null || form.latitude === undefined || Number.isNaN(Number(form.latitude)) ? null : Number(form.latitude),
        longitude: form.longitude === null || form.longitude === undefined || Number.isNaN(Number(form.longitude)) ? null : Number(form.longitude),
      };
      if (editing?.id) await stationsApi.update(editing.id, payload);
      else await stationsApi.create(payload);
      toast('success', editing?.id ? 'Station updated' : 'Station created');
      setModalOpen(false);
      load();
    } catch (e) {
      setFormError(stationsErrorMessage(e, 'Could not save the station.'));
    } finally {
      setSaving(false);
    }
  };

  const apply = async () => {
    setApplying(true);
    try {
      const res = await stationsApi.apply({ notes: 'Requesting to run a pickup station.' });
      // The POST returns the application with its approval status, which is the
      // only place the caller can read it back from — surface it immediately.
      setApplication((res?.data as StationApplication) ?? { status: 'pending' });
      toast('success', 'Application submitted');
    } catch (e) {
      toast('error', stationsErrorMessage(e, 'Could not submit the application.'));
    } finally {
      setApplying(false);
    }
  };

  return (
    <RoleDashboardShell
      title="Pickup stations"
      subtitle="Collection points you run"
      backTo="/marketplace"
      actions={
        <Button size="sm" onClick={openCreate}>
          <Plus size={14} className="mr-1" /> New station
        </Button>
      }
    >
      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">{error}</div>
      )}

      <section className="space-y-2">
        <RoleSectionTitle action={<span className="text-xs text-buddy-text-secondary">{owned.length} of {totalStations}</span>}>
          Your stations
        </RoleSectionTitle>

        {loading ? (
          <div className="space-y-2" role="status" aria-busy="true" aria-label="Loading">
            <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
            <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
          </div>
        ) : owned.length === 0 ? (
          <Card className="p-8 text-center space-y-3">
            <RadioTower size={28} className="mx-auto text-buddy-text-secondary opacity-40" />
            <p className="text-sm text-buddy-text-secondary">
              {totalStations > 0
                ? 'You do not own any of the stations on this server yet.'
                : 'No pickup stations exist yet.'}
            </p>
            <Button size="sm" onClick={openCreate}>Create your first station</Button>
          </Card>
        ) : (
          <div className="space-y-2">
            {owned.map((station, i) => (
              <Card key={station.id || `station-${i}`} className="p-4 space-y-2">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-semibold truncate">{station.name || 'Unnamed station'}</p>
                      {station.is_primary && <Badge variant="gold" label="Primary" size="sm" />}
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-0.5 flex items-center gap-1">
                      <MapPin size={11} /> {stationAreaLabel(station)}
                    </p>
                  </div>
                  <Button size="sm" variant="ghost" onClick={() => openEdit(station)} aria-label={`Edit ${station.name || 'station'}`}>
                    <Pencil size={13} />
                  </Button>
                </div>
                <div className="flex flex-wrap gap-3 text-[11px] text-buddy-text-secondary">
                  <span className="flex items-center gap-1"><Building2 size={11} /> {station.owner_type === 'gym' ? 'Gym' : 'Shop'} owned</span>
                  <span className="flex items-center gap-1"><Clock size={11} /> {stationOpeningHoursLabel(station.opening_hours)}</span>
                  {station.phone && <span>{station.phone}</span>}
                </div>
              </Card>
            ))}
          </div>
        )}
      </section>

      {/* Application */}
      <section className="space-y-2">
        <RoleSectionTitle>Run a station elsewhere</RoleSectionTitle>
        <Card className="p-4 space-y-3">
          {application ? (
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <p className="text-sm font-semibold">Application status</p>
                <Badge
                  variant={isPendingApplication(application.status) ? 'orange' : application.status === 'approved' ? 'green' : application.status === 'rejected' ? 'red' : 'silver'}
                  label={(application.status || 'pending').replace(/_/g, ' ')}
                  size="sm"
                />
              </div>
              <p className="text-xs text-buddy-text-secondary">
                {isPendingApplication(application.status)
                  ? 'Your application is awaiting review. You can keep managing the stations you already own.'
                  : application.status === 'approved'
                    ? 'Approved. Add the station details to start using it.'
                    : application.rejection_reason || 'This application was not approved.'}
              </p>
            </div>
          ) : (
            <>
              <p className="text-xs text-buddy-text-secondary">
                Own a shop or gym but need a collection point somewhere else? Apply to run one — an admin reviews each application.
              </p>
              <Button size="sm" variant="outline" isLoading={applying} onClick={apply}>Apply to become a station</Button>
            </>
          )}
        </Card>
      </section>

      {/* Create / edit */}
      <Modal isOpen={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Edit station' : 'New station'}>
        <div className="space-y-3 max-h-[70vh] overflow-y-auto">
          <Input label="Name" placeholder="Westlands collection point" value={form.name} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, name: e.target.value })} />
          <Input label="Address" placeholder="12th Street, Westlands" value={form.address || ''} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, address: e.target.value })} />
          <div className="grid grid-cols-2 gap-3">
            <Input label="City" placeholder="Nairobi" value={form.city || ''} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, city: e.target.value })} />
            <Input label="Country" placeholder="Kenya" value={form.country || ''} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, country: e.target.value })} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Input label="Latitude" type="number" step="any" placeholder="-1.2864" value={form.latitude === null || form.latitude === undefined ? '' : String(form.latitude)} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, latitude: e.target.value === '' ? null : Number(e.target.value) })} />
            <Input label="Longitude" type="number" step="any" placeholder="36.8172" value={form.longitude === null || form.longitude === undefined ? '' : String(form.longitude)} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, longitude: e.target.value === '' ? null : Number(e.target.value) })} />
          </div>
          <Input label="Phone" type="tel" placeholder="+254…" value={form.phone || ''} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setForm({ ...form, phone: e.target.value })} />
          <OpeningHoursEditor
            value={form.opening_hours ?? null}
            onChange={(hours) => setForm({ ...form, opening_hours: hours })}
          />
          <div className="space-y-1">
            <span className="block text-sm font-medium text-buddy-text-secondary">Owner type</span>
            <select
              value={form.owner_type || 'shop'}
              onChange={(e) => setForm({ ...form, owner_type: e.target.value as 'shop' | 'gym' })}
              aria-label="Owner type"
              className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green"
            >
              <option value="shop">Shop</option>
              <option value="gym">Gym</option>
            </select>
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={form.is_primary === true} onChange={(e) => setForm({ ...form, is_primary: e.target.checked })} className="accent-buddy-green" />
            Primary station for this owner
          </label>

          {formError && (
            <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{formError}</div>
          )}

          <div className="flex gap-2 pt-1">
            <Button onClick={save} isLoading={saving} className="flex-1">{editing ? 'Save changes' : 'Create station'}</Button>
            <Button variant="ghost" onClick={() => setModalOpen(false)}>Cancel</Button>
          </div>
        </div>
      </Modal>
    </RoleDashboardShell>
  );
}