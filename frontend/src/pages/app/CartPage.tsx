import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShoppingCart, Trash2, Minus, Plus, Tag, ChevronLeft, Utensils, Dumbbell, Pill, Calendar, Percent, Coins, DollarSign } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';
import { walletApi, type BalanceItem } from '@/api/wallet';

const itemIcons: Record<string, typeof Pill> = {
  meal_plan: Utensils,
  programme: Dumbbell,
  product: Pill,
  event_ticket: Calendar,
};

const ITEM_FK_KEYS: Record<string, string> = {
  meal_plan: 'meal_plan',
  programme: 'programme',
  product: 'product',
  event_ticket: 'event',
};

const CART_ADD_ID_KEYS: Record<string, string> = {
  meal_plan: 'meal_plan_id',
  programme: 'programme_id',
  product: 'product_id',
  event_ticket: 'event_id',
};

function getItemDetail(item: any): any {
  const fk = ITEM_FK_KEYS[item.item_type];
  return item[`${fk}_detail`] || null;
}

function getItemName(item: any): string {
  const detail = getItemDetail(item);
  if (!detail) return item.item_type.replace('_', ' ');
  if (item.item_type === 'product') return detail.name;
  return detail.title || detail.name || item.item_type.replace('_', ' ');
}

function _getItemPrice(item: any): Record<string, number> {
  const detail = getItemDetail(item);
  if (!detail) return {};
  if (item.item_type === 'meal_plan') return detail.price_artifacts || {};
  if (item.item_type === 'programme') return detail.price_artifacts || {};
  if (item.item_type === 'event_ticket') return detail.ticket_price_artifacts || {};
  return {};
}

function getItemImage(item: any): string | null {
  const detail = getItemDetail(item);
  if (!detail) return null;
  if (item.item_type === 'product') return detail.image_url;
  return detail.cover_image_url || null;
}

