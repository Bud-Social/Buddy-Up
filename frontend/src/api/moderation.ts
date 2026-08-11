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

export const moderationApi = {
  getQueue: (params?: { flag_reason?: string; severity?: string }) =>
    apiClient.get<ApiResponse<ContentFlag[]>>('/moderation/content-flags/queue/', { params }).then((r) => r.data),

  getStats: () =>
    apiClient.get<ApiResponse<ModerationStats>>('/moderation/content-flags/stats/').then((r) => r.data),

  actOnFlag: (flagId: string, action: 'approve' | 'remove' | 'escalate', note = '') =>
    apiClient.post<ApiResponse<ContentFlag>>(`/moderation/content-flags/${flagId}/act/`, { action, note }).then((r) => r.data),
};
