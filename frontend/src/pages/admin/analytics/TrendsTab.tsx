import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import { AXIS_TICK, CHART_TOOLTIP, COLORS, GRID_STROKE } from '@/components/analytics/chartConfig';
import { adminPortalApi, type AnalyticsTimeseries, type AnalyticsWindowParams } from '@/api/adminPortal';
import { Card } from '@/components/ui/Card';
import {
  chartRows, DEFAULT_TRENDS_METRIC, formatCount, GRANULARITIES, metricOptions, metricValue, text,
} from './format';
import { DataSourceNote, NothingToShow, ReportWindowLine } from './shared';

/**
 * Trends — one metric over time.
 *
 * Two things this tab refuses to smooth over:
 *
 * 1. **The series is zero-filled server-side.** A missing bucket is a zero, not
 *    a gap, so the chart plots it and the table below lists it. Rendering only
 *    the non-zero buckets would draw a straight line through days on which
 *    nothing happened, which is the single most common way an analytics chart
 *    lies.
 * 2. **The series may not come from the rollup.** {@link DataSourceNote} names
 *    `computed live` and lists the missing days whenever the rollup had a gap,
 *    because a live aggregation is slower and the operator should know which
 *    chart they are looking at.
 */
export default function TrendsTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [metric, setMetric] = useState(DEFAULT_TRENDS_METRIC);
  const [granularity, setGranularity] = useState<'day' | 'week'>('day');
  const [data, setData] = useState<AnalyticsTimeseries | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getAnalyticsTimeseries({ from, to, metric, granularity })
      .then((res) => setData(res.data || null))
      .catch((err: unknown) => {
        const payload = (err as { response?: { data?: { message?: string; errors?: Record<string, string[]> } } })?.response?.data;
        const detail = payload?.errors
          ? Object.entries(payload.errors).map(([k, v]) => `${k}: ${v.join(' ')}`).join(' ')
          : '';
        setError(
          [payload?.message, detail].filter(Boolean).join(' — ') ||
            'Could not load this metric series. Non-additive metrics are refused here — they are on Overview.',
        );
      })
      .finally(() => setLoading(false));
  }, [from, to, metric, granularity]);

  useEffect(() => { load(); }, [load]);

  // Built from the server's own `metric_catalogue`, filtered to the additive +
  // windowed set the endpoint accepts — never from a list hardcoded here, which
  // would drift from `METRIC_SPECS` and start 400-ing.
  const options = useMemo(
    () => metricOptions(data?.metric_catalogue, data?.available_metrics || [metric]),
    [data?.metric_catalogue, data?.available_metrics, metric],
  );

  const rows = useMemo(() => chartRows(data?.series), [data?.series]);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-end gap-3">
        <label className="inline-flex flex-col gap-1 text-xs text-buddy-text-secondary">
          <span>Metric</span>
          <select
            value={metric}
            aria-label="Metric"
            onChange={(e) => setMetric(e.target.value)}
            className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
          >
            {options.map((option) => (
              <option key={option.key} value={option.key}>
                {option.label} ({option.key})
              </option>
            ))}
          </select>
        </label>
        <div className="inline-flex flex-col gap-1 text-xs text-buddy-text-secondary">
          <span>Granularity</span>
          <div className="flex items-center gap-1">
            {GRANULARITIES.map((g) => (
              <button
                key={g}
                type="button"
                aria-pressed={granularity === g}
                onClick={() => setGranularity(g)}
                className={`text-xs px-2.5 py-1 rounded-lg capitalize transition-colors ${
                  granularity === g
                    ? 'bg-buddy-green/15 text-buddy-green font-semibold'
                    : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
                }`}
              >
                {g}
              </button>
            ))}
          </div>
        </div>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">
          {error}
        </div>
      )}

      {loading && !data && <Card className="h-48 animate-pulse bg-buddy-surface-raised" aria-busy="true" />}

      {data && (
        <>
          <ReportWindowLine window={data.window} />
          <DataSourceNote source={data.data_source} />

          <div className="grid grid-cols-3 gap-3">
            <Card className="p-3">
              <p className="text-[11px] text-buddy-text-secondary">Sum over buckets</p>
              <p className="font-display font-extrabold text-lg">{metricValue(data.totals?.sum, data.metric?.unit)}</p>
            </Card>
            <Card className="p-3">
              <p className="text-[11px] text-buddy-text-secondary">Buckets with a value</p>
              <p className="font-display font-extrabold text-lg">
                {formatCount(data.totals?.non_zero_buckets)} / {formatCount(rows.length)}
              </p>
            </Card>
            <Card className="p-3">
              <p className="text-[11px] text-buddy-text-secondary">Source</p>
              <p className="text-xs break-all">{text(data.metric?.source)}</p>
            </Card>
          </div>

          {data.metric?.description && (
            <p className="text-[11px] text-buddy-text-secondary">{data.metric.description}</p>
          )}

          {rows.length === 0 ? (
            <NothingToShow title="No buckets in this window." hint="Widen the date range." />
          ) : (
            <Card className="p-4">
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={rows} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                    <defs>
                      <linearGradient id="analyticsTrendFill" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor={COLORS[0]} stopOpacity={0.25} />
                        <stop offset="100%" stopColor={COLORS[0]} stopOpacity={0.02} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                    <XAxis dataKey="bucket" tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} interval="preserveStartEnd" minTickGap={16} />
                    <YAxis tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} width={44} allowDecimals={data.metric?.unit !== 'usd'} />
                    <Tooltip {...CHART_TOOLTIP} />
                    <Area
                      type="monotone"
                      dataKey="value"
                      stroke={COLORS[0]}
                      strokeWidth={2}
                      fill="url(#analyticsTrendFill)"
                      isAnimationActive={false}
                      name={text(data.metric?.label, 'value')}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>

              {/* The buckets as numbers. A chart alone cannot show that a gap is
                  a counted zero rather than a day with no data at all. */}
              <div className="mt-3 max-h-56 overflow-y-auto">
                <table className="w-full text-xs">
                  <thead className="sticky top-0 bg-buddy-surface">
                    <tr className="text-left text-buddy-text-secondary">
                      <th className="font-medium py-1 pr-3">Bucket</th>
                      <th className="font-medium py-1">Value</th>
                    </tr>
                  </thead>
                  <tbody>
                    {rows.map((row) => (
                      <tr key={row.bucket} className="border-t border-buddy-surface">
                        <td className="py-1 pr-3 font-mono">{row.bucket}</td>
                        <td className="py-1">{metricValue(row.value, data.metric?.unit)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </Card>
          )}
        </>
      )}
    </div>
  );
}