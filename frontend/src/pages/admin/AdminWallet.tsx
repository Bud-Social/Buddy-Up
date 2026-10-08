import { useCallback, useEffect, useMemo, useState } from 'react';
import { ArrowDownLeft, ArrowUpRight, Receipt, RefreshCw, Scale } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalReconciliationReport, type PortalTransaction } from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminErrorState,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  DataRow,
  FilterChips,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, formatMoney, shortId, text } from './format';
import { useDebounced, usePortalList } from './usePortalList';

const TABS = [
  { value: 'transactions', label: 'Transactions' },
  { value: 'reconciliation', label: 'Reconciliation' },
] as const;
type Tab = (typeof TABS)[number]['value'];

const STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'completed', label: 'Completed' },
  { value: 'pending', label: 'Pending' },
  { value: 'held', label: 'Held' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
];

const DIRECTION_OPTIONS = [
  { value: 'all', label: 'Credits and debits' },
  { value: 'credit', label: 'Credits only' },
  { value: 'debit', label: 'Debits only' },
];

export default function AdminWallet() {
  const [tab, setTab] = useState<Tab>('transactions');
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');
  const [direction, setDirection] = useState('all');
  const debouncedQuery = useDebounced(query);

  const filters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status, direction }),
    [debouncedQuery, status, direction],
  );

  const fetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getTransactions(params as never), []);
  const { items, count, page, pageCount, loading, error, reload, goToPage } = usePortalList<PortalTransaction>(fetcher, filters);

  const reconciliation = useReconciliation(tab === 'reconciliation');

  if (tab === 'transactions') {
    if (loading && !items.length) return <AdminSkeleton />;
    if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;
  }

  const credits = items.filter((t) => t.direction === 'credit');
  const debits = items.filter((t) => t.direction === 'debit');
  const held = items.filter((t) => t.status === 'held' || t.status === 'pending').length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Wallet"
        description="Platform artifact ledger and the reconciliation report."
        onRefresh={() => (tab === 'transactions' ? reload() : reconciliation.reload())}
        refreshing={tab === 'transactions' ? loading : reconciliation.loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Transactions" value={count.toLocaleString()} sub="matching filters" />
        <AdminStatCard label="Credits on this page" value={credits.length} />
        <AdminStatCard label="Debits on this page" value={debits.length} />
        <AdminStatCard label="Pending / held" value={held} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips options={TABS.map((t) => ({ value: t.value, label: t.label }))} value={tab} onChange={(v) => setTab(v as Tab)} />
          {tab === 'transactions' && (
            <div className="ml-auto">
              <SearchField value={query} onChange={setQuery} label="Search transactions" placeholder="Reference, counterparty…" />
            </div>
          )}
        </div>
        {tab === 'transactions' && (
          <div className="flex flex-wrap items-center gap-2">
            <FilterChips options={STATUS_OPTIONS} value={status} onChange={setStatus} />
            <div className="ml-auto">
              <FilterChips options={DIRECTION_OPTIONS} value={direction} onChange={setDirection} />
            </div>
          </div>
        )}
      </Card>

      {tab === 'transactions' ? (
        <>
          {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
          {items.length === 0 ? (
            <AdminEmptyState icon={<Receipt size={32} />} title={count === 0 ? 'No transactions match the current filters.' : 'No transactions on this page.'} />
          ) : (
            <div className="space-y-2">
              {items.map((tx, index) => {
                const isCredit = tx.direction === 'credit';
                return (
                  <Card key={tx.id || `tx-${index}`} className="p-4">
                    <div className="flex flex-wrap items-start gap-3">
                      <div className="flex-1 min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className={`inline-flex items-center gap-1 text-[11px] font-semibold px-2 py-0.5 rounded-full ${isCredit ? 'bg-buddy-green/15 text-buddy-green' : 'bg-buddy-orange/15 text-buddy-orange'}`}>
                            {isCredit ? <ArrowDownLeft size={10} /> : <ArrowUpRight size={10} />}
                            {text(tx.direction).replace(/^./, (c) => c.toUpperCase())}
                          </span>
                          <span className="text-sm font-semibold truncate">{text(tx.description, text(tx.transaction_type, 'Transaction'))}</span>
                          <StatusBadge status={tx.status} />
                        </div>
                        <p className="text-xs text-buddy-text-secondary mt-1">
                          {text(tx.transaction_type)} · {text(tx.artifact_type)} · {text(tx.counterparty_name)}
                        </p>
                        <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                          {shortId(tx.id)} · ref {text(tx.reference_id)} · {formatDate(tx.created_at)}
                        </p>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <p className="font-display font-extrabold text-lg leading-tight">
                          {isCredit ? '+' : '−'}{text(tx.quantity)}
                        </p>
                        <p className="text-[11px] text-buddy-text-secondary">{formatMoney(tx.fiat_amount, text(tx.fiat_currency, 'USD'))}</p>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
          <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />
        </>
      ) : (
        <ReconciliationPanel
          report={reconciliation.report}
          loading={reconciliation.loading}
          error={reconciliation.error}
          onRetry={reconciliation.reload}
        />
      )}
    </div>
  );
}

/**
 * Reconciliation is a single object rather than a paginated list, so it gets a
 * tiny dedicated hook. Unknown bucket keys are read by name with a defensive
 * fallback — the report shape is allowed to grow server-side.
 */
function useReconciliation(enabled: boolean) {
  const [report, setReport] = useState<PortalReconciliationReport | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [nonce, setNonce] = useState(0);

  const reload = useCallback(() => setNonce((n) => n + 1), []);

  useEffect(() => {
    if (!enabled) return;
    let cancelled = false;
    setLoading(true);
    setError('');
    adminPortalApi.getReconciliation()
      .then((res) => { if (!cancelled) setReport(res?.data ?? null); })
      .catch((e) => {
        if (cancelled) return;
        setReport(null);
        setError(e instanceof Error ? e.message : 'Failed to load the reconciliation report.');
      })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [enabled, nonce]);

  return { report, loading, error, reload };
}

function ReconciliationPanel({
  report,
  loading,
  error,
  onRetry,
}: {
  report: PortalReconciliationReport | null;
  loading: boolean;
  error: string;
  onRetry: () => void;
}) {
  if (loading) return <AdminSkeleton rows={3} />;
  if (error) return <AdminErrorState message={error} onRetry={onRetry} />;
  if (!report) {
    return <AdminEmptyState icon={<Scale size={32} />} title="No reconciliation report available." hint="The endpoint returned no data." />;
  }

  const totals = report.totals && typeof report.totals === 'object' ? report.totals : {};
  const totalEntries = Object.entries(totals);
  const buckets = Array.isArray(report.buckets) ? report.buckets : [];
  const discrepancies = Array.isArray(report.discrepancies) ? report.discrepancies : [];

  return (
    <div className="space-y-3">
      <Card className="p-4">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div>
            <p className="text-sm font-semibold">Reconciliation report</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              {formatDate(report.generated_at)}
              {report.period_start ? ` · ${formatDate(report.period_start, false)} → ${formatDate(report.period_end, false)}` : ''}
            </p>
          </div>
          <Button variant="outline" size="sm" onClick={onRetry}>
            <RefreshCw size={14} className="mr-1" /> Refresh
          </Button>
        </div>
      </Card>

      {totalEntries.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {totalEntries.map(([key, value]) => (
            <AdminStatCard
              key={key}
              label={key.replace(/_/g, ' ')}
              value={typeof value === 'number' ? value.toLocaleString() : text(value)}
            />
          ))}
        </div>
      )}

      {buckets.length > 0 && (
        <Card className="p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">Buckets</p>
          <div className="space-y-1">
            {buckets.map((bucket, i) => (
              <div key={`${bucket.label}-${i}`} className="flex items-center justify-between gap-3 py-1.5 border-b border-buddy-surface last:border-0">
                <span className="flex items-center gap-2 min-w-0">
                  <span className="text-xs truncate">{text(bucket.label, 'Bucket')}</span>
                  <StatusBadge status={bucket.status} />
                </span>
                <span className="text-xs text-buddy-text-secondary flex-shrink-0">
                  {typeof bucket.count === 'number' ? `${bucket.count} · ` : ''}
                  {typeof bucket.quantity === 'number' ? `${bucket.quantity} · ` : ''}
                  {bucket.amount === undefined || bucket.amount === null ? '' : formatMoney(bucket.amount, text(report.currency, 'USD'))}
                </span>
              </div>
            ))}
          </div>
        </Card>
      )}

      {discrepancies.length === 0 ? (
        <AdminEmptyState icon={<Scale size={32} />} title="No discrepancies in this period." hint="Every settled transaction matches the provider record." />
      ) : (
        <Card className="p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary mb-2">
            Discrepancies ({discrepancies.length})
          </p>
          <div className="space-y-2">
            {discrepancies.map((d, i) => (
              <div key={`${d.reference_id}-${i}`} className="rounded-xl border border-buddy-surface p-3">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span className="text-xs font-semibold truncate">{text(d.reference_id)}</span>
                  <StatusBadge status={d.reason} />
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 mt-2">
                  <DataRow label="Expected">{d.expected === undefined || d.expected === null ? '—' : formatMoney(d.expected, text(report.currency, 'USD'))}</DataRow>
                  <DataRow label="Actual">{d.actual === undefined || d.actual === null ? '—' : formatMoney(d.actual, text(report.currency, 'USD'))}</DataRow>
                  <DataRow label="Reason">{text(d.reason)}</DataRow>
                  <DataRow label="Seen">{formatDate(d.created_at)}</DataRow>
                </div>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}