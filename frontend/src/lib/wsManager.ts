type MsgHandler = (data: unknown) => void;

class WsManager {
  private static instance: WsManager;
  private sockets = new Map<string, WebSocket>();
  private handlers = new Map<string, Set<MsgHandler>>();
  private attempts = new Map<string, number>();
  private disconnecting = new Set<string>();
  private baseUrl: string;
  private accessToken: string | null = null;

  private constructor() {
    this.baseUrl = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8002';
  }

  static getInstance() { if (!WsManager.instance) WsManager.instance = new WsManager(); return WsManager.instance; }

  setAccessToken(t: string | null) {
    const prev = this.accessToken;
    this.accessToken = t;
    if (prev !== t && t !== null) {
      this.reconnectAll();
    }
  }

  private reconnectAll() {
    const paths = [...this.sockets.keys()];
    for (const path of paths) {
      const existing = this.sockets.get(path);
      if (existing && !this.disconnecting.has(path)) {
        this.disconnecting.add(path);
        existing.close();
        this.disconnecting.delete(path);
        this.sockets.delete(path);
        this.connect(path);
      }
    }
  }

  connect(path: string): WebSocket {
    const existing = this.sockets.get(path);
    if (existing && existing.readyState === WebSocket.OPEN) return existing;
    if (existing) {
      this.disconnecting.add(path);
      existing.close();
      this.disconnecting.delete(path);
      this.sockets.delete(path);
    }
    const url = `${this.baseUrl}/${path}${this.accessToken ? `?token=${this.accessToken}` : ''}`;
    const ws = new WebSocket(url);
    ws.onopen = () => { this.attempts.set(path, 0); };
    ws.onmessage = (e) => { try { const d = JSON.parse(e.data); this.handlers.get(path)?.forEach((h) => h(d)); } catch {} };
    ws.onclose = (evt) => {
      this.sockets.delete(path);
      // Auth rejections (4001 unauthenticated / 4003 forbidden) and logouts
      // must not loop: reconnect only after a fresh token arrives via
      // setAccessToken(). Generic 1006-without-handshake also stops after
      // the attempt cap below.
      const authRejected = evt.code === 4001 || evt.code === 4003;
      if (!this.disconnecting.has(path) && !authRejected && this.accessToken) {
        this.reconnect(path);
      }
      this.disconnecting.delete(path);
    };
    ws.onerror = () => {};
    this.sockets.set(path, ws);
    return ws;
  }

  disconnect(path: string) {
    this.disconnecting.add(path);
    this.sockets.get(path)?.close();
    this.sockets.delete(path);
    this.attempts.delete(path);
  }

  disconnectAll() {
    this.sockets.forEach((ws, path) => {
      this.disconnecting.add(path);
      ws.close();
    });
    this.sockets.clear();
    this.attempts.clear();
  }

  onMessage(path: string, handler: MsgHandler): () => void {
    if (!this.handlers.has(path)) this.handlers.set(path, new Set());
    this.handlers.get(path)!.add(handler);
    return () => { this.handlers.get(path)?.delete(handler); };
  }

  private reconnect(path: string) {
    const a = this.attempts.get(path) || 0;
    if (a >= 10) return;
    this.attempts.set(path, a + 1);
    setTimeout(() => this.connect(path), Math.min(1000 * Math.pow(2, a), 30000));
  }
}

export const wsManager = WsManager.getInstance();
