import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type { BuddyLive } from '@/types/live';

export interface LiveBrowserParams {
  tab?: 'live' | 'scheduled' | 'replays' | 'upcoming';
  category?: string;
  cursor?: string;
}

export interface StartLivePayload {
  title: string;
  live_type: string;
  category: string;
  access?: string;
  artifact_fee?: Record<string, number>;
  gym_id?: string;
  scheduled_for?: string;
  is_recurring?: boolean;
  recurrence_rule?: string;
  equipment_list?: string[];
  co_hosts?: string[];
}

export interface RandomDropPayload {
  activity_type: string;
  duration: number;
  fee?: string;
}

export interface JoinLiveResponse {
  agora_channel: string;
  agora_token: string;
  agora_app_id: string;
  live_type: string;
}

export interface RandomDropStatus {
  status: 'not_searching' | 'searching' | 'matched';
  timeout_seconds?: number;
  agora_channel?: string;
  agora_token?: string;
}

export const livesApi = {
  browse: (params: LiveBrowserParams = {}) =>
    apiClient.get<ApiResponse<BuddyLive[]>>('/lives/browse/', { params }).then((r) => r.data),

  getLive: (liveId: string) =>
    apiClient.get<ApiResponse<BuddyLive>>(`/lives/${liveId}/`).then((r) => r.data),

  startLive: (data: StartLivePayload) =>
    apiClient.post<ApiResponse<BuddyLive>>('/lives/start/', data).then((r) => r.data),

  endLive: (liveId: string, saveReplay = false) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/end/`, { save_replay: saveReplay }).then((r) => r.data),

  joinLive: (liveId: string) =>
    apiClient.post<ApiResponse<JoinLiveResponse>>(`/lives/${liveId}/join/`).then((r) => r.data),

  rsvpLive: (liveId: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/rsvp/`).then((r) => r.data),

  startRandomDrop: (data: RandomDropPayload) =>
    apiClient.post<ApiResponse<{ status: string; timeout_seconds: number }>>('/lives/random-drop/start/', data).then((r) => r.data),

  getRandomDropStatus: () =>
    apiClient.get<ApiResponse<RandomDropStatus>>('/lives/random-drop/status/').then((r) => r.data),

  cancelRandomDrop: () =>
    apiClient.delete<ApiResponse<null>>('/lives/random-drop/status/').then((r) => r.data),

  getGymSchedule: (gymId: string) =>
    apiClient.get<ApiResponse<BuddyLive[]>>(`/lives/gym/${gymId}/schedule/`).then((r) => r.data),
};
