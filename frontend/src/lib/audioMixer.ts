/**
 * StudioAudioMixer — Web Audio engine for the create-studio preview.
 *
 * Key constraint: once `createMediaElementSource(el)` is called the element's
 * audio routes through the graph forever; tearing the graph down (closing the
 * context) silences the element permanently and no amount of `el.volume`
 * fixes it. So the graph is built ONCE and never closed — enhance/speed/
 * volume changes only tweak node params. The context must also be resumed
 * from a user gesture (autoplay policy) or audio routes nowhere.
 *
 * When Web Audio is unavailable (old browsers, tests) the mixer reports
 * fallback: true and callers should drive `el.volume` directly.
 */


export interface OriginalAudioState {
  /** 0–200 (%) applied as master gain on the whole chain. */
  volume: number;
  /** Voice isolate: cut rumble, gate hiss, even levels. */
  enhance: boolean;
}

export class StudioAudioMixer {
  private ctx: AudioContext | null = null;
  private source: MediaElementAudioSourceNode | null = null;
  private masterGain: GainNode | null = null;
  private dspGain: GainNode | null = null;
  private directGain: GainNode | null = null;
  private el: HTMLMediaElement | null = null;
  fallback = false;

  /** Attach (once) to a media element and build the routing graph. */
  attach(el: HTMLElement | null): void {
    const media = el as HTMLMediaElement | null;
    if (!media || this.fallback) return;
    if (this.el === media) {
      this.resume();
      return;
    }
    if (this.el) {
      // Element swapping is not supported by MediaElementAudioSourceNode.
      this.fallback = true;
      return;
    }
    const AC = (globalThis as { AudioContext?: typeof AudioContext }).AudioContext;
    if (!AC) {
      this.fallback = true;
      return;
    }
    try {
      this.ctx = new AC();
      this.source = this.ctx.createMediaElementSource(media);
      // Enhancement chain: rumble cut → noise gate ≈ expander → smart comp.
      const hp = this.ctx.createBiquadFilter();
      hp.type = 'highpass';
      hp.frequency.value = 90;
      hp.Q.value = 0.7;
      const gate = this.ctx.createDynamicsCompressor();
      gate.threshold.value = -48;
      gate.knee.value = 6;
      gate.ratio.value = 6;
      gate.attack.value = 0.003;
      gate.release.value = 0.12;
      const comp = this.ctx.createDynamicsCompressor();
      comp.threshold.value = -26;
      comp.knee.value = 10;
      comp.ratio.value = 3;
      comp.attack.value = 0.005;
      comp.release.value = 0.2;
      const makeup = this.ctx.createGain();
      makeup.gain.value = 1.8;
      this.dspGain = this.ctx.createGain();
      this.dspGain.gain.value = 0;
      this.directGain = this.ctx.createGain();
      this.directGain.gain.value = 1;
      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.value = 1;

      this.source.connect(hp);
      hp.connect(gate);
      gate.connect(comp);
      comp.connect(makeup);
      makeup.connect(this.dspGain);
      // Bypass path keeps the element audible when DSP is off.
      this.source.connect(this.directGain);
      this.dspGain.connect(this.masterGain);
      this.directGain.connect(this.masterGain);
      this.masterGain.connect(this.ctx.destination);
      // Through Web Audio the element volume must stay at max.
      media.volume = 1;
      this.el = media;
    } catch {
      this.fallback = true;
      this.ctx = null;
      this.source = null;
      this.masterGain = null;
      this.dspGain = null;
      this.directGain = null;
    }
  }

  /** Call from a user gesture (play click, slider drag) to beat autoplay policy. */
  resume(): void {
    if (this.ctx?.state === 'suspended') {
      void this.ctx.resume().catch(() => { /* preview-only */ });
    }
  }

  /** Apply original-audio params. Falls back to el.volume when graph absent. */
  update(state: OriginalAudioState): void {
    const vol = Math.min(200, Math.max(0, state.volume ?? 100)) / 100;
    if (this.fallback || !this.masterGain) {
      if (this.el) this.el.volume = Math.min(1, vol);
      return;
    }
    const { masterGain, dspGain, directGain } = this;
    if (state.enhance) {
      dspGain!.gain.value = 1;
      directGain!.gain.value = 0;
    } else {
      dspGain!.gain.value = 0;
      directGain!.gain.value = 1;
    }
    masterGain.gain.value = vol <= 1 ? vol : (state.enhance ? Math.min(2, vol * 0.85) : Math.min(2, vol));
  }

  get audioContext(): AudioContext | null {
    return this.ctx;
  }
}

// ─── Added tracks (sound library / voiceover) ────────────────────────────────
//
// Web Audio cannot pitch-shift without changing duration, so "voice tricks"
// are approximated the TikTok way:
//   chipmunk / deep → playbackRate shift (time-warping, like most phone
//   editors), robot → ring modulator, echo → feedback delay. All applied
//   purely client-side as parametric edits.

