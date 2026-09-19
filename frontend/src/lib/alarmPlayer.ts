/**
 * alarmPlayer — frontend alarm sound playback + scheduling helpers.
 *
 * - playAlarmSound: plays a sound URL via HTMLAudio, looping until the
 *   returned stop function is called. If the audio element fails to load
 *   (bad URL, unsupported codec, no Audio in this environment), falls back
 *   to a WebAudio beep loop in the style of lib/ringtone.ts.
 * - stopAllAlarms: stops every sound started via playAlarmSound.
 * - scheduleAlarm: setTimeout-based one-shot scheduler; returns a cancel fn.
 */

/** UI cap for recordings/uploads (30s), enforced by the Alarm Center page. */
export const MAX_SOUND_MS = 30_000;

/** Max delay for a single setTimeout (~24.8 days); longer waits are chunked. */
const MAX_TIMEOUT_MS = 2_147_483_647;

const activeStops = new Set<() => void>();

function registerStop(stop: () => void): () => void {
  activeStops.add(stop);
  return () => {
    activeStops.delete(stop);
    stop();
  };
}

/** Stop every alarm sound started via playAlarmSound. Safe to call anytime. */
export function stopAllAlarms(): void {
  const stops = Array.from(activeStops);
  activeStops.clear();
  stops.forEach((stop) => {
    try {
      stop();
    } catch {
      // ignore teardown errors — best effort
    }
  });
}

/**
 * WebAudio beep loop fallback (same voice as lib/ringtone.ts).
 * Returns a stop function.
 */
function playBeepLoop(): () => void {
  const AudioCtx =
    typeof window !== 'undefined' &&
    (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext);
  if (!AudioCtx) return () => undefined;
  const ctx = new AudioCtx();
  let stopped = false;
  let timer: ReturnType<typeof setTimeout> | null = null;

  const beep = () => {
    if (stopped) return;
    try {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'sine';
      osc.frequency.setValueAtTime(880, ctx.currentTime);
      osc.frequency.setValueAtTime(660, ctx.currentTime + 0.2);
      gain.gain.setValueAtTime(0.3, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.4);
      osc.start(ctx.currentTime);
      osc.stop(ctx.currentTime + 0.5);
    } catch {
      // ignore per-beep errors; keep looping until stopped
    }
    if (!stopped) timer = setTimeout(beep, 1200);
  };

  beep();

  return () => {
    stopped = true;
    if (timer) clearTimeout(timer);
    try {
      void ctx.close();
    } catch {
      // ignore
    }
  };
}

export interface PlayAlarmOptions {
  /** How many times to play the sound; defaults to looping forever. */
  loops?: number;
  /** Volume 0..1; defaults to 1. */
  volume?: number;
}

/**
 * Play an alarm sound, looping until stopped.
 * Falls back to a WebAudio beep loop if the URL fails to load.
 * The returned function stops playback; stopAllAlarms() stops everything.
 */
export function playAlarmSound(url: string, options: PlayAlarmOptions = {}): () => void {
  const { loops = Number.POSITIVE_INFINITY, volume = 1 } = options;

  if (typeof Audio === 'undefined') return registerStop(playBeepLoop());

  let stopped = false;
  let plays = 0;
  let fallbackStop: (() => void) | null = null;
  let audio: HTMLAudioElement | null = null;

  const cleanup = () => {
    stopped = true;
    if (audio) {
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
      audio = null;
    }
    if (fallbackStop) {
      fallbackStop();
      fallbackStop = null;
    }
  };

  const stop = registerStop(cleanup);

  try {
    audio = new Audio(url);
    audio.volume = Math.min(1, Math.max(0, volume));
    audio.addEventListener('ended', () => {
      if (stopped) return;
      plays += 1;
      if (plays < loops && audio) {
        void audio.play().catch(() => undefined);
      } else {
        stop();
      }
    });
    audio.addEventListener('error', () => {
      if (stopped || fallbackStop) return;
      audio = null;
      fallbackStop = playBeepLoop();
    });
    void audio.play().catch(() => {
      // Autoplay blocked or undecodable here — the error event (or the
      // beep fallback below if play never settles) covers audibility.
      if (stopped || fallbackStop || typeof audio === 'undefined' || audio === null) return;
    });
  } catch {
    if (!stopped && !fallbackStop) fallbackStop = playBeepLoop();
  }

  return stop;
}

/**
 * Schedule a one-shot callback for a future Date.
 * Returns a cancel function. Long delays are chunked so they survive the
 * ~24.8-day setTimeout limit. Past dates fire on the next tick.
 */
export function scheduleAlarm(fireAt: Date, onFire: () => void): () => void {
  let cancelled = false;
  let timer: ReturnType<typeof setTimeout> | null = null;

  const tick = () => {
    if (cancelled) return;
    const delay = fireAt.getTime() - Date.now();
    if (delay <= 0) {
      timer = setTimeout(() => {
        if (!cancelled) onFire();
      }, 0);
      return;
    }
    timer = setTimeout(tick, Math.min(delay, MAX_TIMEOUT_MS));
  };

  tick();

  return () => {
    cancelled = true;
    if (timer) clearTimeout(timer);
  };
}
