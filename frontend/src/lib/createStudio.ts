/**
 * Pure logic for the create studio (trim clamping, cover poster URLs,
 * publish payload building) — kept framework-free for easy testing.
 */
import type { CSSProperties } from 'react';
import type { UploadedMedia } from '@/lib/uploader';

export const MAX_TRIM_MS = 180_000; // TikTok-style 3-minute cap
export const MAX_MEDIA_ITEMS = 12;

export interface TrimSelection {
  start_ms: number;
  end_ms: number;
}

export type TrimRangeValue = TrimSelection;

export interface TrimRange extends TrimSelection {
  /** True when the requested trim had to be shortened to fit the cap. */
  clamped: boolean;
}

/**
 * Clamp a trim selection into [0, durationMs], enforcing a positive
 * selection and the ≤180s cap. Handles inverted or oversized inputs.
 */
export function clampTrim(
  startMs: number,
  endMs: number,
  durationMs: number,
  maxLenMs: number = MAX_TRIM_MS,
): TrimRange {
  const dur = Math.max(0, durationMs);
  let start = Math.min(Math.max(0, startMs), dur);
  let end = Math.min(Math.max(0, endMs), dur);
  if (end <= start) {
    const len = Math.min(1000, dur);
    start = Math.max(0, dur - len);
    end = dur;
  }
  let clamped = false;
  if (end - start > maxLenMs) {
    clamped = true;
    if (endMs > dur || startMs < 0) {
      // The selection hit the media bounds — keep the in point.
      end = start + maxLenMs;
    } else {
      // Dragged thumbs too far apart — keep the out point.
      start = end - maxLenMs;
    }
  }
  return { start_ms: Math.round(start), end_ms: Math.round(end), clamped };
}

/**
 * Move one trim thumb to `posMs` while keeping a minimal positive
 * selection and enforcing the ≤180s cap.
 */
export function moveThumb(
  which: 'start' | 'end',
  posMs: number,
  trim: TrimSelection,
  durationMs: number,
  maxLenMs: number = MAX_TRIM_MS,
): TrimRange {
  const dur = Math.max(0, durationMs);
  let start = trim.start_ms;
  let end = trim.end_ms;
  if (which === 'start') {
    start = Math.min(Math.max(0, posMs), Math.max(0, end - 100));
  } else {
    end = Math.max(Math.min(Math.max(0, posMs), dur), Math.min(start + 100, dur));
  }
  let clamped = false;
  if (end - start > maxLenMs) {
    clamped = true;
    if (which === 'start') start = end - maxLenMs;
    else end = start + maxLenMs;
  }
  return { start_ms: Math.round(start), end_ms: Math.round(end), clamped };
}

/** Format seconds as a compact Cloudinary offset ("1.5" → "so_1.5"). */
export function formatCoverOffset(offsetSec: number): string {
  const rounded = Math.round(offsetSec * 100) / 100;
  return `so_${rounded}`;
}

/** "65400" → "1:05.4" for trim/cover readouts. */
export function formatMs(ms: number): string {
  const total = Math.max(0, ms) / 1000;
  const m = Math.floor(total / 60);
  const s = total - m * 60;
  return `${m}:${s < 10 ? '0' : ''}${s.toFixed(1)}`;
}

/**
 * Poster override for a custom cover frame: append the Cloudinary start
 * offset (`?so_<seconds>`) to the media URL. Returns undefined when there
 * is nothing to append.
 */
export function coverPosterUrl(url: string | undefined | null, offsetSec?: number | null): string | undefined {
  if (!url || offsetSec == null || !Number.isFinite(offsetSec) || offsetSec < 0) return undefined;
  return `${url}?${formatCoverOffset(offsetSec)}`;
}

/** Serializable slice of a studio item used to build the publish payload. */
export type TextAnimation = 'none' | 'fade' | 'pop' | 'slide' | 'karaoke';
export type TextBackground = 'none' | 'pill' | 'block';

export interface TextOverlay {
  id: string;
  text: string;
  start_ms: number;
  end_ms: number;
  /** Position as % of frame (y from top, x from left, 0–100). */
  y: number;
  x?: number;
  /** Rotation in degrees (−15…15). */
  rotation?: number;
  /** 0 small · 1 medium · 2 large (0–2 continuum). */
  size: number;
  color: 'white' | 'yellow' | 'cyan' | 'black' | 'pink' | 'green';
  /** Font family id from FONT_OPTIONS. */
  font?: string;
  /** TikTok text style preset (outline/glow/neon/bubble/highlight/shadow). */
  effect?: TextEffect;
  bg?: TextBackground;
  bg_color?: string;
  animation?: TextAnimation;
}

export interface StickerOverlay {
  id: string;
  kind: 'emoji' | 'countdown' | 'mention';
  /** Emoji char when kind === 'emoji'; username when 'mention'. */
  content: string;
  x: number;
  y: number;
  start_ms: number;
  end_ms: number;
  /** 0.5–2 zoom relative to base size. */
  scale: number;
}

export type AudioTrackEffect = 'none' | 'chipmunk' | 'deep' | 'robot' | 'echo';
export type AudioTrackKind = 'sound' | 'voiceover' | 'url';

export interface AudioTrack {
  id: string;
  kind: AudioTrackKind;
  /** Sound library id when kind === 'sound'. */
  sound_id?: string;
  /** Direct URL (voiceover / custom). */
  url?: string;
  /** Display label for the mixer UI. */
  label?: string;
  /** 0–200 (%). */
  volume: number;
  /** Offset on the clip timeline where the track starts playing. */
  start_ms: number;
  /** Track duration cap (trim end for sound trims). */
  duration_ms?: number;
  effect?: AudioTrackEffect;
  /** Fade in/out lengths in ms (0 = none, parametric — applied at render). */
  fade_in_ms?: number;
  /** Fade out length in ms (0 = none). */
  fade_out_ms?: number;
  /**
   * Voiceover ducking: when true, other tracks dip while this (voiceover)
   * track is active. Stored parametrically; applied at render time.
   */
  ducking?: boolean;
}

