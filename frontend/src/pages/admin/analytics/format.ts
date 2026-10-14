/**
 * Pure display helpers for the platform analytics console.
 *
 * A `.ts` module with no React import, for the same reason `pages/admin/format.ts`
 * and `pages/settings/standing.ts` are: this is a transformation of API data,
 * keeping it out of the component file satisfies `react-refresh/only-export-components`
 * and leaves every rule here directly unit-testable.
 *
 * The rule these helpers exist to protect: **never relabel `accuracy_proxy` as
 * accuracy**. `AIPredictionJob` has no ground-truth column, so the figure is
 * human corrections over completed jobs — a rate of how often people bother to
 * override a model, which is biased toward what people notice. The server says
 * this in `caveats`; `ACCURACY_PROXY_LABEL` is the only string this surface is
 * allowed to put next to the number.
 */

import type {
  AnalyticsKpi,
  AnalyticsMetricCatalogueEntry,
  AnalyticsTimeseriesBucket,
  AnalyticsWindow,
} from '@/api/adminPortal';

/**
 * The one label `accuracy_proxy` may ever carry.
 *
 * "Correction rate proxy" — not "accuracy", not "correct rate" (which reads as
 * a share of *correct* outputs, the exact inversion of what it measures).
 */
export const ACCURACY_PROXY_LABEL = 'Correction-rate proxy';

/** Bootstrap metric for the Trends tab before the server's catalogue arrives. */
export const DEFAULT_TRENDS_METRIC = 'users.new';

export const GRANULARITIES = ['day', 'week'] as const;

export const TRENDING_KINDS = ['posts', 'services', 'events', 'hashtags', 'pages'] as const;

export const TRENDING_KIND_LABELS: Record<string, string> = {
  posts: 'Posts',
  services: 'Services',
  events: 'Events',
  hashtags: 'Hashtags',
  pages: 'Pages',
};

export const REPORT_KEYS = ['overview', 'timeseries', 'trending', 'ai_quality', 'predictive'] as const;

export const REPORT_LABELS: Record<string, string> = {
  overview: 'Platform overview',
  timeseries: 'Metric time series',
  trending: 'Trending',
  ai_quality: 'AI quality and cost',
  predictive: 'Recommendation signals',
};

function num(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

export function formatCount(value: unknown): string {
  const n = num(value);
  return n === null ? '—' : n.toLocaleString();
}

export function formatMoney(value: unknown, currency = 'USD'): string {
  const n = num(value);
  if (n === null) return '—';
  try {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency, maximumFractionDigits: 2 }).format(n);
  } catch {
    return `${n.toFixed(2)} ${currency}`;
  }
}

/** A KPI's value, formatted for its declared unit. */
export function metricValue(value: unknown, unit?: string | null): string {
  if (unit === 'usd') return formatMoney(value);
  return formatCount(value);
}

/** `0.421` → `42.1%`. Em dash rather than `0%` for "no denominator". */
export function formatRatio(value: unknown, digits = 1): string {
  const n = num(value);
  if (n === null) return '—';
  return `${(n * 100).toFixed(digits)}%`;
}

/**
 * A value that is **already** a percentage — `33.3` means 33.3%, not 3330%.
 *
 * Distinct from {@link formatRatio} because the two do not agree: `fallback_rate`
 * and `accuracy_proxy` are ratios, while a trending hashtag's `pct_change` comes
 * off the server as `round(delta * 100 / before, 1)`. Multiplying that by 100 a
 * second time would report a tag that grew by a third as having grown 3,330%.
 */
export function formatPercent(value: unknown, digits = 1): string {
  const n = num(value);
  if (n === null) return '—';
  return `${n.toFixed(digits)}%`;
}

export function formatMilliseconds(value: unknown): string {
  const n = num(value);
  if (n === null) return '—';
  return n >= 1000 ? `${(n / 1000).toFixed(2)} s` : `${n.toFixed(0)} ms`;
}

/** Signed delta: `+12`, `-3`, `0`. */
export function formatDelta(value: unknown): string {
  const n = num(value);
  if (n === null) return '—';
  if (n > 0) return `+${n.toLocaleString()}`;
  if (n < 0) return n.toLocaleString();
  return '0';
}

