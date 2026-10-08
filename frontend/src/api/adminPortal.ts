import type { AxiosError } from 'axios';
import { apiClient } from './client';
import type { ApiResponse, Pagination } from '@/types';

/**
 * Typed client for the `/api/v1/portal/**` admin surface.
 *
 * Conventions mirror `api/admin.ts` and `api/moderation.ts`: the shared axios
 * instance, methods return the raw `{success,data,message,errors,pagination}`
 * envelope (unwrapped one level, not `data.data`), and every list endpoint
 * takes an optional filter object that is passed straight through as query
 * params.
 *
 * Every entity below is declared with optional members on purpose: this client
 * is coded against a contract that is landing in parallel, so a renamed or
 * missing field must degrade in the UI rather than crash it.
 */

export interface PortalPaginationParams {
  page?: number;
  page_size?: number;
  ordering?: string;
}

/* ------------------------------------------------------------------ */
/* Users                                                               */
/* ------------------------------------------------------------------ */

export interface PortalUser {
  id?: string;
  email?: string | null;
  email_verified?: boolean;
  phone?: string | null;
  username?: string | null;
  display_name?: string | null;
  avatar_url?: string | null;
  role?: string | null;
  is_staff?: boolean;
  is_superuser?: boolean;
  is_active?: boolean;
  is_suspended?: boolean;
  suspension_reason?: string | null;
  suspended_at?: string | null;
  suspended_by?: string | null;
  reinstated_at?: string | null;
  verification_status?: string | null;
  is_adult?: boolean;
  onboarding_completed?: boolean;
  has_search_profile?: boolean;
  post_count?: number;
  gym_count?: number;
  buddy_count?: number;
  date_joined?: string | null;
  last_login?: string | null;
  created_at?: string | null;
}

export interface PortalUserFilters extends PortalPaginationParams {
  q?: string;
  role?: string;
  is_active?: boolean;
  verification_status?: string;
  has_search_profile?: boolean;
}

export interface SuspendUserPayload {
  reason?: string;
  /** Optional admin note kept alongside the suspension. */
  note?: string;
}

export interface ReinstateUserPayload {
  reason?: string;
  note?: string;
}

/* ------------------------------------------------------------------ */
/* Shops & products                                                    */
/* ------------------------------------------------------------------ */

export interface PortalShop {
  id?: string;
  handle?: string;
  name?: string;
  description?: string | null;
  logo_url?: string | null;
  banner_url?: string | null;
  category?: string | null;
  verification_status?: string | null;
  is_active?: boolean;
  is_certified?: boolean;
  owner?: string | null;
  owner_display_name?: string | null;
  contact_email?: string | null;
  website_url?: string | null;
  product_count?: number;
  order_count?: number;
  total_revenue_usd?: number;
  created_at?: string | null;
}

export interface PortalProduct {
  id?: string;
  name?: string;
  brand?: string | null;
  description?: string | null;
  category?: string | null;
  image_url?: string | null;
  price_display?: string | null;
  price_usd?: number | null;
  verification_status?: string | null;
  is_active?: boolean;
  is_draft?: boolean;
  stock?: number | null;
  shop?: string | null;
  shop_handle?: string | null;
  shop_name?: string | null;
  created_at?: string | null;
}

export interface PortalProductFilters extends PortalPaginationParams {
  verification_status?: string;
  category?: string;
  is_active?: boolean;
  q?: string;
  shop?: string;
}

/* ------------------------------------------------------------------ */
/* Shop certifications                                                 */
/* ------------------------------------------------------------------ */

export type ShopCertificationStatus = 'pending' | 'submitted' | 'under_review' | 'approved' | 'rejected' | 'expired';

export interface PortalShopCertification {
  id?: string;
  shop?: string | null;
  shop_handle?: string | null;
  shop_name?: string | null;
  shop_logo_url?: string | null;
  status?: ShopCertificationStatus | string | null;
  document_url?: string | null;
  document_type?: string | null;
  notes?: string | null;
  rejection_reason?: string | null;
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  submitted_at?: string | null;
  expires_at?: string | null;
  created_at?: string | null;
}

export interface ReviewShopCertificationPayload {
  status: 'approved' | 'rejected';
  /** Required in practice for a rejection; always sent so the audit trail has context. */
  reason?: string;
}

/* ------------------------------------------------------------------ */
/* Orders                                                              */
/* ------------------------------------------------------------------ */

export interface PortalOrderItem {
  item_type?: string;
  title?: string;
  quantity?: number;
  price_artifacts?: Record<string, number>;
  paid_artifacts?: Record<string, number>;
  creator_name?: string | null;
}

