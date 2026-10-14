import { useCallback, useEffect, useState } from 'react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { AlertTriangle } from 'lucide-react';
import { AXIS_TICK, CHART_TOOLTIP, COLORS, GRID_STROKE } from '@/components/analytics/chartConfig';
import { adminPortalApi, type AnalyticsAIQuality, type AnalyticsWindowParams } from '@/api/adminPortal';
import { Card } from '@/components/ui/Card';
import {
  ACCURACY_PROXY_LABEL, formatCount, formatMilliseconds, formatMoney, formatRatio, text,
} from './format';
import { NothingToShow, ReportWindowLine } from './shared';

/**
 * AI quality, fallback rate, latency and cost.
 *
 * **The one hard rule on this tab: `accuracy_proxy` is never labelled
 * "accuracy".** `AIPredictionJob` stores no ground truth. `correction` is
 * written when a human overrides an AI output, so corrections-over-completed is
 * a *correction rate* — biased toward what people bother to override, and blind
 * to a wrong answer nobody noticed. Calling it "accuracy" would put a number
 * next to a label that promises more than the data can support.
 *
 * The server ships the caveat that says this, and it is rendered verbatim under
 * the totals. It is the only place on this screen where the word appears, and
 * it appears inside the sentence explaining that the figure is not accuracy.
 */

function TotalStat({ label, value }: { label: string; value: string }) {
  return (
    <Card className="p-3">
      <p className="text-[11px] text-buddy-text-secondary">{label}</p>
      <p className="font-display font-extrabold text-lg">{value}</p>
    </Card>
  );
}

