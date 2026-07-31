import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Plus, Trash2, Info, Bell, Clock, Activity, Video } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { ImageUploadField } from '@/components/ui/ImageUploadField';
import { marketplaceApi } from '@/api/marketplace';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';

const CATEGORIES = ['strength', 'hypertrophy', 'endurance', 'hiit', 'bodyweight', 'flexibility', 'sport', 'other'];
const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;
const SCHEDULE_TIMINGS = ['morning', 'midday', 'afternoon', 'evening', 'anytime'];

export default function CreateProgramme() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const editId = searchParams.get('edit');
  const isEditing = Boolean(editId);
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(isEditing);
  const [myShops, setMyShops] = useState<any[]>([]);

  const [scheduleBlocks, setScheduleBlocks] = useState([{
    id: 1, week: 1, day: 1, title: '', duration_mins: 30, timing: 'anytime',
    video_url: '', description: '', tips: '', warnings: '',
  }]);

  const [form, setForm] = useState({
    shop_id: '',
    title: '',
    description: '',
    category: 'strength',
    duration_weeks: 4,
    cover_image_url: '',
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>),
    notification_config: { enabled: true, frequency: '30m', custom_message: "It's time to put in the work! Ready for today's session?" },
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
    marketplaceApi.getProgramme(editId)
      .then((res) => {
        const p = res.data as any;
        setForm({
          shop_id: p.shop_data?.id || '',
          title: p.title,
          description: p.description || '',
          category: p.category || 'strength',
          duration_weeks: p.duration_weeks || 4,
          cover_image_url: p.cover_image_url || '',
          price_artifacts: { ...PRICE_ARTIFACTS.reduce((acc, artifact) => ({ ...acc, [artifact]: 0 }), {} as Record<string, number>), ...(p.price_artifacts || {}) },
          notification_config: p.notification_config || { enabled: true, frequency: '30m', custom_message: '' },
          is_published: p.is_published,
        });
        const blocks: typeof scheduleBlocks = [];
        let nextId = 1;
        Object.entries(p.schedule || {}).forEach(([weekKey, days]: [string, any]) => {
          Object.entries(days || {}).forEach(([dayKey, activities]: [string, any]) => {
            (activities || []).forEach((a: any) => {
              blocks.push({
                id: nextId++,
                week: parseInt(weekKey.replace('week_', ''), 10) || 1,
                day: parseInt(dayKey.replace('day_', ''), 10) || 1,
                title: a.title || '',
                duration_mins: a.duration_mins || 30,
                timing: a.timing || 'anytime',
                video_url: a.video_url || '',
                description: a.description || '',
                tips: a.tips || '',
                warnings: a.warnings || '',
              });
            });
          });
        });
        if (blocks.length > 0) setScheduleBlocks(blocks);
        setIsLoading(false);
      })
      .catch(() => { setIsLoading(false); navigate('/marketplace/creator'); });
  }, [editId]);

  const canProceedToStep2 = form.title.trim().length > 0 && form.description.trim().length > 0;

  const addScheduleBlock = () => {
    setScheduleBlocks([...scheduleBlocks, {
      id: Date.now(), week: 1, day: 1, title: '', duration_mins: 30, timing: 'anytime',
      video_url: '', description: '', tips: '', warnings: ''
    }]);
  };

  const removeScheduleBlock = (id: number) => {
    setScheduleBlocks(scheduleBlocks.filter(b => b.id !== id));
  };

  const updateScheduleBlock = (id: number, field: string, value: any) => {
    setScheduleBlocks(scheduleBlocks.map(b => b.id === id ? { ...b, [field]: value } : b));
  };

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const price_artifacts = Object.fromEntries(
        Object.entries(form.price_artifacts).filter(([, value]) => value > 0)
      ) as Record<string, number>;

      const scheduleMap: Record<string, any> = {};
      scheduleBlocks.forEach(block => {
        if (!scheduleMap[`week_${block.week}`]) scheduleMap[`week_${block.week}`] = {};
        if (!scheduleMap[`week_${block.week}`][`day_${block.day}`]) scheduleMap[`week_${block.week}`][`day_${block.day}`] = [];
        scheduleMap[`week_${block.week}`][`day_${block.day}`].push({
          title: block.title,
          duration_mins: block.duration_mins,
          timing: block.timing,
          video_url: block.video_url,
          description: block.description,
          tips: block.tips,
          warnings: block.warnings,
        });
      });

      const payload = {
        shop_id: form.shop_id || undefined,
        title: form.title,
        description: form.description,
        category: form.category,
        duration_weeks: form.duration_weeks,
        cover_image_url: form.cover_image_url || undefined,
        schedule: scheduleMap,
        notification_config: form.notification_config,
        price_artifacts: Object.keys(price_artifacts).length > 0 ? price_artifacts : {},
        is_published: form.is_published,
      };

      if (isEditing && editId) {
        await marketplaceApi.updateProgramme(editId, payload);
        navigate('/marketplace/creator');
      } else {
        await marketplaceApi.createProgramme(payload);
        navigate('/marketplace');
      }
    } catch {
      /* ignore */
    } finally {
      setSubmitting(false);
    }
  };

  if (isLoading) return <div className="p-4 text-center">Loading programme...</div>;

  return (
    <div className="max-w-xl mx-auto p-4 pb-20">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(isEditing ? '/marketplace/creator' : '/marketplace')} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <h1 className="font-display text-2xl font-extrabold tracking-tight">{isEditing ? 'Edit Programme' : 'Create Programme'}</h1>
      </div>

      <div className="flex gap-2 mb-8 px-2">
        {['Basics', 'Schedule & Details', 'Reminders', 'Pricing'].map((label, idx) => (
          <div key={idx} className="flex-1 flex flex-col gap-1.5">
            <div className={`h-1.5 rounded-full transition-colors ${idx + 1 <= step ? 'bg-buddy-electric shadow-[0_0_8px_rgba(23,154,248,0.4)]' : 'bg-buddy-surface-raised'}`} />
            <span className={`text-[10px] font-semibold text-center uppercase tracking-wider ${idx + 1 <= step ? 'text-buddy-electric' : 'text-buddy-text-secondary'}`}>{label}</span>
          </div>
        ))}
      </div>

      <div className="space-y-6">
        {step === 1 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">The Basics</h2>
                <p className="text-sm text-buddy-text-secondary">Start by giving your programme a title and cover image.</p>
              </div>

              {myShops.length > 0 && (
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Host as Shop</label>
                  <select
                    className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-electric transition-colors"
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
                <label className="text-sm font-semibold mb-1.5 block">Programme Title</label>
                <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. 12-Week Spartan Training" className="bg-buddy-black focus:border-buddy-electric" />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Category</label>
                  <select
                    className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-electric transition-colors"
                    value={form.category}
                    onChange={(e) => setForm({ ...form, category: e.target.value })}
                  >
                    {CATEGORIES.map((category) => (
                      <option key={category} value={category}>{category.charAt(0).toUpperCase() + category.slice(1)}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-sm font-semibold mb-1.5 block">Duration (Weeks)</label>
                  <Input type="number" min="1" value={form.duration_weeks} onChange={(e) => setForm({ ...form, duration_weeks: parseInt(e.target.value, 10) || 1 })} className="bg-buddy-black focus:border-buddy-electric" />
                </div>
              </div>
              
              <div>
                <label className="text-sm font-semibold mb-1.5 block">Description</label>
                <textarea
                  className="w-full rounded-xl bg-buddy-black border border-buddy-surface-raised px-4 py-3 text-sm focus:outline-none focus:border-buddy-electric transition-colors resize-none"
                  rows={4}
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  placeholder="What is this training programme about? Who is it for?..."
                />
              </div>

              <div>
                <label className="text-sm font-semibold mb-1.5 block">Cover Photo</label>
                <div className="bg-buddy-black rounded-xl p-2 border border-buddy-surface-raised">
                  <ImageUploadField
                    value={form.cover_image_url}
                    onChange={(url) => setForm({ ...form, cover_image_url: url })}
                    label="Upload a highly motivating cover image"
                  />
                </div>
              </div>

              <Button className="w-full h-12 text-base font-bold shadow-lg bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
                Next: Build Schedule
              </Button>
            </Card>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <Activity className="text-buddy-electric" size={24} />
                  <h2 className="text-xl font-bold">Programme Schedule</h2>
                </div>
                <p className="text-sm text-buddy-text-secondary">Add schedule blocks for each workout session, day, and week.</p>
              </div>

              <div className="space-y-6 max-h-[500px] overflow-y-auto pr-2 custom-scrollbar">
                {scheduleBlocks.map((block, index) => (
                  <div key={block.id} className="p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised space-y-4 relative">
                    {scheduleBlocks.length > 1 && (
                      <button 
                        onClick={() => removeScheduleBlock(block.id)}
                        className="absolute top-4 right-4 text-buddy-text-secondary hover:text-buddy-red transition-colors"
                      >
                        <Trash2 size={16} />
                      </button>
                    )}
                    
                    <div className="flex items-center gap-2 mb-2">
                      <Badge variant="blue" label={`Block ${index + 1}`} size="sm" />
                    </div>

                    <div className="grid grid-cols-3 gap-3">
                      <div>
                        <label className="text-xs text-buddy-text-secondary mb-1 block">Week</label>
                        <Input type="number" min="1" max={form.duration_weeks} value={block.week} onChange={(e) => updateScheduleBlock(block.id, 'week', parseInt(e.target.value, 10) || 1)} className="bg-buddy-surface h-9" />
                      </div>
                      <div>
                        <label className="text-xs text-buddy-text-secondary mb-1 block">Day</label>
                        <Input type="number" min="1" max="7" value={block.day} onChange={(e) => updateScheduleBlock(block.id, 'day', parseInt(e.target.value, 10) || 1)} className="bg-buddy-surface h-9" />
                      </div>
                      <div>
                        <label className="text-xs text-buddy-text-secondary mb-1 block">Duration (min)</label>
                        <Input type="number" min="5" value={block.duration_mins} onChange={(e) => updateScheduleBlock(block.id, 'duration_mins', parseInt(e.target.value, 10) || 30)} className="bg-buddy-surface h-9" />
                      </div>
                    </div>

                    <div>
                      <label className="text-xs font-semibold mb-1 block">Activity Title</label>
                      <Input value={block.title} onChange={(e) => updateScheduleBlock(block.id, 'title', e.target.value)} placeholder="e.g. Upper Body Power" className="bg-buddy-surface focus:border-buddy-electric" />
                    </div>

                    <div>
                      <label className="text-xs font-semibold mb-1 block">Preferred Timing</label>
                      <select
                        className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-electric transition-colors"
                        value={block.timing}
                        onChange={(e) => updateScheduleBlock(block.id, 'timing', e.target.value)}
                      >
                        {SCHEDULE_TIMINGS.map((timing) => (
                          <option key={timing} value={timing}>{timing.charAt(0).toUpperCase() + timing.slice(1)}</option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="text-xs font-semibold mb-1 flex items-center gap-1"><Video size={12} /> Video URL (Optional)</label>
                      <Input value={block.video_url} onChange={(e) => updateScheduleBlock(block.id, 'video_url', e.target.value)} placeholder="https://youtube.com/..." className="bg-buddy-surface" />
                    </div>

                    <div>
                      <label className="text-xs font-semibold mb-1 block">Workout Description / Transcript</label>
                      <textarea
                        className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-electric transition-colors resize-none"
                        rows={3}
                        value={block.description}
                        onChange={(e) => updateScheduleBlock(block.id, 'description', e.target.value)}
                        placeholder="List the exercises, sets, reps..."
                      />
                    </div>
                    
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-xs font-semibold text-buddy-gold mb-1 block">Tips & DIY</label>
                        <textarea
                          className="w-full rounded-xl bg-buddy-surface border border-buddy-gold/20 px-3 py-2 text-xs focus:outline-none focus:border-buddy-gold transition-colors resize-none"
                          rows={2}
                          value={block.tips}
                          onChange={(e) => updateScheduleBlock(block.id, 'tips', e.target.value)}
                          placeholder="e.g. Keep your core tight..."
                        />
                      </div>
                      <div>
                        <label className="text-xs font-semibold text-buddy-red mb-1 block">Cautions / Side Effects</label>
                        <textarea
                          className="w-full rounded-xl bg-buddy-surface border border-buddy-red/20 px-3 py-2 text-xs focus:outline-none focus:border-buddy-red transition-colors resize-none"
                          rows={2}
                          value={block.warnings}
                          onChange={(e) => updateScheduleBlock(block.id, 'warnings', e.target.value)}
                          placeholder="e.g. Avoid if you have knee issues..."
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <Button variant="outline" className="w-full border-dashed border-buddy-electric text-buddy-electric hover:bg-buddy-electric/10" onClick={addScheduleBlock}>
                <Plus size={16} className="mr-1" /> Add Another Schedule Block
              </Button>

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(1)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90" onClick={() => setStep(3)}>Next: Reminders</Button>
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
                  <h2 className="text-xl font-bold">Workout Reminders</h2>
                </div>
                <p className="text-sm text-buddy-text-secondary">Push notifications to keep subscribers accountable.</p>
              </div>

              <div className="flex items-center justify-between p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised">
                <div>
                  <p className="font-semibold text-sm">Enable Workout Reminders</p>
                  <p className="text-xs text-buddy-text-secondary">Remind users before scheduled sessions</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" className="sr-only peer" checked={form.notification_config.enabled} onChange={(e) => setForm({ ...form, notification_config: { ...form.notification_config, enabled: e.target.checked } })} />
                  <div className="w-11 h-6 bg-buddy-surface-raised peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-buddy-orange"></div>
                </label>
              </div>

              {form.notification_config.enabled && (
                <div className="space-y-4 p-4 border border-buddy-orange/20 bg-buddy-orange/5 rounded-xl">
                  <div>
                    <label className="text-sm font-semibold mb-1.5 block">Reminder Frequency</label>
                    <select
                      className="w-full rounded-xl bg-buddy-black border border-buddy-orange/20 px-4 py-3 text-sm focus:outline-none focus:border-buddy-orange transition-colors"
                      value={form.notification_config.frequency}
                      onChange={(e) => setForm({ ...form, notification_config: { ...form.notification_config, frequency: e.target.value } })}
                    >
                      <option value="15m">15 minutes before</option>
                      <option value="30m">30 minutes before</option>
                      <option value="1h">1 hour before</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-sm font-semibold mb-1.5 block">Custom Message</label>
                    <textarea
                      className="w-full rounded-xl bg-buddy-black border border-buddy-orange/20 px-4 py-3 text-sm focus:outline-none focus:border-buddy-orange transition-colors resize-none"
                      rows={3}
                      value={form.notification_config.custom_message}
                      onChange={(e) => setForm({ ...form, notification_config: { ...form.notification_config, custom_message: e.target.value } })}
                      placeholder="Enter a motivational reminder message..."
                    />
                  </div>
                </div>
              )}

              <div className="flex gap-3 pt-2">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(2)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90" onClick={() => setStep(4)}>Next: Pricing</Button>
              </div>
            </Card>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-6 animate-in slide-in-from-right-4 fade-in duration-300">
            <Card className="p-6 space-y-5 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
              <div className="space-y-1">
                <h2 className="text-xl font-bold">Pricing & Review</h2>
                <p className="text-sm text-buddy-text-secondary">Set your price in artifacts and review the programme.</p>
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
                        className="pl-9 bg-buddy-surface focus:bg-buddy-black transition-colors focus:border-buddy-electric"
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
                      <Badge variant="electric" label={form.category.charAt(0).toUpperCase() + form.category.slice(1)} size="sm" className="mt-1" />
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold text-buddy-gold">{form.duration_weeks} Weeks</p>
                      <p className="text-xs text-buddy-text-secondary">{scheduleBlocks.length} Activities</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex gap-3 pt-4 border-t border-buddy-surface-raised">
                <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(3)}>Back</Button>
                <Button className="flex-1 h-12 shadow-lg bg-gradient-to-r from-buddy-electric to-blue-400 text-buddy-black font-bold" onClick={handleSubmit} isLoading={submitting}>
                  {isEditing ? 'Save Changes' : 'Publish Programme'}
                </Button>
              </div>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
