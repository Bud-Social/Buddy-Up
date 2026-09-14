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
  min_selections?: number;
  max_selections?: number;
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

/** Creative-studio edits (IG/TikTok style) stored per media item. */
export interface PostEditMeta {
  filter?: string | null;
  filter_strength?: number;
  speed?: number;
  volume?: number;
  enhance?: boolean;
  voice_effect?: string;
  adjust?: {
    brightness?: number;
    contrast?: number;
    saturation?: number;
    vignette?: number;
  };
  aspect?: string;
  focus_y?: number;
  text_overlays?: Array<{
    id?: string;
    text: string;
    start_ms: number;
    end_ms: number;
    y: number;
    x?: number;
    rotation?: number;
    size: number;
    color: string;
    font?: string;
    effect?: 'none' | 'outline' | 'glow' | 'neon' | 'bubble' | 'highlight' | 'shadow';
    bg?: 'none' | 'pill' | 'block';
    bg_color?: string;
    animation?: 'none' | 'fade' | 'pop' | 'slide' | 'karaoke';
  }>;
  stickers?: Array<{
    id?: string;
    kind: 'emoji' | 'countdown' | 'mention';
    content: string;
    x: number;
    y: number;
    start_ms: number;
    end_ms: number;
    scale: number;
  }>;
  audio_tracks?: Array<{
    kind: 'sound' | 'voiceover' | 'url';
    url?: string;
    label?: string;
    volume: number;
    start_ms: number;
    duration_ms?: number;
    effect?: string;
    fade_in_ms?: number;
    fade_out_ms?: number;
    ducking?: boolean;
  }>;
  sound_placement?: {
    start_ms?: number;
    fade_in_ms?: number;
    fade_out_ms?: number;
  };
  captions_style?: {
    preset?: string;
    font?: string;
    size?: number;
    color?: string;
    bg?: 'none' | 'pill' | 'block';
    placement?: 'top' | 'center' | 'bottom';
  };
}

/** Structured media item on a post (create studio uploads / Cloudinary). */
export interface PostMedia {
  url: string;
  media_type: 'image' | 'video';
  width?: number | null;
  height?: number | null;
  duration_ms?: number | null;
  poster_url?: string | null;
  trim_start_ms?: number | null;
  trim_end_ms?: number | null;
  sound_id?: string | null;
  sound_volume?: number | null;
  sound_audio_url?: string | null;
  captions?: PostCaption[] | null;
  captions_vtt?: string | null;
  edit_meta?: PostEditMeta | null;
  alt_text?: string | null;
}

/** Timed caption segment (seconds → ms) rendered as an overlay on video. */
export interface PostCaption {
  start_ms: number;
  end_ms: number;
  text: string;
}

export interface Post {
  id: string;
  author_data: AuthorData;
  post_type: PostType;
  body: string;
  is_anonymous: boolean;
  media_urls: string[];
  /** Structured media (create studio). Falls back to media_urls when absent. */
  media?: PostMedia[] | null;
  captions?: PostCaption[] | null;
  captions_vtt?: string | null;
  sound_id?: string | null;
  comments_disabled?: boolean;
  tags: string[];
  workout_log_data: Record<string, unknown> | null;
  meal_data: Record<string, unknown> | null;
  progress_data: Record<string, unknown> | null;
  location_label: string;
  location_lat?: number | null;
  location_lng?: number | null;
  view_count: number;
  /** Number of times the post was shared (server may omit until implemented). */
  share_count?: number;
  /** Number of saves (server may omit until implemented). */
  save_count?: number;
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
    media?: PostMedia[] | null;
    captions?: PostCaption[] | null;
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
    repost_count?: number;
    view_count?: number;
    share_count?: number;
    save_count?: number;
    reaction_counts?: Record<string, number>;
    user_reaction?: string | null;
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

/** Per-post aggregates for the creator-insights endpoint. All counts are
 *  defensive: the backend may omit keys while it is being built in parallel. */
export interface CreatorInsightItem {
  post_id: string;
  views?: number;
  likes?: number;
  comments?: number;
  reposts?: number;
  saves?: number;
  shares?: number;
  created_at?: string;
  visibility?: string;
}
