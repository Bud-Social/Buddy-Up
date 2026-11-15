import { useEffect, useState } from 'react';
import { ShieldCheck, Loader2, Check, Ban } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { VerifiedGymBadge } from '@/components/gym/VerifiedGymBadge';
import { tierApi, type TierOverview } from '@/api/gyms';
import { startTierCheckout } from '@/lib/tierCheckout';

interface TierPanelProps {
  slug: string;
}

const PLAN_CTA: Record<string, string> = {
  regular: 'Current plan',
  midlevel: 'Upgrade to Mid-Level',
  executive: 'Upgrade to Executive',
};

/**
 * Verification tier management — current state, badge explainer and upgrade
 * checkout. Paid monthly via Flutterwave; the gym's currency comes from its
 * location_country (USD default, KES for Kenyan gyms).
 */
export function TierPanel({ slug }: TierPanelProps) {
  const [overview, setOverview] = useState<TierOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await tierApi.tier(slug);
      setOverview(res.data ?? null);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load tier details.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [slug]); // eslint-disable-line react-hooks/exhaustive-deps

  const subscribe = async (tier: 'midlevel' | 'executive') => {
    setBusy(tier);
    setError(null);
    try {
      const result = await startTierCheckout(slug, tier);
      if (result.status === 'confirmed') {
        await load();
      } else if (result.status === 'failed' && result.message) {
        setError(result.message);
      }
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Checkout failed.');
    } finally {
      setBusy(null);
    }
  };

  const cancel = async () => {
    if (!window.confirm('Stop the monthly tier charge? You keep benefits until the paid period ends, then drop to Regular.')) return;
    setBusy('cancel');
    try {
      await tierApi.tierCancel(slug);
      await load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not cancel.');
    } finally {
      setBusy(null);
    }
  };

  if (loading) return <Card className="h-32 animate-pulse bg-buddy-surface-raised" />;
  if (!overview) {
    return (
      <Card className="p-4">
        <p className="text-xs text-buddy-red">{error || 'Tier details unavailable.'}</p>
        <Button size="sm" variant="ghost" onClick={load} className="mt-2">Retry</Button>
      </Card>
    );
  }

  const { subscription, plans, currency } = overview;
  const currentTier = subscription.tier;
  const atCap = subscription.capacity.at_cap;

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <VerifiedGymBadge verified tier={currentTier} size="md" />
          <div>
            <p className="text-xs font-bold capitalize">{currentTier === 'midlevel' ? 'Mid-Level' : currentTier} gym</p>
            <p className="text-[10px] text-buddy-text-secondary capitalize">{subscription.status}{subscription.current_period_end ? ` · renews ${new Date(subscription.current_period_end).toLocaleDateString()}` : ''}{currency !== 'USD' ? ` · ${currency}` : ''}</p>
          </div>
        </div>
        {subscription.auto_renew && (
          <Button size="sm" variant="ghost" onClick={cancel} isLoading={busy === 'cancel'} className="gap-1 text-buddy-red">
            <Ban size={12} /> Cancel
          </Button>
        )}
      </div>

      {/* Capacity bar */}
      <div>
        <div className="flex items-center justify-between text-[10px] text-buddy-text-secondary mb-1">
          <span>{subscription.capacity.current} members{subscription.capacity.cap != null ? ` of ${subscription.capacity.cap}` : ' · unlimited'}</span>
          {atCap && <span className="text-buddy-red font-semibold">Full — upgrade to onboard new members</span>}
        </div>
        {subscription.capacity.cap != null && (
          <div className="h-2 w-full rounded-full bg-buddy-surface-raised overflow-hidden">
            <div
              className={`h-full rounded-full ${atCap ? 'bg-buddy-red' : 'bg-buddy-green'}`}
              style={{ width: `${Math.min(100, (subscription.capacity.current / subscription.capacity.cap) * 100)}%` }}
            />
          </div>
        )}
      </div>

      {subscription.status === 'grace' && subscription.grace_deadline && (
        <p className="text-[11px] text-buddy-gold bg-buddy-gold/10 border border-buddy-gold/20 rounded-lg px-2 py-1.5">
          Payment overdue. You have until {new Date(subscription.grace_deadline).toLocaleDateString()} before the badge downgrades to Regular. New joins are frozen until then.
        </p>
      )}

      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Plans */}
      <div className="grid grid-cols-3 gap-2">
        {(['regular', 'midlevel', 'executive'] as const).map((tier) => {
          const plan = plans[tier];
          if (!plan) return null;
          const isCurrent = currentTier === tier;
          const displayAmount = plan.amount_minor > 0
            ? `${plan.amount_minor / 100} ${plan.currency}`
            : 'Free';
          return (
            <div
              key={tier}
              className={`rounded-2xl border p-2 text-center ${
                isCurrent ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface-raised'
              }`}
            >
              <VerifiedGymBadge verified tier={tier} size="sm" className="mx-auto mb-1" />
              <p className="text-[10px] font-bold capitalize">{tier === 'midlevel' ? 'Mid-Level' : tier}</p>
              <p className="text-[10px] text-buddy-text-secondary">{displayAmount}{plan.amount_minor > 0 ? '/mo' : ''}</p>
              <p className="text-[9px] text-buddy-text-secondary/70">{plan.cap == null ? '∞ members' : `${plan.cap} member cap`}</p>
              {isCurrent ? (
                <p className="mt-1.5 text-[10px] font-bold text-buddy-green flex items-center justify-center gap-1"><Check size={10} /> Current</p>
              ) : tier === 'regular' ? (
                <p className="mt-1.5 text-[9px] text-buddy-text-secondary/70">Default tier</p>
              ) : (
                <Button size="sm" variant="outline" className="w-full mt-1.5 text-[9px] h-7 px-1.5" isLoading={busy === tier} onClick={() => subscribe(tier)}>
                  {PLAN_CTA[tier]}
                </Button>
              )}
            </div>
          );
        })}
      </div>

      <p className="text-[9px] text-buddy-text-secondary/70">
        Badge charges are monthly. Executive ≈ USD 45/mo, Mid-Level ≈ USD 12/mo — charged in {currency}. Downgrade keeps existing members; it only caps new joins.
      </p>
    </Card>
  );
}
