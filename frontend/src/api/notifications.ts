import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface Notification {
  id: string;
  notification_type: string;
  title: string;
  body: string;
  metadata: Record<string, unknown>;
  is_read: boolean;
  is_pinned?: boolean;
  created_at: string;
}

export interface NotificationPreferences {
  push_enabled: boolean;
  email_enabled: boolean;
  in_app_enabled: boolean;
  quiet_hours_start: string | null;
  quiet_hours_end: string | null;
  buddy_request_push: boolean;
  buddy_accepted_push: boolean;
  new_follower_push: boolean;
  comment_push: boolean;
  live_starting_push: boolean;
  session_reminder_push: boolean;
  streak_milestone_push: boolean;
  accountability_ping_push: boolean;
}

export const notificationsApi = {
  getList: (cursor?: string) =>
    apiClient.get<ApiResponse<Notification[]>>('/notifications/', { params: { cursor } }).then((r) => r.data),

  getUnread: (cursor?: string) =>
    apiClient.get<ApiResponse<Notification[]>>('/notifications/', { params: { cursor, unread: 'true' } }).then((r) => r.data),

  markAllRead: () =>
    apiClient.post<ApiResponse<{ marked_read: number }>>('/notifications/').then((r) => r.data),

  markRead: (notificationId: string) =>
    apiClient.post<ApiResponse<null>>(`/notifications/${notificationId}/read/`).then((r) => r.data),

  action: (
    notificationId: string,
    action: 'read' | 'unread' | 'pin' | 'unpin' | 'dismiss',
  ) =>
    apiClient
      .patch<ApiResponse<Partial<Notification>>>(`/notifications/${notificationId}/read/`, { action })
      .then((r) => r.data),

  getUnreadCount: () =>
    apiClient.get<ApiResponse<{ unread_count: number }>>('/notifications/unread-count/').then((r) => r.data),

  getPreferences: () =>
    apiClient.get<ApiResponse<NotificationPreferences>>('/notifications/preferences/').then((r) => r.data),

  updatePreferences: (data: Partial<NotificationPreferences>) =>
    apiClient.put<ApiResponse<NotificationPreferences>>('/notifications/preferences/', data).then((r) => r.data),
};
