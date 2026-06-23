import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface Conversation {
  id: string;
  is_group: boolean;
  group_name: string;
  group_gym_id: string | null;
  sub_channel: string;
  participants_data: { username: string; display_name: string; avatar_url: string }[];
  unread_count: number;
  last_message: { body: string; message_type: string; sender_name: string } | null;
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
  reply_to_id: string | null;
  metadata: Record<string, unknown>;
  is_read: boolean;
  sender_data: { username: string; display_name: string; avatar_url: string };
  reply_data: { id: string; body: string; sender_name: string } | null;
  reactions: Record<string, number>;
  created_at: string;
}

export const messagingApi = {
  getConversations: () =>
    apiClient.get<ApiResponse<Conversation[]>>('/messaging/conversations/').then((r) => r.data),

  startConversation: (participants: string[], group_name?: string) =>
    apiClient.post<ApiResponse<Conversation>>('/messaging/conversations/start/', { participants, group_name }).then((r) => r.data),

  getConversation: (id: string) =>
    apiClient.get<ApiResponse<Conversation>>(`/messaging/conversations/${id}/`).then((r) => r.data),

  getMessages: (conversationId: string, before?: string) =>
    apiClient.get<ApiResponse<Message[]>>(`/messaging/conversations/${conversationId}/messages/`, { params: before ? { before } : {} }).then((r) => r.data),

  sendMessage: (conversationId: string, data: { message_type?: string; body?: string; media_url?: string; reply_to_id?: string; metadata?: Record<string, unknown> }) =>
    apiClient.post<ApiResponse<Message>>(`/messaging/conversations/${conversationId}/messages/`, data).then((r) => r.data),

  markRead: (conversationId: string) =>
    apiClient.post<ApiResponse<{ marked_read: number }>>(`/messaging/conversations/${conversationId}/read/`).then((r) => r.data),

  reactToMessage: (messageId: string, emoji: string) =>
    apiClient.post<ApiResponse<null>>(`/messaging/messages/${messageId}/react/`, { emoji }).then((r) => r.data),
};
