import { useState, useEffect, useCallback } from 'react';
import { ShoppingBag, Send, Clock, ArrowDownLeft, ArrowUpRight, DollarSign, CreditCard, Smartphone } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { Badge } from '@/components/ui/Badge';
import { walletApi } from '@/api/wallet';
import type { BalanceItem, BalanceResponse, BundleInfo } from '@/api/wallet';
import type { ArtifactTransaction } from '@/types';

type WalletTab = 'overview' | 'buy' | 'send' | 'history' | 'withdraw';

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
    <div className="max-w-lg mx-auto p-4">
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
          {activeTab === 'overview' && <OverviewTab balance={balance} refetch={fetchBalance} />}
          {activeTab === 'buy' && <BuyTab refetch={fetchBalance} />}
          {activeTab === 'send' && <SendTab refetch={fetchBalance} />}
          {activeTab === 'history' && <HistoryTab />}
          {activeTab === 'withdraw' && <WithdrawTab refetch={fetchBalance} />}
        </>
      )}
    </div>
  );
}

function OverviewTab({ balance, refetch }: { balance: BalanceResponse | null; refetch: () => void }) {
  return (
    <div className="space-y-4">
      <Card className="p-6 bg-gradient-to-br from-buddy-green/20 to-buddy-surface">
        <p className="text-sm text-buddy-text-secondary">Total Balance</p>
        <p className="font-display text-3xl font-extrabold mt-1">{balance?.total_label || 'KES 0.00'}</p>
      </Card>

      <div className="grid grid-cols-4 gap-2">
        {(balance?.balance || []).map((item) => (
          <Card key={item.artifact_type}
            className={`p-3 text-center ${item.quantity > 0 ? 'bg-buddy-surface-raised' : 'opacity-50'}`}>
            <ArtifactIcon artifact={item.artifact_type} size={24} quantity={item.quantity} />
            <p className="font-mono text-xs mt-1 font-bold">{item.quantity}</p>
            <p className="text-[10px] text-buddy-text-secondary">${item.usd_value.toFixed(2)}</p>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-3">
        <Card className="p-4 text-center hover:bg-buddy-surface-raised cursor-pointer transition-colors">
          <CreditCard size={24} className="mx-auto text-buddy-green mb-2" />
          <p className="font-medium text-sm">Buy Tokens</p>
        </Card>
        <Card className="p-4 text-center hover:bg-buddy-surface-raised cursor-pointer transition-colors">
          <Send size={24} className="mx-auto text-buddy-electric mb-2" />
          <p className="font-medium text-sm">Send / Tip</p>
        </Card>
      </div>
    </div>
  );
}

function BuyTab({ refetch }: { refetch: () => void }) {
  const [bundles, setBundles] = useState<BundleInfo[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [method, setMethod] = useState('stripe');
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [success, setSuccess] = useState('');

  useEffect(() => {
    walletApi.getBundles().then((res) => setBundles(res.data || [])).catch(() => {});
  }, []);

  const handlePurchase = async () => {
    if (!selected) return;
    const bundle = bundles.find((b) => b.id === selected);
    if (!bundle) return;
    setIsPurchasing(true);
    try {
      await walletApi.purchase(bundle.artifact_type, bundle.quantity, method, selected);
      setSuccess(`Purchased ${bundle.quantity} ${bundle.artifact_label}(s)!`);
      refetch();
    } catch {} finally {
      setIsPurchasing(false);
    }
  };

  if (success) {
    return (
      <Card className="p-8 text-center">
        <span className="text-5xl">🎉</span>
        <h3 className="font-heading text-lg font-semibold mt-4">Payment Confirmed</h3>
        <p className="text-buddy-text-secondary text-sm mt-1">{success}</p>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <h3 className="font-heading font-semibold">Artifact Bundles</h3>
      <div className="space-y-2">
        {bundles.map((b) => (
          <button key={b.id} onClick={() => setSelected(b.id)}
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

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Payment Method</label>
        <div className="grid grid-cols-2 gap-2">
          {[
            { value: 'stripe', label: 'Card', icon: CreditCard },
            { value: 'mpesa', label: 'M-Pesa', icon: Smartphone },
          ].map(({ value, label, icon: Icon }) => (
            <button key={value} onClick={() => setMethod(value)}
              className={`flex items-center gap-2 p-3 rounded-xl border transition-colors ${method === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
              <Icon size={16} /> <span className="text-sm">{label}</span>
            </button>
          ))}
        </div>
      </div>

      <Button className="w-full" size="lg" onClick={handlePurchase} isLoading={isPurchasing} disabled={!selected}>
        Purchase Tokens
      </Button>
    </div>
  );
}

function SendTab({ refetch }: { refetch: () => void }) {
  const [mode, setMode] = useState<'tip' | 'gift'>('tip');
  const [username, setUsername] = useState('');
  const [artifactType, setArtifactType] = useState('dumbbell');
  const [quantity, setQuantity] = useState(1);
  const [message, setMessage] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [success, setSuccess] = useState('');

  const artifacts = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint'];

  const handleSend = async () => {
    if (!username.trim()) return;
    setIsSending(true);
    try {
      if (mode === 'tip') {
        await walletApi.tip(username.trim(), artifactType, quantity, message);
        setSuccess(`Tipped @${username.trim()} ${quantity} ${artifactType}!`);
      } else {
        await walletApi.gift(username.trim(), artifactType, quantity, message);
        setSuccess(`Gifted @${username.trim()} ${quantity} ${artifactType}!`);
      }
      refetch();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setSuccess(data?.message || 'Transaction failed.');
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
        <Button variant="outline" className="mt-4" onClick={() => setSuccess('')}>Send Another</Button>
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

      <Input label="Username" value={username} onChange={(e) => setUsername(e.target.value)} placeholder="@fitness_fan" />

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Artifact</label>
        <div className="flex gap-2">
          {artifacts.map((a) => (
            <button key={a} onClick={() => setArtifactType(a)}
              className={`flex-1 p-3 rounded-xl border text-center transition-colors ${
                artifactType === a ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
              }`}>
              <ArtifactIcon artifact={a} size={22} />
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

      <Button className="w-full" size="lg" onClick={handleSend} isLoading={isSending} disabled={!username.trim()}>
        {mode === 'tip' ? 'Send Tip' : 'Send Gift'}
      </Button>
    </div>
  );
}

function HistoryTab() {
  const [transactions, setTransactions] = useState<ArtifactTransaction[]>([]);
  const [filter, setFilter] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    walletApi.getTransactions({ type: filter || undefined })
      .then((res) => setTransactions(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [filter]);

  const types = ['', 'purchase', 'tip_sent', 'tip_received', 'live_fee', 'gym_subscription', 'session_fee', 'withdrawal'];

  return (
    <div className="space-y-4">
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {types.map((t) => (
          <button key={t} onClick={() => setFilter(t)}
            className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors ${
              filter === t ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}>{t || 'All'}</button>
        ))}
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
            <Card key={tx.id} className="p-3 flex items-center gap-3">
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${
                tx.direction === 'credit' ? 'bg-buddy-green/10' : 'bg-buddy-red/10'
              }`}>
                {tx.direction === 'credit' ? <ArrowDownLeft size={16} className="text-buddy-green" /> : <ArrowUpRight size={16} className="text-buddy-red" />}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{tx.description}</p>
                <p className="text-xs text-buddy-text-secondary">
                  {tx.artifact_type} · {new Date(tx.created_at).toLocaleDateString()}
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
        </div>
      )}
    </div>
  );
}

function WithdrawTab({ refetch }: { refetch: () => void }) {
  const [artifactType, setArtifactType] = useState('dumbbell');
  const [quantity, setQuantity] = useState(10);
  const [method, setMethod] = useState('mpesa');
  const [phone, setPhone] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState('');

  const artifacts = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'];

  const handleWithdraw = async () => {
    setIsSubmitting(true);
    try {
      await walletApi.withdraw(artifactType, quantity, method, phone);
      setSuccess(`Withdrawal of ${quantity} ${artifactType}(s) submitted!`);
      refetch();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setSuccess(data?.message || 'Withdrawal failed.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (success) {
    return (
      <Card className="p-8 text-center">
        <span className="text-5xl">🏦</span>
        <h3 className="font-heading text-lg font-semibold mt-4">Withdrawal Requested</h3>
        <p className="text-buddy-text-secondary text-sm mt-1">{success}</p>
        <p className="text-xs text-buddy-text-secondary mt-2">Processing takes 3–5 business days.</p>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl p-4 text-sm text-buddy-text-secondary">
        <p>Minimum withdrawal: $10.00 equivalent. ID verification required.</p>
        <p className="text-xs mt-1">Platform fee: 2.5% + processor fee. Processing: 3–5 days.</p>
      </div>

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Select Artifact</label>
        <div className="flex gap-2 flex-wrap">
          {artifacts.map((a) => (
            <button key={a} onClick={() => setArtifactType(a)}
              className={`flex items-center gap-1 px-3 py-2 rounded-xl border text-sm transition-colors ${
                artifactType === a ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
              }`}>
              <ArtifactIcon artifact={a} size={18} /> {a}
            </button>
          ))}
        </div>
      </div>

      <Input label="Quantity" type="number" min={1} value={quantity} onChange={(e) => setQuantity(parseInt(e.target.value) || 1)} />

      <div>
        <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Method</label>
        <div className="space-y-2">
          {[
            { value: 'mpesa', label: 'M-Pesa', icon: '📱' },
            { value: 'bank_transfer', label: 'Bank Transfer', icon: '🏦' },
            { value: 'paypal', label: 'PayPal', icon: '💳' },
          ].map(({ value, label, icon }) => (
            <button key={value} onClick={() => setMethod(value)}
              className={`w-full p-3 rounded-xl border text-left text-sm flex items-center gap-3 transition-colors ${
                method === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
              }`}>
              <span>{icon}</span> {label}
            </button>
          ))}
        </div>
      </div>

      {method === 'mpesa' && (
        <Input label="M-Pesa Phone Number" value={phone} onChange={(e) => setPhone(e.target.value)}
          placeholder="+254 712 345 678" />
      )}

      <Button className="w-full" size="lg" onClick={handleWithdraw} isLoading={isSubmitting}>Request Withdrawal</Button>
    </div>
  );
}
