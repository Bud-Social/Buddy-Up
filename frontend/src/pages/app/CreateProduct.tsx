import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Tag, Link as LinkIcon, DollarSign } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { ImageUploadField } from '@/components/ui/ImageUploadField';
import { marketplaceApi } from '@/api/marketplace';

const CATEGORIES = ['supplement', 'equipment', 'gear'];

export default function CreateProduct() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const editId = searchParams.get('edit');
  const isEditing = Boolean(editId);
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(isEditing);
  const [myShops, setMyShops] = useState<any[]>([]);
  const [form, setForm] = useState({
    shop_id: '',
    name: '',
    brand: '',
    description: '',
    category: 'supplement',
    image_url: '',
    affiliate_url: '',
    price_display: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    marketplaceApi.getMyShops().then(res => {
      const shops = res.data || [];
      setMyShops(shops);
      if (shops.length > 0) setForm(f => ({ ...f, shop_id: shops[0].id }));
    });
  }, []);

  useEffect(() => {
    if (!editId) return;
    marketplaceApi.getProduct(editId)
      .then((res) => {
        const p = res.data;
        setForm({
          shop_id: p.shop_data?.id || '',
          name: p.name,
          brand: p.brand || '',
          description: p.description || '',
          category: p.category || 'supplement',
          image_url: p.image_url || '',
          affiliate_url: p.affiliate_url || '',
          price_display: p.price_display || '',
        });
        setIsLoading(false);
      })
      .catch(() => { setIsLoading(false); navigate('/marketplace/creator'); });
  }, [editId]);

  const canProceedToStep2 = form.name.trim().length > 0 && form.brand.trim().length > 0 && form.image_url;
  const canProceedToStep3 = form.affiliate_url.trim().length > 0;

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const payload = {
        shop_id: form.shop_id || undefined,
        name: form.name,
        brand: form.brand,
        description: form.description,
        category: form.category,
        image_url: form.image_url || undefined,
        affiliate_url: form.affiliate_url,
        price_display: form.price_display || undefined,
      };
      if (isEditing && editId) {
        await marketplaceApi.updateProduct(editId, payload);
        navigate('/marketplace/creator');
      } else {
        await marketplaceApi.createProduct(payload);
        navigate('/marketplace');
      }
    } catch {
      /* ignore */
    } finally {
      setSubmitting(false);
    }
  };

  if (isLoading) return <div className="p-4 text-center">Loading product...</div>;

  return (
    <div className="max-w-xl mx-auto p-4 pb-20">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(isEditing ? '/marketplace/creator' : '/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold tracking-tight">{isEditing ? 'Edit Product' : 'Recommend Product'}</h1>
      </div>

      <div className="flex gap-2 mb-8 px-2">
        {['Basics', 'Links & Pricing', 'Review'].map((label, idx) => (
          <div key={idx} className="flex-1 flex flex-col gap-1.5">
            <div className={`h-1.5 rounded-full transition-colors ${idx + 1 <= step ? 'bg-buddy-green shadow-[0_0_8px_rgba(23,248,154,0.4)]' : 'bg-buddy-surface-raised'}`} />
            <span className={`text-[10px] font-semibold text-center uppercase tracking-wider ${idx + 1 <= step ? 'text-buddy-green' : 'text-buddy-text-secondary'}`}>{label}</span>
          </div>
        ))}
      </div>

      <div className="space-y-6">
        {step === 1 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold flex items-center gap-2"><Tag className="text-buddy-green" size={24} /> Product Basics</h2>
                <p className="text-sm text-buddy-text-secondary">What product are you recommending to the community?</p>
              </div>

              {myShops.length > 0 && (
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Recommend as Shop</label>
                  <select
                    className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-green transition-colors"
                    value={form.shop_id}
                    onChange={(e) => setForm({ ...form, shop_id: e.target.value })}
                  >
                    {myShops.map((shop) => (
                      <option key={shop.id} value={shop.id}>{shop.name}</option>
                    ))}
                  </select>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Product Name</label>
                  <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="e.g. Whey Protein Isolate" className="bg-buddy-black" />
                </div>
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Brand</label>
                  <Input value={form.brand} onChange={(e) => setForm({ ...form, brand: e.target.value })} placeholder="e.g. Optimum Nutrition" className="bg-buddy-black" />
                </div>
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Category</label>
                <select
                  className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-green transition-colors"
                  value={form.category}
                  onChange={(e) => setForm({ ...form, category: e.target.value })}
                >
                  {CATEGORIES.map((c) => (
                    <option key={c} value={c}>
                      {c.charAt(0).toUpperCase() + c.slice(1)}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Description</label>
                <textarea
                  className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-green transition-colors resize-none"
                  rows={4}
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  placeholder="Why do you recommend this product? What are its benefits?"
                />
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Product Image</label>
                <div className="bg-buddy-black rounded-xl p-2 border border-buddy-surface-raised">
                  <ImageUploadField
                    value={form.image_url}
                    onChange={(url) => setForm({ ...form, image_url: url })}
                    label="Upload a clear image of the product"
                  />
                </div>
              </div>

              <Button className="w-full h-12 text-base font-bold shadow-lg bg-buddy-green text-buddy-black hover:bg-buddy-green/90" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
                Next: Links & Pricing
              </Button>
            </Card>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <LinkIcon className="text-buddy-electric" size={24} />
                  <h2 className="text-xl font-bold">Links & Pricing</h2>
                </div>
                <p className="text-sm text-buddy-text-secondary">Provide an affiliate link where users can buy the product.</p>
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Affiliate URL</label>
                <Input type="url" value={form.affiliate_url} onChange={(e) => setForm({ ...form, affiliate_url: e.target.value })} placeholder="https://your-affiliate-link.com" className="bg-buddy-black focus:border-buddy-electric" />
                <p className="text-xs text-buddy-text-secondary mt-1 flex items-center gap-1">Make sure this link tracks your referrals!</p>
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block flex items-center gap-1"><DollarSign size={16} className="text-buddy-gold" /> Price Display (Optional)</label>
                <Input value={form.price_display} onChange={(e) => setForm({ ...form, price_display: e.target.value })} placeholder="e.g. $29.99 or Approx. KES 3500" className="bg-buddy-black" />
                <p className="text-xs text-buddy-text-secondary mt-1 flex items-center gap-1">Give users an idea of how much it costs.</p>
              </div>

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(1)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90" onClick={() => setStep(3)} disabled={!canProceedToStep3}>Next: Review</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">Review Product</h2>
                <p className="text-sm text-buddy-text-secondary">Confirm the details before sharing with the community.</p>
              </div>
              
              <div className="rounded-2xl border border-buddy-surface p-1 shadow-lg bg-buddy-black">
                {form.image_url && (
                  <img src={form.image_url} alt="Product preview" className="w-full h-48 object-contain bg-white rounded-xl mb-3" />
                )}
                <div className="p-3">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-base font-bold">{form.name}</p>
                      <p className="text-xs text-buddy-text-secondary font-medium">{form.brand}</p>
                      <Badge variant="electric" label={form.category.charAt(0).toUpperCase() + form.category.slice(1)} size="sm" className="mt-2" />
                    </div>
                    <div className="text-right">
                      {form.price_display && <p className="text-sm font-bold text-buddy-gold">{form.price_display}</p>}
                    </div>
                  </div>
                  
                  <div className="mt-4 p-3 bg-buddy-surface rounded-xl text-xs text-buddy-text-secondary break-all">
                    <span className="font-semibold text-buddy-electric">Affiliate Link:</span><br />
                    {form.affiliate_url}
                  </div>
                </div>
              </div>

              <div className="flex gap-3 pt-4 border-t border-buddy-surface-raised">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(2)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-gradient-to-r from-buddy-green to-emerald-400 text-buddy-black font-bold" onClick={handleSubmit} isLoading={submitting}>
                  {isEditing ? 'Save Changes' : 'Publish Product'}
                </Button>
              </div>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
