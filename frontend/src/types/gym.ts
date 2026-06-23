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

export interface Gym {
  id: string;
  name: string;
  handle: string;
  description: string;
  logo_url: string;
  cover_url: string;
  category: string;
  access_type: GymAccess;
  subscription_type: SubscriptionType;
  monthly_fee_artifacts: Record<string, number> | null;
  join_fee_artifacts: Record<string, number> | null;
  is_verified: boolean;
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
