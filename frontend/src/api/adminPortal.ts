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

/**
 * An outstanding offer of staff access.
 *
 * `status` is the thing to render, not `is_active`: a revoked invitation is
 * still a row, and a list that filtered on the boolean would quietly drop the
 * evidence that access was offered and then withdrawn.
 */
export interface StaffInvitation {
  id: string;
  email: string;
  role: string;
  role_display?: string | null;
  scopes?: string[] | null;
  notes?: string | null;
  status: 'pending' | 'accepted' | 'revoked' | 'expired';
  status_display?: string | null;
  is_live: boolean;
  /** Whether the address already registered — decides "sign in" vs "register". */
  has_account: boolean;
  invited_by?: GovernanceUserRef | null;
  invited_by_email?: string | null;
  expires_at?: string | null;
  accepted_at?: string | null;
  accepted_by?: GovernanceUserRef | null;
  accepted_user_email?: string | null;
  requires_second: boolean;
  created_at?: string | null;
}

/** What the public accept screen needs, before anybody is signed in. */
export interface StaffInvitationPreview {
  email: string;
  role: string;
  role_display?: string | null;
  scopes?: string[];
  status: StaffInvitation['status'];
  is_live: boolean;
  expires_at?: string | null;
  invited_by?: string | null;
}

export interface StaffInvitationCreatePayload {
  email: string;
  role: string;
  scopes?: string[];
  notes?: string;
  /** Defaults to true. False emails the link immediately. */
  requires_second?: boolean;
  expires_in_days?: number;
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

/** What the resolve endpoint hands back for one flagged object. */
export interface ResolvedContent {
  label?: string;
  title?: string;
  body?: string;
  route?: string;
  created_at?: string | null;
  author?: { username?: string; display_name?: string; avatar_url?: string } | null;
  fields?: Record<string, unknown> | null;
  context?: { post_id?: string; post_body?: string } | null;
  stats?: Record<string, number> | null;
  media_urls?: string[];
  /** Present only while a takedown is standing. Carries no content. */
  takedown?: {
    taken_down?: boolean;
    reason?: string;
    note?: string;
    taken_down_at?: string | null;
    purge_after?: string | null;
    appeal_window_days?: number | null;
  } | null;
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
  /** Structured pointer to the reported object. Replaces content_url as the
      only way to know *what* was reported. */
  content_type?: string | null;
  content_id?: string | null;
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
/* Platform analytics — /api/v1/portal/analytics/                      */
/* ------------------------------------------------------------------ */

/**
 * Every figure on this surface declares its own window.
 *
 * This is the single most important thing to get right when rendering these
 * reports, so the type models it explicitly rather than letting a page read the
 * page-level `window` and apply it to everything:
 *
 * - `kind: 'gauge'` (`label: 'All time'`) is cumulative — "how many exist up to
 *   the end of the window".
 * - `kind: 'flow'` (`label: 'Window'`) is a delta over the window — "how many
 *   happened inside it".
 *
 * Rendering a gauge as a period figure, or a flow as a stock level, is the
 * failure mode these windows exist to prevent.
 */
export interface AnalyticsWindow {
  from?: string | null;
  to?: string | null;
  days?: number | null;
  basis?: string | null;
  timezone?: string | null;
  /** `'All time'` for a gauge, `'Window'` for a flow, or the explicit range. */
  label?: string | null;
}

export interface AnalyticsWindowParams {
  /** `YYYY-MM-DD`, UTC calendar days. Omit to let the server pick 30 days. */
  from?: string;
  to?: string;
}

export type AnalyticsKpiKind = 'gauge' | 'flow';

export interface AnalyticsKpi {
  key?: string;
  label?: string;
  group?: string;
  /** `count` or `usd`. */
  unit?: string;
  value?: number | null;
  kind?: AnalyticsKpiKind;
  /** This KPI's own window — never the page-level one. */
  window?: AnalyticsWindow;
  /** The model column the figure reads, e.g. `accounts.User.created_at`. */
  source?: string | null;
  /** False when the read costs a sequential scan (see `performance_notes`). */
  indexed?: boolean;
  note?: string;
  source_count?: number | null;
}

export interface AnalyticsPerformanceNote {
  source?: string;
  issue?: string;
  suggested_migration?: string;
  owner?: string;
}

export interface AnalyticsBreakdown {
  title?: string;
  window?: AnalyticsWindow;
  basis?: string;
  note?: string;
  rows?: Array<Record<string, unknown>>;
}

/** The exportable/tabular twin every report carries. */
export interface AnalyticsReportTable {
  columns?: string[];
  rows?: unknown[][];
}

export interface AnalyticsOverview {
  window?: AnalyticsWindow;
  generated_at?: string | null;
  kpis?: AnalyticsKpi[];
  breakdowns?: AnalyticsBreakdown[];
  groups?: string[];
  /** Discloses that several tables have no `created_at` index. */
  performance_notes?: AnalyticsPerformanceNote[];
  table?: AnalyticsReportTable;
}

export interface AnalyticsMetricMeta {
  key?: string;
  label?: string;
  group?: string;
  unit?: string;
  source?: string | null;
  description?: string;
}

/** One row of `metric_catalogue`, the server's own allow-list for a picker. */
export interface AnalyticsMetricCatalogueEntry extends AnalyticsMetricMeta {
  additive?: boolean;
  /** False for a gauge, which has no meaningful series. */
  windowed?: boolean;
}

/**
 * `rollup` = read from `analytics_daily_platform_metric`; `live` = the rollup
 * had gaps so the source table was aggregated instead.
 *
 * A `live` chart is correct but slow. The UI must say so rather than let an
 * operator assume every chart is the cheap pre-computed one.
 */
export interface AnalyticsDataSource {
  path?: 'rollup' | 'live' | string;
  rollup_complete?: boolean;
  /** Days the rollup is missing inside this window; non-empty implies live. */
  missing_days?: string[];
  note?: string;
}

export interface AnalyticsTimeseriesBucket {
  bucket?: string;
  value?: number | null;
}

export interface AnalyticsTimeseries {
  window?: AnalyticsWindow;
  metric?: AnalyticsMetricMeta;
  granularity?: 'day' | 'week' | string;
  /** Zero-filled by the server: a gap means zero, not "no data". */
  series?: AnalyticsTimeseriesBucket[];
  totals?: { sum?: number | null; non_zero_buckets?: number | null };
  data_source?: AnalyticsDataSource;
  /** Flat key list the endpoint accepts — additive, windowed metrics only. */
  available_metrics?: string[];
  metric_catalogue?: AnalyticsMetricCatalogueEntry[];
  table?: AnalyticsReportTable;
}

export type AnalyticsTrendingKind = 'posts' | 'services' | 'events' | 'hashtags' | 'pages';

export type AnalyticsTrendingParams = AnalyticsWindowParams & {
  kind?: AnalyticsTrendingKind;
  limit?: number;
};

/** Item fields differ per kind — read these off `kind`, not off the list. */
export interface AnalyticsTrendingItem {
  rank?: number;

