import type { MouseEvent, ReactNode } from 'react';

/** Compact human-readable counter (1200 -> "1.2k"). Pure helper, unit-tested. */
export function formatCount(n: number | null | undefined): string {
  const v = n ?? 0;
  if (v < 1000) return String(v);
  if (v < 10_000) return `${(Math.floor(v / 100) / 10).toString().replace(/\.0$/, '')}k`;
  if (v < 1_000_000) return `${Math.round(v / 1000)}k`;
  return `${(Math.floor(v / 100_000) / 10).toString().replace(/\.0$/, '')}M`;
}

export const RAIL_ICON_SIZE = 22;

/** Optimistic next-state when toggling `next` from the current reaction. Pure helper. */
export function nextReactionState(
  counts: Record<string, number>,
  userReaction: string | null,
  next: string,
): { counts: Record<string, number>; userReaction: string | null; removed: boolean } {
  const out = { ...counts };
  if (userReaction === next) {
    if (out[next] > 1) out[next]--;
    else delete out[next];
    return { counts: out, userReaction: null, removed: true };
  }
  if (userReaction && out[userReaction] !== undefined) {
    if (out[userReaction] > 1) out[userReaction]--;
    else delete out[userReaction];
  }
  out[next] = (out[next] || 0) + 1;
  return { counts: out, userReaction: next, removed: false };
}

/** Sum of all reaction counts. Pure helper. */
export function totalReactions(counts: Record<string, number> | undefined): number {
  if (!counts) return 0;
  return Object.values(counts).reduce((a, b) => a + b, 0);
}

interface RailActionProps {
  /** Fixed-size icon node (lucide icon at RAIL_ICON_SIZE, or an emoji image). */
  icon: ReactNode;
  /** Accessible label, e.g. "Like", "Comment". Required for a11y. */
  label: string;
  /** Counter value. `undefined` hides the counter (metric unavailable). */
  count?: number;
  /** Always render the counter row, even when 0 (keeps rails aligned). */
  showZero?: boolean;
  active?: boolean;
  /** Active-state color class. Defaults to buddy green. */
  activeClassName?: string;
  /** Dark-video-overlay styling (fullscreen rail) vs default feed styling. */
  tone?: 'default' | 'onDark';
  onClick?: (e: MouseEvent) => void;
  onContextMenu?: (e: MouseEvent) => void;
  title?: string;
  testId?: string;
}

/**
 * Shared feed rail button: 44px touch target, fixed icon size, tabular
 * counter typography, active state, a11y label. Used by the PostCard side
 * rail and the fullscreen right rail (tone="onDark").
 */
export function RailAction({
  icon,
  label,
  count,
  showZero = true,
  active = false,
  activeClassName,
  tone = 'default',
  onClick,
  onContextMenu,
  title,
  testId,
}: RailActionProps) {
  const activeColor = activeClassName ?? (tone === 'onDark' ? 'text-buddy-green' : 'text-buddy-green');
  const idleColor = tone === 'onDark'
    ? 'text-white hover:text-buddy-green'
    : 'text-buddy-text-secondary hover:text-buddy-green';
  const colorCls = active ? activeColor : idleColor;
  const showCount = count !== undefined && (showZero || count > 0);

  const inner = (
    <>
      <span
        className={`flex items-center justify-center rounded-full transition-colors ${
          tone === 'onDark' ? '' : 'group-hover:bg-buddy-green/10'
        }`}
        style={{ width: 44, height: 44 }}
      >
        <span className="flex items-center justify-center" style={{ width: RAIL_ICON_SIZE, height: RAIL_ICON_SIZE }}>
          {icon}
        </span>
      </span>
      {showCount && (
        <span
          data-testid={testId ? `${testId}-count` : undefined}
          className={`text-[11px] font-medium leading-none tabular-nums -mt-1.5 ${
            tone === 'onDark' ? 'text-white/90' : ''
          }`}
        >
          {formatCount(count)}
        </span>
      )}
    </>
  );

  const cls = `group flex min-w-[44px] min-h-[44px] flex-col items-center justify-center gap-0.5 transition-all ${colorCls}`;

  if (!onClick && !onContextMenu) {
    return (
      <span className={cls} role="img" aria-label={label} title={title ?? label} data-testid={testId}>
        {inner}
      </span>
    );
  }

  return (
    <button
      type="button"
      onClick={onClick}
      onContextMenu={onContextMenu}
      className={cls}
      aria-label={label}
      aria-pressed={onClick ? active : undefined}
      title={title ?? label}
      data-testid={testId}
    >
      {inner}
    </button>
  );
}
