/**
 * CreativeLayer — the one true renderer for TikTok-style parametric edits:
 * timed text overlays (font/bg/animation/x/rotation), stickers (emoji,
 * countdown, mention) and synced captions. Used by the create-studio
 * preview AND the feed players so edits render identically everywhere.
 *
 * Consumes the server-shaped PostEditMeta (build it client-side with
 * sanitizeEditMeta from lib/createStudio).
 */
import type { CSSProperties, ReactNode } from 'react';
import {
  TEXT_COLOR_VALUES,
  fontFamilyCss,
  textEffectCss,
} from '@/lib/createStudio';

type EditMetaLike = {
  text_overlays?: CreativeOverlay[] | null;
  stickers?: CreativeSticker[] | null;
  captions_style?: { preset?: string; font?: string; size?: number; color?: string; bg?: string; placement?: string } | null;
};

interface CreativeOverlay {
  id?: string;
  text: string;
  start_ms: number;
  end_ms: number;
  y: number;
  x?: number;
  rotation?: number;
  size: number;
  color: string;
  font?: string;
  effect?: string;
  bg?: string;
  bg_color?: string;
  animation?: string;
}

interface CreativeSticker {
  id?: string;
  kind: 'emoji' | 'countdown' | 'mention';
  content: string;
  x: number;
  y: number;
  start_ms: number;
  end_ms: number;
  scale: number;
}

const overlayPx = (size: number): number => Math.round(12 * Math.pow(1.85, Math.max(0, Math.min(2, size))));

function animClass(anim: string | undefined): string {
  switch (anim) {
    case 'fade': return 'creative-anim-fade';
    case 'pop': return 'creative-anim-pop';
    case 'slide': return 'creative-anim-slide';
    default: return '';
  }
}

function overlayBackground(ov: CreativeOverlay): CSSProperties {
  if (ov.bg === 'pill' || ov.bg === 'block') {
    return {
      background: ov.bg_color || 'rgba(0,0,0,0.55)',
      borderRadius: ov.bg === 'pill' ? 999 : 8,
      padding: ov.bg === 'pill' ? '3px 10px' : '4px 8px',
    };
  }
  return {};
}

export interface CreativeLayerProps {
  /** Server-shaped edit metadata (sanitizeEditMeta output / PostEditMeta). */
  meta?: EditMetaLike | null;
  /** Playback position in ms of the underlying media (absolute media time). */
  timeMs: number;
  /** Caption segment active at timeMs (optional). */
  activeCaption?: { text: string } | null;
  /** Additional children rendered above the layer. */
  children?: ReactNode;
  /** Editor mode: items become tappable/draggable (feed keeps them inert). */
  interactive?: boolean;
  /** Editor-only ids of the item being edited (dashed outline). */
  selectedId?: string | null;
  onOverlayPointerDown?: (id: string, e: React.PointerEvent) => void;
  onStickerPointerDown?: (id: string, e: React.PointerEvent) => void;
}

export function CreativeLayer({
  meta, timeMs, activeCaption, children,
  interactive = false, selectedId, onOverlayPointerDown, onStickerPointerDown,
}: CreativeLayerProps) {
  const overlays = meta?.text_overlays?.filter(
    (o) => timeMs >= o.start_ms - 60 && timeMs <= o.end_ms + 60,
  ) ?? [];
  const stickers = meta?.stickers?.filter(
    (s) => timeMs >= s.start_ms - 40 && timeMs <= s.end_ms + 40,
  ) ?? [];

  return (
    <div className={`absolute inset-0 overflow-hidden ${interactive ? '' : 'pointer-events-none'}`} data-testid="creative-layer">
      {stickers.map((s, i) => {
        const selected = interactive && !!s.id && s.id === selectedId;
        return (
          <span
            key={s.id ?? `s-${i}`}
            onPointerDown={interactive && s.id ? (e) => onStickerPointerDown?.(s.id as string, e) : undefined}
            className="absolute leading-none select-none cursor-move"
            style={{
              left: `${s.x ?? 50}%`,
              top: `${s.y ?? 50}%`,
              transform: 'translate(-50%, -50%)',
              fontSize: Math.round(26 * (s.scale || 1)),
              outline: selected ? '1.5px dashed rgba(255,255,255,0.9)' : undefined,
              borderRadius: 4,
            }}
          >
            {s.kind === 'countdown'
              ? Math.max(0, Math.ceil((s.end_ms - timeMs) / 1000))
              : s.kind === 'mention'
                ? `@${s.content}`
                : s.content}
          </span>
        );
      })}
      {overlays.map((ov, i) => {
        const selected = interactive && !!ov.id && ov.id === selectedId;
        const effectStyle = textEffectCss(ov.effect ?? (ov.bg ? undefined : 'shadow'), TEXT_COLOR_VALUES[ov.color] ?? ov.color ?? '#FFFFFF');
        return (
    <span
      key={ov.id ?? `o-${i}`}
      onPointerDown={interactive && ov.id ? (e) => {
        e.stopPropagation();
        (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
        onOverlayPointerDown?.(ov.id as string, e);
      } : undefined}
      className={`absolute z-10 font-heading font-semibold text-center leading-snug max-w-[92%] ${animClass(ov.animation)}`}
      style={{
        left: `${ov.x ?? 50}%`,
        top: `${ov.y}%`,
        transform: `translate(-50%, -50%) rotate(${ov.rotation ?? 0}deg)`,
        fontFamily: ov.font ? fontFamilyCss(ov.font) : undefined,
        fontSize: overlayPx(ov.size),
        ...effectStyle,
        outline: selected ? '1.5px dashed rgba(255,255,255,0.9)' : undefined,
        outlineOffset: 2,
        cursor: interactive ? 'move' : undefined,
        ...overlayBackground(ov),
      }}
    >
      {ov.text}
    </span>
        );
      })}
      {activeCaption?.text && <CaptionBubble caption={activeCaption.text} meta={meta} />}
      {children}
    </div>
  );
}

function CaptionBubble({ caption, meta }: { caption: string; meta?: EditMetaLike | null }) {
  const style = meta?.captions_style ?? {};
  const placement = style.placement === 'top' || style.placement === 'center' ? style.placement : 'bottom';
  const posClass =
    placement === 'top' ? 'top-12 bottom-auto' : placement === 'center' ? 'top-1/2 bottom-auto -translate-y-1/2' : 'bottom-10';
  return (
    <p
      className={`absolute z-10 max-w-[90%] px-3 py-1.5 text-sm text-center whitespace-pre-wrap ${posClass} ${
        style.bg === 'pill' || style.bg === 'block' ? 'rounded-xl' : ''
      }`}
      style={{
        left: '50%',
        transform: placement === 'center' ? 'translate(-50%, -50%)' : 'translateX(-50%)',
        color: style.color || '#FFFFFF',
        fontFamily: style.font ? fontFamilyCss(style.font) : undefined,
        fontSize: style.size ? `calc(0.875rem * ${style.size})` : undefined,
        background: style.bg === 'block' ? 'rgba(0,0,0,0.45)' : (style.bg === 'pill' ? 'rgba(0,0,0,0.55)' : undefined),
        fontWeight: style.preset === 'karaoke' ? 800 : 600,
      }}
    >
      {caption}
    </p>
  );
}
