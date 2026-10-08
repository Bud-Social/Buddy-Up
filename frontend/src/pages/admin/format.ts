/**
 * Pure display helpers for the admin console.
 *
 * Deliberately a `.ts` module with no React imports: `shared.tsx` holds the
 * components, and keeping the formatters out of it satisfies
 * `react-refresh/only-export-components` (a file should export components only).
 *
 * Every helper is total — a missing, null or renamed field yields a readable
 * placeholder rather than throwing, so a contract drift degrades one cell
 * instead of blanking a page.
 */

type BadgeVariant = 'blue' | 'silver' | 'green' | 'gold' | 'orange' | 'red' | 'electric';

const STATUS_TONES: Array<{ match: RegExp; variant: BadgeVariant }> = [
  { match: /^(approved|active|completed|delivered|verified|succeeded|cleared|reconciled|paid|published)/i, variant: 'green' },
  { match: /^(pending|submitted|under_review|in_review|processing|held|partially_paid|requested|awaiting)/i, variant: 'orange' },
  { match: /^(rejected|failed|suspended|cancelled|canceled|expired|declined|unpaid|missing|discrepan)/i, variant: 'red' },
  { match: /^(refunded|returned|archived|inactive|draft|deactivated|disabled)/i, variant: 'silver' },
  { match: /^(shipped|out_for_delivery|ready_for_pickup|in_transit)/i, variant: 'blue' },
  { match: /(none|unknown|not_|null)/i, variant: 'silver' },
];

/** Map an arbitrary backend status string onto the Badge palette. */
export function statusVariant(status: unknown): BadgeVariant {
  if (typeof status !== 'string' || !status.trim()) return 'silver';
  const hit = STATUS_TONES.find((t) => t.match.test(status.trim()));
  return hit ? hit.variant : 'silver';
}

export function statusLabel(status: unknown): string {
  if (typeof status !== 'string' || !status.trim()) return 'Unknown';
  return status.trim().replace(/_/g, ' ');
}

/** Money: accepts a number or numeric string; em dash for null/undefined/''. */
export function formatMoney(value: unknown, currency = 'USD'): string {
  const n = typeof value === 'number' ? value : typeof value === 'string' ? Number(value) : NaN;
  if (!Number.isFinite(n)) return '—';
  try {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(n);
  } catch {
    return `${n.toFixed(2)} ${currency}`;
  }
}

/** Date: em dash for missing/invalid values instead of "Invalid Date". */
export function formatDate(value: unknown, withTime = true): string {
  if (typeof value !== 'string' || !value) return '—';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  return withTime ? d.toLocaleString() : d.toLocaleDateString();
}

export function formatCount(value: unknown): string {
  return typeof value === 'number' && Number.isFinite(value) ? value.toLocaleString() : '—';
}

/** Display value for a possibly-missing text field. */
export function text(value: unknown, fallback = '—'): string {
  if (typeof value === 'string') return value.trim() || fallback;
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  return fallback;
}

export function shortId(id: unknown): string {
  return typeof id === 'string' && id ? `#${id.slice(0, 8)}` : '—';
}