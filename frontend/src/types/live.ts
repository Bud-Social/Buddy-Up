export type LiveType = 'open_sweat' | 'buddy_circle' | 'gym_live' | 'pt_session_live' | 'random_drop' | 'practitioner_live';
export type PipShape = 'circle' | 'rounded' | 'square' | 'rectangle' | 'fit' | 'fill';
export type LiveStatus = 'scheduled' | 'live' | 'ended';

export interface AgoraCredentials {
  app_id: string;
  channel: string;
  token: string | null;
}

export interface LiveKitCredentials {
  url: string;
  room: string;
  token: string;
  can_publish: boolean;
}

export interface LiveCredentials {
  agora: AgoraCredentials;
  livekit: LiveKitCredentials;
}

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
  mux_playback_id?: string;
  scheduled_for: string | null;
  is_recurring: boolean;
  equipment_list: string[];
  has_rsvped?: boolean;
  rsvp_count?: number;
  created_at: string;
}

export interface CoHost {
  user_id: string;
  display_name: string;
  avatar_url: string;
}

export interface GiftInfo {
  tx_id: string;
  artifact_type: string;
  quantity: number;
  sender_id: string;
  sender_name: string;
  total: number;
}

export interface AttendeeInfo {
  id: string;
  displayName: string;
  avatarUrl: string;
  isSpeaking: boolean;
  hasMicOn: boolean;
  hasVideoOn: boolean;
  isLocal: boolean;
  audioLevel: number;
}

export interface LiveRoomData {
  credentials: LiveCredentials;
  live_type: string;
  title: string;
  host_name: string;
  host_user_id: string;
  host_avatar: string;
  status: string;
  viewer_count?: number;
  co_hosts?: CoHost[];
}
