import { apiClient } from './client';
import type { ApiResponse } from '@/types';
import type { MarketplaceEvent } from './marketplace';
import type { BuddyLive } from '@/types/live';
import type { GymRoutinePost } from '@/types/gym';

export type CommunityEvent = MarketplaceEvent;
export type CommunityLive = BuddyLive;
export type CommunitySchedule = GymRoutinePost;

export interface CommunityEventInput {
  title: string;
  description?: string;
  event_type?: 'in_person' | 'online' | 'hybrid';
  location?: string;
  online_url?: string;
  start_datetime: string;
  end_datetime: string;
  timezone?: string;
  capacity?: number;
  is_free?: boolean;
  cover_image_url?: string;
  tags?: string[];
  category?: string;
}

export interface CommunityLiveInput {
  title: string;
  live_type?: string;
  category?: string;
  access?: string;
  scheduled_for?: string | null;
}

export interface CommunityScheduleInput {
  title?: string;
  content?: string;
  activity_type?: string;
  custom_activity_type?: string;
  location_mode?: string;
  start_time?: string | null;
  end_time?: string | null;
  recurrence?: string;
  recurrence_end_date?: string | null;
  recurrence_days?: number[];
  max_slots?: number;
  timezone?: string;
}

export interface ParticipantData {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
  verification_status: string;
  role: string;
}

export interface Conversation {
  id: string;
  is_group: boolean;
  is_community?: boolean;
  group_name: string;
  group_avatar_url: string;
  cover_url?: string;
  group_gym_id: string | null;
  member_count?: number;
  description?: string;
  post_count?: number;
  sub_channel: string;
  call_in_progress: boolean;
  participants_data: ParticipantData[];
  unread_count: number;
  last_message: {
    body: string;
    message_type: string;
    media_url: string;
    sender_name: string;
  } | null;
  last_message_at: string;
  created_at: string;
  /** How this conversation came about. A 'discovery' DM can be promoted to a buddy relationship. */
  origin?: 'direct' | 'discovery' | 'buddy' | 'group' | 'community';
  promoted_at?: string | null;
  /** True while the viewer may still turn this DM into a buddy relationship. */
  promotable?: boolean;
  promotion_status?: 'pending' | 'accepted' | 'declined' | null;
  /**
   * The ConversationPromotion id — non-null whenever a promotion row exists. This is
   * the id the responder posts to `/promotions/<id>/respond/`.
   */
  promotion_id: string | null;
  /**
   * The user_id of whoever asked for the promotion, or null when there is no
   * promotion. On a pending request this is the only thing that separates the
   * requester from the responder: the requester sees their own id here and keeps
   * just the pending chip, the responder gets Accept/Decline. The respond endpoint
   * stays the authority and 403s the requester if they try anyway.
   */
  promotion_requested_by: string | null;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  message_type: string;
  body: string;
  media_url: string;
  media_mime: string;
  file_name: string;
  reply_to_id: string | null;
  metadata: Record<string, unknown>;
  is_read: boolean;
  deleted_for: string[];
  /** View-once media: the recipient may open the payload exactly once. */
  view_once?: boolean;
  view_once_opened_at?: string | null;
  sender_data: ParticipantData;
  reply_data: {
    id: string;
    body: string;
    sender_name: string;
    message_type: string;
    media_url: string;
  } | null;
  reactions: Record<string, number>;
  created_at: string;
}

export interface ConversationPromotion {
  id: string;
  conversation_id: string;
  status: 'pending' | 'accepted' | 'declined';
  /** Only the promote endpoint echoes this, and only ever the caller's own id. */
  requested_by?: string | null;
  origin?: string;
  promoted_at?: string | null;
}

export interface CallLog {
  id: string;
  conversation_id: string;
  call_type: 'audio' | 'video';
  status: string;
  duration_seconds: number;
  caller_data: { username: string; display_name: string; avatar_url: string };
  callee_data: { username: string; display_name: string; avatar_url: string };
  created_at: string;
  ended_at: string | null;
}

export interface CallParticipantInfo {
  user_id: string;
  display_name: string;
  username: string;
  avatar_url: string;
  joined_at: string | null;
}

export interface StoryReel {
  user: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
    verification_status?: string;
  };
  stories: Array<{
    id: string;
    body: string;
    media_urls: string[];
    visibility: string;
    created_at: string;
  }>;
  latest_at: string | null;
}

export interface CallHistoryEntry {
  id: string;
  conversation_id: string;
  conversation_label: string;
  counterpart_name: string;
  counterpart_username: string;
  counterpart_avatar_url: string;
  call_type: string;
  status: string;
  duration_seconds: number;
  is_outgoing: boolean;
  active_call: { session_id: string; call_type: string; status: string } | null;
  created_at: string;
}

