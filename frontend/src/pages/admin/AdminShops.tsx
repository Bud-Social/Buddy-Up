import { useCallback, useMemo, useState } from 'react';
import { BadgeCheck, CheckCircle2, PackageSearch, RefreshCw, Search, ShieldCheck, Store, XCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalProduct, type PortalShop, type PortalShopCertification } from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminErrorState,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  BooleanBadge,
  DataRow,
  FilterChips,
  FilterSelect,
  ReasonPrompt,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, formatMoney, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

const TABS = [
  { value: 'shops', label: 'Shops' },
  { value: 'products', label: 'Products' },
  { value: 'certifications', label: 'Certifications' },
] as const;
type Tab = (typeof TABS)[number]['value'];

const VERIFICATION_OPTIONS = [
  { value: 'all', label: 'Any verification' },
  { value: 'unverified', label: 'Unverified' },
  { value: 'pending', label: 'Pending' },
  { value: 'verified', label: 'Verified' },
  { value: 'rejected', label: 'Rejected' },
];

const ACTIVE_OPTIONS = [
  { value: 'all', label: 'Any state' },
  { value: 'true', label: 'Active' },
  { value: 'false', label: 'Inactive' },
];

const CERT_STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'pending', label: 'Pending' },
  { value: 'submitted', label: 'Submitted' },
  { value: 'under_review', label: 'Under review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
];

const CERT_PENDING = ['pending', 'submitted', 'under_review'];

