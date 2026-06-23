import { apiClient } from './client';
import type { ApiResponse, Gym, GymMembership } from '@/types';

export interface CreateGymPayload {
  name: string;
  handle: string;
  description?: string;
  category: string;
  access_type: string;
  subscription_type: string;
  location_city?: string;
  location_country?: string;
  rules?: string[];
  tags?: string[];
}

export const gymsApi = {
  list: (params: { q?: string; category?: string; my?: boolean } = {}) =>
    apiClient.get<ApiResponse<Gym[]>>('/gyms/', { params }).then((r) => r.data),

  create: (data: CreateGymPayload) =>
    apiClient.post<ApiResponse<Gym>>('/gyms/create/', data).then((r) => r.data),

  detail: (slug: string) =>
    apiClient.get<ApiResponse<Gym>>(`/gyms/${slug}/`).then((r) => r.data),

  update: (slug: string, data: Partial<Gym>) =>
    apiClient.patch<ApiResponse<Gym>>(`/gyms/${slug}/`, data).then((r) => r.data),

  delete: (slug: string) =>
    apiClient.delete(`/gyms/${slug}/`).then((r) => r.data),

  join: (slug: string) =>
    apiClient.post<ApiResponse<{ role: string }>>(`/gyms/${slug}/join/`).then((r) => r.data),

  leave: (slug: string) =>
    apiClient.post<ApiResponse<null>>(`/gyms/${slug}/leave/`).then((r) => r.data),

  getMembers: (slug: string, params?: { role?: string; q?: string }) =>
    apiClient.get<ApiResponse<GymMembership[]>>(`/gyms/${slug}/members/`, { params }).then((r) => r.data),

  manageMember: (slug: string, userId: string, action: 'change_role' | 'remove', role?: string) =>
    apiClient.post<ApiResponse<null>>(`/gyms/${slug}/members/${userId}/`, { role }).then((r) => r.data),

  removeMember: (slug: string, userId: string) =>
    apiClient.delete(`/gyms/${slug}/members/${userId}/`).then((r) => r.data),
};