export function formatDate(value: unknown): string {
  if (typeof value !== 'string' || !value) return '—';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  return d.toLocaleString();
}

export function text(value: unknown, fallback = '—'): string {
  if (typeof value === 'string') return value.trim() || fallback;
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  return fallback;
}

/**
 * The window as one line, always quoting the server's own label.
 *
 * The label is the load-bearing part: `'All time'` and `'Window'` are the only
 * thing distinguishing a stock from a delta, and both are needed on screen
 * because they mean different things to the person reading the number.
 */
export function windowSummary(window: AnalyticsWindow | undefined | null): string {
  if (!window) return '—';
  const parts: string[] = [];
  if (window.label) parts.push(window.label);
  if (window.from && window.to) parts.push(`${window.from} → ${window.to}`);
  if (typeof window.days === 'number') parts.push(`${window.days} day${window.days === 1 ? '' : 's'}`);
  if (window.timezone) parts.push(window.timezone);
  return parts.length ? parts.join(' · ') : '—';
}

/**
 * A KPI's own window, phrased so a gauge cannot read as a period figure.
 *
 * A gauge's `from`/`to` are still present in the payload — `Window.as_dict` is
 * called with the same dates — so printing them bare would put a date range
 * under the words "All time". For a gauge only the *end* is meaningful, so only
 * the end is shown.
 */
export function kpiWindowText(kpi: AnalyticsKpi): string {
  const window = kpi.window;
  if (!window) return '—';
  if (kpi.kind === 'gauge') {
    return window.to ? `All time — counted up to ${window.to}` : 'All time';
  }
  return windowSummary(window);
}

/** 'gauge' → 'Gauge', 'flow' → 'Period flow'. Anything unknown stays literal. */
export function kpiKindLabel(kpi: AnalyticsKpi): string {
  return kpi.kind === 'gauge' ? 'Gauge' : 'Flow';
}

/**
 * The metrics the picker offers.
 *
 * Built from the server's `metric_catalogue` filtered to additive + windowed —
 * the exact set `TIMESERIES_METRICS` accepts server-side. A hardcoded list here
 * would drift from the registry and produce 400s the moment it did.
 */
export function metricOptions(
  catalogue: AnalyticsMetricCatalogueEntry[] | undefined,
  fallbackKeys: string[] = [],
): Array<{ key: string; label: string; group: string; description: string }> {
  if (catalogue && catalogue.length) {
    return catalogue
      .filter((entry) => entry.additive !== false && entry.windowed !== false && entry.key)
      .map((entry) => ({
        key: String(entry.key),
        label: text(entry.label, String(entry.key)),
        group: text(entry.group, 'other'),
        description: text(entry.description, ''),
      }));
  }
  return fallbackKeys.map((key) => ({ key, label: key, group: 'other', description: '' }));
}

/** Chart-ready rows. The server already zero-fills, so gaps are passed through. */
export function chartRows(series: AnalyticsTimeseriesBucket[] | undefined): Array<{ bucket: string; value: number }> {
  return (series || []).map((row) => ({ bucket: text(row.bucket), value: num(row.value) ?? 0 }));
}

/** Human summary of `data_source`, e.g. `rollup · complete` / `live · 3 days missing`. */
export function dataSourceSummary(source: { path?: string; rollup_complete?: boolean; missing_days?: string[] } | undefined): string {
  if (!source?.path) return '—';
  const missing = source.missing_days?.length ?? 0;
  if (source.path === 'rollup') return 'Pre-computed rollup · complete for this window';
  return `Computed live${missing ? ` · rollup missing ${missing} day${missing === 1 ? '' : 's'}` : ''}`;
}

/** ISO day offset helper for the preset buttons. */
export function isoDaysAgo(days: number): string {
  const d = new Date();
  d.setDate(d.getDate() - (days - 1));
  return d.toISOString().slice(0, 10);
}

export function isoToday(): string {
  return new Date().toISOString().slice(0, 10);
}