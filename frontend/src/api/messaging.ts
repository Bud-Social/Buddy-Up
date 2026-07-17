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

export const messagingApi = {
  getConversations: () =>
    apiClient.get<ApiResponse<Conversation[]>>('/messaging/conversations/').then((r) => r.data),

  startConversation: (userIds: string[], groupName?: string) =>
    apiClient.post<ApiResponse<Conversation>>('/messaging/conversations/start/', { participants: userIds, group_name: groupName }).then((r) => r.data),

  getConversation: (id: string) =>
    apiClient.get<ApiResponse<Conversation>>(`/messaging/conversations/${id}/`).then((r) => r.data),

  getMessages: (conversationId: string, before?: string) =>
    apiClient
      .get<ApiResponse<Message[]>>(`/messaging/conversations/${conversationId}/messages/`, {
        params: before ? { before } : {},
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
};
