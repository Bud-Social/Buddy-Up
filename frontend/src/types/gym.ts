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
  member_count: number;
  active_today: number;
  location_city: string;
  location_country: string;
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

export interface GymSchedulePost {
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
