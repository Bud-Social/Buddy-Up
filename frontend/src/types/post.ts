export type PostType = 'text' | 'photo' | 'short_video' | 'long_video' | 'workout_log' | 'meal' | 'progress' | 'moment';
export type Visibility = 'public' | 'buddies' | 'gym_members' | 'private';
export type ReactionType = 'pump' | 'fire' | 'respect' | 'grind' | 'lets_go' | 'haha' | 'too_hard';

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
  view_count: number;
  reaction_counts: Record<string, number>;
  user_reaction: string | null;
  comment_count: number;
  repost_count: number;
  is_repost: boolean;
  original_post_id: string | null;
  quote_body: string;
  is_saved: boolean;
  visibility: string;
  moderation_status: string;
  gym_tag_id: string | null;
  created_at: string;
  updated_at: string;
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
