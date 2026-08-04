import { useEffect, useRef, useCallback, useState } from 'react';
import { useAuthStore } from '@/store/authStore';

export interface ChatMessage {
  user_id: string;
  display_name: string;
  avatar_url: string;
  message: string;
  timestamp: number;
  gift?: {
    tx_id: string;
    artifact_type: string;
    quantity: number;
    sender_id: string;
    sender_name: string;
    total: number;
  };
  reply_data?: {
    message: string;
    sender_name: string;
    user_id: string;
  };
  priority?: boolean;
}

export interface Reaction {
  user_id: string;
  display_name: string;
  emoji: string;
  timestamp: number;
}

export interface CohostEvent {
  user_id: string;
  username?: string;
  display_name?: string;
  avatar_url?: string;
  action?: string;
}

export type GiftTotals = Record<string, number>;

export interface LiveWebSocketEvent {
  type: 'live_chat' | 'live_reaction' | 'live_viewer_count' | 'live_gift' | 'connected'
    | 'live_cohost_invite' | 'live_cohost_request' | 'live_cohost_response' | 'live_cohost_removed';
  data: any;
}

const WS_BASE = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8002';

export function useLiveWebSocket(liveId: string | undefined) {
  const wsRef = useRef<WebSocket | null>(null);
  const accessToken = useAuthStore((s) => s.accessToken);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout>>();
  const retryCountRef = useRef(0);
  const maxRetries = 10;
  const [isConnected, setIsConnected] = useState(false);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [reactions, setReactions] = useState<Reaction[]>([]);
  const [viewerCount, setViewerCount] = useState(0);
  const [giftTotals, setGiftTotals] = useState<GiftTotals>({});
  const [cohostEvents, setCohostEvents] = useState<CohostEvent[]>([]);

  const connect = useCallback(() => {
    if (!liveId || !accessToken) return;

    const url = `${WS_BASE}/ws/live/${liveId}/?token=${accessToken}`;
    const ws = new WebSocket(url);
    wsRef.current = ws;

    ws.onopen = () => {
      setIsConnected(true);
      retryCountRef.current = 0;
    };

    ws.onmessage = (event) => {
      try {
        const msg: LiveWebSocketEvent = JSON.parse(event.data);

        switch (msg.type) {
          case 'connected':
            if ('viewer_count' in msg.data) {
              setViewerCount((msg.data as { viewer_count: number }).viewer_count);
            }
            break;

          case 'live_chat':
            setChatMessages((prev) => [...prev.slice(-99), msg.data as ChatMessage]);
            break;

          case 'live_reaction':
            if (msg.data && 'emoji' in msg.data) {
              setReactions((prev) => [...prev.slice(-19), msg.data as Reaction]);
              setTimeout(() => {
                setReactions((prev) => prev.filter((r) => r.timestamp !== (msg.data as Reaction).timestamp));
              }, 3000);
            }
            break;

          case 'live_viewer_count':
            if ('count' in msg.data) {
              setViewerCount((msg.data as { count: number }).count);
            }
            break;

          case 'live_gift':
            if (msg.data && 'totals' in msg.data) {
              setGiftTotals((msg.data as { totals: GiftTotals }).totals);
            }
            break;

          case 'live_cohost_invite':
          case 'live_cohost_request':
          case 'live_cohost_response':
          case 'live_cohost_removed':
            setCohostEvents((prev) => [...prev.slice(-19), { ...(msg.data as CohostEvent), action: msg.type.replace('live_cohost_', '') }]);
            break;
        }
      } catch {}
    };

    ws.onclose = () => {
      setIsConnected(false);
      if (wsRef.current !== ws) return;
      retryCountRef.current += 1;
      if (retryCountRef.current <= maxRetries) {
        const delay = Math.min(1000 * Math.pow(2, retryCountRef.current - 1), 30000);
        reconnectTimeoutRef.current = setTimeout(connect, delay);
      }
    };

    ws.onerror = () => {
      ws.close();
    };
  }, [liveId, accessToken]);

  useEffect(() => {
    connect();
    return () => {
      clearTimeout(reconnectTimeoutRef.current);
      wsRef.current?.close();
      wsRef.current = null;
    };
  }, [connect]);

  const sendChat = useCallback((message: string, gift?: { artifact_type: string; quantity: number }, replyTo?: ChatMessage | null) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      const data: Record<string, unknown> = { message };
      if (gift) data.gift = gift;
      if (replyTo) {
        data.reply_to = {
          message: replyTo.message,
          sender_name: replyTo.display_name,
          user_id: replyTo.user_id,
        };
      }
      wsRef.current.send(JSON.stringify({ type: 'chat', data }));
    }
  }, []);

  const sendReaction = useCallback((emoji: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'reaction',
        data: { emoji },
      }));
    }
  }, []);

  const sendGift = useCallback((artifact_type: string, quantity: number) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'gift',
        data: { artifact_type, quantity },
      }));
    }
  }, []);

  const sendCohostEvent = useCallback((type: 'cohost_invite' | 'cohost_request' | 'cohost_response' | 'cohost_removed', data: Record<string, unknown>) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({ type, data }));
    }
  }, []);

  return {
    isConnected,
    chatMessages,
    reactions,
    viewerCount,
    giftTotals,
    cohostEvents,
    sendChat,
    sendReaction,
    sendGift,
    sendCohostEvent,
  };
}
