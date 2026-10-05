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
  target_user?: string;
}

export interface ModerationAppeal {
  id: string;
  status: string;
  reason?: string;
  created_at: string;
}

export const moderationApi = {
  getQueue: (params?: { flag_reason?: string; severity?: string }) =>
    apiClient.get<ApiResponse<ContentFlag[]>>('/moderation/content-flags/queue/', { params }).then((r) => r.data),

  getStats: () =>
    apiClient.get<ApiResponse<ModerationStats>>('/moderation/content-flags/stats/').then((r) => r.data),

  actOnFlag: (flagId: string, action: 'approve' | 'remove' | 'escalate', note = '') =>
    apiClient.post<ApiResponse<ContentFlag>>(`/moderation/content-flags/${flagId}/act/`, { action, note }).then((r) => r.data),

  getReports: (params?: { status?: string }) =>
    apiClient.get<ApiResponse<UserReport[]>>('/moderation/reports/', { params }).then((r) => r.data),

  // NOTE: handle/review return the raw object (no {success,data} envelope).
  handleReport: (reportId: string, action: 'investigate' | 'resolve' | 'dismiss', resolution_note = '') =>
    apiClient.post<UserReport>(`/moderation/reports/${reportId}/handle/`, { action, resolution_note }).then((r) => r.data),

  getAppeals: () =>
    apiClient.get<ApiResponse<ModerationAppeal[]>>('/moderation/appeals/').then((r) => r.data),

  reviewAppeal: (appealId: string, decision: 'approve' | 'deny', resolution_note = '') =>
    apiClient.post<ModerationAppeal>(`/moderation/appeals/${appealId}/review/`, { decision, resolution_note }).then((r) => r.data),
};
