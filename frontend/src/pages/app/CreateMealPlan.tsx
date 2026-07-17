import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { marketplaceApi } from '@/api/marketplace';

const DIET_TYPES = ['balanced', 'high_protein', 'weight_loss', 'muscle_gain', 'vegan', 'keto', 'gluten_free', 'other'];
const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

export default function CreateMealPlan() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [form, setForm] = useState({
    title: '',
    description: '',
    diet_type: 'balanced',
    duration_weeks: 4,
    calorie_range: '',
    cover_image_url: '',
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>),
    is_published: true,
  });
  const [submitting, setSubmitting] = useState(false);

  const canProceedToStep2 = form.title.trim().length > 0 && form.description.trim().length > 0;
  const canProceedToStep3 = form.diet_type.trim().length > 0;

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const price_artifacts = Object.fromEntries(
        Object.entries(form.price_artifacts).filter(([, value]) => value > 0)
      ) as Record<string, number>;

      await marketplaceApi.createMealPlan({
        title: form.title,
        description: form.description,
        diet_type: form.diet_type,
        duration_weeks: form.duration_weeks,
        calorie_range: form.calorie_range || undefined,
        preview_day: form.cover_image_url ? { cover_image_url: form.cover_image_url } : {},
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
        <h1 className="font-display text-2xl font-extrabold">Create Meal Plan</h1>
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
              <label className="text-sm font-semibold mb-1 block">Plan Title</label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. 7-Day Muscle Gain Plan" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1 block">Description</label>
              <textarea
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green resize-none"
                rows={4}
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                placeholder="Describe your meal plan..."
              />
            </div>
            <Button className="w-full" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
              Next: Nutrition Details
            </Button>
          </Card>
        )}

        {step === 2 && (
          <Card className="p-5 space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-semibold mb-1 block">Diet Type</label>
                <select
                  className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                  value={form.diet_type}
                  onChange={(e) => setForm({ ...form, diet_type: e.target.value })}
                >
                  {DIET_TYPES.map((type) => (
                    <option key={type} value={type}>{type.replace('_', ' ')}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm font-semibold mb-1 block">Duration (weeks)</label>
                <Input type="number" min="1" value={form.duration_weeks} onChange={(e) => setForm({ ...form, duration_weeks: parseInt(e.target.value, 10) || 1 })} />
              </div>
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Calorie Range</label>
              <Input value={form.calorie_range} onChange={(e) => setForm({ ...form, calorie_range: e.target.value })} placeholder="e.g. 2000-2500 kcal" />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Cover Photo URL</label>
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
              <p className="text-xs text-buddy-text-secondary mb-2">Enter the cost for each artifact type. Leave empty or zero for free items.</p>
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
              <h2 className="text-lg font-semibold">Review your meal plan</h2>
              <p className="text-sm text-buddy-text-secondary">Ensure the meal plan looks complete before publishing.</p>
            </div>
            <div className="rounded-2xl border border-buddy-surface p-4 space-y-3">
              {form.cover_image_url && (
                <img src={form.cover_image_url} alt="Cover preview" className="w-full h-48 object-cover rounded-xl" />
              )}
              <div>
                <p className="text-sm font-semibold">{form.title}</p>
                <p className="text-xs text-buddy-text-secondary">{form.diet_type.replace('_', ' ')}</p>
              </div>
              <p className="text-sm text-buddy-text-secondary">{form.description || 'No description provided.'}</p>
              <div className="grid grid-cols-2 gap-2 text-xs text-buddy-text-secondary">
                <div>
                  <span className="font-semibold">Duration:</span> {form.duration_weeks} weeks
                </div>
                <div>
                  <span className="font-semibold">Calories:</span> {form.calorie_range || 'Not set'}
                </div>
              </div>
              <div className="space-y-2">
                <div className="text-xs text-buddy-text-secondary font-semibold">Artifact Pricing</div>
                <div className="grid grid-cols-2 gap-2">
                  {PRICE_ARTIFACTS.filter((artifact) => form.price_artifacts[artifact] > 0).map((artifact) => (
                    <div key={artifact} className="rounded-xl bg-buddy-surface p-3 text-xs capitalize">
                      {artifact}: {form.price_artifacts[artifact]}
                    </div>
                  ))}
                </div>
              </div>
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(3)}>
                Back
              </Button>
              <Button className="flex-1" onClick={handleSubmit} isLoading={submitting}>
                Publish Meal Plan
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
