import { useCallback, useEffect, useState } from 'react';
import { AlertTriangle, Eye, Sigma } from 'lucide-react';
import { adminPortalApi, type AnalyticsPredictive, type AnalyticsWindowParams } from '@/api/adminPortal';
import { Card } from '@/components/ui/Card';
import { formatCount, formatRatio, text } from './format';
import { NothingToShow, ReportWindowLine } from './shared';

/**
 * Predictive signals — observed only.
 *
 * The endpoint produces **no forecast**, and says so in `disclaimer`, which is
 * rendered verbatim at the top because a reader who skims this tab should not
 * be able to walk away believing there is a projection behind these numbers.
 *
 * The second job is separating `observed: true` from `observed: false`. A
 * counted row and a ratio of two counted rows are both facts, but they answer
 * different questions, and the payload declares which is which on every signal.
 * Mixing them into one table is how a derived share gets quoted later as
 * though it were a count.
 */

function SignalCard({
  label,
  value,
  basis,
  note,
  derived,
  testId,
}: {
  label: string;
  value: string;
  basis: string;
  note?: string;
  derived: boolean;
  testId?: string;
}) {
  const Icon = derived ? Sigma : Eye;
  return (
    <Card className={`p-4 ${derived ? 'border-buddy-electric/25' : ''}`} data-testid={testId}>
      <div className="flex items-start justify-between gap-2">
        <p className="text-xs text-buddy-text-secondary">{label}</p>
        <span
          className={`inline-flex items-center gap-1 text-[10px] font-semibold px-1.5 py-0.5 rounded-full whitespace-nowrap ${
            derived ? 'bg-buddy-electric/15 text-buddy-electric' : 'bg-buddy-green/15 text-buddy-green'
          }`}
        >
          <Icon size={10} />
          {derived ? 'Derived' : 'Observed'}
        </span>
      </div>
      <p className="font-display font-extrabold text-xl mt-1">{value}</p>
      <p className="text-[11px] text-buddy-text-secondary mt-1 break-words">
        <span className="font-medium">Basis: </span>{basis}
      </p>
      {note && <p className="text-[11px] text-buddy-orange/90 mt-1 break-words">{note}</p>}
    </Card>
  );
}

export default function PredictiveTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [data, setData] = useState<AnalyticsPredictive | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getAnalyticsPredictive({ from, to })
      .then((res) => setData(res.data || null))
      .catch((err: unknown) => {
        const payload = (err as { response?: { data?: { message?: string } } })?.response?.data;
        setError(payload?.message || 'Could not load recommendation signals.');
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

  const signals = data?.signals || [];
  const observedSignals = signals.filter((s) => s.observed === true);
  const derivedSignals = signals.filter((s) => s.observed !== true);
  const feedback = data?.observed?.recommendation_feedback;
  const impressions = data?.observed?.recommendation_impressions;

  return (
    <div className="space-y-5">
      {data?.disclaimer && (
        <Card className="p-4 border-buddy-orange/25" data-testid="predictive-disclaimer">
          <div className="flex items-start gap-2">
            <AlertTriangle size={16} className="text-buddy-orange mt-0.5 shrink-0" />
            <p className="text-xs text-buddy-text-secondary break-words">{data.disclaimer}</p>
          </div>
        </Card>
      )}

      {data && <ReportWindowLine window={data.window} />}

      {signals.length === 0 ? (
        <NothingToShow title="No signals in this window." hint="Recommendation feedback and impressions are counted from the event stream." />
      ) : (
        <>
          <section>
            <h3 className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">
              Observed — counted directly
            </h3>
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {observedSignals.map((signal) => (
                <SignalCard
                  key={text(signal.key)}
                  testId="signal-observed"
                  label={text(signal.label)}
                  value={signal.value == null ? '—' : formatCount(signal.value)}
                  basis={text(signal.basis)}
                  note={signal.note}
                  derived={false}
                />
              ))}
            </div>
          </section>

          <section>
            <h3 className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">
              Derived from observed counts — ratios, not measurements
            </h3>
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {derivedSignals.map((signal) => (
                <SignalCard
                  key={text(signal.key)}
                  testId="signal-derived"
                  label={text(signal.label)}
                  value={signal.value == null ? '—' : formatRatio(signal.value)}
                  basis={text(signal.basis)}
                  note={signal.note}
                  derived
                />
              ))}
            </div>
          </section>
        </>
      )}

      <div className="grid gap-3 lg:grid-cols-2">
        {feedback && (
          <Card className="p-4">
            <p className="text-sm font-semibold">Recommendation feedback rows</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5 break-words">{text(feedback.source)}</p>
            <div className="grid grid-cols-3 gap-2 mt-2">
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Total</p>
                <p className="text-sm font-semibold">{formatCount(feedback.total)}</p>
              </div>
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Negative</p>
                <p className="text-sm font-semibold">{formatCount(feedback.negative)}</p>
              </div>
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Helpful</p>
                <p className="text-sm font-semibold">{formatCount(feedback.positive)}</p>
              </div>
            </div>
            {(feedback.rows || []).length > 0 && (
              <ul className="mt-2 space-y-1">
                {(feedback.rows || []).map((row) => (
                  <li key={text(row.feedback)} className="flex items-center justify-between gap-3 text-xs">
                    <span className="min-w-0 break-words">{text(row.feedback).replace(/_/g, ' ')}</span>
                    <span className="font-semibold">{formatCount(row.count)}</span>
                  </li>
                ))}
              </ul>
            )}
          </Card>
        )}

        {impressions && (
          <Card className="p-4">
            <p className="text-sm font-semibold">Recommendation impressions by source</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5 break-words">{text(impressions.source)}</p>
            <div className="grid grid-cols-4 gap-2 mt-2">
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Total</p>
                <p className="text-sm font-semibold">{formatCount(impressions.total)}</p>
              </div>
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Model</p>
                <p className="text-sm font-semibold">{formatCount(impressions.ai)}</p>
              </div>
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Fallback</p>
                <p className="text-sm font-semibold">{formatCount(impressions.fallback)}</p>
              </div>
              <div>
                <p className="text-[11px] text-buddy-text-secondary">Unlabelled</p>
                <p className="text-sm font-semibold">{formatCount(impressions.unlabelled)}</p>
              </div>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}