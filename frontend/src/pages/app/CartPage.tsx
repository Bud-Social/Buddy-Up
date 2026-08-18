import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShoppingCart, Trash2, Minus, Plus, Tag, ChevronLeft, Utensils, Dumbbell, Pill, Calendar, Percent, Coins, DollarSign, CheckCircle2, X, Truck, Store, MapPin } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';

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

export default function CartPage() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [cart, setCart] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [checkingOut, setCheckingOut] = useState(false);
  const [discountCode, setDiscountCode] = useState('');
  const [applyingDiscount, setApplyingDiscount] = useState(false);
  const [discountMsg, setDiscountMsg] = useState('');
  const [showConfirm, setShowConfirm] = useState(false);
  const [receipt, setReceipt] = useState<any>(null);
  const [fulfillmentType, setFulfillmentType] = useState('digital');
  const [deliveryLine, setDeliveryLine] = useState('');
  const [deliveryCity, setDeliveryCity] = useState('');
  const [deliveryCountry, setDeliveryCountry] = useState('');
  const [deliveryPhone, setDeliveryPhone] = useState('');
  const [pickupLocation, setPickupLocation] = useState('');
  const [pickupInstructions, setPickupInstructions] = useState('');

  const fetchCart = useCallback(() => {
    setIsLoading(true);
    marketplaceApi.getCart()
      .then((res) => setCart(res.data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  useEffect(() => { fetchCart(); }, [fetchCart]);

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

  const handleCheckout = async () => {
    setCheckingOut(true);
    try {
      const payload: Record<string, unknown> = { fulfillment_type: fulfillmentType };
      if (fulfillmentType === 'delivery') {
        payload.delivery_address = { line1: deliveryLine, city: deliveryCity, country: deliveryCountry, phone: deliveryPhone };
      } else if (fulfillmentType === 'pickup') {
        payload.pickup_details = { location: pickupLocation, instructions: pickupInstructions };
      }
      const res = await marketplaceApi.checkoutCart(payload);
      toast('success', 'Checkout successful! Items have been purchased.');
      setCart({ ...cart, items: [] });
      setShowConfirm(false);
      setReceipt(res.data || {});
      window.dispatchEvent(new CustomEvent('cart-updated'));
    } catch (err: any) {
      toast('error', err.response?.data?.message || 'Checkout failed');
      setShowConfirm(false);
    } finally {
      setCheckingOut(false);
    }
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

          <Button className="w-full" size="lg" onClick={() => setShowConfirm(true)} disabled={items.length === 0}>
            Review & Checkout {itemCount > 0 && `(${itemCount} item${itemCount > 1 ? 's' : ''})`}
          </Button>
        </>
      )}

      {receipt && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-4">
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl border border-buddy-surface-raised shadow-2xl max-h-[90vh] overflow-y-auto">
            <div className="p-5 border-b border-buddy-surface-raised flex items-center justify-between">
              <h2 className="font-display text-lg font-extrabold">Order Receipt</h2>
              <button onClick={() => setReceipt(null)} className="p-2 rounded-lg hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary"><X size={16} /></button>
            </div>
            <div className="p-5 space-y-4">
              <div className="flex flex-col items-center gap-2 py-2">
                <CheckCircle2 size={44} className="text-buddy-green" />
                <p className="font-semibold text-sm">Payment Successful</p>
                <p className="text-xs text-buddy-text-secondary">Order #{receipt.order_number || receipt.order_id?.slice(0, 8).toUpperCase()}</p>
              </div>

              <div className="space-y-2">
                {(receipt.items || []).map((it: any, i: number) => (
                  <div key={i} className="rounded-xl bg-buddy-surface-raised/50 p-3 text-xs space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="font-semibold truncate">{it.title} × {it.quantity}</span>
                      <span className="text-buddy-text-secondary capitalize">{it.item_type.replace('_', ' ')}</span>
                    </div>
                    {it.paid_artifacts && Object.keys(it.paid_artifacts).length > 0 && (
                      <p className="text-buddy-green font-medium">{artifactDisplay(it.paid_artifacts)}</p>
                    )}
                    {it.creator_name && <p className="text-buddy-text-secondary">to {it.creator_name}</p>}
                  </div>
                ))}
              </div>

              <div className="space-y-1.5 text-sm border-t border-buddy-surface-raised pt-3">
                <div className="flex justify-between text-xs">
                  <span className="text-buddy-text-secondary">Original total</span>
                  <span>{artifactDisplay(receipt.original_artifacts)}</span>
                </div>
                {receipt.savings_artifacts && Object.keys(receipt.savings_artifacts).filter(k => receipt.savings_artifacts[k] > 0).length > 0 && (
                  <div className="flex justify-between text-xs text-buddy-green">
                    <span className="flex items-center gap-1">
                      <Percent size={11} /> Savings
                      {receipt.discount_code && <span className="font-mono">({receipt.discount_code})</span>}
                    </span>
                    <span>-{artifactDisplay(receipt.savings_artifacts)}</span>
                  </div>
                )}
                <div className="flex justify-between text-sm font-bold pt-1 border-t border-buddy-surface-raised">
                  <span>You paid</span>
                  <span className="text-buddy-green">{artifactDisplay(receipt.total_artifacts)}</span>
                </div>
                {receipt.spent_usd != null && (
                  <div className="flex justify-between text-xs text-buddy-text-secondary">
                    <span>Value ({baseCurrency})</span>
                    <span>${receipt.spent_usd.toFixed(2)}</span>
                  </div>
                )}
              </div>

              <Button className="w-full" onClick={() => receipt.order_id ? navigate(`/marketplace/orders/${receipt.order_id}`) : navigate('/marketplace')}>
                View Order Tracking
              </Button>
              <Button variant="ghost" className="w-full" onClick={() => navigate('/marketplace')}>Done</Button>
            </div>
          </div>
        </div>
      )}

      {showConfirm && cart && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end sm:items-center justify-center p-4">
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl border border-buddy-surface-raised shadow-2xl max-h-[90vh] overflow-y-auto">
            <div className="p-5 border-b border-buddy-surface-raised flex items-center justify-between">
              <h2 className="font-display text-lg font-extrabold">Confirm Order</h2>
              <button onClick={() => setShowConfirm(false)} className="p-2 rounded-lg hover:bg-buddy-surface-raised transition-colors text-buddy-text-secondary"><X size={16} /></button>
            </div>
            <div className="p-5 space-y-4">
              <div className="space-y-2">
                {items.map((item: any) => (
                  <div key={item.id} className="flex items-center justify-between text-xs">
                    <span className="truncate pr-2">{getItemName(item)} × {item.quantity}</span>
                    <span className="font-medium flex-shrink-0">
                      {artifactDisplay(item.item_total_artifacts) || (item.item_total_usd ? `$${item.item_total_usd.toFixed(2)}` : '')}
                    </span>
                  </div>
                ))}
              </div>

              <div className="space-y-1.5 text-sm border-t border-buddy-surface-raised pt-3">
                {cart.discount_code && (
                  <div className="flex justify-between text-xs text-buddy-green">
                    <span className="font-mono">{cart.discount_code.code}</span>
                    <span>discount applied at checkout</span>
                  </div>
                )}
                <div className="flex justify-between text-sm font-bold">
                  <span>Total to pay</span>
                  <span className="text-buddy-green">{artifactDisplay(cart.total_artifacts)}</span>
                </div>
                <div className="flex justify-between text-xs text-buddy-text-secondary">
                  <span>{baseCurrency} value</span>
                  <span>${cart.total_usd?.toFixed(2)}{conversionRate > 0 ? ` · ${localCurrency} ${cart.total_local_currency?.toFixed(2)}` : ''}</span>
                </div>
              </div>

              <div className="rounded-xl bg-buddy-gold/10 border border-buddy-gold/20 p-3 text-xs text-buddy-text-secondary">
                Artifacts will be deducted instantly from your wallet. Your purchase unlocks instant access.
              </div>

              {/* Fulfillment method */}
              <div className="space-y-2">
                <p className="text-xs font-semibold flex items-center gap-1.5"><Truck size={13} className="text-buddy-green" /> Delivery method</p>
                <div className="grid grid-cols-3 gap-2">
                  {([
                    { key: 'digital', label: 'Digital', icon: CheckCircle2 },
                    { key: 'pickup', label: 'Pickup', icon: Store },
                    { key: 'delivery', label: 'Delivery', icon: Truck },
                  ] as const).map(({ key, label, icon: Icon }) => (
                    <button
                      key={key}
                      onClick={() => setFulfillmentType(key)}
                      className={`rounded-xl border p-2.5 text-xs font-medium flex flex-col items-center gap-1 transition-colors ${
                        fulfillmentType === key ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-text-secondary/30'
                      }`}
                    >
                      <Icon size={14} />
                      {label}
                    </button>
                  ))}
                </div>

                {fulfillmentType === 'delivery' && (
                  <div className="space-y-2 rounded-xl bg-buddy-surface-raised/40 p-3">
                    <div className="flex items-center gap-1.5 text-xs text-buddy-text-secondary"><MapPin size={11} /> Delivery address</div>
                    <input className="w-full bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="Street address" value={deliveryLine} onChange={(e) => setDeliveryLine(e.target.value)} />
                    <div className="grid grid-cols-2 gap-2">
                      <input className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="City" value={deliveryCity} onChange={(e) => setDeliveryCity(e.target.value)} />
                      <input className="bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="Country" value={deliveryCountry} onChange={(e) => setDeliveryCountry(e.target.value)} />
                    </div>
                    <input className="w-full bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="Phone" value={deliveryPhone} onChange={(e) => setDeliveryPhone(e.target.value)} />
                  </div>
                )}

                {fulfillmentType === 'pickup' && (
                  <div className="space-y-2 rounded-xl bg-buddy-surface-raised/40 p-3">
                    <div className="flex items-center gap-1.5 text-xs text-buddy-text-secondary"><Store size={11} /> Pickup location</div>
                    <input className="w-full bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="Venue / location" value={pickupLocation} onChange={(e) => setPickupLocation(e.target.value)} />
                    <input className="w-full bg-buddy-background rounded-lg px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green" placeholder="Instructions (optional)" value={pickupInstructions} onChange={(e) => setPickupInstructions(e.target.value)} />
                  </div>
                )}
              </div>

              <div className="flex gap-3">
                <Button variant="ghost" className="flex-1" onClick={() => setShowConfirm(false)} disabled={checkingOut}>Cancel</Button>
                <Button className="flex-1" onClick={handleCheckout} isLoading={checkingOut} disabled={checkingOut}>
                  Confirm Payment
                </Button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
