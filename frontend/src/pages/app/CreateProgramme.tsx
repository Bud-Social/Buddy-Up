import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { marketplaceApi } from '@/api/marketplace';

const CATEGORIES = ['strength', 'hypertrophy', 'endurance', 'hiit', 'bodyweight', 'flexibility', 'sport', 'other'];
const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

export default function CreateProgramme() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [form, setForm] = useState({
    title: '',
    description: '',
    category: 'strength',
    duration_weeks: 4,
    cover_image_url: '',
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>),
    is_published: true,
  });
  const [submitting, setSubmitting] = useState(false);

  const canProceedToStep2 = form.title.trim().length > 0 && form.description.trim().length > 0;
  const canProceedToStep3 = form.category.trim().length > 0;

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const price_artifacts = Object.fromEntries(
        Object.entries(form.price_artifacts).filter(([, value]) => value > 0)
      ) as Record<string, number>;

      await marketplaceApi.createProgramme({
        title: form.title,
        description: form.description,
        category: form.category,
        duration_weeks: form.duration_weeks,
        price_artifacts: Object.keys(price_artifacts).length > 0 ? price_artifacts : {},
        is_published: form.is_published,
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
        <h1 className="font-display text-2xl font-extrabold">Create Programme</h1>
      </div>

      <div className="flex gap-2 mb-6">
        {[1, 2, 3, 4].map((value) => (
          <div key={value} className={`flex-1 h-1 rounded-full ${value <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
        ))}
      </div>

      <div className="space-y-6">
        {step === 1 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Programme Title</label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. 12-Week Strength Builder" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Description</label>
              <textarea
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green resize-none"
                rows={4}
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                placeholder="Describe your programme..."
              />
            </div>
            <Button className="w-full" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
              Next: Category
            </Button>
          </Card>
        )}

        {step === 2 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Category</label>
              <select
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                value={form.category}
                onChange={(e) => setForm({ ...form, category: e.target.value })}
              >
                {CATEGORIES.map((category) => (
                  <option key={category} value={category}>{category.charAt(0).toUpperCase() + category.slice(1)}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Duration (weeks)</label>
              <Input type="number" min={1} value={form.duration_weeks} onChange={(e) => setForm({ ...form, duration_weeks: parseInt(e.target.value, 10) || 1 })} />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Cover Photo URL (optional)</label>
              <Input value={form.cover_image_url} onChange={(e) => setForm({ ...form, cover_image_url: e.target.value })} placeholder="https://..." />
              {form.cover_image_url && (
                <div className="mt-4 overflow-hidden rounded-xl border border-buddy-surface">
                  <img src={form.cover_image_url} alt="Cover preview" className="w-full h-48 object-cover" />
                </div>
              )}
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(1)}>
                Back
              </Button>
              <Button className="flex-1" onClick={() => setStep(3)} disabled={!canProceedToStep3}>
                Next: Pricing
              </Button>
            </div>
          </Card>
        )}

        {step === 3 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Price Artifacts</label>
              <p className="text-xs text-buddy-text-secondary mb-2">Set the artifact cost per programme.</p>
              <div className="grid grid-cols-2 gap-4">
                {PRICE_ARTIFACTS.map((artifact) => (
                  <div key={artifact}>
                    <label className="text-xs text-buddy-text-secondary mb-1 block capitalize">{artifact}</label>
                    <Input
                      type="number"
                      min={0}
                      value={form.price_artifacts[artifact]}
                      onChange={(e) => setForm({
                        ...form,
                        price_artifacts: { ...form.price_artifacts, [artifact]: parseInt(e.target.value, 10) || 0 },
                      })}
                    />
                  </div>
                ))}
              </div>
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(2)}>
                Back
              </Button>
              <Button className="flex-1" onClick={() => setStep(4)}>
                Next: Review
              </Button>
            </div>
          </Card>
        )}

        {step === 4 && (
          <Card className="p-5 space-y-4">
            <div>
              <h2 className="text-lg font-semibold">Review your programme</h2>
              <p className="text-sm text-buddy-text-secondary">Confirm the programme details before publishing.</p>
            </div>
            <div className="rounded-2xl border border-buddy-surface p-4 space-y-3">
              {form.cover_image_url && (
                <img src={form.cover_image_url} alt="Cover preview" className="w-full h-48 object-cover rounded-xl" />
              )}
              <div>
                <p className="text-sm font-semibold">{form.title}</p>
                <p className="text-xs text-buddy-text-secondary">{form.category.replace('_', ' ')}</p>
              </div>
              <p className="text-sm text-buddy-text-secondary">{form.description || 'No description provided.'}</p>
              <div className="grid grid-cols-2 gap-2 text-xs text-buddy-text-secondary">
                <div>
                  <span className="font-semibold">Duration:</span> {form.duration_weeks} weeks
                </div>
                <div className="font-semibold">Pricing</div>
              </div>
              <div className="grid grid-cols-2 gap-2">
                {PRICE_ARTIFACTS.filter((artifact) => form.price_artifacts[artifact] > 0).map((artifact) => (
                  <div key={artifact} className="rounded-xl bg-buddy-surface p-3 text-xs capitalize">
                    {artifact}: {form.price_artifacts[artifact]}
                  </div>
                ))}
              </div>
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(3)}>
                Back
              </Button>
              <Button className="flex-1" onClick={handleSubmit} isLoading={submitting}>
                Publish Programme
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
