import { apiClient } from './client';
import type { ApiResponse, Profile, Post } from '@/types';

export const profilesApi = {
  getProfile: (username: string) =>
    apiClient.get<ApiResponse<Profile>>(`/profiles/${username}/`).then((r) => r.data),

  getMyProfile: () =>
    apiClient.get<ApiResponse<Profile>>('/profiles/me/').then((r) => r.data),

  updateProfile: (data: Partial<Profile>) =>
    apiClient.patch<ApiResponse<Profile>>('/profiles/me/', data).then((r) => r.data),

  sendBuddyRequest: (username: string) =>
    apiClient.post<ApiResponse<{ status: string }>>(`/profiles/${username}/buddy/`).then((r) => r.data),

  acceptBuddyRequest: (username: string) =>
    apiClient.post<ApiResponse<{ status: string }>>(`/profiles/${username}/buddy/accept/`).then((r) => r.data),

  declineBuddyRequest: (username: string) =>
    apiClient.post<ApiResponse<null>>(`/profiles/${username}/buddy/decline/`).then((r) => r.data),

  removeBuddy: (username: string) =>
    apiClient.delete(`/profiles/${username}/buddy/`).then((r) => r.data),

  follow: (username: string) =>
    apiClient.post<ApiResponse<null>>(`/profiles/${username}/follow/`).then((r) => r.data),

  unfollow: (username: string) =>
    apiClient.delete(`/profiles/${username}/follow/`).then((r) => r.data),

  block: (username: string) =>
    apiClient.post<ApiResponse<null>>(`/profiles/${username}/block/`).then((r) => r.data),

  unblock: (username: string) =>
    apiClient.delete(`/profiles/${username}/block/`).then((r) => r.data),

  getBuddies: (username: string) =>
    apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/buddies/`).then((r) => r.data),

  getPendingRequests: () =>
    apiClient.get<ApiResponse<Profile[]>>('/profiles/pending-requests/').then((r) => r.data),

  getFollowers: (username: string) =>
    apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/followers/`).then((r) => r.data),

  getFollowing: (username: string) =>
    apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/following/`).then((r) => r.data),

  getBlocked: () =>
    apiClient.get<ApiResponse<Profile[]>>('/profiles/blocked/').then((r) => r.data),

  ping: (username: string, message?: string) =>
    apiClient.post<ApiResponse<{ ping_id: string }>>(`/profiles/${username}/ping/`, { message }).then((r) => r.data),

  searchProfiles: (params: { q: string; limit?: number }) =>
    apiClient.get<ApiResponse<Profile[]>>('/profiles/search/', { params }).then((r) => r.data),

  getProfilePosts: (username: string) =>
    apiClient.get<ApiResponse<Post[]>>(`/profiles/${username}/posts/`).then((r) => r.data),

  uploadAvatar: (file: File) => {
    const formData = new FormData();
    formData.append('avatar', file);
    return apiClient.post<ApiResponse<{ avatar_url: string }>>('/profiles/me/avatar/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  },

  uploadCover: (file: File) => {
    const formData = new FormData();
    formData.append('cover', file);
    return apiClient.post<ApiResponse<{ cover_url: string }>>('/profiles/me/cover/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  },
};