export default function AiQualityTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [data, setData] = useState<AnalyticsAIQuality | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getAnalyticsAIQuality({ from, to })
      .then((res) => setData(res.data || null))
      .catch((err: unknown) => {
        const payload = (err as { response?: { data?: { message?: string } } })?.response?.data;
        setError(payload?.message || 'Could not load AI quality metrics.');
      })
      .finally(() => setLoading(false));
  }, [from, to]);

  useEffect(() => { load(); }, [load]);

  if (loading && !data) return <Card className="h-40 animate-pulse bg-buddy-surface-raised" />;

  if (error && !data) {
    return (
      <Card className="p-6 text-center">
        <p className="text-sm text-buddy-red break-words">{error}</p>
      </Card>
    );
  }

  const totals = data?.totals || {};
  const latency = data?.latency_ms || {};
  const buckets = data?.confidence_distribution?.buckets || [];
  const models = data?.models || [];
  const reasons = data?.fallback_reasons || [];

  return (
    <div className="space-y-4">
      {data && <ReportWindowLine window={data.window} />}

      {(data?.caveats || []).map((caveat) => (
        <Card key={caveat} className="p-4 border-buddy-orange/25" data-testid="ai-quality-caveats">
          <div className="flex items-start gap-2">
            <AlertTriangle size={16} className="text-buddy-orange mt-0.5 shrink-0" />
            <p className="text-[11px] text-buddy-text-secondary break-words">{caveat}</p>
          </div>
        </Card>
      ))}

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <TotalStat label="AI calls" value={formatCount(totals.calls)} />
        <TotalStat
          label="Fallback rate"
          value={`${formatCount(totals.fallbacks)} (${formatRatio(totals.fallback_rate)})`}
        />
        <TotalStat label="Human corrections" value={formatCount(totals.corrections)} />
        <TotalStat label={ACCURACY_PROXY_LABEL} value={formatRatio(totals.accuracy_proxy)} />
        <TotalStat label="Cost in window" value={formatMoney(totals.cost_usd)} />
        <TotalStat label="Cost per call" value={formatMoney(totals.cost_per_call_usd)} />
        <TotalStat label="Lifetime cost" value={formatMoney(totals.cumulative_cost_usd)} />
        <TotalStat label="Lifetime cost per call" value={formatMoney(totals.cumulative_cost_per_call_usd)} />
      </div>

      <div className="grid gap-3 lg:grid-cols-2">
        <Card className="p-4">
          <p className="text-sm font-semibold">Latency</p>
          <div className="grid grid-cols-4 gap-2 mt-2">
            {(['p50', 'p95', 'min', 'max'] as const).map((key) => (
              <div key={key}>
                <p className="text-[11px] text-buddy-text-secondary uppercase">{key}</p>
                <p className="text-sm font-semibold">{formatMilliseconds(latency[key])}</p>
              </div>
            ))}
          </div>
          <p className="text-[11px] text-buddy-text-secondary mt-2">
            {formatCount(latency.samples)} sample{latency.samples === 1 ? '' : 's'}
            {latency.sampled === true
              ? ` — capped at ${formatCount(latency.sample_limit)}; percentiles are from that sample while the counts above are exact.`
              : ' — every job in the window, not a sample.'}
          </p>
        </Card>

        <Card className="p-4">
          <p className="text-sm font-semibold">Fallback reasons</p>
          {reasons.length === 0 ? (
            <p className="text-xs text-buddy-text-secondary mt-2">No fallback was used in this window.</p>
          ) : (
            <ul className="mt-2 space-y-1">
              {reasons.map((row) => (
                <li key={text(row.reason)} className="flex items-center justify-between gap-3 text-xs">
                  <span className="min-w-0 break-words">{text(row.reason)}</span>
                  <span className="font-semibold">{formatCount(row.count)}</span>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>

      {buckets.length > 0 && (
        <Card className="p-4">
          <p className="text-sm font-semibold">Model confidence distribution</p>
          <p className="text-[11px] text-buddy-text-secondary">
            {formatCount(data?.confidence_distribution?.with_confidence)} job(s) reported a confidence value.
          </p>
          <div className="h-48 mt-2">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={buckets.map((b) => ({ bucket: text(b.bucket), count: Number(b.count ?? 0) }))}>
                <CartesianGrid stroke={GRID_STROKE} strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="bucket" tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} />
                <YAxis tick={AXIS_TICK} tickLine={false} axisLine={{ stroke: GRID_STROKE }} width={40} />
                <Tooltip {...CHART_TOOLTIP} />
                <Bar dataKey="count" fill={COLORS[1]} isAnimationActive={false} radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      )}

      {models.length === 0 ? (
        <NothingToShow title="No model ran in this window." hint="Calls, fallbacks and cost are all zero because nothing was requested." />
      ) : (
        <Card className="p-4 overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="text-left text-buddy-text-secondary">
                <th className="font-medium py-1 pr-3">Model</th>
                <th className="font-medium py-1 pr-3">Task</th>
                <th className="font-medium py-1 pr-3 text-right">Calls</th>
                <th className="font-medium py-1 pr-3 text-right">Success</th>
                <th className="font-medium py-1 pr-3 text-right">Fallback</th>
                <th className="font-medium py-1 pr-3 text-right">Corrections</th>
                <th className="font-medium py-1 pr-3 text-right">{ACCURACY_PROXY_LABEL}</th>
                <th className="font-medium py-1 pr-3 text-right">Mean confidence</th>
                <th className="font-medium py-1 text-right">Cost</th>
              </tr>
            </thead>
            <tbody>
              {models.map((row) => (
                <tr key={text(row.model)} className="border-t border-buddy-surface">
                  <td className="py-1.5 pr-3">{text(row.model)}</td>
                  <td className="py-1.5 pr-3">{text(row.task)}</td>
                  <td className="py-1.5 pr-3 text-right">{formatCount(row.calls)}</td>
                  <td className="py-1.5 pr-3 text-right">{formatRatio(row.success_rate)}</td>
                  <td className="py-1.5 pr-3 text-right">{formatRatio(row.fallback_rate)}</td>
                  <td className="py-1.5 pr-3 text-right">{formatCount(row.corrections)}</td>
                  <td className="py-1.5 pr-3 text-right">{formatRatio(row.accuracy_proxy)}</td>
                  <td className="py-1.5 pr-3 text-right">
                    {row.mean_confidence == null ? '—' : row.mean_confidence.toFixed(2)}
                  </td>
                  <td className="py-1.5 text-right">{formatMoney(row.cost_usd)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}
    </div>
  );
}