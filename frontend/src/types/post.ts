export type PostType = 'text' | 'photo' | 'short_video' | 'long_video' | 'workout_log' | 'meal' | 'progress' | 'moment';
export type Visibility = 'public' | 'buddies' | 'gym_members' | 'private';
export type ReactionType = 'pump' | 'fire' | 'respect' | 'grind' | 'lets_go' | 'haha' | 'too_hard';

export interface Post {
  id: string;
  author: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
    verification_status: string;
  };
  post_type: PostType;
  body: string;
  is_anonymous: boolean;
  media_urls: string[];
  tags: string[];
  workout_log_data: Record<string, unknown> | null;
  meal_data: Record<string, unknown> | null;
  view_count: number;
  reaction_counts: Record<string, number>;
  comment_count: number;
  repost_count: number;
  is_repost: boolean;
  original_post_id: string | null;
  created_at: string;
}

export interface Comment {
  id: string;
  post_id: string;
  author: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  };
  body: string;
  parent_id: string | null;
  is_anonymous: boolean;
  created_at: string;
}
