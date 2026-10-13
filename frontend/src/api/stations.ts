import type { AxiosError } from 'axios';
import { apiClient } from './client';
import type { ApiResponse } from '@/types';

/**
 * Typed client for the pickup-station and order-payment surface.
 *
 * Conventions mirror `api/marketplace.ts` and `api/adminPortal.ts`: the shared
 * axios instance, methods return the raw `{success,data,message,errors,
 * pagination}` envelope (unwrapped one level, not `data.data`), and every member
 * of a station is declared optional on purpose — these endpoints are landing in
 * parallel with this client, so a renamed or absent field must degrade in the UI
 * rather than crash the checkout.
 *
 * `GET /marketplace/stations/` only computes `distance_km` when `lat` and `lng`
 * are both supplied, so a caller with no location gets a list with no distances
 * at all. Every helper below treats that as a first-class "degraded" case
 * rather than an error: order is preserved, distance is simply omitted.
 */

export type StationOwnerType = 'shop' | 'gym';

/**
 * A station's owning entity. `GET /marketplace/stations/` returns one of these
 * inline on each row (`owner_type: 'shop' | 'gym'`) rather than only the id, so
 * ownership can be derived from the list response alone — no extra round trip.
 *
 * `membership_role` is what makes gym ownership decidable: a gym's `owner_data`
 * lists every leader with their role, and only `owner`/`co_owner` may edit a
 * station (matching the backend's write guard).
 */
export interface StationOwnerRef {
  id?: string | null;
  name?: string | null;
  handle?: string | null;
  /** The owning entity's own user id, when the backend denormalises it. */
  owner?: string | null;
  owner_username?: string | null;
  membership_role?: string | null;
  owner_data?: Array<{ user_id?: string | null; username?: string | null; role?: string | null }> | null;
}

export interface StationOwnerIdentity {
  id?: string | null;
  username?: string | null;
}

/** Real-money methods only. Artifacts (wallet) never goes through a provider. */
export type StationPaymentMethod = 'mpesa' | 'card';

export interface StationDayHours {
  open?: string | null;
  close?: string | null;
  closed?: boolean;
}

/**
 * `{monday: {open: '08:00', close: '20:00'}}` per the model, but a station may
 * legitimately ship a plain string per day (`{mon: '08:00-20:00'}`), so both
 * shapes are accepted.
 */
export type StationOpeningHours = Record<string, StationDayHours | string | null | undefined>;

export interface PickupStation {
  id?: string;
  name?: string;
  description?: string | null;
  address?: string | null;
  city?: string | null;
  country?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  opening_hours?: StationOpeningHours | null;
  phone?: string | null;
  instructions?: string | null;
  is_primary?: boolean;
  owner_type?: StationOwnerType | string | null;
  /** Present when `owner_type === 'shop'`. */
  shop?: StationOwnerRef | null;
  /** Present when `owner_type === 'gym'`. */
  gym?: StationOwnerRef | null;
  /** Present only when the list was called with both `lat` and `lng`. */
  distance_km?: number | null;
  created_at?: string | null;
}

/**
 * Write payload for `POST/PATCH /marketplace/stations/`.
 *
 * `owner_type` plus exactly one of `shop`/`gym` identifies the owner. The
 * backend enforces who may write (shop owner/manager, gym owner/co-owner); this
 * type only describes the shape.
 */
export interface StationWritePayload {
  name: string;
  address?: string;
  city?: string;
  country?: string;
  latitude?: number | null;
  longitude?: number | null;
  phone?: string;
  description?: string;
  instructions?: string;
  opening_hours?: StationOpeningHours | null;
  is_primary?: boolean;
  owner_type?: StationOwnerType;
  shop?: string;
  gym?: string;
}

