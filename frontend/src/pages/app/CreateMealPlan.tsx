import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Info, Clock, Bell } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Toggle } from '@/components/ui/Toggle';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { ImageUploadField } from '@/components/ui/ImageUploadField';
import { marketplaceApi } from '@/api/marketplace';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';

const DIET_TYPES = ['balanced', 'high_protein', 'weight_loss', 'muscle_gain', 'vegan', 'keto', 'gluten_free', 'other'];

const MEAL_SLOTS = ['breakfast', 'lunch', 'dinner', 'snack'];
const MEAL_TIMINGS = ['morning', 'midday', 'afternoon', 'evening', 'anytime'];
const REMINDER_FREQUENCIES = ['15m', '30m', '1h'];
const MEDICAL_DISCLAIMER = "This meal plan isn't medical advice — consult a professional.";

interface MealBlock {
  id: number;
  week: number;
  day: number;
  slot: string;
  title: string;
  duration_mins: number;
  timing: string;
  photo_url: string;
  alternatives: string;
  side_effects: string;
}

const MEAL_PLAN_TEMPLATES = [
  {
    name: 'Lean & High-Protein',
    form: { title: 'Lean & High-Protein Reset', description: '4 weeks of simple high-protein meals for steady fat loss.', diet_type: 'high_protein', duration_weeks: 4, meals_per_day: 4, calorie_range: '1800-2100 kcal', macro_targets: { protein_pct: 40, carbs_pct: 30, fat_pct: 30 } },
  },
  {
    name: 'Plant-Powered Week',
    form: { title: 'Plant-Powered Week', description: '7 days of satisfying vegan meals, no cooking marathons.', diet_type: 'vegan', duration_weeks: 1, meals_per_day: 3, calorie_range: '1800-2200 kcal', macro_targets: { protein_pct: 25, carbs_pct: 50, fat_pct: 25 } },
  },
  {
    name: 'Bulking Basics',
    form: { title: 'Bulking Basics', description: 'Calorie-surplus staples to support a 6-week mass phase.', diet_type: 'muscle_gain', duration_weeks: 6, meals_per_day: 5, calorie_range: '2800-3200 kcal', macro_targets: { protein_pct: 30, carbs_pct: 45, fat_pct: 25 } },
  },
];
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
    reminder_settings: { enabled: true, time_of_day: '08:00', timing: 'morning' as string, frequency: '1h', message_template: "Hey Buddy! Here is your meal plan for today. Let's hit those macros!" },
    is_published: true,
  });
  const [mealBlocks, setMealBlocks] = useState<MealBlock[]>([
    { id: 1, week: 1, day: 1, slot: 'breakfast', title: '', duration_mins: 15, timing: 'morning', photo_url: '', alternatives: '', side_effects: '' },
  ]);
  const [disclaimerAccepted, setDisclaimerAccepted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const macroSum = form.macro_targets.protein_pct + form.macro_targets.carbs_pct + form.macro_targets.fat_pct;
  const macroValid = macroSum === 100;
  const mealTotalMins = mealBlocks.reduce((sum, b) => sum + (b.duration_mins || 0), 0);
  const mealWeeksCovered = new Set(mealBlocks.map((b) => b.week)).size;

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
          reminder_settings: {
            enabled: true, time_of_day: '08:00', timing: 'morning', frequency: '1h', message_template: '',
            ...(p.reminder_settings || {}),
          },
          is_published: p.is_published,
        });
        const blocks: MealBlock[] = [];
        let nextId = 1;
        Object.entries(p.full_plan || {}).forEach(([weekKey, days]: [string, any]) => {
          Object.entries(days || {}).forEach(([dayKey, meals]: [string, any]) => {
            (Array.isArray(meals) ? meals : []).forEach((m: any) => {
              if (m && typeof m === 'object') {
                blocks.push({
                  id: nextId++,
                  week: parseInt(String(weekKey).replace('week_', ''), 10) || 1,
                  day: parseInt(String(dayKey).replace('day_', ''), 10) || 1,
                  slot: m.slot || 'breakfast',
                  title: m.title || '',
                  duration_mins: m.duration_mins || 15,
                  timing: m.timing || m.time_of_day || 'morning',
                  photo_url: m.photo_url || '',
                  alternatives: m.alternatives || '',
                  side_effects: m.side_effects || '',
                });
              }
            });
          });
        });
        if (blocks.length > 0) setMealBlocks(blocks);
        setDisclaimerAccepted(true);
        setIsLoading(false);
      })
      .catch(() => { setIsLoading(false); navigate('/marketplace/creator'); });
  }, [editId]);

  const canProceedToStep2 = form.title.trim().length > 0 && form.description.trim().length > 0 && form.cover_image_url;
  const canProceedToStep3 = form.diet_type.trim().length > 0 && macroValid && mealBlocks.length > 0;

  const addMealBlock = () => {
    setMealBlocks([...mealBlocks, {
      id: Date.now(), week: 1, day: 1, slot: 'breakfast', title: '', duration_mins: 15,
      timing: 'morning', photo_url: '', alternatives: '', side_effects: '',
    }]);
  };

  const removeMealBlock = (id: number) => {
    setMealBlocks(mealBlocks.filter((b) => b.id !== id));
  };

  const updateMealBlock = (id: number, field: keyof MealBlock, value: string | number) => {
    setMealBlocks(mealBlocks.map((b) => (b.id === id ? { ...b, [field]: value } : b)));
  };

  const handleSubmit = async () => {
    if (!disclaimerAccepted) return;
    setSubmitting(true);
    try {
      const price_artifacts = Object.fromEntries(
        Object.entries(form.price_artifacts).filter(([, value]) => value > 0)
      ) as Record<string, number>;

      const full_plan: Record<string, any> = {};
      mealBlocks.forEach((block) => {
        if (!full_plan[`week_${block.week}`]) full_plan[`week_${block.week}`] = {};
        if (!full_plan[`week_${block.week}`][`day_${block.day}`]) full_plan[`week_${block.week}`][`day_${block.day}`] = [];
        full_plan[`week_${block.week}`][`day_${block.day}`].push({
          slot: block.slot,
          title: block.title,
          duration_mins: block.duration_mins,
          timing: block.timing,
          photo_url: block.photo_url,
          alternatives: block.alternatives,
          side_effects: block.side_effects,
        });
      });

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
        full_plan,
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
            <div className={`h-1.5 rounded-full transition-colors ${idx + 1 <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
            <span className={`text-[10px] font-semibold text-center uppercase tracking-wider ${idx + 1 <= step ? 'text-buddy-green' : 'text-buddy-text-secondary'}`}>{label}</span>
          </div>
        ))}
      </div>

      <div className="space-y-6">
        {step === 1 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-sm bg-buddy-surface">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">The Basics</h2>
                <p className="text-sm text-buddy-text-secondary">Start from a template or blank — then make it yours.</p>
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Start from a template</label>
                <div className="flex flex-wrap gap-2">
                  {MEAL_PLAN_TEMPLATES.map((t) => (
                    <button key={t.name} type="button" onClick={() => setForm((f) => ({ ...f, ...t.form }))}
                      className="px-3 py-1.5 rounded-full text-xs border border-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-green hover:border-buddy-green/40 transition-colors">
                      {t.name}
                    </button>
                  ))}
                </div>
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

              <Button className="w-full h-12 text-base font-bold" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
                Next: Nutrition Details
              </Button>
            </Card>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-sm bg-buddy-surface">
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
                <label className="text-sm font-semibold mb-3 flex items-center gap-2"><Clock size={16} className="text-buddy-green" /> Macro Targets (%) — must total 100%</label>
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
                <p className={`text-xs mt-2 font-semibold ${macroValid ? 'text-buddy-green' : 'text-buddy-red'}`}>
                  Macros total {macroSum}%{macroValid ? ' — looks good.' : ' — must add up to 100%.'}
                </p>
              </div>

              <div className="pt-2 border-t border-buddy-surface-raised space-y-4">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-semibold">Meal Schedule Blocks</label>
                  <span className="text-xs text-buddy-text-secondary">
                    {mealBlocks.length} meals · {mealTotalMins} min total prep
                  </span>
                </div>
                <div className="space-y-4 max-h-[420px] overflow-y-auto pr-1">
                  {mealBlocks.map((block, index) => (
                    <div key={block.id} className="p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised space-y-3 relative">
                      {mealBlocks.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeMealBlock(block.id)}
                          className="absolute top-3 right-3 text-buddy-text-secondary hover:text-buddy-red transition-colors"
                          aria-label={`Remove meal ${index + 1}`}
                        >
                          ✕
                        </button>
                      )}
                      <p className="text-xs font-bold text-buddy-green">Meal {index + 1}</p>
                      <div className="grid grid-cols-3 gap-3">
                        <div>
                          <label className="text-xs text-buddy-text-secondary mb-1 block">Week</label>
                          <Input type="number" min="1" max={form.duration_weeks} value={block.week} onChange={(e) => updateMealBlock(block.id, 'week', parseInt(e.target.value, 10) || 1)} className="bg-buddy-surface h-9" />
                        </div>
                        <div>
                          <label className="text-xs text-buddy-text-secondary mb-1 block">Day</label>
                          <Input type="number" min="1" max="7" value={block.day} onChange={(e) => updateMealBlock(block.id, 'day', parseInt(e.target.value, 10) || 1)} className="bg-buddy-surface h-9" />
                        </div>
                        <div>
                          <label className="text-xs text-buddy-text-secondary mb-1 block">Prep (min)</label>
                          <Input type="number" min="0" value={block.duration_mins} onChange={(e) => updateMealBlock(block.id, 'duration_mins', parseInt(e.target.value, 10) || 0)} className="bg-buddy-surface h-9" />
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="text-xs font-semibold mb-1 block">Slot</label>
                          <select
                            className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green transition-colors"
                            value={block.slot}
                            onChange={(e) => updateMealBlock(block.id, 'slot', e.target.value)}
                          >
                            {MEAL_SLOTS.map((s) => (
                              <option key={s} value={s}>{s.charAt(0).toUpperCase() + s.slice(1)}</option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="text-xs font-semibold mb-1 block">Timing</label>
                          <select
                            className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green transition-colors"
                            value={block.timing}
                            onChange={(e) => updateMealBlock(block.id, 'timing', e.target.value)}
                          >
                            {MEAL_TIMINGS.map((t) => (
                              <option key={t} value={t}>{t.charAt(0).toUpperCase() + t.slice(1)}</option>
                            ))}
                          </select>
                        </div>
                      </div>
                      <div>
                        <label className="text-xs font-semibold mb-1 block">Meal Title</label>
                        <Input value={block.title} onChange={(e) => updateMealBlock(block.id, 'title', e.target.value)} placeholder="e.g. Grilled chicken + quinoa" className="bg-buddy-surface" />
                      </div>
                      <div>
                        <label className="text-xs font-semibold mb-1 block">Photo URL (optional)</label>
                        <Input value={block.photo_url} onChange={(e) => updateMealBlock(block.id, 'photo_url', e.target.value)} placeholder="https://..." className="bg-buddy-surface" />
                      </div>
                      <div>
                        <label className="text-xs font-semibold mb-1 block">Alternatives</label>
                        <Input value={block.alternatives} onChange={(e) => updateMealBlock(block.id, 'alternatives', e.target.value)} placeholder="e.g. Swap chicken for tofu" className="bg-buddy-surface" />
                      </div>
                      <div>
                        <label className="text-xs font-semibold mb-1 block">Side Effects / Notes</label>
                        <Input value={block.side_effects} onChange={(e) => updateMealBlock(block.id, 'side_effects', e.target.value)} placeholder="e.g. High fibre — hydrate well" className="bg-buddy-surface" />
                      </div>
                    </div>
                  ))}
                </div>
                <Button variant="outline" className="w-full border-dashed" onClick={addMealBlock}>
                  + Add Meal Block
                </Button>
                <p className="text-xs text-buddy-text-secondary">
                  Total prep time: {mealTotalMins} min ({(mealTotalMins / 60).toFixed(1)} hrs) across {mealWeeksCovered} week{mealWeeksCovered === 1 ? '' : 's'}.
                  {mealWeeksCovered < form.duration_weeks && (
                    <span className="text-buddy-orange font-semibold"> Schedule covers fewer weeks than the {form.duration_weeks}-week duration.</span>
                  )}
                </p>
              </div>

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(1)}>Back</Button>
                <Button className="flex-1 h-12" onClick={() => setStep(3)} disabled={!canProceedToStep3}>Next: Notifications</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-sm bg-buddy-surface">
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
                <Toggle checked={form.reminder_settings.enabled}
                  onCheckedChange={(v) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, enabled: v } })}
                  label="Enable daily reminders" />
              </div>

              {form.reminder_settings.enabled && (
                <div className="space-y-4 p-4 border border-buddy-orange/20 bg-buddy-orange/5 rounded-xl">
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-sm font-semibold mb-1.5 block">Time of Day</label>
                      <Input type="time" value={form.reminder_settings.time_of_day} onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, time_of_day: e.target.value } })} className="bg-buddy-black border-buddy-orange/20 focus:border-buddy-orange" />
                      <p className="text-xs text-buddy-text-secondary mt-1 flex items-center gap-1"><Info size={12} /> Local time for the subscriber</p>
                    </div>
                    <div>
                      <label className="text-sm font-semibold mb-1.5 block">Default Timing</label>
                      <select
                        className="w-full rounded-xl bg-buddy-black border border-buddy-orange/20 px-4 py-3 text-sm focus:outline-none focus:border-buddy-orange transition-colors"
                        value={form.reminder_settings.timing}
                        onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, timing: e.target.value } })}
                      >
                        {MEAL_TIMINGS.map((t) => (
                          <option key={t} value={t}>{t.charAt(0).toUpperCase() + t.slice(1)}</option>
                        ))}
                      </select>
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-semibold mb-1.5 block">Reminder Frequency</label>
                    <select
                      className="w-full rounded-xl bg-buddy-black border border-buddy-orange/20 px-4 py-3 text-sm focus:outline-none focus:border-buddy-orange transition-colors"
                      value={form.reminder_settings.frequency}
                      onChange={(e) => setForm({ ...form, reminder_settings: { ...form.reminder_settings, frequency: e.target.value } })}
                    >
                      {REMINDER_FREQUENCIES.map((f) => (
                        <option key={f} value={f}>{f === '15m' ? 'Every 15 minutes' : f === '30m' ? 'Every 30 minutes' : 'Hourly'}</option>
                      ))}
                    </select>
                    <p className="text-xs text-buddy-text-secondary mt-1">Each meal block also carries its own timing (morning / midday / afternoon / evening / anytime).</p>
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
                <Button className="flex-1 h-12" onClick={() => setStep(4)}>Next: Pricing</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-sm bg-buddy-surface">
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

              <div className="rounded-2xl border border-buddy-surface p-1 shadow-sm bg-buddy-black">
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
                  <div className="mt-3 pt-3 border-t border-buddy-surface-raised text-xs text-buddy-text-secondary space-y-1">
                    <p>{mealBlocks.length} meals scheduled · {mealTotalMins} min total prep ({(mealTotalMins / 60).toFixed(1)} hrs)</p>
                    <p>Macros: {form.macro_targets.protein_pct}/{form.macro_targets.carbs_pct}/{form.macro_targets.fat_pct} (P/C/F) — total {macroSum}%</p>
                    <p>Reminders: {form.reminder_settings.enabled ? `${form.reminder_settings.timing}, ${form.reminder_settings.frequency}` : 'off'}</p>
                  </div>
                </div>
              </div>

              <label className="flex items-start gap-3 p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised cursor-pointer">
                <input
                  type="checkbox"
                  checked={disclaimerAccepted}
                  onChange={(e) => setDisclaimerAccepted(e.target.checked)}
                  className="mt-1 h-4 w-4 accent-green-500"
                />
                <span className="text-xs text-buddy-text-secondary">{MEDICAL_DISCLAIMER}</span>
              </label>

              <div className="flex gap-3 pt-4 border-t border-buddy-surface-raised">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(3)}>Back</Button>
                <Button className="flex-1 h-12 bg-buddy-green text-buddy-black font-bold" onClick={handleSubmit} isLoading={submitting} disabled={!disclaimerAccepted}>
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