export interface CaptionsStyle {
  preset: string;
  font?: string;
  /** 0.8–1.6 multiplier over the base caption size. */
  size?: number;
  color?: string;
  bg?: TextBackground;
  /** Vertical placement of the caption bubble (default 'bottom'). */
  placement?: CaptionPlacement;
}

export type CaptionPlacement = 'top' | 'center' | 'bottom';

export const CAPTION_PLACEMENTS: { id: CaptionPlacement; label: string }[] = [
  { id: 'top', label: 'Top' },
  { id: 'center', label: 'Center' },
  { id: 'bottom', label: 'Bottom' },
];

export interface EditAdjustments {
  brightness: number;
  contrast: number;
  saturation: number;
  vignette: number;
}

export type AspectMode = 'original' | '9:16' | '1:1' | '4:5' | '16:9';

export interface EditMeta {
  /** IG-style preset id applied as a CSS filter. */
  filter: string | null;
  /** Preset strength 0–100 (100 = full recipe). */
  filter_strength: number;
  /** Playback speed multiplier (0.3–3). */
  speed: number;
  /** Original audio volume 0–200. */
  volume: number;
  /** Voice-enhance (noise gate + high-pass + compressor preview). */
  enhance: boolean;
  /** Manual color/saturation adjustments 0–100 around neutral 50. */
  adjust: EditAdjustments;
  /** Frame crop mode replayed parametrically. */
  aspect: AspectMode;
  /** Vertical focus point (0 top–100 bottom) for cover crops. */
  focus_y: number;
  /** Voice effect applied to the original audio track preview. */
  voice_effect: AudioTrackEffect;
  textOverlays: TextOverlay[];
  stickers: StickerOverlay[];
  audioTracks: AudioTrack[];
  captions_style?: CaptionsStyle | null;
}

export const EDIT_FILTERS: { id: string; label: string; fns: Array<[string, number]> }[] = [
  { id: 'normal', label: 'Normal', fns: [] },
  { id: 'vivid', label: 'Vivid', fns: [['saturate', 1.5], ['contrast', 1.1]] },
  { id: 'warm', label: 'Warm', fns: [['sepia', 0.35], ['saturate', 1.3], ['hue-rotate', -10]] },
  { id: 'cool', label: 'Cool', fns: [['saturate', 1.15], ['hue-rotate', 15], ['brightness', 1.05]] },
  { id: 'mono', label: 'Mono', fns: [['grayscale', 1], ['contrast', 1.1]] },
  { id: 'fade', label: 'Fade', fns: [['contrast', 0.88], ['saturate', 0.8], ['brightness', 1.08]] },
  { id: 'dramatic', label: 'Drama', fns: [['contrast', 1.35], ['saturate', 1.2], ['brightness', 0.92]] },
  { id: 'nostalgia', label: 'Retro', fns: [['sepia', 0.55], ['contrast', 0.95], ['brightness', 1.05]] },
  { id: 'electric', label: 'Electric', fns: [['saturate', 1.7], ['contrast', 1.25], ['hue-rotate', -25]] },
  { id: 'sunset', label: 'Sunset', fns: [['sepia', 0.2], ['saturate', 1.4], ['brightness', 1.02], ['hue-rotate', -18]] },
  { id: 'arctic', label: 'Arctic', fns: [['saturate', 0.75], ['brightness', 1.1], ['hue-rotate', 30]] },
  { id: 'infrared', label: 'Infrared', fns: [['saturate', 1.9], ['contrast', 1.4], ['hue-rotate', -70]] },
];

const _FN_RENDER: Record<string, (v: number) => string> = {
  saturate: (v) => `saturate(${v.toFixed(3)})`,
  contrast: (v) => `contrast(${v.toFixed(3)})`,
  brightness: (v) => `brightness(${v.toFixed(3)})`,
  grayscale: (v) => `grayscale(${v.toFixed(3)})`,
  sepia: (v) => `sepia(${v.toFixed(3)})`,
  'hue-rotate': (v) => `hue-rotate(${Math.round(v)}deg)`,
};

export function filterCss(id: string | null | undefined): string {
  return filterCssAt(id, 100);
}

/**
 * Preset CSS with per-function strength: t=100 renders the full recipe,
 * t=0 renders neutral, values lerp per function toward identity (1°/0).
 */
export function filterCssAt(id: string | null | undefined, strength: number): string {
  const preset = EDIT_FILTERS.find((f) => f.id === id);
  if (!preset || preset.fns.length === 0) return '';
  const t = clamp01((Number.isFinite(strength) ? strength : 100) / 100);
  const parts = preset.fns
    .filter(([, v]) => !(t === 0 || Math.abs(1 + (v - 1) * t - 1) < 0.001))
    .map(([fn, v]) => _FN_RENDER[fn]?.(1 + (v - 1) * t) ?? '')
    .filter(Boolean);
  return parts.length ? parts.join(' ') : '';
}

function clamp01(v: number): number {
  return Math.min(1, Math.max(0, v));
}

/** CSS filter chain from manual adjustments (50 = neutral). */
export function adjustCss(
  adjust: Partial<Pick<EditAdjustments, 'brightness' | 'contrast' | 'saturation' | 'vignette'>> | undefined | null,
): string {
  if (!adjust) return '';
  const fns: string[] = [];
  const brightness = adjust.brightness;
  const contrast = adjust.contrast;
  const saturation = adjust.saturation;
  if (brightness != null && brightness !== 50) fns.push(`brightness(${lerpFactor(brightness).toFixed(3)})`);
  if (contrast != null && contrast !== 50) fns.push(`contrast(${lerpFactor(contrast).toFixed(3)})`);
  if (saturation != null && saturation !== 50) fns.push(`saturate(${lerpFactor(saturation).toFixed(3)})`);
  return fns.join(' ');
}

