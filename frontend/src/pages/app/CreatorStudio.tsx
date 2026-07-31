import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { CreatorAnalytics, DiscountAnalytics, ProductMP } from '@/api/marketplace';
import { useToast } from '@/components/ui/Toast';
import BuddyUpCertification from './BuddyUpCertification';

type Tab = 'analytics' | 'services' | 'discounts' | 'shop';

const TAB_STYLES: Record<Tab, { active: string; dot: string; label: string }> = {
  analytics: { active: 'bg-buddy-electric text-buddy-black shadow-lg', dot: 'bg-buddy-electric', label: 'Analytics' },
  services: { active: 'bg-buddy-green text-buddy-black shadow-lg', dot: 'bg-buddy-green', label: 'Services' },
  shop: { active: 'bg-buddy-gold text-buddy-black shadow-lg', dot: 'bg-buddy-gold', label: 'My Shops' },
  discounts: { active: 'bg-buddy-orange text-buddy-black shadow-lg', dot: 'bg-buddy-orange', label: 'Discounts' },
};

const TYPE_COLORS: Record<string, string> = {
  meal_plan: 'text-buddy-green border-buddy-green/30 bg-buddy-green/10',
  programme: 'text-buddy-electric border-buddy-electric/30 bg-buddy-electric/10',
  event: 'text-buddy-gold border-buddy-gold/30 bg-buddy-gold/10',
  product: 'text-buddy-orange border-buddy-orange/30 bg-buddy-orange/10',
};

const ARTIFACT_VALUES: Record<string, number> = { dumbbell: 0.10, barbell: 0.50, burpee: 1.00, squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00 };

function artifactUsd(artifacts: Record<string, number> | undefined): number {
  if (!artifacts) return 0;
  return Object.entries(artifacts).reduce((s, [k, v]) => s + (ARTIFACT_VALUES[k] || 0) * (v || 0), 0);
}

export default function CreatorStudio() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [tab, setTab] = useState<Tab>('analytics');
  const [analytics, setAnalytics] = useState<CreatorAnalytics | null>(null);
  const [services, setServices] = useState<any>(null);
  const [shops, setShops] = useState<any[]>([]);
  const [loadingAnalytics, setLoadingAnalytics] = useState(true);
  const [loadingServices, setLoadingServices] = useState(true);
  const [loadingShops, setLoadingShops] = useState(true);
  const [certifyingShop, setCertifyingShop] = useState<{id: string, name: string} | null>(null);
  const [openMenu, setOpenMenu] = useState<string | null>(null);
  const [analyticsPanel, setAnalyticsPanel] = useState<DiscountAnalytics | null>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    marketplaceApi.getCreatorAnalytics()
      .then((res) => setAnalytics(res.data))
      .catch(() => {})
      .finally(() => setLoadingAnalytics(false));
  }, []);

  useEffect(() => {
    marketplaceApi.getMyServices()
      .then((res) => setServices(res.data))
      .catch(() => {})
      .finally(() => setLoadingServices(false));
  }, []);

  useEffect(() => {
    marketplaceApi.getMyShops()
      .then((res) => setShops(res.data || []))
      .catch(() => {})
      .finally(() => setLoadingShops(false));
  }, []);

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setOpenMenu(null);
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  const refreshServices = () => {
    setLoadingServices(true);
    marketplaceApi.getMyServices()
      .then((res) => setServices(res.data))
      .catch(() => {})
      .finally(() => setLoadingServices(false));
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
      const res = await marketplaceApi.shareDiscountCode(code.id);
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
          <Badge variant={isPublished ? 'green' : 'orange'} label={isPublished ? 'Published' : 'Draft'} size="sm" />
          <span className="text-[11px] text-buddy-text-secondary">{meta}</span>
          {p.abandoned_cart_count > 0 && <Badge variant="orange" label={`${p.abandoned_cart_count} in carts`} size="sm" />}
        </div>
      </div>
      <div className="flex items-center gap-1 shrink-0">
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
    <div className="max-w-lg mx-auto p-4 space-y-4 pb-20">
      <div className="flex items-center gap-3 mb-1">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold flex-1">Creator Studio</h1>
      </div>

      <div className="flex gap-1 bg-buddy-surface rounded-xl p-1">
        {Object.entries(TAB_STYLES).map(([key, style]) => (
          <button
            key={key}
            onClick={() => setTab(key as Tab)}
            className={`flex-1 py-2 text-xs font-semibold rounded-lg transition-all ${tab === key ? style.active : 'text-buddy-text-secondary hover:text-buddy-text'}`}
          >
            <span className="inline-flex items-center gap-1.5">
              <span className={`w-1.5 h-1.5 rounded-full ${tab === key ? 'bg-current' : style.dot} ${tab === key ? '' : 'opacity-60'}`} />
              {style.label}
            </span>
          </button>
        ))}
      </div>

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
                <p className="text-xs text-buddy-text-secondary font-medium mb-2">Revenue Over Time</p>
                <div className="space-y-1.5">
                  {analytics.revenue_over_time.map((r) => (
                    <div key={r.month} className="flex items-center justify-between text-xs">
                      <span>{r.month}</span>
                      <span className="font-medium">${r.total.toFixed(2)}</span>
                    </div>
                  ))}
                </div>
              </Card>
            )}
          </section>
        )
      )}

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
                {services.events.map((p: any) => renderServiceCard(
                  p, 'event', p.cover_image_url,
                  `/marketplace/events/${p.id}`,
                  `/marketplace/events/create?edit=${p.id}`,
                  `${p.attendee_count} attending · ${new Date(p.start_datetime).toLocaleDateString()}`,
                  p.is_published,
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

      {tab === 'shop' && (
        loadingShops ? (
          <div className="space-y-3">
            {Array.from({ length: 2 }).map((_, i) => (
              <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
            ))}
          </div>
        ) : shops.length === 0 ? (
          <div className="text-center py-10 space-y-4 bg-buddy-surface/30 rounded-xl">
            <p className="text-sm text-buddy-text-secondary">You don't have any shops yet.</p>
            <Button onClick={() => navigate('/marketplace/shops/create')} className="bg-buddy-electric text-buddy-black font-bold">Create a Shop</Button>
          </div>
        ) : (
          <div className="space-y-4">
            <div className="flex justify-end">
              <Button size="sm" onClick={() => navigate('/marketplace/shops/create')} className="bg-buddy-electric text-buddy-black font-bold">+ New Shop</Button>
            </div>
            {shops.map(shop => (
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
    </div>
  );
}
