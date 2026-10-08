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
  /** Present only when the list was called with both `lat` and `lng`. */
  distance_km?: number | null;
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
};

export type StationsApi = typeof stationsApi;