function lerpFactor(v: number): number {
  // 0 → 0.3, 50 → 1, 100 → 2.4 (perceptual slider feel).
  const t = clamp01(v / 100);
  return t < 0.5 ? 0.3 + 1.4 * t : 1 + 2.8 * (t - 0.5);
}

export const ASPECT_MODES: { id: AspectMode; label: string; ratio: number | null }[] = [
  { id: 'original', label: 'Original', ratio: null },
  { id: '9:16', label: '9:16', ratio: 9 / 16 },
  { id: '1:1', label: '1:1', ratio: 1 },
  { id: '4:5', label: '4:5', ratio: 4 / 5 },
  { id: '16:9', label: '16:9', ratio: 16 / 9 },
];

export const TEXT_COLORS = ['white', 'yellow', 'cyan', 'black', 'pink', 'green'] as const;
export const TEXT_COLOR_VALUES: Record<string, string> = {
  white: '#FFFFFF', yellow: '#FFD400', cyan: '#38E1FF', black: '#111111',
  pink: '#FF3CA7', green: '#00FF9D',
};

/** Big TikTok-style text font catalog — display faces load from Google Fonts. */
export const FONT_OPTIONS: { id: string; label: string; stack: string }[] = [
  { id: 'classic', label: 'Classic', stack: '"Plus Jakarta Sans", var(--font-heading, inherit)' },
  { id: 'typewriter', label: 'Typewriter', stack: '"JetBrains Mono", ui-monospace, monospace' },
  { id: 'handwrite', label: 'Handwrite', stack: '"Caveat", "Comic Sans MS", cursive' },
  { id: 'script', label: 'Script', stack: '"Pacifico", "Segoe Script", cursive' },
  { id: 'marker', label: 'Marker', stack: '"Permanent Marker", "Segoe Print", cursive' },
  { id: 'satisfy', label: 'Satisfy', stack: '"Satisfy", "Segoe Script", cursive' },
  { id: 'kaushan', label: 'Artsy', stack: '"Kaushan Script", cursive' },
  { id: 'lucky', label: 'Carnival', stack: '"Luckiest Guy", Impact, sans-serif' },
  { id: 'bangers', label: 'Comic', stack: '"Bangers", Impact, sans-serif' },
  { id: 'anton', label: 'Anton', stack: '"Anton", Impact, sans-serif' },
  { id: 'bebas', label: 'Tall', stack: '"Bebas Neue", Impact, sans-serif' },
  { id: 'bungee', label: 'Cube', stack: '"Bungee", Impact, sans-serif' },
  { id: 'racing', label: 'Racing', stack: '"Racing Sans One", Impact, sans-serif' },
  { id: 'retro', label: 'Retro', stack: '"Rubik Mono One", monospace' },
  { id: 'gamer', label: 'Gamer', stack: '"Press Start 2P", monospace' },
  { id: 'neon', label: 'Neon', stack: '"Monoton", "Trebuchet MS", sans-serif' },
  { id: 'spooky', label: 'Spooky', stack: '"Creepster", Impact, sans-serif' },
  { id: 'soft', label: 'Soft', stack: '"Fredoka", "Trebuchet MS", sans-serif' },
  { id: 'serif', label: 'Serif', stack: 'Georgia, "Times New Roman", serif' },
  { id: 'grotesk', label: 'Grotesk', stack: '"Arial Black", Roboto, sans-serif' },
];

export function fontFamilyCss(fontId: string | undefined | null): string {
  return FONT_OPTIONS.find((f) => f.id === fontId)?.stack ?? FONT_OPTIONS[0].stack;
}

/** TikTok-style text style presets (applied as pure CSS in editor + feed). */
export type TextEffect = 'none' | 'outline' | 'glow' | 'neon' | 'bubble' | 'highlight' | 'shadow';

export const TEXT_EFFECTS: { id: TextEffect; label: string }[] = [
  { id: 'none', label: 'Plain' },
  { id: 'outline', label: 'Outline' },
  { id: 'glow', label: 'Glow' },
  { id: 'neon', label: 'Neon' },
  { id: 'bubble', label: 'Bubble' },
  { id: 'highlight', label: 'Highlight' },
  { id: 'shadow', label: 'Drop' },
];

const TEXT_SHADOW_BLACK = '0 1px 4px rgba(0,0,0,.55)';

/**
 * CSS for a text effect preset. `color` is the resolved text color so glow
 * attachments can echo it. Pure — shared by editor and feed renderers.
 */
export function textEffectCss(effect: string | undefined | null, color: string): CSSProperties {
  switch (effect) {
    case 'outline':
      return {
        webkitTextStrokeWidth: '1.6px',
        webkitTextStrokeColor: 'rgba(0,0,0,0.92)',
        color,
        textShadow: color === '#111111' ? TEXT_SHADOW_BLACK : undefined,
      } as CSSProperties;
    case 'glow':
      return {
        color,
        textShadow: `0 0 6px ${color}, 0 0 14px ${color}, 0 0 28px ${color}`,
      } as CSSProperties;
    case 'neon':
      return {
        color: '#3FF3FF',
        textShadow:
          '0 0 4px #2EE6FF, 0 0 10px #1680d8, 0 0 22px #7A05F0, 0 0 40px #7A05F0, 0 0 70px #C017D9',
        filter: 'drop-shadow(0 0 8px rgba(63,243,255,0.8))',
      } as CSSProperties;
    case 'bubble':
      return {
        color,
        background: 'rgba(255,255,255,0.92)',
        border: '3px solid rgba(17,17,17,0.9)',
        borderRadius: 999,
        padding: '4px 12px',
        textShadow: color === '#FFFFFF' || color === '#FFD400' || color === '#38E1FF' || color === '#00FF9D'
          ? '0 1px 2px rgba(0,0,0,0.35)'
          : undefined,
      } as CSSProperties;
    case 'highlight':
      return {
        color: '#111111',
        background: color === '#111111' ? '#FFD400' : color,
        borderRadius: 6,
        padding: '2px 8px',
        boxShadow: 'none',
      } as CSSProperties;
    case 'shadow':
      return {
        color,
        textShadow: '0 4px 0 rgba(0,0,0,0.55), 0 8px 18px rgba(0,0,0,0.45)',
      } as CSSProperties;
    default:
      return { color, textShadow: TEXT_SHADOW_BLACK } as CSSProperties;
  }
}

