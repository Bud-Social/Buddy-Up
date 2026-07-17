import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { marketplaceApi } from '@/api/marketplace';

export default function CartPage() {
  const navigate = useNavigate();
  const [cart, setCart] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [discountCode, setDiscountCode] = useState('');

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
    fetchCart();
  };

  const handleCheckout = async () => {
    try {
      await marketplaceApi.checkoutCart();
      alert('Checkout successful!');
      fetchCart();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Checkout failed');
    }
  };

  const applyDiscount = async () => {
    try {
      await marketplaceApi.applyDiscount(discountCode);
      fetchCart();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Invalid code');
    }
  };

  return (
    <div className="max-w-lg mx-auto p-4 space-y-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold">Shopping Cart</h1>
      </div>
      
      {isLoading ? (
        <div className="p-4 text-center">Loading...</div>
      ) : !cart || !cart.items || cart.items.length === 0 ? (
        <div className="text-center py-20 text-buddy-text-secondary">Your cart is empty.</div>
      ) : (
        <>
          <div className="space-y-2">
            {cart.items.map((item: any) => (
              <Card key={item.id} className="p-3 flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium capitalize">{item.item_type.replace('_', ' ')}</p>
                  <p className="text-xs text-buddy-text-secondary">Qty: {item.quantity}</p>
                </div>
                <button onClick={() => handleRemove(item.id)} className="text-xs text-red-500 hover:underline">Remove</button>
              </Card>
            ))}
          </div>

          <div className="pt-4 border-t border-buddy-surface-raised">
            <div className="flex gap-2 mb-4">
              <input
                type="text"
                placeholder="Discount code"
                className="flex-1 bg-buddy-surface rounded-lg px-3 py-2 text-sm outline-none"
                value={discountCode}
                onChange={(e) => setDiscountCode(e.target.value)}
              />
              <Button variant="secondary" onClick={applyDiscount}>Apply</Button>
            </div>
            {cart.discount_code && (
              <p className="text-xs text-buddy-green mb-4">Discount code applied: {cart.discount_code}</p>
            )}
            
            <Button className="w-full" onClick={handleCheckout}>Checkout All Items</Button>
          </div>
        </>
      )}
    </div>
  );
}
