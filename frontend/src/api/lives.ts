import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type { BuddyLive, LiveCredentials, LiveRoomData } from '@/types/live';

export interface LivePollData {
  poll_id: string;
  question: string;
  options: string[];
  duration_seconds: number;
  dispatched_at: string | null;
  ends_at: string | null;
  tally?: number[];
  total_votes?: number;
  your_vote?: number | null;
}

export interface LiveBrowserParams {
  tab?: 'live' | 'scheduled' | 'replays' | 'upcoming';
  category?: string;
  cursor?: string;
  mine?: boolean;
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
  recording_consent?: 'auto_record' | 'opt_out';
  content_rating?: 'general' | 'mature';
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

  recordReplayView: (liveId: string) =>
    apiClient.post<ApiResponse<{ unique_viewers: number }>>(`/lives/${liveId}/replay/view/`, {}).then((r) => r.data),

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

  inviteCohost: (liveId: string, username: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/co-host/invite/`, { username }).then((r) => r.data),

  cancelCohostInvite: (liveId: string, username: string) =>
    apiClient.delete<ApiResponse<null>>(`/lives/${liveId}/co-host/invite/`, { data: { username } }).then((r) => r.data),

  respondCohostInvite: (liveId: string, action: 'accept' | 'decline') =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/co-host/respond/`, { action }).then((r) => r.data),

  requestToSpeak: (liveId: string) =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/co-host/request/`).then((r) => r.data),

  getCohostRequests: (liveId: string) =>
    apiClient.get<ApiResponse<{ user_id: string; username: string; display_name: string; avatar_url: string }[]>>(`/lives/${liveId}/co-host/requests/`).then((r) => r.data),

  respondToSpeakRequest: (liveId: string, username: string, action: 'approve' | 'deny') =>
    apiClient.post<ApiResponse<null>>(`/lives/${liveId}/co-host/respond-request/`, { username, action }).then((r) => r.data),

  updateVisibility: (liveId: string, access: 'public' | 'buddies' | 'gym_members' | 'private') =>
    apiClient.patch<ApiResponse<{ access: string }>>(`/lives/${liveId}/visibility/`, { access }).then((r) => r.data),

  submitFeedback: (liveId: string, rating: number, comment = '') =>
    apiClient.post<ApiResponse<{ rating: number; comment: string }>>(`/lives/${liveId}/feedback/`, { rating, comment }).then((r) => r.data),

  getFeedback: (liveId: string) =>
    apiClient.get<ApiResponse<{ count: number; average: number; recent: Array<{ rating: number; comment: string; display_name: string; avatar_url: string }> } | { rating: number; comment: string } | null>>(`/lives/${liveId}/feedback/`).then((r) => r.data),

  createPoll: (liveId: string, payload: { question: string; options: string[]; show_after_seconds: number; duration_seconds: number }) =>
    apiClient.post<ApiResponse<LivePollData>>(`/lives/${liveId}/polls/`, payload).then((r) => r.data),

  getCurrentPoll: (liveId: string) =>
    apiClient.get<ApiResponse<LivePollData | null>>(`/lives/${liveId}/polls/current/`).then((r) => r.data),

  votePoll: (liveId: string, pollId: string, option: number) =>
    apiClient.post<ApiResponse<{ tally: number[]; total_votes: number; your_vote: number }>>(`/lives/${liveId}/polls/${pollId}/vote/`, { option }).then((r) => r.data),

  toggleNotInterested: (liveId: string) =>
    apiClient.post<ApiResponse<{ not_interested: boolean }>>(`/lives/${liveId}/not-interested/`).then((r) => r.data),

  toggleMuteHost: (liveId: string) =>
    apiClient.post<ApiResponse<{ muted: boolean }>>(`/lives/${liveId}/mute-host/`).then((r) => r.data),

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
