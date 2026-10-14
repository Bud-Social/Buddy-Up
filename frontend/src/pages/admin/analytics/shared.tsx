import { useState, type ReactNode } from 'react';
import { AlertTriangle, Info, Radio, X } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import type { AnalyticsKpi, AnalyticsPerformanceNote } from '@/api/adminPortal';
import { dataSourceSummary, formatDate, kpiKindLabel, kpiWindowText, metricValue, text } from './format';
import type { AnalyticsDataSource } from '@/api/adminPortal';

/**
 * Building blocks shared by every tab of the analytics console.
 *
 * Two of these exist purely to keep a promise the API makes in words:
 *
 * - {@link DataSourceNote} — a chart served from `live` was aggregated out of a
 *   source table rather than read from the rollup, and it says which days the
 *   rollup is missing. An operator reading a chart that took a sequential scan
 *   has no way to know that from the chart itself.
 * - {@link PerformanceNotesPanel} — the disclosure that several tables have no
 *   `created_at` index, so some of these figures cost a full scan today. It is
 *   dismissible, not hidden: the point is that a staff member has seen it.
 *
 * Components only — no constant exports — so this file satisfies
 * `react-refresh/only-export-components`.
 */

export function AnalyticsTabBar({
  tabs,
  value,
  onChange,
}: {
  tabs: Array<{ id: string; label: string }>;
  value: string;
  onChange: (id: string) => void;
}) {
  return (
    <div className="flex flex-wrap items-center gap-2" role="tablist" aria-label="Analytics reports">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          type="button"
          role="tab"
          aria-selected={value === tab.id}
          onClick={() => onChange(tab.id)}
          className={`text-xs px-3 py-1.5 rounded-lg transition-colors ${
            value === tab.id
              ? 'bg-buddy-green/15 text-buddy-green font-semibold'
              : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
          }`}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
}

/**
 * The one date-range control for the whole page.
 *
 * Empty inputs mean "no opinion" and the string is simply omitted from the
 * query, so the server applies its own 30-day default rather than the browser
 * inventing a window the report was not computed for.
 */
export function AnalyticsDateRange({
  from,
  to,
  onChange,
}: {
  from: string;
  to: string;
  onChange: (next: { from: string; to: string }) => void;
}) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
        <span className="sr-only">From date</span>
        <input
          type="date"
          value={from}
          max={to || undefined}
          aria-label="From date"
          onChange={(e) => onChange({ from: e.target.value, to })}
          className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
        />
      </label>
      <span className="text-xs text-buddy-text-secondary">to</span>
      <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
        <span className="sr-only">To date</span>
        <input
          type="date"
          value={to}
          min={from || undefined}
          aria-label="To date"
          onChange={(e) => onChange({ from, to: e.target.value })}
          className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
        />
      </label>
      <Button
        size="sm"
        variant="ghost"
        onClick={() => onChange({ from: '', to: '' })}
        aria-label="Clear the date range and use the server default"
      >
        Server default
      </Button>
    </div>
  );
}

/**
 * Where this chart's numbers came from.
 *
 * `live` is called out in words — "computed live" — because it is a different
 * kind of number to a rollup read: slower, and recomputed from the source table
 * every request. Missing rollup days are listed rather than summarised so the
 * gap is auditable.
 */
export function DataSourceNote({ source }: { source?: AnalyticsDataSource }) {
  if (!source?.path) return null;
  const isLive = source.path === 'live';
  const missing = source.missing_days ?? [];
  return (
    <div
      className={`flex items-start gap-2 rounded-xl border px-3 py-2 text-[11px] ${
        isLive ? 'border-buddy-orange/25 bg-buddy-orange/5 text-buddy-orange' : 'border-buddy-surface-raised text-buddy-text-secondary'
      }`}
    >
      {isLive ? <AlertTriangle size={13} className="mt-0.5 shrink-0" /> : <Radio size={13} className="mt-0.5 shrink-0" />}
      <div className="min-w-0">
        <p className="font-semibold">
          {isLive ? 'Computed live' : 'Served from the daily rollup'}
          <span className="font-normal opacity-80"> · {dataSourceSummary(source)}</span>
        </p>
        {source.note && <p className="mt-0.5 opacity-90">{source.note}</p>}
        {missing.length > 0 && (
          <p className="mt-1 break-words">
            <span className="font-semibold">Rollup missing {missing.length} day{missing.length === 1 ? '' : 's'}:</span>{' '}
            {missing.join(', ')}
          </p>
        )}
      </div>
    </div>
  );
}

