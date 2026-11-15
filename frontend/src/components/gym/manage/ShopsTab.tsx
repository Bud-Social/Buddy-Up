import { useEffect, useState } from 'react';
import { Store, Unplug, ExternalLink, ShieldCheck, ShoppingBag } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { shopsApi, type GymShopSummary, type GymShopsPayload } from '@/api/gyms';

interface ShopsTabProps {
  slug: string;
  canManage: boolean;
}

/**
 * Shops connected to this gym.
 *
 * The gym connects shops it works with (affiliate, partner, house shop).
 * Sales are attributed best-effort from paid order items against the
 * linked shop's catalogue — exact per-type artifact splits come from each
 * item's seller split ledger.
 */
export function ShopsTab({ slug, canManage }: ShopsTabProps) {
  const [summary, setSummary] = useState<GymShopsPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [handle, setHandle] = useState('');
  const [connecting, setConnecting] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await shopsApi.list(slug);
      setSummary(res.data ?? null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load connected shops.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [slug]); // eslint-disable-line react-hooks/exhaustive-deps

  const connect = async () => {
    const value = handle.trim().toLowerCase().replace(/^@/, '');
    if (!value) return;
    setConnecting(true);
    setError(null);
    try {
      await shopsApi.connect(slug, value);
      setHandle('');
      await load();
    } catch (e: any) {
      setError(e?.response?.data?.message || `No active shop with handle “${value}”.`);
    } finally {
      setConnecting(false);
    }
  };

  const disconnect = async (shop: GymShopSummary) => {
    if (!window.confirm(`Disconnect ${shop.name} from this gym?`)) return;
    try {
      await shopsApi.disconnect(slug, shop.handle);
      await load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not disconnect that shop.');
    }
  };

  const splits = summary?.totals.artifact_splits_90d ?? {};

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-2">
          <Store size={14} /> Shops ({summary?.shops.length ?? 0})
        </h2>
        <p className="text-[10px] text-buddy-text-secondary/70">Affiliate & partner shops</p>
      </div>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">
          {error}
        </div>
      )}

      {canManage && (
        <Card className="p-3 space-y-2">
          <p className="text-xs font-semibold text-buddy-text-primary">Connect a shop</p>
          <p className="text-[10px] text-buddy-text-secondary">
            Enter the shop's handle — e.g. “iron-gear”. The shop keeps running normally; this only links it to your gym for attribution.
          </p>
          <div className="flex gap-2">
            <div className="flex-1">
              <Input
                value={handle}
                onChange={(e) => setHandle(e.target.value)}
                placeholder="shop-handle"
                onKeyDown={(e) => { if (e.key === 'Enter') connect(); }}
                aria-label="Shop handle"
              />
            </div>
            <Button size="sm" onClick={connect} isLoading={connecting}>Connect</Button>
          </div>
        </Card>
      )}

      {loading ? (
        <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
      ) : summary && summary.shops.length > 0 ? (
        <>
          <Card className="p-4 flex items-center justify-between">
            <div>
              <p className="text-[10px] uppercase text-buddy-text-secondary">Last 90 days</p>
              <p className="text-lg font-extrabold">{summary.totals.units_sold_90d} items</p>
              <p className="text-[10px] text-buddy-text-secondary">{summary.totals.orders_90d} orders</p>
            </div>
            <div className="grid grid-cols-2 gap-1.5 text-right">
              {Object.keys(splits).length === 0
                ? <p className="text-[10px] text-buddy-text-secondary/70 col-span-2">No artifact splits yet</p>
                : Object.entries(splits).map(([artifact, qty]) => (
                  <p key={artifact} className="text-[10px] text-buddy-text-secondary">{qty} <span className="capitalize">{artifact}</span></p>
                ))}
            </div>
          </Card>

          <div className="space-y-2">
            {summary.shops.map((shop) => (
              <Card key={shop.id} className="p-3 flex items-center gap-3">
                <div
                  className="w-11 h-11 rounded-xl flex items-center justify-center text-buddy-green overflow-hidden"
                  style={{ background: `${shop.accent_color || '#6366f1'}22` }}
                >
                  {shop.logo_url
                    ? <img src={shop.logo_url} alt="" className="w-full h-full object-contain" />
                    : <Store size={20} />}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold truncate flex items-center gap-1.5">
                    {shop.name}
                    {shop.verification_status === 'verified' && <ShieldCheck size={12} className="text-buddy-blue" />}
                  </p>
                  <p className="text-[10px] text-buddy-text-secondary truncate">@{shop.handle} · {shop.products_count} products · {shop.units_sold_90d} sold</p>
                  {shop.description && <p className="text-[9px] text-buddy-text-secondary/70 truncate">{shop.description}</p>}
                </div>
                <div className="flex items-center gap-1">
                  <a href={`/marketplace/shops/${shop.handle}`} target="_blank" rel="noreferrer" className="p-1.5 text-buddy-text-secondary hover:text-buddy-green" aria-label="Open shop"><ExternalLink size={14} /></a>
                  {canManage && (
                    <button onClick={() => disconnect(shop)} className="p-1.5 text-buddy-text-secondary hover:text-buddy-red" title={`Disconnect ${shop.name}`}>
                      <Unplug size={14} />
                    </button>
                  )}
                </div>
              </Card>
            ))}
          </div>
        </>
      ) : (
        <Card className="p-8 text-center text-buddy-text-secondary text-xs">
          <ShoppingBag size={28} className="mx-auto mb-2 opacity-40" />
          No shops connected yet. Connect one above to start tracking gym-attributed sales.
        </Card>
      )}
    </section>
  );
}
