import { apiClient } from './client';
import type { ApiResponse, Profile } from '@/types';

export const profilesApi = {
  getProfile: (username: string) => apiClient.get<ApiResponse<Profile>>(`/profiles/${username}/`).then((r) => r.data),
  getMyProfile: () => apiClient.get<ApiResponse<Profile>>('/profiles/me/').then((r) => r.data),
  updateProfile: (data: Partial<Profile>) => apiClient.patch<ApiResponse<Profile>>('/profiles/me/', data).then((r) => r.data),
  sendBuddyRequest: (username: string) => apiClient.post<ApiResponse<null>>(`/profiles/${username}/buddy/`).then((r) => r.data),
  acceptBuddyRequest: (username: string) => apiClient.post<ApiResponse<null>>(`/profiles/${username}/buddy/accept/`).then((r) => r.data),
  declineBuddyRequest: (username: string) => apiClient.post<ApiResponse<null>>(`/profiles/${username}/buddy/decline/`).then((r) => r.data),
  removeBuddy: (username: string) => apiClient.delete(`/profiles/${username}/buddy/`).then((r) => r.data),
  follow: (username: string) => apiClient.post<ApiResponse<null>>(`/profiles/${username}/follow/`).then((r) => r.data),
  unfollow: (username: string) => apiClient.delete(`/profiles/${username}/follow/`).then((r) => r.data),
  block: (username: string) => apiClient.post<ApiResponse<null>>(`/profiles/${username}/block/`).then((r) => r.data),
  unblock: (username: string) => apiClient.delete(`/profiles/${username}/block/`).then((r) => r.data),
  getBuddies: (username: string) => apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/buddies/`).then((r) => r.data),
  getFollowers: (username: string) => apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/followers/`).then((r) => r.data),
  getFollowing: (username: string) => apiClient.get<ApiResponse<Profile[]>>(`/profiles/${username}/following/`).then((r) => r.data),
};