export default function AdminShops() {
  const [tab, setTab] = useState<Tab>('shops');
  const [query, setQuery] = useState('');
  const [verification, setVerification] = useState('all');
  const [active, setActive] = useState('all');
  const [certStatus, setCertStatus] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [review, setReview] = useState<{ id: string; decision: 'approved' | 'rejected' } | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const boolOrUndef = (v: string) => (v === 'all' ? undefined : v === 'true');

  const shopFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, verification_status: verification, is_active: boolOrUndef(active) }),
    [debouncedQuery, verification, active],
  );
  const productFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, verification_status: verification, is_active: boolOrUndef(active) }),
    [debouncedQuery, verification, active],
  );
  const certFilters = useMemo(
    () => ({ q: debouncedQuery.trim() || undefined, status: certStatus }),
    [debouncedQuery, certStatus],
  );

  const shopFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getShops(params as never), []);
  const productFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getProducts(params as never), []);
  const certFetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getShopCertifications(params as never), []);

  // All three lists stay mounted-fetched so switching tabs is instant; only the
  // active one renders.
  const shops = usePortalList<PortalShop>(shopFetcher, shopFilters);
  const products = usePortalList<PortalProduct>(productFetcher, productFilters);
  const certs = usePortalList<PortalShopCertification>(certFetcher, certFilters);

  const activeList = tab === 'shops' ? shops : tab === 'products' ? products : certs;

  const toggleShopActive = useCallback(
    async (shop: PortalShop) => {
      const handle = shop.handle;
      if (!handle) return;
      const next = shop.is_active === false;
      const ok = await action.run(
        handle,
        () => adminPortalApi.updateShop(handle, { is_active: next }),
        { success: `${text(shop.name, 'Shop')} is now ${next ? 'active' : 'inactive'}.`, failure: 'Failed to update shop.' },
      );
      if (ok) shops.reload(true);
    },
    [action, shops],
  );

  const submitReview = useCallback(
    async (cert: PortalShopCertification, decision: 'approved' | 'rejected', reason: string) => {
      const id = cert.id;
      if (!id) return;
      const ok = await action.run(
        id,
        () => adminPortalApi.reviewShopCertification(id, { status: decision, reason }),
        { success: `Certification ${decision}.`, failure: 'Failed to review certification.' },
      );
      setReview(null);
      if (ok) certs.reload(true);
    },
    [action, certs],
  );

  if (activeList.error && !activeList.items.length) {
    return <AdminErrorState message={activeList.error} onRetry={() => activeList.reload()} />;
  }
  if (activeList.loading && !activeList.items.length) return <AdminSkeleton />;

  const pendingCerts = certs.items.filter((c) => CERT_PENDING.includes(String(c.status))).length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Shops &amp; Products"
        description="Seller storefronts, catalogue health and the shop certification review queue."
        onRefresh={() => activeList.reload()}
        refreshing={activeList.loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Shops" value={shops.count.toLocaleString()} sub={`${shops.items.filter((s) => s.verification_status === 'verified').length} verified on this page`} />
        <AdminStatCard label="Products" value={products.count.toLocaleString()} sub={`${products.items.filter((p) => p.is_active !== false).length} active on this page`} />
        <AdminStatCard label="Certifications pending" value={pendingCerts} sub={`${certs.count} total`} />
        <AdminStatCard label="Catalogue inactive" value={products.items.filter((p) => p.is_active === false).length} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips
            options={TABS.map((t) => ({ value: t.value, label: t.label }))}
            value={tab}
            onChange={(v) => setTab(v as Tab)}
          />
          <div className="ml-auto">
            <SearchField value={query} onChange={setQuery} label="Search shops and products" placeholder="Name, handle, brand…" />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {tab === 'certifications' ? (
            <FilterSelect label="Certification status" value={certStatus} options={CERT_STATUS_OPTIONS} onChange={setCertStatus} />
          ) : (
            <>
              <FilterSelect label="Verification" value={verification} options={VERIFICATION_OPTIONS} onChange={setVerification} />
              <FilterSelect label="State" value={active} options={ACTIVE_OPTIONS} onChange={setActive} />
            </>
          )}
          {query && (
            <Button variant="ghost" size="sm" onClick={() => setQuery('')}>
              Clear search
            </Button>
          )}
        </div>
      </Card>

      {activeList.error && <AdminErrorBanner message={activeList.error} onRetry={() => activeList.reload()} />}
      {action.error && <AdminErrorBanner message={action.error} />}
      {action.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {action.notice}
        </div>
      )}

      {tab === 'shops' && (
        shops.items.length === 0 ? (
          <AdminEmptyState icon={<Store size={32} />} title={shops.count === 0 ? 'No shops match the current filters.' : 'No shops on this page.'} />
        ) : (
          <div className="space-y-2">
            {shops.items.map((shop, index) => {
              const key = shop.id || shop.handle || `shop-${index}`;
              const isOpen = expanded === key;
              const busy = action.actingId === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(shop.name, 'Unnamed shop')}</span>
                        <StatusBadge status={shop.verification_status} />
                        <BooleanBadge value={shop.is_active} trueLabel="Active" falseLabel="Inactive" />
                        {shop.is_certified === true && <StatusBadge status="certified" />}
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">@{text(shop.handle)} · owner {text(shop.owner_display_name || shop.owner)}</p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {shortId(shop.id)} · {formatMoney(shop.total_revenue_usd)} revenue · {shop.product_count ?? '—'} products
                      </p>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : key)}>Details</Button>
                      {shop.handle && (
                        <Button variant={shop.is_active === false ? 'outline' : 'destructive'} size="sm" disabled={busy} onClick={() => toggleShopActive(shop)}>
                          {shop.is_active === false ? 'Activate' : 'Deactivate'}
                        </Button>
                      )}
                    </div>
                  </div>
                  {isOpen && (
                    <div className="mt-3 pt-3 border-t border-buddy-surface grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                      <DataRow label="Category">{text(shop.category)}</DataRow>
                      <DataRow label="Contact email">{text(shop.contact_email)}</DataRow>
                      <DataRow label="Website">{text(shop.website_url)}</DataRow>
                      <DataRow label="Orders">{typeof shop.order_count === 'number' ? shop.order_count : '—'}</DataRow>
                      <DataRow label="Products">{typeof shop.product_count === 'number' ? shop.product_count : '—'}</DataRow>
                      <DataRow label="Created">{formatDate(shop.created_at)}</DataRow>
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        )
      )}

      {tab === 'products' && (
        products.items.length === 0 ? (
          <AdminEmptyState icon={<PackageSearch size={32} />} title={products.count === 0 ? 'No products match the current filters.' : 'No products on this page.'} />
        ) : (
          <div className="space-y-2">
            {products.items.map((product, index) => (
              <Card key={product.id || `product-${index}`} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold truncate">{text(product.name, 'Untitled product')}</span>
                      <StatusBadge status={product.verification_status} />
                      <BooleanBadge value={product.is_active !== false} trueLabel="Active" falseLabel="Inactive" />
                      {product.is_draft === true && <StatusBadge status="draft" />}
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      {text(product.brand)} · {text(product.category)} · {text(product.shop_name || product.shop)}
                    </p>
                    <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                      {shortId(product.id)} · {text(product.price_display) || formatMoney(product.price_usd)}
                      {typeof product.stock === 'number' ? ` · ${product.stock} in stock` : ''}
                    </p>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )
      )}

      {tab === 'certifications' && (
        certs.items.length === 0 ? (
          <AdminEmptyState
            icon={<ShieldCheck size={32} />}
            title={certs.count === 0 ? 'No shop certifications submitted yet.' : 'No certifications on this page.'}
            hint="Shops appear here once they submit business registration documents."
          />
        ) : (
          <div className="space-y-2">
            {certs.items.map((cert, index) => {
              const key = cert.id || `cert-${index}`;
              const isPending = CERT_PENDING.includes(String(cert.status));
              const busy = action.actingId === key;
              return (
                <Card key={key} className="p-4">
                  <div className="flex flex-wrap items-start gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold truncate">{text(cert.shop_name || cert.shop, 'Unknown shop')}</span>
                        <StatusBadge status={cert.status} />
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">@{text(cert.shop_handle)} · {shortId(cert.id)}</p>
                      <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                        {text(cert.document_type)} · submitted {formatDate(cert.submitted_at || cert.created_at)}
                        {cert.reviewed_at ? ` · reviewed ${formatDate(cert.reviewed_at)}` : ''}
                      </p>
                      {cert.notes && <p className="text-xs text-buddy-text-secondary mt-1.5 line-clamp-2">{cert.notes}</p>}
                      {cert.rejection_reason && <p className="text-[11px] text-buddy-red mt-1 break-words">Reason: {cert.rejection_reason}</p>}
                      {cert.document_url && (
                        <a href={cert.document_url} target="_blank" rel="noreferrer" className="inline-block text-xs text-buddy-green hover:underline mt-1.5">
                          <BadgeCheck size={12} className="mr-1 inline" />Open registration document
                        </a>
                      )}
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      {isPending ? (
                        <>
                          <Button variant="outline" size="sm" disabled={busy} onClick={() => setReview({ id: key, decision: 'approved' })}>
                            <CheckCircle2 size={14} className="mr-1" /> Approve
                          </Button>
                          <Button variant="destructive" size="sm" disabled={busy} onClick={() => setReview({ id: key, decision: 'rejected' })}>
                            <XCircle size={14} className="mr-1" /> Reject
                          </Button>
                        </>
                      ) : (
                        <span className="text-xs text-buddy-text-secondary">No action</span>
                      )}
                    </div>
                  </div>
                  <ReasonPrompt
                    open={review?.id === key}
                    action={review?.id === key ? review.decision : 'approved'}
                    submitLabel={review?.decision === 'rejected' ? 'Reject application' : 'Approve certification'}
                    placeholder={review?.decision === 'rejected' ? 'Explain what is missing — the shop owner sees this.' : 'Optional internal note.'}
                    busy={busy}
                    onSubmit={(reason) => submitReview(cert, review?.decision || 'approved', reason)}
                    onCancel={() => setReview(null)}
                  />
                </Card>
              );
            })}
          </div>
        )
      )}

      <AdminPagination page={activeList.page} pageCount={activeList.pageCount} count={activeList.count} onPage={activeList.goToPage} busy={activeList.loading} />

      {tab !== 'certifications' && pendingCerts > 0 && (
        <button
          type="button"
          onClick={() => setTab('certifications')}
          className="w-full text-xs text-buddy-text-secondary hover:text-buddy-text-primary flex items-center justify-center gap-1.5"
        >
          <RefreshCw size={12} /> {pendingCerts} shop certification{pendingCerts === 1 ? '' : 's'} awaiting review
        </button>
      )}
      {tab === 'certifications' && (
        <p className="text-[11px] text-buddy-text-secondary text-center flex items-center justify-center gap-1.5">
          <Search size={12} /> Certification decisions are recorded in the audit log with the reason you supply.
        </p>
      )}
    </div>
  );
}