export type TrackEffect = 'none' | 'chipmunk' | 'deep' | 'robot' | 'echo';

export const TRACK_EFFECT_RATES: Record<TrackEffect, number> = {
  none: 1, chipmunk: 1.28, deep: 0.76, robot: 1, echo: 1,
};

/** Only these effects need the MediaElementSource Web Audio graph. */
function ctxNeedsGraph(effect: TrackEffect): boolean {
  return effect === 'robot' || effect === 'echo';
}

export interface AddedTrackParams {
  id: string;
  url: string;
  /** 0–200 (%) */
  volume: number;
  /** Position on the clip timeline (absolute media ms) where it starts. */
  start_ms: number;
  /** Max play length on the timeline (track duration may be shorter). */
  duration_ms?: number;
  effect?: TrackEffect;
  fade_in_ms?: number;
  fade_out_ms?: number;
  /** Start position inside the audio file (attached-sound placement). */
  offset_ms?: number;
  /** When true, other tracks dip while this one plays. */
  ducking?: boolean;
}

const DUCK_DIP = 0.35;

class TrackController {
  el: HTMLAudioElement;
  readonly url: string;
  private ctx: AudioContext | null = null;
  private gain: GainNode | null = null;
  private ringMod: GainNode | null = null;
  private osc: OscillatorNode | null = null;
  private delay: DelayNode | null = null;
  private feedback: GainNode | null = null;
  private effect: TrackEffect = 'none';
  private startMs: number = 0;
  private durationMs: number | null = null;
  private baseVolume: number = 1;
  private fileOffsetMs: number = 0;
  private fadeInMs: number = 0;
  private fadeOutMs: number = 0;
  private _ducking: boolean = false;
  private started = false;

  constructor(params: AddedTrackParams) {
    this.url = params.url;
    this.startMs = params.start_ms ?? 0;
    this.durationMs = params.duration_ms ?? null;
    this.el = new Audio(params.url);
    this.el.preload = 'auto';
    this.el.crossOrigin = 'anonymous';
    this.applyParams(params);
  }

  /** Attach (once) to a shared AudioContext for robot/echo DSP. */
  attachGraph(ctx: AudioContext): void {
    if (this.ctx) return;
    this.ctx = ctx;
    try {
      const src = ctx.createMediaElementSource(this.el);
      this.gain = ctx.createGain();
      src.connect(this.gain);
      this.gain.connect(ctx.destination);
      // Once a source node exists only the graph controls the level.
      this.gain.gain.value = Math.min(1, 100 / 100);
      this.el.volume = 1;
      this.rewire(this.effect);
    } catch {
      this.gain = null; // fallback to element volume only
    }
  }

  private rewire(effect: TrackEffect): void {
    if (!this.ctx || !this.gain) return;
    try {
      if (effect !== 'robot') { try { this.osc?.stop(); } catch { /* noop */ } this.osc = null; }
      if (effect === 'echo') return this.rewireEcho();
      if (effect === 'robot') return this.rewireRobot();
    } catch { /* fallback silently */ }
  }

  private rewireEcho(): void {
    this.delay = this.delay ?? this.ctx!.createDelay(1.0);
    this.delay.delayTime.value = 0.18;
    this.feedback = this.feedback ?? this.ctx!.createGain();
    this.feedback.gain.value = 0.32;
    this.delay.connect(this.feedback);
    this.feedback.connect(this.delay);
    this.delay.connect(this.gain!);
  }

  private rewireRobot(): void {
    this.ringMod = this.ringMod ?? this.ctx!.createGain();
    this.ringMod.gain.value = 0.4;
    this.osc = this.osc ?? this.ctx!.createOscillator();
    this.osc.type = 'sine';
    this.osc.frequency.value = 30;
    this.osc.connect(this.ringMod.gain);
    this.osc.start();
    this.ringMod.connect(this.gain!);
  }

  applyParams(params: AddedTrackParams): void {
    if (params.url !== this.url) return;
    this.startMs = params.start_ms ?? 0;
    this.durationMs = params.duration_ms ?? null;
    const effect = params.effect ?? 'none';
    this.el.playbackRate = TRACK_EFFECT_RATES[effect] ?? 1;
    this.effect = effect;
    this.fadeInMs = Math.max(0, params.fade_in_ms ?? 0);
    this.fadeOutMs = Math.max(0, params.fade_out_ms ?? 0);
    this.fileOffsetMs = Math.max(0, params.offset_ms ?? 0);
    this._ducking = params.ducking ?? false;
    // DSP-only effects need the Web Audio graph (which requires CORS on the
    // media source); rate-based effects keep the simple element path.
    if (ctxNeedsGraph(effect) && this.ctx) this.attachGraph(this.ctx);
    this.rewire(effect);
    this.setLevel(params.volume);
  }

  setLevel(volume: number): void {
    this.baseVolume = Math.min(1, Math.max(0, volume) / 100);
    this.renderLevel(1, 1);
  }

