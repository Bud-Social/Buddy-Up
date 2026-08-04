import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Plus, Trash2, Info, Clock, Bell, Settings } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { ImageUploadField } from '@/components/ui/ImageUploadField';
import { marketplaceApi } from '@/api/marketplace';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';

const DIET_TYPES = ['balanced', 'high_protein', 'weight_loss', 'muscle_gain', 'vegan', 'keto', 'gluten_free', 'other'];
const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

export default function CreateMealPlan() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const editId = searchParams.get('edit');
  const isEditing = Boolean(editId);
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(isEditing);
  const [myShops, setMyShops] = useState<any[]>([]);
  const [form, setForm] = useState({
    shop_id: '',
    title: '',
    description: '',
    diet_type: 'balanced',
    duration_weeks: 4,
    meals_per_day: 3,
    calorie_range: '',
    macro_targets: { protein_pct: 30, carbs_pct: 40, fat_pct: 30 },
    cover_image_url: '',
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>),
    reminder_settings: { enabled: true, time_of_day: '08:00', message_template: "Hey Buddy! Here is your meal plan for today. Let's hit those macros!" },
    is_published: true,
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
    marketplaceApi.getMealPlan(editId)
      .then((res) => {
        const p = res.data as any;
        setForm({
          shop_id: p.shop_data?.id || '',
          title: p.title,
          description: p.description || '',
          diet_type: p.diet_type || 'balanced',
          duration_weeks: p.duration_weeks || 4,
          meals_per_day: p.meals_per_day || 3,
          calorie_range: p.calorie_range || '',
          macro_targets: p.macro_targets || { protein_pct: 30, carbs_pct: 40, fat_pct: 30 },
          cover_image_url: p.cover_image_url || '',
          price_artifacts: { ...PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>), ...(p.price_artifacts || {}) },
          reminder_settings: p.reminder_settings || { enabled: true, time_of_day: '08:00', message_template: '' },
          is_published: p.is_published,
        });
        setIsLoading(false);
      })
      .catch(() => { setIsLoading(false); navigate('/marketplace/creator'); });
  }, [editId]);

  const canProceedToStep2 = form.title.trim().length > 0 && form.description.trim().length > 0 && form.cover_image_url;
  const canProceedToStep3 = form.diet_type.trim().length > 0;

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const price_artifacts = Object.fromEntries(
        Object.entries(form.price_artifacts).filter(([, value]) => value > 0)
      ) as Record<string, number>;

      const payload = {
        shop_id: form.shop_id || undefined,
        title: form.title,
        description: form.description,
        diet_type: form.diet_type,
        duration_weeks: form.duration_weeks,
        meals_per_day: form.meals_per_day,
        calorie_range: form.calorie_range || undefined,
        macro_targets: form.macro_targets,
        preview_day: form.cover_image_url ? { cover_image_url: form.cover_image_url } : {},
        price_artifacts: Object.keys(price_artifacts).length > 0 ? price_artifacts : {},
        reminder_settings: form.reminder_settings,
        is_published: form.is_published,
      };

      if (isEditing && editId) {
        await marketplaceApi.updateMealPlan(editId, payload);
        navigate('/marketplace/creator');
      } else {
        await marketplaceApi.createMealPlan(payload);
        navigate('/marketplace');
      }
    } catch {
      /* ignore */
    } finally {
      setSubmitting(false);
    }
  };

  if (isLoading) return <div className="p-4 text-center">Loading plan...</div>;

  return (
    <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 pb-20">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(isEditing ? '/marketplace/creator' : '/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold tracking-tight">{isEditing ? 'Edit Meal Plan' : 'Create Meal Plan'}</h1>
      </div>

      <div className="flex gap-2 mb-8 px-2">
        {['Basics', 'Nutrition & Schedule', 'Notifications', 'Pricing'].map((label, idx) => (
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
                <h2 className="text-xl font-bold">The Basics</h2>
                <p className="text-sm text-buddy-text-secondary">Start by giving your meal plan a catchy title and cover image.</p>
              </div>

              {myShops.length > 0 && (
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Host as Shop</label>
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

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Plan Title</label>
                <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. 7-Day Lean Muscle Builder" className="bg-buddy-black" />
              </div>
              
              <div>
                <label className="text-sm font-semibold mb-1.5 block">Description</label>
                <textarea
                  className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-green transition-colors resize-none"
                  rows={4}
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  placeholder="What makes this meal plan special? Mention key benefits and what's included..."
                />
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Cover Photo</label>
                <div className="bg-buddy-black rounded-xl p-2 border border-buddy-surface-raised">
                  <ImageUploadField
                    value={form.cover_image_url}
                    onChange={(url) => setForm({ ...form, cover_image_url: url })}
                    label="Upload a mouth-watering cover image"
                  />
                </div>
              </div>

              <Button className="w-full h-12 text-base font-bold shadow-lg" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
                Next: Nutrition Details
              </Button>
            </Card>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">Nutrition & Schedule</h2>
                <p className="text-sm text-buddy-text-secondary">Define the nutritional goals and daily routine.</p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Diet Type</label>
                  <select
                    className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-green transition-colors"
                    value={form.diet_type}
                    onChange={(e) => setForm({ ...form, diet_type: e.target.value })}
                  >
                    {DIET_TYPES.map((type) => (
                      <option key={type} value={type}>{type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-sm font-semibold mb-1.5 block text-buddy-gold">Duration (Weeks)</label>
                  <Input type="number" min="1" value={form.duration_weeks} onChange={(e) => setForm({ ...form, duration_weeks: parseInt(e.target.value, 10) || 1 })} className="bg-buddy-black" />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Meals per Day</label>
                  <Input type="number" min="1" max="8" value={form.meals_per_day} onChange={(e) => setForm({ ...form, meals_per_day: parseInt(e.target.value, 10) || 3 })} className="bg-buddy-black" />
                </div>
                <div>
                  <label className="text-sm font-semibold mb-1.5 block text-buddy-electric">Calorie Range</label>
                  <Input value={form.calorie_range} onChange={(e) => setForm({ ...form, calorie_range: e.target.value })} placeholder="e.g. 2000-2500 kcal" className="bg-buddy-black" />
                </div>
              </div>

              <div className="pt-2 border-t border-buddy-surface-raised">
                <label className="text-sm font-semibold mb-3 flex items-center gap-2"><Clock size={16} className="text-buddy-green" /> Macro Targets (%)</label>
                <div className="flex gap-4">
                  <div className="flex-1">
                    <label className="text-xs text-buddy-text-secondary mb-1 block">Protein</label>
                    <Input type="number" min="0" max="100" value={form.macro_targets.protein_pct} onChange={(e) => setForm({ ...form, macro_targets: { ...form.macro_targets, protein_pct: parseInt(e.target.value, 10) || 0 } })} className="bg-buddy-black" />
                  </div>
                  <div className="flex-1">
                    <label className="text-xs text-buddy-text-secondary mb-1 block">Carbs</label>
                    <Input type="number" min="0" max="100" value={form.macro_targets.carbs_pct} onChange={(e) => setForm({ ...form, macro_targets: { ...form.macro_targets, carbs_pct: parseInt(e.target.value, 10) || 0 } })} className="bg-buddy-black" />
                  </div>
                  <div className="flex-1">
                    <label className="text-xs text-buddy-text-secondary mb-1 block">Fat</label>
                    <Input type="number" min="0" max="100" value={form.macro_targets.fat_pct} onChange={(e) => setForm({ ...form, macro_targets: { ...form.macro_targets, fat_pct: parseInt(e.target.value, 10) || 0 } })} className="bg-buddy-black" />
                  </div>
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(1)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg" onClick={() => setStep(3)} disabled={!canProceedToStep3}>Next: Notifications</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <Bell className="text-buddy-orange" size={24} />
                  <h2 className="text-xl font-bold">Subscriber Reminders</h2>
                </div>
                <p className="text-sm text-buddy-text-secondary">Set up push notifications to remind your subscribers about their daily meals.</p>
              </div>

              <div className="flex items-center justify-between p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised">
                <div>
                  <p className="font-semibold text-sm">Enable Daily Reminders</p>
                  <p className="text-xs text-buddy-text-secondary">Send daily motivation and meal previews</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" className="sr-only peer" checked={form.reminder_settings.enabled} onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, enabled: e.target.checked } })} />
                  <div className="w-11 h-6 bg-buddy-surface-raised peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-buddy-orange"></div>
                </label>
              </div>

              {form.reminder_settings.enabled && (
                <div className="space-y-4 p-4 border border-buddy-orange/20 bg-buddy-orange/5 rounded-xl">
                  <div>
                    <label className="text-sm font-semibold mb-1.5 block">Time of Day</label>
                    <Input type="time" value={form.reminder_settings.time_of_day} onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, time_of_day: e.target.value } })} className="bg-buddy-black border-buddy-orange/20 focus:border-buddy-orange" />
                    <p className="text-xs text-buddy-text-secondary mt-1 flex items-center gap-1"><Info size={12} /> Local time for the subscriber</p>
                  </div>
                  <div>
                    <label className="text-sm font-semibold mb-1.5 block">Message Template</label>
                    <textarea
                      className="w-full rounded-xl bg-buddy-black border border-buddy-orange/20 px-4 py-3 text-sm focus:outline-none focus:border-buddy-orange transition-colors resize-none"
                      rows={3}
                      value={form.reminder_settings.message_template}
                      onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, message_template: e.target.value } })}
                      placeholder="Enter a motivational reminder message..."
                    />
                  </div>
                </div>
              )}

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(2)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg" onClick={() => setStep(4)}>Next: Pricing</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">Pricing & Review</h2>
                <p className="text-sm text-buddy-text-secondary">Set your price in artifacts and review the plan.</p>
              </div>
              
              <div className="p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised space-y-4">
                <h3 className="font-semibold text-sm border-b border-buddy-surface-raised pb-2">Price Artifacts</h3>
                <div className="grid grid-cols-2 gap-4">
                  {PRICE_ARTIFACTS.map((artifact) => (
                    <div key={artifact} className="relative group">
                      <div className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary group-focus-within:text-buddy-gold transition-colors">
                        <ArtifactIcon artifact={artifact} size={16} />
                      </div>
                      <Input
                        type="number"
                        min={0}
                        className="pl-9 bg-buddy-surface focus:bg-buddy-black transition-colors"
                        value={form.price_artifacts[artifact]}
                        onChange={(e) => setForm({
                          ...form,
                          price_artifacts: { ...form.price_artifacts, [artifact]: parseInt(e.target.value, 10) || 0 },
                        })}
                      />
                      <label className="text-[10px] uppercase font-bold text-buddy-text-secondary mt-1 block text-center tracking-wider">{artifact}</label>
                    </div>
                  ))}
                </div>
              </div>

              <div className="rounded-2xl border border-buddy-surface p-1 shadow-lg bg-buddy-black">
                {form.cover_image_url && (
                  <img src={form.cover_image_url} alt="Cover preview" className="w-full h-32 object-cover rounded-xl mb-3" />
                )}
                <div className="p-3">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-base font-bold">{form.title}</p>
                      <Badge variant="blue" label={form.diet_type.split('_').join(' ')} size="sm" className="mt-1" />
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold text-buddy-gold">{form.duration_weeks} Weeks</p>
                      <p className="text-xs text-buddy-text-secondary">{form.meals_per_day} meals/day</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex gap-3 pt-4 border-t border-buddy-surface-raised">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(3)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-gradient-to-r from-buddy-green to-emerald-400 text-buddy-black font-bold" onClick={handleSubmit} isLoading={submitting}>
                  {isEditing ? 'Save Changes' : 'Publish Plan'}
                </Button>
              </div>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
