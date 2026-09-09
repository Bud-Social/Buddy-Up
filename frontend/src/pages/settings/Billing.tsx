import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronRight, CreditCard, Loader, Wallet } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { gymsApi, walletApi } from '@/api';
import type { BalanceResponse } from '@/api/wallet';
import type { Gym } from '@/types';
import { SectionShell } from './SectionShell';

export default function Billing() {
  const navigate = useNavigate();
  const [balance, setBalance] = useState<BalanceResponse | null>(null);
  const [gyms, setGyms] = useState<Gym[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    Promise.allSettled([walletApi.getBalance(), gymsApi.list({ my: true })])
      .then(([balanceRes, gymsRes]) => {
        if (cancelled) return;
        if (balanceRes.status === 'fulfilled') setBalance(balanceRes.value.data);
        if (gymsRes.status === 'fulfilled') setGyms(gymsRes.value.data || []);
        if (balanceRes.status === 'rejected' && gymsRes.status === 'rejected') {
          setError('Could not load your billing details.');
        }
      })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

  return (
    <SectionShell title="Subscription & Billing">
      {loading ? (
        <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
      ) : (
        <div className="space-y-4">
          {error && <p className="text-xs text-buddy-red">{error}</p>}

          <Card className="p-4 space-y-3">
            <p className="text-sm font-medium">Wallet Balance</p>
            {balance ? (
              <>
                <div className="flex justify-between text-sm">
                  <span className="text-buddy-text-secondary">Fiat total</span>
                  <span className="font-medium">{balance.fiat_currency} {balance.total_fiat.toLocaleString(undefined, { maximumFractionDigits: 2 })}</span>
                </div>
                {balance.balance.map((item) => (
                  <div key={item.artifact_type} className="flex justify-between text-sm">
                    <span className="text-buddy-text-secondary">{item.label}</span>
                    <span>{item.quantity.toLocaleString()} <span className="text-xs text-buddy-text-secondary">(~${item.usd_value.toLocaleString(undefined, { maximumFractionDigits: 2 })})</span></span>
                  </div>
                ))}
              </>
            ) : (
              <p className="text-xs text-buddy-text-secondary">Balance unavailable.</p>
            )}
          </Card>

          <Card className="p-4 space-y-3">
            <p className="text-sm font-medium">Active Gym Subscriptions</p>
            {gyms.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">No active paid gym subscriptions.</p>
            ) : (
              gyms.map((gym) => (
                <button key={gym.id} onClick={() => navigate(`/gyms/${gym.handle}`)}
                  className="w-full flex items-center justify-between gap-2 text-sm group">
                  <span className="min-w-0">
                    <span className="block font-medium truncate group-hover:text-buddy-green">{gym.name}</span>
                    <span className="block text-xs text-buddy-text-secondary capitalize">
                      {gym.subscription_type}
                      {gym.monthly_fee_artifacts && ` · ${Object.entries(gym.monthly_fee_artifacts).map(([k, v]) => `${v} ${k}`).join(', ')}/mo`}
                    </span>
                  </span>
                  <ChevronRight size={16} className="text-buddy-text-secondary flex-shrink-0" />
                </button>
              ))
            )}
          </Card>

          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4">
              <Wallet size={18} className="text-buddy-green mb-2" />
              <p className="text-sm font-medium mb-1">Billing History</p>
              <p className="text-xs text-buddy-text-secondary mb-3">All transactions live in your Wallet.</p>
              <Button variant="outline" size="sm" className="w-full" onClick={() => navigate('/wallet')}>Go to Wallet</Button>
            </Card>
            <Card className="p-4">
              <CreditCard size={18} className="text-buddy-green mb-2" />
              <p className="text-sm font-medium mb-1">Discover Gyms</p>
              <p className="text-xs text-buddy-text-secondary mb-3">Browse gyms and membership plans.</p>
              <Button variant="outline" size="sm" className="w-full" onClick={() => navigate('/gyms')}>Browse Gyms</Button>
            </Card>
          </div>
        </div>
      )}
    </SectionShell>
  );
}
