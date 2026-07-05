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
  priority?: boolean;
}

export interface Reaction {
  user_id: string;
  display_name: string;
  emoji: string;
  timestamp: number;
}

export type GiftTotals = Record<string, number>;

export interface LiveWebSocketEvent {
  type: 'live_chat' | 'live_reaction' | 'live_viewer_count' | 'live_gift' | 'connected';
  data: ChatMessage | Reaction | { count: number } | { user_id: string; live_id: string; viewer_count: number } | { type: string; gift: { tx_id: string; artifact_type: string; quantity: number; sender_id: string; sender_name: string; total: number }; totals: GiftTotals };
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

  const sendChat = useCallback((message: string, gift?: { artifact_type: string; quantity: number }) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      const data: Record<string, unknown> = { message };
      if (gift) data.gift = gift;
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

  return {
    isConnected,
    chatMessages,
    reactions,
    viewerCount,
    giftTotals,
    sendChat,
    sendReaction,
    sendGift,
  };
}