  /* posts */
  post_id?: string;
  author_username?: string | null;
  post_type?: string | null;
  body_excerpt?: string;
  created_at?: string | null;
  reactions?: number | null;
  comments?: number | null;
  view_count?: number | null;
  share_count?: number | null;
  engagement?: number | null;

  /* services */
  kind?: string;
  id?: string;
  title?: string | null;
  creator?: string | null;
  purchases_in_window?: number | null;
  purchase_count_total?: number | null;
  average_rating?: number | null;
  review_count?: number | null;
  is_published?: boolean | null;

  /* events */
  category?: string | null;
  event_type?: string | null;
  starts_at?: string | null;
  shop?: string | null;
  gym?: string | null;
  tickets_in_window?: number | null;
  sold_tickets_in_window?: number | null;
  attendee_count?: number | null;
  is_cancelled?: boolean | null;

  /* hashtags */
  tag?: string;
  tag_id?: string;
  posts_in_window?: number | null;
  posts_in_previous_window?: number | null;
  delta?: number | null;
  /** null when the previous window was zero — a percentage of nothing. */
  pct_change?: number | null;
  total_posts_ever?: number | null;
}

export interface AnalyticsTrending {
  kind?: AnalyticsTrendingKind;
  /** `false` for `pages`: the endpoint has no data and says why. */
  available?: boolean;
  /** Only ever set when `available` is false. Render it; never chart around it. */
  reason?: string;
  rank_basis?: string;
  window?: AnalyticsWindow;
  items?: AnalyticsTrendingItem[];
  table?: AnalyticsReportTable;
}

export interface AnalyticsConfidenceBucket {
  bucket?: string;
  low?: number;
  high?: number;
  count?: number;
}

export interface AnalyticsModelRow {
  model?: string;
  task?: string | null;
  model_version?: string | null;
  calls?: number | null;
  completed?: number | null;
  failed?: number | null;
  success_rate?: number | null;
  fallbacks?: number | null;
  fallback_rate?: number | null;
  corrections?: number | null;
  /**
   * NOT accuracy. `AIPredictionJob` has no ground-truth column; this is
   * corrections over completed jobs. It must never be relabelled "accuracy".
   */
  accuracy_proxy?: number | null;
  mean_confidence?: number | null;
  cost_usd?: number | null;
  cost_per_call_usd?: number | null;
}

export interface AnalyticsAIQuality {
  window?: AnalyticsWindow;
  totals?: {
    calls?: number | null;
    fallbacks?: number | null;
    fallback_rate?: number | null;
    corrections?: number | null;
    accuracy_proxy?: number | null;
    cost_usd?: number | null;
    cost_per_call_usd?: number | null;
    cumulative_cost_usd?: number | null;
    cumulative_calls?: number | null;
    cumulative_cost_per_call_usd?: number | null;
  };
  latency_ms?: {
    samples?: number | null;
    sampled?: boolean;
    sample_limit?: number | null;
    p50?: number | null;
    p95?: number | null;
    min?: number | null;
    max?: number | null;
  };
  confidence_distribution?: {
    window?: AnalyticsWindow;
    with_confidence?: number | null;
    buckets?: AnalyticsConfidenceBucket[];
  };
  fallback_reasons?: Array<{ reason?: string; count?: number | null }>;
  models?: AnalyticsModelRow[];
  /** Always carries the "this is a proxy, not accuracy" caveat. */
  caveats?: string[];
  table?: AnalyticsReportTable;
}

export interface AnalyticsPredictiveSignal {
  key?: string;
  label?: string;
  /** false = derived from observed counts, not itself counted. */
  observed?: boolean;
  derivation?: string;
  basis?: string;
  value?: number | null;
  note?: string;
}

export interface AnalyticsPredictive {
  window?: AnalyticsWindow;
  /** "This endpoint reports observed signals only. It does not forecast." */
  disclaimer?: string;
  signals?: AnalyticsPredictiveSignal[];
  observed?: Record<
    string,
    {
      window?: AnalyticsWindow;
      source?: string;
      total?: number | null;
      rows?: Array<Record<string, unknown>>;
      negative?: number | null;
      positive?: number | null;
      ai?: number | null;
      fallback?: number | null;
      unlabelled?: number | null;
      corrected?: number | null;
      completed?: number | null;
    }
  >;
  table?: AnalyticsReportTable;
}

/* Export ---------------------------------------------------------------- */

export type AnalyticsReportKey =
  | 'overview'
  | 'timeseries'
  | 'trending'
  | 'ai_quality'
  | 'predictive';

export type AnalyticsExportFormat = 'csv' | 'xlsx';

export interface AnalyticsExportParams extends AnalyticsWindowParams {
  report: AnalyticsReportKey;
  format: AnalyticsExportFormat;
  /** Required for `timeseries`, honoured by `trending`. */
  metric?: string;
  granularity?: 'day' | 'week';
  kind?: AnalyticsTrendingKind;
  limit?: number;
}

export interface AnalyticsExportFile {
  blob: Blob;
  /** From `Content-Disposition`, so the operator sees the server's own name. */
  filename: string;
  report?: string;
  rows?: number | null;
  from?: string;
  to?: string;
  dataSource?: string;
}

export type AnalyticsExportRefusalReason = 'row_cap' | 'xlsx_unavailable' | 'error';

/**
 * The export endpoint resolves a union rather than throwing.
 *
 * Its interesting outcomes are refusals, not transports: a **400** naming the
 * 50k row cap means the file was refused rather than truncated, and a **503**
 * means `openpyxl` is not installed server-side. A thrown `AxiosError` would
 * make the caller reconstruct both from a status code, which is exactly the
 * place this console has to be precise — so the message is handed back
 * untouched and the caller decides what to say about it.
 */
export type AnalyticsExportOutcome =
  | { ok: true; file: AnalyticsExportFile }
  | {
      ok: false;
      status: number;
      reason: AnalyticsExportRefusalReason;
      /** The server's message, verbatim. Never paraphrased. */
      message: string;
    };

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
 * Normalise a moderation list response to the `ApiResponse` envelope.
 *
 * The moderation list endpoints (`/reports/`, `/content-flags/`, `/actions/`,
 * `/appeals/`, `/commendations/`) return raw DRF pagination —
 * `{count, next, previous, results}` — while `pending-approvals` returns the
 * usual envelope. Callers are typed against `ApiResponse<T[]>` and read
 * `res.data`, so on the raw endpoints that was always `undefined` and every one
 * of those tabs silently rendered an empty list.
 *
 * Rather than let the inconsistency leak into each call site, accept both
 * shapes here and hand back the envelope. Anything already enveloped passes
 * through untouched.
 */
function envelopeList<T>(body: unknown): ApiResponse<T[]> {
  const b = body as {
    success?: boolean;
    data?: T[];
    results?: T[];
    count?: number;
    next?: string | null;
    previous?: string | null;
    message?: string;
    errors?: Record<string, string[]> | null;
    pagination?: Pagination | null;
  };
  if (Array.isArray(b?.results)) {
    return {
      success: true,
      data: b.results,
      message: b.message ?? '',
      errors: b.errors ?? null,
      pagination: { count: b.count ?? b.results.length, next: b.next ?? null, previous: b.previous ?? null },
    };
  }
  return body as ApiResponse<T[]>;
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
/* Analytics export plumbing                                           */
/* ------------------------------------------------------------------ */

/**
 * Read an error body that axios handed back as a `Blob` (which is what happens
 * whenever `responseType: 'blob'`).
 *
 * A blob's `text()` is async, so the refusal path has to await it — that is why
 * `exportAnalytics` resolves rather than throwing.
 */
async function readBlobError(data: unknown): Promise<ErrorPayload | null> {
  if (data instanceof Blob) {
    try {
      const text = await data.text();
      return text ? (JSON.parse(text) as ErrorPayload) : null;
    } catch {
      return null;
    }
  }
  return data && typeof data === 'object' ? (data as ErrorPayload) : null;
}

function refusalMessage(payload: ErrorPayload | null, fallback: string): string {
  if (!payload) return fallback;
  const detail = flattenErrors(payload.errors);
  return [payload.message, payload.detail, detail.join(' ')].filter(Boolean).join(' — ') || fallback;
}

function filenameFromDisposition(header: unknown, report: string): string {
  const value = typeof header === 'string' ? header : '';
  const match = /filename\*?=(?:UTF-8'')?"?([^";]+)"?/i.exec(value);
  if (match?.[1]) return decodeURIComponent(match[1]);
  return `analytics-${report}.csv`;
}

/** The 400 that names the row cap. `to` is the field the server blames. */
function isRowCapRefusal(payload: ErrorPayload | null): boolean {
  return /row cap|above the .* row|Narrow the date range/i.test(refusalMessage(payload, ''));
}

/** The 503 that means openpyxl is missing server-side. CSV is unaffected. */
function isXlsxUnavailable(payload: ErrorPayload | null): boolean {
  return /openpyxl/i.test(refusalMessage(payload, ''));
}

/**
 * Download one analytics report as CSV or XLSX.
 *
 * Streamed as a blob rather than followed as a plain URL because the two
 * failure modes this endpoint has (row cap, missing xlsx dependency) are JSON
 * errors the browser would otherwise save to disk as a broken file. Reading the
 * body here is what lets the UI say "refused, narrow the range" instead of
 * handing the operator a 3 KB file named `.xlsx`.
 */
export async function exportAnalyticsReport(params: AnalyticsExportParams): Promise<AnalyticsExportOutcome> {
  try {
    const response = await apiClient.get('/portal/analytics/export/', {
      params: clean(params as unknown as Record<string, unknown>),
      responseType: 'blob',
    });

    const headers = response.headers as unknown as Record<string, string>;
    return {
      ok: true,
      file: {
        blob: response.data as Blob,
        filename: filenameFromDisposition(headers['content-disposition'], params.report),
        report: headers['x-analytics-report'],
        rows: headers['x-analytics-rows'] != null ? Number(headers['x-analytics-rows']) : null,
        from: headers['x-analytics-from'],
        to: headers['x-analytics-to'],
        dataSource: headers['x-analytics-data-source'],
      },
    };
  } catch (error) {
    const status = (error as AxiosError | undefined)?.response?.status ?? 0;
    const payload = await readBlobError((error as AxiosError<unknown> | undefined)?.response?.data);
    const message = refusalMessage(
      payload,
      status === 0
        ? 'The export could not be requested — the network request failed.'
        : `The export was refused (HTTP ${status}).`,
    );
    const reason: AnalyticsExportRefusalReason =
      status === 400 ? 'row_cap'
        : status === 503 ? 'xlsx_unavailable'
          : 'error';
    return {
      ok: false,
      status,
      reason: isRowCapRefusal(payload) || reason === 'row_cap' ? 'row_cap'
        : isXlsxUnavailable(payload) || reason === 'xlsx_unavailable' ? 'xlsx_unavailable'
          : 'error',
      message,
    };
  }
}

/**
 * Save a downloaded report through a temporary object URL.
 *
 * The blob has to be handed to the browser rather than written by us: the file
 * is a spreadsheet, and a `data:` URL long enough to hold one gets truncated by
 * some browsers.
 */
export function saveAnalyticsFile(file: AnalyticsExportFile): void {
  const url = URL.createObjectURL(file.blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = file.filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
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

  /* Governance — staff onboarding ---------------------------------- */
  getStaffInvitations: (params?: { status?: string; email?: string }) =>
    apiClient.get<ApiResponse<StaffInvitation[]>>('/governance/staff-invitations/', { params }).then((r) => r.data),

  /**
   * Offer staff access to an email address.
   *
   * Returns **202** when `requires_second` is left default: the invitation
   * exists but nothing has been emailed until a second approver settles it.
   */
  createStaffInvitation: (payload: StaffInvitationCreatePayload) =>
    apiClient.post<ApiResponse<StaffInvitation>>('/governance/staff-invitations/', payload).then((r) => r.data),

  revokeStaffInvitation: (id: string) =>
    apiClient.delete<ApiResponse<StaffInvitation>>(`/governance/staff-invitations/${id}/`).then((r) => r.data),

  resendStaffInvitation: (id: string) =>
    apiClient.post<ApiResponse<StaffInvitation>>(`/governance/staff-invitations/${id}/`, {}).then((r) => r.data),

  /** Unauthenticated read so the accept screen can explain a dead link. */
  getStaffInvitationPreview: (token: string) =>
    apiClient.get<ApiResponse<StaffInvitationPreview>>(`/governance/staff-invitations/accept/${token}/`).then((r) => r.data),

  /** Requires the caller to be signed in *as the invited address*. */
  acceptStaffInvitation: (token: string) =>
    apiClient.post<ApiResponse<StaffRoleAssignment>>(`/governance/staff-invitations/accept/${token}/`, {}).then((r) => r.data),

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
    apiClient.get<unknown>('/moderation/reports/', { params: clean(params as Record<string, unknown>) }).then((r) => envelopeList<ModerationReportRow>(r.data)),

  assignModerationReport: (id: string, payload: AssignReportPayload) =>
    apiClient.post<ApiResponse<ModerationReportRow>>(`/moderation/reports/${id}/assign/`, payload).then((r) => r.data),

  handleModerationReport: (id: string, action: 'investigate' | 'resolve' | 'dismiss', resolution_note = '') =>
    apiClient.post<ApiResponse<ModerationReportRow>>(`/moderation/reports/${id}/handle/`, { action, resolution_note }).then((r) => r.data),

  /* Moderation — flags ---------------------------------------------- */
  getContentFlags: (params?: { flag_reason?: string; severity?: string; is_actioned?: boolean; content_type?: string }) =>
    apiClient.get<unknown>('/moderation/content-flags/', { params: clean(params as Record<string, unknown>) }).then((r) => envelopeList<ContentFlagRow>(r.data)),

  actOnContentFlag: (id: string, action: 'approve' | 'remove' | 'escalate', note = '') =>
    apiClient.post<ApiResponse<{ flag?: ContentFlagRow; effect?: string }>>(`/moderation/content-flags/${id}/act/`, { action, note }).then((r) => r.data),

  /**
   * Resolve a flagged/reported object into something viewable.
   *
   * Staff-only and deliberately returns the content in full: this is the surface
   * where a moderator has to see what they are about to act on.
   */
  resolveModerationContent: (contentType: string, contentId: string) =>
    apiClient
      .get<ApiResponse<ResolvedContent>>('/moderation/content-flags/resolve/', {
        params: { content_type: contentType, content_id: contentId },
      })
      .then((r) => r.data),

  getContentFlagStats: () =>
    apiClient.get<ApiResponse<ModerationStatsRow>>('/moderation/content-flags/stats/').then((r) => r.data),

  /** Ban/suspension requests raised from moderation, awaiting a second approver. */
  getPendingApprovals: () =>
    apiClient.get<ApiResponse<PendingApprovalRow[]>>('/moderation/content-flags/pending-approvals/').then((r) => r.data),

  /* Moderation — disciplinary actions -------------------------------- */
  getModerationActions: (params?: ModerationActionFilters) =>
    apiClient.get<unknown>('/moderation/actions/', { params: clean(params as Record<string, unknown>) }).then((r) => envelopeList<ModerationActionRow>(r.data)),

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
    apiClient.get<unknown>('/moderation/commendations/', { params: clean(params as Record<string, unknown>) }).then((r) => envelopeList<Commendation>(r.data)),

  createCommendation: (payload: CreateCommendationPayload) =>
    apiClient.post<ApiResponse<Commendation>>('/moderation/commendations/', payload).then((r) => r.data),

  /** Hard delete. The recipient may remove their own; staff may remove any. */
  deleteCommendation: (id: string) =>
    apiClient.delete<ApiResponse<null>>(`/moderation/commendations/${id}/`).then((r) => r.data),

  /** Withdraws from the recipient's view but keeps the row. Failed ones 409. */
  revokeCommendation: (id: string, payload: { reason?: string } = {}) =>
    apiClient.post<ApiResponse<Commendation>>(`/moderation/commendations/${id}/revoke/`, payload).then((r) => r.data),

  /* Platform analytics ------------------------------------------------- */

  /** Headline KPIs. Each one carries its own `window` and `kind`. */
  getAnalyticsOverview: (params?: AnalyticsWindowParams) =>
    apiClient
      .get<ApiResponse<AnalyticsOverview>>('/portal/analytics/overview/', {
        params: clean(params as Record<string, unknown>),
      })
      .then((r) => r.data),

  /** One metric over time, zero-filled, with its `data_source` provenance. */
  getAnalyticsTimeseries: (params: AnalyticsWindowParams & { metric: string; granularity?: 'day' | 'week' }) =>
    apiClient
      .get<ApiResponse<AnalyticsTimeseries>>('/portal/analytics/timeseries/', {
        params: clean(params as unknown as Record<string, unknown>),
      })
      .then((r) => r.data),

  /** `kind=pages` answers `available:false` with a reason instead of a series. */
  getAnalyticsTrending: (params?: AnalyticsTrendingParams) =>
    apiClient
      .get<ApiResponse<AnalyticsTrending>>('/portal/analytics/trending/', {
        params: clean(params as Record<string, unknown>),
      })
      .then((r) => r.data),

  /** `accuracy_proxy` is a correction rate. It is never labelled accuracy. */
  getAnalyticsAIQuality: (params?: AnalyticsWindowParams) =>
    apiClient
      .get<ApiResponse<AnalyticsAIQuality>>('/portal/analytics/ai-quality/', {
        params: clean(params as Record<string, unknown>),
      })
      .then((r) => r.data),

  /** Observed signals only. The endpoint produces no forecast and says so. */
  getAnalyticsPredictive: (params?: AnalyticsWindowParams) =>
    apiClient
      .get<ApiResponse<AnalyticsPredictive>>('/portal/analytics/predictive/', {
        params: clean(params as Record<string, unknown>),
      })
      .then((r) => r.data),
};

export type AdminPortalApi = typeof adminPortalApi;