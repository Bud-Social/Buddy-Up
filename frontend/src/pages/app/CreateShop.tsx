import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { marketplaceApi } from '@/api/marketplace';
import { useAuthStore } from '@/store/authStore';

export default function CreateShop() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);
  const [step, setStep] = useState(1);
  const totalSteps = 5;
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    handle: '',
    description: '',
    category: 'fitness',
    accent_color: '#8A2BE2',
    contact_email: user?.email || '',
    contact_phone: '',
    website_url: '',
    social_links: '',
    refund_policy: '',
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [bannerFile, setBannerFile] = useState<File | null>(null);

  const [logoPreview, setLogoPreview] = useState<string>('');
  const [bannerPreview, setBannerPreview] = useState<string>('');

  const handleNext = () => setStep(s => Math.min(s + 1, totalSteps));
  const handlePrev = () => setStep(s => Math.max(s - 1, 1));

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, type: 'logo' | 'banner') => {
    const file = e.target.files?.[0];
    if (file) {
      if (type === 'logo') {
        setLogoFile(file);
        setLogoPreview(URL.createObjectURL(file));
      } else {
        setBannerFile(file);
        setBannerPreview(URL.createObjectURL(file));
      }
    }
  };

  const handleSubmit = async () => {
    setIsSubmitting(true);
    setError(null);
    try {
      const data = new FormData();
      Object.entries(formData).forEach(([key, value]) => {
        data.append(key, value);
      });
      if (logoFile) data.append('logo', logoFile);
      if (bannerFile) data.append('banner', bannerFile);

      // Cast as any since our API type currently says Record<string, unknown> but we're passing FormData
      const res = await marketplaceApi.createShop(data as any);
      if (res.success) {
        navigate('/marketplace/my-services');
      } else {
        setError(res.message || 'Failed to create shop');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'An error occurred.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-md lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24 space-y-6">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold flex-1">Create Shop</h1>
        <span className="text-sm font-bold text-buddy-text-secondary">{step}/{totalSteps}</span>
      </div>

      <div className="w-full bg-buddy-surface-raised h-2 rounded-full overflow-hidden">
        <div className="bg-buddy-electric h-full transition-all" style={{ width: `${(step / totalSteps) * 100}%` }} />
      </div>

      {error && (
        <div className="p-3 bg-red-500/10 border border-red-500/20 rounded-xl text-red-500 text-sm">
          {error}
        </div>
      )}

      <Card className="p-4 space-y-4">
        {step === 1 && (
          <div className="space-y-4">
            <h2 className="text-lg font-bold">1. Identity</h2>
            <p className="text-sm text-buddy-text-secondary">What's the name and handle of your shop?</p>
            <Input label="Shop Name" placeholder="e.g. FitGear Pro" value={formData.name} onChange={(e: any) => setFormData({...formData, name: e.target.value})} />
            <Input label="Handle" placeholder="e.g. fitgearpro" value={formData.handle} onChange={(e: any) => setFormData({...formData, handle: e.target.value.toLowerCase().replace(/\s+/g, '')})} />
            
            <div className="space-y-1">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Category</label>
              <select 
                className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-3 text-sm focus:outline-none focus:border-buddy-electric"
                value={formData.category}
                onChange={(e) => setFormData({...formData, category: e.target.value})}
              >
                <option value="fitness">Fitness</option>
                <option value="nutrition">Nutrition</option>
                <option value="apparel">Apparel</option>
                <option value="mixed">Mixed</option>
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Description</label>
              <textarea 
                className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-3 text-sm focus:outline-none focus:border-buddy-electric focus:ring-1 focus:ring-buddy-electric transition-all"
                rows={3}
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
              />
            </div>
          </div>
        )}
        {step === 2 && (
          <div className="space-y-4">
            <h2 className="text-lg font-bold">2. Branding</h2>
            <p className="text-sm text-buddy-text-secondary">Upload your logo and banner to stand out.</p>
            
            <div className="space-y-2">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Shop Logo</label>
              <div 
                className="relative flex items-center justify-center w-full h-32 border-2 border-dashed border-buddy-surface-raised rounded-xl overflow-hidden bg-buddy-surface cursor-pointer hover:bg-buddy-surface-raised transition-colors"
                onClick={() => document.getElementById('logo-upload')?.click()}
              >
                {logoPreview ? (
                  <img src={logoPreview} alt="Logo" className="w-full h-full object-contain p-2" />
                ) : (
                  <span className="text-xs text-buddy-text-secondary">Click to upload logo</span>
                )}
                <input id="logo-upload" type="file" className="hidden" accept="image/*" onChange={(e) => handleFileChange(e, 'logo')} />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Shop Banner</label>
              <div 
                className="relative flex items-center justify-center w-full h-40 border-2 border-dashed border-buddy-surface-raised rounded-xl overflow-hidden bg-buddy-surface cursor-pointer hover:bg-buddy-surface-raised transition-colors"
                onClick={() => document.getElementById('banner-upload')?.click()}
              >
                {bannerPreview ? (
                  <img src={bannerPreview} alt="Banner" className="w-full h-full object-cover" />
                ) : (
                  <span className="text-xs text-buddy-text-secondary">Click to upload banner</span>
                )}
                <input id="banner-upload" type="file" className="hidden" accept="image/*" onChange={(e) => handleFileChange(e, 'banner')} />
              </div>
            </div>

            <div className="flex gap-4 items-center pt-2">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Accent Color</label>
              <input 
                type="color" 
                value={formData.accent_color}
                onChange={(e) => setFormData({...formData, accent_color: e.target.value})}
                className="w-10 h-10 rounded border-0 cursor-pointer bg-transparent"
              />
            </div>
          </div>
        )}
        {step === 3 && (
          <div className="space-y-4">
            <h2 className="text-lg font-bold">3. Contact</h2>
            <p className="text-sm text-buddy-text-secondary">How can customers reach you?</p>
            <Input type="email" label="Contact Email" placeholder="support@shop.com" value={formData.contact_email} onChange={(e: any) => setFormData({...formData, contact_email: e.target.value})} />
            <Input type="tel" label="Contact Phone" placeholder="+1234567890" value={formData.contact_phone} onChange={(e: any) => setFormData({...formData, contact_phone: e.target.value})} />
          </div>
        )}
        {step === 4 && (
          <div className="space-y-4">
            <h2 className="text-lg font-bold">4. Links & Policies</h2>
            <p className="text-sm text-buddy-text-secondary">Add your website, socials, and policies.</p>
            <Input label="Website URL (Optional)" placeholder="https://" value={formData.website_url} onChange={(e: any) => setFormData({...formData, website_url: e.target.value})} />
            
            <div className="space-y-1">
              <label className="text-xs font-bold text-buddy-text-secondary uppercase">Refund Policy</label>
              <textarea 
                className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-3 text-sm focus:outline-none focus:border-buddy-electric"
                rows={4}
                placeholder="E.g., No refunds on digital products..."
                value={formData.refund_policy}
                onChange={(e) => setFormData({...formData, refund_policy: e.target.value})}
              />
            </div>
          </div>
        )}
        {step === 5 && (
          <div className="space-y-4">
            <h2 className="text-lg font-bold">5. Review</h2>
            <p className="text-sm text-buddy-text-secondary">Review your shop details before creating.</p>
            <div className="p-4 bg-buddy-surface rounded-xl space-y-3 text-sm">
              <div className="flex gap-4 items-center">
                <div className="w-16 h-16 rounded-full bg-buddy-surface-raised overflow-hidden">
                  {logoPreview && <img src={logoPreview} className="w-full h-full object-cover" />}
                </div>
                <div>
                  <p className="font-bold text-lg">{formData.name || 'Shop Name'}</p>
                  <p className="text-buddy-text-secondary">@{formData.handle || 'handle'}</p>
                </div>
              </div>
              <hr className="border-buddy-surface-raised" />
              <p><strong>Category:</strong> {formData.category}</p>
              <p><strong>Email:</strong> {formData.contact_email || 'N/A'}</p>
            </div>
          </div>
        )}
      </Card>

      <div className="flex gap-3">
        {step > 1 && (
          <Button variant="outline" className="flex-1" onClick={handlePrev} disabled={isSubmitting}>Back</Button>
        )}
        {step < totalSteps ? (
          <Button className="flex-1" onClick={handleNext}>Next</Button>
        ) : (
          <Button className="flex-1" onClick={handleSubmit} disabled={isSubmitting || !formData.name || !formData.handle}>
            {isSubmitting ? 'Creating...' : 'Create Shop'}
          </Button>
        )}
      </div>
    </div>
  );
}
