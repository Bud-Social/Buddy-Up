export type GymAccess = 'public' | 'private' | 'secret';
export type SubscriptionType = 'free' | 'members_free' | 'paid' | 'tiered';
export type GymRole = 'owner' | 'co_owner' | 'trainer' | 'moderator' | 'member' | 'guest';

export interface OwnerData {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
  role: string;
}

export interface GymCategory {
  id: string | number;
  name: string;
  display_name: string;
  icon: string;
  is_active: boolean;
}

export interface GymCategoryPricing {
  id?: string;
  category: string | number;
  category_name?: string;
  fee_per_day: number | null;
  fee_per_week: number | null;
  fee_per_month: number | null;
  fee_per_year: number | null;
  is_free: boolean;
}

export interface Gym {
  id: string;
  name: string;
  handle: string;
  description: string;
  logo_url: string;
  cover_url: string;
  category: string;
  categories: GymCategory[];
  access_type: GymAccess;
  subscription_type: SubscriptionType;
  monthly_fee_artifacts: Record<string, number> | null;
  join_fee_artifacts: Record<string, number> | null;
  category_pricing: GymCategoryPricing[];
  is_verified: boolean;
  is_reviews_enabled: boolean;
  is_donations_enabled: boolean;
  average_rating?: number;
  review_count?: number;
  recent_reviewers?: MemberData[];
  rules: string[];
  tags: string[];
  content_rating: 'general' | 'mature';
  member_count: number;
  active_today: number;
  location_city: string;
  location_country: string;
  delivery_modes?: string[];
  distance_km?: number | null;
  offers_online_coaching?: boolean;
  coaching_types?: string[];
  online_coaches_count?: number;
  online_coaches?: GymOnlineCoach[];
  followed_members?: GymFollowedMember[];
  followed_members_count?: number;
  location_summary?: GymLocationSummary;
  registration_status?: GymRegistrationStatus;
  gallery?: GymMediaItem[];
  owner_data: OwnerData[];
  membership_role: GymRole | null;
  is_member: boolean;
  created_at: string;
  updated_at: string;
}

export interface MemberData {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
  verification_status?: string;
}

export type GymRegistrationStatus =
  | 'unverified'
  | 'pending'
  | 'verified'
  | 'rejected'
  | 'suspended';

export interface GymFollowedMember {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
}

export interface GymLocationSummary {
  has_physical: boolean;
  venue_count: number;
  cities: string[];
  nearest_km: number | null;
}

export interface VenueLocation {
  id: string;
  name: string;
  address: string;
  city: string;
  country: string;
  latitude: number | string | null;
  longitude: number | string | null;
  instructions: string;
  is_primary: boolean;
  is_active: boolean;
  created_at?: string;
}

export interface GymMediaItem {
  id: string;
  kind: 'photo' | 'video';
  file_url: string;
  thumbnail_url: string;
  caption: string;
  created_at?: string;
}

export interface GymOnlineCoach {
  id: string;
  gym_id?: string;
  coach?: string;
  user_id?: string;
  username?: string;
  display_name?: string;
  avatar_url?: string;
  verification_status?: string;
  coach_data?: MemberData;
  specialties: string[];
  is_available: boolean;
  note: string;
  created_at?: string;
}

export interface GymEndorsement {
  id: string;
  gym_id: string;
  trainer: string;
  trainer_data: MemberData;
  note: string;
  is_active: boolean;
  created_at: string;
}

export interface GymRegistration {
  id: string;
  gym_id: string;
  legal_name: string;
  registration_number: string;
  country: string;
  tax_id: string;
  website: string;
  contact_email: string;
  contact_phone: string;
  status: GymRegistrationStatus;
  rejection_reason: string;
  submitted_at: string | null;
  reviewed_at: string | null;
  registration_documents?: Array<{
    id: string;
    document_type: string;
    status: string;
    rejection_reason: string;
    created_at: string;
  }>;
  is_verified?: boolean;
  can_submit?: boolean;
  created_at: string;
  updated_at: string;
}

export interface GymMembership {
  id: string;
  gym_id: string;
  member_id: string;
  role: GymRole;
  subscription_active: boolean;
  subscription_expires_at: string | null;
  member_data: MemberData;
  created_at: string;
}

/**
 * `GET /gyms/<handle>/partner-metrics/` — the operator's own numbers.
 *
 * Every field is declared with its own window rather than inheriting an
 * ambient "current period", so the UI never has to guess what a delta is
 * relative to. Mirrors `backend/apps/gyms/views.py:PartnerMetricsView`.
 */
export interface GymPartnerMetrics {
  active_members: number;
  new_members_30d?: number;
  churned_30d?: number;
  retention_rate_30d?: number;
  check_ins_30d: number;
  avg_check_ins_per_day_30d?: number;
  unique_attendees_30d: number;
  activation_rate_30d: number;
  scheduled_activities_30d: number;
  capacity_utilization_30d?: number;
  online_coaches?: number;
  offers_online_coaching?: boolean;
  registration_status?: GymRegistrationStatus;
  subscription_revenue?: number;
}

export interface JoinRequest {
  id: string;
  gym_id: string;
  requester: string;
  requester_data: MemberData;
  message: string;
  status: 'pending' | 'approved' | 'rejected';
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
}

export interface GymInvite {
  id: string;
  gym_id: string;
  invited_user: string;
  invited_user_data: MemberData;
  invited_by: string;
  invited_by_data: { user_id: string; username: string; display_name: string };
  status: 'pending' | 'accepted' | 'declined';
  created_at: string;
}

export interface CityResult {
  place_id: string;
  city: string;
  country: string;
  description: string;
}

export interface GymRoutinePost {
  id: string;
  gym_id: string;
  author: string;
  author_data: MemberData;
  title: string;
  content: string;
  activity_type: string;
  custom_activity_type: string;
  location_mode: string;
  start_time: string | null;
  end_time: string | null;
  recurrence?: string;
  recurrence_end_date?: string | null;
  max_slots: number;
  enrollment_count?: number;
  is_enrolled?: boolean;
  created_at: string;
}

export interface GymReview {
  id: string;
  gym_id: string;
  reviewer: string;
  reviewer_data: MemberData;
  rating: number;
  comment: string;
  reply_text: string;
  replied_by: string | null;
  replied_by_data: MemberData | null;
  replied_at: string | null;
  created_at: string;
}

export interface GymDonation {
  id: string;
  gym_id: string;
  donor: string;
  donor_data: MemberData;
  amount: string | number;
  message: string;
  created_at: string;
}

export interface GymMembershipException {
  id: string;
  gym_id: string;
  member: string;
  member_data: MemberData;
  discount_pct: number;
  reason: string;
  expires_at: string | null;
  is_active: boolean;
  created_at: string;
}

export interface MembershipCheckoutResult {
  role: GymRole;
  charged_artifacts: Record<string, number>;
  savings_artifacts: Record<string, number>;
  discount_code: string | null;
  subscription_expires_at: string;
}