export const TEXT_ANIMATIONS: { id: TextAnimation; label: string }[] = [
  { id: 'none', label: 'None' },
  { id: 'fade', label: 'Fade' },
  { id: 'pop', label: 'Pop' },
  { id: 'slide', label: 'Slide' },
  { id: 'karaoke', label: 'Bounce' },
];

export const AUDIO_TRACK_EFFECTS: { id: AudioTrackEffect; label: string }[] = [
  { id: 'none', label: 'Original' },
  { id: 'chipmunk', label: 'Chipmunk' },
  { id: 'deep', label: 'Deep' },
  { id: 'robot', label: 'Robot' },
  { id: 'echo', label: 'Echo' },
];

export const CAPTION_PRESETS: { id: string; label: string; font?: string; color: string; bg: TextBackground; bg_color?: string; uppercase?: boolean }[] = [
  { id: 'classic', label: 'Classic', color: '#FFFFFF', bg: 'none' },
  { id: 'pop', label: 'Pop', font: 'grotesk', color: '#FFFFFF', bg: 'pill', bg_color: '#111111' },
  { id: 'karaoke', label: 'Bounce', font: 'typewriter', color: '#FFD400', bg: 'none' },
  { id: 'clean', label: 'Clean', color: '#FFFFFF', bg: 'block', bg_color: 'rgba(0,0,0,0.45)' },
  { id: 'neon', label: 'Neon', font: 'neon', color: '#38E1FF', bg: 'none' },
];

export const SPEED_OPTIONS = [0.3, 0.5, 1, 1.5, 2, 3] as const;

export function defaultAdjust(): EditAdjustments {
  return { brightness: 50, contrast: 50, saturation: 50, vignette: 0 };
}

export function defaultEditMeta(): EditMeta {
  return {
    filter: null,
    filter_strength: 100,
    speed: 1,
    volume: 100,
    enhance: false,
    adjust: defaultAdjust(),
    aspect: 'original',
    focus_y: 50,
    voice_effect: 'none',
    textOverlays: [],
    stickers: [],
    audioTracks: [],
    captions_style: undefined,
  };
}

const clampNum = (v: unknown, lo: number, hi: number, fallback: number): number => {
  const n = Number(v);
  return Number.isFinite(n) ? Math.min(hi, Math.max(lo, n)) : fallback;
};
const cleanStr = (v: unknown, max: number): string => String(v ?? '').trim().slice(0, max);

