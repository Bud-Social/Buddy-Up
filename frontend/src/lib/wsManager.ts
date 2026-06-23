type MsgHandler = (data: unknown) => void;

class WsManager {
  private static instance: WsManager;
  private sockets = new Map<string, WebSocket>();
  private handlers = new Map<string, Set<MsgHandler>>();
  private attempts = new Map<string, number>();
  private baseUrl: string;
  private accessToken: string | null = null;

  private constructor() {
    this.baseUrl = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8000';
  }

  static getInstance() { if (!WsManager.instance) WsManager.instance = new WsManager(); return WsManager.instance; }

  setAccessToken(t: string | null) { this.accessToken = t; }

  connect(path: string): WebSocket {
    if (this.sockets.has(path)) return this.sockets.get(path)!;
    const url = `${this.baseUrl}/${path}${this.accessToken ? `?token=${this.accessToken}` : ''}`;
    const ws = new WebSocket(url);
    ws.onopen = () => { this.attempts.set(path, 0); };
    ws.onmessage = (e) => { try { const d = JSON.parse(e.data); this.handlers.get(path)?.forEach((h) => h(d)); } catch {} };
    ws.onclose = () => { this.sockets.delete(path); this.reconnect(path); };
    ws.onerror = () => {};
    this.sockets.set(path, ws);
    return ws;
  }

  disconnect(path: string) { this.sockets.get(path)?.close(); this.sockets.delete(path); this.attempts.delete(path); }

  disconnectAll() { this.sockets.forEach((ws) => ws.close()); this.sockets.clear(); this.attempts.clear(); }

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
