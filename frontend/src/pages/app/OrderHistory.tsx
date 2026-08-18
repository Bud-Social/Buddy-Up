import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Package, ChevronRight, Truck, Coins } from 'lucide-react';
import { Card } from '@/components/ui/Card';
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

function artifactDisplay(artifacts: Record<string, number> | null | undefined): string {
  if (!artifacts || Object.keys(artifacts).length === 0) return '';
  return Object.entries(artifacts)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${v} ${k}`)
    .join(', ');
}

export default function OrderHistory() {
  const navigate = useNavigate();
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchOrders = useCallback(() => {
    marketplaceApi.getOrders()
      .then((res) => setOrders(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  useEffect(() => { fetchOrders(); }, [fetchOrders]);

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="font-display text-2xl font-extrabold">My Orders</h1>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : orders.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-buddy-text-secondary">
          <Package size={48} className="mb-4 opacity-30" />
          <p className="text-lg font-medium mb-1">No orders yet</p>
          <p className="text-sm mb-6">Your purchases and their tracking will appear here</p>
          <button onClick={() => navigate('/marketplace')} className="text-buddy-green text-sm font-medium hover:underline">
            Browse Marketplace
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          {orders.map((order) => (
            <Card
              key={order.id}
              className="p-4 cursor-pointer hover:border-buddy-green/40 transition-colors"
              onClick={() => navigate(`/marketplace/orders/${order.id}`)}
            >
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="font-mono text-sm font-semibold">{order.order_number}</span>
                  <span className={`px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider ${STATUS_STYLES[order.status] || 'bg-buddy-surface-raised text-buddy-text-secondary'}`}>
                    {order.status_label}
                  </span>
                </div>
                <ChevronRight size={16} className="text-buddy-text-secondary" />
              </div>

              <div className="flex items-center justify-between text-xs">
                <div className="text-buddy-text-secondary space-y-0.5">
                  <p>{order.items?.length || 0} item{(order.items?.length || 0) > 1 ? 's' : ''} · {new Date(order.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}</p>
                  <p className="flex items-center gap-1">
                    <Coins size={11} className="text-buddy-green" />
                    {artifactDisplay(order.total_artifacts) || '$0'}
                    {order.spent_usd > 0 && <span className="text-buddy-text-secondary/70">(${order.spent_usd.toFixed(2)})</span>}
                  </p>
                </div>
                <div className="flex items-center gap-1 text-buddy-text-secondary">
                  <Truck size={12} />
                  <span className="capitalize">{order.fulfillment_type.replace('_', ' ')}</span>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
