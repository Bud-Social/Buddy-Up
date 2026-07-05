import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type { BuddyLive, LiveCredentials, LiveRoomData } from '@/types/live';

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
  credentials: LiveCredentials;
  live_type: string;
  host_name: string;
}

export interface RandomDropStatus {
  status: 'not_searching' | 'searching' | 'matched';
  timeout_seconds?: number;
  live_id?: string;
  credentials?: LiveCredentials;
}

export interface StartLiveResponse {
  live: BuddyLive;
  credentials: LiveCredentials;
}

export const livesApi = {
  browse: (params: LiveBrowserParams = {}) =>
    apiClient.get<ApiResponse<BuddyLive[]>>('/lives/browse/', { params }).then((r) => r.data),

  getLive: (liveId: string) =>
    apiClient.get<ApiResponse<BuddyLive>>(`/lives/${liveId}/`).then((r) => r.data),

  startLive: (data: StartLivePayload) =>
    apiClient.post<ApiResponse<StartLiveResponse>>('/lives/start/', data).then((r) => r.data),

  endLive: (liveId: string, saveReplay = false) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/end/`, { save_replay: saveReplay }).then((r) => r.data),

  joinLive: (liveId: string) =>
    apiClient.post<ApiResponse<JoinLiveResponse>>(`/lives/${liveId}/join/`).then((r) => r.data),

  getLiveCredentials: (liveId: string) =>
    apiClient.get<ApiResponse<LiveRoomData>>(`/lives/${liveId}/credentials/`).then((r) => r.data),

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

  getUserLives: (username: string, params: { tab?: string; cursor?: string } = {}) =>
    apiClient.get<ApiResponse<BuddyLive[]>>(`/lives/profile/${username}/`, { params }).then((r) => r.data),

  refundGift: (liveId: string, txId: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/refund-gift/${txId}/`).then((r) => r.data),

  addCoHost: (liveId: string, username: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/co-host/`, { username }).then((r) => r.data),

  removeCoHost: (liveId: string, username: string) =>
    apiClient.delete<ApiResponse<null>>(`/lives/${liveId}/co-host/`, { data: { username } }).then((r) => r.data),

  initClientRecording: (liveId: string) =>
    apiClient.post<ApiResponse<{ session_id: string }>>(`/lives/${liveId}/recording/init/`).then((r) => r.data),

  uploadReplayChunk: (liveId: string, chunk: Blob, chunkIndex: number) => {
    const fd = new FormData();
    fd.append('chunk', chunk);
    fd.append('chunk_index', String(chunkIndex));
    return apiClient.post<ApiResponse<null>>(`/lives/${liveId}/recording/upload/`, fd).then((r) => r.data);
  },

  completeClientReplay: (liveId: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/recording/complete/`).then((r) => r.data),
};
