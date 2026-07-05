export type UserRole = 'user' | 'trainer' | 'practitioner';
export type VerificationStatus = 'none' | 'email' | 'id' | 'trainer' | 'practitioner';
export type PrivacyLevel = 'public' | 'private';

export interface User {
  id: string;
  email: string;
  email_verified: boolean;
  phone_verified: boolean;
  is_adult: boolean;
  totp_enabled?: boolean;
  created_at: string;
}

export interface Profile {
  user_id: string;
  username: string;
  display_name: string;
  bio: string;
  avatar_url: string;
  cover_url: string;
  pronouns: string;
  location_city: string;
  location_country: string;
  role: UserRole;
  verification_status: VerificationStatus;
  privacy_level: PrivacyLevel;
  streak_days: number;
  artifact_balance: Record<string, number>;
  buddy_count: number;
  following_count: number;
  follower_count: number;
  gym_count: number;
  post_count: number;
  show_active_status: boolean;
}
