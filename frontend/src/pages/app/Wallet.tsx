import { useState, useEffect, useCallback, useRef } from 'react';
import { ShoppingBag, Send, Clock, ArrowDownLeft, ArrowUpRight, DollarSign, CreditCard, Smartphone, Search, X, Plus, Minus, Building2, Edit2, ArrowRightLeft } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { walletApi } from '@/api/wallet';
import { profilesApi } from '@/api/profiles';
import type { BalanceResponse, BundleInfo } from '@/api/wallet';
import type { ArtifactTransaction } from '@/types';
import type { Profile } from '@/types';

type WalletTab = 'overview' | 'buy' | 'send' | 'history' | 'withdraw';
const ALL_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'];

export default function Wallet() {
  const [activeTab, setActiveTab] = useState<WalletTab>('overview');
  const [balance, setBalance] = useState<BalanceResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const fetchBalance = useCallback(async () => {
    try {
      const res = await walletApi.getBalance();
      setBalance(res.data);
    } catch {} finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { fetchBalance(); }, [fetchBalance]);

  const tabs: { key: WalletTab; label: string; icon: typeof ShoppingBag }[] = [
    { key: 'overview', label: 'Overview', icon: ShoppingBag },
    { key: 'buy', label: 'Buy', icon: CreditCard },
    { key: 'send', label: 'Send', icon: Send },
    { key: 'history', label: 'History', icon: Clock },
    { key: 'withdraw', label: 'Withdraw', icon: DollarSign },
  ];

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Wallet</h1>

      <div className="flex overflow-x-auto gap-2 mb-4 scrollbar-hide">
        {tabs.map(({ key, label, icon: Icon }) => (
          <button key={key} onClick={() => setActiveTab(key)}
            className={`flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-medium whitespace-nowrap transition-colors ${
              activeTab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary border border-buddy-surface hover:text-buddy-text-primary'
            }`}
          ><Icon size={14} /> {label}</button>
        ))}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          <div className="bg-buddy-surface rounded-2xl h-40 animate-pulse" />
          <div className="bg-buddy-surface rounded-2xl h-64 animate-pulse" />
        </div>
      ) : (
        <>
          {activeTab === 'overview' && <OverviewTab balance={balance} onBuyClick={() => setActiveTab('buy')} onSendClick={() => setActiveTab('send')} refetchBalance={fetchBalance} />}
          {activeTab === 'buy' && <BuyTab refetch={fetchBalance} />}
          {activeTab === 'send' && <SendTab refetch={fetchBalance} />}
          {activeTab === 'history' && <HistoryTab />}
          {activeTab === 'withdraw' && <WithdrawTab balance={balance} refetch={fetchBalance} />}
        </>
      )}
    </div>
  );
}