/** `POST /marketplace/station-applications/` — reviewed by an admin. */
export interface StationApplication {
  id?: string;
  status?: string | null;
  station_name?: string | null;
  name?: string | null;
  city?: string | null;
  country?: string | null;
  address?: string | null;
  notes?: string | null;
  rejection_reason?: string | null;
  created_at?: string | null;
}

/** Statuses an application sits in before a decision lands. */
export const STATION_APPLICATION_PENDING = ['pending', 'submitted', 'under_review'] as const;

export function isPendingApplication(status: unknown): boolean {
  return typeof status === 'string' && (STATION_APPLICATION_PENDING as readonly string[]).includes(status.toLowerCase());
}

export interface StationListParams {
  lat?: number;
  lng?: number;
  radius_km?: number;
  owner_type?: StationOwnerType;
}

export interface PaymentIntent {
  id?: string;
  order_id?: string;
  method?: StationPaymentMethod | string | null;
  amount?: number | string | null;
  currency?: string | null;
  status?: string | null;
  provider_reference?: string | null;
}

export interface CreatePaymentIntentPayload {
  order_id: string;
  method: StationPaymentMethod;
  /** M-Pesa STK push target. Omitted from the body when absent. */
  phone?: string;
}

const DAY_KEYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] as const;
const DAY_LABELS: Record<string, string> = {
  monday: 'Mon', tuesday: 'Tue', wednesday: 'Wed', thursday: 'Thu',
  friday: 'Fri', saturday: 'Sat', sunday: 'Sun',
};

const HOURS_UNKNOWN = 'Hours not listed';
const ADDRESS_UNKNOWN = 'Address not listed';

/** True only for a usable, finite distance — the marker for "we know where you are". */
export function hasStationDistance(station: PickupStation): boolean {
  return typeof station.distance_km === 'number' && Number.isFinite(station.distance_km);
}

/**
 * Nearest first. The API already sorts this way, but re-sorting locally means a
 * station list still reads correctly if the ordering regresses or a caller
 * merges results from two queries.
 *
 * Degraded case: when no station carries a distance the server's order is
 * returned untouched (`Array.sort` is stable, so partial distances keep their
 * relative server order behind the measured ones).
 */
export function sortStationsByDistance<T extends PickupStation>(stations: T[]): T[] {
  if (!stations.some(hasStationDistance)) return [...stations];
  const rank = (s: T) => (hasStationDistance(s) ? (s.distance_km as number) : Number.POSITIVE_INFINITY);
  return [...stations].sort((a, b) => rank(a) - rank(b));
}

/** Normalise a list payload that may arrive bare, paginated, or empty. */
export function stationList<T extends PickupStation>(data: unknown): T[] {
  if (Array.isArray(data)) return data as T[];
  if (data && typeof data === 'object') {
    const results = (data as { results?: unknown }).results;
    if (Array.isArray(results)) return results as T[];
    const items = (data as { items?: unknown }).items;
    if (Array.isArray(items)) return items as T[];
  }
  return [];
}

/** `address, city, country` collapsed into one line, or a placeholder. */
export function stationAreaLabel(station: PickupStation): string {
  const parts = [station.address, station.city, station.country]
    .map((p) => (typeof p === 'string' ? p.trim() : ''))
    .filter(Boolean);
  return parts.length ? parts.join(', ') : ADDRESS_UNKNOWN;
}

function dayWindowLabel(value: StationDayHours | string | null | undefined): string | null {
  if (!value) return null;
  if (typeof value === 'string') return value.trim() || null;
  if (value.closed) return null;
  const open = value.open?.trim() || '';
  const close = value.close?.trim() || '';
  if (open && close) return `${open}\u2013${close}`;
  return open || close || null;
}

/**
 * One-line opening-hours summary.
 *
 * `Daily HH:MM–HH:MM` only appears when all seven days are defined and share one
 * window — a station that only opens on weekdays is not "Daily". Otherwise each
 * open day is labelled and closed days are dropped. Unrecognised or absent hours
 * degrade to a placeholder rather than an empty string, so the picker row never
 * collapses to two words.
 */
