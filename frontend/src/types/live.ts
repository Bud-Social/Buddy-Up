export type LiveType = 'open_sweat' | 'buddy_circle' | 'gym_live' | 'pt_session_live' | 'random_drop' | 'practitioner_live';
export type LiveStatus = 'scheduled' | 'live' | 'ended';

export interface BuddyLive {
  id: string;
  host: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  };
  title: string;
  live_type: LiveType;
  category: string;
  access: string;
  artifact_fee: Record<string, number> | null;
  gym_id: string | null;
  status: LiveStatus;
  started_at: string | null;
  ended_at: string | null;
  viewer_peak: number;
  replay_url: string;
  replay_saved: boolean;
  scheduled_for: string | null;
  is_recurring: boolean;
  equipment_list: string[];
  created_at: string;
}