export interface PortalOrder {
  id?: string;
  order_number?: string;
  status?: string;
  status_label?: string;
  fulfillment_type?: string | null;
  payment_status?: string | null;
  payment_method?: string | null;
  buyer?: string | null;
  buyer_display_name?: string | null;
  shop?: string | null;
  shop_name?: string | null;
  items_total_artifacts?: Record<string, number>;
  total_artifacts?: Record<string, number>;
  total_usd?: number | null;
  paid_at?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
  items?: PortalOrderItem[];
  status_history?: Array<{ status?: string; at?: string | null; note?: string }>;
}

export interface PortalOrderFilters extends PortalPaginationParams {
  status?: string;
  fulfillment_type?: string;
  payment_status?: string;
  payment_method?: string;
  q?: string;
}

export interface UpdateOrderStatusPayload {
  status: string;
  note?: string;
}

/* ------------------------------------------------------------------ */
/* Gyms                                                                */
/* ------------------------------------------------------------------ */

export interface PortalGym {
  id?: string;
  handle?: string;
  name?: string;
  description?: string | null;
  category?: string | null;
  access_type?: string | null;
  subscription_type?: string | null;
  is_active?: boolean;
  is_verified?: boolean;
  /** Count only — the portal deliberately never exposes a member roster. */
  member_count?: number;
  logo_url?: string | null;
  location_city?: string | null;
  location_country?: string | null;
  owner?: string | null;
  verification_status?: string | null;
  created_at?: string | null;
}

export interface PortalGymFilters extends PortalPaginationParams {
  access_type?: string;
  category?: string;
  is_verified?: boolean;
  q?: string;
}

/* ------------------------------------------------------------------ */
/* Communities (member_count only — never a member list)              */
/* ------------------------------------------------------------------ */

export interface PortalCommunity {
  id?: string;
  slug?: string;
  name?: string;
  description?: string | null;
  icon_url?: string | null;
  is_public?: boolean;
  member_count?: number;
  post_count?: number;
  created_by?: string | null;
  created_at?: string | null;
}

export interface PortalCommunityFilters extends PortalPaginationParams {
  is_public?: boolean;
  q?: string;
}

/* ------------------------------------------------------------------ */
/* Stations                                                            */
/* ------------------------------------------------------------------ */

export interface PortalStation {
  id?: string;
  name?: string;
  code?: string | null;
  description?: string | null;
  status?: string | null;
  is_active?: boolean;
  latitude?: number | null;
  longitude?: number | null;
  address?: string | null;
  city?: string | null;
  country?: string | null;
  community?: string | null;
  community_name?: string | null;
  rider_count?: number;
  created_at?: string | null;
}

export interface ReviewApplicationPayload {
  status: 'approved' | 'rejected';
  reason?: string;
  note?: string;
}

/* ------------------------------------------------------------------ */
/* Stations applications                                               */
/* ------------------------------------------------------------------ */

export interface PortalStationApplication {
  id?: string;
  station?: string | null;
  station_name?: string | null;
  applicant?: string | null;
  applicant_display_name?: string | null;
  status?: string | null;
  station_code?: string | null;
  notes?: string | null;
  rejection_reason?: string | null;
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  created_at?: string | null;
}

/* ------------------------------------------------------------------ */
/* Delivery personnel                                                  */
/* ------------------------------------------------------------------ */

export interface PortalDeliveryPersonnel {
  id?: string;
  user?: string | null;
  display_name?: string | null;
  phone?: string | null;
  station?: string | null;
  station_name?: string | null;
  is_active?: boolean;
  is_verified?: boolean;
  status?: string | null;
  vehicle_type?: string | null;
  vehicle_plate?: string | null;
  completed_deliveries?: number;
  rating?: number | null;
  created_at?: string | null;
}

export interface PortalDeliveryApplication {
  id?: string;
  applicant?: string | null;
  applicant_display_name?: string | null;
  applicant_email?: string | null;
  phone?: string | null;
  station?: string | null;
  station_name?: string | null;
  status?: string | null;
  vehicle_type?: string | null;
  vehicle_plate?: string | null;
  documents?: Array<{ id?: string; document_type?: string; file_url?: string; status?: string }>;
  notes?: string | null;
  rejection_reason?: string | null;
  reviewed_by?: string | null;
  reviewed_at?: string | null;
  created_at?: string | null;
}

/* ------------------------------------------------------------------ */
/* Wallet                                                              */
/* ------------------------------------------------------------------ */

export interface PortalTransaction {
  id?: string;
  reference_id?: string | null;
  transaction_type?: string | null;
  artifact_type?: string | null;
  quantity?: number;
  direction?: string | null;
  status?: string | null;
  counterparty_name?: string | null;
  fiat_amount?: string | number | null;
  fiat_currency?: string | null;
  description?: string | null;
  created_at?: string | null;
}

