import { useCallback, useState } from 'react';
import { AlertTriangle, Download, FileSpreadsheet, Info } from 'lucide-react';
import {
  exportAnalyticsReport,
  saveAnalyticsFile,
  type AnalyticsExportFormat,
  type AnalyticsExportOutcome,
  type AnalyticsReportKey,
  type AnalyticsTrendingKind,
  type AnalyticsWindowParams,
} from '@/api/adminPortal';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { formatCount, REPORT_KEYS, REPORT_LABELS, text, TRENDING_KIND_LABELS, TRENDING_KINDS } from './format';

/**
 * Export — download a report as CSV or XLSX.
 *
 * Two refusals are possible and they mean opposite things, so this tab refuses
 * to collapse them into "export failed":
 *
 * - **400, row cap** — the report was *refused*, not truncated. The server
 *   raises rather than writing a short file, because a truncated export would
 *   disagree with the report the operator was looking at and nothing in the
 *   file would say so. The message is rendered verbatim and no file is offered.
 * - **503, xlsx** — `openpyxl` is not installed on this deployment. Nothing is
 *   wrong with the data or the request; the CSV of the same report is produced
 *   by code with no dependency, so the fix offered is the button that downloads
 *   it, not a rebuild.
 */

interface ExportState {
  outcome: AnalyticsExportOutcome;
  report: AnalyticsReportKey;
  format: AnalyticsExportFormat;
}

