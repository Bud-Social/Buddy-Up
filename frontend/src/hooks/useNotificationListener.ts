import { useEffect } from 'react';
import { wsManager } from '@/lib/wsManager';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { useCallStore } from '@/store/callStore';

export function useNotificationListener() {
  const profile = useAuthStore((s) => s.profile);
  const addNotification = useNotificationStore((s) => s.addNotification);

  useEffect(() => {
    if (!profile?.user_id) return;

    wsManager.connect(`ws/user/${profile.user_id}/`);

    const unsub = wsManager.onMessage(`ws/user/${profile.user_id}/`, (data: unknown) => {
      const payload = data as { type?: string; title?: string; body?: string; metadata?: Record<string, unknown>; data?: Record<string, unknown> };

      if (payload?.type === 'event_notification') {
        const notifData = payload.data;
        
        if (notifData?.['type'] === 'incoming_call') {
          useCallStore.getState().setPendingCall(notifData as any);
        } else {
          const notif = {
            id: (payload as { id?: string }).id || crypto.randomUUID(),
            notification_type: payload.title || 'update',
            title: payload.title || 'New notification',
            body: payload.body || '',
            metadata: payload.metadata || {},
            is_read: false,
            created_at: new Date().toISOString(),
          };
          addNotification(notif);
        }
      }
    });

    return () => {
      unsub();
      wsManager.disconnect(`ws/user/${profile.user_id}/`);
    };
  }, [profile?.user_id]);
}