export interface PortalReconciliationBucket {
  label?: string;
  status?: string | null;
  count?: number;
  quantity?: number;
  amount?: string | number | null;
}

export interface PortalReconciliationReport {
  generated_at?: string | null;
  period_start?: string | null;
  period_end?: string | null;
  currency?: string | null;
  totals?: Record<string, string | number | null>;
  /** Named buckets vary by deployment — read defensively, never by index. */
  buckets?: PortalReconciliationBucket[];
  discrepancies?: Array<{
    reference_id?: string;
    reason?: string;
    expected?: string | number | null;
    actual?: string | number | null;
    created_at?: string | null;
  }>;
  total_count?: number;
}

/* ------------------------------------------------------------------ */
/* Error handling                                                      */
/* ------------------------------------------------------------------ */

interface ErrorPayload {
  success?: boolean;
  message?: string;
  detail?: string;
  errors?: Record<string, unknown> | unknown[] | null;
}

function flattenErrors(errors: ErrorPayload['errors']): string[] {
  if (!errors) return [];
  if (Array.isArray(errors)) return errors.map((e) => String(e)).filter(Boolean);
  return Object.entries(errors).map(([key, value]) => `${key}: ${Array.isArray(value) ? value.join(' ') : String(value)}`);
}

/**
 * Best-effort human message for a failed portal call.
 *
 * A failed call returns `{success:false,message:'...'}` (HTTP 4xx), so the body
 * is the source of truth. A 403 from `IsAdminUser` means the signed-in user is
 * not staff — the router guard normally prevents ever reaching it, but the
 * message is explicit about that so the console never looks like it is acting
 * with the wrong privileges.
 */
export function adminPortalErrorMessage(error: unknown, fallback = 'Something went wrong.'): string {
  const err = error as AxiosError<ErrorPayload> | undefined;
  const payload = err?.response?.data;
  const detail = flattenErrors(payload?.errors);
  const base = [payload?.message, payload?.detail, detail.join(' ')].filter(Boolean).join(' — ') || fallback;
  if (err?.response?.status === 403) {
    return `${base} Staff access is required for the admin console — if you are staff, sign in again.`;
  }
  if (err?.response?.status === 401) {
    return `${base} Your session expired — sign in again to continue.`;
  }
  return base;
}

/** True when the failure is the admin guard rejecting a non-staff session. */
export function isAdminPrivilegeError(error: unknown): boolean {
  return (error as AxiosError | undefined)?.response?.status === 403;
}

/**
 * Normalise a list payload. The contract says every list is a bare array, but
 * a paginated shape (`{results: [...]}`) or a null body must not crash a table.
 */
export function portalListItems<T>(data: unknown): T[] {
  if (Array.isArray(data)) return data as T[];
  if (data && typeof data === 'object') {
    const results = (data as { results?: unknown }).results;
    if (Array.isArray(results)) return results as T[];
    const items = (data as { items?: unknown }).items;
    if (Array.isArray(items)) return items as T[];
  }
  return [];
}

/** Normalise the pagination block, defaulting every member defensively. */
export function portalPagination(pagination: Pagination | null | undefined, fallbackCount = 0): Pagination & { page: number; num_pages: number } {
  const count = typeof pagination?.count === 'number' ? pagination.count : fallbackCount;
  const numPages = Math.max(1, Math.ceil(count / 25));
  return {
    count,
    next: pagination?.next ?? null,
    previous: pagination?.previous ?? null,
    page: 1,
    num_pages: numPages,
  };
}

/** Drop empty filter values so the query string stays clean. */
function clean(params?: Record<string, unknown>): Record<string, unknown> | undefined {
  if (!params) return undefined;
  const out = Object.entries(params).reduce<Record<string, unknown>>((acc, [k, v]) => {
    if (v === undefined || v === null || v === '' || v === 'all') return acc;
    acc[k] = v;
    return acc;
  }, {});
  return Object.keys(out).length ? out : undefined;
}

/* ------------------------------------------------------------------ */
/* Client                                                              */
/* ------------------------------------------------------------------ */

