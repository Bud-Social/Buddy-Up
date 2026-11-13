import { useEffect } from 'react';
import { wsManager } from '@/lib/wsManager';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { useCallStore } from '@/store/callStore';

export function useNotificationListener() {
  const profile = useAuthStore((s) => s.profile);
  const accessToken = useAuthStore((s) => s.accessToken);
  const addNotification = useNotificationStore((s) => s.addNotification);

  // The persisted store rehydrates on page load without touching the auth
  // setters — so wsManager never learns the token after a plain reload.
  // Pushing it here keeps the user socket alive across refreshes.
  useEffect(() => {
    wsManager.setAccessToken(accessToken);
  }, [accessToken]);

  useEffect(() => {
    if (!profile?.user_id) return;

    wsManager.connect(`ws/user/${profile.user_id}/`);

    const unsub = wsManager.onMessage(`ws/user/${profile.user_id}/`, (data: unknown) => {
      const payload = data as {
        type?: string;
        title?: string;
        body?: string;
        metadata?: Record<string, unknown>;
        data?: Record<string, unknown>;
      };

      // The user channel sends the notification payload *bare* — the
      // consumer forwards event['data'] only — so unwrap both shapes:
      // { type: 'event_notification', data: {...} } and bare { type: ..., ... }.
      const unwrapped =
        payload?.type === 'event_notification' && payload.data && typeof payload.data === 'object'
          ? (payload.data as Record<string, unknown>)
          : (payload as unknown as Record<string, unknown> | null);

      if (!unwrapped) return;

      if (unwrapped['type'] === 'incoming_call') {
        useCallStore.getState().setPendingCall(unwrapped as any);
        return;
      }
      if (unwrapped['type'] === 'call_ended') {
        useCallStore.getState().setRemoteEnd({
          conversation_id: String(unwrapped['conversation_id'] ?? ''),
          session_id: typeof unwrapped['session_id'] === 'string' ? (unwrapped['session_id'] as string) : undefined,
        });
        return;
      }

      const notif = {
        id: crypto.randomUUID(),
        notification_type: (unwrapped['title'] as string) || (unwrapped['type'] as string) || 'update',
        title: (unwrapped['title'] as string) || (unwrapped['type'] as string) || 'Update',
        body: (unwrapped['body'] as string) || '',
        metadata: (unwrapped['metadata'] as Record<string, unknown>) || {},
        is_read: false,
        created_at: new Date().toISOString(),
      };
      addNotification(notif);
    });

    return () => {
      unsub();
      wsManager.disconnect(`ws/user/${profile.user_id}/`);
    };
  }, [profile?.user_id, addNotification]);
}
