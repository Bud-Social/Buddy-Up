import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Coins, Truck, Store, MapPin, Package, ExternalLink, CheckCircle2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi, type Order } from '@/api/marketplace';

const STATUS_STYLES: Record<string, string> = {
  paid: 'bg-buddy-green/20 text-buddy-green',
  processing: 'bg-buddy-blue/20 text-buddy-blue',
  shipped: 'bg-buddy-gold/20 text-buddy-gold',
  out_for_delivery: 'bg-buddy-gold/20 text-buddy-gold',
  ready_for_pickup: 'bg-buddy-blue/20 text-buddy-blue',
  delivered: 'bg-buddy-green/20 text-buddy-green',
  completed: 'bg-buddy-green/20 text-buddy-green',
  cancelled: 'bg-buddy-red/20 text-buddy-red',
};

const STATUS_LABELS: Record<string, string> = {
  paid: 'Paid',
  processing: 'Processing',
  shipped: 'Shipped',
  out_for_delivery: 'Out for Delivery',
  ready_for_pickup: 'Ready for Pickup',
  delivered: 'Delivered',
  completed: 'Completed',
  cancelled: 'Cancelled',
};

const SELLER_STATUS_FLOW = ['processing', 'shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered'];

function artifactDisplay(artifacts: Record<string, number> | null | undefined): string {
  if (!artifacts || Object.keys(artifacts).length === 0) return '';
  return Object.entries(artifacts)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${v} ${k}`)
    .join(', ');
}

export default function OrderDetail() {
  const { orderId } = useParams<{ orderId: string }>();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [order, setOrder] = useState<Order | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSeller, setIsSeller] = useState(false);
  const [status, setStatus] = useState('');
  const [trackingNumber, setTrackingNumber] = useState('');
  const [trackingUrl, setTrackingUrl] = useState('');
  const [carrier, setCarrier] = useState('');
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    if (!orderId) return;
    marketplaceApi.getOrder(orderId)
      .then((res) => {
        setOrder(res.data);
        setStatus(res.data.status);
        setTrackingNumber(res.data.fulfillment?.tracking_number || '');
        setTrackingUrl(res.data.fulfillment?.tracking_url || '');
        setCarrier(res.data.fulfillment?.carrier || '');
        setIsSeller(res.data.is_seller === true);
      })
      .catch((err: any) => {
        if (err.response?.status === 404) {
          toast('error', 'Order not found');
        } else if (err.response?.status === 403) {
          toast('error', 'Permission denied');
        }
        navigate('/marketplace/orders');
      })
      .finally(() => setIsLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [orderId]);

  const handleUpdateFulfillment = async () => {
    if (!orderId) return;
    setUpdating(true);
    try {
      const payload: Record<string, unknown> = { carrier, tracking_number: trackingNumber, tracking_url: trackingUrl };
      if (status !== order?.status) payload.status = status;
      const res = await marketplaceApi.updateOrderFulfillment(orderId, payload);
      setOrder(res.data);
      setStatus(res.data.status);
      toast('success', 'Order updated');
    } catch (err: any) {
      toast('error', err.response?.data?.message || 'Update failed');
    } finally {
      setUpdating(false);
    }
  };

  if (isLoading) {
    return (
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
        <div className="h-24 bg-buddy-surface rounded-2xl animate-pulse" />
      </div>
    );
  }

  if (!order) return null;

  const timeline = [...(order.status_history || [])].reverse();
  const canFulfill = isSeller && SELLER_STATUS_FLOW.includes(order.status);

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 space-y-4">
      <div className="flex items-center gap-3 mb-2">
        <button onClick={() => navigate('/marketplace/orders')} className="p-2 rounded-full hover:bg-buddy-surface transition-colors">
          <ArrowLeft size={20} />
        </button>
        <div>
          <h1 className="font-display text-2xl font-extrabold">Order Details</h1>
          <p className="text-xs text-buddy-text-secondary font-mono">{order.order_number}</p>
        </div>
      </div>

      {/* Status banner */}
      <div className="rounded-2xl bg-buddy-surface p-5 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-xl bg-buddy-green/10 flex items-center justify-center">
            <CheckCircle2 size={22} className="text-buddy-green" />
          </div>
          <div>
            <p className="font-bold">{order.status_label}</p>
            <p className="text-xs text-buddy-text-secondary">Order placed {new Date(order.created_at).toLocaleString()}</p>
          </div>
        </div>
        <span className={`px-2 py-1 rounded text-xs font-bold uppercase tracking-wider ${STATUS_STYLES[order.status] || 'bg-buddy-surface-raised text-buddy-text-secondary'}`}>
          {order.status}
        </span>
      </div>

      {/* Fulfillment summary */}
      <Card className="p-4 space-y-2">
        <h3 className="text-sm font-semibold flex items-center gap-2">
          <Truck size={14} className="text-buddy-green" /> Fulfillment
        </h3>
        <div className="flex items-center justify-between text-xs">
          <span className="text-buddy-text-secondary capitalize">{order.fulfillment_type.replace('_', ' ')}</span>
          {order.fulfillment?.carrier && <span className="font-medium">{order.fulfillment.carrier}</span>}
        </div>
        {order.fulfillment?.pickup_location && (
          <div className="flex items-center gap-2 text-xs">
            <Store size={12} className="text-buddy-text-secondary" />
            <span>{order.fulfillment.pickup_location}</span>
          </div>
        )}
        {order.fulfillment?.tracking_number && (
          <div className="flex items-center gap-2 text-xs">
            <Package size={12} className="text-buddy-text-secondary" />
            <span className="font-mono">{order.fulfillment.tracking_number}</span>
            {order.fulfillment.tracking_url && (
              <a href={order.fulfillment.tracking_url} target="_blank" rel="noreferrer" className="text-buddy-green inline-flex items-center gap-0.5 hover:underline">
                Track <ExternalLink size={10} />
              </a>
            )}
          </div>
        )}
        {order.delivery_address && Object.keys(order.delivery_address).length > 0 && (
          <div className="flex items-start gap-2 text-xs">
            <MapPin size={12} className="text-buddy-text-secondary mt-0.5" />
            <span>{Object.values(order.delivery_address).filter(Boolean).join(', ')}</span>
          </div>
        )}
      </Card>

      {/* Items */}
      <Card className="p-4 space-y-3">
        <h3 className="text-sm font-semibold">Items</h3>
        {(order.items || []).map((it, i) => (
          <div key={i} className="flex items-center justify-between rounded-xl bg-buddy-surface-raised/50 p-3 text-xs">
            <div className="min-w-0">
              <p className="font-semibold truncate">{it.title} <span className="text-buddy-text-secondary">× {it.quantity}</span></p>
              <p className="text-buddy-text-secondary capitalize mt-0.5">{it.item_type.replace('_', ' ')}{it.creator_name ? ` · by ${it.creator_name}` : ''}</p>
            </div>
            <div className="text-right flex-shrink-0">
              <p className="text-buddy-green font-medium">{artifactDisplay(it.paid_artifacts) || '-'}</p>
            </div>
          </div>
        ))}
        <div className="border-t border-buddy-surface-raised pt-3 space-y-1.5 text-xs">
          {order.discount_code && (
            <div className="flex justify-between text-buddy-green">
              <span className="font-mono">{order.discount_code}</span>
              <span>-{artifactDisplay(order.discount_artifacts) || '0'}</span>
            </div>
          )}
          <div className="flex justify-between">
            <span className="text-buddy-text-secondary">You paid</span>
            <span className="font-bold flex items-center gap-1"><Coins size={11} className="text-buddy-green" />{artifactDisplay(order.total_artifacts) || '$0'}</span>
          </div>
          {order.spent_usd > 0 && (
            <div className="flex justify-between text-buddy-text-secondary">
              <span>Value</span>
              <span>${order.spent_usd.toFixed(2)}</span>
            </div>
          )}
        </div>
      </Card>

      {/* Seller fulfillment panel */}
      {canFulfill && (
        <Card className="p-4 space-y-3">
          <h3 className="text-sm font-semibold">Update Fulfillment</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
            <input
              className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green"
              placeholder="Carrier"
              value={carrier}
              onChange={(e) => setCarrier(e.target.value)}
            />
            <input
              className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green"
              placeholder="Tracking number"
              value={trackingNumber}
              onChange={(e) => setTrackingNumber(e.target.value)}
            />
            <input
              className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green"
              placeholder="Tracking URL"
              value={trackingUrl}
              onChange={(e) => setTrackingUrl(e.target.value)}
            />
          </div>
          <div className="flex items-center gap-2">
            <label className="text-xs text-buddy-text-secondary">Status</label>
            <select
              className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green flex-1"
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              {SELLER_STATUS_FLOW.map((s) => (
                <option key={s} value={s}>{STATUS_LABELS[s]}</option>
              ))}
              {order.status !== 'delivered' && <option value="delivered">Delivered</option>}
              {order.status !== 'cancelled' && <option value="cancelled">Cancelled</option>}
            </select>
            <Button size="sm" onClick={handleUpdateFulfillment} isLoading={updating} disabled={updating}>
              Save
            </Button>
          </div>
        </Card>
      )}

      {/* Timeline */}
      {timeline.length > 0 && (
        <Card className="p-4">
          <h3 className="text-sm font-semibold mb-4">Order Timeline</h3>
          <div className="space-y-0">
            {timeline.map((entry, i) => (
              <div key={i} className="flex gap-3">
                <div className="flex flex-col items-center">
                  <div className={`w-2.5 h-2.5 rounded-full mt-1.5 ${i === 0 ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
                  {i < timeline.length - 1 && <div className="w-px flex-1 bg-buddy-surface-raised" />}
                </div>
                <div className={`pb-4 ${i === timeline.length - 1 ? '' : ''}`}>
                  <p className="text-sm font-medium capitalize">{entry.status.replace('_', ' ')}</p>
                  <p className="text-xs text-buddy-text-secondary">
                    {entry.at ? new Date(entry.at).toLocaleString() : ''}
                    {entry.note ? ` · ${entry.note}` : ''}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
}