export interface CallSessionCredentials {
  session_id: string;
  status: string;
  call_type: 'audio' | 'video';
  livekit: {
    url: string;
    room: string;
    token: string;
    identity: string;
  };
  participants: CallParticipantInfo[];
  conversation?: {
    id: string;
    is_group: boolean;
    is_community?: boolean;
    group_name: string;
    group_avatar_url: string;
  };
}

export interface LinkPreviewData {
  url: string;
  title: string;
  description: string;
  image: string;
  domain: string;
}

export type CommunityRole = 'owner' | 'admin' | 'member';

export interface CommunityMember {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
  verification_status: string;
  role: CommunityRole;
  created_at: string;
}

export interface CommunityPostComment {
  id: string;
  post_id: string;
  body: string;
  reply_to_id: string | null;
  reply_count: number;
  author_data: { user_id: string; username: string; display_name: string; avatar_url: string };
  reaction_counts?: Record<string, number>;
  user_reaction?: string | null;
  created_at: string;
}

export interface CommunityPost {
  id: string;
  conversation_id: string;
  author_id: string;
  body: string;
  media_url: string;
  media_mime: string;
  is_pinned: boolean;
  like_count: number;
  comment_count: number;
  author_data: {
    user_id: string;
    username: string;
    display_name: string;
    avatar_url: string;
    role: string;
  };
  is_liked: boolean;
  comments: CommunityPostComment[] | null;
  created_at: string;
}

export interface Community extends Conversation {
  is_community: boolean;
  description: string;
  cover_url: string;
  invite_code: string;
  is_public: boolean;
  membership_role: CommunityRole | null;
  members?: CommunityMember[];
  member_count?: number;
  my_role?: CommunityRole | null;
  role?: CommunityRole | null;
}

export interface CommunityListData {
  mine: Community[];
  discover: Community[];
}

