import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface ActivityEvent {
  id: string;
  event_type: string;
  ip_address: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
}

export const activityApi = {
  getActivityLog: (type?: string, cursor?: string) =>
    apiClient.get<ApiResponse<ActivityEvent[]>>('/auth/activity-log/', {
      params: { type, cursor },
    }).then((r) => r.data),
};
