/**
 * Countdown presentation helpers.
 *
 * The count a countdown shows, when the next check-in opens and how long
 * that is — kept out of the page so the rules can be tested on their own.
 *
 * The headline number is the *counter*: the number of units the user has
 * actually completed. The wall-clock length of the streak is a separate
 * number, because the two move at different times — a manual countdown only
 * counts when the user checks in, while an automatic one only counts when
 * its signal fires.
 */

import type { CountdownSignal, UserCountdown } from '@/types/countdowns';

export interface CheckInState {
  /** True when the check-in is still locked. */
  locked: boolean;
  /** When the check-in opens, or null when it is already open. */
  nextAt: Date | null;
  /** "23h 12m" — how long until it opens. */
  remaining: string;
  /** The button label. */
  label: string;
}

/** "23h 12m" / "12m" — a compact duration. */
export function formatDuration(seconds: number): string {
  const total = Math.max(0, Math.round(seconds));
  const days = Math.floor(total / 86400);
  const hours = Math.floor((total % 86400) / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  if (days > 0) return hours > 0 ? `${days}d ${hours}h` : `${days}d`;
  if (hours > 0) return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  if (minutes > 0) return `${minutes}m`;
  return `${total}s`;
}

/**
 * Whether a manual countdown can be checked in right now.
 *
 * A check-in unlocks once per unit: an hourly countdown every hour, a
 * daily one every 24 hours.
 */
export function checkInState(countdown: UserCountdown, now: Date = new Date()): CheckInState {
  if (countdown.countdown_type !== 'manual') {
    return { locked: true, nextAt: null, remaining: '', label: 'Automatic' };
  }
  const nextAtRaw = countdown.next_checkin_at;
  if (!nextAtRaw) {
    return { locked: false, nextAt: null, remaining: '', label: 'Check in' };
  }
  const nextAt = new Date(nextAtRaw);
  const seconds = (nextAt.getTime() - now.getTime()) / 1000;
  if (seconds <= 0) {
    return { locked: false, nextAt: null, remaining: '', label: 'Check in' };
  }
  return {
    locked: true,
    nextAt,
    remaining: formatDuration(seconds),
    label: `Opens in ${formatDuration(seconds)}`,
  };
}

/**
 * The number the countdown card leads with.
 *
 * The counter is what the user completed; the streak's wall-clock length is
 * shown alongside it so a countdown that has not been checked in recently
 * still reads honestly.
 */
export function countdownHeadline(countdown: UserCountdown): {
  value: number;
  unit: string;
  streakUnits: number;
} {
  return {
    value: countdown.current_count,
    unit: countdown.unit,
    streakUnits: countdown.elapsed_units ?? countdown.current_count,
  };
}

/** The label for an automatic countdown's signal, e.g. "A logged walk". */
export function signalLabel(
  signals: CountdownSignal[],
  key: string | null | undefined,
): string {
  if (!key) return 'Automatic';
  const found = signals.find((s) => s.key === key);
  if (found) return found.label;
  // Fall back to something readable when the signal list is unavailable.
  return key.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

/** The badge text for a countdown's type. */
export function typeTag(
  countdown: UserCountdown,
  signals: CountdownSignal[],
): { text: string; className: string } {
  if (countdown.countdown_type === 'automatic') {
    return {
      text: `Auto · ${signalLabel(signals, countdown.auto_advance_signal)}`,
      className: 'bg-buddy-electric/15 text-buddy-electric border border-buddy-electric/30',
    };
  }
  return {
    text: 'Manual',
    className: 'bg-buddy-surface text-buddy-text-secondary border border-buddy-border',
  };
}

/** Progress towards the target, as a percentage (0 when there is no target). */
export function progressPct(countdown: UserCountdown): number {
  if (!countdown.target_count) {
    // With no target the streak is measured against a 30-unit window.
    return Math.min(100, (countdown.current_count / 30) * 100);
  }
  return Math.min(100, (countdown.current_count / countdown.target_count) * 100);
}