export const messagingApi = {
  /**
   * The conversations in one inbox.
   *
   * Buddy chats have their own inbox, so they never mix with the rest of
   * the messaging.
   */
  getConversations: (kind: 'main' | 'buddy' | 'communities' = 'main') =>
    apiClient.get<ApiResponse<Conversation[]>>('/messaging/conversations/', { params: { kind } }).then((r) => r.data),

  /**
   * Start (or reuse) a conversation. Pass `origin: 'discovery'` for threads opened
   * from the Find-a-Buddy surfaces so they are tagged as promotable buddy chats.
   */
  startConversation: (participants: string[], groupName?: string, origin?: 'direct' | 'discovery') =>
    apiClient
      .post<ApiResponse<Conversation>>('/messaging/conversations/start/', {
        participants,
        group_name: groupName,
        ...(origin ? { origin } : {}),
      })
      .then((r) => r.data),

  getConversation: (id: string) =>
    apiClient.get<ApiResponse<Conversation>>(`/messaging/conversations/${id}/`).then((r) => r.data),

  /** Ask the other participant to make this DM a buddy relationship (pending until they accept). */
  promoteConversation: (id: string) =>
    apiClient.post<ApiResponse<ConversationPromotion>>(`/messaging/conversations/${id}/promote/`).then((r) => r.data),

  /** Only the participant who did NOT request the promotion may respond. */
  respondToPromotion: (promotionId: string, accept: boolean) =>
    apiClient
      .post<ApiResponse<ConversationPromotion>>(`/messaging/conversations/promotions/${promotionId}/respond/`, { accept })
      .then((r) => r.data),

  getMessages: (conversationId: string, before?: string, attachmentType?: string) =>
    apiClient
      .get<ApiResponse<Message[]>>(`/messaging/conversations/${conversationId}/messages/`, {
        params: { ...(before ? { before } : {}), ...(attachmentType ? { attachment_type: attachmentType } : {}) },
      })
      .then((r) => r.data),

  sendMessage: (
    conversationId: string,
    data: {
      message_type?: string;
      body?: string;
      media_url?: string;
      media_mime?: string;
      file_name?: string;
      reply_to_id?: string;
      metadata?: Record<string, unknown>;
      view_once?: boolean;
    },
  ) =>
    apiClient
      .post<ApiResponse<Message>>(`/messaging/conversations/${conversationId}/messages/`, data)
      .then((r) => r.data),

  markRead: (conversationId: string) =>
    apiClient
      .post<ApiResponse<{ marked_read: number }>>(`/messaging/conversations/${conversationId}/read/`)
      .then((r) => r.data),

  reactToMessage: (messageId: string, emoji: string) =>
    apiClient
      .post<ApiResponse<{ reactions: Record<string, number> }>>(`/messaging/messages/${messageId}/react/`, { emoji })
      .then((r) => r.data),

  deleteMessage: (messageId: string, forEveryone = false) =>
    apiClient
      .delete(`/messaging/messages/${messageId}/delete/`, { data: { for_everyone: forEveryone } })
      .then((r) => r.data),

  uploadAttachment: (file: File) => {
    const form = new FormData();
    form.append('file', file);
    return apiClient
      .post<ApiResponse<{ url: string; mime: string; file_name: string; size: number }>>(
        '/messaging/upload/',
        form,
        { headers: { 'Content-Type': 'multipart/form-data' } },
      )
      .then((r) => r.data);
  },

  getCallLogs: (conversationId: string) =>
    apiClient
      .get<ApiResponse<CallLog[]>>(`/messaging/conversations/${conversationId}/calls/`)
      .then((r) => r.data),

  logCall: (
    conversationId: string,
    data: {
      callee_id: string;
      call_type: 'audio' | 'video';
      status: string;
      duration_seconds?: number;
    },
  ) =>
    apiClient
      .post<ApiResponse<CallLog>>(`/messaging/conversations/${conversationId}/calls/`, data)
      .then((r) => r.data),

  /** Mark a view-once message as opened by the recipient. */
  markViewOnceOpened: (messageId: string) =>
    apiClient
      .post<ApiResponse<{ view_once: boolean; view_once_opened_at: string | null }>>(
        `/messaging/messages/${messageId}/view-once/`,
      )
      .then((r) => r.data),

  // ── Multi-party LiveKit calls ────────────────────────────────────────────
  startOrJoinCall: (conversationId: string, callType: 'audio' | 'video') =>
    apiClient
      .post<ApiResponse<CallSessionCredentials>>(`/messaging/conversations/${conversationId}/calls/session/`, {
        call_type: callType,
      })
      .then((r) => r.data),

  getActiveCallSession: (conversationId: string) =>
    apiClient
      .get<ApiResponse<CallSessionCredentials | null>>(`/messaging/conversations/${conversationId}/calls/session/`)
      .then((r) => r.data),

  getCallHistory: () =>
    apiClient
      .get<ApiResponse<CallHistoryEntry[]>>('/messaging/calls/')
      .then((r) => r.data),

  getStories: () =>
    apiClient
      .get<ApiResponse<StoryReel[]>>('/messaging/stories/')
      .then((r) => r.data),

  leaveCall: (conversationId: string) =>
    apiClient
      .delete<ApiResponse<{ ended: boolean }>>(`/messaging/conversations/${conversationId}/calls/session/`)
      .then((r) => r.data),

  addCallBuddy: (conversationId: string, buddyUserId: string) =>
    apiClient
      .post<ApiResponse<{ participants: Array<{ user_id: string; display_name: string; username: string; avatar_url: string }> }>>(
        `/messaging/conversations/${conversationId}/calls/session/add/`,
        { buddy_user_id: buddyUserId },
      )
      .then((r) => r.data),

  switchCallToVideo: (conversationId: string, accept: boolean) =>
    apiClient
      .post<ApiResponse<{ call_type: string; accepted: boolean }>>(
        `/messaging/conversations/${conversationId}/calls/session/switch/`,
        { accept },
      )
      .then((r) => r.data),

  forwardMessage: (messageId: string, targetConversationId: string) =>
    apiClient
      .post<ApiResponse<Message>>(`/messaging/messages/${messageId}/forward/`, { conversation_id: targetConversationId })
      .then((r) => r.data),

  getServeFileUrl: (messageId: string) => `/messaging/messages/${messageId}/serve/`,

  linkPreview: (url: string) =>
    apiClient
      .post<ApiResponse<LinkPreviewData>>('/messaging/link-preview/', { url })
      .then((r) => r.data.data),

  // ── Communities ────────────────────────────────────────────────────────
  getCommunities: () =>
    apiClient.get<ApiResponse<CommunityListData>>('/messaging/communities/').then((r) => r.data.data),

  createCommunity: (data: { name: string; description?: string; cover_url?: string; group_avatar_url?: string; is_public?: boolean }) =>
    apiClient.post<ApiResponse<Community>>('/messaging/communities/', data).then((r) => r.data.data),

  getCommunity: (id: string) =>
    apiClient.get<ApiResponse<Community>>(`/messaging/communities/${id}/`).then((r) => r.data.data),

  updateCommunity: (
    id: string,
    data: Partial<{ name: string; description: string; cover_url: string; group_avatar_url: string; is_public: boolean }>,
  ) => apiClient.patch<ApiResponse<Community>>(`/messaging/communities/${id}/`, data).then((r) => r.data.data),

  joinCommunityByCode: (inviteCode: string) =>
    apiClient.post<ApiResponse<Community>>('/messaging/communities/join/', { invite_code: inviteCode }).then((r) => r.data.data),

  joinCommunity: (id: string, inviteCode?: string) =>
    apiClient.post<ApiResponse<Community>>(`/messaging/communities/${id}/join/`, { invite_code: inviteCode }).then((r) => r.data.data),

  leaveCommunity: (id: string) =>
    apiClient.post(`/messaging/communities/${id}/leave/`).then((r) => r.data),

  addCommunityMembers: (id: string, userIds: string[]) =>
    apiClient.post(`/messaging/communities/${id}/members/`, { user_ids: userIds }).then((r) => r.data),

  removeCommunityMember: (id: string, userId: string) =>
    apiClient.delete(`/messaging/communities/${id}/members/${userId}/`).then((r) => r.data),

  setCommunityRole: (id: string, userId: string, role: 'admin' | 'member') =>
    apiClient.patch(`/messaging/communities/${id}/members/${userId}/role/`, { role }).then((r) => r.data),

  transferCommunityOwnership: (id: string, userId: string) =>
    apiClient.post(`/messaging/communities/${id}/transfer/`, { user_id: userId }).then((r) => r.data),

  rotateInviteCode: (id: string) =>
    apiClient.post<ApiResponse<{ invite_code: string }>>(`/messaging/communities/${id}/invite/`).then((r) => r.data.data),

  getCommunityPosts: (id: string, params?: { author_id?: string; pinned?: boolean }) =>
    apiClient
      .get<ApiResponse<CommunityPost[]>>(`/messaging/communities/${id}/posts/`, { params })
      .then((r) => r.data.data),

  createCommunityPost: (id: string, data: { body?: string; media_url?: string; is_pinned?: boolean }) =>
    apiClient.post<ApiResponse<CommunityPost>>(`/messaging/communities/${id}/posts/`, data).then((r) => r.data.data),

  getCommunityPost: (id: string, postId: string) =>
    apiClient.get<ApiResponse<CommunityPost>>(`/messaging/communities/${id}/posts/${postId}/`).then((r) => r.data.data),

  updateCommunityPost: (id: string, postId: string, data: Partial<{ body: string; is_pinned: boolean }>) =>
    apiClient.patch<ApiResponse<CommunityPost>>(`/messaging/communities/${id}/posts/${postId}/`, data).then((r) => r.data.data),

  deleteCommunityPost: (id: string, postId: string) =>
    apiClient.delete(`/messaging/communities/${id}/posts/${postId}/`).then((r) => r.data),

  togglePostLike: (id: string, postId: string) =>
    apiClient
      .post<ApiResponse<{ is_liked: boolean; like_count: number }>>(`/messaging/communities/${id}/posts/${postId}/like/`)
      .then((r) => r.data.data),


  repostCommunityPost: (id: string, postId: string) =>
    apiClient
      .post<ApiResponse<{ is_reposted: boolean; repost_count: number }>>(`/messaging/communities/${id}/posts/${postId}/repost/`)
      .then((r) => r.data.data),

  saveCommunityPost: (id: string, postId: string) =>
    apiClient
      .post<ApiResponse<{ is_saved: boolean; save_count: number }>>(`/messaging/communities/${id}/posts/${postId}/save/`)
      .then((r) => r.data.data),

  reactCommunityPost: (id: string, postId: string, reactionType: string) =>
    apiClient
      .post<ApiResponse<{ is_reacted: boolean; reaction_count: number }>>(`/messaging/communities/${id}/posts/${postId}/react/`, {
        reaction_type: reactionType,
      })
      .then((r) => r.data.data),

  shareCommunityPost: (id: string, postId: string) =>
    apiClient
      .post<ApiResponse<{ shared: boolean; share_count: number }>>(`/messaging/communities/${id}/posts/${postId}/share/`)
      .then((r) => r.data.data),
  getPostShares: (id: string, postId: string) =>
    apiClient
      .get<ApiResponse<{ sharers: any[] }>>(`/messaging/communities/${id}/posts/${postId}/shares/`)
      .then((r) => r.data.data?.sharers || []),
  downloadCommunityPostMedia: (id: string, postId: string) =>
    apiClient.get(`/messaging/communities/${id}/posts/${postId}/media/`, {
      responseType: 'blob',
    }),
  /** Compose a branded video card for a community post (whole clip + audio). */
  createCommunityVideoShareCard: (id: string, postId: string, layers: {
    base: Blob;
    over: Blob;
    rect: string;
    radius: number;
  }) => {
    const form = new FormData();
    form.append('base', layers.base, 'base.png');
    form.append('over', layers.over, 'over.png');
    form.append('rect', layers.rect);
    form.append('radius', String(layers.radius));
    return apiClient
      .post<ApiResponse<{ job_id: string; status: string }>>(
        `/messaging/communities/${id}/posts/${postId}/video-card/`,
        form,
        { headers: { 'Content-Type': 'multipart/form-data' }, timeout: 120000 },
      )
      .then((r) => r.data.data);
  },
  /** Poll a community video card job. Resolves with the rendered MP4 once ready. */
  getCommunityVideoShareCard: (id: string, postId: string, jobId: string) =>
    apiClient
      .get(`/messaging/communities/${id}/posts/${postId}/video-card/${jobId}/`, {
        responseType: 'blob',
        timeout: 120000,
      })
      .then((r) => r.data as Blob),
  viewCommunityPost: (communityId: string, postId: string) =>
    apiClient.post(`/messaging/communities/${communityId}/posts/${postId}/view/`).then((r) => r.data.data),
  getPostComments: (id: string, postId: string) =>
    apiClient
      .get<ApiResponse<CommunityPostComment[]>>(`/messaging/communities/${id}/posts/${postId}/comments/`)
      .then((r) => r.data.data),

  addPostComment: (
    id: string,
    postId: string,
    body: string,
    replyToId?: string,
    media?: { media_type?: string; media_url?: string; sticker_pack?: string },
  ) =>
    apiClient
      .post<ApiResponse<CommunityPostComment>>(`/messaging/communities/${id}/posts/${postId}/comments/`, {
        body,
        reply_to_id: replyToId,
        ...media,
      })
      .then((r) => r.data.data),

  deletePostComment: (id: string, postId: string, commentId: string) =>
    apiClient.delete(`/messaging/communities/${id}/posts/${postId}/comments/${commentId}/`).then((r) => r.data),

  toggleCommunityCommentLike: (id: string, postId: string, commentId: string) =>
    apiClient
      .post<ApiResponse<{ is_liked: boolean; like_count: number; reaction_counts: Record<string, number>; user_reaction: string | null }>>(
        `/messaging/communities/${id}/posts/${postId}/comments/${commentId}/like/`,
      )
      .then((r) => r.data.data),

  // ── Community activities (events / lives / schedules) ─────────────────
  // Readable by members and by anyone viewing a public community; only admins
  // may create or remove. The server owns that rule, the page just hides the
  // controls for people it would refuse.
  getCommunityEvents: (communityId: string) =>
    apiClient
      .get<ApiResponse<CommunityEvent[]>>(`/messaging/communities/${communityId}/events/`)
      .then((r) => r.data.data),

  createCommunityEvent: (communityId: string, data: CommunityEventInput) =>
    apiClient
      .post<ApiResponse<CommunityEvent>>(`/messaging/communities/${communityId}/events/`, data)
      .then((r) => r.data.data),

  deleteCommunityEvent: (communityId: string, eventId: string) =>
    apiClient
      .delete(`/messaging/communities/${communityId}/events/${eventId}/`)
      .then((r) => r.data),

  getCommunityLives: (communityId: string) =>
    apiClient
      .get<ApiResponse<CommunityLive[]>>(`/messaging/communities/${communityId}/lives/`)
      .then((r) => r.data.data),

  createCommunityLive: (communityId: string, data: CommunityLiveInput) =>
    apiClient
      .post<ApiResponse<CommunityLive>>(`/messaging/communities/${communityId}/lives/`, data)
      .then((r) => r.data.data),

  deleteCommunityLive: (communityId: string, liveId: string) =>
    apiClient
      .delete(`/messaging/communities/${communityId}/lives/${liveId}/`)
      .then((r) => r.data),

  getCommunitySchedules: (communityId: string) =>
    apiClient
      .get<ApiResponse<CommunitySchedule[]>>(`/messaging/communities/${communityId}/schedules/`)
      .then((r) => r.data.data),

  createCommunitySchedule: (communityId: string, data: CommunityScheduleInput) =>
    apiClient
      .post<ApiResponse<CommunitySchedule>>(`/messaging/communities/${communityId}/schedules/`, data)
      .then((r) => r.data.data),

  deleteCommunitySchedule: (communityId: string, scheduleId: string) =>
    apiClient
      .delete(`/messaging/communities/${communityId}/schedules/${scheduleId}/`)
      .then((r) => r.data),
};
