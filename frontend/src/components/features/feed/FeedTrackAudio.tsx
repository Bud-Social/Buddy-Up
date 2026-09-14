/**
 * FeedTrackAudio — plays a post's parametric audio mix (added sound/voiceover
 * tracks + attached library sound) in sync with a feed <video> element.
 *
 * Reuses TrackSyncer from the studio engine: fades, ducking, voice effects
 * and per-track levels all replay live. Renders nothing.
 */
import { useEffect, useRef } from 'react';
import { TrackSyncer, type AddedTrackParams } from '@/lib/audioMixer';
import type { PostEditMeta } from '@/types';

export interface FeedTrackAudioProps {
  /** Accessor for the video element to follow (ref may attach late). */
  getVideo: () => HTMLVideoElement | null;
  /** Server-shaped edit metadata (audio_tracks). */
  editMeta?: PostEditMeta | null;
  /** Attached library sound (sound_id row). */
  soundUrl?: string | null;
  soundVolume?: number | null;
  soundPlacement?: { start_ms?: number; fade_in_ms?: number; fade_out_ms?: number } | null;
  /** Absolute media-ms offset when legacy parametric trims apply. */
  trimStartMs?: number | null;
  muted: boolean;
  active: boolean;
}

export function FeedTrackAudio({
  getVideo, editMeta, soundUrl, soundVolume, soundPlacement,
  trimStartMs, muted, active,
}: FeedTrackAudioProps) {
  const syncerRef = useRef<TrackSyncer | null>(null);
  if (!syncerRef.current) syncerRef.current = new TrackSyncer();
  const stateRef = useRef({ muted, active });
  stateRef.current = { muted, active };

  // Track lifecycle.
  useEffect(() => {
    const syncer = syncerRef.current!;
    const params: AddedTrackParams[] = (editMeta?.audio_tracks ?? [])
      .filter((t) => !!t.url)
      .map((t, i) => ({
        id: `track-${i}-${(t.url ?? '').slice(-24)}`,
        url: t.url as string,
        volume: t.volume ?? 100,
        start_ms: t.start_ms ?? 0,
        duration_ms: t.duration_ms ?? undefined,
        effect: (t.effect as AddedTrackParams['effect']) ?? 'none',
        fade_in_ms: t.fade_in_ms ?? undefined,
        fade_out_ms: t.fade_out_ms ?? undefined,
        ducking: t.ducking ?? undefined,
      }));
    if (soundUrl) {
      params.push({
        id: 'attached-sound',
        url: soundUrl,
        volume: soundVolume ?? 100,
        start_ms: 0,
        offset_ms: soundPlacement?.start_ms ?? 0,
        fade_in_ms: soundPlacement?.fade_in_ms ?? undefined,
        fade_out_ms: soundPlacement?.fade_out_ms ?? undefined,
      });
    }
    syncer.setTracks(params);
  }, [editMeta, soundUrl, soundVolume, soundPlacement]);

  // Follow the video element's timeline. The rAF loop runs only while the
  // video reports playing, so idle feed videos cost nothing.
  useEffect(() => {
    const syncer = syncerRef.current!;
    let raf = 0;
    const tick = () => {
      const el = getVideo();
      const { muted: m, active: a } = stateRef.current;
      if (!el || el.paused) {
        syncer.syncAll(-1, false);
        raf = 0;
        return;
      }
      const t = el.currentTime * 1000 + (trimStartMs ?? 0);
      syncer.syncAll(t, a && !m);
      raf = requestAnimationFrame(tick);
    };
    const kick = () => { if (!raf) raf = requestAnimationFrame(tick); };
    const onPause = () => {
      if (raf) cancelAnimationFrame(raf);
      raf = 0;
      syncer.syncAll(-1, false);
    };
    const el = getVideo();
    el?.addEventListener('play', kick);
    el?.addEventListener('seeked', kick);
    el?.addEventListener('pause', onPause);
    el?.addEventListener('ended', onPause);
    kick();
    return () => {
      if (raf) cancelAnimationFrame(raf);
      el?.removeEventListener('play', kick);
      el?.removeEventListener('seeked', kick);
      el?.removeEventListener('pause', onPause);
      el?.removeEventListener('ended', onPause);
      syncer.syncAll(-1, false);
    };
    // getVideo identity is stable per render site; re-bind when activity flips.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [active, muted, trimStartMs]);

  useEffect(() => () => syncerRef.current?.dispose(), []);

  return null;
}
