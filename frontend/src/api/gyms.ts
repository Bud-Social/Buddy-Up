import { apiClient } from './client';
import type {
  ApiResponse, Gym, GymMembership, GymCategory,
  JoinRequest, GymInvite, CityResult, GymCategoryPricing,
  GymSchedulePost, GymReview, GymDonation, GymMembershipException, MembershipCheckoutResult,
} from '@/types';

export interface CreateGymPayload {
  name: string;
  handle: string;
  description?: string;
  category: string;
  category_ids?: (string | number)[];
  access_type: string;
  subscription_type: string;
  location_city?: string;
  location_country?: string;
  rules?: string[];
  tags?: string[];
  content_rating?: 'general' | 'mature';
  category_pricing?: Omit<GymCategoryPricing, 'id' | 'category_name'>[];
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

  join: (slug: string, message?: string) =>
    apiClient.post<ApiResponse<{ role: string }>>(`/gyms/${slug}/join/`, { message }).then((r) => r.data),

  membershipCheckout: (slug: string, data: { discount_code?: string } = {}) =>
    apiClient.post<ApiResponse<MembershipCheckoutResult>>(`/gyms/${slug}/membership/checkout/`, data).then((r) => r.data),

  getMembershipExceptions: (slug: string) =>
    apiClient.get<ApiResponse<GymMembershipException[]>>(`/gyms/${slug}/membership-exceptions/`).then((r) => r.data),

  createMembershipException: (slug: string, data: { member_id?: string; username?: string; discount_pct?: number; reason?: string; expires_at?: string | null; is_active?: boolean }) =>
    apiClient.post<ApiResponse<GymMembershipException>>(`/gyms/${slug}/membership-exceptions/`, data).then((r) => r.data),

  deleteMembershipException: (slug: string, exceptionId: string) =>
    apiClient.delete(`/gyms/${slug}/membership-exceptions/${exceptionId}/`).then((r) => r.data),

  leave: (slug: string) =>
    apiClient.post<ApiResponse<null>>(`/gyms/${slug}/leave/`).then((r) => r.data),

  getMembers: (slug: string, params?: { role?: string; q?: string }) =>
    apiClient.get<ApiResponse<GymMembership[]>>(`/gyms/${slug}/members/`, { params }).then((r) => r.data),

  manageMember: (slug: string, userId: string, action: 'change_role' | 'remove', role?: string) =>
    apiClient.post<ApiResponse<null>>(`/gyms/${slug}/members/${userId}/`, { role }).then((r) => r.data),

  removeMember: (slug: string, userId: string) =>
    apiClient.delete(`/gyms/${slug}/members/${userId}/`).then((r) => r.data),

  checkHandle: (candidate: string) =>
    apiClient.get<ApiResponse<{ available: boolean; suggested: string | null }>>('/gyms/check-handle/', {
      params: { candidate },
    }).then((r) => r.data),

  getCategories: () =>
    apiClient.get<ApiResponse<GymCategory[]>>('/gyms/categories/').then((r) => r.data),

  searchCities: (q: string) =>
    apiClient.get<ApiResponse<CityResult[]>>('/gyms/cities/', { params: { q } }).then((r) => r.data),

  getJoinRequests: (slug: string, status?: string) =>
    apiClient.get<ApiResponse<JoinRequest[]>>(`/gyms/${slug}/join-requests/`, {
      params: status ? { status } : {},
    }).then((r) => r.data),

  manageJoinRequest: (slug: string, requestId: string, status: 'approved' | 'rejected') =>
    apiClient.patch<ApiResponse<JoinRequest>>(`/gyms/${slug}/join-requests/${requestId}/`, { status }).then((r) => r.data),

  invite: (slug: string, payload: { username?: string; email?: string }) =>
    apiClient.post<ApiResponse<any>>(`/gyms/${slug}/invite/`, payload).then((r) => r.data),

  respondToInvite: (slug: string, inviteId: string, action: 'accept' | 'decline') =>
    apiClient.post<ApiResponse<GymInvite>>(`/gyms/${slug}/invites/${inviteId}/${action}/`).then((r) => r.data),

  getSchedulePosts: (slug: string, params?: { page?: number }) =>
    apiClient.get<ApiResponse<GymSchedulePost[]>>(`/gyms/${slug}/schedule-posts/`, { params }).then((r) => r.data),

  createSchedulePost: (slug: string, data: { 
    title?: string; content?: string; activity_type: string; custom_activity_type?: string; 
    location_mode: string; start_time?: string; end_time?: string;
    recurrence?: string; recurrence_end_date?: string; recurrence_days?: number[];
    max_slots?: number; timezone?: string;
  }) => apiClient.post<ApiResponse<GymSchedulePost>>(`/gyms/${slug}/schedule-posts/`, data).then((r) => r.data),

  enrollScheduleSlot: (slug: string, postId: string) =>
    apiClient.post<ApiResponse<any>>(`/gyms/${slug}/schedule-posts/${postId}/enroll/`).then((r) => r.data),

  getMyEnrollments: (slug: string) =>
    apiClient.get<ApiResponse<any[]>>(`/gyms/${slug}/my-enrollments/`).then((r) => r.data),

  getReviews: (slug: string, params?: { page?: number }) =>
    apiClient.get<ApiResponse<GymReview[]>>(`/gyms/${slug}/reviews/`, { params }).then((r) => r.data),

  createReview: (slug: string, data: { rating: number; comment?: string }) =>
    apiClient.post<ApiResponse<GymReview>>(`/gyms/${slug}/reviews/`, data).then((r) => r.data),

  replyToReview: (slug: string, reviewId: string, reply_text: string) =>
    apiClient.post<ApiResponse<GymReview>>(`/gyms/${slug}/reviews/${reviewId}/reply/`, { reply_text }).then((r) => r.data),

  getGymFeed: (slug: string, params?: { page?: number }) =>
    apiClient.get<ApiResponse<any>>(`/gyms/${slug}/feed/`, { params }).then((r) => r.data),

  donate: (slug: string, data: { amount: number; message?: string }) =>
    apiClient.post<ApiResponse<GymDonation>>(`/gyms/${slug}/donate/`, data).then((r) => r.data),

  getEvents: (slug: string, upcoming: boolean = true) =>
    apiClient.get<ApiResponse<any[]>>(`/gyms/${slug}/events/`, { params: { upcoming } }).then((r) => r.data),
};
