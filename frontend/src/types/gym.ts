export type GymAccess = 'public' | 'private' | 'secret';
export type SubscriptionType = 'free' | 'members_free' | 'paid' | 'tiered';
export type GymRole = 'owner' | 'co_owner' | 'trainer' | 'moderator' | 'member' | 'guest';

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
  location_city: string;
  location_country: string;
  created_at: string;
}

export interface GymMembership {
  gym_id: string;
  role: GymRole;
  subscription_active: boolean;
  subscription_expires_at: string | null;
}
