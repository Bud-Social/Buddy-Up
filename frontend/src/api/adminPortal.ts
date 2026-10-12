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
  /** Legal next states, computed server-side from the order's fulfilment type. */
  allowed_next_statuses?: string[];
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
/* Governance — staff roles, approvals, audit, assistance email        */
/* ------------------------------------------------------------------ */

/**
 * Identity shape shared by every governance serializer.
 *
 * The read side returns `{id, email, display_name}` rather than a whole user
 * row on purpose: staff need to know *who* a row concerns after the account is
 * gone, which is why `display_name` is a snapshot string rather than a lookup.
 * Every member is optional so a caller can render `—` instead of crashing.
 */
export interface GovernanceUserRef {
  id?: string | null;
  email?: string | null;
  display_name?: string | null;
}

export interface StaffRoleAssignment {
  id?: string;
  user?: GovernanceUserRef | null;
  role?: string | null;
  role_display?: string | null;
  /** Stored extras, added on top of the role's defaults. */
  scopes?: string[] | null;
  /** The floor the role itself grants. */
  default_scopes?: string[] | null;
  effective_scopes?: string[] | null;
  granted_by?: GovernanceUserRef | null;
  granted_at?: string | null;
  notes?: string | null;
  revoked_at?: string | null;
  is_active?: boolean;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface StaffRoleFilters extends PortalPaginationParams {
  role?: string;
  /** `'true'` lists revoked rows too; `'false'` lists only live ones. */
  revoked?: boolean | string;
}

export interface StaffRoleGrantPayload {
  user: string;
  role: string;
  scopes?: string[];
  notes?: string;
  /** Defaults to true server-side. False applies the grant inline. */
  requires_second?: boolean;
}

export interface StaffRoleUpdatePayload {
  role?: string;
  scopes?: string[];
  notes?: string;
}

export type ApprovalStatus = 'pending' | 'approved' | 'rejected' | 'cancelled';

export type ApprovalAction =
  | 'ban'
  | 'suspension'
  | 'verification_decision'
  | 'payout'
  | 'staff_role_grant';

export interface GovernanceApproval {
  id?: string;
  action?: string | null;
  action_display?: string | null;
  /** The scope the *approver* must hold — checked at approve time, not raise time. */
  required_scope?: string | null;
  target_user?: GovernanceUserRef | null;
  payload?: Record<string, unknown> | null;
  status?: string | null;
  is_open?: boolean;
  requested_by?: GovernanceUserRef | null;
  requested_by_profile?: string | null;
  decided_by?: GovernanceUserRef | null;
  decided_at?: string | null;
  decision_note?: string | null;
  requires_second?: boolean;
  applied_at?: string | null;
  /** Approve response only: what the server actually did. */
  effect?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface ApprovalFilters extends PortalPaginationParams {
  status?: string;
  action?: string;
  target_user?: string;
  /** `'true'` narrows to requests this operator raised. */
  mine?: boolean | string;
}

export interface ApprovalRequestPayload {
  action: string;
  target_user: string;
  payload?: Record<string, unknown>;
  notes?: string;
  requires_second?: boolean;
}

export interface DecisionPayload {
  /** Required by the server for reject and cancel; optional for approve. */
  note?: string;
}

export interface AuditLogEntry {
  id?: string;
  actor?: string | null;
  /** Snapshot of the actor's address at write time; survives account deletion. */
  actor_email?: string | null;
  action?: string | null;
  target_type?: string | null;
  target_id?: string | null;
  summary?: string | null;
  before?: Record<string, unknown> | null;
  after?: Record<string, unknown> | null;
  request_id?: string | null;
  ip_address?: string | null;
  user_agent?: string | null;
  created_at?: string | null;
}

export interface AuditFilters extends PortalPaginationParams {
  action?: string;
  target_type?: string;
  target_id?: string;
  actor?: string;
  date_from?: string;
  date_to?: string;
}

export type StaffEmailStatus = 'queued' | 'sent' | 'failed' | 'skipped';

export interface StaffEmailLog {
  id?: string;
  recipient_user?: string | null;
  recipient?: GovernanceUserRef | null;
  recipient_email?: string | null;
  subject?: string | null;
  body_preview?: string | null;
  template_key?: string | null;
  sent_by?: string | null;
  sender?: GovernanceUserRef | null;
  sent_by_email?: string | null;
  status?: string | null;
  error?: string | null;
  dedupe_key?: string | null;
  related_object_type?: string | null;
  related_object_id?: string | null;
  created_at?: string | null;
}

export interface EmailLogFilters extends PortalPaginationParams {
  status?: string;
  recipient_email?: string;
  sent_by?: string;
}

export interface SendStaffEmailPayload {
  /** Exactly one of `user_id` / `email`. The schema has no list field at all. */
  user_id?: string;
  email?: string;
  subject: string;
  body: string;
  related_object_type?: string;
  related_object_id?: string;
}

/* ------------------------------------------------------------------ */
/* Moderation operations (staff side)                                  */
/* ------------------------------------------------------------------ */

export type ContentFlagReason =
  | 'nsfw' | 'toxic' | 'spam' | 'misinfo' | 'custom'
  | 'medical_claim' | 'undisclosed_sponsor' | 'adult_ungated';

export interface ContentFlagRow {
  id?: string;
  flag_reason?: string | null;
  severity?: string | null;
  confidence?: number | null;
  source?: string | null;
  content_type?: string | null;
  content_id?: string | null;
  content_preview?: string | null;
  is_actioned?: boolean;
  action_taken?: string | null;
  created_at?: string | null;
}

export interface ModerationStatsRow {
  total?: number;
  unactioned?: number;
  actioned?: number;
  by_severity?: Record<string, number>;
  by_reason?: Record<string, number>;
}

export interface ModerationReportRow {
  id?: string;
  reporter?: string | null;
  target_user?: string | null;
  reason?: string | null;
  description?: string | null;
  content_url?: string | null;
  status?: string | null;
  assigned_to?: string | null;
  resolved_at?: string | null;
  resolution_note?: string | null;
  /** Computed server-side from `created_at` + reason (4h urgent, 24h standard). */
  sla_due_at?: string | null;
  sla_breached?: boolean | null;
  created_at?: string | null;
}

export interface ModerationReportFilters extends PortalPaginationParams {
  status?: string;
  reason?: string;
  /** `'me'` or a user id. `'unassigned'` is *not* a value — use `unassigned`. */
  assigned_to?: string;
  unassigned?: boolean | string;
}

export interface AssignReportPayload {
  /** A staff user id, or `null` to unassign. Omitting it entirely is a 400. */
  assigned_to: string | null;
  note?: string;
}

export interface ModerationActionRow {
  id?: string;
  action?: string | null;
  moderator?: string | null;
  report?: string | null;
  target_user?: string | null;
  reason?: string | null;
  duration_days?: number | null;
  content_type?: string | null;
  content_type_display?: string | null;
  content_id?: string | null;
  is_reversed?: boolean;
  reversed_by?: string | null;
  reversed_at?: string | null;
  reversal_reason?: string | null;
  reversed_by_moderator?: GovernanceUserRef | null;
  created_at?: string | null;
}

export interface ModerationActionFilters extends PortalPaginationParams {
  action?: string;
}

export interface CreateModerationActionPayload {
  action: string;
  target_user: string;
  reason: string;
  /** Required for `user_suspended`, refused for `user_banned`. */
  duration_days?: number | null;
  report?: string | null;
}

/**
 * The create endpoint answers in two different shapes:
 *
 * - `warning` → **201**, `data` is the `ModerationAction` row itself.
 * - `user_suspended` / `user_banned` → **202**, `data` is
 *   `{moderation_action, approval, applied: false}` — the action is *raised*,
 *   not applied, and nothing has happened to the account yet.
 *
 * Both are declared as one all-optional type so a page can discriminate on
 * `applied` without a cast that could be wrong. Read the outcome through
 * {@link moderationActionApplied} rather than branching on the HTTP status,
 * which axios discards on success.
 */
export interface ModerationActionSubmission {
  /* The 201 warning shape. */
  id?: string;
  action?: string | null;
  reason?: string | null;
  target_user?: string | null;
  created_at?: string | null;
  /* The 202 pending shape. */
  moderation_action?: ModerationActionRow | null;
  approval?: {
    id?: string;
    action?: string | null;
    status?: string | null;
    requires_second?: boolean;
  } | null;
  applied?: boolean;
}

export interface ReverseModerationActionPayload {
  reason: string;
}

export interface PendingApprovalRow {
  id?: string;
  /** The governance action word: `ban` or `suspension`. */
  governance_action?: string | null;
  target_user?: string | null;
  requested_by?: string | null;
  requested_by_profile?: string | null;
  reason?: string | null;
  duration_days?: number | null;
  requires_second?: boolean;
  waiting_seconds?: number | null;
  created_at?: string | null;
  moderation_action_id?: string | null;
}

export interface Commendation {
  id?: string;
  recipient?: GovernanceUserRef | null;
  issued_by?: GovernanceUserRef | null;
  category?: string | null;
  category_display?: string | null;
  message?: string | null;
  visible_to_recipient?: boolean;
  created_at?: string | null;
}

export interface CommendationFilters extends PortalPaginationParams {
  category?: string;
}

export interface CreateCommendationPayload {
  /** A **Profile** id, not a user id — the API says so in its 400. */
  recipient: string;
  category: string;
  message: string;
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

/**
 * Whether a disciplinary action actually landed on the account.
 *
 * The discriminator is `applied`, not the HTTP status: axios resolves 2xx, so a
 * **202** and a **201** are indistinguishable to a caller that only checks for
 * a rejection. `applied === false` is the server saying, in as many words,
 * "this is queued for a second approver and nothing has been done to this
 * user". Treating that as success is the single worst thing this console could
 * get wrong — a moderator would tell a user they had been banned when they had
 * not.
 *
 * `applied === undefined` means the 201 warning shape (a warning applies
 * immediately), so it counts as applied.
 */
export function moderationActionApplied(data: ModerationActionSubmission | null | undefined): boolean {
  return data?.applied !== false;
}

/**
 * Absolute URL for the audit CSV export, carrying the current filters.
 *
 * Returns a plain URL rather than an apiClient call because the endpoint sets
 * `Content-Disposition: attachment` and is meant to be followed by the browser:
 * streaming a 50k-row file through a JS buffer to re-create the same file
 * client-side would be strictly worse. Note the access token travels in the
 * `Authorization` header this client adds, so a signed-in staff member is
 * authenticated; an export opened in a fresh tab without a session is refused
 * by the API rather than silently exported.
 */
export function auditExportUrl(params?: AuditFilters): string {
  const base = String(apiClient.defaults?.baseURL || '/api/v1').replace(/\/+$/, '');
  const query = clean(params as Record<string, unknown>);
  const qs = query
    ? `?${new URLSearchParams(Object.entries(query).map(([k, v]) => [k, String(v)])).toString()}`
    : '';
  return `${base}/governance/audit/export/${qs}`;
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

  /* Governance — staff roles --------------------------------------- */
  getStaffRoles: (params?: StaffRoleFilters) =>
    apiClient.get<ApiResponse<StaffRoleAssignment[]>>('/governance/staff-roles/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getStaffRole: (id: string) =>
    apiClient.get<ApiResponse<StaffRoleAssignment>>(`/governance/staff-roles/${id}/`).then((r) => r.data),

  /**
   * Grant or replace a role.
   *
   * Returns **202** with an `AccountActionRequest` when `requires_second` is
   * left at its default: nothing has been applied. Read `data.status` /
   * `data.requires_second` rather than treating a resolution as a grant.
   */
  createStaffRole: (payload: StaffRoleGrantPayload) =>
    apiClient.post<ApiResponse<StaffRoleAssignment | GovernanceApproval>>('/governance/staff-roles/', payload).then((r) => r.data),

  updateStaffRole: (id: string, payload: StaffRoleUpdatePayload) =>
    apiClient.patch<ApiResponse<StaffRoleAssignment>>(`/governance/staff-roles/${id}/`, payload).then((r) => r.data),

  /** Revokes rather than deletes — the row is the audit trail. */
  revokeStaffRole: (id: string, notes?: string) =>
    apiClient
      .delete<ApiResponse<StaffRoleAssignment>>(`/governance/staff-roles/${id}/`, {
        data: notes ? { notes } : undefined,
      })
      .then((r) => r.data),

  /* Governance — two-person approvals ------------------------------- */
  getApprovals: (params?: ApprovalFilters) =>
    apiClient.get<ApiResponse<GovernanceApproval[]>>('/governance/approvals/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getApproval: (id: string) =>
    apiClient.get<ApiResponse<GovernanceApproval>>(`/governance/approvals/${id}/`).then((r) => r.data),

  approveApproval: (id: string, payload: DecisionPayload = {}) =>
    apiClient.post<ApiResponse<GovernanceApproval>>(`/governance/approvals/${id}/approve/`, payload).then((r) => r.data),

  rejectApproval: (id: string, payload: DecisionPayload = {}) =>
    apiClient.post<ApiResponse<GovernanceApproval>>(`/governance/approvals/${id}/reject/`, payload).then((r) => r.data),

  cancelApproval: (id: string, payload: DecisionPayload = {}) =>
    apiClient.post<ApiResponse<GovernanceApproval>>(`/governance/approvals/${id}/cancel/`, payload).then((r) => r.data),

  /** Raises a request. Nothing is applied until a different operator approves. */
  requestApproval: (payload: ApprovalRequestPayload) =>
    apiClient.post<ApiResponse<GovernanceApproval>>('/governance/approvals/request/', payload).then((r) => r.data),

  /* Governance — audit trail ---------------------------------------- */
  getAuditLog: (params?: AuditFilters) =>
    apiClient.get<ApiResponse<AuditLogEntry[]>>('/governance/audit/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  getAuditEntry: (id: string) =>
    apiClient.get<ApiResponse<AuditLogEntry>>(`/governance/audit/${id}/`).then((r) => r.data),

  /** Chronological history of one object. `target_type` is mandatory server-side. */
  getAuditTimeline: (params: AuditFilters & { target_type: string }) =>
    apiClient
      .get<ApiResponse<AuditLogEntry[]>>('/governance/audit/timeline/', {
        params: clean(params as unknown as Record<string, unknown>),
      })
      .then((r) => r.data),

  /* Governance — assistance email ----------------------------------- */
  getEmailLog: (params?: EmailLogFilters) =>
    apiClient.get<ApiResponse<StaffEmailLog[]>>('/governance/emails/log/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  /** Answers **202**: queued for delivery, not delivered. 429s at 20/hour/staff. */
  sendStaffEmail: (payload: SendStaffEmailPayload) =>
    apiClient.post<ApiResponse<StaffEmailLog>>('/governance/emails/send/', payload).then((r) => r.data),

  /** Failed messages only — the server refuses a `sent` or `queued` one with 409. */
  resendStaffEmail: (id: string) =>
    apiClient.post<ApiResponse<StaffEmailLog>>(`/governance/emails/${id}/resend/`, {}).then((r) => r.data),

  /* Moderation — reports -------------------------------------------- */
  getModerationReports: (params?: ModerationReportFilters) =>
    apiClient.get<ApiResponse<ModerationReportRow[]>>('/moderation/reports/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  assignModerationReport: (id: string, payload: AssignReportPayload) =>
    apiClient.post<ApiResponse<ModerationReportRow>>(`/moderation/reports/${id}/assign/`, payload).then((r) => r.data),

  handleModerationReport: (id: string, action: 'investigate' | 'resolve' | 'dismiss', resolution_note = '') =>
    apiClient.post<ApiResponse<ModerationReportRow>>(`/moderation/reports/${id}/handle/`, { action, resolution_note }).then((r) => r.data),

  /* Moderation — flags ---------------------------------------------- */
  getContentFlags: (params?: { flag_reason?: string; severity?: string; is_actioned?: boolean }) =>
    apiClient.get<ApiResponse<ContentFlagRow[]>>('/moderation/content-flags/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  actOnContentFlag: (id: string, action: 'approve' | 'remove' | 'escalate', note = '') =>
    apiClient.post<ApiResponse<{ flag?: ContentFlagRow; effect?: string }>>(`/moderation/content-flags/${id}/act/`, { action, note }).then((r) => r.data),

  getContentFlagStats: () =>
    apiClient.get<ApiResponse<ModerationStatsRow>>('/moderation/content-flags/stats/').then((r) => r.data),

  /** Ban/suspension requests raised from moderation, awaiting a second approver. */
  getPendingApprovals: () =>
    apiClient.get<ApiResponse<PendingApprovalRow[]>>('/moderation/content-flags/pending-approvals/').then((r) => r.data),

  /* Moderation — disciplinary actions -------------------------------- */
  getModerationActions: (params?: ModerationActionFilters) =>
    apiClient.get<ApiResponse<ModerationActionRow[]>>('/moderation/actions/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  /**
   * `warning` applies at once (**201**). `user_suspended` / `user_banned` are
   * raised for approval and return **202** with `applied: false` — use
   * {@link moderationActionApplied} before telling anyone anything happened.
   */
  createModerationAction: (payload: CreateModerationActionPayload) =>
    apiClient.post<ApiResponse<ModerationActionSubmission>>('/moderation/actions/', payload).then((r) => r.data),

  reverseModerationAction: (id: string, payload: ReverseModerationActionPayload) =>
    apiClient.post<ApiResponse<{ reversed_action?: ModerationActionRow; reversal?: ModerationActionRow; effect?: string }>>(`/moderation/actions/${id}/reverse/`, payload).then((r) => r.data),

  /* Moderation — commendations --------------------------------------- */
  getCommendations: (params?: CommendationFilters) =>
    apiClient.get<ApiResponse<Commendation[]>>('/moderation/commendations/', { params: clean(params as Record<string, unknown>) }).then((r) => r.data),

  createCommendation: (payload: CreateCommendationPayload) =>
    apiClient.post<ApiResponse<Commendation>>('/moderation/commendations/', payload).then((r) => r.data),

  /** Hard delete. The recipient may remove their own; staff may remove any. */
  deleteCommendation: (id: string) =>
    apiClient.delete<ApiResponse<null>>(`/moderation/commendations/${id}/`).then((r) => r.data),

  /** Withdraws from the recipient's view but keeps the row. Failed ones 409. */
  revokeCommendation: (id: string, payload: { reason?: string } = {}) =>
    apiClient.post<ApiResponse<Commendation>>(`/moderation/commendations/${id}/revoke/`, payload).then((r) => r.data),
};

export type AdminPortalApi = typeof adminPortalApi;