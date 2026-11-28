import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bike, CheckCircle2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { marketplaceApi, checkoutErrorMessage } from '@/api/marketplace';
import { RoleDashboardShell } from './roles/RoleShell';
import { verificationApi } from '@/api/verification';

const VEHICLE_TYPES = ['bicycle', 'motorcycle', 'car', 'van'];

/**
 * Courier self-registration.
 *
 * The dashboard sends riders here when `GET /delivery/summary/` 404s, which is
 * the server's way of saying "no `DeliveryPersonnel` row for this user". The
 * same `POST /marketplace/delivery-personnel/` endpoint creates the row and
 * flips the availability toggle afterwards.
 */
export default function CourierRegister() {
  const navigate = useNavigate();
  const [vehicleType, setVehicleType] = useState('motorcycle');
  const [plate, setPlate] = useState('');
  const [phone, setPhone] = useState('');
  const [zones, setZones] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [idFile, setIdFile] = useState<File | null>(null);
  const [licenceFile, setLicenceFile] = useState<File | null>(null);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const [idDoc, licenceDoc] = await Promise.all([
        idFile ? verificationApi.uploadCredential('id_card', idFile) : Promise.resolve(null),
        licenceFile ? verificationApi.uploadCredential('drivers_license', licenceFile) : Promise.resolve(null),
      ]);
      await marketplaceApi.registerDeliveryPersonnel({
        vehicle_type: vehicleType,
        vehicle_plate: plate.trim() || undefined,
        phone: phone.trim() || undefined,
        service_zones: zones.split(',').map((z) => z.trim()).filter(Boolean),
        is_active: true,
        id_document_url: idDoc?.data?.file_url || undefined,
        licence_document_url: licenceDoc?.data?.file_url || undefined,
      });
      setDone(true);
      navigate('/marketplace/delivery', { replace: true });
    } catch (err) {
      setError(checkoutErrorMessage(err, 'Registration failed. Please try again.'));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <RoleDashboardShell title="Become a courier" subtitle="Register to start delivering" backTo="/marketplace">
      {done ? (
        <Card className="p-8 text-center space-y-2">
          <CheckCircle2 size={32} className="mx-auto text-buddy-green" />
          <p className="text-sm font-semibold">You are registered.</p>
          <p className="text-xs text-buddy-text-secondary">Taking you to your courier dashboard…</p>
        </Card>
      ) : (
        <form onSubmit={submit} className="space-y-4">
          <Card className="p-4 space-y-4">
            <div className="flex items-center gap-2">
              <span className="w-8 h-8 rounded-lg bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
                <Bike size={16} className="text-buddy-green" />
              </span>
              <p className="text-sm text-buddy-text-secondary">
                You need a courier registration before you can be assigned deliveries.
              </p>
            </div>

            <div className="space-y-1">
              <label htmlFor="courier-vehicle" className="block text-sm font-medium text-buddy-text-secondary">Vehicle type</label>
              <select
                id="courier-vehicle"
                value={vehicleType}
                onChange={(e) => setVehicleType(e.target.value)}
                className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              >
                {VEHICLE_TYPES.map((v) => <option key={v} value={v}>{v.charAt(0).toUpperCase() + v.slice(1)}</option>)}
              </select>
            </div>

            <Input label="Plate number (optional)" placeholder="KDA 123B" value={plate} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPlate(e.target.value)} />

            <Input label="Phone (optional)" type="tel" placeholder="+254…" value={phone} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPhone(e.target.value)} />

            <Input
              label="Service zones"
              helperText="Comma separated, e.g. Westlands, Kilimani"
              placeholder="Westlands, Kilimani"
              value={zones}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setZones(e.target.value)}
            />
            <div className="grid sm:grid-cols-2 gap-3">
              <label className="rounded-xl border border-dashed border-buddy-surface-raised p-3 text-xs text-buddy-text-secondary cursor-pointer hover:border-buddy-green">
                <span className="block font-medium text-buddy-text-primary">National ID / passport</span>
                <span className="block mt-1">{idFile?.name || 'Choose file · max 50 MB'}</span>
                <input type="file" accept="image/*,.pdf" className="hidden" onChange={(e) => setIdFile(e.target.files?.[0] || null)} />
              </label>
              <label className="rounded-xl border border-dashed border-buddy-surface-raised p-3 text-xs text-buddy-text-secondary cursor-pointer hover:border-buddy-green">
                <span className="block font-medium text-buddy-text-primary">Driving licence</span>
                <span className="block mt-1">{licenceFile?.name || 'Choose file · max 50 MB'}</span>
                <input type="file" accept="image/*,.pdf" className="hidden" onChange={(e) => setLicenceFile(e.target.files?.[0] || null)} />
              </label>
            </div>
          </Card>

          {error && (
            <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{error}</div>
          )}

          <Button type="submit" className="w-full" isLoading={submitting}>Register as courier</Button>
        </form>
      )}
    </RoleDashboardShell>
  );
}
