import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, ShoppingBag } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { marketplaceApi } from '@/api/marketplace';

const CATEGORIES = ['supplement', 'equipment', 'gear'];

export default function CreateProduct() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [form, setForm] = useState({
    name: '',
    brand: '',
    description: '',
    category: 'supplement',
    image_url: '',
    affiliate_url: '',
    price_display: '',
  });
  const [submitting, setSubmitting] = useState(false);

  const canProceedToStep2 = form.name.trim().length > 0 && form.brand.trim().length > 0;
  const canProceedToStep3 = form.affiliate_url.trim().length > 0;

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      await marketplaceApi.createProduct({
        name: form.name,
        brand: form.brand,
        description: form.description,
        category: form.category,
        image_url: form.image_url || undefined,
        affiliate_url: form.affiliate_url,
        price_display: form.price_display || undefined,
      });
      navigate('/marketplace');
    } catch {
      /* ignore */
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/marketplace')} className="p-2 rounded-xl hover:bg-buddy-surface"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold">Recommend Product</h1>
      </div>

      <div className="flex gap-2 mb-6">
        {[1, 2, 3].map((value) => (
          <div key={value} className={`flex-1 h-1 rounded-full ${value <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
        ))}
      </div>

      <div className="space-y-6">
        {step === 1 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Product Name</label>
              <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="e.g. Whey Protein Isolate" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Brand</label>
              <Input value={form.brand} onChange={(e) => setForm({ ...form, brand: e.target.value })} placeholder="e.g. Optimum Nutrition" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Category</label>
              <select
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
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
            <Button className="w-full" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
              Next: Add Details
            </Button>
          </Card>
        )}

        {step === 2 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Description</label>
              <textarea
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green resize-none"
                rows={4}
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                placeholder="Why recommend this product?"
              />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Image URL</label>
              <Input value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })} placeholder="https://..." />
              {form.image_url && (
                <div className="mt-4 overflow-hidden rounded-xl border border-buddy-surface">
                  <img src={form.image_url} alt="Product preview" className="w-full h-48 object-cover" />
                </div>
              )}
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Affiliate URL</label>
              <Input value={form.affiliate_url} onChange={(e) => setForm({ ...form, affiliate_url: e.target.value })} placeholder="https://..." />
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(1)}>
                Back
              </Button>
              <Button className="flex-1" onClick={() => setStep(3)} disabled={!canProceedToStep3}>
                Next: Review
              </Button>
            </div>
          </Card>
        )}

        {step === 3 && (
          <Card className="p-5 space-y-4">
            <div>
              <h2 className="text-lg font-semibold">Review your product recommendation</h2>
              <p className="text-sm text-buddy-text-secondary">Confirm the details before sharing with the community.</p>
            </div>
            <div className="rounded-2xl border border-buddy-surface p-4 space-y-3">
              {form.image_url && (
                <img src={form.image_url} alt="Product preview" className="w-full h-48 object-cover rounded-xl" />
              )}
              <div>
                <p className="text-sm font-semibold">{form.name}</p>
                <p className="text-xs text-buddy-text-secondary">{form.brand}</p>
              </div>
              <p className="text-sm text-buddy-text-secondary">{form.description || 'No description provided.'}</p>
              <div className="grid grid-cols-2 gap-2 text-xs text-buddy-text-secondary">
                <div>
                  <span className="font-semibold">Category:</span> {form.category}
                </div>
                <div>
                  <span className="font-semibold">Price:</span> {form.price_display || 'Not set'}
                </div>
                <div className="col-span-2 break-all">
                  <span className="font-semibold">Affiliate link:</span> {form.affiliate_url}
                </div>
              </div>
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(2)}>
                Back
              </Button>
              <Button className="flex-1" onClick={handleSubmit} isLoading={submitting} disabled={submitting || !form.name || !form.brand || !form.affiliate_url}>
                Publish Product
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
