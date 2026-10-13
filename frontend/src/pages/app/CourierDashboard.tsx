import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bike, MapPin, Navigation, Star, Package, Building2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Toggle } from '@/components/ui/Toggle';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi, courierActionsFor, checkoutErrorMessage } from '@/api/marketplace';
import type { CourierOrder, CourierProfile, CourierEarnings } from '@/api/marketplace';
import { RoleDashboardShell, RoleSectionTitle } from './roles/RoleShell';

const STATUS_FILTERS = [
  { value: '', label: 'All' },
  { value: 'processing', label: 'Processing' },
  { value: 'shipped', label: 'Shipped' },
  { value: 'out_for_delivery', label: 'Out for delivery' },
  { value: 'delivered', label: 'Delivered' },
];

function addressLabel(raw: CourierOrder['delivery_address']): string {
  if (!raw) return 'No delivery address on file';
  if (typeof raw === 'string') return raw;
  const parts = ['line1', 'line2', 'city', 'postal_code', 'country']
    .map((k) => (typeof raw[k] === 'string' ? (raw[k] as string).trim() : ''))
    .filter(Boolean);
  return parts.length ? parts.join(', ') : 'No delivery address on file';
}

function artifactsUsd(artifacts: Record<string, number> | null | undefined): number {
  const VALUES: Record<string, number> = { dumbbell: 0.10, barbell: 0.50, burpee: 1.00, squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00 };
  if (!artifacts) return 0;
  return Object.entries(artifacts).reduce((sum, [k, v]) => sum + (VALUES[k] || 0) * (v || 0), 0);
}

/**
 * Courier dashboard.
 *
 * Three surfaces: the rider's profile (with the availability toggle), the orders
 * assigned to them with only the legal status actions, and an earnings figure
 * that is explicitly an estimate rather than a payable balance.
 */
