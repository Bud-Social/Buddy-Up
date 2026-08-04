import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { marketplaceApi } from '@/api/marketplace';
import type { DiscountCode } from '@/api/marketplace';

const EMPTY_FORM = {
  code: '',
  discount_type: 'percentage',
  discount_pct: 0,
  discount_artifacts: '{}',
  code_type: 'text',
  description: '',
  campaign: '',
  valid_from: '',
  valid_until: '',
  usage_limit: 0,
  max_uses_per_user: 0,
  min_purchase_artifacts: '{}',
  is_active: true,
};

export default function DiscountCodes() {
  const navigate = useNavigate();
  const [codes, setCodes] = useState<DiscountCode[]>([]);
  const [editing, setEditing] = useState<DiscountCode | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [isLoading, setIsLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const loadCodes = () => {
    marketplaceApi.getDiscountCodes()
      .then((res) => setCodes(res.data || []))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  };

  useEffect(() => { loadCodes(); }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      const payload = {
        ...form,
        discount_pct: Number(form.discount_pct),
        usage_limit: Number(form.usage_limit),
        max_uses_per_user: Number(form.max_uses_per_user),
        discount_artifacts: form.discount_artifacts ? JSON.parse(form.discount_artifacts) : {},
        min_purchase_artifacts: form.min_purchase_artifacts ? JSON.parse(form.min_purchase_artifacts) : {},
        valid_from: form.valid_from || null,
        valid_until: form.valid_until || null,
      };
      if (editing) {
        await marketplaceApi.updateDiscountCode(editing.id, payload);
      } else {
        await marketplaceApi.createDiscountCode(payload);
      }
      setEditing(null);
      setForm(EMPTY_FORM);
      loadCodes();
    } catch (e: any) {
      alert(e.response?.data?.message || 'Failed to save discount code');
    } finally {
      setSaving(false);
    }
  };

  const handleToggle = async (code: DiscountCode) => {
    const suspending = code.is_active && !code.is_expired;
    if (!window.confirm(suspending ? 'Suspend this code? It will stop being usable.' : 'Reactivate this code?')) return;
    try {
      await marketplaceApi.patchDiscountCode(code.id, { action: suspending ? 'suspend' : 'reactivate' });
      loadCodes();
    } catch { }
  };

  const handleDelete = async (codeId: string) => {
    if (!window.confirm('Retire this discount code? It will no longer be usable.')) return;
    try {
      await marketplaceApi.deleteDiscountCode(codeId);
      loadCodes();
    } catch { }
  };

  const handleShare = async (codeId: string) => {
    try {
      const res = await marketplaceApi.shareDiscountCode(codeId);
      const data = res.data;
      if (data.qr_code) {
        const a = document.createElement('a');
        a.href = `data:image/png;base64,${data.qr_code}`;
        a.download = `discount-${data.code}.png`;
        a.click();
      }
      navigator.clipboard.writeText(data.code);
      loadCodes();
    } catch { }
  };

  if (isLoading) return <div className="p-4 text-center">Loading...</div>;

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 space-y-4 pb-20">
      <div className="flex items-center gap-3 mb-2">
        <button onClick={() => navigate('/marketplace/creator')} className="p-2 rounded-full hover:bg-buddy-surface">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="font-display text-2xl font-extrabold flex-1">Discount Codes</h1>
        <Button size="sm" onClick={() => { setEditing(null); setForm(EMPTY_FORM); }}>+ New</Button>
      </div>

      <div className="space-y-3">
        {codes.length === 0 && <p className="text-sm text-buddy-text-secondary">No discount codes yet. Create one to start promoting your services.</p>}
        {codes.map((code) => (
          <Card key={code.id} className="p-3">
            <div className="flex items-start justify-between">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="font-bold text-sm truncate">{code.code}</p>
                  {code.is_expired && <Badge variant="red" label="Expired" size="sm" />}
                  {!code.is_active && <Badge variant="orange" label="Inactive" size="sm" />}
                  {code.is_active && !code.is_expired && <Badge variant="green" label="Active" size="sm" />}
                </div>
                <p className="text-xs text-buddy-text-secondary mt-1">
                  {code.discount_type === 'percentage' ? `${code.discount_pct}% off` : `Fixed artifact discount`}
                  {code.campaign && ` · ${code.campaign}`}
                </p>
                {code.description && <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">{code.description}</p>}
                <div className="flex items-center gap-3 mt-1.5 text-xs text-buddy-text-tertiary">
                  <span>{code.times_used}/{code.usage_limit || '∞'} uses</span>
                  <span>{code.share_count} shares</span>
                  {code.valid_until && <span>Expires {new Date(code.valid_until).toLocaleDateString()}</span>}
                </div>
              </div>
              <div className="flex items-center gap-1 ml-2">
                <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/creator/discount-codes/${code.id}/analytics`)}>📊</Button>
                <Button size="sm" variant="ghost" onClick={() => handleToggle(code)}>{code.is_active && !code.is_expired ? '⏸️' : '▶️'}</Button>
                <Button size="sm" variant="ghost" onClick={() => handleShare(code.id)}>📤</Button>
                <Button size="sm" variant="ghost" onClick={() => { setEditing(code); setForm({ code: code.code, discount_type: code.discount_type, discount_pct: code.discount_pct, discount_artifacts: JSON.stringify(code.discount_artifacts || {}), code_type: code.code_type, description: code.description || '', campaign: code.campaign || '', valid_from: code.valid_from || '', valid_until: code.valid_until || '', usage_limit: code.usage_limit || 0, max_uses_per_user: code.max_uses_per_user || 0, min_purchase_artifacts: JSON.stringify(code.min_purchase_artifacts || {}), is_active: code.is_active }); }}>✏️</Button>
                <Button size="sm" variant="ghost" onClick={() => handleDelete(code.id)}>🗑️</Button>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {editing !== null && (
        <Card className="p-4">
          <h2 className="font-bold text-sm mb-3">{editing ? 'Edit Discount Code' : 'New Discount Code'}</h2>
          <div className="space-y-3">
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary">Code *</label>
              <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg focus:outline-none focus:border-buddy-electric" value={form.code} onChange={(e) => setForm({ ...form, code: e.target.value })} placeholder="SUMMER20" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Discount Type</label>
                <select className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" value={form.discount_type} onChange={(e) => setForm({ ...form, discount_type: e.target.value as any })}>
                  <option value="percentage">Percentage</option>
                  <option value="fixed_artifacts">Fixed Artifacts</option>
                </select>
              </div>
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Code Type</label>
                <select className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" value={form.code_type} onChange={(e) => setForm({ ...form, code_type: e.target.value as any })}>
                  <option value="text">Text</option>
                  <option value="qr">QR Code</option>
                </select>
              </div>
            </div>
            {form.discount_type === 'percentage' && (
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Discount %</label>
                <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" type="number" min="0" max="100" value={form.discount_pct} onChange={(e) => setForm({ ...form, discount_pct: Number(e.target.value) })} />
              </div>
            )}
            {form.discount_type === 'fixed_artifacts' && (
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Discount Artifacts (JSON, e.g. {"{"}"dumbbell": 100{"}"})</label>
                <textarea className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg font-mono" rows={2} value={form.discount_artifacts} onChange={(e) => setForm({ ...form, discount_artifacts: e.target.value })} />
              </div>
            )}
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary">Min Purchase Artifacts (JSON, e.g. {"{"}"dumbbell": 50{"}"})</label>
              <textarea className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg font-mono" rows={2} value={form.min_purchase_artifacts} onChange={(e) => setForm({ ...form, min_purchase_artifacts: e.target.value })} placeholder='{"dumbbell": 50}' />
            </div>
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary">Description</label>
              <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} placeholder="Summer sale 2026" />
            </div>
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary">Campaign</label>
              <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" value={form.campaign} onChange={(e) => setForm({ ...form, campaign: e.target.value })} placeholder="summer-2026" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Valid From</label>
                <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" type="datetime-local" value={form.valid_from} onChange={(e) => setForm({ ...form, valid_from: e.target.value })} />
              </div>
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Valid Until</label>
                <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" type="datetime-local" value={form.valid_until} onChange={(e) => setForm({ ...form, valid_until: e.target.value })} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Usage Limit (0 = unlimited)</label>
                <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" type="number" min="0" value={form.usage_limit} onChange={(e) => setForm({ ...form, usage_limit: Number(e.target.value) })} />
              </div>
              <div>
                <label className="text-xs font-medium text-buddy-text-secondary">Max/User (0 = unlimited)</label>
                <input className="w-full mt-1 px-3 py-2 text-sm bg-buddy-surface border border-buddy-surface rounded-lg" type="number" min="0" value={form.max_uses_per_user} onChange={(e) => setForm({ ...form, max_uses_per_user: Number(e.target.value) })} />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <input type="checkbox" id="is_active" checked={form.is_active} onChange={(e) => setForm({ ...form, is_active: e.target.checked })} />
              <label htmlFor="is_active" className="text-xs font-medium text-buddy-text-secondary">Active</label>
            </div>
            <div className="flex gap-2 pt-2">
              <Button onClick={handleSave} disabled={saving || !form.code.trim()} className="flex-1">{saving ? 'Saving...' : editing ? 'Update' : 'Create'}</Button>
              <Button variant="ghost" onClick={() => { setEditing(null); setForm(EMPTY_FORM); }}>Cancel</Button>
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}
