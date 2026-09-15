import { useEffect, useRef } from 'react';
import { track } from '@/lib/analytics';

interface HeartbeatOpts {
  /** The post is the active fullscreen slide. */
  active: boolean;
  /** The video element is actually playing (not paused/buffering). */
  playing: boolean;
  /** Returns the current playback position in ms (best-effort). */
  getPositionMs?: () => number;
  /** Emit a heartbeat every this many ms of actual playback. Default 5000. */
  intervalMs?: number;
}

/**
 * Playback-heartbeat watch-time tracking for the Bud Press player.
 *
 * Accumulates real playback time (active slide AND video playing) and emits a
 * `feed.video_watch` analytics event every `intervalMs`, plus a final partial
 * heartbeat on pause / slide change / unmount so short watches are not lost.
 * Silent-friendly: tracking must never break playback.
 */
export function usePlaybackHeartbeat(
  postId: string | undefined,
  { active, playing, getPositionMs, intervalMs = 5000 }: HeartbeatOpts,
): void {
  const bufferRef = useRef(0);

  // Flush any pending playback time when playback stops, the slide changes or
  // the component unmounts.
  const flush = () => {
    const pending = bufferRef.current;
    bufferRef.current = 0;
    if (!postId || pending < 1000) return;
    let positionMs = 0;
    try { positionMs = Math.round(getPositionMs?.() ?? 0); } catch { /* best-effort */ }
    track('feed.video_watch', {
      surface: 'video_feed',
      object_type: 'post',
      object_id: postId,
      properties: { delta_ms: pending, position_ms: positionMs },
    });
  };

  useEffect(() => {
    if (!active) {
      flush();
      return;
    }
    // 1s tick: accumulate only while the video is genuinely playing.
    const tick = setInterval(() => {
      if (!playing) return;
      bufferRef.current += 1000;
      if (bufferRef.current >= intervalMs) flush();
    }, 1000);
    return () => {
      clearInterval(tick);
      flush();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [active, playing, intervalMs, postId]);

  // Final flush when the whole player unmounts.
  useEffect(() => () => flush(), []); // eslint-disable-line react-hooks/exhaustive-deps
}
