/**
 * shareWorkout — one share path for workout and activity rows.
 *
 * Prefers the native share sheet, falls back to copying the link, and never
 * throws: a failed share must not break the row it was tapped from.
 */

export type ShareOutcome = 'shared' | 'copied' | 'cancelled' | 'failed';

export interface ShareActivityInput {
  title: string;
  text: string;
  url: string;
}

/** Deep link into the analytics tab — `/app/analytics` redirects to it. */
export const ANALYTICS_PATH = '/app/analytics';

export function analyticsShareUrl(path: string = ANALYTICS_PATH, origin?: string): string {
  const base = origin ?? (typeof window !== 'undefined' ? window.location.origin : '');
  return `${base}${path}`;
}

export interface ShareFacts {
  label: string;
  category?: string | null;
  durationMinutes?: number | null;
  distanceKm?: number | null;
  calories?: number | null;
  detail?: string | null;
}

const round = (n: number): string => (n >= 10 ? String(Math.round(n)) : n.toFixed(1));

/** "Strength · Upper — 45 min · 320 kcal. Logged on BuddyUp." */
export function buildShareText({ label, category, durationMinutes, distanceKm, calories, detail }: ShareFacts): string {
  const head = [label, category].filter(Boolean).join(' · ');
  const bits: string[] = [];
  if (durationMinutes != null && durationMinutes > 0) bits.push(`${Math.round(durationMinutes)} min`);
  if (distanceKm != null && distanceKm > 0) bits.push(`${round(distanceKm)} km`);
  if (calories != null && calories > 0) bits.push(`${Math.round(calories)} kcal`);
  if (detail) bits.push(detail);
  const body = bits.length ? ` — ${bits.join(' · ')}` : '';
  return `${head}${body}. Logged on BuddyUp.`;
}

async function copyToClipboard(url: string): Promise<boolean> {
  try {
    if (typeof navigator !== 'undefined' && navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(url);
      return true;
    }
  } catch {
    // Permission denied or insecure context — try the legacy path below.
  }
  try {
    if (typeof document === 'undefined') return false;
    const ta = document.createElement('textarea');
    ta.value = url;
    ta.setAttribute('readonly', '');
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    const ok = document.execCommand('copy');
    document.body.removeChild(ta);
    return ok;
  } catch {
    return false;
  }
}

/**
 * Share via the OS sheet when the platform has one, otherwise copy the link.
 * Resolves to what happened; rejects nothing.
 */
export async function shareActivity({ title, text, url }: ShareActivityInput): Promise<ShareOutcome> {
  if (typeof navigator !== 'undefined' && typeof navigator.share === 'function') {
    try {
      await navigator.share({ title, text, url });
      return 'shared';
    } catch (err) {
      const name = (err as { name?: string } | null)?.name;
      if (name === 'AbortError') return 'cancelled';
      // A share sheet that throws for any other reason is still worth a copy.
      return (await copyToClipboard(url)) ? 'copied' : 'failed';
    }
  }
  return (await copyToClipboard(url)) ? 'copied' : 'failed';
}