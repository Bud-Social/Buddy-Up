import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { CreatorAnalytics, DiscountAnalytics, ProductMP, Order } from '@/api/marketplace';
import { walletApi } from '@/api/wallet';
import type { BalanceResponse, BankInfo } from '@/api/wallet';
import type { ArtifactTransaction } from '@/types';
import { useToast } from '@/components/ui/Toast';
import BuddyUpCertification from './BuddyUpCertification';

type Tab = 'analytics' | 'orders' | 'services' | 'payouts' | 'shop' | 'discounts';

const TAB_STYLES: Record<Tab, { active: string; dot: string; label: string }> = {
  analytics: { active: 'bg-buddy-electric text-buddy-black shadow-lg', dot: 'bg-buddy-electric', label: 'Analytics' },
  orders: { active: 'bg-buddy-green text-buddy-black shadow-lg', dot: 'bg-buddy-green', label: 'Orders' },
  services: { active: 'bg-buddy-gold text-buddy-black shadow-lg', dot: 'bg-buddy-gold', label: 'Services' },
  payouts: { active: 'bg-purple-500 text-white shadow-lg', dot: 'bg-purple-500', label: 'Payouts' },
  shop: { active: 'bg-blue-500 text-white shadow-lg', dot: 'bg-blue-500', label: 'My Shops' },
  discounts: { active: 'bg-buddy-orange text-buddy-black shadow-lg', dot: 'bg-buddy-orange', label: 'Discounts' },
};

const TYPE_COLORS: Record<string, string> = {
  meal_plan: 'text-buddy-green border-buddy-green/30 bg-buddy-green/10',
  programme: 'text-buddy-electric border-buddy-electric/30 bg-buddy-electric/10',
  event: 'text-buddy-gold border-buddy-gold/30 bg-buddy-gold/10',
  product: 'text-buddy-orange border-buddy-orange/30 bg-buddy-orange/10',
};

const ARTIFACT_VALUES: Record<string, number> = { dumbbell: 0.10, barbell: 0.50, burpee: 1.00, squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00 };

/** Allowed forward transitions for bulk seller updates (mirrors backend). */
const SELLER_FORWARD_OK: Record<string, string[]> = {
  paid: ['processing', 'shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered', 'cancelled'],
  processing: ['shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered'],
  shipped: ['out_for_delivery', 'ready_for_pickup', 'delivered'],
  out_for_delivery: ['ready_for_pickup', 'delivered'],
  ready_for_pickup: ['delivered'],
};

function artifactUsd(artifacts: Record<string, number> | undefined): number {
  if (!artifacts) return 0;
  return Object.entries(artifacts).reduce((s, [k, v]) => s + (ARTIFACT_VALUES[k] || 0) * (v || 0), 0);
}

