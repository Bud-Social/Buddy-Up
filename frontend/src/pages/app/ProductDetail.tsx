import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, ExternalLink, Pill } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { ProductMP } from '@/api/marketplace';

export default function ProductDetail() {
  const { productId } = useParams<{ productId: string }>();
  const navigate = useNavigate();
  const [product, setProduct] = useState<ProductMP | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!productId) return;
    setLoading(true);
    marketplaceApi.getProduct(productId)
      .then((res) => setProduct(res.data))
      .catch(() => navigate('/marketplace'))
      .finally(() => setLoading(false));
  }, [productId, navigate]);

  const handleClick = () => {
    if (!productId || !product) return;
    marketplaceApi.clickProduct(productId);
    if (product.affiliate_url) {
      window.open(product.affiliate_url, '_blank', 'noopener,noreferrer');
    }
  };

  if (loading) {
    return (
      <div className="max-w-lg mx-auto p-4">
        <div className="flex items-center gap-3 mb-6"><button className="p-2"><ArrowLeft size={20} /></button><div className="h-7 w-40 bg-buddy-surface rounded animate-pulse" /></div>
        <Card className="p-4 animate-pulse"><div className="aspect-square bg-buddy-surface-raised rounded-xl mb-4" /><div className="h-5 w-2/3 bg-buddy-surface-raised rounded mb-2" /><div className="h-4 w-1/2 bg-buddy-surface-raised rounded" /></Card>
      </div>
    );
  }

  if (!product) return null;

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl hover:bg-buddy-surface"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold truncate">{product.name}</h1>
      </div>

      <Card className="p-4 space-y-4">
        <div className="aspect-square bg-buddy-surface rounded-xl flex items-center justify-center text-3xl overflow-hidden">
          {product.image_url ? (
            <img src={product.image_url} alt={product.name} className="w-full h-full object-cover" />
          ) : (
            <Pill size={48} className="text-buddy-text-secondary/30" />
          )}
        </div>

        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-buddy-text-secondary">{product.brand}</p>
            <Badge variant="blue" label={product.category} size="sm" />
          </div>
          {product.price_display && <span className="text-lg font-coin font-bold text-buddy-green">{product.price_display}</span>}
        </div>

        <p className="text-sm text-buddy-text-secondary">{product.description}</p>

        {product.recommender_data && (
          <p className="text-xs text-buddy-electric">Recommended by {product.recommender_data.display_name}</p>
        )}

        <p className="text-xs text-buddy-text-secondary">{product.click_count} clicks</p>

        {product.affiliate_url && (
          <Button className="w-full" onClick={handleClick}>
            <ExternalLink size={16} className="mr-2" /> View on Store
          </Button>
        )}
      </Card>
    </div>
  );
}
