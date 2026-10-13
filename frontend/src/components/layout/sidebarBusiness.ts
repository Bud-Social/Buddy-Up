/**
 * The destinations an operator holds, and how the sidebar labels them.
 *
 * Deliberately a `.ts` module with no React imports, mirroring
 * `pages/admin/format.ts`: keeping the derivation out of `Sidebar.tsx` satisfies
 * `react-refresh/only-export-components` and lets the data layer and the
 * presentation layer be tested independently.
 */

export type BusinessRoleKey = 'shop' | 'events' | 'gym' | 'stations' | 'courier';

/** The five signals `useBusinessRoles` derives from real ownership data. */
export interface BusinessRoleFlags {
  hasShop: boolean;
  hasEvents: boolean;
  gymSlug: string | null;
  hasStation: boolean;
  isCourier: boolean;
}

export interface BusinessEntry {
  key: BusinessRoleKey;
  /** Route to navigate to. */
  to: string;
  /** Label in the "Your business" list. */
  label: string;
  /** Compact label in the role switcher. */
  shortLabel: string;
}

/**
 * Destinations the operator qualifies for, in working-priority order.
 *
 * The switcher and the nav list are both built from this one list, so a
 * destination can never be reachable from one and missing from the other.
 */
export function businessEntries(flags: BusinessRoleFlags): BusinessEntry[] {
  const entries: BusinessEntry[] = [];
  if (flags.hasShop) entries.push({ key: 'shop', to: '/marketplace/creator', label: 'Creator Studio', shortLabel: 'Shop' });
  if (flags.hasEvents) entries.push({ key: 'events', to: '/marketplace/events', label: 'My Events', shortLabel: 'Events' });
  if (flags.gymSlug) entries.push({ key: 'gym', to: `/gyms/${flags.gymSlug}/manage`, label: 'My Gym', shortLabel: 'Gym' });
  if (flags.hasStation) entries.push({ key: 'stations', to: '/marketplace/stations', label: 'My Stations', shortLabel: 'Stations' });
  if (flags.isCourier) entries.push({ key: 'courier', to: '/marketplace/delivery', label: 'Courier', shortLabel: 'Courier' });
  return entries;
}