/**
 * useChatSocket – manages a single WebSocket connection to a BuddyUp chat conversation.
 * Handles reconnection, event dispatching and typing debounce.
 */
import { useEffect, useRef, useCallback } from 'react';
import { useAuthStore } from '@/store/authStore';

export type ChatEvent =
  | { type: 'message'; [key: string]: unknown }
  | { type: 'typing_start'; user_id: string; username: string; display_name: string; avatar_url: string }
  | { type: 'typing_stop'; user_id: string; username: string }
  | { type: 'read'; conversation_id: string; reader_id: string; message_id?: string; count: number }
  | { type: 'react'; conversation_id: string; message_id: string; reactions: Record<string, number> }
  | { type: 'call_offer' | 'call_answer' | 'call_ice' | 'call_end' | 'call_decline' | 'call_ringing'; [key: string]: unknown };

interface Options {
  conversationId: string | null;
  onEvent: (event: ChatEvent) => void;
  enabled?: boolean;
}

const WS_BASE = (import.meta.env.VITE_WS_URL ?? 'ws://localhost:8000').replace(/\/$/, '');

export function useChatSocket({ conversationId, onEvent, enabled = true }: Options) {
  const token = useAuthStore((s) => s.accessToken);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const onEventRef = useRef(onEvent);
  onEventRef.current = onEvent;

  const sendRaw = useCallback((data: object) => {
    const ws = wsRef.current;
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
      return true;
    }
    return false;
  }, []);

  // ── Public API ────────────────────────────────────────────────────────────

  const sendMessage = useCallback(
    (payload: {
      body?: string;
      message_type?: string;
      media_url?: string;
      media_mime?: string;
      file_name?: string;
      reply_to_id?: string;
      metadata?: Record<string, unknown>;
    }) => {
      return sendRaw({ type: 'message', data: payload });
    },
    [sendRaw],
  );

  const sendTypingStart = useCallback(() => {
    sendRaw({ type: 'typing_start' });
  }, [sendRaw]);

  const sendTypingStop = useCallback(() => {
    sendRaw({ type: 'typing_stop' });
  }, [sendRaw]);

  const sendRead = useCallback((messageId?: string) => {
    sendRaw({ type: 'read', message_id: messageId });
  }, [sendRaw]);

  const sendReact = useCallback((messageId: string, emoji: string) => {
    sendRaw({ type: 'react', message_id: messageId, emoji });
  }, [sendRaw]);

  const sendCallSignal = useCallback(
    (
      signalType: 'call_offer' | 'call_answer' | 'call_ice' | 'call_end' | 'call_decline',
      data: object,
      callType: 'audio' | 'video' = 'audio',
    ) => {
      sendRaw({ type: signalType, data, call_type: callType });
    },
    [sendRaw],
  );

  // ── Connection management ─────────────────────────────────────────────────

  const connect = useCallback(() => {
    if (!conversationId || !token || !enabled) return;

    // Close any existing connection first
    if (wsRef.current) {
      wsRef.current.onclose = null; // prevent reconnect loop
      wsRef.current.close();
      wsRef.current = null;
    }

    const url = `${WS_BASE}/ws/conversation/${conversationId}/?token=${token}`;
    const ws = new WebSocket(url);
    wsRef.current = ws;

    ws.onopen = () => {
      reconnectAttempts.current = 0;
      console.log('[ChatSocket] Connected to conversation', conversationId);
    };

    ws.onmessage = (evt) => {
      try {
        const data = JSON.parse(evt.data);
        onEventRef.current(data as ChatEvent);
      } catch {
        // ignore malformed frames
      }
    };

    ws.onclose = (evt) => {
      wsRef.current = null;
      if (!enabled) return;
      if (evt.code === 4001 || evt.code === 4003) {
        console.warn('[ChatSocket] Auth/member check failed, not reconnecting');
        return;
      }
      // Exponential backoff: 1s, 2s, 4s … max 30s
      const delay = Math.min(1000 * 2 ** reconnectAttempts.current, 30_000);
      reconnectAttempts.current += 1;
      console.log(`[ChatSocket] Reconnecting in ${delay}ms (attempt ${reconnectAttempts.current})`);
      reconnectTimerRef.current = setTimeout(() => connect(), delay);
    };

    ws.onerror = (err) => {
      console.error('[ChatSocket] WebSocket error', err);
      ws.close();
    };
  }, [conversationId, token, enabled]);

  useEffect(() => {
    connect();
    return () => {
      if (reconnectTimerRef.current) clearTimeout(reconnectTimerRef.current);
      if (wsRef.current) {
        wsRef.current.onclose = null;
        wsRef.current.close();
        wsRef.current = null;
      }
    };
  }, [connect]);

  return { sendMessage, sendTypingStart, sendTypingStop, sendRead, sendReact, sendCallSignal };
}
