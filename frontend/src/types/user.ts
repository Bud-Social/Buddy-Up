export type UserRole = 'user' | 'trainer' | 'practitioner';
export type VerificationStatus = 'none' | 'email' | 'id' | 'trainer' | 'practitioner';
export type PrivacyLevel = 'public' | 'private';
export type ContentRating = 'general' | 'mature';

export interface User {
  id: string;
  email: string;
  email_verified: boolean;
  phone?: string;
  phone_verified: boolean;
  is_adult: boolean;
  totp_enabled?: boolean;
  is_staff: boolean;
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
  external_link?: string;
  content_rating?: ContentRating;
  is_anonymous_posting?: boolean;
  is_buddy?: boolean;
  buddy_status?: string;
  is_following?: boolean;
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