/** Keep creative-layer ids + strip no-ops so payloads stay compact. */
export function sanitizeEditMeta(meta: EditMeta | undefined | null): Record<string, unknown> | undefined {
  if (!meta) return undefined;
  const out: Record<string, unknown> = {};
  if (meta.filter) {
    out.filter = cleanStr(meta.filter, 32);
    const strength = clampNum(meta.filter_strength ?? 100, 0, 100, 100);
    if (strength !== 100) out.filter_strength = strength;
  }
  if (meta.speed && meta.speed !== 1) out.speed = clampNum(meta.speed, 0.3, 3, 1);
  if (meta.volume != null && meta.volume !== 100) out.volume = clampNum(meta.volume, 0, 200, 100);
  if (meta.enhance) out.enhance = true;
  if (meta.voice_effect && meta.voice_effect !== 'none') out.voice_effect = meta.voice_effect;
  const adjust = meta.adjust;
  if (adjust && [adjust.brightness, adjust.contrast, adjust.saturation].some((v) => v != null && v !== 50) || adjust?.vignette) {
    const cleaned: Record<string, number> = {};
    if (adjust.brightness !== 50) cleaned.brightness = clampNum(adjust.brightness, 0, 100, 50);
    if (adjust.contrast !== 50) cleaned.contrast = clampNum(adjust.contrast, 0, 100, 50);
    if (adjust.saturation !== 50) cleaned.saturation = clampNum(adjust.saturation, 0, 100, 50);
    if (adjust.vignette) cleaned.vignette = clampNum(adjust.vignette, 0, 100, 0);
    if (Object.keys(cleaned).length) out.adjust = cleaned;
  }
  if (meta.aspect && meta.aspect !== 'original') {
    out.aspect = meta.aspect;
    out.focus_y = clampNum(meta.focus_y ?? 50, 0, 100, 50);
  }
  const overlays = (meta.textOverlays || [])
    .filter((o) => o.text.trim() && o.end_ms > o.start_ms)
    .slice(0, 50)
    .map((o) => {
      const ov: Record<string, unknown> = {
        id: o.id,
        text: cleanStr(o.text, 200), start_ms: o.start_ms, end_ms: o.end_ms, y: clampNum(o.y, 0, 100, 80),
        size: clampNum(o.size, 0, 2, 1), color: cleanStr(o.color, 16) || 'white',
      };
      if (o.x != null) ov.x = clampNum(o.x, 0, 100, 50);
      if (o.rotation) ov.rotation = clampNum(o.rotation, -15, 15, 0);
      if (o.font && o.font !== 'classic') ov.font = cleanStr(o.font, 24);
      if (o.effect && o.effect !== 'none' && TEXT_EFFECTS.some((fx) => fx.id === o.effect)) ov.effect = o.effect;
      if (o.bg && o.bg !== 'none') ov.bg = o.bg;
      if (o.bg_color) ov.bg_color = cleanStr(o.bg_color, 32);
      if (o.animation && o.animation !== 'none') ov.animation = o.animation;
      return ov;
    });
  if (overlays.length) out.text_overlays = overlays;
  const stickers = (meta.stickers || [])
    .filter((s) => ((s.kind === 'emoji' || s.kind === 'mention') ? !!s.content : true) && s.end_ms > s.start_ms)
    .slice(0, 12)
    .map((s) => ({
      id: s.id,
      kind: s.kind === 'emoji' || s.kind === 'countdown' || s.kind === 'mention' ? s.kind : 'emoji',
      content: cleanStr(s.content, s.kind === 'emoji' ? 8 : 60),
      x: clampNum(s.x, 0, 100, 50), y: clampNum(s.y, 0, 100, 50),
      start_ms: s.start_ms, end_ms: s.end_ms, scale: clampNum(s.scale, 0.5, 2, 1),
    }));
  if (stickers.length) out.stickers = stickers;
  const tracks = (meta.audioTracks || [])
    .filter((t) => (t.kind === 'sound' && !!t.sound_id) || !!t.url)
    .slice(0, 3)
    .map((t) => {
      const tr: Record<string, unknown> = {
        kind: t.kind,
        volume: clampNum(t.volume, 0, 200, 100),
        start_ms: clampNum(t.start_ms, 0, Infinity, 0),
      };
      if (t.sound_id) tr.sound_id = t.sound_id;
      if (t.url) tr.url = cleanStr(t.url, 1000);
      if (t.duration_ms != null) tr.duration_ms = clampNum(t.duration_ms, 0, MAX_TRIM_MS, 0);
      if (t.effect && t.effect !== 'none') tr.effect = t.effect;
      if (t.fade_in_ms) tr.fade_in_ms = clampNum(t.fade_in_ms, 0, 10_000, 0);
      if (t.fade_out_ms) tr.fade_out_ms = clampNum(t.fade_out_ms, 0, 10_000, 0);
      if (t.ducking) tr.ducking = true;
      if (t.label) tr.label = cleanStr(t.label, 60);
      return tr;
    });
  if (tracks.length) out.audio_tracks = tracks;
  if (meta.captions_style) {
    const cs = meta.captions_style;
    out.captions_style = {
      preset: cleanStr(cs.preset, 24) || 'classic',
      ...(cs.font ? { font: cleanStr(cs.font, 24) } : {}),
      ...(cs.size != null ? { size: clampNum(cs.size, 0.8, 1.6, 1) } : {}),
      ...(cs.color ? { color: cleanStr(cs.color, 16) } : {}),
      ...(cs.bg ? { bg: cs.bg } : {}),
      ...(cs.placement && cs.placement !== 'bottom' ? { placement: cs.placement } : {}),
    };
  }
  return Object.keys(out).length ? out : undefined;
}

export interface PublishableMediaItem {
  kind: 'image' | 'video';
  media: UploadedMedia;
  trim_start_ms?: number | null;
  trim_end_ms?: number | null;
  editMeta?: EditMeta | null;
  captions?: PublishableCaption[] | null;
  sound?: {
    id: string;
    volume: number;
    /** Offset into the sound where playback starts (ms, parametric). */
    start_ms?: number | null;
    /** Fade in/out lengths in ms (0 = none, parametric). */
    fade_in_ms?: number | null;
    fade_out_ms?: number | null;
  } | null;
  alt_text?: string | null;
  coverOffsetSec?: number | null;
}

export interface PublishableCaption {
  start_ms: number;
  end_ms: number;
  text: string;
}

export interface MediaPayloadItem {
  url: string;
  media_type: 'image' | 'video';
  width?: number;
  height?: number;
  duration_ms?: number;
  poster_url?: string;
  trim_start_ms?: number;
  trim_end_ms?: number;
  edit_meta?: Record<string, unknown>;
  captions?: PublishableCaption[];
  sound_id?: string;
  sound_volume?: number;
  sound_start_ms?: number;
  sound_fade_in_ms?: number;
  sound_fade_out_ms?: number;
  alt_text?: string;
}

/** Build the `media` JSON array sent to POST /feed/create/ (max 12 items). */
export function buildMediaPayload(items: PublishableMediaItem[]): MediaPayloadItem[] {
  return items.slice(0, MAX_MEDIA_ITEMS).map((item) => {
    const out: MediaPayloadItem = {
      url: item.media.url,
      media_type: item.kind,
    };
    if (item.media.width != null) out.width = item.media.width;
    if (item.media.height != null) out.height = item.media.height;
    if (item.kind === 'video' && item.media.duration_ms != null) out.duration_ms = item.media.duration_ms;
    const poster = coverPosterUrl(item.media.url, item.coverOffsetSec) ?? item.media.poster_url;
    if (poster) out.poster_url = poster;
    if (item.kind === 'video') {
      if (item.trim_start_ms != null && item.trim_start_ms > 0) out.trim_start_ms = item.trim_start_ms;
      if (item.trim_end_ms != null && item.trim_end_ms > 0) out.trim_end_ms = item.trim_end_ms;
      const editMeta = sanitizeEditMeta(item.editMeta);
      if (editMeta) out.edit_meta = editMeta;
      const captions = (item.captions || [])
        .filter((c) => c.text.trim() && c.end_ms > c.start_ms)
        .slice(0, 500)
        .map((c) => ({
          start_ms: Math.max(0, Math.round(c.start_ms)),
          end_ms: Math.max(0, Math.round(c.end_ms)),
          text: c.text.trim().slice(0, 500),
        }));
      if (captions.length) out.captions = captions;
      if (item.sound) {
        out.sound_id = item.sound.id;
        out.sound_volume = item.sound.volume;
        // Parametric sound placement (ignored by older backends, kept for
        // forward-compat — never affects the required sound_id/volume pair).
        if (item.sound.start_ms) out.sound_start_ms = Math.max(0, Math.round(item.sound.start_ms));
        if (item.sound.fade_in_ms) out.sound_fade_in_ms = Math.max(0, Math.round(item.sound.fade_in_ms));
        if (item.sound.fade_out_ms) out.sound_fade_out_ms = Math.max(0, Math.round(item.sound.fade_out_ms));
      }
    }
    if (item.alt_text) out.alt_text = item.alt_text;
    return out;
  });
}

