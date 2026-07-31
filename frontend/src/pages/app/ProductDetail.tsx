import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, ExternalLink, ShoppingCart, Star, Clock, Pill, Store, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';
import type { ProductMP } from '@/api/marketplace';

export default function ProductDetail() {
  const { productId } = useParams<{ productId: string }>();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [product, setProduct] = useState<ProductMP | null>(null);
  const [loading, setLoading] = useState(true);
  const [adding, setAdding] = useState(false);

  useEffect(() => {
    if (!productId) return;
    setLoading(true);
    marketplaceApi.getProduct(productId)
      .then((res) => setProduct(res.data))
      .catch(() => navigate('/marketplace'))
      .finally(() => setLoading(false));
  }, [productId, navigate]);

  const handleAddToCart = async () => {
    if (!productId) return;
    setAdding(true);
    try {
      await marketplaceApi.addToCart('product', { product_id: productId }, 1);
      toast('success', 'Added to cart!');
      window.dispatchEvent(new CustomEvent('cart-updated'));
    } catch {
      toast('error', 'Failed to add to cart');
    } finally {
      setAdding(false);
    }
  };

  const handleAffiliateClick = () => {
    if (!productId || !product) return;
    marketplaceApi.clickProduct(productId);
    if (product.affiliate_url) {
      window.open(product.affiliate_url, '_blank', 'noopener,noreferrer');
    }
  };

  if (loading) {
    return (
      <div className="max-w-xl mx-auto p-4 pb-24 animate-pulse">
        <div className="flex items-center gap-3 mb-6"><div className="w-10 h-10 bg-buddy-surface rounded-xl" /><div className="h-8 w-48 bg-buddy-surface rounded" /></div>
        <Card className="p-4"><div className="aspect-square bg-buddy-surface-raised rounded-xl mb-4" /><div className="h-6 w-2/3 bg-buddy-surface-raised rounded mb-3" /><div className="h-4 w-1/2 bg-buddy-surface-raised rounded" /></Card>
      </div>
    );
  }

  if (!product) return null;

  return (
    <div className="max-w-xl mx-auto p-4 pb-24">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate tracking-tight">{product.name}</h1>
      </div>

      <Card className="p-0 overflow-hidden mb-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
        <div className="aspect-square bg-white relative flex items-center justify-center overflow-hidden">
          {product.image_url ? (
            <img src={product.image_url} alt={product.name} className="w-full h-full object-contain p-8" />
          ) : (
            <Pill size={80} className="text-gray-200" />
          )}
          
          <div className="absolute top-4 right-4 flex flex-col gap-2 items-end">
            <Badge variant="blue" label={product.category.charAt(0).toUpperCase() + product.category.slice(1)} size="sm" className="shadow-lg" />
          </div>
        </div>

        <div className="p-6 space-y-5">
          <div className="flex items-start justify-between gap-3 border-b border-buddy-surface-raised pb-4">
            <div className="flex-1 min-w-0">
              <h2 className="text-2xl font-bold truncate leading-tight">{product.name}</h2>
              <p className="text-base text-buddy-text-secondary font-medium mt-1">{product.brand}</p>
            </div>
          </div>
          
          {product.shop_data && (
            <div className="flex items-center gap-3 bg-buddy-surface rounded-xl p-4 border border-buddy-surface-raised cursor-pointer hover:border-buddy-electric transition-colors" onClick={() => navigate(`/shops/${product.shop_data?.handle}`)}>
              <div className="w-10 h-10 rounded-full bg-buddy-electric/10 flex items-center justify-center text-buddy-electric">
                <Store size={20} />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-1">
                  <p className="font-bold text-sm">{product.shop_data.name}</p>
                  {product.shop_data.verification_status === 'verified' && <ShieldCheck size={14} className="text-buddy-electric" />}
                </div>
                <p className="text-xs text-buddy-text-secondary">Host Shop</p>
              </div>
              <ArrowLeft size={16} className="text-buddy-text-secondary rotate-180" />
            </div>
          )}

          {product.price_display && (
            <div className="bg-buddy-green/10 rounded-xl px-5 py-4 flex items-center justify-between border border-buddy-green/20">
              <span className="text-sm font-bold text-buddy-green uppercase tracking-wider">Estimated Price</span>
              <span className="text-2xl font-bold text-buddy-green">{product.price_display}</span>
            </div>
          )}

          <div>
            <h3 className="font-bold text-lg mb-2">Description</h3>
            <p className="text-sm text-buddy-text-secondary leading-relaxed whitespace-pre-wrap">{product.description || 'No description available.'}</p>
          </div>

          {product.recommender_data && (
            <div className="flex items-center gap-3 bg-buddy-gold/10 border border-buddy-gold/20 rounded-xl p-4">
              <Star size={20} className="text-buddy-gold fill-buddy-gold" />
              <div className="text-sm">
                <span className="text-buddy-text-secondary">Recommended by </span>
                <span className="text-buddy-text-primary font-bold">{product.recommender_data.display_name}</span>
              </div>
            </div>
          )}

          <div className="flex items-center gap-4 text-xs font-semibold text-buddy-text-secondary border-t border-buddy-surface-raised pt-4">
            <span className="flex items-center gap-1"><Clock size={14} /> Listed {new Date(product.created_at).toLocaleDateString()}</span>
            <span className="flex items-center gap-1"><ExternalLink size={14} /> {product.click_count} clicks</span>
          </div>
        </div>
      </Card>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
        <div className="w-full max-w-xl flex gap-3">
          <Button className="flex-1 h-12 shadow-[0_0_15px_rgba(23,248,154,0.3)] bg-buddy-green text-buddy-black font-bold text-base hover:bg-buddy-green/90" onClick={handleAddToCart} isLoading={adding} disabled={adding}>
            <ShoppingCart size={18} className="mr-2" /> Add to Cart
          </Button>
          {product.affiliate_url && (
            <Button variant="outline" className="flex-shrink-0 h-12 px-6 border-buddy-electric text-buddy-electric hover:bg-buddy-electric/10" onClick={handleAffiliateClick}>
              <ExternalLink size={18} className="mr-2" /> Buy from Vendor
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
