import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface AlarmSound {
  id: string;
  name: string;
  source: string;
  audio_url: string;
  duration_ms: number | null;
  visibility: string;
  owner: string;
  is_mine: boolean;
}

export interface Alarm {
  id: string;
  time: string;
  days_mask: number;
  label: string;
  sound: AlarmSound | null;
  enabled: boolean;
  snooze_minutes: number;
}

export interface CreateAlarmPayload {
  time: string;
  days_mask: number;
  label?: string;
  sound?: string | null;
  enabled?: boolean;
  snooze_minutes?: number;
}

export type UpdateAlarmPayload = Partial<CreateAlarmPayload>;

export interface SoundShareSender {
  user_id?: string;
  profile_id?: string;
  username?: string;
  display_name?: string;
  avatar_url?: string;
}

export interface SoundShare {
  id: string;
  sound: AlarmSound;
  sender: SoundShareSender;
  status: string;
}

export interface AlarmSuggestion {
  id: string;
  title: string;
  note?: string | null;
  url?: string | null;
  sender?: SoundShareSender | null;
  status: string;
  created_at?: string;
}

export type SuggestionDecision = 'accept' | 'decline' | 'dismiss';

export const alarmsApi = {
  // ── Alarms ─────────────────────────────────────────────────────────────
  getAlarms: () =>
    apiClient.get<ApiResponse<Alarm[]>>('/alarms/').then((r) => r.data),

  createAlarm: (data: CreateAlarmPayload) =>
    apiClient.post<ApiResponse<Alarm>>('/alarms/', data).then((r) => r.data),

  updateAlarm: (id: string, data: UpdateAlarmPayload) =>
    apiClient.patch<ApiResponse<Alarm>>(`/alarms/${id}/`, data).then((r) => r.data),

  deleteAlarm: (id: string) =>
    apiClient.delete(`/alarms/${id}/`).then((r) => r.data),

  // ── Sounds ─────────────────────────────────────────────────────────────
  getSounds: () =>
    apiClient.get<ApiResponse<AlarmSound[]>>('/alarms/sounds/').then((r) => r.data),

  /**
   * Upload a new alarm sound. The messaging attachment endpoint
   * (/messaging/upload/) only stores a file and returns a bare URL — it
   * cannot create a sound record with name/visibility — so sounds go
   * directly to the alarms sounds endpoint as multipart
   * {audio, name, visibility}.
   */
  uploadSound: (file: File, name: string, visibility = 'private') => {
    const form = new FormData();
    form.append('audio', file);
    form.append('name', name);
    form.append('visibility', visibility);
    return apiClient
      .post<ApiResponse<AlarmSound>>('/alarms/sounds/', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data);
  },

  shareSound: (soundId: string, recipientProfileId: string) =>
    apiClient
      .post<ApiResponse<SoundShare>>(`/alarms/sounds/${soundId}/share/`, {
        recipient_profile_id: recipientProfileId,
      })
      .then((r) => r.data),

  // ── Shares inbox ───────────────────────────────────────────────────────
  getSharesInbox: () =>
    apiClient.get<ApiResponse<SoundShare[]>>('/alarms/shares/inbox/').then((r) => r.data),

  respondToShare: (shareId: string, accept: boolean) =>
    apiClient
      .post<ApiResponse<SoundShare>>(`/alarms/shares/${shareId}/respond/`, { accept })
      .then((r) => r.data),

  // ── Suggestions ────────────────────────────────────────────────────────
  getSuggestions: () =>
    apiClient.get<ApiResponse<AlarmSuggestion[]>>('/alarms/suggestions/').then((r) => r.data),

  sendSuggestion: (data: { recipient_profile_id: string; title: string; note?: string; url?: string }) =>
    apiClient.post<ApiResponse<AlarmSuggestion>>('/alarms/suggestions/', data).then((r) => r.data),

  respondToSuggestion: (suggestionId: string, decision: SuggestionDecision) =>
    apiClient
      .post<ApiResponse<AlarmSuggestion>>(`/alarms/suggestions/${suggestionId}/respond/`, { decision })
      .then((r) => r.data),
};
