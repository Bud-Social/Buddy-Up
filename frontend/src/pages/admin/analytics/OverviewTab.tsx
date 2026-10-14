import { useCallback, useEffect, useState } from 'react';
import { adminPortalApi, type AnalyticsOverview, type AnalyticsWindowParams } from '@/api/adminPortal';
import { Card } from '@/components/ui/Card';
import { formatCount, formatMoney, text } from './format';
import { KpiCard, NothingToShow, PerformanceNotesPanel, ReportWindowLine } from './shared';

/**
 * Overview — the headline figures, grouped, plus the breakdown tables.
 *
 * The tab's whole job is to keep the two kinds of KPI apart. The API hands back
 * a single flat `kpis` array mixing cumulative gauges (`All time`) with period
 * flows (`Window`), and a grid that sorted them together would let an operator
 * read "Total users 41,203" next to "New users 2,914" as two halves of one
 * period. Grouping is by the server's own `group`, so a new metric appears under
 * the right heading without this file being edited.
 */
export default function OverviewTab({ window: windowParams }: { window: AnalyticsWindowParams }) {
  const { from, to } = windowParams;
  const [data, setData] = useState<AnalyticsOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    setError('');
    adminPortalApi
      .getAnalyticsOverview({ from, to })
      .then((res) => setData(res.data || null))
      .catch((err: unknown) => {
        const message = (err as { response?: { data?: { message?: string; errors?: Record<string, string[]> } } })?.response?.data;
        const detail = message?.errors ? Object.entries(message.errors).map(([k, v]) => `${k}: ${v.join(' ')}`).join(' ') : '';
        setError([message?.message, detail].filter(Boolean).join(' — ') || 'Could not load the platform overview.');
      })
      .finally(() => setLoading(false));
  }, [from, to]);

  useEffect(() => { load(); }, [load]);

  if (loading && !data) {
    return (
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {Array.from({ length: 8 }).map((_, i) => (
          <Card key={i} className="h-24 animate-pulse bg-buddy-surface-raised" />
        ))}
      </div>
    );
  }

  if (error && !data) {
    return (
      <Card className="p-6 text-center">
        <p className="text-sm text-buddy-red break-words">{error}</p>
      </Card>
    );
  }

  const kpis = data?.kpis || [];
  const groups = data?.groups || Array.from(new Set(kpis.map((k) => text(k.group, 'other'))));
  const breakdowns = data?.breakdowns || [];

  return (
    <div className="space-y-5">
      <ReportWindowLine window={data?.window} generatedAt={data?.generated_at} />

      <PerformanceNotesPanel notes={data?.performance_notes} />

      {kpis.length === 0 ? (
        <NothingToShow title="The overview returned no figures." hint="Every KPI in the registry failed to compute." />
      ) : (
        groups.map((group) => (
          <section key={group}>
            <h3 className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">
              {group}
            </h3>
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
              {kpis.filter((k) => text(k.group, 'other') === group).map((kpi) => (
                <KpiCard key={text(kpi.key)} kpi={kpi} />
              ))}
            </div>
          </section>
        ))
      )}

      {breakdowns.length > 0 && (
        <div className="grid gap-3 lg:grid-cols-2">
          {breakdowns.map((breakdown) => {
            const columns = Object.keys(breakdown.rows?.[0] ?? {});
            if (!columns.length) return null;
            return (
              <Card key={text(breakdown.title)} className="p-4">
                <p className="text-sm font-semibold">{text(breakdown.title)}</p>
                {breakdown.basis && <p className="text-[11px] text-buddy-text-secondary mt-0.5">{breakdown.basis}</p>}
                {breakdown.note && <p className="text-[11px] text-buddy-orange/90 mt-1">{breakdown.note}</p>}
                <div className="mt-3 overflow-x-auto">
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="text-left text-buddy-text-secondary">
                        {columns.map((column) => (
                          <th key={column} className="font-medium py-1 pr-3 whitespace-nowrap">
                            {column.replace(/_/g, ' ')}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {(breakdown.rows || []).map((row, index) => (
                        <tr key={index} className="border-t border-buddy-surface">
                          {columns.map((column) => {
                            const value = row[column];
                            const shown =
                              typeof value === 'number'
                                ? column.includes('fiat')
                                  ? formatMoney(value)
                                  : formatCount(value)
                                : text(value);
                            return (
                              <td key={column} className="py-1 pr-3 whitespace-nowrap">{shown}</td>
                            );
                          })}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}