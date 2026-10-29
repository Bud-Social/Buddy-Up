import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface ContentFlag {
  id: string;
  flag_reason: 'nsfw' | 'toxic' | 'spam' | 'misinfo' | 'custom' | 'medical_claim' | 'undisclosed_sponsor' | 'adult_ungated';
  severity: 'low' | 'medium' | 'high' | 'critical';
  confidence: number;
  source: string;
  content_type: string;
  content_id: string;
  content_preview: string;
  /**
   * The model's own account of why it flagged this, captured at flag time.
   *
   * Optional on purpose: flags raised by hand (and rows written before the
   * field existed) have none, and the UI has to render those without pretending
   * they have a rationale.
   */
  ai_explanation?: string;
  /** Which layer decided — a classifier, or a keyword rule. */
  ai_method?: string;
  /**
   * Whether a bias model was actually run. `false` means "not assessed", which
   * is *not* the same as "nothing biased found" — the console says so rather
   * than leaving a reviewer to assume the flag covered bias.
   */
  bias_assessed?: boolean;
  is_actioned: boolean;
  action_taken: string;
  created_at: string;
}

export type FlagReason = ContentFlag['flag_reason'];

export interface ModerationStats {
  total: number;
  unactioned: number;
  actioned: number;
  by_severity: Record<'critical' | 'high' | 'medium' | 'low', number>;
  by_reason: Record<FlagReason, number>;
}

export interface UserReport {
  id: string;
  reason: string;
  status: string;
  description: string;
  created_at: string;
  reporter?: string | null;
  target_user?: string | null;
  /** Staff member the queue is currently sitting with, or null for unassigned. */
  assigned_to?: string | null;
  content_url?: string | null;
  resolved_at?: string | null;
  resolution_note?: string | null;
  /** Computed server-side: 4h for urgent reasons, 24h otherwise. */
  sla_due_at?: string | null;
  sla_breached?: boolean | null;
}

export interface ModerationAppeal {
  id: string;
  /** The `ModerationAction` this appeals. A UUID, required on create. */
  action?: string | null;
  reason?: string;
  status: string;
  resolution_note?: string | null;
  reviewer?: string | null;
  reviewed_at?: string | null;
  created_at: string;
}

export interface Commendation {
  id: string;
  recipient?: { id?: string | null; email?: string | null; display_name?: string | null } | null;
  issued_by?: { id?: string | null; email?: string | null; display_name?: string | null } | null;
  category?: string | null;
  category_display?: string | null;
  message?: string | null;
  visible_to_recipient?: boolean;
  created_at?: string | null;
}

export interface ModerationPendingApproval {
  id: string;
  governance_action?: string | null;
  target_user?: string | null;
  requested_by_profile?: string | null;
  reason?: string | null;
  duration_days?: number | null;
  waiting_seconds?: number | null;
  created_at?: string | null;
  moderation_action_id?: string | null;
}

export interface FlagExplanation {
  flag_id: string;
  flag_reason: string;
  severity: string;
  confidence: number;
  ai_explanation?: string;
  ai_method?: string;
  content_preview?: string;
  content_type: string;
  content_id: string;
  is_actioned: boolean;
  created_at: string;
}

export const moderationApi = {
  getQueue: (params?: { flag_reason?: string; severity?: string }) =>
    apiClient.get<ApiResponse<ContentFlag[]>>('/moderation/content-flags/queue/', { params }).then((r) => r.data),

  getStats: () =>
    apiClient.get<ApiResponse<ModerationStats>>('/moderation/content-flags/stats/').then((r) => r.data),

  actOnFlag: (flagId: string, action: 'approve' | 'remove' | 'escalate', note = '') =>
    apiClient.post<ApiResponse<ContentFlag>>(`/moderation/content-flags/${flagId}/act/`, { action, note }).then((r) => r.data),

  /** `assigned_to` accepts `'me'` or a user id; `unassigned` is its own boolean. */
  getReports: (params?: { status?: string; assigned_to?: string; unassigned?: boolean }) =>
    apiClient.get<ApiResponse<UserReport[]>>('/moderation/reports/', { params }).then((r) => r.data),

  // NOTE: handle/review return the raw object (no {success,data} envelope).
  handleReport: (reportId: string, action: 'investigate' | 'resolve' | 'dismiss', resolution_note = '') =>
    apiClient.post<UserReport>(`/moderation/reports/${reportId}/handle/`, { action, resolution_note }).then((r) => r.data),

  /** The user's own appeals, plus all of them if the caller is staff. */
  getAppeals: () =>
    apiClient.get<ApiResponse<ModerationAppeal[]>>('/moderation/appeals/').then((r) => r.data),

  /**
   * Decide an appeal.
   *
   * `resolution_note` is REQUIRED by `ModerationAppealReviewSerializer` for
   * every decision, including `approve` — it is the only record of why a ban
   * was lifted. The parameter is typed optional only so existing callers still
   * compile; `requiredResolutionNote()` below exists to make the requirement
   * explicit at the call site. Omitting it is a 400.
   */
  reviewAppeal: (appealId: string, decision: 'approve' | 'deny', resolution_note = '') =>
    apiClient.post<ModerationAppeal>(`/moderation/appeals/${appealId}/review/`, { decision, resolution_note }).then((r) => r.data),

  /**
   * Raise an appeal against a moderation action.
   *
   * The server refuses an appeal for an action that was not applied to the
   * caller's own account, so `action` is the `ModerationAction` id the user was
   * given in their notification metadata — never a guessable one.
   */
  createAppeal: (payload: { action: string; reason: string }) =>
    apiClient.post<ApiResponse<ModerationAppeal>>('/moderation/appeals/', payload).then((r) => r.data),

  /** Commendations addressed to the caller, plus the ones they issued. */
  getCommendations: () =>
    apiClient.get<ApiResponse<Commendation[]>>('/moderation/commendations/').then((r) => r.data),

  /** 204. The recipient may delete their own; staff may delete any. */
  deleteCommendation: (commendationId: string) =>
    apiClient.delete<void>(`/moderation/commendations/${commendationId}/`).then((r) => r.data),

  /** Ban/suspension requests raised from moderation, awaiting a second approver. */
    getPendingApprovals: () =>
    apiClient.get<ApiResponse<ModerationPendingApproval[]>>('/moderation/content-flags/pending-approvals/').then((r) => r.data),

  /**
   * Human-readable explanation for why content was flagged, by flag ID.
   * Any authenticated user may request this so viewers understand a
   * moderation decision instead of seeing a silent removal.
   */
  getExplanation: (flagId: string) =>
    apiClient.get<ApiResponse<FlagExplanation>>(`/moderation/content-flags/${flagId}/explanation/`).then((r) => r.data.data),
};
