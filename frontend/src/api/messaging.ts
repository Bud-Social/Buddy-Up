import { apiClient } from './client';
import type { ApiResponse } from '@/types';

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
  group_gym_id: string | null;
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
}

export interface CommunityListData {
  mine: Community[];
  discover: Community[];
}

export const messagingApi = {
  getConversations: () =>
    apiClient.get<ApiResponse<Conversation[]>>('/messaging/conversations/').then((r) => r.data),

  startConversation: (participants: string[], groupName?: string) =>
    apiClient.post<ApiResponse<Conversation>>('/messaging/conversations/start/', { participants, group_name: groupName }).then((r) => r.data),

  getConversation: (id: string) =>
    apiClient.get<ApiResponse<Conversation>>(`/messaging/conversations/${id}/`).then((r) => r.data),

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

  leaveCall: (conversationId: string) =>
    apiClient
      .delete<ApiResponse<{ ended: boolean }>>(`/messaging/conversations/${conversationId}/calls/session/`)
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

  getPostComments: (id: string, postId: string) =>
    apiClient
      .get<ApiResponse<CommunityPostComment[]>>(`/messaging/communities/${id}/posts/${postId}/comments/`)
      .then((r) => r.data.data),

  addPostComment: (id: string, postId: string, body: string, replyToId?: string) =>
    apiClient
      .post<ApiResponse<CommunityPostComment>>(`/messaging/communities/${id}/posts/${postId}/comments/`, {
        body,
        reply_to_id: replyToId,
      })
      .then((r) => r.data.data),

  deletePostComment: (id: string, postId: string, commentId: string) =>
    apiClient.delete(`/messaging/communities/${id}/posts/${postId}/comments/${commentId}/`).then((r) => r.data),
};
