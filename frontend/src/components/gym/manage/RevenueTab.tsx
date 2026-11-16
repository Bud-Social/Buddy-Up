import { useEffect, useMemo, useState } from 'react';
import { Loader2, Wallet, TrendingUp, Gift, Store, CheckCheck } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { tierApi, shopsApi, type GymWalletSummary, type GymShopsPayload } from '@/api/gyms';
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
  const [shops, setShops] = useState<GymShopsPayload | null>(null);
  const [shopMode, setShopMode] = useState<'consolidated' | 'individual'>('consolidated');

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

  useEffect(() => {
    shopsApi.list(slug).then((res) => setShops(res.data ?? null)).catch(() => setShops(null));
  }, [slug]);

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

      {/* Attributed shop sales — consolidated vs per-shop infographic */}
      <Card className="p-4">
        <div className="flex items-center justify-between gap-2 flex-wrap">
          <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Store size={12} /> Attributed shop sales · 90d</p>
          <div className="flex rounded-lg bg-buddy-surface p-0.5" role="group" aria-label="Shop sales view">
            {([['consolidated', 'All shops'], ['individual', 'Per shop']] as const).map(([mode, label]) => (
              <button
                key={mode}
                onClick={() => setShopMode(mode)}
                aria-pressed={shopMode === mode}
                className={`px-2.5 py-1 rounded-md text-[10px] font-semibold transition-colors ${shopMode === mode ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {shops === null ? (
          <p className="text-[10px] text-buddy-text-secondary/70 mt-2">Could not load shop attribution — refresh to retry.</p>
        ) : shops.shops.length === 0 ? (
          <p className="text-[10px] text-buddy-text-secondary/70 mt-2">No shops approved yet. Sales feeds go live here the moment a connected shop accepts your request.</p>
        ) : shopMode === 'consolidated' ? (
          <div className="mt-2 space-y-2">
            <div className="flex flex-wrap gap-2">
              <span className="text-[10px] bg-buddy-surface rounded-lg px-2 py-1"><span className="font-semibold tabular-nums">{shops.totals.units_sold_90d}</span> units sold</span>
              <span className="text-[10px] bg-buddy-surface rounded-lg px-2 py-1"><span className="font-semibold tabular-nums">{shops.totals.orders_90d}</span> paid orders</span>
              <span className="text-[10px] bg-buddy-surface rounded-lg px-2 py-1"><span className="font-semibold tabular-nums">{shops.totals.shops}</span> approved shops</span>
            </div>
            {Object.keys(shops.totals.artifact_splits_90d).length > 0 && (
              <div className="space-y-1">
                <p className="text-[9px] uppercase text-buddy-text-secondary/70">Artifact split (seller share)</p>
                {Object.entries(shops.totals.artifact_splits_90d).map(([artifact, qty]) => {
                  const total = Object.values(shops.totals.artifact_splits_90d).reduce((a, b) => a + b, 0);
                  return (
                    <div key={artifact} className="flex items-center gap-2">
                      <ArtifactIcon artifact={artifact} size={12} className="w-14" />
                      <div className="flex-1 h-2 rounded bg-buddy-surface-raised overflow-hidden">
                        <div className="h-full bg-buddy-blue rounded" style={{ width: `${total > 0 ? (qty / total) * 100 : 0}%` }} />
                      </div>
                      <span className="text-[10px] tabular-nums w-8 text-right">{qty}</span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        ) : (
          <div className="space-y-2 mt-2">
            {[...shops.shops].sort((a, b) => b.units_sold_90d - a.units_sold_90d).map((shop) => {
              const max = Math.max(1, ...shops.shops.map((s) => s.units_sold_90d));
              return (
                <div key={shop.shop_id} className={`rounded-xl border px-3 py-2 ${shop.status === 'active' ? 'border-buddy-surface-raised bg-buddy-surface' : 'border-dashed border-buddy-gold/30 bg-buddy-gold/5'}`}>
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-lg overflow-hidden shrink-0 flex items-center justify-center" style={{ background: `${shop.accent_color || '#6366f1'}22` }}>
                      {shop.logo_url ? <img src={shop.logo_url} alt="" className="w-full h-full object-contain" /> : <Store size={14} />}
                    </div>
                    <p className="flex-1 min-w-0 text-[11px] font-semibold truncate">{shop.name}</p>
                    {shop.status === 'pending' && <span className="text-[9px] uppercase font-bold text-buddy-gold bg-buddy-gold/10 border border-buddy-gold/20 rounded-full px-1.5 py-0.5">Pending</span>}
                    {shop.status === 'active' && <CheckCheck size={12} className="text-buddy-green shrink-0" aria-label="Connected" />}
                  </div>
                  {shop.status === 'active' ? (
                    <>
                      <div className="flex items-center gap-2 mt-1.5 text-[10px] text-buddy-text-secondary">
                        <span className="tabular-nums">{shop.units_sold_90d} units</span> · <span className="tabular-nums">{shop.orders_90d} orders</span>
                        <div className="flex-1 h-1.5 rounded bg-buddy-surface-raised overflow-hidden ml-1">
                          <div className="h-full bg-buddy-green" style={{ width: `${(shop.units_sold_90d / max) * 100}%` }} />
                        </div>
                      </div>
                      {shop.artifact_splits_90d && Object.keys(shop.artifact_splits_90d).length > 0 && (
                        <div className="flex flex-wrap gap-1 mt-1.5">
                          {Object.entries(shop.artifact_splits_90d).map(([artifact, qty]) => (
                            <ArtifactIcon key={artifact} artifact={artifact} quantity={qty} size={12} className="text-[9px]" />
                          ))}
                        </div>
                      )}
                    </>
                  ) : (
                    <p className="text-[9px] text-buddy-text-secondary/80 mt-1">Waiting on the shop to approve — sales will appear here once they do.</p>
                  )}
                </div>
              );
            })}
          </div>
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
