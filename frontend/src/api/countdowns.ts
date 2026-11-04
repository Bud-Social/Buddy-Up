import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type {
  CountdownTemplate,
  UserCountdown,
  CreateUserCountdown,
  UpdateUserCountdown,
} from '@/types/countdowns';

export const countdownsApi = {
  listTemplates: () =>
    apiClient
      .get<ApiResponse<CountdownTemplate[]>>('/countdowns/templates/')
      .then((r) => r.data.data),

  seedTemplates: () =>
    apiClient.post<ApiResponse<{ created: number; total: number }>>('/countdowns/templates/seed/').then((r) => r.data.data),

  listCountdowns: (params?: { is_active?: boolean }) =>
    apiClient
      .get<ApiResponse<UserCountdown[]>>('/countdowns/', { params })
      .then((r) => r.data.data),

  createCountdown: (payload: CreateUserCountdown) =>
    apiClient.post<ApiResponse<UserCountdown>>('/countdowns/', payload).then((r) => r.data.data),

  getCountdown: (id: string) =>
    apiClient.get<ApiResponse<UserCountdown>>(`/countdowns/${id}/`).then((r) => r.data.data),

  updateCountdown: (id: string, payload: UpdateUserCountdown) =>
    apiClient.patch<ApiResponse<UserCountdown>>(`/countdowns/${id}/`, payload).then((r) => r.data.data),

  deleteCountdown: (id: string) =>
    apiClient.delete(`/countdowns/${id}/`).then((r) => r.data),

  checkIn: (id: string) =>
    apiClient.post<ApiResponse<UserCountdown>>(`/countdowns/${id}/checkin/`).then((r) => r.data.data),

  reset: (id: string) =>
    apiClient.post<ApiResponse<UserCountdown>>(`/countdowns/${id}/reset/`).then((r) => r.data.data),

  autoAdvance: (signal: string) =>
    apiClient
      .post<ApiResponse<{ advanced_ids: string[]; count: number }>>('/countdowns/auto-advance/', { signal })
      .then((r) => r.data.data),

  welcomeCheck: (email: string) =>
    apiClient
      .post<ApiResponse<{
        is_welcome_user: boolean;
        display_name: string;
        nickname: string;
        auto_buddy_email: string | null;
      }>>('/countdowns/welcome-check/', { email })
      .then((r) => r.data.data),
};
