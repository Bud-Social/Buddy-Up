import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Bike, Building2, CreditCard, Dumbbell, LayoutDashboard, RadioTower,
  ShieldCheck, ShoppingCart, TrendingUp, Users, UsersRound, ChevronRight,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, adminPortalErrorMessage, portalListItems } from '@/api/adminPortal';
import type { ApiResponse } from '@/types';
import { AdminErrorBanner } from './shared';

/**
 * Admin console home.
 *
 * Deliberately additive: `/admin` still renders the pre-existing ML dashboard,
 * so every existing bookmark keeps working. This page is the landing surface
 * that orients a staff member — one card per domain, each linking straight to
 * its page, with live counts pulled from the portal API.
 *
 * Every probe is independent (`Promise.allSettled`): one failing endpoint
 * degrades a single card instead of blanking the whole console.
 */

interface Probe {
  key: string;
  label: string;
  to: string;
  icon: typeof Users;
  load: () => Promise<ApiResponse<unknown[]>>;
}

const PROBES: Probe[] = [
  { key: 'users', label: 'Users', to: '/admin/users', icon: Users, load: () => adminPortalApi.getUsers({ page_size: 1 }) },
  { key: 'shops', label: 'Shops', to: '/admin/shops', icon: Building2, load: () => adminPortalApi.getShops({ page_size: 1 }) },
  { key: 'products', label: 'Products', to: '/admin/shops', icon: TrendingUp, load: () => adminPortalApi.getProducts({ page_size: 1 }) },
  { key: 'orders', label: 'Orders', to: '/admin/orders', icon: ShoppingCart, load: () => adminPortalApi.getOrders({ page_size: 1 }) },
  { key: 'gyms', label: 'Gyms', to: '/admin/gyms', icon: Dumbbell, load: () => adminPortalApi.getGyms({ page_size: 1 }) },
  { key: 'communities', label: 'Communities', to: '/admin/communities', icon: UsersRound, load: () => adminPortalApi.getCommunities({ page_size: 1 }) },
  { key: 'stations', label: 'Stations', to: '/admin/stations', icon: RadioTower, load: () => adminPortalApi.getStations({ page_size: 1 }) },
  { key: 'delivery', label: 'Delivery', to: '/admin/delivery', icon: Bike, load: () => adminPortalApi.getDeliveryPersonnel({ page_size: 1 }) },
  { key: 'wallet', label: 'Transactions', to: '/admin/wallet', icon: CreditCard, load: () => adminPortalApi.getTransactions({ page_size: 1 }) },
];

const QUEUES = [
  { to: '/admin/shops', label: 'Shop certifications', icon: ShieldCheck },
  { to: '/admin/stations', label: 'Station applications', icon: RadioTower },
  { to: '/admin/delivery', label: 'Delivery applications', icon: Bike },
  { to: '/admin/moderation', label: 'Content moderation', icon: ShieldCheck },
  { to: '/admin/verification', label: 'Verification reviews', icon: ShieldCheck },
];

type ProbeState = { count: number | null; error: string };

export default function AdminHome() {
  const [states, setStates] = useState<Record<string, ProbeState>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [nonce, setNonce] = useState(0);

  const reload = useCallback(() => {
    setLoading(true);
    setError('');
    setNonce((n) => n + 1);
  }, []);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      const results = await Promise.allSettled(PROBES.map((p) => p.load()));
      if (cancelled) return;
      const next: Record<string, ProbeState> = {};
      let anySuccess = false;
      results.forEach((result, i) => {
        const probe = PROBES[i];
        if (result.status === 'fulfilled') {
          anySuccess = true;
          const items = portalListItems(result.value?.data);
          const paginationCount = result.value?.pagination?.count;
          next[probe.key] = {
            count: typeof paginationCount === 'number' ? paginationCount : items.length,
            error: '',
          };
        } else {
          next[probe.key] = { count: null, error: adminPortalErrorMessage(result.reason, 'Unavailable.') };
        }
      });
      setStates(next);
      setError(anySuccess ? '' : 'The admin portal API is not reachable from this session.');
      setLoading(false);
    };
    void run();
    return () => { cancelled = true; };
  }, [nonce]);

  return (
    <div className="space-y-6 pb-8">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <h2 className="font-display text-xl sm:text-2xl font-extrabold flex items-center gap-2">
            <LayoutDashboard size={20} className="text-buddy-green" /> Admin overview
          </h2>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Every surface on one page. You are signed in as yourself — nothing here impersonates another user.
          </p>
        </div>
        <Button variant="outline" size="sm" onClick={reload} isLoading={loading}>Refresh</Button>
      </div>

      {error && <AdminErrorBanner message={error} onRetry={reload} />}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        {PROBES.map(({ key, label, to, icon: Icon }) => {
          const state = states[key];
          return (
            <Link
              key={key}
              to={to}
              className="group"
              aria-label={`Open ${label}`}
            >
              <Card className="p-4 h-full transition-colors group-hover:bg-buddy-surface-raised">
                <div className="flex items-center justify-between gap-2">
                  <span className="flex items-center gap-2 text-xs text-buddy-text-secondary min-w-0">
                    <Icon size={15} className="shrink-0" />
                    <span className="truncate">{label}</span>
                  </span>
                  <ChevronRight size={14} className="text-buddy-text-secondary shrink-0" />
                </div>
                {state?.error ? (
                  <p className="text-[11px] text-buddy-red mt-2">Unavailable</p>
                ) : (
                  <p className="font-display font-extrabold text-2xl leading-tight mt-1">
                    {state?.count === null || state?.count === undefined
                      ? <span className="text-buddy-text-secondary/40 text-lg">—</span>
                      : state.count.toLocaleString()}
                  </p>
                )}
                <p className="text-[11px] text-buddy-text-secondary">total</p>
              </Card>
            </Link>
          );
        })}
      </div>

      <div>
        <p className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">Review queues</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {QUEUES.map(({ to, label, icon: Icon }) => (
            <Link key={to + label} to={to} className="group" aria-label={`Open ${label}`}>
              <Card className="p-3 flex items-center gap-2 transition-colors group-hover:bg-buddy-surface-raised">
                <Icon size={15} className="text-buddy-green shrink-0" />
                <span className="text-xs truncate flex-1">{label}</span>
                <ChevronRight size={13} className="text-buddy-text-secondary shrink-0" />
              </Card>
            </Link>
          ))}
        </div>
      </div>

      <p className="text-[11px] text-buddy-text-secondary text-center">
        The ML dashboard (model registry, training runs, system health) remains at{' '}
        <Link to="/admin" className="text-buddy-green hover:underline">/admin</Link>.
      </p>
    </div>
  );
}