/**
 * alarmSchedule — day-mask helpers shared by the Alarm Center and the
 * app-wide AlarmWatcher. Kept out of the page module so non-page code can
 * import it without pulling in the whole settings screen.
 */

export const DAY_LABELS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] as const;

/** Expand a bitmask into 7 booleans, Mon-first. */
export function maskToDays(mask: number): boolean[] {
  return DAY_LABELS.map((_, i) => Boolean(mask & (1 << i)));
}

/** Flip one day-bit (index 0=Mon … 6=Sun). */
export function toggleDayBit(mask: number, index: number): number {
  return mask ^ (1 << index);
}

/** Human summary: "Every day", "Weekdays", "Weekends", "Mon, Wed", "Once". */
export function formatDays(mask: number): string {
  if (mask === 0) return 'Once';
  if (mask === 127) return 'Every day';
  if (mask === 31) return 'Weekdays';
  if (mask === 96) return 'Weekends';
  return DAY_LABELS.filter((_, i) => mask & (1 << i)).join(', ');
}

/** Next Date matching a "HH:MM" time + days mask (mask 0 = next occurrence). */
export function nextFireDate(time: string, daysMask: number, from: Date = new Date()): Date | null {
  const m = /^(\d{1,2}):(\d{2})/.exec(time);
  if (!m) return null;
  const hh = Math.min(23, parseInt(m[1], 10));
  const mm = Math.min(59, parseInt(m[2], 10));
  for (let offset = 0; offset < 8; offset += 1) {
    const d = new Date(from);
    d.setDate(from.getDate() + offset);
    d.setHours(hh, mm, 0, 0);
    if (d <= from) continue;
    if (daysMask === 0) return d;
    const idx = (d.getDay() + 6) % 7; // Mon=0 … Sun=6
    if (daysMask & (1 << idx)) return d;
  }
  return null;
}