export const adminPortalApi = {
  /* Users ---------------------------------------------------------- */
  getUsers: (params?: PortalUserFilters) =>
    apiClient.get<ApiResponse<PortalUser[]>>('/portal/users/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateUser: (id: string, payload: Partial<PortalUser>) =>
    apiClient.patch<ApiResponse<PortalUser>>(`/portal/users/${id}/`, payload).then((r) => r.data),

  suspendUser: (id: string, payload: SuspendUserPayload = {}) =>
    apiClient.post<ApiResponse<PortalUser>>(`/portal/users/${id}/suspend/`, payload).then((r) => r.data),

  reinstateUser: (id: string, payload: ReinstateUserPayload = {}) =>
    apiClient.post<ApiResponse<PortalUser>>(`/portal/users/${id}/reinstate/`, payload).then((r) => r.data),

  /* Shops & products ---------------------------------------------- */
  getShops: (params?: PortalPaginationParams & { q?: string; verification_status?: string; is_active?: boolean }) =>
    apiClient.get<ApiResponse<PortalShop[]>>('/portal/shops/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getShop: (handle: string) =>
    apiClient.get<ApiResponse<PortalShop>>(`/portal/shops/${encodeURIComponent(handle)}/`).then((r) => r.data),

  updateShop: (handle: string, payload: Partial<PortalShop>) =>
    apiClient.patch<ApiResponse<PortalShop>>(`/portal/shops/${encodeURIComponent(handle)}/`, payload).then((r) => r.data),

  getProducts: (params?: PortalProductFilters) =>
    apiClient.get<ApiResponse<PortalProduct[]>>('/portal/products/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  /* Shop certifications -------------------------------------------- */
  getShopCertifications: (params?: PortalPaginationParams & { status?: string; q?: string }) =>
    apiClient.get<ApiResponse<PortalShopCertification[]>>('/portal/shop-certifications/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  reviewShopCertification: (id: string, payload: ReviewShopCertificationPayload) =>
    apiClient.patch<ApiResponse<PortalShopCertification>>(`/portal/shop-certifications/${id}/`, payload).then((r) => r.data),

  /* Orders --------------------------------------------------------- */
  getOrders: (params?: PortalOrderFilters) =>
    apiClient.get<ApiResponse<PortalOrder[]>>('/portal/orders/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateOrderStatus: (id: string, payload: UpdateOrderStatusPayload) =>
    apiClient.patch<ApiResponse<PortalOrder>>(`/portal/orders/${id}/status/`, payload).then((r) => r.data),

  /* Gyms ----------------------------------------------------------- */
  getGyms: (params?: PortalGymFilters) =>
    apiClient.get<ApiResponse<PortalGym[]>>('/portal/gyms/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateGym: (id: string, payload: Partial<PortalGym>) =>
    apiClient.patch<ApiResponse<PortalGym>>(`/portal/gyms/${id}/`, payload).then((r) => r.data),

  /* Communities ---------------------------------------------------- */
  getCommunities: (params?: PortalCommunityFilters) =>
    apiClient.get<ApiResponse<PortalCommunity[]>>('/portal/communities/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  /* Stations ------------------------------------------------------- */
  getStations: (params?: PortalPaginationParams & { q?: string; status?: string; is_active?: boolean }) =>
    apiClient.get<ApiResponse<PortalStation[]>>('/portal/stations/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateStation: (id: string, payload: Partial<PortalStation>) =>
    apiClient.patch<ApiResponse<PortalStation>>(`/portal/stations/${id}/`, payload).then((r) => r.data),

  /* Station applications ------------------------------------------- */
  getStationApplications: (params?: PortalPaginationParams & { status?: string; q?: string }) =>
    apiClient.get<ApiResponse<PortalStationApplication[]>>('/portal/station-applications/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateStationApplication: (id: string, payload: ReviewApplicationPayload) =>
    apiClient.patch<ApiResponse<PortalStationApplication>>(`/portal/station-applications/${id}/`, payload).then((r) => r.data),

  /* Delivery personnel --------------------------------------------- */
  getDeliveryPersonnel: (params?: PortalPaginationParams & { status?: string; is_active?: boolean; station?: string; q?: string }) =>
    apiClient.get<ApiResponse<PortalDeliveryPersonnel[]>>('/portal/delivery-personnel/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getDeliveryApplications: (params?: PortalPaginationParams & { status?: string; q?: string }) =>
    apiClient.get<ApiResponse<PortalDeliveryApplication[]>>('/portal/delivery-personnel-applications/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  updateDeliveryApplication: (id: string, payload: ReviewApplicationPayload) =>
    apiClient.patch<ApiResponse<PortalDeliveryApplication>>(`/portal/delivery-personnel-applications/${id}/`, payload).then((r) => r.data),

  /* Wallet --------------------------------------------------------- */
  getTransactions: (params?: PortalPaginationParams & { status?: string; transaction_type?: string; direction?: string; q?: string }) =>
    apiClient.get<ApiResponse<PortalTransaction[]>>('/portal/transactions/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getReconciliation: (params?: { date_from?: string; date_to?: string }) =>
    apiClient.get<ApiResponse<PortalReconciliationReport>>('/portal/wallet/reconciliation/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),
};

export type AdminPortalApi = typeof adminPortalApi;