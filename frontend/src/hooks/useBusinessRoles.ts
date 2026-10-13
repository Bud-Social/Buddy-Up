import { useEffect, useMemo, useState } from 'react';
import { marketplaceApi } from '@/api/marketplace';
import { stationsApi, deriveOwnedStations, type StationOwnerIdentity } from '@/api/stations';
import { gymsApi } from '@/api/gyms';
import { useAuthStore } from '@/store/authStore';
import type { Gym } from '@/types';

/**
 * Role signals for the sidebar.
 *
 * Every flag is independently optional: a probe that fails (or an endpoint that
 * does not exist yet) resolves to `false` rather than blocking the sidebar, so a
 * backend that is mid-rollout can only ever hide an entry — never show one the
 * user does not hold, and never break navigation.
 */
export interface BusinessRoles {
  /** True until every probe has settled. Sidebar renders `false` meanwhile. */
  loading: boolean;
  /** Owns a shop, or has ever sold a marketplace service. */
  hasShop: boolean;
  /** Has created at least one event. */
  hasEvents: boolean;
  /** Slug of the first gym where the user is owner or co_owner. */
  gymSlug: string | null;
  /** Name of that gym, for the switcher label. */
  gymName: string | null;
  /** Owns at least one pickup station. */
  hasStation: boolean;
  /** Has a `DeliveryPersonnel` row. */
  isCourier: boolean;
}

const EMPTY: BusinessRoles = {
  loading: true,
  hasShop: false,
  hasEvents: false,
  gymSlug: null,
  gymName: null,
  hasStation: false,
  isCourier: false,
};

/**
 * Resolve a probe without letting one failure take down the rest.
 *
 * `Promise.allSettled` over individually `.catch`ed promises would do the same
 * job, but `allSettled` also guarantees a settled promise per probe even if a
 * mocked/faked method throws synchronously — which is exactly what happens in
 * tests and in a jsdom render with no server.
 */
function probe<T>(fn: () => Promise<T>, fallback: T): Promise<T> {
  try {
    return Promise.resolve(fn()).catch(() => fallback);
  } catch {
    return Promise.resolve(fallback);
  }
}

export function useBusinessRoles(): BusinessRoles {
  const userId = useAuthStore((s) => s.user?.id);
  const username = useAuthStore((s) => s.profile?.username);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [roles, setRoles] = useState<BusinessRoles>(EMPTY);

  const identity = useMemo<StationOwnerIdentity>(
    () => ({ id: userId ?? null, username: username ?? null }),
    [userId, username],
  );

  useEffect(() => {
    // Signed out: nothing to derive, and probing would 401 on every mount.
    if (!isAuthenticated || !userId) {
      setRoles({ ...EMPTY, loading: false });
      return;
    }

    let cancelled = false;
    setRoles({ ...EMPTY, loading: true });

    Promise.all([
      // A shop OR any created listing both mean "you sell here".
      probe(async () => {
        const [shops, services] = await Promise.all([
          probe(() => marketplaceApi.getMyShops(), null as { data: unknown[] } | null),
          probe(() => marketplaceApi.getMyServices(), null as never),
        ]);
        const hasOwnedShop = Array.isArray(shops?.data) && shops.data.length > 0;
        const svc = services?.data as
          | { meal_plans?: unknown[]; programmes?: unknown[]; events?: unknown[]; products?: unknown[] }
          | null;
        const hasSold = Boolean(
          svc && [svc.meal_plans, svc.programmes, svc.events, svc.products].some((l) => Array.isArray(l) && l.length > 0),
        );
        return hasOwnedShop || hasSold;
      }, false),
      // 403 for a non-organiser is the expected answer and reads as "no events".
      probe(async () => {
        const res = await marketplaceApi.getOrganisedEvents();
        const rows = Array.isArray(res?.data) ? res.data : ((res?.data as { results?: unknown[] })?.results ?? []);
        return rows.length > 0;
      }, false),
      // `my: true` returns every gym the user belongs to; ownership is decided
      // by the role the caller already holds, not by membership alone.
      probe(async () => {
        const res = await gymsApi.list({ my: true });
        const rows: Gym[] = Array.isArray(res?.data)
          ? res.data
          : ((res?.data as { results?: Gym[] })?.results ?? []);
        const owned = rows.find(
          (g) => g?.membership_role === 'owner' || g?.membership_role === 'co_owner',
        );
        return owned ? { slug: owned.handle, name: owned.name } : null;
      }, null as { slug: string; name: string } | null),
      // Ownership is derived from the list response itself — no per-row probe.
      probe(async () => {
        const res = await stationsApi.list();
        const rows = Array.isArray(res?.data) ? res.data : ((res?.data as { results?: never[] })?.results ?? []);
        return deriveOwnedStations(rows as never[], identity).length > 0;
      }, false),
      // The delivery summary 404s for anyone without a DeliveryPersonnel row,
      // which is precisely the "not a courier" answer.
      probe(async () => {
        await marketplaceApi.getCourierSummary();
        return true;
      }, false),
    ]).then(([hasShop, hasEvents, gym, hasStation, isCourier]) => {
      if (cancelled) return;
      setRoles({
        loading: false,
        hasShop,
        hasEvents,
        gymSlug: gym?.slug ?? null,
        gymName: gym?.name ?? null,
        hasStation,
        isCourier,
      });
    });

    return () => { cancelled = true; };
  }, [isAuthenticated, userId, identity]);

  return roles;
}