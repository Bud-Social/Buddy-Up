export type PostType = 'text' | 'photo' | 'short_video' | 'long_video' | 'workout_log' | 'meal' | 'progress' | 'moment' | 'poll';
export type Visibility = 'public' | 'buddies' | 'gym_members' | 'private';
export type ReactionType = 'pump' | 'fire' | 'respect' | 'grind' | 'lets_go' | 'haha' | 'too_hard';

export interface PollOption {
  id: string;
  text: string;
  order: number;
  vote_count: number;
  user_voted: boolean;
}

export interface Poll {
  id: string;
  question: string;
  closes_at: string | null;
  allow_multiple: boolean;
  total_votes: number;
  is_closed: boolean;
  options: PollOption[];
  user_voted_option_ids: string[];
}

export interface AuthorData {
  user_id?: string;
  username: string;
  display_name: string;
  avatar_url: string;
  verification_status?: string;
}

export interface Post {
  id: string;
  author_data: AuthorData;
  post_type: PostType;
  body: string;
  is_anonymous: boolean;
  media_urls: string[];
  tags: string[];
  workout_log_data: Record<string, unknown> | null;
  meal_data: Record<string, unknown> | null;
  progress_data: Record<string, unknown> | null;
  location_label: string;
  location_lat?: number | null;
  location_lng?: number | null;
  view_count: number;
  reaction_counts: Record<string, number>;
  user_reaction: string | null;
  comment_count: number;
  repost_count: number;
  is_repost: boolean;
  is_reposted_by_me: boolean;
  original_post_id: string | null;
  quote_body: string;
  is_saved: boolean;
  is_pinned?: boolean;
  visibility: string;
  moderation_status: string;
  ai_analysis?: Record<string, unknown>;
  gym_tag_id: string | null;
  content_rating: 'general' | 'mature';
  created_at: string;
  updated_at: string;
  poll?: Poll | null;
  gym_tag_name?: string | null;
  original_post_data?: {
    id: string;
    author_data: AuthorData;
    body: string;
    media_urls: string[];
    created_at: string;
    post_type: string;
    location_label?: string;
    location_lat?: number | null;
    location_lng?: number | null;
    quote_body?: string;
    workout_log_data?: Record<string, unknown> | null;
    meal_data?: Record<string, unknown> | null;
    progress_data?: Record<string, unknown> | null;
    poll?: Poll | null;
    comment_count?: number;
    gym_tag_name?: string | null;
  } | null;
}

export interface Comment {
  id: string;
  post_id: string;
  author_data: AuthorData;
  author_id: string;
  body: string;
  parent_id: string | null;
  is_anonymous: boolean;
  reply_count: number;
  reaction_counts: Record<string, number>;
  user_reaction: string | null;
  created_at: string;
}