export default function CourierDashboard() {
  const navigate = useNavigate();

  const [profile, setProfile] = useState<CourierProfile | null>(null);
  const [orders, setOrders] = useState<CourierOrder[]>([]);
  const [earnings, setEarnings] = useState<CourierEarnings | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState('');
  const [busyOrder, setBusyOrder] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [toggling, setToggling] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      // The summary is the gate: it is scoped to the signed-in courier, so a
      // 404 means there is no DeliveryPersonnel row at all. In that case send
      // the rider to the registration wizard instead of showing an empty shell.
      const summary = await marketplaceApi.getCourierSummary();
      setProfile(summary.data);
      const [ordersRes, earningsRes] = await Promise.all([
        marketplaceApi.getCourierOrders(statusFilter || undefined).catch(() => null),
        marketplaceApi.getCourierEarnings().catch(() => null),
      ]);
      setOrders(Array.isArray(ordersRes?.data) ? ordersRes.data : []);
      setEarnings(earningsRes?.data ?? null);
    } catch (e) {
      const status = (e as { response?: { status?: number } })?.response?.status;
      if (status === 404) {
        navigate('/marketplace/delivery/register', { replace: true });
        return;
      }
      setError(checkoutErrorMessage(e, 'Could not load your courier profile.'));
    } finally {
      setLoading(false);
    }
  }, [navigate, statusFilter]);

  useEffect(() => { load(); }, [load]);

  const handleAction = async (order: CourierOrder, nextStatus: string) => {
    if (!order.id) return;
    setBusyOrder(order.id);
    setActionError(null);
    try {
      await marketplaceApi.updateCourierOrderStatus(order.id, nextStatus as never);
      await load();
    } catch (e) {
      // The backend names the illegal move in a 400 — surface it verbatim.
      setActionError(checkoutErrorMessage(e, 'That status change was refused.'));
    } finally {
      setBusyOrder(null);
    }
  };

  const handleToggleActive = async (next: boolean) => {
    setToggling(true);
    setActionError(null);
    const previous = profile?.is_active;
    setProfile((p) => (p ? { ...p, is_active: next } : p));
    try {
      await marketplaceApi.toggleCourierActive(next, {
        vehicle_type: profile?.vehicle_type ?? undefined,
        service_zones: profile?.service_zones ?? undefined,
      });
    } catch (e) {
      setProfile((p) => (p ? { ...p, is_active: previous } : p));
      setActionError(checkoutErrorMessage(e, 'Could not update your availability.'));
    } finally {
      setToggling(false);
    }
  };

  const counts = profile?.counts ?? {};
  const zones = useMemo(() => (profile?.service_zones ?? []).filter(Boolean), [profile?.service_zones]);

  if (loading && !profile) {
    return (
      <RoleDashboardShell title="Courier" subtitle="Your deliveries" backTo="/marketplace">
        <div className="space-y-3" role="status" aria-busy="true" aria-label="Loading">
          <Card className="h-28 animate-pulse bg-buddy-surface-raised" />
          <Card className="h-24 animate-pulse bg-buddy-surface-raised" />
          <Card className="h-24 animate-pulse bg-buddy-surface-raised" />
        </div>
      </RoleDashboardShell>
    );
  }

  return (
    <RoleDashboardShell
      title="Courier"
      subtitle="Your deliveries"
      backTo="/marketplace"
      actions={<Button size="sm" variant="outline" onClick={() => navigate('/marketplace/delivery/register')}><Bike size={14} className="mr-1" /> Courier details</Button>}
    >
      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">{error}</div>
      )}
      {actionError && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{actionError}</div>
      )}

      {/* Profile */}
      <Card className="p-4 space-y-3">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0 space-y-1">
            <p className="text-xs text-buddy-text-secondary">Vehicle</p>
            <p className="font-semibold capitalize">{profile?.vehicle_type || 'Not set'}</p>
          </div>
          <div className="min-w-0 space-y-1">
            <p className="text-xs text-buddy-text-secondary flex items-center gap-1"><Star size={12} className="fill-current" /> Rating</p>
            <p className="font-semibold">{typeof profile?.rating === 'number' ? profile.rating.toFixed(2) : '—'}</p>
          </div>
          <div className="min-w-0 space-y-1">
            <p className="text-xs text-buddy-text-secondary">Commission</p>
            <p className="font-semibold">{typeof profile?.commission_rate === 'number' ? `${(profile.commission_rate * 100).toFixed(1)}%` : '—'}</p>
          </div>
        </div>

        <div className="space-y-1">
          <p className="text-xs text-buddy-text-secondary">Service zones</p>
          <div className="flex flex-wrap gap-1.5">
            {zones.length ? zones.map((zone) => <Badge key={zone} variant="electric" label={zone} size="sm" />) : <span className="text-sm text-buddy-text-secondary">No zones assigned yet</span>}
          </div>
        </div>

        <div className="flex items-center justify-between gap-3 pt-2 border-t border-buddy-surface-raised">
          <div>
            <p className="text-sm font-medium">Accepting deliveries</p>
            <p className="text-xs text-buddy-text-secondary">Pause when you are unavailable</p>
          </div>
          <Toggle checked={profile?.is_active === true} disabled={toggling} onCheckedChange={handleToggleActive} label="Accepting deliveries" />
        </div>
      </Card>

      {/* Orders */}
      <section className="space-y-3">
        <RoleSectionTitle>Assigned orders</RoleSectionTitle>
        <div className="flex gap-1.5 overflow-x-auto scrollbar-hide pb-1">
          {STATUS_FILTERS.map((f) => {
            const count = f.value ? counts[f.value] : undefined;
            return (
              <button
                key={f.value || 'all'}
                onClick={() => setStatusFilter(f.value)}
                aria-pressed={statusFilter === f.value}
                className={`px-2.5 py-1 text-[11px] font-semibold rounded-lg transition-colors whitespace-nowrap ${statusFilter === f.value ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary'}`}
              >
                {f.label}{typeof count === 'number' ? ` ${count}` : ''}
              </button>
            );
          })}
        </div>

        {orders.length === 0 ? (
          <Card className="p-8 text-center text-buddy-text-secondary space-y-2">
            <p className="text-sm">No assigned orders.</p>
            <p className="text-xs">New deliveries appear here as soon as they are assigned to you.</p>
          </Card>
        ) : (
          <div className="space-y-3">
            {orders.map((order) => {
              const actions = courierActionsFor(order.status);
              const commission = order.commission_artifacts || {};
              return (
                <Card key={order.id} className="p-4 space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2 min-w-0">
                      <Package size={14} className="text-buddy-text-secondary flex-shrink-0" />
                      <span className="font-mono text-xs font-bold truncate">{order.order_number || order.id}</span>
                    </div>
                    <Badge variant={order.status === 'delivered' ? 'green' : order.status === 'out_for_delivery' ? 'blue' : 'orange'} label={order.status_label || order.status || 'Unknown'} size="sm" />
                  </div>

                  {/* Delivery address and pickup point are in view, not behind a tap. */}
                  <div className="space-y-1.5 text-xs">
                    <p className="flex items-start gap-1.5 text-buddy-text-secondary">
                      <MapPin size={12} className="mt-0.5 flex-shrink-0" />
                      <span>{addressLabel(order.delivery_address)}</span>
                    </p>
                    {order.pickup_station && (
                      <p className="flex items-start gap-1.5 text-buddy-text-secondary">
                        <Building2 size={12} className="mt-0.5 flex-shrink-0" />
                        <span>Pick up: {order.pickup_station.name}{order.pickup_station.address ? ` — ${order.pickup_station.address}` : ''}</span>
                      </p>
                    )}
                  </div>

                  {Array.isArray(order.items) && order.items.length > 0 && (
                    <div className="space-y-1 pt-2 border-t border-buddy-surface-raised">
                      {order.items.map((item, i) => (
                        <p key={i} className="flex items-center justify-between gap-2 text-xs">
                          <span className="truncate">{item.title}</span>
                          <span className="text-buddy-text-secondary flex-shrink-0">x{item.quantity}{item.creator_name ? ` · ${item.creator_name}` : ''}</span>
                        </p>
                      ))}
                    </div>
                  )}

                  {Object.keys(commission).length > 0 && (
                    <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                      <Navigation size={12} />
                      Commission <ArtifactIcon artifact={Object.keys(commission)[0]} quantity={Object.values(commission)[0]} size={12} />
                      <span className="text-buddy-text-primary font-medium">≈ ${artifactsUsd(commission).toFixed(2)}</span>
                    </div>
                  )}

                  {actions.length > 0 ? (
                    <div className="flex flex-wrap gap-2 pt-2">
                      {actions.map((action) => (
                        <Button
                          key={action.to}
                          size="sm"
                          variant={action.to === 'delivered' ? 'primary' : 'outline'}
                          disabled={busyOrder === order.id}
                          onClick={() => handleAction(order, action.to)}
                        >
                          {action.label}
                        </Button>
                      ))}
                    </div>
                  ) : (
                    <p className="text-xs text-buddy-text-secondary pt-2">No status changes available from “{order.status_label || order.status}”.</p>
                  )}
                </Card>
              );
            })}
          </div>
        )}
      </section>

      {/* Earnings — an estimate from completed orders, never a payable balance. */}
      <section className="space-y-2">
        <RoleSectionTitle>Earnings</RoleSectionTitle>
        <Card className="p-4 space-y-3">
          <div className="flex items-baseline justify-between gap-3">
            <div>
              <p className="text-xs text-buddy-text-secondary">Estimated commission</p>
              <p className="font-display font-extrabold text-2xl mt-0.5">≈ ${artifactsUsd(earnings?.commission_artifacts).toFixed(2)}</p>
            </div>
            <Badge variant="orange" label="Estimate" size="sm" />
          </div>
          <div className="grid grid-cols-2 gap-3 pt-2 border-t border-buddy-surface-raised text-xs">
            <div>
              <p className="text-buddy-text-secondary">Delivered orders</p>
              <p className="font-semibold">{earnings?.delivered_count ?? 0}</p>
            </div>
            <div>
              <p className="text-buddy-text-secondary">Order value</p>
              <p className="font-semibold">≈ ${artifactsUsd(earnings?.delivered_value_artifacts).toFixed(2)}</p>
            </div>
          </div>
          <p className="text-[11px] text-buddy-text-secondary leading-relaxed">
            This is an estimate calculated from your completed orders. It is not a payable balance — payouts are made from your wallet ledger.
          </p>
        </Card>
      </section>
    </RoleDashboardShell>
  );
}