// ─── Split-at-playhead (TikTok-style clip splitting) ─────────────────────────

export interface SplitRange {
  start_ms: number;
  end_ms: number;
}

/**
 * Partition timed creative elements between two split halves. Each element
 * is assigned to the range containing its midpoint; boundary-spanning
 * elements are dropped from #1 and — per TikTok behaviour — re-anchor on
 * the half that keeps the majority of their run.
 */
export function partitionTimedElements<T extends { start_ms: number; end_ms: number }>(
  elements: T[],
  ranges: SplitRange[],
): T[][] {
  return ranges.map((range) =>
    elements.filter((el) => {
      const mid = (el.start_ms + el.end_ms) / 2;
      return mid >= range.start_ms && mid < range.end_ms;
    }),
  );
}

/** Split a trim range at `atMs` (clamped 100 ms away from either edge). */
export function splitTrim(trim: SplitRange, atMs?: number): [SplitRange, SplitRange] {
  const at = Math.max(
    trim.start_ms + 100,
    Math.min(trim.end_ms - 100, atMs != null && Number.isFinite(atMs) ? atMs : (trim.start_ms + trim.end_ms) / 2),
  );
  return [
    { start_ms: trim.start_ms, end_ms: Math.round(at) },
    { start_ms: Math.round(at), end_ms: trim.end_ms },
  ];
}

export interface TrimExportPlan {
  start_ms: number;
  end_ms: number;
  duration_ms: number;
}

/**
 * Normalize a trim for physical export. Returns null when the selection is
 * missing, invalid, or too short to re-encode reliably.
 */
export function normalizeTrimExport(
  startMs: number | null | undefined,
  endMs: number | null | undefined,
  durationMs: number | null | undefined,
): TrimExportPlan | null {
  const duration = Math.round(durationMs ?? 0);
  if (!Number.isFinite(duration) || duration <= 0) return null;
  const start = Math.round(Math.min(Math.max(0, startMs ?? 0), duration));
  const end = Math.round(Math.min(Math.max(0, endMs ?? 0), duration));
  if (end - start < 300) return null;
  return { start_ms: start, end_ms: end, duration_ms: end - start };
}

/** True when the trim removes enough footage to justify a physical export. */
export function shouldExportTrimmedVideo(plan: TrimExportPlan | null, toleranceMs = 250): boolean {
  if (!plan) return false;
  return plan.start_ms > toleranceMs || plan.end_ms < plan.duration_ms - toleranceMs;
}

/** Target a similar quality to the source without exceeding sane bounds. */
export function trimmedVideoBitrate(
  fileSizeBytes: number | null | undefined,
  segmentMs: number,
  sourceDurationMs?: number | null,
): number {
  const segmentSec = segmentMs / 1000;
  const sourceSec = (sourceDurationMs ?? segmentMs) / 1000;
  if (fileSizeBytes && fileSizeBytes > 0 && segmentSec > 0 && sourceSec > 0) {
    return Math.round(Math.min(8_000_000, Math.max(1_000_000, ((fileSizeBytes * 8) / sourceSec) * 0.9)));
  }
  return 4_000_000;
}

export function trimmedVideoFilename(name: string, mimeType: string): string {
  const base = (name || 'video').replace(/\.[^.]+$/, '') || 'video';
  const ext = mimeType.includes('mp4') ? 'mp4' : 'webm';
  return `${base}-trim.${ext}`;
}

/** Shift absolute timeline metadata into trimmed-snippet coordinates. */
export function rebaseTimedSegments<T extends { start_ms: number; end_ms: number }>(
  segments: T[],
  offsetMs: number,
  durationMs: number,
): T[] {
  return segments
    .map((segment) => ({
      ...segment,
      start_ms: Math.round(segment.start_ms - offsetMs),
      end_ms: Math.round(segment.end_ms - offsetMs),
    }))
    .filter((segment) => segment.end_ms > 0 && segment.start_ms < durationMs)
    .map((segment) => ({
      ...segment,
      start_ms: Math.min(Math.max(0, segment.start_ms), durationMs),
      end_ms: Math.min(Math.max(0, segment.end_ms), durationMs),
    }))
    .filter((segment) => segment.end_ms > segment.start_ms);
}

/** Re-anchor all timed edit metadata after a physical trim export. */
export function rebaseEditMetaForTrimmedVideo(meta: EditMeta, offsetMs: number, durationMs: number): EditMeta {
  return {
    ...meta,
    textOverlays: rebaseTimedSegments(meta.textOverlays, offsetMs, durationMs),
    stickers: rebaseTimedSegments(meta.stickers || [], offsetMs, durationMs),
    audioTracks: (meta.audioTracks || [])
      .map((track) => {
        const start = track.start_ms - offsetMs;
        if (track.duration_ms == null) {
          if (start >= durationMs) return null;
          return { ...track, start_ms: Math.max(0, start) };
        }
        const end = start + track.duration_ms;
        if (end <= 0 || start >= durationMs) return null;
        const nextStart = Math.min(Math.max(0, start), durationMs);
        const nextEnd = Math.min(Math.max(0, end), durationMs);
        return { ...track, start_ms: nextStart, duration_ms: Math.max(0, nextEnd - nextStart) };
      })
      .filter((track): track is AudioTrack => track != null && (track.duration_ms ?? 1) > 0),
  };
}