function OverviewTab({ balance, onBuyClick, onSendClick, refetchBalance }: { balance: BalanceResponse | null; onBuyClick?: () => void; onSendClick?: () => void; refetchBalance: () => void; }) {
  const [rates, setRates] = useState<{ conversion_rate: number; base_currency: string; local_currency: string } | null>(null);
  const [showTransfer, setShowTransfer] = useState(false);
  const [transferTarget, setTransferTarget] = useState<{ artifact: string; available: number } | null>(null);
  const [showCreatorNameEdit, setShowCreatorNameEdit] = useState(false);
  const hasCreatorBalance = (balance?.creator_balance || []).some((i) => i.quantity > 0);

  const openTransfer = (artifact: string, available: number) => {
    setTransferTarget({ artifact, available });
    setShowTransfer(true);
  };

  useEffect(() => {
    walletApi.getExchangeRates().then((res) => {
      setRates(res.data);
    }).catch(() => {});
  }, []);

  return (
    <div className="space-y-4">
      <Card className="p-6 bg-gradient-to-br from-buddy-green/20 to-buddy-surface">
        <p className="text-sm text-buddy-text-secondary">Total Balance</p>
        <p className="font-display text-3xl font-extrabold mt-1">{balance?.total_label || '$0.00'}</p>
      </Card>

      <div className="flex flex-wrap gap-2">
        {(balance?.balance || []).map((item) => (
          <Card key={item.artifact_type}
            className={`p-3 text-center flex-1 min-w-[80px] ${item.quantity > 0 ? 'bg-buddy-surface-raised' : 'opacity-50'}`}>
            <ArtifactIcon artifact={item.artifact_type} size={24} quantity={item.quantity} />
            <p className="font-mono text-xs mt-1 font-bold">{item.quantity}</p>
            <p className="text-[10px] text-buddy-text-secondary">${item.usd_value.toFixed(2)}</p>
          </Card>
        ))}
      </div>

      {/* Regular Wallet Section */}
      <Card className="p-4">
        <p className="text-xs font-bold text-buddy-text-secondary uppercase mb-2">Wallet Balance</p>
        <div className="flex flex-wrap gap-2">
          {(balance?.regular_balance || []).filter((i) => i.quantity > 0).map((item) => (
            <Card key={item.artifact_type} className="p-2.5 text-center flex-1 min-w-[70px] bg-buddy-surface-raised">
              <ArtifactIcon artifact={item.artifact_type} size={20} quantity={item.quantity} />
              <p className="font-mono text-[11px] mt-1 font-bold">{item.quantity}</p>
            </Card>
          ))}
          {(balance?.regular_balance || []).filter((i) => i.quantity > 0).length === 0 && (
            <p className="text-xs text-buddy-text-secondary">No tokens in regular wallet.</p>
          )}
        </div>
        <p className="text-right text-xs text-buddy-text-secondary mt-2">USD ${balance?.regular_total_fiat.toFixed(2) || '0.00'}</p>
      </Card>

      {(hasCreatorBalance || (balance?.creator_display_name)) && (
        <Card className="p-4 border-l-2 border-buddy-gold/60">
          <div className="flex items-center justify-between mb-1">
            <p className="text-xs font-bold text-buddy-gold uppercase">
              {balance?.creator_display_name ? `${balance.creator_display_name}'s Creator Wallet` : 'Creator Wallet'}
            </p>
            <button
              onClick={() => setShowCreatorNameEdit(true)}
              className="text-buddy-text-secondary hover:text-buddy-gold transition-colors"
              title="Edit creator display name"
            >
              <Edit2 size={12} />
            </button>
          </div>
          <div className="flex flex-wrap gap-2">
            {(balance?.creator_balance || []).filter((i) => i.quantity > 0).map((item) => (
              <button
                key={item.artifact_type}
                onClick={() => openTransfer(item.artifact_type, item.quantity)}
                className="p-2.5 text-center flex-1 min-w-[70px] bg-buddy-gold/5 hover:bg-buddy-gold/15 rounded-xl transition-colors"
                title="Transfer to wallet"
              >
                <ArtifactIcon artifact={item.artifact_type} size={20} quantity={item.quantity} />
                <p className="font-mono text-[11px] mt-1 font-bold">{item.quantity}</p>
              </button>
            ))}
            {(balance?.creator_balance || []).filter((i) => i.quantity > 0).length === 0 && (
              <p className="text-xs text-buddy-text-secondary">No marketplace earnings yet.</p>
            )}
          </div>
          <p className="text-right text-xs text-buddy-text-secondary mt-2">USD ${balance?.creator_total_fiat.toFixed(2) || '0.00'}</p>
        </Card>
      )}

      {showTransfer && transferTarget && (
        <TransferModal
          artifact={transferTarget.artifact}
          available={transferTarget.available}
          onClose={() => setShowTransfer(false)}
          onTransferred={() => { setShowTransfer(false); refetchBalance(); }}
        />
      )}

      {showCreatorNameEdit && (
        <CreatorNameEditModal
          current={balance?.creator_display_name || ''}
          onClose={() => setShowCreatorNameEdit(false)}
          onSaved={() => { setShowCreatorNameEdit(false); refetchBalance(); }}
        />
      )}

      {rates && (
        <Card className="p-3 flex items-center justify-between text-xs text-buddy-text-secondary">
          <span>Exchange Rate</span>
          <span className="font-medium">1 {rates.base_currency} = {rates.conversion_rate} {rates.local_currency}</span>
        </Card>
      )}

      <div className="grid grid-cols-2 gap-3">
        <Card className="p-4 text-center hover:bg-buddy-surface-raised cursor-pointer transition-colors" onClick={onBuyClick}>
          <CreditCard size={24} className="mx-auto text-buddy-green mb-2" />
          <p className="font-medium text-sm">Buy Tokens</p>
        </Card>
        <Card className="p-4 text-center hover:bg-buddy-surface-raised cursor-pointer transition-colors" onClick={onSendClick}>
          <Send size={24} className="mx-auto text-buddy-electric mb-2" />
          <p className="font-medium text-sm">Send / Tip</p>
        </Card>
      </div>
    </div>
  );
}

const ARTIFACT_UNIT_PRICES: Record<string, number> = {
  dumbbell: 0.10, barbell: 0.50, burpee: 1.00,
  squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00,
};

