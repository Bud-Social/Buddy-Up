import { apiClient } from './client';
import type { ApiResponse } from '@/types';

/** Guardians / parental co-owner management (prefix /guardians/). */

export interface GuardianPermissions {
  allow_direct_messages: boolean;
  allow_spends: boolean;
}

export interface GuardianParty {
  username: string;
  display_name: string;
  avatar_url?: string | null;
}

export interface GuardianLink {
  id: string | number;
  role: 'guardian' | 'teen' | string;
  status: 'pending' | 'accepted' | string;
  invite_email?: string | null;
  permissions: GuardianPermissions;
  created_at: string;
  accepted_at?: string | null;
  teen?: GuardianParty;
  guardian?: GuardianParty;
  hard_deletion_scheduled?: string | null;
}

export interface GuardianLinksResponse {
  as_guardian: GuardianLink[];
  as_teen: GuardianLink[];
}

export interface GuardianDashboardEntry {
  link_id: string | number;
  teen: GuardianParty;
  account_age_days: number;
  last_active: string | null;
  posts_last_7d: number;
  workouts_last_7d: number;
  upcoming_sessions: number;
  permissions: GuardianPermissions;
}

export const guardiansApi = {
  invite: (data: { teen_email: string; teen_name?: string; teen_dob?: string }) =>
    apiClient.post<ApiResponse<GuardianLink>>('/guardians/invite/', data).then((r) => r.data),

  links: () =>
    apiClient.get<ApiResponse<GuardianLinksResponse>>('/guardians/links/').then((r) => r.data),

  acceptLink: (id: string | number) =>
    apiClient.post<ApiResponse<GuardianLink>>(`/guardians/links/${id}/accept/`).then((r) => r.data),

  deleteLink: (id: string | number) =>
    apiClient.delete<ApiResponse<null>>(`/guardians/links/${id}/`).then((r) => r.data),

  updatePermissions: (id: string | number, permissions: Partial<GuardianPermissions>) =>
    apiClient.patch<ApiResponse<GuardianLink>>(`/guardians/links/${id}/permissions/`, permissions).then((r) => r.data),

  dashboard: () =>
    apiClient.get<ApiResponse<GuardianDashboardEntry[]>>('/guardians/dashboard/').then((r) => r.data),

  /** Public endpoint (invite token from the email link). */
  acceptInvite: (invite_token: string, new_password: string) =>
    apiClient.post<ApiResponse<GuardianLink>>('/guardians/accept-invite/', { invite_token, new_password }).then((r) => r.data),
};