/** Convert an absolute cover timestamp into trimmed-snippet coordinates. */
export function rebaseCoverOffsetSeconds(
  offsetSec: number | null | undefined,
  offsetMs: number,
  durationMs: number,
): number | null {
  if (offsetSec == null || !Number.isFinite(offsetSec)) return offsetSec ?? null;
  return Math.min(Math.max(0, offsetSec - offsetMs / 1000), durationMs / 1000);
}

// ─── Publish state machine ───────────────────────────────────────────────────
//
// Publish runs as a TikTok-style pipeline: Finalize (prepare local files) →
// Upload (sequential, byte-accurate progress) → Create (POST /feed/create/).
// The reducer is pure so the pipeline can be unit tested without a DOM.

export type PublishStage = 'idle' | 'finalizing' | 'uploading' | 'creating' | 'done';

export interface PublishUploadItem {
  id: string;
  name: string;
  kind: 'image' | 'video';
  status: 'pending' | 'uploading' | 'done' | 'error';
  loadedBytes: number;
  totalBytes: number;
  /** Server-provided failure reason when status === 'error'. */
  message?: string;
}

export interface PublishState {
  stage: PublishStage;
  items: PublishUploadItem[];
  /** Item currently uploading (or the one that failed and awaits retry). */
  activeId: string | null;
  error: string | null;
}

export type PublishAction =
  | { type: 'start' }
  | { type: 'finalized' }
  | { type: 'itemStart'; id: string }
  | { type: 'itemProgress'; id: string; loadedBytes: number; totalBytes: number }
  | { type: 'itemDone'; id: string }
  | { type: 'itemError'; id: string; message: string }
  | { type: 'itemRetry'; id: string }
  | { type: 'cancel' }
  | { type: 'creating' }
  | { type: 'createError'; message: string }
  | { type: 'done' };

export interface PublishPlanItem {
  id: string;
  name: string;
  kind: 'image' | 'video';
  size: number;
}

/** Fresh state for a publish run: every item queued, nothing sent yet. */
export function createPublishState(items: PublishPlanItem[]): PublishState {
  return {
    stage: 'idle',
    items: items.map((it) => ({
      id: it.id,
      name: it.name,
      kind: it.kind,
      status: 'pending' as const,
      loadedBytes: 0,
      totalBytes: it.size,
    })),
    activeId: null,
    error: null,
  };
}

function nextPendingId(items: PublishUploadItem[]): string | null {
  return items.find((it) => it.status === 'pending')?.id ?? null;
}

/** Advance the publish pipeline. Unknown ids on progress actions are no-ops. */
export function publishReducer(state: PublishState, action: PublishAction): PublishState {
  switch (action.type) {
    case 'start':
      return { ...state, stage: 'finalizing', error: null };
    case 'finalized':
      return { ...state, stage: 'uploading', activeId: nextPendingId(state.items) };
    case 'itemStart':
      return {
        ...state,
        stage: 'uploading',
        activeId: action.id,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'uploading', message: undefined } : it,
        ),
      };
    case 'itemProgress':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id
            ? { ...it, loadedBytes: action.loadedBytes, totalBytes: action.totalBytes }
            : it,
        ),
      };
    case 'itemDone':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id
            ? { ...it, status: 'done', loadedBytes: it.totalBytes, message: undefined }
            : it,
        ),
        activeId: nextPendingId(state.items),
      };
    case 'itemError':
      return {
        ...state,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'error', message: action.message } : it,
        ),
        activeId: action.id,
        error: action.message,
      };
    case 'itemRetry':
      return {
        ...state,
        error: null,
        activeId: action.id,
        items: state.items.map((it) =>
          it.id === action.id ? { ...it, status: 'uploading', message: undefined } : it,
        ),
      };
    case 'cancel':
      return createPublishState(
        state.items.map((it) => ({
          id: it.id,
          name: it.name,
          kind: it.kind,
          size: it.totalBytes,
        })),
      );
    case 'creating':
      return { ...state, stage: 'creating', error: null };
    case 'createError':
      return { ...state, stage: 'creating', error: action.message };
    case 'done':
      return { ...state, stage: 'done', error: null };
    default:
      return state;
  }
}

/** Overall publish progress 0–100 from bytes sent across all items. */
export function publishOverallProgress(state: PublishState): number {
  const totalBytes = state.items.reduce((sum, it) => sum + it.totalBytes, 0);
  if (totalBytes <= 0) return state.stage === 'done' ? 100 : 0;
  const loadedBytes = state.items.reduce((sum, it) => sum + it.loadedBytes, 0);
  return Math.min(100, Math.floor((loadedBytes / totalBytes) * 100));
}

/** Per-item percentage 0–100 for the active upload readout. */
export function publishItemPct(item: PublishUploadItem): number {
  if (item.status === 'done') return 100;
  if (item.totalBytes <= 0) return 0;
  return Math.min(100, Math.floor((item.loadedBytes / item.totalBytes) * 100));
}

/** Bytes → "12.4 MB" for the upload readout. */
export function formatMb(bytes: number): string {
  return `${(Math.max(0, bytes) / (1024 * 1024)).toFixed(1)} MB`;
}

// ─── Per-clip captions (multiclip Bud Press studio) ──────────────────────────
//
// Captions are owned per video item: captionsByItem[videoItemId] holds that
// clip's segments in ABSOLUTE media coordinates (matching trim thumbs and the
// preview clock). Publish rebases each list into its trimmed upload via
// rebaseTimedSegments; split/duplicate/delete/reorder move ownership with the
// clip. The feed payload shape per item ({start_ms,end_ms,text}) is unchanged.