  private renderLevel(fade: number, duck: number): void {
    const v = Math.min(1, Math.max(0, this.baseVolume * fade * duck));
    if (this.gain) this.gain.gain.value = v;
    else this.el.volume = v;
  }

  /** Fade multiplier for a track-local position (ms since track start). */
  private fadeAt(localMs: number, windowMs: number): number {
    let f = 1;
    if (this.fadeInMs > 0 && localMs < this.fadeInMs) f = Math.min(f, localMs / this.fadeInMs);
    if (this.fadeOutMs > 0) {
      const remaining = windowMs - localMs;
      if (remaining < this.fadeOutMs) f = Math.min(f, Math.max(0, remaining) / this.fadeOutMs);
    }
    return Math.min(1, Math.max(0, f));
  }

  /** Sync this track's play/pause/position against the clip timeline. */
  sync(clipMs: number, clipPlaying: boolean, duckDip: number = 1): void {
    const rate = this.el.playbackRate || 1;
    const trackDurSec = this.el.duration && Number.isFinite(this.el.duration) ? this.el.duration : 0;
    const windowEndMs = this.startMs
      + (this.durationMs != null ? this.durationMs * rate : trackDurSec * 1000 * rate);
    const inWindow = clipMs >= this.startMs && trackDurSec > 0 && clipMs < windowEndMs;
    if (!inWindow || !clipPlaying) {
      if (!this.el.paused) this.el.pause();
      if (clipMs < this.startMs - 500 && this.el.currentTime > 0.05) this.el.currentTime = 0;
      this.started = false;
      return;
    }
    if (!this.started) {
      this.el.currentTime = this.fileOffsetMs / 1000 + (clipMs - this.startMs) / 1000;
      this.started = true;
    }
    this.renderLevel(this.fadeAt(clipMs - this.startMs, windowEndMs - this.startMs), duckDip);
    void this.el.play().catch(() => { /* autoplay policy; retried on next sync */ });
  }

  dispose(): void {
    this.el.pause();
    try { this.osc?.stop(); } catch { /* noop */ }
  }

  get ducking(): boolean {
    return this._ducking;
  }

  /** True when this ducking-enabled track is audibly playing right now. */
  isDuckingNow(clipMs: number): boolean {
    if (!this._ducking) return false;
    const rate = this.el.playbackRate || 1;
    const trackDurSec = this.el.duration && Number.isFinite(this.el.duration) ? this.el.duration : 0;
    const windowEndMs = this.startMs
      + (this.durationMs != null ? this.durationMs * rate : trackDurSec * 1000 * rate);
    return clipMs >= this.startMs && trackDurSec > 0 && clipMs < windowEndMs && !this.el.paused;
  }
}

/**
 * TrackSyncer manages the added audio tracks of one clip: element lifecycle,
 * effect graphs and drift-free sync against the video timeline. Without a
 * Web Audio context (old browsers, tests) tracks still play via element
 * volume/rate so the mixing basics keep working.
 */
export class TrackSyncer {
  private tracks = new Map<string, TrackController>();
  private ctx: AudioContext | null = null;

  setTracks(params: AddedTrackParams[]): void {
    const nextIds = new Set(params.map((p) => p.id));
    for (const [id, ctrl] of [...this.tracks]) {
      const p = params.find((x) => x.id === id);
      if (!nextIds.has(id)) {
        ctrl.dispose();
        this.tracks.delete(id);
      } else if (p && p.url !== ctrl.url) {
        ctrl.dispose();
        this.tracks.delete(id);
      }
    }
    for (const p of params) {
      const existing = this.tracks.get(p.id);
      if (existing) {
        if (p.url === existing.url) { existing.applyParams(p); continue; }
        existing.dispose();
        this.tracks.delete(p.id);
      }
      const ctrl = new TrackController(p);
      this.tracks.set(p.id, ctrl);
      // DSP graphs attach lazily (on effects that need them) — plain level
      // control works via element volume and needs no CORS handshake.
      if (this.ctx && ctxNeedsGraph(p.effect ?? 'none')) ctrl.attachGraph(this.ctx);
    }
    for (const p of params) {
      this.tracks.get(p.id)?.setLevel(p.volume);
    }
  }

  /** Wire the original-audio mixer context in for DSP effects. */
  useSharedContext(ctx: AudioContext | null): void {
    if (!ctx || ctx === this.ctx) return;
    this.ctx = ctx; // graphs attach lazily per-track when effects need them
  }

  get audioContext(): AudioContext | null {
    return this.ctx;
  }

  syncAll(clipMs: number, clipPlaying: boolean): void {
    const duckActive = clipPlaying && [...this.tracks.values()].some((c) => c.isDuckingNow(clipMs));
    for (const ctrl of this.tracks.values()) {
      ctrl.sync(clipMs, clipPlaying, duckActive && !ctrl.ducking ? DUCK_DIP : 1);
    }
  }

  dispose(): void {
    for (const ctrl of this.tracks.values()) ctrl.dispose();
    this.tracks.clear();
  }
}
