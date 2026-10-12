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

export type BadgeVariant = 'blue' | 'silver' | 'green' | 'gold' | 'orange' | 'red' | 'electric';

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

/**
 * Coarse "3d 4h" / "2h 15m" / "40s" span.
 *
 * Deliberately two units at most. A moderator scanning a queue needs "is this
 * close or not", and a minute-accurate countdown on an SLA is a number they
 * cannot act on differently from a rounded one.
 */
export function formatDuration(seconds: unknown): string {
  const total = typeof seconds === 'number' ? seconds : Number(seconds);
  if (!Number.isFinite(total)) return '—';
  const s = Math.max(0, Math.floor(total));
  if (s < 60) return `${s}s`;
  const minutes = Math.floor(s / 60);
  if (minutes < 60) {
    const rem = s % 60;
    return rem ? `${minutes}m ${rem}s` : `${minutes}m`;
  }
  const hours = Math.floor(minutes / 60);
  if (hours < 48) {
    const rem = minutes % 60;
    return rem ? `${hours}h ${rem}m` : `${hours}h`;
  }
  return `${Math.floor(hours / 24)}d ${hours % 24}h`;
}

export interface SlaState {
  /** True when the target has passed, or the server has already said so. */
  overdue: boolean;
  /** Human text for the badge: "3h 20m left" / "1h 12m overdue" / "—". */
  label: string;
  variant: BadgeVariant;
}

/**
 * The state of a moderation report's response target.
 *
 * Two inputs, and the server's word wins: `sla_breached` is computed by the
 * backend at serialisation time, so it is authoritative even when this client's
 * clock is wrong or `sla_due_at` is missing. The countdown is only a reading
 * aid, and a missing due date renders as a neutral "No SLA" rather than a
 * fabricated zero.
 */
export function slaState(dueAt: unknown, breached: unknown, now: number = Date.now()): SlaState {
  const serverBreached = breached === true;
  const iso = typeof dueAt === 'string' ? dueAt : '';
  const due = iso ? new Date(iso).getTime() : NaN;
  if (Number.isNaN(due)) {
    return serverBreached
      ? { overdue: true, label: 'SLA breached', variant: 'red' }
      : { overdue: false, label: 'No SLA', variant: 'silver' };
  }
  const remainingMs = due - now;
  const overdue = serverBreached || remainingMs < 0;
  const seconds = Math.abs(remainingMs) / 1000;
  // Under an hour left is the point at which a moderator should reorder their
  // queue, so it gets its own tone rather than sharing the calm blue.
  const urgent = !overdue && seconds < 3600;
  return {
    overdue,
    label: `${formatDuration(seconds)} ${overdue ? 'overdue' : 'left'}`,
    variant: overdue ? 'red' : urgent ? 'orange' : 'blue',
  };
}