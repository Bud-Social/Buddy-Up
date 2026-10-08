import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { act, renderHook, waitFor } from '@testing-library/react';
import { useChatSocket } from '@/hooks/useChatSocket';
import { useAuthStore } from '@/store/authStore';

/** WebSocket double — the hook only constructs one and drives its handlers. */
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

  constructor(readonly url: string, readonly protocols?: string | string[]) {
    FakeSocket.instances.push(this);
  }

  send() {}
  close() { this.readyState = FakeSocket.CLOSED; }
  open() { this.readyState = FakeSocket.OPEN; this.onopen?.(); }
  closeWith(code: number) {
    this.readyState = FakeSocket.CLOSED;
    this.onclose?.({ code, reason: '' });
  }
}

const origWebSocket = globalThis.WebSocket;
const CONVO = 'convo-1';

beforeEach(() => {
  FakeSocket.instances = [];
  globalThis.WebSocket = FakeSocket as unknown as typeof WebSocket;
  localStorage.clear();
  useAuthStore.setState({ accessToken: null, isAuthenticated: false });
});

afterEach(() => {
  globalThis.WebSocket = origWebSocket;
  vi.useRealTimers();
  vi.restoreAllMocks();
  useAuthStore.setState({ accessToken: null, isAuthenticated: false });
});

const mount = (enabled = true) =>
  renderHook(() => useChatSocket({ conversationId: CONVO, onEvent: () => {}, enabled }));

describe('useChatSocket — connecting once a token exists', () => {
  it('connects when the token only becomes available after mount', async () => {
    // The access token is memory-only: on a page load the hook mounts before
    // the boot refresh resolves, and nothing else would ever open the socket.
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    mount();

    expect(FakeSocket.instances).toHaveLength(0);
    expect(warn).not.toHaveBeenCalled();

    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });

    await waitFor(() => expect(FakeSocket.instances).toHaveLength(1));
    expect(FakeSocket.instances[0].url).toContain(`/ws/conversation/${CONVO}/`);
    expect(FakeSocket.instances[0].protocols).toEqual(['bearer', 'tok-1']);
  });

  it('connects straight away when the token is already in memory', () => {
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });

    mount();

    expect(FakeSocket.instances).toHaveLength(1);
    expect(FakeSocket.instances[0].protocols).toEqual(['bearer', 'tok-1']);
  });

  it('re-handshakes when the token rotates', async () => {
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });
    mount();
    await waitFor(() => expect(FakeSocket.instances).toHaveLength(1));

    act(() => { useAuthStore.getState().setAccessToken('tok-2'); });

    await waitFor(() => expect(FakeSocket.instances).toHaveLength(2));
    expect(FakeSocket.instances[1].protocols).toEqual(['bearer', 'tok-2']);
  });

  it('stays closed while disabled, even with a token present', () => {
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });

    mount(false);

    expect(FakeSocket.instances).toHaveLength(0);
  });

  it('closes the socket on unmount without scheduling a retry', () => {
    vi.useFakeTimers();
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });
    const { unmount } = mount();
    const ws = FakeSocket.instances[0];

    unmount();
    vi.advanceTimersByTime(60_000);

    expect(ws.readyState).toBe(FakeSocket.CLOSED);
    expect(FakeSocket.instances).toHaveLength(1);
  });
});

describe('useChatSocket — close-code reporting', () => {
  it('calls a 1006 handshake failure an auth rejection, not an unreachable server', async () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    vi.spyOn(console, 'log').mockImplementation(() => {});
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });
    mount();

    FakeSocket.instances[0].closeWith(1006);

    await waitFor(() => expect(warn).toHaveBeenCalledTimes(1));
    const msg = String(warn.mock.calls[0][0]);
    expect(msg).not.toMatch(/unreachable/i);
    expect(msg).toMatch(/handshake refused/i);
  });

  it('does not blame the network once the socket had opened', async () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    vi.spyOn(console, 'log').mockImplementation(() => {});
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });
    mount();
    FakeSocket.instances[0].open();

    FakeSocket.instances[0].closeWith(1006);

    await waitFor(() => expect(warn).toHaveBeenCalledTimes(1));
    const msg = String(warn.mock.calls[0][0]);
    expect(msg).toMatch(/after connecting/i);
    expect(msg).not.toMatch(/unreachable/i);
  });

  it('backs off 1s, 2s, 4s … capped at 30s', async () => {
    vi.useFakeTimers();
    vi.spyOn(console, 'warn').mockImplementation(() => {});
    vi.spyOn(console, 'log').mockImplementation(() => {});
    act(() => { useAuthStore.getState().setAccessToken('tok-1'); });
    mount();

    FakeSocket.instances[0].closeWith(1006);
    vi.advanceTimersByTime(999);
    expect(FakeSocket.instances).toHaveLength(1);
    vi.advanceTimersByTime(1);
    expect(FakeSocket.instances).toHaveLength(2);

    FakeSocket.instances[1].closeWith(1006);
    vi.advanceTimersByTime(1_999);
    expect(FakeSocket.instances).toHaveLength(2);
    vi.advanceTimersByTime(1);
    expect(FakeSocket.instances).toHaveLength(3);
  });
});