import { useCallback, useMemo, useState } from 'react';
import { ArrowRight, PackageSearch, ShoppingCart, TriangleAlert } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { adminPortalApi, type PortalOrder, type UpdateOrderStatusPayload } from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminErrorState,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  DataRow,
  FilterChips,
  FilterSelect,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, formatMoney, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

/** Order lifecycle as the marketplace models it. */
const ORDER_STATUSES = [
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'out_for_delivery',
  'ready_for_pickup',
  'delivered',
  'cancelled',
  'refunded',
];

const NEXT_STATUSES: Record<string, string[]> = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['processing', 'cancelled'],
  processing: ['shipped', 'ready_for_pickup', 'cancelled'],
  shipped: ['out_for_delivery'],
  out_for_delivery: ['delivered'],
  ready_for_pickup: ['delivered'],
  delivered: ['refunded'],
  cancelled: [],
  refunded: [],
};

const FULFILMENT_OPTIONS = [
  { value: 'all', label: 'Any fulfilment' },
  { value: 'digital', label: 'Digital' },
  { value: 'physical', label: 'Physical' },
  { value: 'pickup', label: 'Pickup' },
  { value: 'service', label: 'Service' },
];

const PAYMENT_STATUS_OPTIONS = [
  { value: 'all', label: 'Any payment' },
  { value: 'unpaid', label: 'Unpaid' },
  { value: 'pending', label: 'Pending' },
  { value: 'paid', label: 'Paid' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
];

const PAYMENT_METHOD_OPTIONS = [
  { value: 'all', label: 'Any method' },
  { value: 'card', label: 'Card' },
  { value: 'mpesa', label: 'M-Pesa' },
  { value: 'flutterwave', label: 'Flutterwave' },
  { value: 'wallet', label: 'Wallet' },
  { value: 'promo', label: 'Promo code' },
];

const statusOptions = () => [
  { value: 'all', label: 'Any status' },
  ...ORDER_STATUSES.map((s) => ({ value: s, label: s.replace(/_/g, ' ') })),
];

export default function AdminOrders() {
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState('all');
  const [fulfilment, setFulfilment] = useState('all');
  const [paymentStatus, setPaymentStatus] = useState('all');
  const [paymentMethod, setPaymentMethod] = useState('all');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [pending, setPending] = useState<{ id: string; status: string } | null>(null);
  const debouncedQuery = useDebounced(query);
  const action = usePortalAction();

  const filters = useMemo(
    () => ({
      q: debouncedQuery.trim() || undefined,
      status,
      fulfillment_type: fulfilment,
      payment_status: paymentStatus,
      payment_method: paymentMethod,
    }),
    [debouncedQuery, status, fulfilment, paymentStatus, paymentMethod],
  );

  const fetcher = useCallback((params: Record<string, unknown>) => adminPortalApi.getOrders(params as never), []);
  const { items, count, page, pageCount, loading, error, reload, goToPage } = usePortalList<PortalOrder>(fetcher, filters);

  const transition = useCallback(
    async (order: PortalOrder, next: string, note: string) => {
      const id = order.id;
      if (!id) return;
      const payload: UpdateOrderStatusPayload = { status: next, note: note || undefined };
      const ok = await action.run(
        id,
        () => adminPortalApi.updateOrderStatus(id, payload),
        {
          success: `Order ${text(order.order_number, id.slice(0, 8))} moved to ${next.replace(/_/g, ' ')}.`,
          failure: 'Failed to update order status.',
        },
      );
      setPending(null);
      if (ok) reload(true);
    },
    [action, reload],
  );

  if (loading && !items.length) return <AdminSkeleton />;
  if (error && !items.length) return <AdminErrorState message={error} onRetry={() => reload()} />;

  const unpaid = items.filter((o) => o.payment_status === 'unpaid' || o.payment_status === 'failed').length;
  const open = items.filter((o) => !['delivered', 'cancelled', 'refunded'].includes(String(o.status))).length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Orders"
        description="Order lifecycle across the marketplace. Illegal transitions are rejected by the server and surfaced here."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching orders" value={count.toLocaleString()} />
        <AdminStatCard label="Open on this page" value={open} />
        <AdminStatCard label="Payment issues" value={unpaid} sub="unpaid or failed" />
        <AdminStatCard label="On this page" value={items.length} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <SearchField value={query} onChange={setQuery} label="Search orders" placeholder="Order number, buyer, shop…" />
          <div className="ml-auto">
            <FilterChips options={statusOptions()} value={status} onChange={setStatus} />
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <FilterChips
            options={FULFILMENT_OPTIONS.map((o) => ({ value: o.value, label: o.label }))}
            value={fulfilment}
            onChange={setFulfilment}
          />
          <div className="flex flex-wrap items-center gap-2 ml-auto">
            <FilterSelect label="Payment" value={paymentStatus} options={PAYMENT_STATUS_OPTIONS} onChange={setPaymentStatus} />
            <FilterSelect label="Method" value={paymentMethod} options={PAYMENT_METHOD_OPTIONS} onChange={setPaymentMethod} />
          </div>
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {action.error && <AdminErrorBanner message={action.error} />}
      {action.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {action.notice}
        </div>
      )}

      {items.length === 0 ? (
        <AdminEmptyState icon={<PackageSearch size={32} />} title={count === 0 ? 'No orders match the current filters.' : 'No orders on this page.'} />
      ) : (
        <div className="space-y-2">
          {items.map((order, index) => {
            const key = order.id || `order-${index}`;
            const isOpen = expanded === key;
            const busy = action.actingId === key;
            const options = NEXT_STATUSES[String(order.status)] ?? [];
            const total = text(order.total_usd === null || order.total_usd === undefined ? undefined : formatMoney(order.total_usd));
            return (
              <Card key={key} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-sm font-semibold">{text(order.order_number, shortId(order.id))}</span>
                      <StatusBadge status={order.status} />
                      <StatusBadge status={order.payment_status} />
                      {order.fulfillment_type && <StatusBadge status={order.fulfillment_type} />}
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      {text(order.shop_name || order.shop)} · buyer {text(order.buyer_display_name || order.buyer)} · {text(order.payment_method)}
                    </p>
                    <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                      {total} · {shortId(order.id)} · placed {formatDate(order.created_at)}
                    </p>
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <Button variant="ghost" size="sm" onClick={() => setExpanded(isOpen ? null : key)}>Details</Button>
                  </div>
                </div>

                {isOpen && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface space-y-3">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6">
                      <DataRow label="Fulfilment">{text(order.fulfillment_type)}</DataRow>
                      <DataRow label="Payment status">{text(order.payment_status)}</DataRow>
                      <DataRow label="Payment method">{text(order.payment_method)}</DataRow>
                      <DataRow label="Paid at">{formatDate(order.paid_at)}</DataRow>
                      <DataRow label="Items">{order.items?.length ?? '—'}</DataRow>
                      <DataRow label="Last updated">{formatDate(order.updated_at)}</DataRow>
                    </div>

                    {Array.isArray(order.items) && order.items.length > 0 && (
                      <div className="rounded-xl border border-buddy-surface p-3 space-y-1">
                        {order.items.map((item, i) => (
                          <div key={item.item_type || i} className="flex items-center justify-between gap-3 text-xs">
                            <span className="min-w-0 truncate">{text(item.title, 'Item')} × {item.quantity ?? 1}</span>
                            <span className="text-buddy-text-secondary flex-shrink-0">{text(item.creator_name, '—')}</span>
                          </div>
                        ))}
                      </div>
                    )}

                    {Array.isArray(order.status_history) && order.status_history.length > 0 && (
                      <div>
                        <p className="text-[11px] font-semibold uppercase tracking-wide text-buddy-text-secondary mb-1">History</p>
                        <div className="space-y-1">
                          {order.status_history.map((h, i) => (
                            <div key={`${h.status}-${i}`} className="flex items-center justify-between gap-3 text-[11px]">
                              <span className="capitalize">{text(h.status).replace(/_/g, ' ')}</span>
                              <span className="text-buddy-text-secondary">{formatDate(h.at)}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    <div>
                      <p className="text-[11px] font-semibold uppercase tracking-wide text-buddy-text-secondary mb-1.5">Move to</p>
                      {options.length === 0 ? (
                        <p className="text-xs text-buddy-text-secondary">This order is in a final state — no further transitions are available.</p>
                      ) : (
                        <div className="flex flex-wrap items-center gap-2">
                          {options.map((next) => (
                            <Button
                              key={next}
                              variant={next === 'cancelled' || next === 'refunded' ? 'destructive' : 'outline'}
                              size="sm"
                              disabled={busy}
                              onClick={() => setPending({ id: key, status: next })}
                            >
                              <ArrowRight size={12} className="mr-1" /> {next.replace(/_/g, ' ')}
                            </Button>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {pending?.id === key && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface">
                    <p className="text-xs text-buddy-text-secondary mb-2 flex items-center gap-1.5">
                      <TriangleAlert size={13} className="text-buddy-orange" />
                      Set order {text(order.order_number, key)} to <span className="font-semibold capitalize">{pending.status.replace(/_/g, ' ')}</span>
                    </p>
                    <OrderNoteForm
                      busy={busy}
                      onSubmit={(note) => transition(order, pending.status, note)}
                      onCancel={() => setPending(null)}
                    />
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />

      <p className="text-[11px] text-buddy-text-secondary text-center flex items-center justify-center gap-1.5">
        <ShoppingCart size={12} /> The server owns the state machine — an invalid transition returns 400 and its message is shown above.
      </p>
    </div>
  );
}

/** Local note composer for a status transition. */
function OrderNoteForm({
  busy,
  onSubmit,
  onCancel,
}: {
  busy: boolean;
  onSubmit: (note: string) => void;
  onCancel: () => void;
}) {
  const [note, setNote] = useState('');
  return (
    <div>
      <label className="block text-xs text-buddy-text-secondary mb-1.5">Note (optional, kept in the status history)</label>
      <input
        value={note}
        onChange={(e) => setNote(e.target.value)}
        placeholder="e.g. handed to courier at 14:20"
        aria-label="Status change note"
        className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
      />
      <div className="flex items-center gap-2 mt-2">
        <Button size="sm" isLoading={busy} onClick={() => onSubmit(note.trim())}>Confirm</Button>
        <Button variant="ghost" size="sm" onClick={onCancel}>Cancel</Button>
      </div>
    </div>
  );
}