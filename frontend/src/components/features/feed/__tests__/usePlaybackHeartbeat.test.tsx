import { describe, expect, it, vi, beforeEach, afterEach } from 'vitest';
import { render, act } from '@testing-library/react';
import { usePlaybackHeartbeat } from '../usePlaybackHeartbeat';

const { trackMock } = vi.hoisted(() => ({ trackMock: vi.fn() }));
vi.mock('@/lib/analytics', () => ({ track: trackMock }));

function Harness({ active, playing, getPositionMs }: {
  active: boolean; playing: boolean; getPositionMs?: () => number;
}) {
  usePlaybackHeartbeat('post-hb', { active, playing, getPositionMs });
  return null;
}

describe('usePlaybackHeartbeat', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    trackMock.mockClear();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it('emits a heartbeat every 5s of real playback and nothing while paused', () => {
    const { rerender } = render(<Harness active playing />);
    act(() => { vi.advanceTimersByTime(5000); });
    expect(trackMock).toHaveBeenCalledTimes(1);
    const [name, props] = trackMock.mock.calls[0];
    expect(name).toBe('feed.video_watch');
    expect(props.surface).toBe('video_feed');
    expect(props.object_type).toBe('post');
    expect(props.object_id).toBe('post-hb');
    expect(props.properties.delta_ms).toBe(5000);

    // Paused: no further accumulation, and the pending buffer is empty.
    rerender(<Harness active={false} playing={false} />);
    act(() => { vi.advanceTimersByTime(10000); });
    expect(trackMock).toHaveBeenCalledTimes(1);
  });

  it('flushes partial playback on pause and on unmount', () => {
    const { rerender, unmount } = render(<Harness active playing />);
    act(() => { vi.advanceTimersByTime(3000); });
    // Pause flushes the 3s remainder.
    rerender(<Harness active playing={false} />);
    expect(trackMock).toHaveBeenCalledTimes(1);
    expect(trackMock.mock.calls[0][1].properties.delta_ms).toBe(3000);

    // Resume, accumulate 2s, unmount flushes the rest.
    rerender(<Harness active playing />);
    act(() => { vi.advanceTimersByTime(2000); });
    unmount();
    expect(trackMock).toHaveBeenCalledTimes(2);
    expect(trackMock.mock.calls[1][1].properties.delta_ms).toBe(2000);
  });

  it('flushes when the active slide changes and drops sub-second remainders', () => {
    const { rerender, unmount } = render(<Harness active playing />);
    act(() => { vi.advanceTimersByTime(2600); });
    // Slide change: active=false flushes 2 complete 1s ticks (600ms dropped).
    rerender(<Harness active={false} playing />);
    expect(trackMock).toHaveBeenCalledTimes(1);
    expect(trackMock.mock.calls[0][1].properties.delta_ms).toBe(2000);

    // 800ms while inactive must never accumulate.
    act(() => { vi.advanceTimersByTime(800); });
    unmount();
    expect(trackMock).toHaveBeenCalledTimes(1);
  });
});