export function stationOpeningHoursLabel(hours: StationOpeningHours | null | undefined): string {
  if (!hours || typeof hours !== 'object') return HOURS_UNKNOWN;
  const dayWindows = DAY_KEYS.map((key) => dayWindowLabel(hours[key]));
  if (dayWindows.every((window) => window !== null && window === dayWindows[0])) {
    return `Daily ${dayWindows[0]}`;
  }
  const labelled: string[] = [];
  DAY_KEYS.forEach((key, index) => {
    const window = dayWindows[index];
    if (window) labelled.push(`${DAY_LABELS[key]} ${window}`);
  });
  // Tolerate non-canonical day keys ("mon", "public_holidays") rather than dropping them.
  for (const key of Object.keys(hours)) {
    if ((DAY_KEYS as readonly string[]).includes(key)) continue;
    const window = dayWindowLabel(hours[key]);
    if (window) labelled.push(window);
  }
  return labelled.length ? labelled.join(' \u00b7 ') : HOURS_UNKNOWN;
}

interface ErrorPayload {
  message?: string;
  detail?: string;
  errors?: Record<string, unknown> | unknown[] | null;
}

function flattenErrors(errors: ErrorPayload['errors']): string[] {
  if (!errors) return [];
  if (Array.isArray(errors)) return errors.map((e) => String(e)).filter(Boolean);
  return Object.entries(errors).map(([key, value]) => `${key}: ${Array.isArray(value) ? value.join(' ') : String(value)}`);
}

/** Best-effort human message for a failed station/payment call. */
export function stationsErrorMessage(error: unknown, fallback = 'Something went wrong.'): string {
  const err = error as AxiosError<ErrorPayload> | undefined;
  const payload = err?.response?.data;
  return [payload?.message, payload?.detail, flattenErrors(payload?.errors).join(' ')]
    .filter(Boolean)
    .join(' \u2014 ') || fallback;
}

/**
 * True when the endpoint itself is absent (not built yet / wrong route) rather
 * than merely failing. The checkout page uses this to fall back to a free-text
 * collection point instead of dead-ending the buyer on a 404.
 */
export function isStationsUnavailable(error: unknown): boolean {
  const status = (error as AxiosError | undefined)?.response?.status;
  return status === 404 || status === 405 || status === 501;
}

/** Drop empty params so the query string stays clean. */
function cleanParams(params?: StationListParams): Record<string, unknown> | undefined {
  if (!params) return undefined;
  const out = Object.entries(params).reduce<Record<string, unknown>>((acc, [k, v]) => {
    if (v === undefined || v === null || v === '') return acc;
    acc[k] = v;
    return acc;
  }, {});
  return Object.keys(out).length ? out : undefined;
}

/* ------------------------------------------------------------------ */
/* Ownership derivation                                                */
/* ------------------------------------------------------------------ */

const STATION_OWNER_ROLES = ['owner', 'co_owner'];

function matchesUser(value: string | null | undefined, identity: StationOwnerIdentity): boolean {
  if (!value) return false;
  if (identity.id && value === identity.id) return true;
  return Boolean(identity.username && value === identity.username);
}

/**
 * Does the signed-in user own (and so may edit) this station?
 *
 * The backend's write guard is "shop owner/manager or gym owner/co-owner", so
 * the same rule is mirrored here rather than probed per row. Each owner type is
 * checked against every signal the list response might carry, because the
 * serializer shape varies with what is related — a shop row may inline only
 * `owner`, a gym row only `owner_data`:
 *
 *  1. the owner reference's own `owner` / `owner_username` matches me;
 *  2. for gyms, `owner_data` contains me at `owner`/`co_owner` — a plain
 *     `member` or `moderator` entry is NOT ownership, so it is excluded;
 *  3. an explicitly denormalised `membership_role` at `owner`/`co_owner`.
 *
 * Unknown owner type → false. An identity with neither id nor username matches
 * nothing, so an unauthenticated render never claims a station as its own.
 */