export default function CreatorStudio() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [tab, setTab] = useState<Tab>('analytics');

  // Analytics
  const [analytics, setAnalytics] = useState<CreatorAnalytics | null>(null);
  const [loadingAnalytics, setLoadingAnalytics] = useState(true);

  // Services
  const [services, setServices] = useState<any>(null);
  const [loadingServices, setLoadingServices] = useState(true);

  // Shops
  const [shops, setShops] = useState<any[]>([]);
  const [loadingShops, setLoadingShops] = useState(true);
  const [certifyingShop, setCertifyingShop] = useState<{ id: string; name: string } | null>(null);

  // Orders
  const [orders, setOrders] = useState<Order[]>([]);
  const [orderStatusFilter, setOrderStatusFilter] = useState<string>('');
  const [loadingOrders, setLoadingOrders] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [updatingOrderStatus, setUpdatingOrderStatus] = useState<string | null>(null);
  const [statusNote, setStatusNote] = useState('');
  const [selectedOrderIds, setSelectedOrderIds] = useState<string[]>([]);
  const [bulkUpdating, setBulkUpdating] = useState(false);

  // Payouts
  const [walletBalance, setWalletBalance] = useState<BalanceResponse | null>(null);
  const [payouts, setPayouts] = useState<ArtifactTransaction[]>([]);
  const [loadingPayouts, setLoadingPayouts] = useState(false);
  const [showPayoutModal, setShowPayoutModal] = useState(false);
  const [payoutAmount, setPayoutAmount] = useState('');
  const [payoutMethod, setPayoutMethod] = useState<'mpesa' | 'bank_transfer'>('mpesa');
  const [payoutPhone, setPayoutPhone] = useState('');
  const [payoutBankCode, setPayoutBankCode] = useState('');
  const [payoutBankAccount, setPayoutBankAccount] = useState('');
  const [payoutAccountName, setPayoutAccountName] = useState('');
  const [banks, setBanks] = useState<BankInfo[]>([]);
  const [submittingPayout, setSubmittingPayout] = useState(false);

  // Menu & Panels
  const [openMenu, setOpenMenu] = useState<string | null>(null);
  const [analyticsPanel, setAnalyticsPanel] = useState<DiscountAnalytics | null>(null);
  const [showAddServiceModal, setShowAddServiceModal] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    marketplaceApi.getCreatorAnalytics()
      .then((res) => setAnalytics(res.data))
      .catch(() => {})
      .finally(() => setLoadingAnalytics(false));
  }, []);

  useEffect(() => {
    refreshServices();
    loadShops();
  }, []);

  useEffect(() => {
    if (tab === 'orders') {
      loadOrders(orderStatusFilter);
    } else if (tab === 'payouts') {
      loadPayoutData();
    }
  }, [tab, orderStatusFilter]);

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setOpenMenu(null);
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  const hasShop = shops.length > 0;

  const handleRegisterCreator = async () => {
    try {
      await marketplaceApi.registerCreator();
      toast('success', 'You are now a creator!');
      loadShops();
      refreshServices();
    } catch (err: any) {
      toast('error', err.response?.data?.message || 'Registration failed');
      loadShops();
    }
  };

  const loadShops = () => {
    setLoadingShops(true);
    marketplaceApi.getMyShops()
      .then((res) => setShops(res.data || []))
      .catch(() => {})
      .finally(() => setLoadingShops(false));
  };

  const refreshServices = () => {
    setLoadingServices(true);
    marketplaceApi.getMyServices()
      .then((res) => setServices(res.data))
      .catch(() => {})
      .finally(() => setLoadingServices(false));
  };

  const loadOrders = (status?: string) => {
    setLoadingOrders(true);
    marketplaceApi.getSellerOrders(status || undefined)
      .then((res) => setOrders(res.data || []))
      .catch(() => {})
      .finally(() => {
        setLoadingOrders(false);
        setSelectedOrderIds([]);
      });
  };

  const exportOrdersCsv = () => {
    if (orders.length === 0) return;
    const esc = (v: unknown) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const rows = [['order_number', 'date', 'status', 'items', 'total_usd', 'tracking_number', 'carrier']];
    for (const o of orders) {
      rows.push([
        o.order_number,
        new Date(o.created_at).toISOString(),
        o.status,
        o.items.map((it) => `${it.title} x${it.quantity}`).join('; '),
        String(o.total_usd ?? ''),
        o.fulfillment?.tracking_number || '',
        o.fulfillment?.carrier || '',
      ]);
    }
    const csv = rows.map((r) => r.map(esc).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `buddyup-orders-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    a.remove();
  };

  const handleBulkStatus = async (newStatus: string) => {
    const targets = selectedOrderIds.filter((id) => {
      const order = orders.find((o) => o.id === id);
      return order && SELLER_FORWARD_OK[order.status]?.includes(newStatus);
    });
    if (targets.length === 0) {
      toast('error', 'No selected orders can move to that status');
      return;
    }
    setBulkUpdating(true);
    let ok = 0;
    for (const id of targets) {
      try {
        await marketplaceApi.updateOrderStatus(id, newStatus, '');
        ok += 1;
      } catch { /* keep going */ }
    }
    setBulkUpdating(false);
    setSelectedOrderIds([]);
    toast(ok === targets.length ? 'success' : 'error', `Updated ${ok}/${targets.length} orders`);
    loadOrders(orderStatusFilter);
  };

  const loadPayoutData = async () => {
    setLoadingPayouts(true);
    try {
      const [balRes, histRes, banksRes] = await Promise.all([
        walletApi.getBalance().catch(() => null),
        walletApi.getPayoutHistory().catch(() => null),
        walletApi.getBanks('KE').catch(() => null),
      ]);
      if (balRes?.data) setWalletBalance(balRes.data);
      if (histRes?.data) setPayouts(histRes.data);
      if (banksRes?.data) setBanks(banksRes.data);
    } finally {
      setLoadingPayouts(false);
    }
  };

  const handleUpdateOrderStatus = async (orderId: string, newStatus: string) => {
    try {
      await marketplaceApi.updateOrderStatus(orderId, newStatus, statusNote);
      toast('success', `Order status updated to ${newStatus}`);
      setSelectedOrder(null);
      setUpdatingOrderStatus(null);
      setStatusNote('');
      loadOrders(orderStatusFilter);
    } catch (err: any) {
      toast('error', err.response?.data?.message || 'Failed to update order status');
    }
  };

  const handleRequestPayout = async (e: React.FormEvent) => {
    e.preventDefault();
    const amount = parseFloat(payoutAmount);
    if (!amount || amount < 5) {
      toast('error', 'Minimum payout amount is $5.00');
      return;
    }
    setSubmittingPayout(true);
    try {
      await walletApi.requestPayout({
        amount,
        method: payoutMethod,
        phone_number: payoutMethod === 'mpesa' ? payoutPhone : undefined,
        bank_account: payoutMethod === 'bank_transfer' ? payoutBankAccount : undefined,
        bank_code: payoutMethod === 'bank_transfer' ? payoutBankCode : undefined,
        account_name: payoutMethod === 'bank_transfer' ? payoutAccountName : undefined,
      });
      toast('success', 'Payout request submitted successfully!');
      setShowPayoutModal(false);
      setPayoutAmount('');
      loadPayoutData();
    } catch (err: any) {
      toast('error', err.response?.data?.message || 'Payout request failed');
    } finally {
      setSubmittingPayout(false);
    }
  };

  const handleDuplicateService = async (type: string, item: any) => {
    try {
      if (type === 'meal_plan') {
        const copy = { ...item, title: `${item.title} (Copy)`, is_published: false };
        delete copy.id;
        delete copy.creator_data;
        delete copy.purchase_count;
        await marketplaceApi.createMealPlan(copy);
      } else if (type === 'programme') {
        const copy = { ...item, title: `${item.title} (Copy)`, is_published: false };
        delete copy.id;
        delete copy.creator_data;
        delete copy.purchase_count;
        await marketplaceApi.createProgramme(copy);
      } else if (type === 'event') {
        const copy = { ...item, title: `${item.title} (Copy)`, is_published: false };
        delete copy.id;
        delete copy.creator_data;
        delete copy.attendee_count;
        await marketplaceApi.createEvent(copy);
      } else if (type === 'product') {
        const copy = { ...item, name: `${item.name} (Copy)` };
        delete copy.id;
        delete copy.click_count;
        await marketplaceApi.createProduct(copy);
      }
      toast('success', 'Service duplicated as draft');
      refreshServices();
    } catch (err: any) {
      toast('error', 'Failed to duplicate service');
    }
  };

  const handleTogglePublish = async (type: string, id: string, currentlyPublished: boolean) => {
    try {
      if (type === 'meal_plan') {
        await marketplaceApi.updateMealPlan(id, { is_published: !currentlyPublished });
      } else if (type === 'programme') {
        await marketplaceApi.updateProgramme(id, { is_published: !currentlyPublished });
      } else if (type === 'event') {
        await marketplaceApi.updateEvent(id, { is_published: !currentlyPublished });
      } else if (type === 'product') {
        await marketplaceApi.updateProduct(id, { is_active: !currentlyPublished });
      }
      toast('success', currentlyPublished ? 'Unpublished / Archived' : 'Published live');
      refreshServices();
    } catch {
      toast('error', 'Action failed');
    }
  };

  const handleDelete = async (type: string, id: string, title: string) => {
    if (!window.confirm(`Delete "${title}"? This action cannot be undone.`)) return;
    try {
      if (type === 'meal_plan') await marketplaceApi.deleteMealPlan(id);
      else if (type === 'programme') await marketplaceApi.deleteProgramme(id);
      else if (type === 'event') await marketplaceApi.deleteEvent(id);
      else if (type === 'product') await marketplaceApi.deleteProduct(id);
      else if (type === 'discount') await marketplaceApi.deleteDiscountCode(id);
      toast('success', 'Deleted successfully');
      refreshServices();
    } catch {
      toast('error', 'Failed to delete');
    }
  };

  const handleToggleCode = async (code: any) => {
    try {
      await marketplaceApi.patchDiscountCode(code.id, { action: code.is_active && !code.is_expired ? 'suspend' : 'reactivate' });
      toast('success', code.is_active && !code.is_expired ? 'Code suspended' : 'Code reactivated');
      refreshServices();
    } catch {
      toast('error', 'Action failed');
    }
  };

  const handleShare = async (code: any) => {
    try {
      await marketplaceApi.shareDiscountCode(code.id);
      await navigator.clipboard.writeText(code.code).catch(() => {});
      toast('success', `Code ${code.code} copied to clipboard`);
      refreshServices();
    } catch {
      toast('error', 'Share failed');
    }
  };

  const loadAnalytics = async (codeId: string) => {
    try {
      const res = await marketplaceApi.getDiscountCodeAnalytics(codeId);
      setAnalyticsPanel(res.data);
    } catch {
      toast('error', 'Failed to load analytics');
    }
  };

  const renderServiceCard = (p: any, type: string, imageUrl: string, previewRoute: string, editRoute: string, meta: string, isPublished: boolean) => (
    <Card key={p.id} className="p-3 flex items-center gap-3">
      <div className="w-14 h-14 rounded-xl bg-buddy-surface-raised overflow-hidden shrink-0">
        {imageUrl && <img src={imageUrl} alt="" className="w-full h-full object-cover" />}
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-sm font-medium truncate">{p.title ?? p.name}</p>
        <div className="flex items-center gap-2 mt-1 flex-wrap">
          <Badge variant={isPublished ? 'green' : 'orange'} label={isPublished ? 'Live' : 'Draft'} size="sm" />
          <span className="text-[11px] text-buddy-text-secondary">{meta}</span>
          {p.abandoned_cart_count > 0 && <Badge variant="orange" label={`${p.abandoned_cart_count} in carts`} size="sm" />}
        </div>
      </div>
      <div className="flex items-center gap-1 shrink-0">
        <button title={isPublished ? 'Archive / Unpublish' : 'Publish'} onClick={() => handleTogglePublish(type, p.id, isPublished)} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary hover:text-buddy-green">
          {isPublished ? (
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect width="20" height="5" x="2" y="3" rx="1"/><path d="M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8"/><path d="m10 12 2 2 2-2"/></svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          )}
        </button>
        <button title="Duplicate" onClick={() => handleDuplicateService(type, p)} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary hover:text-buddy-electric">
          <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>
        </button>
        <button title="Preview" onClick={() => navigate(previewRoute)} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary hover:text-buddy-electric">
          <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
        </button>
        <button title="Edit" onClick={() => navigate(editRoute)} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary hover:text-buddy-gold">
          <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/></svg>
        </button>
        <button title="Delete" onClick={() => handleDelete(type, p.id, p.title ?? p.name)} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary hover:text-buddy-red">
          <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
        </button>
      </div>
    </Card>
  );

  const renderDiscountCard = (c: any) => {
    const isSuspended = !c.is_active && !c.is_expired && !c.is_retired;
    const isExpired = c.is_expired;
    const statusVariant = isExpired ? 'red' : isSuspended ? 'orange' : 'green';
    const statusLabel = isExpired ? 'Expired' : isSuspended ? 'Suspended' : 'Active';
    return (
      <Card key={c.id} className="p-3">
        <div className="flex items-center justify-between gap-2">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <p className="text-sm font-mono font-bold">{c.code}</p>
              <Badge variant={statusVariant} label={statusLabel} size="sm" />
            </div>
            <p className="text-xs text-buddy-text-secondary mt-0.5">
              {c.discount_type === 'percentage' ? `${c.discount_pct}% off` : 'Fixed artifact discount'} · {c.times_used}/{c.usage_limit || '∞'} uses
              {c.campaign ? ` · ${c.campaign}` : ''}
            </p>
          </div>
          <div className="relative shrink-0" ref={openMenu === c.id ? menuRef : undefined}>
            <button onClick={() => { setOpenMenu(openMenu === c.id ? null : c.id); if (openMenu !== c.id) loadAnalytics(c.id); }} className="p-2 rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/></svg>
            </button>
            {openMenu === c.id && (
              <div className="absolute right-0 top-9 z-20 w-48 bg-buddy-surface rounded-xl border border-buddy-surface-raised shadow-xl p-1.5 text-xs font-medium">
                <button onClick={() => { navigate(`/marketplace/creator/discount-codes/${c.id}/analytics`); setOpenMenu(null); }} className="w-full text-left px-3 py-2 rounded-lg hover:bg-buddy-surface-raised flex items-center gap-2">
                  <span className="text-buddy-electric">📊</span> Analytics
                </button>
                <button onClick={() => { handleShare(c); setOpenMenu(null); }} className="w-full text-left px-3 py-2 rounded-lg hover:bg-buddy-surface-raised flex items-center gap-2">
                  <span>📤</span> Share Code
                </button>
                {!isExpired && (
                  <button onClick={() => { handleToggleCode(c); setOpenMenu(null); }} className="w-full text-left px-3 py-2 rounded-lg hover:bg-buddy-surface-raised flex items-center gap-2">
                    <span className={isSuspended ? 'text-buddy-green' : 'text-buddy-orange'}>{isSuspended ? '▶' : '⏸'}</span> {isSuspended ? 'Reactivate' : 'Suspend'}
                  </button>
                )}
                <button onClick={() => { navigate('/marketplace/creator/discount-codes'); setOpenMenu(null); }} className="w-full text-left px-3 py-2 rounded-lg hover:bg-buddy-surface-raised flex items-center gap-2">
                  <span>✏️</span> Edit
                </button>
                <button onClick={() => { handleDelete('discount', c.id, c.code); setOpenMenu(null); }} className="w-full text-left px-3 py-2 rounded-lg hover:bg-buddy-surface-raised text-buddy-red flex items-center gap-2">
                  <span>🗑️</span> Delete
                </button>
              </div>
            )}
          </div>
        </div>

        {analyticsPanel && analyticsPanel.code?.id === c.id && (
          <div className="mt-3 pt-3 border-t border-buddy-surface-raised">
            <div className="flex items-end justify-between mb-2">
              <div className="grid grid-cols-2 gap-2 flex-1">
                <div><span className="text-[10px] text-buddy-text-secondary">Uses</span><p className="text-sm font-bold">{analyticsPanel.total_uses}</p></div>
                <div><span className="text-[10px] text-buddy-text-secondary">Savings</span><p className="text-sm font-bold text-buddy-green">${analyticsPanel.total_savings_usd}</p></div>
              </div>
              <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/creator/discount-codes/${c.id}/analytics`)} className="text-buddy-electric">View Full Analytics →</Button>
            </div>
            {analyticsPanel.usage_over_time && analyticsPanel.usage_over_time.length > 0 && (
              <div className="flex items-end gap-1 h-10">
                {analyticsPanel.usage_over_time.slice(-14).map((p: any, i: number) => {
                  const max = Math.max(...analyticsPanel.usage_over_time.slice(-14).map((x: any) => x.count), 1);
                  return (
                    <div key={i} className="flex-1 bg-buddy-electric/40 hover:bg-buddy-electric rounded-t transition-colors" style={{ height: `${Math.max((p.count / max) * 100, 8)}%` }} title={`${p.date}: ${p.count} uses`} />
                  );
                })}
              </div>
            )}
          </div>
        )}
      </Card>
    );
  };

  if (certifyingShop) {
    return (
      <BuddyUpCertification
        shopId={certifyingShop.id}
        shopName={certifyingShop.name}
        onClose={() => setCertifyingShop(null)}
      />
    );
  }

  return (
    <div className="max-w-lg lg:max-w-3xl xl:max-w-4xl mx-auto p-4 space-y-4 pb-20">
      <div className="flex items-center justify-between gap-3 mb-1">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('/marketplace')} className="p-2 rounded-full hover:bg-buddy-surface">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
          </button>
          <h1 className="font-display text-2xl font-extrabold">Creator Studio</h1>
        </div>
        <Button size="sm" onClick={() => setShowAddServiceModal(true)} className="bg-buddy-electric text-buddy-black font-bold">
          + Add Service
        </Button>
      </div>

      {/* 6 Tabs Navigation */}
      <div className="flex gap-1 bg-buddy-surface rounded-xl p-1 overflow-x-auto">
        {Object.entries(TAB_STYLES).map(([key, style]) => (
          <button
            key={key}
            onClick={() => setTab(key as Tab)}
            className={`flex-1 min-w-[75px] py-2 px-1 text-xs font-semibold rounded-lg transition-all ${tab === key ? style.active : 'text-buddy-text-secondary hover:text-buddy-text'}`}
          >
            <span className="inline-flex items-center gap-1.5">
              <span className={`w-1.5 h-1.5 rounded-full ${tab === key ? 'bg-current' : style.dot} ${tab === key ? '' : 'opacity-60'}`} />
              {style.label}
            </span>
          </button>
        ))}
      </div>

      {/* TAB 1: Analytics */}
      {tab === 'analytics' && (
        loadingAnalytics ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <Card key={i} className="p-4 animate-pulse"><div className="h-12 bg-buddy-surface-raised rounded-xl" /></Card>
            ))}
          </div>
        ) : !analytics ? (
          <p className="text-sm text-buddy-text-secondary text-center py-8">Failed to load analytics.</p>
        ) : (
          <section className="space-y-4">
            <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Performance Overview</h2>

            <div className="grid grid-cols-2 gap-3">
              <Card className="p-4 bg-gradient-to-br from-buddy-green/20 to-transparent border-buddy-green/30">
                <p className="text-xs text-buddy-text-secondary font-medium">Total Revenue</p>
                <p className="text-2xl font-display font-extrabold mt-1">${analytics.total_revenue_usd.toLocaleString()}</p>
                <p className="text-[10px] text-buddy-green mt-1">{analytics.total_sales} sales</p>
              </Card>
              <Card className="p-4">
                <p className="text-xs text-buddy-text-secondary font-medium">Total Views</p>
                <p className="text-2xl font-display font-extrabold mt-1">{analytics.total_views.toLocaleString()}</p>
                <p className="text-[10px] text-buddy-green mt-1">Impressions</p>
              </Card>
            </div>

            {Object.keys(analytics.category_sales).length > 0 && (
              <Card className="p-4">
                <p className="text-xs text-buddy-text-secondary font-medium mb-3">Category Sales</p>
                <div className="space-y-3">
                  {Object.entries(analytics.category_sales).map(([cat, count]) => {
                    const pct = analytics.total_sales > 0 ? Math.round((count / analytics.total_sales) * 100) : 0;
                    const colorMap: Record<string, string> = { meal_plan: 'bg-buddy-green', programme: 'bg-buddy-electric', event: 'bg-buddy-gold' };
                    return (
                      <div key={cat}>
                        <div className="flex justify-between text-xs mb-1">
                          <span className="capitalize">{cat.replace('_', ' ')} ({pct}%)</span>
                          <span className="font-bold">{count} sales</span>
                        </div>
                        <div className="h-2 w-full bg-buddy-surface-raised rounded-full overflow-hidden">
                          <div className={`h-full ${colorMap[cat] || 'bg-buddy-electric'} rounded-full`} style={{ width: `${pct}%` }} />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </Card>
            )}

            {analytics.top_services.length > 0 && (
              <Card className="p-4">
                <p className="text-xs text-buddy-text-secondary font-medium mb-2">Top Services</p>
                <div className="space-y-2">
                  {analytics.top_services.map((s) => (
                    <div key={s.id} className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2 min-w-0">
                        <Badge variant="blue" label={s.type.replace('_', ' ')} size="sm" />
                        <span className="truncate">{s.title}</span>
                      </div>
                      <span className="font-medium flex-shrink-0">{s.sales} sales</span>
                    </div>
                  ))}
                </div>
              </Card>
            )}

            {analytics.revenue_over_time.length > 0 && (
              <Card className="p-4">
                <p className="text-xs text-buddy-text-secondary font-medium mb-3">Revenue Over Time</p>
                {(() => {
                  const points = analytics.revenue_over_time;
                  const max = Math.max(...points.map((r) => r.total), 0.01);
                  return (
                    <>
                      <div className="flex items-end gap-2 h-32 mb-2">
                        {points.map((r) => {
                          const h = Math.max(4, Math.round((r.total / max) * 100));
                          return (
                            <div key={r.month} className="flex-1 flex flex-col items-center justify-end h-full group">
                              <span className="text-[9px] font-semibold text-buddy-green opacity-0 group-hover:opacity-100 transition-opacity">
                                ${r.total.toFixed(0)}
                              </span>
                              <div
                                className="w-full max-w-8 rounded-t-md bg-gradient-to-t from-buddy-green/40 to-buddy-green transition-all"
                                style={{ height: `${h}%` }}
                                title={`${r.month}: $${r.total.toFixed(2)}`}
                              />
                            </div>
                          );
                        })}
                      </div>
                      <div className="flex justify-between text-[10px] text-buddy-text-secondary">
                        {points.map((r) => (
                          <span key={r.month} className="flex-1 text-center truncate">{r.month}</span>
                        ))}
                      </div>
                    </>
                  );
                })()}
              </Card>
            )}
          </section>
        )
      )}

      {/* TAB 2: Orders */}
      {tab === 'orders' && (
        <section className="space-y-4">
          <div className="flex items-center justify-between flex-wrap gap-2">
            <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Creator Orders ({orders.length})</h2>
            <div className="flex items-center gap-2">
              <div className="flex gap-1 overflow-x-auto">
                {['', 'paid', 'shipped', 'delivered', 'cancelled'].map((st) => (
                  <button
                    key={st}
                    onClick={() => setOrderStatusFilter(st)}
                    className={`px-2.5 py-1 text-[11px] font-semibold rounded-lg transition-colors ${orderStatusFilter === st ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary'}`}
                  >
                    {st === '' ? 'All' : st.replace('_', ' ').toUpperCase()}
                  </button>
                ))}
              </div>
              <button
                onClick={exportOrdersCsv}
                disabled={orders.length === 0}
                className="px-2.5 py-1 text-[11px] font-semibold rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-green disabled:opacity-40 shrink-0"
                title="Export orders as CSV"
              >
                Export CSV
              </button>
            </div>
          </div>

          {/* Bulk actions */}
          {selectedOrderIds.length > 0 && (
            <Card className="p-3 flex items-center justify-between flex-wrap gap-2 border-buddy-green/40">
              <span className="text-xs font-semibold">{selectedOrderIds.length} selected</span>
              <div className="flex flex-wrap gap-1.5">
                {['processing', 'shipped', 'delivered'].map((st) => (
                  <button
                    key={st}
                    onClick={() => handleBulkStatus(st)}
                    disabled={bulkUpdating}
                    className="px-3 py-1.5 text-[11px] font-semibold rounded-lg bg-buddy-green text-buddy-black hover:bg-buddy-green-deep disabled:opacity-40"
                  >
                    Mark {st.replace('_', ' ')}
                  </button>
                ))}
                <button
                  onClick={() => setSelectedOrderIds([])}
                  className="px-3 py-1.5 text-[11px] font-semibold rounded-lg bg-buddy-surface hover:bg-buddy-surface-raised"
                >
                  Clear
                </button>
              </div>
            </Card>
          )}

          {loadingOrders ? (
            <div className="space-y-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
              ))}
            </div>
          ) : orders.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary space-y-2">
              <p className="text-sm">No orders found.</p>
              <p className="text-xs">When buyers purchase your products or services, orders appear here.</p>
            </Card>
          ) : (
            <div className="space-y-3">
              {orders.map((order) => {
                const statusColors: Record<string, string> = {
                  paid: 'green',
                  pending: 'orange',
                  shipped: 'blue',
                  delivered: 'green',
                  cancelled: 'red',
                };
                return (
                  <Card key={order.id} className="p-4 space-y-3">
                    <div className="flex items-start justify-between gap-2">
                      <div className="flex items-start gap-2.5 min-w-0">
                        <input
                          type="checkbox"
                          checked={selectedOrderIds.includes(order.id)}
                          onChange={(e) => setSelectedOrderIds((prev) => e.target.checked ? [...prev, order.id] : prev.filter((x) => x !== order.id))}
                          className="mt-1 accent-buddy-green shrink-0"
                          title="Select for bulk update"
                        />
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-mono text-xs font-bold">{order.order_number}</span>
                            <Badge variant={(statusColors[order.status] || 'silver') as any} label={order.status_label || order.status} size="sm" />
                          </div>
                          <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                            {new Date(order.created_at).toLocaleString()} · Total: ${order.total_usd?.toFixed(2) || '0.00'}
                          </p>
                        </div>
                      </div>
                      <Button size="sm" variant="outline" onClick={() => setSelectedOrder(order)}>
                        Manage Status
                      </Button>
                    </div>

                    <div className="space-y-1.5 border-t border-buddy-surface-raised pt-2">
                      {order.items.map((item, idx) => (
                        <div key={idx} className="flex justify-between text-xs">
                          <span className="truncate flex-1">{item.title} (x{item.quantity})</span>
                          <span className="text-buddy-text-secondary capitalize text-[11px]">{item.item_type.replace('_', ' ')}</span>
                        </div>
                      ))}
                    </div>

                    {order.fulfillment?.tracking_number && (
                      <div className="text-xs bg-buddy-surface-raised p-2 rounded-lg text-buddy-text-secondary">
                        Tracking: <span className="font-mono text-buddy-text">{order.fulfillment.tracking_number}</span> ({order.fulfillment.carrier || 'Standard'})
                      </div>
                    )}
                  </Card>
                );
              })}
            </div>
          )}
        </section>
      )}

      {/* TAB 3: Services */}
      {tab === 'services' && (
        loadingServices ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <Card key={i} className="p-4 animate-pulse"><div className="h-12 bg-buddy-surface-raised rounded-xl" /></Card>
            ))}
          </div>
        ) : !services ? (
          <p className="text-sm text-buddy-text-secondary text-center py-8">Failed to load services.</p>
        ) : (
          <div className="space-y-6">
            {!hasShop && (
              <Card className="p-5 bg-buddy-electric/10 border-buddy-electric/30 text-center space-y-3">
                <p className="text-sm font-medium">Become a creator to start selling on BuddyUp.</p>
                <Button onClick={handleRegisterCreator} className="bg-buddy-electric text-buddy-black font-bold">Register as Creator</Button>
              </Card>
            )}

            <section>
              <div className="flex items-center justify-between mb-2">
                <h3 className={`text-xs font-bold uppercase px-2 py-1 rounded-lg border ${TYPE_COLORS.meal_plan}`}>Meal Plans ({services.meal_plans.length})</h3>
                <Button size="sm" variant="ghost" onClick={() => navigate('/marketplace/meal-plans/create')}>+ New</Button>
              </div>
              <div className="space-y-2">
                {services.meal_plans.length === 0 && <p className="text-xs text-buddy-text-secondary px-1">No meal plans created yet.</p>}
                {services.meal_plans.map((p: any) => renderServiceCard(
                  p, 'meal_plan', p.cover_image_url,
                  `/marketplace/meal-plans/${p.id}`,
                  `/marketplace/meal-plans/create?edit=${p.id}`,
                  `${p.purchase_count} sold · ~$${artifactUsd(p.price_artifacts).toFixed(2)}`,
                  p.is_published,
                ))}
              </div>
            </section>

            <section>
              <div className="flex items-center justify-between mb-2">
                <h3 className={`text-xs font-bold uppercase px-2 py-1 rounded-lg border ${TYPE_COLORS.programme}`}>Programmes ({services.programmes.length})</h3>
                <Button size="sm" variant="ghost" onClick={() => navigate('/marketplace/programmes/create')}>+ New</Button>
              </div>
              <div className="space-y-2">
                {services.programmes.length === 0 && <p className="text-xs text-buddy-text-secondary px-1">No programmes created yet.</p>}
                {services.programmes.map((p: any) => renderServiceCard(
                  p, 'programme', p.cover_image_url,
                  `/marketplace/programmes/${p.id}`,
                  `/marketplace/programmes/create?edit=${p.id}`,
                  `${p.purchase_count} sold · ~$${artifactUsd(p.price_artifacts).toFixed(2)}`,
                  p.is_published,
                ))}
              </div>
            </section>

            <section>
              <div className="flex items-center justify-between mb-2">
                <h3 className={`text-xs font-bold uppercase px-2 py-1 rounded-lg border ${TYPE_COLORS.event}`}>Events ({services.events.length})</h3>
                <Button size="sm" variant="ghost" onClick={() => navigate('/marketplace/events/create')}>+ New</Button>
              </div>
              <div className="space-y-2">
                {services.events.length === 0 && <p className="text-xs text-buddy-text-secondary px-1">No events created yet.</p>}
                {services.events.map((e: any) => renderServiceCard(
                  e, 'event', e.cover_image_url,
                  `/marketplace/events/${e.id}`,
                  `/marketplace/events/create?edit=${e.id}`,
                  `${e.attendee_count} attending · ${new Date(e.start_datetime).toLocaleDateString()}`,
                  e.is_published,
                ))}
              </div>
            </section>

            <section>
              <div className="flex items-center justify-between mb-2">
                <h3 className={`text-xs font-bold uppercase px-2 py-1 rounded-lg border ${TYPE_COLORS.product}`}>Products ({services.products?.length || 0})</h3>
                <Button size="sm" variant="ghost" onClick={() => navigate('/marketplace/products/create')}>+ New</Button>
              </div>
              <div className="space-y-2">
                {(!services.products || services.products.length === 0) && <p className="text-xs text-buddy-text-secondary px-1">No products created yet.</p>}
                {services.products?.map((p: ProductMP) => renderServiceCard(
                  p as any, 'product', p.image_url,
                  `/marketplace/products/${p.id}`,
                  `/marketplace/products/create?edit=${p.id}`,
                  `${p.click_count} clicks`,
                  (p as any).is_active ?? true,
                ))}
              </div>
            </section>
          </div>
        )
      )}

      {/* TAB 4: Payouts */}
      {tab === 'payouts' && (
        <section className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Payouts & Earnings</h2>
            <Button size="sm" onClick={() => setShowPayoutModal(true)} className="bg-purple-500 hover:bg-purple-600 text-white font-bold">
              Request Payout
            </Button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4 bg-gradient-to-br from-purple-500/20 to-transparent border-purple-500/30">
              <p className="text-xs text-buddy-text-secondary font-medium">Creator Balance</p>
              <p className="text-2xl font-display font-extrabold mt-1">
                ${walletBalance?.creator_total_fiat?.toFixed(2) || '0.00'}
              </p>
              <p className="text-[10px] text-purple-400 mt-1">Available for withdrawal</p>
            </Card>
            <Card className="p-4">
              <p className="text-xs text-buddy-text-secondary font-medium">Total Balance</p>
              <p className="text-2xl font-display font-extrabold mt-1">
                ${walletBalance?.total_fiat?.toFixed(2) || '0.00'}
              </p>
              <p className="text-[10px] text-buddy-green mt-1">All wallets combined</p>
            </Card>
          </div>

          <Card className="p-4 space-y-3">
            <h3 className="text-xs font-bold text-buddy-text-secondary uppercase">Payout History</h3>
            {loadingPayouts ? (
              <div className="space-y-2">
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} className="h-10 bg-buddy-surface-raised animate-pulse rounded-lg" />
                ))}
              </div>
            ) : payouts.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary text-center py-4">No payout transactions recorded yet.</p>
            ) : (
              <div className="space-y-2">
                {payouts.map((tx) => (
                  <div key={tx.id} className="flex items-center justify-between p-2.5 rounded-lg bg-buddy-surface-raised text-xs">
                    <div>
                      <p className="font-semibold">{tx.description || 'Payout Withdrawal'}</p>
                      <p className="text-[10px] text-buddy-text-secondary">{new Date(tx.created_at).toLocaleDateString()} · {tx.reference_id || tx.id}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-bold text-sm">${tx.fiat_amount ? parseFloat(tx.fiat_amount).toFixed(2) : (tx.quantity * 1.0).toFixed(2)}</p>
                      <Badge variant={tx.status === 'completed' ? 'green' : tx.status === 'pending' ? 'orange' : 'red'} label={tx.status} size="sm" />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </section>
      )}

      {/* TAB 5: My Shops */}
      {tab === 'shop' && (
        loadingShops ? (
          <div className="space-y-3">
            {Array.from({ length: 2 }).map((_, i) => (
              <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
            ))}
          </div>
        ) : shops.length === 0 ? (
          <div className="text-center py-10 space-y-4 bg-buddy-surface/30 rounded-xl">
            <p className="text-sm text-buddy-text-secondary">You're not a creator yet. Register to start selling your services on BuddyUp.</p>
            <Button onClick={handleRegisterCreator} className="bg-buddy-electric text-buddy-black font-bold">Register as Creator</Button>
            <p className="text-[11px] text-buddy-text-secondary">or</p>
            <Button onClick={() => navigate('/marketplace/shops/create')} variant="outline" className="text-buddy-electric">Set up a custom shop</Button>
          </div>
        ) : (
          <div className="space-y-4">
            <div className="flex justify-end">
              <Button size="sm" onClick={() => navigate('/marketplace/shops/create')} className="bg-buddy-electric text-buddy-black font-bold">+ New Shop</Button>
            </div>
            {shops.map((shop) => (
              <Card key={shop.id} className="p-4 border-none shadow-md bg-buddy-surface/50 backdrop-blur-md">
                <div className="flex items-start justify-between mb-3 border-b border-buddy-surface-raised pb-3">
                  <div>
                    <h3 className="font-bold text-lg">{shop.name}</h3>
                    <p className="text-xs text-buddy-text-secondary">@{shop.handle}</p>
                  </div>
                  <Badge
                    variant={shop.verification_status === 'verified' ? 'green' : shop.verification_status === 'pending' ? 'orange' : 'silver'}
                    label={shop.verification_status === 'verified' ? 'Verified' : shop.verification_status === 'pending' ? 'Pending' : 'Unverified'}
                    size="sm"
                  />
                </div>

                <p className="text-sm text-buddy-text-secondary line-clamp-2 mb-4">{shop.description || 'No description.'}</p>

                <div className="flex gap-2">
                  <Button variant="outline" size="sm" className="flex-1" onClick={() => navigate(`/shops/${shop.handle}`)}>View Storefront</Button>
                  {shop.verification_status !== 'verified' && shop.verification_status !== 'pending' && (
                    <Button size="sm" className="flex-1 bg-gradient-to-r from-buddy-gold to-yellow-400 text-buddy-black font-bold border-none" onClick={() => setCertifyingShop({ id: shop.id, name: shop.name })}>
                      Get Certified
                    </Button>
                  )}
                </div>
              </Card>
            ))}
          </div>
        )
      )}

      {/* TAB 6: Discounts */}
      {tab === 'discounts' && (
        loadingServices ? (
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Card key={i} className="p-4 animate-pulse"><div className="h-12 bg-buddy-surface-raised rounded-xl" /></Card>
            ))}
          </div>
        ) : !services ? (
          <p className="text-sm text-buddy-text-secondary text-center py-8">Failed to load.</p>
        ) : (
          <section>
            <div className="flex items-center justify-between mb-2">
              <h3 className="text-xs font-bold text-buddy-text-secondary uppercase">Discount Codes ({services.discount_codes?.length || 0})</h3>
              <Button size="sm" variant="ghost" onClick={() => navigate('/marketplace/creator/discount-codes')}>+ New</Button>
            </div>
            <div className="space-y-2">
              {(!services.discount_codes || services.discount_codes.length === 0) && <p className="text-xs text-buddy-text-secondary">No discount codes created.</p>}
              {services.discount_codes?.map((c: any) => renderDiscountCard(c))}
            </div>
          </section>
        )
      )}

      {/* MODAL: Update Order Status */}
      {selectedOrder && (
        <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4 backdrop-blur-sm">
          <Card className="w-full max-w-md p-5 space-y-4 bg-buddy-surface">
            <h3 className="font-bold text-base">Update Order Status</h3>
            <p className="text-xs text-buddy-text-secondary">Order #{selectedOrder.order_number}</p>

            <div className="space-y-2">
              <label className="text-xs font-medium">Select Status</label>
              <div className="grid grid-cols-2 gap-2">
                {['pending_fulfillment', 'shipped', 'out_for_delivery', 'delivered', 'cancelled'].map((st) => (
                  <button
                    key={st}
                    onClick={() => setUpdatingOrderStatus(st)}
                    className={`p-2 text-xs font-semibold rounded-lg border transition-colors ${updatingOrderStatus === st ? 'border-buddy-green bg-buddy-green/20 text-buddy-green' : 'border-buddy-surface-raised hover:bg-buddy-surface-raised'}`}
                  >
                    {st.replace(/_/g, ' ').toUpperCase()}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-1">
              <label className="text-xs font-medium">Note / Tracking info (Optional)</label>
              <textarea
                value={statusNote}
                onChange={(e) => setStatusNote(e.target.value)}
                placeholder="e.g. Dispatched via DHL. Tracking #12345"
                rows={2}
                className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-xs outline-none border border-buddy-surface-raised focus:border-buddy-green"
              />
            </div>

            <div className="flex gap-2 justify-end pt-2">
              <Button variant="ghost" size="sm" onClick={() => setSelectedOrder(null)}>Cancel</Button>
              <Button
                size="sm"
                disabled={!updatingOrderStatus}
                onClick={() => updatingOrderStatus && handleUpdateOrderStatus(selectedOrder.id, updatingOrderStatus)}
                className="bg-buddy-green text-buddy-black font-bold"
              >
                Confirm Update
              </Button>
            </div>
          </Card>
        </div>
      )}

      {/* MODAL: Request Payout */}
      {showPayoutModal && (
        <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4 backdrop-blur-sm">
          <Card className="w-full max-w-md p-5 space-y-4 bg-buddy-surface">
            <h3 className="font-bold text-base">Request Creator Payout</h3>
            <p className="text-xs text-buddy-text-secondary">Available balance: ${walletBalance?.creator_total_fiat?.toFixed(2) || '0.00'}</p>

            <form onSubmit={handleRequestPayout} className="space-y-3">
              <div>
                <label className="text-xs font-medium block mb-1">Amount (USD)</label>
                <input
                  type="number"
                  step="0.01"
                  min="5"
                  max={walletBalance?.creator_total_fiat || 10000}
                  value={payoutAmount}
                  onChange={(e) => setPayoutAmount(e.target.value)}
                  placeholder="Min $5.00"
                  required
                  className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-sm outline-none border border-buddy-surface-raised focus:border-purple-500"
                />
              </div>

              <div>
                <label className="text-xs font-medium block mb-1">Payout Method</label>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setPayoutMethod('mpesa')}
                    className={`flex-1 p-2 text-xs font-bold rounded-lg border transition-colors ${payoutMethod === 'mpesa' ? 'border-buddy-green bg-buddy-green/20 text-buddy-green' : 'border-buddy-surface-raised'}`}
                  >
                    M-Pesa
                  </button>
                  <button
                    type="button"
                    onClick={() => setPayoutMethod('bank_transfer')}
                    className={`flex-1 p-2 text-xs font-bold rounded-lg border transition-colors ${payoutMethod === 'bank_transfer' ? 'border-purple-500 bg-purple-500/20 text-purple-400' : 'border-buddy-surface-raised'}`}
                  >
                    Bank Transfer
                  </button>
                </div>
              </div>

              {payoutMethod === 'mpesa' ? (
                <div>
                  <label className="text-xs font-medium block mb-1">M-Pesa Phone Number</label>
                  <input
                    type="tel"
                    value={payoutPhone}
                    onChange={(e) => setPayoutPhone(e.target.value)}
                    placeholder="+254 7XX XXX XXX"
                    required
                    className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-sm outline-none border border-buddy-surface-raised focus:border-buddy-green"
                  />
                </div>
              ) : (
                <div className="space-y-2">
                  <div>
                    <label className="text-xs font-medium block mb-1">Bank</label>
                    <select
                      value={payoutBankCode}
                      onChange={(e) => setPayoutBankCode(e.target.value)}
                      required
                      className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-xs outline-none border border-buddy-surface-raised"
                    >
                      <option value="">Select Bank</option>
                      {banks.map((b) => (
                        <option key={b.code} value={b.code}>{b.name}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="text-xs font-medium block mb-1">Account Number</label>
                    <input
                      type="text"
                      value={payoutBankAccount}
                      onChange={(e) => setPayoutBankAccount(e.target.value)}
                      placeholder="e.g. 1234567890"
                      required
                      className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-xs outline-none border border-buddy-surface-raised"
                    />
                  </div>
                  <div>
                    <label className="text-xs font-medium block mb-1">Account Name</label>
                    <input
                      type="text"
                      value={payoutAccountName}
                      onChange={(e) => setPayoutAccountName(e.target.value)}
                      placeholder="Account holder name"
                      required
                      className="w-full p-2.5 bg-buddy-surface-raised rounded-xl text-xs outline-none border border-buddy-surface-raised"
                    />
                  </div>
                </div>
              )}

              <div className="flex gap-2 justify-end pt-2">
                <Button variant="ghost" size="sm" type="button" onClick={() => setShowPayoutModal(false)}>Cancel</Button>
                <Button type="submit" size="sm" disabled={submittingPayout} className="bg-purple-500 hover:bg-purple-600 text-white font-bold">
                  {submittingPayout ? 'Submitting...' : 'Submit Request'}
                </Button>
              </div>
            </form>
          </Card>
        </div>
      )}

      {/* MODAL: Add Service Picker */}
      {showAddServiceModal && (
        <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4 backdrop-blur-sm">
          <Card className="w-full max-w-sm p-5 space-y-4 bg-buddy-surface">
            <h3 className="font-bold text-base">Create New Service</h3>
            <div className="space-y-2">
              <button
                onClick={() => { setShowAddServiceModal(false); navigate('/marketplace/meal-plans/create'); }}
                className="w-full p-3 text-left rounded-xl bg-buddy-surface-raised hover:bg-buddy-green/20 hover:text-buddy-green flex items-center gap-3 transition-colors"
              >
                <span className="text-lg">🥗</span>
                <div>
                  <p className="font-bold text-sm">Meal Plan</p>
                  <p className="text-[11px] text-buddy-text-secondary">Custom nutrition and diet guides</p>
                </div>
              </button>
              <button
                onClick={() => { setShowAddServiceModal(false); navigate('/marketplace/programmes/create'); }}
                className="w-full p-3 text-left rounded-xl bg-buddy-surface-raised hover:bg-buddy-electric/20 hover:text-buddy-electric flex items-center gap-3 transition-colors"
              >
                <span className="text-lg">🏋️</span>
                <div>
                  <p className="font-bold text-sm">Training Programme</p>
                  <p className="text-[11px] text-buddy-text-secondary">Structured workout routines & schedules</p>
                </div>
              </button>
              <button
                onClick={() => { setShowAddServiceModal(false); navigate('/marketplace/events/create'); }}
                className="w-full p-3 text-left rounded-xl bg-buddy-surface-raised hover:bg-buddy-gold/20 hover:text-buddy-gold flex items-center gap-3 transition-colors"
              >
                <span className="text-lg">🎟️</span>
                <div>
                  <p className="font-bold text-sm">Event / Workshop</p>
                  <p className="text-[11px] text-buddy-text-secondary">Tickets for in-person or live events</p>
                </div>
              </button>
              <button
                onClick={() => { setShowAddServiceModal(false); navigate('/marketplace/products/create'); }}
                className="w-full p-3 text-left rounded-xl bg-buddy-surface-raised hover:bg-buddy-orange/20 hover:text-buddy-orange flex items-center gap-3 transition-colors"
              >
                <span className="text-lg">🛍️</span>
                <div>
                  <p className="font-bold text-sm">Product</p>
                  <p className="text-[11px] text-buddy-text-secondary">Affiliate or direct merchandise item</p>
                </div>
              </button>
            </div>
            <div className="flex justify-end">
              <Button variant="ghost" size="sm" onClick={() => setShowAddServiceModal(false)}>Cancel</Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
