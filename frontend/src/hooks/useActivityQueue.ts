import { useCallback, useEffect, useRef, useState } from 'react';
import { useAuthStore } from '@/store/authStore';
import {
  countQueuedActivities,
  flushActivityQueue,
  ACTIVITY_QUEUE_CHANGED,
  ACTIVITY_QUEUE_SYNCED,
} from '@/lib/offlineActivities';

const AUTO_SYNC_INTERVAL_MS = 60_000;

/**
 * Keeps the offline activity queue moving:
 * - on mount (the app just opened, possibly after being offline)
 * - when the browser reports it is back online
 * - when the tab becomes visible again
 * - on a slow interval while the app is open
 *
 * Pending counts are scoped to the signed-in account, so one person's queued
 * run can never be uploaded to whoever logs in next on the same device.
 */
export function useActivityQueue() {
  const ownerId = useAuthStore((s) => s.user?.id ?? null);
  const [pending, setPending] = useState(0);
  const [syncing, setSyncing] = useState(false);
  const [justSynced, setJustSynced] = useState(0);
  const syncingRef = useRef(false);

  const refresh = useCallback(async () => {
    const count = await countQueuedActivities(ownerId);
    setPending(count);
  }, [ownerId]);

  const syncNow = useCallback(async () => {
    if (!ownerId || syncingRef.current) return;
    if (typeof navigator !== 'undefined' && navigator.onLine === false) return;
    syncingRef.current = true;
    setSyncing(true);
    try {
      const result = await flushActivityQueue(ownerId);
      setPending(result.remaining);
      if (result.synced) {
        setJustSynced(result.synced);
        window.setTimeout(() => setJustSynced(0), 6000);
      }
    } finally {
      syncingRef.current = false;
      setSyncing(false);
    }
  }, [ownerId]);

  useEffect(() => {
    void refresh();
    void syncNow();

    const onQueueChanged = () => void refresh();
    const onOnline = () => void syncNow();
    const onSynced = () => void refresh();
    const onVisibility = () => {
      if (document.visibilityState === 'visible') {
        void refresh();
        void syncNow();
      }
    };

    window.addEventListener(ACTIVITY_QUEUE_CHANGED, onQueueChanged);
    window.addEventListener(ACTIVITY_QUEUE_SYNCED, onSynced);
    window.addEventListener('online', onOnline);
    document.addEventListener('visibilitychange', onVisibility);
    const interval = window.setInterval(() => void syncNow(), AUTO_SYNC_INTERVAL_MS);

    return () => {
      window.removeEventListener(ACTIVITY_QUEUE_CHANGED, onQueueChanged);
      window.removeEventListener(ACTIVITY_QUEUE_SYNCED, onSynced);
      window.removeEventListener('online', onOnline);
      document.removeEventListener('visibilitychange', onVisibility);
      window.clearInterval(interval);
    };
  }, [refresh, syncNow]);

  return { ownerId, pending, syncing, justSynced, syncNow, refresh };
}
