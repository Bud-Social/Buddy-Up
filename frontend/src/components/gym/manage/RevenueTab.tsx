import { useEffect, useMemo, useState } from 'react';
import { Loader2, Wallet, TrendingUp, Gift } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { tierApi, type GymWalletSummary } from '@/api/gyms';
import { TierPanel } from './TierPanel';

interface RevenueTabProps {
  slug: string;
}

const KIND_LABEL: Record<string, string> = {
  join_fee: 'Join fees',
  subscription_fee: 'Subscriptions',
  live_fee: 'Charged lives',
  event_fee: 'Charged events',
  shop_sale: 'Attributed shop sales',
  donation: 'Donations (fiat)',
  adjustment: 'Adjustments',
};

const WINDOWS = [7, 30, 90, 365] as const;

/**
 * Gym wallet view — artifacts the gym holds, where they came from and
 * the full ledger. Also hosts the verification tier panel: both answer
 * "how is this gym making money?".
 */
export function RevenueTab({ slug }: RevenueTabProps) {
  const [summary, setSummary] = useState<GymWalletSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [windowDays, setWindowDays] = useState<7 | 30 | 90 | 365>(30);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await tierApi.wallet(slug, windowDays);
      setSummary(res.data ?? null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load the gym wallet.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [slug, windowDays]); // eslint-disable-line react-hooks/exhaustive-deps

  const byKind = summary?.by_kind ?? {};
  const maxKindValue = useMemo(
    () => Math.max(1, ...Object.values(byKind).map((d) => d.credit?.quantity || 0)),
    [byKind],
  );

  return (
    <section className="space-y-3">
      <TierPanel slug={slug} />

      <Card className="p-4">
        <div className="flex items-center justify-between gap-2 flex-wrap">
          <div>
            <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Wallet size={12} /> Gym wallet</p>
            <p className="text-2xl font-extrabold mt-1">{summary?.usd_estimate ?? '—'} <span className="text-xs font-semibold text-buddy-text-secondary">USD</span></p>
            <p className="text-[9px] text-buddy-text-secondary/70">Artifact value (includes all denominations)</p>
          </div>
          <div className="flex gap-1">
            {WINDOWS.map((d) => (
              <button
                key={d}
                onClick={() => setWindowDays(d)}
                className={`px-2.5 py-1 rounded-lg text-[10px] font-semibold transition-colors ${windowDays === d ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-text-secondary'}`}
              >
                {d}d
              </button>
            ))}
          </div>
        </div>

        {/* Balance by denomination */}
        {summary && Object.keys(summary.balance).length > 0 && (
          <div className="flex flex-wrap gap-2 mt-3">
            {Object.entries(summary.balance).map(([artifact, qty]) => (
              <ArtifactIcon key={artifact} artifact={artifact} quantity={qty} size={16} className="bg-buddy-surface-raised rounded-lg px-2 py-1" />
            ))}
          </div>
        )}
        {summary && Object.keys(summary.balance).length === 0 && (
          <p className="text-[10px] text-buddy-text-secondary/70 mt-2">No artifacts yet — joins, charged lives and paid events feed this wallet.</p>
        )}
      </Card>

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Where money came from */}
      <Card className="p-4">
        <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5 mb-2"><TrendingUp size={12} /> What fed the wallet · {windowDays}d</p>
        {summary && Object.keys(byKind).length > 0 ? (
          <div className="space-y-1.5">
            {Object.entries(byKind).map(([kind, directions]) => {
              const credit = directions.credit?.quantity || 0;
              if (credit <= 0 && (directions.debit?.quantity || 0) <= 0) return null;
              return (
                <div key={kind} className="flex items-center gap-2">
                  <span className="text-[10px] w-28 truncate text-buddy-text-secondary">{KIND_LABEL[kind] || kind}</span>
                  <div className="flex-1 h-2.5 rounded bg-buddy-surface-raised overflow-hidden">
                    <div className="h-full bg-buddy-green rounded" style={{ width: `${(credit / maxKindValue) * 100}%` }} />
                  </div>
                  <span className="text-[10px] tabular-nums w-8 text-right">{credit}</span>
                </div>
              );
            })}
          </div>
        ) : (
          <p className="text-[10px] text-buddy-text-secondary/70">Nothing yet in this window.</p>
        )}
        {summary && (
          <p className="text-[10px] text-buddy-text-secondary/70 mt-2 flex items-center gap-1">
            <Gift size={11} /> Donations (fiat): {(summary.donations_received ?? 0).toFixed(2)} — shown separately from artifacts
          </p>
        )}
      </Card>

      {/* Ledger */}
      <Card className="overflow-hidden">
        <div className="flex items-center justify-between px-4 pt-3 pb-2">
          <p className="text-[10px] uppercase text-buddy-text-secondary">Ledger</p>
          {loading && <Loader2 size={12} className="animate-spin text-buddy-green" />}
        </div>
        {summary && summary.entries.length > 0 ? (
          <div className="max-h-64 overflow-y-auto divide-y divide-buddy-surface-raised">
            {summary.entries.slice(0, 50).map((entry) => (
              <div key={entry.id} className="flex items-center gap-2 px-4 py-2 text-xs">
                <ArtifactIcon artifact={entry.artifact_type} size={14} className="w-20" />
                <span className={entry.direction === 'credit' ? 'text-buddy-green' : 'text-buddy-red'}>
                  {entry.direction === 'credit' ? '+' : '−'}{entry.quantity}
                </span>
                <span className="text-buddy-text-secondary text-[10px] flex-1 truncate">{KIND_LABEL[entry.kind] || entry.kind}{entry.note ? ` · ${entry.note}` : ''}</span>
                <span className="text-[9px] text-buddy-text-secondary/60 tabular-nums">{new Date(entry.created_at).toLocaleDateString()}</span>
              </div>
            ))}
          </div>
        ) : (
          <p className="px-4 pb-4 text-[10px] text-buddy-text-secondary/70">No transactions recorded yet.</p>
        )}
      </Card>
    </section>
  );
}