export interface StudioCaption {
  id: string;
  start_ms: number;
  end_ms: number;
  text: string;
}

export type CaptionsByItem = Record<string, StudioCaption[]>;

export function newCaptionId(): string {
  try {
    return crypto.randomUUID();
  } catch {
    return `cap-${Date.now()}-${Math.floor(Math.random() * 1e9)}`;
  }
}

/** Drop empty/invalid lines and normalize numbers for publish or storage. */
export function cleanCaptionSegments<T extends { start_ms: number; end_ms: number; text: string }>(
  segments: T[],
): PublishableCaption[] {
  return (segments || [])
    .filter((s) => s.text.trim() && s.end_ms > s.start_ms)
    .map(({ start_ms, end_ms, text }) => ({
      start_ms: Math.max(0, Math.round(start_ms)),
      end_ms: Math.max(0, Math.round(end_ms)),
      text: text.trim().slice(0, 500),
    }))
    .filter((s) => s.end_ms > s.start_ms)
    .slice(0, 500);
}

export interface TrimOffsetInfo {
  offsetMs: number;
  durationMs: number;
  exported: boolean;
}

/**
 * Plan per-item publish captions: clean every clip's list, then rebase the
 * lists of clips whose upload is a physically trimmed snippet back into
 * snippet coordinates. Clips without captions (or rebased to nothing) are
 * omitted — the payload shape per item is unchanged.
 */
export function planCaptionsForItems<T extends { start_ms: number; end_ms: number; text: string }>(
  captionsByItem: Record<string, T[]>,
  trimOffsets: Map<string, TrimOffsetInfo> | Record<string, TrimOffsetInfo>,
): Record<string, PublishableCaption[]> {
  const out: Record<string, PublishableCaption[]> = {};
  const lookup = (id: string): TrimOffsetInfo | undefined =>
    trimOffsets instanceof Map ? trimOffsets.get(id) : trimOffsets[id];
  for (const [itemId, segments] of Object.entries(captionsByItem || {})) {
    const cleaned = cleanCaptionSegments(segments || []);
    if (cleaned.length === 0) continue;
    const trim = lookup(itemId);
    const rebased = trim?.exported
      ? rebaseTimedSegments(cleaned, trim.offsetMs, trim.durationMs)
      : cleaned;
    if (rebased.length > 0) out[itemId] = rebased;
  }
  return out;
}

/**
 * Partition one clip's captions across a split (midpoint rule — same as
 * text/sticker overlays). Segment ids are preserved: the halves are disjoint
 * so ids stay unique per resulting list.
 */
export function partitionCaptionsForSplit<T extends { start_ms: number; end_ms: number }>(
  captions: T[],
  left: SplitRange,
  right: SplitRange,
): [T[], T[]] {
  const [l, r] = partitionTimedElements(captions || [], [left, right]);
  return [l, r];
}

/** Deep-clone a caption list with fresh ids (clip duplicate). */
export function cloneCaptionSegments<T extends { start_ms: number; end_ms: number; text: string }>(
  segments: T[],
): StudioCaption[] {
  return (segments || []).map((s) => ({
    id: newCaptionId(),
    start_ms: s.start_ms,
    end_ms: s.end_ms,
    text: s.text,
  }));
}

export function countCaptions(captionsByItem: CaptionsByItem | undefined | null, itemId: string): number {
  return captionsByItem?.[itemId]?.length ?? 0;
}

// ─── Upload-planning helpers ─────────────────────────────────────────────────

/**
 * Stable fingerprint for a picked file (trim-cache keys + resumable-upload
 * session records). Name+size+type+mtime identifies the source bytes well
 * enough for a local cache; collisions only waste an export, never corrupt.
 */
export function fingerprintFile(file: { name: string; size: number; type: string; lastModified?: number }): string {
  return [file.name ?? '', file.size ?? 0, file.type ?? '', file.lastModified ?? 0].join('|');
}

/** Cache key for a trimmed export: source fingerprint + exact trim bounds. */
export function trimCacheKeyFor(fingerprint: string, startMs: number, endMs: number): string {
  return `${fingerprint}::${Math.round(startMs)}-${Math.round(endMs)}`;
}

// ─── Bounded undo/redo ───────────────────────────────────────────────────────
//
// The studio stores immutable snapshots (React state is never mutated in
// place, so keeping the previous reference is safe). Covers trim, text,
// stickers, captions, audio, filter and speed — everything that flows through
// the snapshot the caller builds. Capped so long sessions stay small.

export const STUDIO_HISTORY_LIMIT = 50;

export class UndoStack<T> {
  private past: T[] = [];
  private future: T[] = [];
  constructor(private readonly limit: number = STUDIO_HISTORY_LIMIT) {}

  get canUndo(): boolean {
    return this.past.length > 0;
  }

  get canRedo(): boolean {
    return this.future.length > 0;
  }

  get depth(): number {
    return this.past.length;
  }

  /** Record the CURRENT state before a mutation; clears the redo branch. */
  push(state: T): void {
    this.past.push(state);
    if (this.past.length > this.limit) this.past.splice(0, this.past.length - this.limit);
    this.future = [];
  }

  /**
   * Push without clearing redo — for high-frequency updates (trim drags,
   * sliders) so a drag burst stays one undo step per pause.
   */
  pushCoalesced(state: T): void {
    this.past.push(state);
    if (this.past.length > this.limit) this.past.splice(0, this.past.length - this.limit);
  }

  undo(current: T): T | null {
    const prev = this.past.pop();
    if (prev === undefined) return null;
    this.future.push(current);
    return prev;
  }

  redo(current: T): T | null {
    const next = this.future.pop();
    if (next === undefined) return null;
    this.past.push(current);
    if (this.past.length > this.limit) this.past.splice(0, this.past.length - this.limit);
    return next;
  }

  clear(): void {
    this.past = [];
    this.future = [];
  }
}
