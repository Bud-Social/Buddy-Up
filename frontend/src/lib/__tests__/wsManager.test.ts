import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { wsManager } from '@/lib/wsManager';

/**
 * Minimal WebSocket double: the manager only ever constructs one, reads the
 * readyState constants off it and drives onopen/onclose/onmessage/onerror.
 */
class FakeSocket {
  static CONNECTING = 0;
  static OPEN = 1;
  static CLOSING = 2;
  static CLOSED = 3;

  static instances: FakeSocket[] = [];

  readyState = FakeSocket.CONNECTING;
  onopen: ((e?: unknown) => void) | null = null;
  onmessage: ((e: { data: string }) => void) | null = null;
  onclose: ((e: { code: number; reason: string }) => void) | null = null;
  onerror: ((e: unknown) => void) | null = null;
  readonly sent: string[] = [];

  constructor(readonly url: string, readonly protocols?: string | string[]) {
    FakeSocket.instances.push(this);
  }

  send(data: string) { this.sent.push(data); }
  close() { this.readyState = FakeSocket.CLOSED; }

  /** Completes the handshake. */
  open() {
    this.readyState = FakeSocket.OPEN;
    this.onopen?.();
  }

  /** What the browser reports when daphne answers the upgrade with a bare 403. */
  rejectHandshake(code = 1006) {
    this.readyState = FakeSocket.CLOSED;
    this.onclose?.({ code, reason: '' });
  }
}

const origWebSocket = globalThis.WebSocket;

beforeEach(() => {
  FakeSocket.instances = [];
  globalThis.WebSocket = FakeSocket as unknown as typeof WebSocket;
  wsManager.setAccessToken(null);
  wsManager.disconnectAll();
});

afterEach(() => {
  globalThis.WebSocket = origWebSocket;
  vi.useRealTimers();
  vi.restoreAllMocks();
  wsManager.setAccessToken(null);
  wsManager.disconnectAll();
});

const PATH = 'ws/user/user-1/';

describe('wsManager — never opens a tokenless socket', () => {
  it('does not construct a WebSocket while no access token exists', () => {
    // The token is memory-only and lands a tick after mount, so this is the
    // normal first render of the app — a connect here would be a guaranteed 403.
    expect(wsManager.connect(PATH)).toBeNull();
    expect(FakeSocket.instances).toHaveLength(0);
  });

  it('opens the deferred socket as soon as a token arrives', () => {
    wsManager.connect(PATH);

    wsManager.setAccessToken('tok-1');

    expect(FakeSocket.instances).toHaveLength(1);
    expect(FakeSocket.instances[0].url).toContain(PATH);
    expect(FakeSocket.instances[0].protocols).toEqual(['bearer', 'tok-1']);
  });

  it('reuses the live socket instead of opening a second one', () => {
    wsManager.setAccessToken('tok-1');
    const first = wsManager.connect(PATH);

    expect(wsManager.connect(PATH)).toBe(first);
    expect(FakeSocket.instances).toHaveLength(1);
  });

  it('drops a deferred path on disconnect so it cannot outlive its subscriber', () => {
    wsManager.connect(PATH);
    wsManager.disconnect(PATH);

    wsManager.setAccessToken('tok-1');

    expect(FakeSocket.instances).toHaveLength(0);
  });

  it('stays quiet while no token exists rather than retrying blind', () => {
    vi.useFakeTimers();
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.connect(PATH);
    wsManager.connect(PATH);

    vi.advanceTimersByTime(120_000);

    expect(FakeSocket.instances).toHaveLength(0);
    expect(warn).not.toHaveBeenCalled();
  });
});

describe('wsManager — close-code reporting', () => {
  it('reports a 1006 handshake rejection as an auth failure, not an unreachable server', () => {
    vi.useFakeTimers();
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('tok-1');
    const ws = wsManager.connect(PATH)!;

    // No onopen ever ran: the upgrade request itself was refused.
    ws.rejectHandshake(1006);

    expect(warn).toHaveBeenCalledTimes(1);
    const msg = String(warn.mock.calls[0][0]);
    expect(msg).not.toMatch(/unreachable/i);
    expect(msg).toMatch(/handshake/i);
    expect(msg).toMatch(/auth/i);
  });

  it('says the connection dropped only when the handshake had completed', () => {
    vi.useFakeTimers();
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('tok-1');
    const ws = wsManager.connect(PATH)!;
    ws.open();

    ws.rejectHandshake(1006);

    const msg = String(warn.mock.calls[0][0]);
    expect(msg).toMatch(/after the handshake completed/i);
    expect(msg).not.toMatch(/unreachable/i);
  });

  it('explains a failing path once instead of on every retry', () => {
    vi.useFakeTimers();
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('tok-1');

    wsManager.connect(PATH)!.rejectHandshake(1006);
    expect(warn).toHaveBeenCalledTimes(1);

    // Backoff is 1s, 2s, 4s … — retry, and stay quiet about the same failure.
    vi.advanceTimersByTime(1_000);
    expect(FakeSocket.instances).toHaveLength(2);
    FakeSocket.instances[1].rejectHandshake(1006);

    expect(warn).toHaveBeenCalledTimes(1);
  });

  it('retries with exponential backoff and stops at the attempt cap', () => {
    vi.useFakeTimers();
    vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('tok-1');
    wsManager.connect(PATH);

    // First retry waits 1s, the second 2s, the third 4s …
    FakeSocket.instances[0].rejectHandshake(1006);
    vi.advanceTimersByTime(999);
    expect(FakeSocket.instances).toHaveLength(1);
    vi.advanceTimersByTime(1);
    expect(FakeSocket.instances).toHaveLength(2);

    // Burn through the rest of the budget; each close schedules one more retry.
    for (let i = 0; i < 20; i++) {
      FakeSocket.instances[FakeSocket.instances.length - 1].rejectHandshake(1006);
      vi.advanceTimersByTime(60_000);
    }

    expect(FakeSocket.instances).toHaveLength(11); // initial + 10 retries
  });

  it('goes quiet once the cap is spent', () => {
    vi.useFakeTimers();
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('tok-1');
    wsManager.connect(PATH);

    for (let i = 0; i < 20; i++) {
      FakeSocket.instances[FakeSocket.instances.length - 1].rejectHandshake(1006);
      vi.advanceTimersByTime(60_000);
    }
    expect(warn).toHaveBeenCalledTimes(1);

    warn.mockClear();
    FakeSocket.instances[FakeSocket.instances.length - 1].rejectHandshake(1006);
    vi.advanceTimersByTime(120_000);

    expect(FakeSocket.instances).toHaveLength(11);
    expect(warn).not.toHaveBeenCalled();
  });

  it('parks an auth-rejected path until a fresh token arrives', () => {
    vi.useFakeTimers();
    vi.spyOn(console, 'warn').mockImplementation(() => {});
    wsManager.setAccessToken('expired');
    wsManager.connect(PATH)!.rejectHandshake(4001);

    vi.advanceTimersByTime(60_000);
    expect(FakeSocket.instances).toHaveLength(1); // no blind retry loop

    wsManager.setAccessToken('fresh');
    expect(FakeSocket.instances).toHaveLength(2);
    expect(FakeSocket.instances[1].protocols).toEqual(['bearer', 'fresh']);
  });
});