function BuyTab({ refetch }: { refetch: () => void }) {
  const [bundles, setBundles] = useState<BundleInfo[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [method, setMethod] = useState('card');
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [isConfirming, setIsConfirming] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');
  const [pendingTxRef, setPendingTxRef] = useState<string | null>(null);

  const [customType, setCustomType] = useState('dumbbell');
  const [customQty, setCustomQty] = useState(10);
  const [showCustom, setShowCustom] = useState(false);
  const [customUsd, setCustomUsd] = useState<number | null>(null);

  const [mpesaPhone, setMpesaPhone] = useState('');

  useEffect(() => {
    walletApi.getBundles().then((res) => setBundles(res.data || [])).catch(() => {});
  }, []);

  useEffect(() => {
    if (!showCustom) return;
    const bundle = bundles.find((b) => b.artifact_type === customType);
    if (bundle) {
      const unitPrice = bundle.price_usd / bundle.quantity;
      setCustomUsd(unitPrice * customQty);
    } else {
      const unitPrice = ARTIFACT_UNIT_PRICES[customType] || 0;
      setCustomUsd(unitPrice * customQty);
    }
  }, [customType, customQty, bundles, showCustom]);

  const handleCardPurchase = async (type: string, qty: number, bundleId?: string) => {
    setIsPurchasing(true);
    setError('');
    try {
      const opts = bundleId ? { bundle: bundleId } : {};
      const res = await walletApi.initializePurchase(type, qty, 'card', opts);
      const { tx_ref, public_key, amount, currency, customer_email, customer_name } = res.data;

      window.FlutterwaveCheckout({
        public_key,
        tx_ref,
        amount: amount || qty * (ARTIFACT_UNIT_PRICES[type] || 0),
        currency: currency || 'USD',
        payment_options: 'card',
        customer: {
          email: customer_email || '',
          name: customer_name || '',
        },
        callback: async (response) => {
          if (response.status === 'successful' || response.status === 'completed') {
            try {
              const confirmRes = await walletApi.confirmPurchase(tx_ref, response.transaction_id);
              setSuccess(`Purchased ${confirmRes.data.transaction.quantity} ${confirmRes.data.transaction.artifact_type}(s)!`);
              refetch();
            } catch {
              setError('Payment verified but confirmation failed. Contact support.');
            }
          }
        },
        onclose: () => {
          setIsPurchasing(false);
        },
        customizations: {
          title: 'BuddyUp',
          description: 'Purchase Artifacts',
          logo: 'https://buddyup.app/logo.png',
        },
      });
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Purchase initialization failed.');
      setIsPurchasing(false);
    }
  };

  const handleMpesaPurchase = async (type: string, qty: number, bundleId?: string) => {
    if (!mpesaPhone.trim()) {
      setError('Please enter your M-Pesa phone number.');
      return;
    }
    setIsPurchasing(true);
    setError('');
    try {
      const opts = bundleId ? { bundle: bundleId, mpesa_phone: mpesaPhone } : { mpesa_phone: mpesaPhone };
      const res = await walletApi.initializePurchase(type, qty, 'mpesa', opts);
      setPendingTxRef(res.data.tx_ref);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'M-Pesa payment initiation failed.');
      setIsPurchasing(false);
    }
  };

  const confirmMpesaPayment = async () => {
    if (!pendingTxRef) return;
    setIsConfirming(true);
    setError('');
    try {
      const res = await walletApi.confirmPurchase(pendingTxRef, '');
      setSuccess(`Purchased ${res.data.transaction.quantity} ${res.data.transaction.artifact_type}(s)!`);
      refetch();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Payment confirmation failed. Check your M-Pesa and try again.');
    } finally {
      setIsConfirming(false);
      setPendingTxRef(null);
    }
  };

  if (success) {
    return (
      <Card className="p-8 text-center">
        <span className="text-5xl">🎉</span>
        <h3 className="font-heading text-lg font-semibold mt-4">Payment Confirmed</h3>
        <p className="text-buddy-text-secondary text-sm mt-1">{success}</p>
        <Button variant="outline" className="mt-4" onClick={() => setSuccess('')}>Buy More</Button>
      </Card>
    );
  }

  if (pendingTxRef) {
    return (
      <Card className="p-8 text-center space-y-4">
        <Smartphone size={48} className="mx-auto text-buddy-green" />
        <h3 className="font-heading text-lg font-semibold">Check Your Phone</h3>
        <p className="text-buddy-text-secondary text-sm">
          An M-Pesa payment prompt has been sent to <strong>{mpesaPhone}</strong>.
          Enter your PIN to complete the payment.
        </p>
        <Button className="w-full" size="lg" onClick={confirmMpesaPayment} isLoading={isConfirming}>
          I've Paid — Confirm
        </Button>
        <Button variant="ghost" size="sm" onClick={() => { setPendingTxRef(null); setIsPurchasing(false); }}>Cancel</Button>
        {error && <p className="text-xs text-buddy-red">{error}</p>}
      </Card>
    );
  }

  const handlePurchase = (type: string, qty: number, bundleId?: string) => {
    if (method === 'card') handleCardPurchase(type, qty, bundleId);
    else handleMpesaPurchase(type, qty, bundleId);
  };

  return (
    <div className="space-y-4">
      <h3 className="font-heading font-semibold">Artifact Bundles</h3>
      <div className="space-y-2">
        {bundles.map((b) => (
          <button key={b.id} onClick={() => { setSelected(b.id); setShowCustom(false); }}
            className={`w-full p-4 rounded-xl border-2 text-left transition-colors flex items-center gap-3 ${
              selected === b.id ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
            }`}>
            <ArtifactIcon artifact={b.artifact_type} size={28} />
            <div className="flex-1">
              <p className="font-medium text-sm">{b.quantity} {b.artifact_label}s</p>
              <p className="text-xs text-buddy-text-secondary">${b.price_usd.toFixed(2)} USD</p>
            </div>
            {b.savings > 0 && (
              <Badge variant="green" label={`Save $${b.savings.toFixed(2)}`} size="sm" />
            )}
          </button>
        ))}
      </div>

      <button onClick={() => setShowCustom(!showCustom)}
        className="w-full p-3 rounded-xl border-2 border-dashed border-buddy-surface hover:border-buddy-green/50 text-sm text-buddy-text-secondary hover:text-buddy-green transition-colors flex items-center justify-center gap-2">
        {showCustom ? <Minus size={16} /> : <Plus size={16} />}
        {showCustom ? 'Hide Custom Purchase' : 'Custom Quantity'}
      </button>

      {showCustom && (
        <Card className="p-4 space-y-3">
          <div>
            <label className="text-xs font-medium text-buddy-text-secondary mb-1 block">Artifact Type</label>
            <div className="flex gap-1.5 flex-wrap">
              {ALL_ARTIFACTS.map((a) => (
                <button key={a} onClick={() => setCustomType(a)}
                  className={`p-2 rounded-lg border text-xs transition-colors ${
                    customType === a ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface'
                  }`}>
                  <ArtifactIcon artifact={a} size={20} />
                </button>
              ))}
            </div>
          </div>
          <div className="flex items-center gap-3">
            <Input label="Quantity" type="number" min={1} max={100000} value={customQty}
              onChange={(e) => setCustomQty(parseInt(e.target.value) || 1)} />
            <div className="text-right flex-shrink-0">
              {customUsd !== null ? (
                <>
                  <p className="font-display font-bold text-buddy-green">${customUsd.toFixed(2)}</p>
                  <p className="text-[10px] text-buddy-text-secondary">${(customUsd / customQty).toFixed(2)} each</p>
                </>
              ) : (
                <p className="text-xs text-buddy-text-secondary">--</p>
              )}
            </div>
          </div>
          <Button size="sm" onClick={() => handlePurchase(customType, customQty)}
            isLoading={isPurchasing}>Purchase {customQty} {customType}</Button>
        </Card>
      )}

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Payment Method</label>
        <div className="grid grid-cols-2 gap-2">
          {[
            { value: 'card', label: 'Card', icon: CreditCard },
            { value: 'mpesa', label: 'M-Pesa', icon: Smartphone },
          ].map(({ value, label, icon: Icon }) => (
            <button key={value} onClick={() => setMethod(value)}
              className={`flex items-center gap-2 p-3 rounded-xl border transition-colors ${method === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
              <Icon size={16} /> <span className="text-sm">{label}</span>
            </button>
          ))}
        </div>
      </div>

      {method === 'mpesa' && (
        <Input label="M-Pesa Phone Number" value={mpesaPhone} onChange={(e) => setMpesaPhone(e.target.value)} placeholder="+254 712 345 678" />
      )}

      {method === 'card' && (
        <Card className="p-4 bg-buddy-green/5 border border-buddy-green/20 rounded-xl">
          <p className="text-sm text-buddy-text-secondary text-center">
            You'll be redirected to Flutterwave's secure checkout to complete your card payment.
          </p>
        </Card>
      )}

      {selected && !showCustom && (
        <Button className="w-full" size="lg" onClick={() => {
          const bundle = bundles.find((b) => b.id === selected);
          if (bundle) handlePurchase(bundle.artifact_type, bundle.quantity, selected);
        }} isLoading={isPurchasing}>
          Purchase Tokens
        </Button>
      )}

      {error && <p className="text-xs text-buddy-red text-center">{error}</p>}
    </div>
  );
}

function SendTab({ refetch }: { refetch: () => void }) {
  const [mode, setMode] = useState<'tip' | 'gift'>('tip');
  const [username, setUsername] = useState('');
  const [searchResults, setSearchResults] = useState<Profile[]>([]);
  const [showSearch, setShowSearch] = useState(false);
  const [selectedUser, setSelectedUser] = useState<Profile | null>(null);
  const [searching, setSearching] = useState(false);
  const [searchedTerm, setSearchedTerm] = useState('');
  const searchTimer = useRef<ReturnType<typeof setTimeout>>();
  const searchRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);
  const [highlightIdx, setHighlightIdx] = useState(-1);
  const [artifactType, setArtifactType] = useState('dumbbell');
  const [quantity, setQuantity] = useState(1);
  const [message, setMessage] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const handleSearch = useCallback((q: string) => {
    setUsername(q);
    setSelectedUser(null);
    setHighlightIdx(-1);
    if (searchTimer.current) clearTimeout(searchTimer.current);
    if (!q.trim()) { setSearchResults([]); setShowSearch(false); setSearchedTerm(''); return; }
    setSearching(true);
    setSearchedTerm(q.trim());
    searchTimer.current = setTimeout(async () => {
      try {
        const res = await profilesApi.searchProfiles({ q: q.trim(), limit: 10 });
        setSearchResults(res.data || []);
        setShowSearch(true);
      } catch { setSearchResults([]); }
      setSearching(false);
    }, 300);
  }, []);

  useEffect(() => {
    const h = (e: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(e.target as Node)) setShowSearch(false);
    };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, []);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (!showSearch || searchResults.length === 0) return;
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setHighlightIdx((prev) => Math.min(prev + 1, searchResults.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setHighlightIdx((prev) => Math.max(prev - 1, 0));
    } else if (e.key === 'Enter' && highlightIdx >= 0) {
      e.preventDefault();
      const p = searchResults[highlightIdx];
      setSelectedUser(p);
      setUsername(p.username);
      setShowSearch(false);
      setHighlightIdx(-1);
    } else if (e.key === 'Escape') {
      setShowSearch(false);
      setHighlightIdx(-1);
    }
  };

  const handleSend = async () => {
    const target = selectedUser?.username || username.trim();
    if (!target) return;
    setIsSending(true);
    setError('');
    try {
      if (mode === 'tip') {
        await walletApi.tip(target, artifactType, quantity, message);
        setSuccess(`Tipped @${target} ${quantity} ${artifactType}!`);
      } else {
        await walletApi.gift(target, artifactType, quantity, message);
        setSuccess(`Gifted @${target} ${quantity} ${artifactType}!`);
      }
      refetch();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Transaction failed.');
    } finally {
      setIsSending(false);
    }
  };

  if (success) {
    return (
      <Card className="p-8 text-center">
        <span className="text-5xl">{mode === 'tip' ? '💝' : '🎁'}</span>
        <h3 className="font-heading text-lg font-semibold mt-4">{mode === 'tip' ? 'Tip Sent!' : 'Gift Sent!'}</h3>
        <p className="text-buddy-text-secondary text-sm mt-1">{success}</p>
        <Button variant="outline" className="mt-4" onClick={() => { setSuccess(''); setSelectedUser(null); setUsername(''); }}>Send Another</Button>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex rounded-xl bg-buddy-surface p-1">
        {[
          { value: 'tip' as const, label: 'Tip Creator' },
          { value: 'gift' as const, label: 'Gift to Friend' },
        ].map(({ value, label }) => (
          <button key={value} onClick={() => setMode(value)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
              mode === value ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}>{label}</button>
        ))}
      </div>

      <div ref={searchRef} className="relative">
        <div className="relative">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
          <input ref={searchInputRef} value={selectedUser ? `@${selectedUser.username}` : username}
            onChange={(e) => handleSearch(e.target.value.replace('@', ''))}
            onKeyDown={handleKeyDown}
            placeholder="@username"
            className="w-full bg-buddy-surface rounded-xl pl-9 pr-10 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
          {selectedUser && (
            <button onClick={() => { setSelectedUser(null); setUsername(''); }} className="absolute right-3 top-1/2 -translate-y-1/2">
              <X size={14} className="text-buddy-text-secondary" />
            </button>
          )}
          {searching && (
            <div className="absolute right-3 top-1/2 -translate-y-1/2">
              <div className="w-3.5 h-3.5 border-2 border-buddy-green border-t-transparent rounded-full animate-spin" />
            </div>
          )}
        </div>
        {showSearch && searchResults.length > 0 && (
          <Card className="absolute top-full left-0 right-0 mt-1 z-20 p-1 shadow-xl">
            {searchResults.map((p, i) => (
              <button key={p.user_id} onClick={() => { setSelectedUser(p); setUsername(p.username); setShowSearch(false); setHighlightIdx(-1); }}
                className={`w-full flex items-center gap-2 p-2 rounded-lg text-left transition-colors ${i === highlightIdx ? 'bg-buddy-surface' : 'hover:bg-buddy-surface'}`}>
                <Avatar src={p.avatar_url} alt={p.display_name} size="sm" />
                <div>
                  <p className="text-sm font-medium">{p.display_name}</p>
                  <p className="text-xs text-buddy-text-secondary">@{p.username}</p>
                </div>
              </button>
            ))}
          </Card>
        )}
        {showSearch && searchResults.length === 0 && !searching && searchedTerm && (
          <Card className="absolute top-full left-0 right-0 mt-1 z-20 p-3 shadow-xl text-center text-sm text-buddy-text-secondary">
            No users found matching "{searchedTerm}"
          </Card>
        )}
      </div>

      {selectedUser && (
        <div className="flex items-center gap-2 bg-buddy-surface rounded-xl px-3 py-2">
          <Avatar src={selectedUser.avatar_url} alt={selectedUser.display_name} size="sm" />
          <span className="text-sm font-medium flex-1">{selectedUser.display_name}</span>
          <span className="text-xs text-buddy-text-secondary">@{selectedUser.username}</span>
          <button onClick={() => { setSelectedUser(null); setUsername(''); }} className="p-1"><X size={14} className="text-buddy-text-secondary" /></button>
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Artifact</label>
        <div className="flex gap-1.5 flex-wrap">
          {ALL_ARTIFACTS.map((a) => (
            <button key={a} onClick={() => setArtifactType(a)}
              className={`flex-1 min-w-[40px] p-2.5 rounded-xl border text-center transition-colors ${
                artifactType === a ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
              }`}>
              <ArtifactIcon artifact={a} size={20} />
            </button>
          ))}
        </div>
      </div>

      <Input label="Quantity" type="number" min={1} max={100} value={quantity}
        onChange={(e) => setQuantity(parseInt(e.target.value) || 1)} />

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Message (optional)</label>
        <textarea value={message} onChange={(e) => setMessage(e.target.value)}
          placeholder="You crushed it! 💪"
          className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-20" />
      </div>

      {error && <p className="text-xs text-buddy-red">{error}</p>}

      <Button className="w-full" size="lg" onClick={handleSend} isLoading={isSending}
        disabled={!(selectedUser || username.trim())}>
        {mode === 'tip' ? 'Send Tip' : 'Send Gift'}
      </Button>
    </div>
  );
}

function HistoryTab() {
  const [transactions, setTransactions] = useState<ArtifactTransaction[]>([]);
  const [filter, setFilter] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [nextCursor, setNextCursor] = useState<string | null>(null);

  const fetchTx = useCallback(async (cursor?: string) => {
    try {
      const res = await walletApi.getTransactions({ type: filter || undefined, cursor });
      return res;
    } catch { return null; }
  }, [filter]);

  useEffect(() => {
    setIsLoading(true);
    setNextCursor(null);
    fetchTx().then((res) => {
      if (res) {
        setTransactions(res.data || []);
        const url = res.pagination?.next;
        setNextCursor(url ? extractCursor(url) : null);
      }
    }).catch(() => {}).finally(() => setIsLoading(false));
  }, [fetchTx]);

  const loadMore = async () => {
    if (!nextCursor || loadingMore) return;
    setLoadingMore(true);
    const res = await fetchTx(nextCursor);
    if (res) {
      setTransactions((prev) => [...prev, ...(res.data || [])]);
      const url = res.pagination?.next;
      setNextCursor(url ? extractCursor(url) : null);
    }
    setLoadingMore(false);
  };

  const types = ['', 'purchase', 'tip_sent', 'tip_received', 'live_fee', 'gym_subscription', 'session_fee', 'marketplace', 'creator_transfer', 'withdrawal', 'gift_sent', 'gift_received', 'platform_cut'];

  return (
    <div className="space-y-4">
      <div className="sticky top-0 z-10 bg-buddy-black pb-2 -mx-4 px-4 border-b border-buddy-surface mb-2">
        <div className="flex gap-2 overflow-x-auto scrollbar-hide">
          {types.map((t) => (
            <button key={t} onClick={() => setFilter(t)}
              className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors flex-shrink-0 ${
                filter === t ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}>{t.replace(/_/g, ' ') || 'All'}</button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <Card key={i} className="p-3 animate-pulse"><div className="h-10 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : transactions.length === 0 ? (
        <div className="text-center py-12">
          <Clock size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary">No transactions yet</p>
        </div>
      ) : (
        <div className="space-y-1">
          {transactions.map((tx) => (
            <Card key={tx.id} className="p-3 flex items-center gap-3 w-full">
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${
                tx.direction === 'credit' ? 'bg-buddy-green/10' : 'bg-buddy-red/10'
              }`}>
                {tx.direction === 'credit' ? <ArrowDownLeft size={16} className="text-buddy-green" /> : <ArrowUpRight size={16} className="text-buddy-red" />}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{tx.description || `${tx.direction === 'credit' ? 'Received' : 'Sent'} ${tx.artifact_type}`}</p>
                <p className="text-xs text-buddy-text-secondary">
                  {tx.transaction_type.replace(/_/g, ' ')} · {new Date(tx.created_at).toLocaleDateString()}
                  {tx.status === 'pending' && <Badge variant="orange" label="Pending" size="sm" className="ml-1" />}
                </p>
              </div>
              <div className="text-right flex-shrink-0">
                <p className={`font-mono text-sm font-bold ${tx.direction === 'credit' ? 'text-buddy-green' : 'text-buddy-red'}`}>
                  {tx.direction === 'credit' ? '+' : '-'}{tx.quantity}
                </p>
                {tx.fiat_amount && (
                  <p className="text-xs text-buddy-text-secondary">{tx.fiat_currency} {tx.fiat_amount}</p>
                )}
              </div>
            </Card>
          ))}
          {nextCursor && (
            <div className="flex justify-center mt-3">
              <Button variant="outline" className="w-fit" onClick={loadMore} isLoading={loadingMore}>
                Load More
              </Button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function WithdrawTab({ balance, refetch }: { balance: BalanceResponse | null; refetch: () => void }) {
  const [artifactType, setArtifactType] = useState('dumbbell');
  const [quantity, setQuantity] = useState(10);
  const [method, setMethod] = useState('mpesa');
  const [phone, setPhone] = useState('');
  const [source, setSource] = useState<'regular' | 'creator'>('regular');

  const [banks, setBanks] = useState<{ code: string; name: string }[]>([]);
  const [loadingBanks, setLoadingBanks] = useState(false);
  const [bankCode, setBankCode] = useState('');
  const [bankAccount, setBankAccount] = useState('');
  const [accountName, setAccountName] = useState('');
  const [resolving, setResolving] = useState(false);
  const [resolved, setResolved] = useState(false);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const sourceList = source === 'creator' ? (balance?.creator_balance || []) : (balance?.regular_balance || []);
  const balanceItem = sourceList.find((b) => b.artifact_type === artifactType);
  const available = balanceItem?.quantity || 0;
  const fiatPerUnit = balanceItem ? balanceItem.usd_value / (balanceItem.quantity || 1) : 0;
  const fiatEquivalent = quantity * fiatPerUnit;

  useEffect(() => {
    if (method === 'bank_transfer' && banks.length === 0) {
      setLoadingBanks(true);
      walletApi.getBanks().then((res) => setBanks(res.data || [])).catch(() => {}).finally(() => setLoadingBanks(false));
    }
  }, [method, banks.length]);

  const handleResolveAccount = async () => {
    if (!bankCode || !bankAccount.trim()) { setError('Select a bank and enter account number.'); return; }
    setResolving(true);
    setError('');
    try {
      const res = await walletApi.resolveBank(bankAccount.trim(), bankCode);
      setAccountName(res.data.account_name);
      setResolved(true);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Could not resolve account name.');
    } finally {
      setResolving(false);
    }
  };

  const handleWithdraw = async () => {
    if (quantity > available) { setError(`Insufficient ${artifactType} balance. You have ${available}.`); return; }
    if (method === 'mpesa' && !phone.trim()) { setError('Phone number required for M-Pesa.'); return; }
    if (method === 'bank_transfer' && (!bankAccount.trim() || !bankCode || !accountName)) { setError('Complete bank account details first.'); return; }
    setIsSubmitting(true);
    setError('');
    try {
      const opts = method === 'mpesa'
        ? { phone_number: phone }
        : { bank_account: bankAccount, bank_code: bankCode, account_name: accountName };
      await walletApi.withdraw(artifactType, quantity, method, { ...opts, source });
      setSuccess(`Withdrawal of ${quantity} ${artifactType}(s) processed!`);
      refetch();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Withdrawal failed.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (success) {
    return (
      <Card className="p-8 text-center">
        <DollarSign size={48} className="mx-auto text-buddy-green mb-4" />
        <h3 className="font-heading text-lg font-semibold mt-4">Withdrawal Complete</h3>
        <p className="text-buddy-text-secondary text-sm mt-1">{success}</p>
        <Button variant="outline" className="mt-4" onClick={() => { setSuccess(''); setResolved(false); setAccountName(''); }}>New Withdrawal</Button>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl p-4 text-sm text-buddy-text-secondary">
        <p>Minimum withdrawal: $10.00 equivalent. ID verification required.</p>
        <p className="text-xs mt-1">Platform fee: 2.5% + processor fee.</p>
      </div>

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Withdraw From</label>
        <div className="grid grid-cols-2 gap-2">
          <button onClick={() => { setSource('regular'); setArtifactType('dumbbell'); }}
            className={`p-3 rounded-xl border text-sm transition-colors text-left ${
              source === 'regular' ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
            }`}>
            <p className="font-semibold">Regular Wallet</p>
            <p className="text-[10px] text-buddy-text-secondary mt-0.5">${balance?.regular_total_fiat.toFixed(2) || '0.00'}</p>
          </button>
          <button onClick={() => { setSource('creator'); setArtifactType('dumbbell'); }}
            disabled={(balance?.creator_balance || []).every((i) => i.quantity === 0)}
            className={`p-3 rounded-xl border text-sm transition-colors text-left ${
              source === 'creator' ? 'border-buddy-gold bg-buddy-gold/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
            } disabled:opacity-50 disabled:cursor-not-allowed`}>
            <p className="font-semibold">Creator Wallet</p>
            <p className="text-[10px] text-buddy-text-secondary mt-0.5">${balance?.creator_total_fiat.toFixed(2) || '0.00'}</p>
          </button>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Select Artifact</label>
        <div className="flex gap-1.5 flex-wrap">
          {ALL_ARTIFACTS.map((a) => {
            const bal = sourceList.find((b) => b.artifact_type === a);
            return (
              <button key={a} onClick={() => setArtifactType(a)} disabled={!bal || bal.quantity === 0}
                className={`flex items-center gap-1 px-3 py-2 rounded-xl border text-sm transition-colors disabled:opacity-40 disabled:cursor-not-allowed ${
                  artifactType === a ? (source === 'creator' ? 'border-buddy-gold bg-buddy-gold/5' : 'border-buddy-green bg-buddy-green/5') : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                }`}>
                <ArtifactIcon artifact={a} size={18} /> {a}
                {bal && <span className="text-[10px] text-buddy-text-secondary ml-0.5">({bal.quantity})</span>}
              </button>
            );
          })}
        </div>
      </div>

      <div className="flex items-center justify-between text-sm">
        <span className="text-buddy-text-secondary">Available Balance:</span>
        <span className="font-bold">{available} {artifactType}</span>
      </div>

      <Input label="Quantity" type="number" min={1} max={available} value={quantity}
        onChange={(e) => setQuantity(Math.min(parseInt(e.target.value) || 1, available))} />

      {fiatEquivalent > 0 && (
        <div className="text-right">
          <p className="text-xs text-buddy-text-secondary">Equivalent Value</p>
          <p className="font-display font-bold text-buddy-green">${fiatEquivalent.toFixed(2)} USD</p>
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Method</label>
        <div className="space-y-2">
          {[
            { value: 'mpesa', label: 'M-Pesa', icon: Smartphone },
            { value: 'bank_transfer', label: 'Bank Transfer', icon: Building2 },
          ].map(({ value, label, icon: Icon }) => (
            <button key={value} onClick={() => { setMethod(value); setResolved(false); setAccountName(''); }}
              className={`w-full p-3 rounded-xl border text-left text-sm flex items-center gap-3 transition-colors ${
                method === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
              }`}>
              <Icon size={18} /> {label}
            </button>
          ))}
        </div>
      </div>

      {method === 'mpesa' && (
        <Input label="M-Pesa Phone Number" value={phone} onChange={(e) => setPhone(e.target.value)}
          placeholder="+254 712 345 678" />
      )}

      {method === 'bank_transfer' && (
        <div className="space-y-3">
          <div>
            <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Select Bank</label>
            <select value={bankCode} onChange={(e) => { setBankCode(e.target.value); setResolved(false); setAccountName(''); }}
              className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
              <option value="">{loadingBanks ? 'Loading banks...' : 'Choose a bank'}</option>
              {banks.map((b) => (
                <option key={b.code} value={b.code}>{b.name}</option>
              ))}
            </select>
          </div>

          <Input label="Account Number" value={bankAccount} onChange={(e) => { setBankAccount(e.target.value); setResolved(false); setAccountName(''); }}
            placeholder="e.g. 1234567890" maxLength={10} />

          {!resolved ? (
            <Button variant="outline" className="w-full" onClick={handleResolveAccount} isLoading={resolving}
              disabled={!bankCode || !bankAccount.trim()}>
              Verify Account Name
            </Button>
          ) : (
            <Card className="p-3 bg-buddy-green/5 border border-buddy-green/20">
              <p className="text-xs text-buddy-text-secondary">Account Name</p>
              <p className="font-medium">{accountName}</p>
            </Card>
          )}
        </div>
      )}

      {error && <p className="text-xs text-buddy-red">{error}</p>}

      <Button className="w-full" size="lg" onClick={handleWithdraw} isLoading={isSubmitting}
        disabled={quantity > available || quantity < 1 || (method === 'bank_transfer' && !resolved)}>
        {method === 'bank_transfer' ? 'Withdraw to Bank' : 'Withdraw to M-Pesa'}
      </Button>
    </div>
  );
}

function extractCursor(url: string): string | null {
  try {
    const u = new URL(url);
    return u.searchParams.get('cursor');
  } catch {
    return null;
  }
}

function TransferModal({ artifact, available, onClose, onTransferred }: { artifact: string; available: number; onClose: () => void; onTransferred: () => void; }) {
  const [quantity, setQuantity] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleTransfer = async () => {
    if (quantity <= 0 || quantity > available) { setError(`Enter 1-${available}.`); return; }
    setIsSubmitting(true);
    setError('');
    try {
      await walletApi.transferFromCreator(artifact, quantity);
      onTransferred();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Transfer failed.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4">
      <Card className="p-6 max-w-sm w-full space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-heading text-lg font-semibold flex items-center gap-2"><ArrowRightLeft size={18} className="text-buddy-gold" /> Transfer to Wallet</h3>
          <button onClick={onClose} className="p-1 hover:bg-buddy-surface-raised rounded-lg"><X size={18} /></button>
        </div>
        <p className="text-xs text-buddy-text-secondary">Move {artifact} tokens from your creator wallet to your regular wallet so you can withdraw them.</p>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Quantity (available: {available})</label>
          <Input type="number" min={1} max={available} value={quantity} onChange={(e) => setQuantity(Math.max(1, Math.min(available, Number(e.target.value) || 1)))} />
        </div>
        {error && <p className="text-xs text-buddy-red">{error}</p>}
        <div className="flex gap-2">
          <Button variant="ghost" className="flex-1" onClick={onClose}>Cancel</Button>
          <Button className="flex-1" isLoading={isSubmitting} onClick={handleTransfer}>Transfer</Button>
        </div>
      </Card>
    </div>
  );
}

function CreatorNameEditModal({ current, onClose, onSaved }: { current: string; onClose: () => void; onSaved: () => void; }) {
  const [name, setName] = useState(current);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleSave = async () => {
    const trimmed = name.trim();
    if (trimmed && (trimmed.length < 3 || trimmed.length > 50)) {
      setError('Display name must be 3-50 characters.');
      return;
    }
    setIsSubmitting(true);
    setError('');
    try {
      await walletApi.updateCreatorProfile({ creator_display_name: trimmed });
      onSaved();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Save failed.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4">
      <Card className="p-6 max-w-sm w-full space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-heading text-lg font-semibold">Creator Display Name</h3>
          <button onClick={onClose} className="p-1 hover:bg-buddy-surface-raised rounded-lg"><X size={18} /></button>
        </div>
        <p className="text-xs text-buddy-text-secondary">Shown to buyers alongside your marketplace services. Leave empty to clear.</p>
        <div>
          <Input placeholder="e.g. Coach Imani" value={name} onChange={(e) => setName(e.target.value)} maxLength={50} />
        </div>
        {error && <p className="text-xs text-buddy-red">{error}</p>}
        <div className="flex gap-2">
          <Button variant="ghost" className="flex-1" onClick={onClose}>Cancel</Button>
          <Button className="flex-1" isLoading={isSubmitting} onClick={handleSave}>Save</Button>
        </div>
      </Card>
    </div>
  );
}
