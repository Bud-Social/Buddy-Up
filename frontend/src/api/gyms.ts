import { apiClient } from './client';
import type {
  ApiResponse, Gym, GymMembership, GymCategory,
  JoinRequest, GymInvite, CityResult, GymCategoryPricing,
  GymRoutinePost, GymReview, GymDonation, GymMembershipException, MembershipCheckoutResult,
  GymPartnerMetrics, GymMediaItem, GymOnlineCoach, GymEndorsement, GymRegistration,
  VenueLocation,
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
  logo_url?: string;
  cover_url?: string;
  offers_online_coaching?: boolean;
  coaching_types?: string[];
  rules?: string[];
  tags?: string[];
  content_rating?: 'general' | 'mature';
  category_pricing?: Omit<GymCategoryPricing, 'id' | 'category_name'>[];
}

export interface VenueLocationPayload {
  name: string;
  address?: string;
  city?: string;
  country?: string;
  latitude?: number | null;
  longitude?: number | null;
  instructions?: string;
  is_primary?: boolean;
}

export interface GymListParams {
  q?: string;
  category?: string;
  my?: boolean;
  city?: string;
  country?: string;
  verified?: boolean;
  min_rating?: number;
  delivery?: 'any' | 'physical' | 'virtual' | 'hybrid';
  lat?: number;
  lng?: number;
  radius_km?: number;
  ordering?: 'members' | 'rating' | 'newest' | 'nearest';
}

export interface GymCheckInStatus {
  can_check_in: boolean;
  is_member: boolean;
  last_check_in_at: string | null;
  next_check_in_at: string | null;
}