function artifactDisplay(artifacts: Record<string, number>): string {
  if (!artifacts || Object.keys(artifacts).length === 0) return '';
  return Object.entries(artifacts)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${v} ${k}`)
    .join(', ');
}

/**
 * The cart is a pure cart: line editing, discount codes and totals only.
 * Review, fulfillment, payment and the receipt all live on the standalone
 * `/marketplace/checkout` page, which this navigates to.
 */
export default function CartPage() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [cart, setCart] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [discountCode, setDiscountCode] = useState('');
  const [applyingDiscount, setApplyingDiscount] = useState(false);
  const [discountMsg, setDiscountMsg] = useState('');
  const [balance, setBalance] = useState<BalanceItem[]>([]);

  const fetchCart = useCallback(() => {
    setIsLoading(true);
    Promise.all([marketplaceApi.getCart(), walletApi.getBalance().catch(() => null)])
      .then(([cartRes, balRes]) => {
        setCart(cartRes.data);
        if (balRes?.data?.regular_balance) setBalance(balRes.data.regular_balance);
      })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  useEffect(() => { fetchCart(); }, [fetchCart]);

  const balanceFor = (type: string) => balance.find((b) => b.artifact_type === type)?.quantity ?? 0;
  const cartTotals: Record<string, number> = (cart?.total_artifacts as Record<string, number>) || {};
  const shortfall = Object.entries(cartTotals).filter(([, v]) => v > 0).find(([k, v]) => balanceFor(k) < v);

  const handleRemove = async (itemId: string) => {
    await marketplaceApi.removeFromCart(itemId);
    toast('success', 'Item removed');
    window.dispatchEvent(new CustomEvent('cart-updated'));
    fetchCart();
  };

  const handleQuantity = async (item: any, delta: number) => {
    const newQty = item.quantity + delta;
    if (newQty < 1) {
      await handleRemove(item.id);
      return;
    }
    await marketplaceApi.removeFromCart(item.id);
    const type = item.item_type as 'meal_plan' | 'programme' | 'product' | 'event_ticket';
    const id = item[ITEM_FK_KEYS[type]];
    await marketplaceApi.addToCart(type, { [CART_ADD_ID_KEYS[type]]: id }, newQty);
    window.dispatchEvent(new CustomEvent('cart-updated'));
    fetchCart();
  };

  const applyDiscount = async () => {
    if (!discountCode.trim()) return;
    setApplyingDiscount(true);
    setDiscountMsg('');
    try {
      await marketplaceApi.applyDiscount(discountCode.trim());
      toast('success', 'Discount applied!');
      setDiscountMsg('');
      fetchCart();
    } catch (err: any) {
      setDiscountMsg(err.response?.data?.message || 'Invalid discount code');
    } finally {
      setApplyingDiscount(false);
    }
  };

  const items = cart?.items || [];
  const itemCount = items.reduce((s: number, i: any) => s + i.quantity, 0);
  const baseCurrency = cart?.base_currency || 'USD';
  const localCurrency = cart?.local_currency || 'KES';
  const conversionRate = cart?.conversion_rate || 0;

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 space-y-4">
      <div className="flex items-center gap-3 mb-2">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface">
          <ChevronLeft size={20} />
        </button>
        <h1 className="font-display text-2xl font-extrabold">Shopping Cart</h1>
        {itemCount > 0 && (
          <Badge variant="green" label={`${itemCount}`} size="sm" />
        )}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : items.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-buddy-text-secondary">
          <ShoppingCart size={48} className="mb-4 opacity-30" />
          <p className="text-lg font-medium mb-1">Your cart is empty</p>
          <p className="text-sm mb-6">Browse the marketplace to add items</p>
          <Button onClick={() => navigate('/marketplace')} variant="primary">Browse Marketplace</Button>
        </div>
      ) : (
        <>
          <div className="space-y-3">
            {items.map((item: any) => {
              const Icon = itemIcons[item.item_type] || ShoppingCart;
              const img = getItemImage(item);
              const itemTotal = item.item_total_artifacts;
              const itemUsd = item.item_total_usd;
              const totalStr = itemTotal ? artifactDisplay(itemTotal) : null;
              return (
                <Card key={item.id} className="p-3">
                  <div className="flex gap-3">
                    <div className="w-16 h-16 bg-buddy-surface rounded-xl flex items-center justify-center flex-shrink-0 overflow-hidden">
                      {img ? (
                        <img src={img} alt="" className="w-full h-full object-cover" />
                      ) : (
                        <Icon size={24} className="text-buddy-text-secondary/30" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <p className="text-sm font-medium truncate">{getItemName(item)}</p>
                          <Badge variant="blue" label={item.item_type.replace('_', ' ')} size="sm" />
                        </div>
                        <button onClick={() => handleRemove(item.id)} className="p-1 text-buddy-red/60 hover:text-buddy-red transition-colors flex-shrink-0">
                          <Trash2 size={14} />
                        </button>
                      </div>
                      {totalStr && (
                        <p className="text-xs font-medium text-buddy-green mt-1">{totalStr}</p>
                      )}
                      {itemUsd != null && itemUsd > 0 && (
                        <p className="text-xs text-buddy-text-secondary mt-0.5">
                          ~{baseCurrency} {itemUsd.toFixed(2)}
                          {conversionRate > 0 && (
                            <span className="ml-1">(~{localCurrency} {(itemUsd * conversionRate).toFixed(2)})</span>
                          )}
                        </p>
                      )}
                      <div className="flex items-center gap-2 mt-2">
                        <div className="flex items-center border border-buddy-surface-raised rounded-lg">
                          <button
                            onClick={() => handleQuantity(item, -1)}
                            className="p-1.5 hover:bg-buddy-surface transition-colors rounded-l-lg"
                          >
                            <Minus size={12} />
                          </button>
                          <span className="px-3 text-xs font-medium min-w-[24px] text-center">{item.quantity}</span>
                          <button
                            onClick={() => handleQuantity(item, 1)}
                            className="p-1.5 hover:bg-buddy-surface transition-colors rounded-r-lg"
                          >
                            <Plus size={12} />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>

          {/* Totals Summary */}
          {cart.total_artifacts && Object.keys(cart.total_artifacts).length > 0 && (
            <Card className="p-4 space-y-2">
              <h3 className="text-sm font-semibold flex items-center gap-2"><Coins size={14} className="text-buddy-green" /> Cart Summary</h3>
              <div className="text-xs space-y-1">
                {Object.entries(cart.total_artifacts as Record<string, number>)
                  .filter(([, v]) => v > 0)
                  .map(([k, v]) => (
                    <div key={k} className="flex justify-between">
                      <span className="capitalize text-buddy-text-secondary">{k}</span>
                      <span className="font-medium">{v}</span>
                    </div>
                  ))}
              </div>
              <div className="border-t border-buddy-surface-raised pt-2 mt-2 space-y-1">
                <div className="flex justify-between text-sm">
                  <span className="flex items-center gap-1"><DollarSign size={12} /> Total ({baseCurrency})</span>
                  <span className="font-semibold">{baseCurrency} {cart.total_usd?.toFixed(2)}</span>
                </div>
                {conversionRate > 0 && (
                  <div className="flex justify-between text-sm">
                    <span className="flex items-center gap-1 text-buddy-text-secondary">{localCurrency} Equivalent</span>
                    <span className="font-semibold">{localCurrency} {cart.total_local_currency?.toFixed(2)}</span>
                  </div>
                )}
              </div>
            </Card>
          )}

          <div className="bg-buddy-surface rounded-xl p-4 space-y-3">
            <h3 className="text-sm font-semibold flex items-center gap-2"><Percent size={14} className="text-buddy-green" /> Discount Code</h3>
            <div className="flex gap-2">
              <div className="flex-1 relative">
                <Tag size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
                <input
                  type="text"
                  placeholder="Enter code"
                  className="w-full bg-buddy-background rounded-lg pl-9 pr-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green"
                  value={discountCode}
                  onChange={(e) => { setDiscountCode(e.target.value); setDiscountMsg(''); }}
                  onKeyDown={(e) => e.key === 'Enter' && applyDiscount()}
                />
              </div>
              <Button variant="secondary" size="sm" onClick={applyDiscount} disabled={applyingDiscount || !discountCode.trim()}>
                {applyingDiscount ? '...' : 'Apply'}
              </Button>
            </div>
            {cart.discount_code && (
              <div className="flex items-center justify-between bg-buddy-green/10 rounded-lg px-3 py-2">
                <span className="text-xs font-medium text-buddy-green">
                  {cart.discount_code.code}
                  {cart.discount_code.discount_type === 'percentage' && cart.discount_code.discount_pct > 0
                    ? ` — ${cart.discount_code.discount_pct}% off`
                    : cart.discount_code.discount_type === 'fixed_artifacts'
                      ? ' — Fixed artifact discount'
                      : ''}
                </span>
              </div>
            )}
            {discountMsg && (
              <p className="text-xs text-buddy-red">{discountMsg}</p>
            )}
          </div>

          {shortfall && (
            <div role="alert" className="rounded-xl bg-buddy-red/10 border border-buddy-red/30 px-4 py-2.5 text-xs text-buddy-red">
              Not enough {shortfall[0]} — this cart needs {shortfall[1]}, you have {balanceFor(shortfall[0])}. Top up in Wallet to check out.
            </div>
          )}

          <Button className="w-full" size="lg" onClick={() => navigate('/marketplace/checkout')} disabled={items.length === 0}>
            Review & Checkout {itemCount > 0 && `(${itemCount} item${itemCount > 1 ? 's' : ''})`}
          </Button>
        </>
      )}
    </div>
  );
}
