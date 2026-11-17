import { apiClient } from './client';
import type {
  ApiResponse, Gym, GymMembership, GymCategory,
  JoinRequest, GymInvite, CityResult, GymCategoryPricing,
  GymRoutinePost, GymReview, GymDonation, GymMembershipException, MembershipCheckoutResult,
  GymPartnerMetrics, GymMediaItem, GymOnlineCoach, GymEndorsement, GymRegistration,
  VenueLocation, GymActionLog,
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
  building_name?: string;
  floor?: number | null;
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

/**
 * The pin picker yields full-precision floats but the backend stores
 * `DecimalField(max_digits=9, decimal_places=6)` — sending more precision
 * makes the API reject the venue. Round defensively here.
 */
function normalizeVenuePayload<T extends { latitude?: number | null; longitude?: number | null }>(data: T): T {
  const round = (value: number | null | undefined) =>
    typeof value === 'number' && Number.isFinite(value)
      ? Number(value.toFixed(6))
      : value;
  return {
    ...data,
    latitude: round(data.latitude),
    longitude: round(data.longitude),
  };
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

  /** Append-only audit trail. Moderator/owner/co-owner only on the server. */
  getActionLogs: (slug: string, params?: { action?: string; limit?: number }) =>
    apiClient.get<ApiResponse<GymActionLog[]>>(`/gyms/${slug}/action-logs/`, { params }).then((r) => r.data),

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

  getPublicVenues: (slug: string) =>
    apiClient.get<ApiResponse<VenueLocation[]>>(`/gyms/${slug}/venues-public/`).then((r) => r.data),

  createVenue: (slug: string, data: VenueLocationPayload) =>
    apiClient.post<ApiResponse<VenueLocation>>(`/gyms/${slug}/venues/`, normalizeVenuePayload(data)).then((r) => r.data),

  updateVenue: (slug: string, venueId: string, data: Partial<VenueLocationPayload>) =>
    apiClient.patch<ApiResponse<VenueLocation>>(`/gyms/${slug}/venues/${venueId}/`, normalizeVenuePayload(data)).then((r) => r.data),

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

  uploadMedia: (slug: string, files: File[], kind: 'photo' | 'video' = 'photo', caption = '', onProgress?: (index: number, ratio: number, file: File) => void) => {
    // Sequential per-file requests so each file shows byte-accurate progress.
    // The backend accepts a single file per request through the same path.
    const run = async () => {
      const items: GymMediaItem[] = [];
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const form = new FormData();
        form.append('file', file);
        form.append('kind', kind);
        if (caption) form.append('caption', caption);
        const res = await apiClient.post<ApiResponse<GymMediaItem[]>>(`/gyms/${slug}/media/`, form, {
          headers: { 'Content-Type': 'multipart/form-data' },
          onUploadProgress: (e) => {
            const ratio = e.total ? Math.min(1, e.loaded / e.total) : 0;
            onProgress?.(i, ratio, file);
          },
        });
        const rows = Array.isArray(res.data?.data) ? res.data.data : [];
        items.push(...rows);
      }
      return { success: true as const, data: items, message: 'Uploaded', errors: null, pagination: null };
    };
    return run();
  },

  deleteMedia: (slug: string, mediaId: string) =>
    apiClient.delete(`/gyms/${slug}/media/${mediaId}/`).then((r) => r.data),

  // ── Online coaching ──────────────────────────────────────────────────
  getOnlineCoaching: (slug: string) =>
    apiClient.get<ApiResponse<{ offers_online_coaching: boolean; coaching_types: string[]; coaches: GymOnlineCoach[] }>>(
      `/gyms/${slug}/online-coaching/`,
    ).then((r) => r.data),

  // ── Online coaches ───────────────────────────────────────────────────
  respondCoachInvite: (slug: string, coachId: string, action: 'accept' | 'decline') =>
    apiClient.post(`/gyms/${slug}/online-coaches/${coachId}/respond/`, { action }).then((r) => r.data),

  updateOnlineCoaching: (slug: string, data: { offers_online_coaching?: boolean; coaching_types?: string[] }) =>
    apiClient.patch<ApiResponse<{ offers_online_coaching: boolean; coaching_types: string[] }>>(
      `/gyms/${slug}/online-coaching/`, data,
    ).then((r) => r.data),

  addOnlineCoach: (slug: string, data: { username?: string; user_id?: string; specialties?: string[]; is_available?: boolean; note?: string }) =>
    apiClient.post<ApiResponse<GymOnlineCoach>>(`/gyms/${slug}/online-coaches/`, data).then((r) => r.data),

  removeOnlineCoach: (slug: string, coachId: string) =>
    apiClient.delete(`/gyms/${slug}/online-coaches/${coachId}/`).then((r) => r.data),

  addToTeam: (slug: string, data: { username: string; role: 'trainer' | 'moderator' }) =>
    apiClient.post<ApiResponse<{ username: string; role: string; created: boolean }>>(
      `/gyms/${slug}/team/add/`, data,
    ).then((r) => r.data),

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

// ── Verification tiers & gym wallet (real-money tier subscription) ────────
export interface TierPlan {
  tier: 'regular' | 'midlevel' | 'executive';
  amount_minor: number;
  currency: string;
  cap: number | null;
}

export interface TierOverview {
  subscription: {
    tier: 'regular' | 'midlevel' | 'executive';
    status: 'regular' | 'active' | 'grace' | 'cancelled';
    current_period_end: string | null;
    grace_deadline: string | null;
    auto_renew: boolean;
    currency: string;
    amount_minor: number;
    capacity: { tier: string; cap: number | null; current: number; remaining: number | null; at_cap: boolean };
  };
  plans: Record<'regular' | 'midlevel' | 'executive', TierPlan>;
  country: string;
  currency: string;
}

export interface GymWalletSummary {
  balance: Record<string, number>;
  usd_estimate: number;
  entries: Array<{
    id: string;
    artifact_type: string;
    quantity: number;
    direction: 'credit' | 'debit';
    kind: string;
    reference_id: string;
    note: string;
    created_at: string;
  }>;
  by_kind: Record<string, Record<string, { quantity: number; count: number }>>;
  window_days: number;
  donations_received: number;
  capacity: { tier: string; cap: number | null; current: number; remaining: number | null; at_cap: boolean };
}

const tierApi = {
  tier: (slug: string) =>
    apiClient.get<ApiResponse<TierOverview>>(`/gyms/${slug}/tier/`).then((r) => r.data),

  tierCheckout: (slug: string, tier: 'midlevel' | 'executive', method: 'card' | 'mpesa' = 'card', mpesaPhone?: string) =>
    apiClient.post(`/gyms/${slug}/tier/checkout/`, { tier, method, mpesa_phone: mpesaPhone }).then((r) => r.data),

  tierConfirm: (slug: string, txRef: string, flutterwaveId: string) =>
    apiClient.post(`/gyms/${slug}/tier/confirm/`, { tx_ref: txRef, flutterwave_id: flutterwaveId }).then((r) => r.data),

  tierCancel: (slug: string) =>
    apiClient.post(`/gyms/${slug}/tier/cancel/`, {}).then((r) => r.data),

  wallet: (slug: string, days: 7 | 30 | 90 | 365 = 30) =>
    apiClient.get<ApiResponse<GymWalletSummary>>(`/gyms/${slug}/wallet/`, { params: { days } }).then((r) => r.data),
};

export { tierApi };

// ── Connected shops ───────────────────────────────────────────────────────
export interface GymShopSummary {
  id: string;
  shop_id: string;
  name: string;
  handle: string;
  description: string;
  logo_url: string;
  accent_color: string;
  verification_status: string;
  is_active: boolean;
  products_count: number;
  created_at: string;
  units_sold_90d: number;
  orders_90d: number;
  /** Seller-split artifact totals for this shop's paid orders (last 90d). */
  artifact_splits_90d?: Record<string, number>;
  status: 'pending' | 'active' | 'declined';
  is_primary: boolean;
  decided_at: string | null;
}

export interface GymShopsPayload {
  shops: GymShopSummary[];
  totals: {
    shops: number;
    units_sold_90d: number;
    orders_90d: number;
    artifact_splits_90d: Record<string, number>;
  };
  window_days: number;
}

const shopsApi = {
  list: (slug: string) =>
    apiClient.get<ApiResponse<GymShopsPayload>>(`/gyms/${slug}/shops/`).then((r) => r.data),

  connect: (slug: string, handle: string) =>
    apiClient.post<ApiResponse<GymShopSummary>>(`/gyms/${slug}/shops/`, { handle }).then((r) => r.data),

  disconnect: (slug: string, handle: string) =>
    apiClient.delete(`/gyms/${slug}/shops/`, { data: { handle } }).then((r) => r.data),
};

export { shopsApi };

// ── Console insights: sessions, messages, communities, rich analytics ──────
export interface GymInsightBooking {
  id: string;
  client: string;
  client_display: string;
  client_avatar: string;
  trainer: string;
  trainer_display: string;
  trainer_avatar: string;
  session_type: string;
  status: string;
  scheduled_at: string | null;
  completed_at: string | null;
  duration_minutes: number | null;
  fee: number | Record<string, number> | null;
  created_at: string;
}

export interface GymSessionsPayload {
  summary: {
    sessions_30d: number;
    upcoming_30d: number;
    cancelled_30d: number;
    no_shows_30d: number;
    check_ins_30d: number;
    unique_attendees_30d: number;
  };
  bookings: GymInsightBooking[];
  check_ins_daily: { date: string; count: number }[];
}

export interface GymGymMessageConversation {
  id: string;
  kind: 'community' | 'group' | 'direct';
  name: string;
  members: { username: string; display_name: string; avatar_url: string; role: string }[];
  last_message_at: string | null;
  last_message: string | null;
  is_community: boolean;
}

export interface GymInboundMessage {
  id: string;
  body: string;
  sender: string;
  sender_display: string;
  sender_avatar: string;
  sent_at: string;
  conversation: string;
}

export interface GymMessagesPayload {
  conversations: GymGymMessageConversation[];
  recent_inbound: GymInboundMessage[];
  summary: {
    community_chats: number;
    group_chats: number;
    direct_threads: number;
    inbound_7d: number;
  };
}

export interface GymLinkedCommunity {
  id: string;
  name: string;
  description: string;
  avatar_url: string;
  cover_url: string;
  member_count: number;
  post_count: number;
  is_public: boolean;
  is_primary: boolean;
  is_member: boolean;
  is_gym_formed: boolean;
  created_at: string;
  /** 'pending' until the community approves the link. */
  status?: 'pending' | 'active' | 'declined';
}

export interface GymDiscoverableCommunity {
  id: string;
  name: string;
  description: string;
  avatar_url: string;
  member_count: number;
  created_at: string;
}

export interface GymCommunitiesPayload {
  linked: GymLinkedCommunity[];
  discoverable: GymDiscoverableCommunity[];
  primary_count: number;
}

export interface GymAnalyticsKpis {
  active_members: number;
  new_members_30d: number;
  churned_30d: number;
  retention_rate_30d: number;
  activation_rate_30d: number;
  check_ins_30d: number;
  avg_check_ins_per_day: number;
  unique_attendees_30d: number;
  visit_rate_30d: number;
  bookings_30d: number;
  completed_bookings_30d: number;
  messages_30d: number;
  inbound_client_messages_30d: number;
  community_members: number;
  revenue_30d_artifacts: number;
  revenue_lifetime_artifacts: number;
  posts_30d: number;
  join_requests_30d: number;
  join_requests_approved_30d: number;
  join_conversion_30d: number;
  events_hosted: number;
  events_hosted_30d: number;
  products_sold: number;
  products_sold_30d: number;
  programmes_sold: number;
  programmes_sold_30d: number;
  meal_plans_sold: number;
  meal_plans_sold_30d: number;
  shop_orders_30d: number;
}

export interface GymAnalyticsPayload {
  kpis: GymAnalyticsKpis;
  growth: {
    audience_pct: number;
    check_ins_pct: number;
    bookings_pct: number;
    posts_pct: number;
    messages_pct: number;
    revenue_pct: number;
  };
  timeseries: {
    check_ins: { date: string; count: number }[];
    new_members: { date: string; count: number }[];
    posts: { date: string; count: number }[];
    revenue_artifacts: { date: string; count: number }[];
    messages: { date: string; count: number }[];
    bookings: { date: string; count: number }[];
  };
  share_card: string;
}

const gymInsightsApi = {
  sessions: (slug: string) =>
    apiClient.get<ApiResponse<GymSessionsPayload>>(`/gyms/${slug}/sessions/`).then((r) => r.data),

  messages: (slug: string) =>
    apiClient.get<ApiResponse<GymMessagesPayload>>(`/gyms/${slug}/messages/`).then((r) => r.data),

  communities: (slug: string) =>
    apiClient.get<ApiResponse<GymCommunitiesPayload>>(`/gyms/${slug}/communities/`).then((r) => r.data),

  linkCommunity: (slug: string, communityId: string, opts?: { is_primary?: boolean }) =>
    apiClient
      .post<ApiResponse<GymLinkedCommunity>>(`/gyms/${slug}/communities/`, { action: 'link', community_id: communityId, ...opts })
      .then((r) => r.data),

  createCommunity: (slug: string, data: { name: string; description?: string; is_public?: boolean }) =>
    apiClient
      .post<ApiResponse<GymLinkedCommunity>>(`/gyms/${slug}/communities/`, { action: 'create', ...data })
      .then((r) => r.data),

  unlinkCommunity: (slug: string, communityId: string) =>
    apiClient.delete(`/gyms/${slug}/communities/`, { data: { community_id: communityId } }).then((r) => r.data),

  analytics: (slug: string) =>
    apiClient.get<ApiResponse<GymAnalyticsPayload>>(`/gyms/${slug}/analytics/`).then((r) => r.data),
};

export { gymInsightsApi };

// ── Community-side approval of gym→community link requests ─────────────────
export interface GymLinkRequest {
  id: number;
  gym_handle: string;
  gym_name: string;
  gym_logo_url: string;
  gym_category: string;
  gym_member_count: number;
  community_id: string;
  community_name: string;
  requested_by: string;
  created_at: string;
}

export interface GymLinkRequestDecideResult {
  id: number;
  status: 'active' | 'declined';
  is_primary: boolean;
  community_id: string;
  gym_handle: string;
}

const communityLinkApi = {
  list: (communityId?: string) =>
    apiClient.get<ApiResponse<{ requests: GymLinkRequest[]; count: number }>>(
      '/gyms/community-link-requests/',
      { params: communityId ? { community_id: communityId } : {} },
    ).then((r) => r.data),

  decide: (requestId: number, decision: 'approved' | 'declined') =>
    apiClient.post<ApiResponse<GymLinkRequestDecideResult>>(
      `/gyms/community-link-requests/${requestId}/decide/`, { decision },
    ).then((r) => r.data),
};

export { communityLinkApi };

// ── Gym-identity engagement on the public home feed ────────────────────────
const gymFeedApi = {
  react: (slug: string, postId: string, reactionType?: string) =>
    apiClient.post<ApiResponse<{ reaction_counts: Record<string, number>; gym_reaction: string | null; post_id: string }>>(
      `/gyms/${slug}/feed/react/`, { post_id: postId, reaction_type: reactionType },
    ).then((r) => r.data),

  repost: (slug: string, postId: string) =>
    apiClient.post<ApiResponse<{ action: 'reposted' | 'unreposted'; repost_count: number; gym_reposted: boolean }>>(
      `/gyms/${slug}/feed/repost/`, { post_id: postId },
    ).then((r) => r.data),

  comment: (slug: string, payload: { post_id: string; body: string; parent_id?: string }) =>
    apiClient.post<ApiResponse<any>>(`/gyms/${slug}/feed/comment/`, payload).then((r) => r.data.data),

  save: (slug: string, postId: string) =>
    apiClient.post<ApiResponse<{ saved: boolean; post_id: string }>>(
      `/gyms/${slug}/feed/save/`, { post_id: postId },
    ).then((r) => r.data.data),

  saved: (slug: string, params: { collection?: string } = {}) =>
    apiClient.get<ApiResponse<{ count: number; items: any[] }>>(`/gyms/${slug}/feed/saved/`, { params })
      .then((r) => r.data.data),

  reactCommunityPost: (slug: string, communityId: string, postId: string, reactionType: string) =>
    apiClient.post<ApiResponse<{ reaction_type: string; is_reacted: boolean; like_count?: number }>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/react/`, { reaction_type: reactionType },
    ).then((r) => r.data.data),

  repostCommunityPost: (slug: string, communityId: string, postId: string) =>
    apiClient.post<ApiResponse<{ reposted: boolean; repost_count: number }>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/repost/`, {},
    ).then((r) => r.data.data),

  saveCommunityPost: (slug: string, communityId: string, postId: string) =>
    apiClient.post<ApiResponse<{ saved: boolean; save_count: number }>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/save/`, {},
    ).then((r) => r.data.data),

  commentCommunityPost: (slug: string, communityId: string, postId: string, body: string, replyToId?: string) =>
    apiClient.post<ApiResponse<any>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/comments/`,
      replyToId ? { body, reply_to_id: replyToId } : { body },
    ).then((r) => r.data.data),

  listCommunityComments: (slug: string, communityId: string, postId: string) =>
    apiClient.get<ApiResponse<any[]>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/comments/`,
    ).then((r) => r.data.data),

  toggleCommunityCommentLike: (slug: string, communityId: string, postId: string, commentId: string) =>
    apiClient.post<ApiResponse<{ is_liked: boolean; like_count: number; reaction_counts: Record<string, number>; user_reaction: string | null }>>(
      `/gyms/${slug}/communities/${communityId}/posts/${postId}/comments/${commentId}/like/`, {},
    ).then((r) => r.data.data),

  toggleCommentLike: (slug: string, postId: string, commentId: string) =>
    apiClient.post<ApiResponse<{ reaction_counts: Record<string, number>; user_reaction: string | null; is_liked: boolean }>>(
      `/gyms/${slug}/feed/comments/like/`, { post_id: postId, comment_id: commentId },
    ).then((r) => r.data.data),
};

export { gymFeedApi };

// ── Contained gym inbox (gym ↔ members / team / clients) ───────────────────
export type GymInboxAudience = 'member' | 'team' | 'client';

export interface GymInboxConversation {
  id: string;
  kind: 'gym';
  conversation_kind: GymInboxAudience;
  is_group: boolean;
  group_name: string;
  group_avatar_url: string;
  group_gym_id: string | null;
  gym_name: string;
  member_count: number;
  participants: { user_id: string; username: string; display_name: string; avatar_url: string; role: string }[];
  /** The non-staff participant in a member/client DM — the gym's counterpart. */
  audience_member?: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  } | null;
  last_message: string;
  last_message_at: string | null;
  unread_count: number;
  is_staff_view?: boolean;
}

export interface GymInboxMessage {
  id: string;
  conversation: string;
  sender: string;
  sender_display: string;
  sender_avatar: string;
  sender_username: string;
  message_type: string;
  body: string;
  created_at: string;
  is_read: boolean;
  is_gym?: boolean;
}

const gymInboxApi = {
  list: (slug: string) =>
    apiClient.get<ApiResponse<{ conversations: GymInboxConversation[] }>>(`/gyms/${slug}/inbox/`).then((r) => r.data.data?.conversations ?? []),

  open: (slug: string, payload: { audience?: GymInboxAudience; participant_id?: string; body?: string }) =>
    apiClient.post<ApiResponse<GymInboxConversation>>(`/gyms/${slug}/inbox/`, payload).then((r) => r.data.data),

  messages: (slug: string, conversationId: string) =>
    apiClient.get<ApiResponse<{ messages: GymInboxMessage[] }>>(`/gyms/${slug}/inbox/${conversationId}/messages/`)
      .then((r) => r.data.data?.messages ?? []),

  send: (slug: string, conversationId: string, body: string) =>
    apiClient.post<ApiResponse<GymInboxMessage>>(`/gyms/${slug}/inbox/${conversationId}/messages/`, { body })
      .then((r) => r.data.data),
};

export { gymInboxApi };
