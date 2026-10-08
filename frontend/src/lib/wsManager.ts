type MsgHandler = (data: unknown) => void;

/** Reconnect ceiling per path — the backoff below tops out at 30s. */
const MAX_ATTEMPTS = 10;

class WsManager {
  private static instance: WsManager;
  private sockets = new Map<string, WebSocket>();
  private handlers = new Map<string, Set<MsgHandler>>();
  private attempts = new Map<string, number>();
  /**
   * Paths that asked for a socket while no access token was available. The
   * token lives in memory only and lands a tick after mount (boot refresh), so
   * this is an expected state — the path is remembered, not opened blind.
   */
  private deferred = new Set<string>();
  /** Paths whose current failure has already been explained once. */
  private explained = new Set<string>();
  private baseUrl: string;
  private accessToken: string | null = null;

  private constructor() {
    this.baseUrl = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8002';
  }

  static getInstance() { if (!WsManager.instance) WsManager.instance = new WsManager(); return WsManager.instance; }

  setAccessToken(t: string | null) {
    const prev = this.accessToken;
    this.accessToken = t;
    if (prev === t || t === null) return;
    // A token just arrived: re-handshake the live sockets so they carry the new
    // credential, then open the paths that were waiting for one. Deferred paths
    // never hold a socket, so the two passes can't collide.
    this.reconnectAll();
    this.flushDeferred();
  }

  private flushDeferred() {
    if (!this.accessToken) return;
    for (const path of [...this.deferred]) this.connect(path);
  }

  private reconnectAll() {
    for (const path of [...this.sockets.keys()]) {
      const existing = this.sockets.get(path);
      if (!existing) continue;
      this.sockets.delete(path);
      existing.close();
      this.connect(path);
    }
  }

  /**
   * Opens the socket for `path`, or returns null while no access token exists —
   * in which case the path is remembered and opened by setAccessToken().
   */
  connect(path: string): WebSocket | null {
    const existing = this.sockets.get(path);
    if (existing && (existing.readyState === WebSocket.OPEN || existing.readyState === WebSocket.CONNECTING)) return existing;
    if (existing) {
      // A dead socket never reopens itself; drop it so a deferred connect (or a
      // token refresh) can't hand the caller a corpse.
      this.sockets.delete(path);
      existing.close();
    }
    // SECURITY / CORRECTNESS: the token is the only credential these consumers
    // accept, and a tokenless connect can only ever be refused — the consumer
    // closes 4001/4003 *before* accept(), which daphne turns into a bare HTTP
    // 403 the browser reports as 1006. Defer instead of burning a handshake.
    if (!this.accessToken) {
      this.deferred.add(path);
      return null;
    }
    this.deferred.delete(path);

    // SECURITY: never put the token in the query string — URLs end up in
    // access logs, proxies and referrers. Browsers can't set custom headers
    // on WebSocket connects, so the token rides in the Sec-WebSocket-Protocol
    // subprotocol list (['bearer', <token>]); the backend strips and reads it
    // from there. Native clients still use the legacy ?token= query param.
    const url = `${this.baseUrl}/${path}`;
    const ws = new WebSocket(url, ['bearer', this.accessToken]);
    // Per-socket, not per-path: a replaced socket's close event must never be
    // read as the new socket's handshake outcome.
    let opened = false;
    ws.onopen = () => { opened = true; this.attempts.set(path, 0); this.explained.delete(path); };
    ws.onmessage = (e) => { try { const d = JSON.parse(e.data); this.handlers.get(path)?.forEach((h) => h(d)); } catch {} };
    ws.onclose = (evt) => {
      // Identity check, not a "closing" flag: every deliberate teardown
      // (disconnect / disconnectAll / token rotation) removes the map entry
      // before closing, so a close from anything but the *current* socket is
      // already accounted for and must not trigger a retry.
      if (this.sockets.get(path) !== ws) return;
      this.sockets.delete(path);

      // Logouts and native ASGI-level rejections must not loop: park the path
      // until a fresh token arrives via setAccessToken().
      if (evt.code === 4001 || evt.code === 4003 || !this.accessToken) {
        this.deferred.add(path);
        return;
      }

      const attempt = (this.attempts.get(path) || 0) + 1;
      if (attempt > MAX_ATTEMPTS) return;
      if (import.meta.env.DEV && !this.explained.has(path)) {
        this.explained.add(path);
        // A close before onopen means the *upgrade request* never completed.
        // daphne answers every pre-accept consumer close with a bare HTTP 403,
        // so a rejected handshake reaches us as 1006 — the same code a missing
        // host produces, and overwhelmingly the former once a token is in hand.
        // Name what actually happened instead of blaming the wrong tier.
        console.warn(
          opened
            ? `[ws] ${path} dropped (code=${evt.code || 'none'}) after the handshake completed — the connection ended unexpectedly (idle proxy timeout or network blip). Attempt ${attempt}/${MAX_ATTEMPTS}.`
            : `[ws] ${path} refused before the handshake completed (code=${evt.code || 'none'}) — the server answered the upgrade request with a failure status instead of 101. With a token in hand this is an auth/permission failure: daphne turns a pre-accept close (4001 unauthenticated / 4003 not a member) into a bare HTTP 403. Attempt ${attempt}/${MAX_ATTEMPTS}.`,
        );
      }
      this.reconnect(path);
    };
    ws.onerror = () => {};
    this.sockets.set(path, ws);
    return ws;
  }

  disconnect(path: string) {
    const ws = this.sockets.get(path);
    this.sockets.delete(path);
    ws?.close();
    this.deferred.delete(path);
    this.explained.delete(path);
    this.attempts.delete(path);
  }

  disconnectAll() {
    for (const ws of this.sockets.values()) ws.close();
    this.sockets.clear();
    this.attempts.clear();
    this.deferred.clear();
    this.explained.clear();
  }

  onMessage(path: string, handler: MsgHandler): () => void {
    if (!this.handlers.has(path)) this.handlers.set(path, new Set());
    this.handlers.get(path)!.add(handler);
    return () => { this.handlers.get(path)?.delete(handler); };
  }

  private reconnect(path: string) {
    const a = this.attempts.get(path) || 0;
    if (a >= MAX_ATTEMPTS) return;
    this.attempts.set(path, a + 1);
    setTimeout(() => this.connect(path), Math.min(1000 * Math.pow(2, a), 30_000));
  }
}

export const wsManager = WsManager.getInstance();