export const gymsApi = {
  list: (params: GymListParams = {}) =>
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

  /** Whether I can check in here, and when I last did. */
  getCheckInStatus: (slug: string) =>
    apiClient
      .get<ApiResponse<GymCheckInStatus>>(`/gyms/${slug}/check-in/`)
      .then((r) => r.data.data),

  /** Check myself in. A gym visit is what a "gym attendance" countdown follows. */
  checkIn: (slug: string) =>
    apiClient.post<ApiResponse<GymCheckInStatus>>(`/gyms/${slug}/check-in/`).then((r) => r.data),

  getMembers: (slug: string, params?: { role?: string; q?: string }) =>
    apiClient.get<ApiResponse<GymMembership[]>>(`/gyms/${slug}/members/`, { params }).then((r) => r.data),

  manageMember: (slug: string, userId: string, action: 'change_role' | 'remove', role?: string) =>
    apiClient.post<ApiResponse<null>>(`/gyms/${slug}/members/${userId}/`, { role }).then((r) => r.data),

  removeMember: (slug: string, userId: string) =>
    apiClient.delete(`/gyms/${slug}/members/${userId}/`).then((r) => r.data),

  // Partner-facing analytics. Partner-only on the server (owner/co-owner/
  // moderator); the UI hides the tab rather than relying on a 403.
  getPartnerMetrics: (slug: string) =>
    apiClient
      .get<ApiResponse<GymPartnerMetrics>>(`/gyms/${slug}/partner-metrics/`)
      .then((r) => r.data),

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

  getRoutinePosts: (slug: string, params?: { page?: number }) =>
    apiClient.get<ApiResponse<GymRoutinePost[]>>(`/gyms/${slug}/routine-posts/`, { params }).then((r) => r.data),

  createRoutinePost: (slug: string, data: { 
    title?: string; content?: string; activity_type: string; custom_activity_type?: string; 
    location_mode: string; start_time?: string; end_time?: string;
    recurrence?: string; recurrence_end_date?: string; recurrence_days?: number[];
    max_slots?: number; timezone?: string;
  }) => apiClient.post<ApiResponse<GymRoutinePost>>(`/gyms/${slug}/routine-posts/`, data).then((r) => r.data),

  enrollRoutineSlot: (slug: string, postId: string) =>
    apiClient.post<ApiResponse<any>>(`/gyms/${slug}/routine-posts/${postId}/enroll/`).then((r) => r.data),

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

  // ── Locations ────────────────────────────────────────────────────────
  getVenues: (slug: string) =>
    apiClient.get<ApiResponse<VenueLocation[]>>(`/gyms/${slug}/venues/`).then((r) => r.data),

  createVenue: (slug: string, data: VenueLocationPayload) =>
    apiClient.post<ApiResponse<VenueLocation>>(`/gyms/${slug}/venues/`, data).then((r) => r.data),

  updateVenue: (slug: string, venueId: string, data: Partial<VenueLocationPayload>) =>
    apiClient.patch<ApiResponse<VenueLocation>>(`/gyms/${slug}/venues/${venueId}/`, data).then((r) => r.data),

  deleteVenue: (slug: string, venueId: string) =>
    apiClient.delete<ApiResponse<null>>(`/gyms/${slug}/venues/${venueId}/`).then((r) => r.data),

  // ── Business registration & verification ─────────────────────────────
  getRegistration: (slug: string) =>
    apiClient.get<ApiResponse<GymRegistration>>(`/gyms/${slug}/registration/`).then((r) => r.data),

  saveRegistration: (slug: string, data: Partial<GymRegistration>) =>
    apiClient.patch<ApiResponse<GymRegistration>>(`/gyms/${slug}/registration/`, data).then((r) => r.data),

  submitRegistration: (slug: string, data: Partial<GymRegistration> & { document_ids?: string[] }) =>
    apiClient.post<ApiResponse<GymRegistration>>(`/gyms/${slug}/registration/`, data).then((r) => r.data),

  getVerificationStatus: (slug: string) =>
    apiClient.get<ApiResponse<GymRegistration>>(`/gyms/${slug}/verification-status/`).then((r) => r.data),

  // ── Gallery ──────────────────────────────────────────────────────────
  getMedia: (slug: string, kind?: 'photo' | 'video') =>
    apiClient.get<ApiResponse<GymMediaItem[]>>(`/gyms/${slug}/media/`, { params: { kind } }).then((r) => r.data),

  uploadMedia: (slug: string, files: File[], kind: 'photo' | 'video' = 'photo', caption = '') => {
    const form = new FormData();
    files.forEach((file) => form.append('file', file));
    form.append('kind', kind);
    if (caption) form.append('caption', caption);
    return apiClient.post<ApiResponse<GymMediaItem[]>>(`/gyms/${slug}/media/`, form, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data);
  },

  deleteMedia: (slug: string, mediaId: string) =>
    apiClient.delete(`/gyms/${slug}/media/${mediaId}/`).then((r) => r.data),

  // ── Online coaching ──────────────────────────────────────────────────
  getOnlineCoaching: (slug: string) =>
    apiClient.get<ApiResponse<{ offers_online_coaching: boolean; coaching_types: string[]; coaches: GymOnlineCoach[] }>>(
      `/gyms/${slug}/online-coaching/`,
    ).then((r) => r.data),

  updateOnlineCoaching: (slug: string, data: { offers_online_coaching?: boolean; coaching_types?: string[] }) =>
    apiClient.patch<ApiResponse<{ offers_online_coaching: boolean; coaching_types: string[] }>>(
      `/gyms/${slug}/online-coaching/`, data,
    ).then((r) => r.data),

  addOnlineCoach: (slug: string, data: { username?: string; user_id?: string; specialties?: string[]; is_available?: boolean; note?: string }) =>
    apiClient.post<ApiResponse<GymOnlineCoach>>(`/gyms/${slug}/online-coaches/`, data).then((r) => r.data),

  removeOnlineCoach: (slug: string, coachId: string) =>
    apiClient.delete(`/gyms/${slug}/online-coaches/${coachId}/`).then((r) => r.data),

  // ── Endorsements ─────────────────────────────────────────────────────
  getEndorsements: (slug: string) =>
    apiClient.get<ApiResponse<{ can_endorse: boolean; endorsements: GymEndorsement[] }>>(
      `/gyms/${slug}/endorsements/`,
    ).then((r) => r.data),

  endorseTrainer: (slug: string, data: { username?: string; user_id?: string; verification_type?: 'trainer' | 'practitioner'; note?: string }) =>
    apiClient.post<ApiResponse<GymEndorsement>>(`/gyms/${slug}/endorsements/`, data).then((r) => r.data),

  withdrawEndorsement: (slug: string, endorsementId: string) =>
    apiClient.delete(`/gyms/${slug}/endorsements/${endorsementId}/`).then((r) => r.data),

  // ── Announcements ────────────────────────────────────────────────────
  announce: (slug: string, data: { title: string; body: string; notify_members?: boolean }) =>
    apiClient.post<ApiResponse<{ post_id: string; notified: number }>>(`/gyms/${slug}/announce/`, data).then((r) => r.data),
};
