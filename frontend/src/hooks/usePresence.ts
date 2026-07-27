import { useState, useEffect, useCallback, useRef } from 'react';
import { apiClient } from '@/api/client';

export interface PresenceInfo {
  online: boolean;
  last_seen: string | null;
}

export function usePresence(userIds: string[], pollIntervalMs = 30_000) {
  const [presence, setPresence] = useState<Record<string, PresenceInfo>>({});
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const mountedRef = useRef(true);

  const fetchPresence = useCallback(async () => {
    if (!userIds.length) return;
    try {
      const res = await apiClient.post<{ data: Record<string, PresenceInfo> }>(
        '/profiles/presence/',
        { user_ids: userIds },
      );
      if (mountedRef.current) {
        setPresence(res.data.data || {});
      }
    } catch {
      // silently ignore
    }
  }, [userIds.join(',')]);

  useEffect(() => {
    mountedRef.current = true;
    fetchPresence();
    timerRef.current = setInterval(fetchPresence, pollIntervalMs);
    return () => {
      mountedRef.current = false;
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [fetchPresence, pollIntervalMs]);

  return presence;
}

export function formatLastSeen(lastSeen: string | null): string {
  if (!lastSeen) return '';
  const date = new Date(lastSeen);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMin = Math.floor(diffMs / 60_000);
  const diffHr = Math.floor(diffMs / 3_600_000);
  const diffDays = Math.floor(diffMs / 86_400_000);

  if (diffMin < 1) return 'Last seen just now';
  if (diffMin < 60) return `Last seen ${diffMin}m ago`;
  if (diffHr < 24) return `Last seen ${diffHr}h ago`;
  if (diffDays === 1) return `Last seen yesterday`;
  if (diffDays < 7) return `Last seen ${diffDays} days ago`;
  return `Last seen ${date.toLocaleDateString([], { month: 'short', day: 'numeric' })}`;
}