/**
 * The `created_at` index disclosure, dismissible.
 *
 * The fix for each of these belongs to the app that owns the model, so the
 * console can only report it. A staff member has to be able to see the cost of
 * the screen in front of them without re-reading the backend to find it.
 */
export function PerformanceNotesPanel({ notes }: { notes?: AnalyticsPerformanceNote[] }) {
  const [dismissed, setDismissed] = useState(false);
  if (dismissed || !notes || notes.length === 0) return null;
  return (
    <Card className="p-4 border-buddy-orange/25">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-start gap-2 min-w-0">
          <AlertTriangle size={16} className="text-buddy-orange mt-0.5 shrink-0" />
          <div className="min-w-0">
            <p className="text-sm font-semibold">
              Performance notes — {notes.length} source{notes.length === 1 ? '' : 's'} without a{' '}
              <code className="text-buddy-orange">created_at</code> index
            </p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              Figures read from these tables cost a sequential scan on every request. The fix is an index in
              the app that owns each model, so it is reported here rather than applied from this console.
            </p>
            <ul className="mt-2 space-y-1">
              {notes.map((note) => (
                <li key={text(note.source, 'source')} className="text-[11px] text-buddy-text-secondary break-words">
                  <span className="font-mono text-buddy-text-primary">{text(note.source)}</span>
                  {note.issue ? ` — ${note.issue}` : ''}
                  {note.suggested_migration ? (
                    <span className="block font-mono text-buddy-orange/90">{note.suggested_migration}</span>
                  ) : null}
                </li>
              ))}
            </ul>
          </div>
        </div>
        <Button size="sm" variant="ghost" onClick={() => setDismissed(true)} aria-label="Dismiss performance notes">
          <X size={14} className="mr-1" /> Dismiss
        </Button>
      </div>
    </Card>
  );
}

/**
 * One headline figure, with the window it was counted over.
 *
 * The window line is not decoration: the API deliberately gives each KPI its own
 * window, and a gauge (`All time`) next to a flow (`Window`) must never read as
 * two numbers for the same thing. The `source` is shown too, because a figure
 * with no index behind it is a different kind of claim from one with.
 */
export function KpiCard({ kpi }: { kpi: AnalyticsKpi }) {
  const isGauge = kpi.kind === 'gauge';
  return (
    <Card className="p-4">
      <div className="flex items-start justify-between gap-2">
        <p className="text-xs text-buddy-text-secondary">{text(kpi.label, text(kpi.key))}</p>
        <Badge
          variant={isGauge ? 'silver' : 'blue'}
          label={kpiKindLabel(kpi)}
          size="sm"
        />
      </div>
      <p className="font-display font-extrabold text-2xl leading-tight mt-1">
        {metricValue(kpi.value, kpi.unit)}
      </p>
      <p className="text-[11px] text-buddy-text-secondary mt-0.5" data-testid={`kpi-window-${text(kpi.key)}`}>
        {kpiWindowText(kpi)}
      </p>
      <p className="text-[10px] text-buddy-text-secondary/70 mt-1 break-words">
        <span className="font-mono">{text(kpi.source)}</span>
        {kpi.indexed === false && (
          <span className="text-buddy-orange"> · no index — sequential scan</span>
        )}
      </p>
      {kpi.note && <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">{kpi.note}</p>}
    </Card>
  );
}

/** The page-level window plus when the report was generated. */
export function ReportWindowLine({
  window,
  generatedAt,
}: {
  window?: { label?: string | null; from?: string | null; to?: string | null; days?: number | null };
  generatedAt?: string | null;
}) {
  const range = window?.from && window?.to ? `${window.from} → ${window.to}` : text(window?.label);
  return (
    <p className="text-[11px] text-buddy-text-secondary">
      <Info size={11} className="inline mr-1" />
      {range}
      {typeof window?.days === 'number' ? ` · ${window.days} day${window.days === 1 ? '' : 's'}` : ''}
      {generatedAt ? ` · generated ${formatDate(generatedAt)}` : ''}
    </p>
  );
}

/** Neutral "there is genuinely nothing here" card. Never used to hide a failure. */
export function NothingToShow({ title, hint }: { title: string; hint?: ReactNode }) {
  return (
    <Card className="p-6 text-center">
      <p className="text-sm text-buddy-text-secondary">{title}</p>
      {hint && <p className="text-[11px] text-buddy-text-secondary/80 mt-1">{hint}</p>}
    </Card>
  );
}