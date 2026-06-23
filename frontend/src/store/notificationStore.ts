import { create } from 'zustand';

export interface AppNotification {
  id: string;
  notification_type: string;
  title: string;
  body: string;
  metadata: Record<string, unknown>;
  is_read: boolean;
  created_at: string;
}

interface NotificationState {
  notifications: AppNotification[];
  unreadCount: number;
  setNotifications: (n: AppNotification[]) => void;
  addNotification: (n: AppNotification) => void;
  markRead: (id: string) => void;
  markAllRead: () => void;
}

export const useNotificationStore = create<NotificationState>((set) => ({
  notifications: [],
  unreadCount: 0,

  setNotifications: (n) =>
    set({
      notifications: n,
      unreadCount: n.filter((x) => !x.is_read).length,
    }),

  addNotification: (n) =>
    set((s) => ({
      notifications: [n, ...s.notifications],
      unreadCount: s.unreadCount + (n.is_read ? 0 : 1),
    })),

  markRead: (id) =>
    set((s) => ({
      notifications: s.notifications.map((n) => (n.id === id ? { ...n, is_read: true } : n)),
      unreadCount: Math.max(0, s.unreadCount - 1),
    })),

  markAllRead: () =>
    set((s) => ({
      notifications: s.notifications.map((n) => ({ ...n, is_read: true })),
      unreadCount: 0,
    })),
}));