export function isStationOwnedBy(station: PickupStation, identity: StationOwnerIdentity | null | undefined): boolean {
  if (!identity || (!identity.id && !identity.username)) return false;
  const type = station.owner_type;
  if (type !== 'shop' && type !== 'gym') return false;

  const ref = type === 'shop' ? station.shop : station.gym;
  if (!ref) return false;

  if (matchesUser(ref.owner, identity) || matchesUser(ref.owner_username, identity)) return true;

  if (type === 'gym' && Array.isArray(ref.owner_data)) {
    const leads = ref.owner_data.filter((o) => STATION_OWNER_ROLES.includes((o.role || '').toLowerCase()));
    if (leads.some((o) => matchesUser(o.user_id, identity) || matchesUser(o.username, identity))) return true;
  }

  // The caller is being described as the owner entity itself, with their role
  // denormalised onto the row. Only a leadership role qualifies — a `moderator`
  // or `member` membership_role is not station ownership.
  if (typeof ref.membership_role === 'string' && STATION_OWNER_ROLES.includes(ref.membership_role.toLowerCase())) {
    return matchesUser(ref.id, identity);
  }

  return false;
}

/** Keep only the stations the signed-in user owns. Order is preserved. */
export function deriveOwnedStations<T extends PickupStation>(stations: T[], identity: StationOwnerIdentity | null | undefined): T[] {
  if (!Array.isArray(stations)) return [];
  return stations.filter((s) => isStationOwnedBy(s, identity));
}

/**
 * A station's owner, as one human line. Falls back to the owner type alone when
 * the related row is not inlined, so the line is never blank.
 */
export function stationOwnerLabel(station: PickupStation): string {
  const ref = station.owner_type === 'gym' ? station.gym : station.shop;
  if (!ref) return station.owner_type ? `${station.owner_type} owned` : 'Unknown owner';
  return ref.name || ref.handle || `${station.owner_type} owned`;
}

export const stationsApi = {
  /**
   * Stations, nearest first when `lat`/`lng` are supplied. The response envelope
   * is returned with `data` re-sorted and normalised, so callers can index into
   * `data` without guarding against a paginated or null body.
   */
  list: (params?: StationListParams) =>
    apiClient
      .get<ApiResponse<PickupStation[]>>('/marketplace/stations/', { params: cleanParams(params) })
      .then((r) => ({ ...r.data, data: sortStationsByDistance(stationList<PickupStation>(r.data?.data)) })),

  get: (id: string) =>
    apiClient
      .get<ApiResponse<PickupStation>>(`/marketplace/stations/${id}/`)
      .then((r) => r.data),

  /** Starts provider confirmation for an order that is already created. */
  createPaymentIntent: (payload: CreatePaymentIntentPayload) =>
    apiClient
      .post<ApiResponse<PaymentIntent>>('/marketplace/orders/payment-intents/', {
        order_id: payload.order_id,
        method: payload.method,
        ...(payload.phone ? { phone: payload.phone } : {}),
      })
      .then((r) => r.data),

  /** Owner-only write. The backend rejects a non-owner shop/gym admin. */
  create: (data: StationWritePayload) =>
    apiClient.post<ApiResponse<PickupStation>>('/marketplace/stations/', data).then((r) => r.data),

  update: (id: string, data: Partial<StationWritePayload>) =>
    apiClient.patch<ApiResponse<PickupStation>>(`/marketplace/stations/${id}/`, data).then((r) => r.data),

  /** Apply to run a station. Reviewed by an admin; status comes back on submit. */
  apply: (data: Record<string, unknown>) =>
    apiClient.post<ApiResponse<StationApplication>>('/marketplace/station-applications/', data).then((r) => r.data),
};

export type StationsApi = typeof stationsApi;