export default function ExportTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [report, setReport] = useState<AnalyticsReportKey>('overview');
  const [format, setFormat] = useState<AnalyticsExportFormat>('csv');
  const [metric, setMetric] = useState('users.new');
  const [granularity, setGranularity] = useState<'day' | 'week'>('day');
  const [kind, setKind] = useState<string>('posts');
  const [limit, setLimit] = useState(10);
  const [busy, setBusy] = useState(false);
  const [state, setState] = useState<ExportState | null>(null);

  const run = useCallback(
    async (nextFormat: AnalyticsExportFormat = format) => {
      setBusy(true);
      setState(null);
      const outcome = await exportAnalyticsReport({
        report,
        format: nextFormat,
        from,
        to,
        ...(report === 'timeseries' ? { metric, granularity } : {}),
        ...(report === 'trending' ? { kind: kind as AnalyticsTrendingKind, limit } : {}),
      });
      if (outcome.ok) saveAnalyticsFile(outcome.file);
      setState({ outcome, report, format: nextFormat });
      setBusy(false);
    },
    [format, from, to, kind, limit, metric, granularity, report],
  );

  const failure = state && !state.outcome.ok ? state.outcome : null;

  return (
    <div className="space-y-4 max-w-2xl">
      <Card className="p-4 space-y-3">
        <div>
          <p className="text-sm font-semibold mb-1">Download a report</p>
          <p className="text-[11px] text-buddy-text-secondary">
            Exports carry the same window and the same rows as the tab above — there is no second query path,
            so a file cannot cover a different period from the report you were reading.
          </p>
        </div>

        <label className="flex flex-col gap-1 text-xs text-buddy-text-secondary">
          <span>Report</span>
          <select
            value={report}
            aria-label="Report"
            onChange={(e) => setReport(e.target.value as AnalyticsReportKey)}
            className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
          >
            {REPORT_KEYS.map((key) => (
              <option key={key} value={key}>{REPORT_LABELS[key]}</option>
            ))}
          </select>
        </label>

        {report === 'timeseries' && (
          <div className="flex flex-wrap gap-3">
            <label className="flex flex-col gap-1 text-xs text-buddy-text-secondary">
              <span>Metric key</span>
              <input
                value={metric}
                aria-label="Metric key"
                onChange={(e) => setMetric(e.target.value)}
                className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              />
            </label>
            <label className="flex flex-col gap-1 text-xs text-buddy-text-secondary">
              <span>Granularity</span>
              <select
                value={granularity}
                aria-label="Granularity"
                onChange={(e) => setGranularity(e.target.value as 'day' | 'week')}
                className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              >
                <option value="day">Day</option>
                <option value="week">Week</option>
              </select>
            </label>
          </div>
        )}

        {report === 'trending' && (
          <div className="flex flex-wrap gap-3">
            <label className="flex flex-col gap-1 text-xs text-buddy-text-secondary">
              <span>Kind</span>
              <select
                value={kind}
                aria-label="Kind"
                onChange={(e) => setKind(e.target.value)}
                className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              >
                {TRENDING_KINDS.map((k) => (
                  <option key={k} value={k}>{TRENDING_KIND_LABELS[k]}</option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-1 text-xs text-buddy-text-secondary">
              <span>Limit</span>
              <input
                type="number"
                min={1}
                max={100}
                value={limit}
                aria-label="Limit"
                onChange={(e) => setLimit(Math.min(100, Math.max(1, Number(e.target.value) || 1)))}
                className="w-24 bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
              />
            </label>
          </div>
        )}

        <div className="flex flex-wrap items-center gap-2">
          <span className="text-xs text-buddy-text-secondary">Format</span>
          {(['csv', 'xlsx'] as const).map((f) => (
            <button
              key={f}
              type="button"
              aria-pressed={format === f}
              onClick={() => setFormat(f)}
              className={`text-xs px-2.5 py-1 rounded-lg uppercase transition-colors ${
                format === f
                  ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                  : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
              }`}
            >
              {f}
            </button>
          ))}
          <Button size="sm" onClick={() => run()} isLoading={busy} className="ml-auto">
            <Download size={14} className="mr-1" /> Download {format.toUpperCase()}
          </Button>
        </div>

        <p className="text-[11px] text-buddy-text-secondary">
          <Info size={11} className="inline mr-1" />
          CSV needs nothing server-side and always works. XLSX needs the <code>openpyxl</code> package on
          the API deployment.
        </p>
      </Card>

      {state?.outcome.ok && (
        <Card className="p-4 border-buddy-green/25" data-testid="export-success">
          <div className="flex items-start gap-2">
            <FileSpreadsheet size={16} className="text-buddy-green mt-0.5 shrink-0" />
            <div className="min-w-0">
              <p className="text-sm font-semibold">{state.outcome.file.filename}</p>
              <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                {formatCount(state.outcome.file.rows)} row{state.outcome.file.rows === 1 ? '' : 's'}
                {state.outcome.file.from && state.outcome.file.to
                  ? ` · ${state.outcome.file.from} → ${state.outcome.file.to}`
                  : ''}
                {state.outcome.file.dataSource ? ` · source: ${state.outcome.file.dataSource}` : ''}
              </p>
              {state.outcome.file.dataSource === 'live' && (
                <p className="text-[11px] text-buddy-orange mt-1">
                  This file was aggregated live because the rollup had gaps in this window.
                </p>
              )}
            </div>
          </div>
        </Card>
      )}

      {failure && (
        <Card
          className={`p-4 ${failure.reason === 'xlsx_unavailable' ? 'border-buddy-orange/30' : 'border-buddy-red/30'}`}
          data-testid={failure.reason === 'row_cap' ? 'export-row-cap' : 'export-error'}
        >
          <div className="flex items-start gap-2">
            <AlertTriangle
              size={16}
              className={`mt-0.5 shrink-0 ${failure.reason === 'xlsx_unavailable' ? 'text-buddy-orange' : 'text-buddy-red'}`}
            />
            <div className="min-w-0">
              <p className="text-sm font-semibold">
                {failure.reason === 'row_cap'
                  ? 'Export refused — nothing was downloaded'
                  : failure.reason === 'xlsx_unavailable'
                    ? 'XLSX export is unavailable on this deployment'
                    : 'Export failed'}
              </p>
              {/* Verbatim. The server's wording is the part that is actionable
                  (the row count, the cap, the package name), so it is never
                  paraphrased or replaced with a generic failure line. */}
              <p className="text-xs text-buddy-text-secondary mt-1 break-words">{failure.message}</p>

              {failure.reason === 'row_cap' && (
                <p className="text-[11px] text-buddy-text-secondary mt-2">
                  This is a refusal, not a truncated file: no partial download was produced, so nothing on
                  your disk is missing rows. Narrow the date range above and try again.
                </p>
              )}

              {failure.reason === 'xlsx_unavailable' && (
                <div className="mt-3">
                  <p className="text-[11px] text-buddy-text-secondary">
                    This is a missing server dependency, not a problem with your data or this request. CSV
                    export of the same report takes no dependency and is unaffected.
                  </p>
                  <Button
                    size="sm"
                    variant="outline"
                    className="mt-2"
                    isLoading={busy}
                    onClick={() => run('csv')}
                  >
                    <Download size={14} className="mr-1" /> Download the same report as CSV
                  </Button>
                </div>
              )}

              {failure.reason === 'error' && (
                <p className="text-[11px] text-buddy-text-secondary mt-1">
                  Report requested: {text(REPORT_LABELS[state?.report as AnalyticsReportKey])}. HTTP {failure.status}.
                </p>
              )}
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}