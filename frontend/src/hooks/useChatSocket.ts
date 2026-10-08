/**
 * useChatSocket – manages a single WebSocket connection to a BuddyUp Fit chat conversation.
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

const WS_BASE = (import.meta.env.VITE_WS_BASE_URL ?? 'ws://localhost:8002').replace(/\/$/, '');

export function useChatSocket({ conversationId, onEvent, enabled = true }: Options) {
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const onEventRef = useRef(onEvent);
  onEventRef.current = onEvent;
  // The access token is memory-only, so it lands a tick *after* this hook
  // mounts (boot refresh) — and rotates every ~15 minutes. Subscribing to it is
  // what makes the connection (re)start the moment a token becomes available.
  const accessToken = useAuthStore((s) => s.accessToken);
  /** The current failure has already been explained once — don't repeat it per retry. */
  const explainedRef = useRef(false);

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
    if (!conversationId || !enabled) return;
    // No token yet is a normal state, not an error: bail quietly and let the
    // effect below re-run (with the token) as soon as the boot refresh lands.
    if (!accessToken) return;

    // Close any existing connection first
    if (wsRef.current) {
      wsRef.current.onclose = null; // prevent reconnect loop
      wsRef.current.close();
      wsRef.current = null;
    }

    // SECURITY: token rides in Sec-WebSocket-Protocol (['bearer', token]) —
    // never in the query string, which leaks into logs/proxies/referrers.
    const url = `${WS_BASE}/ws/conversation/${conversationId}/`;
    const ws = new WebSocket(url, ['bearer', accessToken]);
    wsRef.current = ws;
    // Per-socket: a replaced socket's close must not be read as the new one's.
    let opened = false;

    ws.onopen = () => {
      opened = true;
      reconnectAttempts.current = 0;
      explainedRef.current = false;
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
      if (wsRef.current !== ws) return; // superseded by a newer socket
      wsRef.current = null;
      if (!enabled) return;
      // Only an ASGI-level close reports these; daphne answers a pre-accept
      // close with a bare HTTP 403, so a browser will normally see 1006 below.
      if (evt.code === 4001 || evt.code === 4003) {
        console.warn('[ChatSocket] Auth/member check failed, not reconnecting');
        return;
      }
      const attempt = reconnectAttempts.current + 1;
      // Exponential backoff: 1s, 2s, 4s … max 30s
      const delay = Math.min(1000 * 2 ** reconnectAttempts.current, 30_000);
      reconnectAttempts.current = attempt;
      // A close before onopen means the *upgrade request* never completed —
      // with a token in hand that is an auth/permission rejection surfacing
      // as 1006, the same code a missing host produces. Explain the first
      // failure only, so a backoff loop stays readable.
      if (import.meta.env.DEV && !explainedRef.current) {
        explainedRef.current = true;
        console.warn(
          opened
            ? `[ChatSocket] Dropped (code=${evt.code || 'none'}) after connecting — the connection ended unexpectedly.`
            : `[ChatSocket] Handshake refused (code=${evt.code || 'none'}) — the server answered the upgrade with a failure status instead of 101. With a token in hand this is an auth/permission failure (daphne turns a pre-accept close into a bare HTTP 403).`,
        );
      }
      console.log(`[ChatSocket] Reconnecting in ${delay}ms (attempt ${attempt})`);
      reconnectTimerRef.current = setTimeout(() => connect(), delay);
    };

    ws.onerror = (err) => {
      console.error('[ChatSocket] WebSocket error', err);
      ws.close();
    };
  }, [conversationId, enabled, accessToken]);

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
