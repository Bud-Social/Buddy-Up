import { create } from 'zustand';

interface Notification { id: string; type: string; message: string; read: boolean; created_at: string; }

interface NotificationState {
  notifications: Notification[]; unreadCount: number;
  setNotifications: (n: Notification[]) => void;
  addNotification: (n: Notification) => void;
  markRead: (id: string) => void;
  markAllRead: () => void;
}

export const useNotificationStore = create<NotificationState>((set) => ({
  notifications: [], unreadCount: 0,
  setNotifications: (n) => set({ notifications: n, unreadCount: n.filter((x) => !x.read).length }),
  addNotification: (n) => set((s) => ({ notifications: [n, ...s.notifications], unreadCount: s.unreadCount + 1 })),
  markRead: (id) => set((s) => ({
    notifications: s.notifications.map((n) => n.id === id ? { ...n, read: true } : n),
    unreadCount: Math.max(0, s.unreadCount - 1),
  })),
  markAllRead: () => set((s) => ({ notifications: s.notifications.map((n) => ({ ...n, read: true })), unreadCount: 0 })),
}));
