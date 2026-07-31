import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, AlertCircle, Plus, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { ImageUploadField } from '@/components/ui/ImageUploadField';
import { marketplaceApi } from '@/api';
import type { MarketplaceEvent } from '@/api/marketplace';

const EVENT_CATEGORIES = [
  'fitness', 'wellness', 'nutrition', 'mindfulness', 'challenge', 'community', 'other',
];

const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

function computeEarlyBirdPct(base: Record<string, number> | undefined, early: Record<string, number> | undefined): number {
  if (!base || !early) return 0;
  for (const [at, qty] of Object.entries(base)) {
    if (qty > 0 && early[at]) return Math.round((1 - early[at] / qty) * 100);
  }
  return 0;
}

export default function CreateEvent() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const editId = searchParams.get('edit');
  const isEditing = Boolean(editId);
  const [step, setStep] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(isEditing);
  const [error, setError] = useState('');
  const [myShops, setMyShops] = useState<any[]>([]);
  const [selectedShop, setSelectedShop] = useState('');
  const [agenda, setAgenda] = useState<{ title: string; time: string }[]>([]);
  const [tierRows, setTierRows] = useState<{ name: string; price: string; perks: string }[]>([]);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: 'fitness',
    event_type: 'in_person',
    location: '',
    online_url: '',
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
    start_date: '',
    start_time: '',
    end_date: '',
    end_time: '',
    capacity: '0',
    is_free: true,
    cover_image_url: '',
    gallery_urls: '',
    promo_video_url: '',
    recurrence: 'none',
    early_bird_until: '',
    early_bird_pct: '0',
    cancellation_policy: '',
    is_draft: false,
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, type) => ({ ...acc, [type]: 0 }), {} as Record<string, number>),
  });

  useEffect(() => {
    marketplaceApi.getMyShops()
      .then((res) => {
        const shops = res.data || [];
        setMyShops(shops);
        if (shops.length > 0) setSelectedShop(shops[0].id);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    if (!editId) return;
    marketplaceApi.getEvent(editId)
      .then((res) => {
        const ev: MarketplaceEvent = res.data;
        const start = new Date(ev.start_datetime);
        const end = new Date(ev.end_datetime);
        const pad = (n: number) => String(n).padStart(2, '0');
        setFormData({
          title: ev.title,
          description: ev.description || '',
          category: ev.category || 'fitness',
          event_type: ev.event_type,
          location: ev.location || '',
          online_url: ev.online_url || '',
          timezone: ev.timezone || 'UTC',
          start_date: `${start.getFullYear()}-${pad(start.getMonth() + 1)}-${pad(start.getDate())}`,
          start_time: `${pad(start.getHours())}:${pad(start.getMinutes())}`,
          end_date: `${end.getFullYear()}-${pad(end.getMonth() + 1)}-${pad(end.getDate())}`,
          end_time: `${pad(end.getHours())}:${pad(end.getMinutes())}`,
          capacity: String(ev.capacity || 0),
          is_free: ev.is_free,
          cover_image_url: ev.cover_image_url || '',
          gallery_urls: (ev.gallery_urls || []).join('\n'),
          promo_video_url: ev.promo_video_url || '',
          recurrence: ev.recurrence || 'none',
          early_bird_until: ev.early_bird_deadline ? ev.early_bird_deadline.slice(0, 16) : '',
          early_bird_pct: String(computeEarlyBirdPct(ev.ticket_price_artifacts, ev.early_bird_price_artifacts) || 0),
          cancellation_policy: ev.cancellation_policy || '',
          is_draft: ev.is_draft || false,
          price_artifacts: {
            ...PRICE_ARTIFACTS.reduce((acc, type) => ({ ...acc, [type]: 0 }), {} as Record<string, number>),
            ...(ev.ticket_price_artifacts || {}),
          },
        });
        setAgenda((ev.agenda || []).map((a: any) => ({ title: a.title || '', time: a.time || a.start_time || '' })));
        setTierRows((ev.ticket_tiers || []).map((t: any) => ({ name: t.name || '', price: String(t.price_artifacts?.sprint ?? t.price ?? ''), perks: (t.perks || []).join('\n') })));
        if (ev.shop_data?.id) setSelectedShop(ev.shop_data.id);
        setIsLoading(false);
      })
      .catch(() => { setIsLoading(false); navigate('/marketplace/creator'); });
  }, [editId]);

  const canProceedToStep2 = formData.title.trim().length > 0 && formData.description.trim().length > 0;
  const canProceedToStep3 = Boolean(formData.start_date && formData.start_time && formData.end_date && formData.end_time);
  const canProceedToStep4 = formData.event_type === 'online'
    ? Boolean(formData.online_url.trim())
    : Boolean(formData.location.trim());

  const handleSubmit = async () => {
    setIsSubmitting(true);
    setError('');

    try {
      const payload: Record<string, unknown> = {
        title: formData.title,
        description: formData.description,
        category: formData.category,
        event_type: formData.event_type,
        timezone: formData.timezone,
        start_datetime: new Date(`${formData.start_date}T${formData.start_time}`).toISOString(),
        end_datetime: new Date(`${formData.end_date}T${formData.end_time}`).toISOString(),
        capacity: parseInt(formData.capacity, 10) || 0,
        is_free: formData.is_free,
        cover_image_url: formData.cover_image_url || undefined,
        agenda,
        gallery_urls: formData.gallery_urls.split('\n').map((s) => s.trim()).filter(Boolean),
        promo_video_url: formData.promo_video_url || '',
        cancellation_policy: formData.cancellation_policy,
        is_draft: formData.is_draft,
        recurrence: formData.recurrence,
      };

      if (!formData.is_free) {
        const artifacts: Record<string, number> = {};
        PRICE_ARTIFACTS.forEach((type) => {
          const quantity = formData.price_artifacts[type];
          if (quantity > 0) artifacts[type] = quantity;
        });
        payload.ticket_price_artifacts = artifacts;
      }

      const earlyBirdEnabled = Boolean(formData.early_bird_until) && Number(formData.early_bird_pct) > 0;
      payload.early_bird_enabled = earlyBirdEnabled;
      payload.early_bird_deadline = earlyBirdEnabled ? new Date(formData.early_bird_until).toISOString() : null;
      if (earlyBirdEnabled) {
        const pct = Number(formData.early_bird_pct);
        const discounted: Record<string, number> = {};
        Object.entries((payload.ticket_price_artifacts as Record<string, number>) || {}).forEach(([at, qty]) => {
          discounted[at] = Math.max(1, Math.round(qty * ((100 - pct) / 100)));
        });
        payload.early_bird_price_artifacts = discounted;
      } else {
        payload.early_bird_price_artifacts = {};
      }

      if (!formData.is_free) {
        payload.ticket_tiers = tierRows
          .filter((t) => t.name.trim())
          .map((t) => ({ name: t.name.trim(), price_artifacts: { sprint: Number(t.price) || 0 }, perks: t.perks.split('\n').map((s) => s.trim()).filter(Boolean) }));
      } else {
        payload.ticket_tiers = [];
      }

      if (selectedShop) payload.shop_id = selectedShop;
      if (formData.event_type !== 'online') payload.location = formData.location;
      if (formData.event_type !== 'in_person') payload.online_url = formData.online_url;

      const res = isEditing && editId
        ? await marketplaceApi.updateEvent(editId, payload)
        : await marketplaceApi.createEvent(payload);
      navigate(`/marketplace/events/${res.data.id}`);
    } catch (err: any) {
      setError(err?.response?.data?.message || err?.message || 'Failed to save event.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) return <div className="p-4 text-center">Loading event...</div>;

  return (
    <div className="max-w-lg mx-auto p-4 pb-20">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="text-buddy-text-secondary hover:text-buddy-text-primary transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-2xl font-bold">{isEditing ? 'Edit Event' : 'Create Event'}</h1>
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
              <label className="text-sm font-semibold mb-1 block">Event Title</label>
              <Input
                placeholder="e.g. Summer Beach Workout"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Description</label>
              <textarea
                className="w-full bg-buddy-surface-raised rounded-xl p-3 text-sm focus:outline-none focus:ring-1 focus:ring-buddy-green min-h-[120px] resize-y"
                placeholder="Tell people what this event is about..."
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Category</label>
              <select
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              >
                {EVENT_CATEGORIES.map((category) => (
                  <option key={category} value={category}>{category.replace('_', ' ').replace(/\b\w/g, (c) => c.toUpperCase())}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Event Type</label>
              <div className="flex bg-buddy-surface-raised rounded-lg p-1">
                {['in_person', 'online', 'hybrid'].map((type) => (
                  <button
                    key={type}
                    type="button"
                    onClick={() => setFormData({ ...formData, event_type: type })}
                    className={`flex-1 py-2 text-xs font-medium rounded-md transition-colors ${formData.event_type === type ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}
                  >
                    {type.replace('_', ' ')}
                  </button>
                ))}
              </div>
            </div>

            <Button className="w-full" onClick={() => setStep(2)} disabled={!canProceedToStep2}>
              Next: When & Where
            </Button>
          </Card>
        )}

        {step === 2 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Start Date & Time</label>
              <div className="grid grid-cols-2 gap-4">
                <Input type="date" value={formData.start_date} onChange={(e) => setFormData({ ...formData, start_date: e.target.value })} />
                <Input type="time" value={formData.start_time} onChange={(e) => setFormData({ ...formData, start_time: e.target.value })} />
              </div>
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">End Date & Time</label>
              <div className="grid grid-cols-2 gap-4">
                <Input type="date" value={formData.end_date} onChange={(e) => setFormData({ ...formData, end_date: e.target.value })} />
                <Input type="time" value={formData.end_time} onChange={(e) => setFormData({ ...formData, end_time: e.target.value })} />
              </div>
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Timezone</label>
              <Input value={formData.timezone} onChange={(e) => setFormData({ ...formData, timezone: e.target.value })} />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Recurrence</label>
              <select
                className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                value={formData.recurrence}
                onChange={(e) => setFormData({ ...formData, recurrence: e.target.value })}
              >
                <option value="none">One-time</option>
                <option value="daily">Daily</option>
                <option value="weekly">Weekly</option>
                <option value="monthly">Monthly</option>
              </select>
            </div>

            {formData.event_type !== 'online' && (
              <div>
                <label className="text-sm font-semibold mb-1 block">Location</label>
                <Input placeholder="Address or venue name" value={formData.location} onChange={(e) => setFormData({ ...formData, location: e.target.value })} />
              </div>
            )}

            {formData.event_type !== 'in_person' && (
              <div>
                <label className="text-sm font-semibold mb-1 block">Online Link</label>
                <Input type="url" placeholder="https://zoom.us/j/..." value={formData.online_url} onChange={(e) => setFormData({ ...formData, online_url: e.target.value })} />
              </div>
            )}

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(1)}>
                Back
              </Button>
              <Button className="flex-1" onClick={() => setStep(3)} disabled={!canProceedToStep3 || !canProceedToStep4}>
                Next: Cover & Tickets
              </Button>
            </div>
          </Card>
        )}

        {step === 3 && (
          <Card className="p-5 space-y-4">
            <div>
              <label className="text-sm font-semibold mb-1 block">Cover Photo</label>
              <ImageUploadField
                value={formData.cover_image_url}
                onChange={(url) => setFormData({ ...formData, cover_image_url: url })}
                label="Event Cover Image"
              />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Gallery Media (one URL per line)</label>
              <textarea
                className="w-full bg-buddy-surface-raised rounded-xl p-3 text-sm font-mono focus:outline-none focus:ring-1 focus:ring-buddy-green min-h-[80px] resize-y"
                placeholder={'https://res.cloudinary.com/.../photo.jpg\nhttps://res.cloudinary.com/.../video.mp4'}
                value={formData.gallery_urls}
                onChange={(e) => setFormData({ ...formData, gallery_urls: e.target.value })}
              />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Promo Video URL</label>
              <Input type="url" placeholder="https://..." value={formData.promo_video_url} onChange={(e) => setFormData({ ...formData, promo_video_url: e.target.value })} />
            </div>

            <div>
              <label className="text-sm font-semibold mb-1 block">Capacity</label>
              <Input type="number" min="0" value={formData.capacity} onChange={(e) => setFormData({ ...formData, capacity: e.target.value })} />
            </div>

            <div className="flex items-center justify-between py-2 border-b border-buddy-surface-raised">
              <div>
                <p className="text-sm font-medium">Free Event</p>
                <p className="text-xs text-buddy-text-secondary">No tickets required</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" className="sr-only peer" checked={formData.is_free} onChange={(e) => setFormData({ ...formData, is_free: e.target.checked })} />
                <div className="w-11 h-6 bg-buddy-surface-raised peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-buddy-green"></div>
              </label>
            </div>

            {!formData.is_free && (
              <div className="space-y-3">
                <p className="text-xs font-semibold text-buddy-text-secondary">Base Ticket Price</p>
                <div className="grid grid-cols-2 gap-4">
                  {PRICE_ARTIFACTS.map((artifact) => (
                    <div key={artifact}>
                      <label className="text-xs text-buddy-text-secondary mb-1 block capitalize">{artifact}</label>
                      <div className="relative">
                        <div className="absolute left-3 top-1/2 -translate-y-1/2">
                          <ArtifactIcon artifact={artifact.toUpperCase() as any} size={16} />
                        </div>
                        <Input type="number" min={0} className="pl-9" value={formData.price_artifacts[artifact] ?? 0} onChange={(e) => setFormData({ ...formData, price_artifacts: { ...formData.price_artifacts, [artifact]: parseInt(e.target.value, 10) || 0 } })} />
                      </div>
                    </div>
                  ))}
                </div>

                <div className="pt-2 border-t border-buddy-surface-raised">
                  <p className="text-xs font-semibold text-buddy-text-secondary mb-2">Ticket Tiers (optional)</p>
                  <div className="space-y-2">
                    {tierRows.map((tier, i) => (
                      <div key={i} className="rounded-xl bg-buddy-surface p-3 space-y-2">
                        <div className="flex items-center gap-2">
                          <Input placeholder="Tier name (e.g. VIP)" value={tier.name} onChange={(e) => setTierRows(tierRows.map((t, j) => j === i ? { ...t, name: e.target.value } : t))} />
                          <Input type="number" placeholder="sprint price" value={tier.price} onChange={(e) => setTierRows(tierRows.map((t, j) => j === i ? { ...t, price: e.target.value } : t))} />
                          <button type="button" onClick={() => setTierRows(tierRows.filter((_, j) => j !== i))} className="p-2 text-buddy-red shrink-0"><X size={16} /></button>
                        </div>
                        <Input placeholder="Perks (one per line)" value={tier.perks} onChange={(e) => setTierRows(tierRows.map((t, j) => j === i ? { ...t, perks: e.target.value } : t))} />
                      </div>
                    ))}
                    <Button size="sm" variant="secondary" onClick={() => setTierRows([...tierRows, { name: '', price: '', perks: '' }])} className="w-full">
                      <Plus size={14} className="mr-1" /> Add Tier
                    </Button>
                  </div>
                </div>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-semibold mb-1 block">Early Bird Until</label>
                <Input type="datetime-local" value={formData.early_bird_until} onChange={(e) => setFormData({ ...formData, early_bird_until: e.target.value })} />
              </div>
              <div>
                <label className="text-sm font-semibold mb-1 block">Early Bird %</label>
                <Input type="number" min="0" max="100" value={formData.early_bird_pct} onChange={(e) => setFormData({ ...formData, early_bird_pct: e.target.value })} />
              </div>
            </div>

            {myShops.length > 0 && (
              <div>
                <label className="text-sm font-semibold mb-1 block">Host as Shop</label>
                <select
                  className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                  value={selectedShop}
                  onChange={(e) => setSelectedShop(e.target.value)}
                >
                  {myShops.map((shop) => (
                    <option key={shop.id} value={shop.id}>{shop.name}</option>
                  ))}
                </select>
              </div>
            )}

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
            <div className="space-y-3">
              <div>
                <h2 className="text-lg font-semibold">Review your event</h2>
                <p className="text-sm text-buddy-text-secondary">Confirm all details before publishing.</p>
              </div>

              <div className="rounded-2xl border border-buddy-surface p-4 space-y-3">
                {formData.cover_image_url && (
                  <img src={formData.cover_image_url} alt="Cover preview" className="w-full h-48 object-cover rounded-xl" />
                )}
                <div>
                  <p className="text-sm font-semibold">{formData.title}</p>
                  <p className="text-xs text-buddy-text-secondary">{formData.category.replace('_', ' ')}</p>
                </div>
                <p className="text-sm text-buddy-text-secondary">{formData.description}</p>
                <div className="grid grid-cols-2 gap-2 text-xs text-buddy-text-secondary">
                  <div>
                    <span className="font-semibold">Type:</span> {formData.event_type.replace('_', ' ')}
                  </div>
                  <div>
                    <span className="font-semibold">When:</span> {formData.start_date} {formData.start_time} — {formData.end_date} {formData.end_time}
                  </div>
                  <div>
                    <span className="font-semibold">Where:</span> {formData.event_type === 'online' ? formData.online_url : formData.location}
                  </div>
                  <div>
                    <span className="font-semibold">Capacity:</span> {formData.capacity || 'Unlimited'}
                  </div>
                </div>
                {formData.recurrence !== 'none' && (
                  <p className="text-xs text-buddy-electric"><span className="font-semibold">Repeats:</span> {formData.recurrence}</p>
                )}
                {!formData.is_free && (
                  <div className="space-y-2">
                    <div className="text-xs text-buddy-text-secondary font-semibold">Ticket Pricing</div>
                    <div className="grid grid-cols-2 gap-2">
                      {PRICE_ARTIFACTS.filter((type) => formData.price_artifacts[type] > 0).map((type) => (
                        <div key={type} className="rounded-xl bg-buddy-surface p-3 text-xs">
                          <span className="font-medium capitalize">{type}</span>: {formData.price_artifacts[type]}
                        </div>
                      ))}
                    </div>
                    {tierRows.filter((t) => t.name.trim()).length > 0 && (
                      <div>
                        <p className="text-xs text-buddy-text-secondary font-semibold mb-1">Tiers</p>
                        {tierRows.filter((t) => t.name.trim()).map((t, i) => (
                          <p key={i} className="text-xs"><span className="font-semibold">{t.name}</span> — {t.price} sprint {t.perks.trim() && `· ${t.perks.trim().split('\n').join(', ')}`}</p>
                        ))}
                      </div>
                    )}
                  </div>
                )}
                {formData.early_bird_until && formData.early_bird_pct !== '0' && (
                  <p className="text-xs text-buddy-green"><span className="font-semibold">Early bird:</span> {formData.early_bird_pct}% off until {formData.early_bird_until}</p>
                )}
                {agenda.length > 0 && (
                  <p className="text-xs text-buddy-text-secondary"><span className="font-semibold">Agenda:</span> {agenda.length} session{agenda.length > 1 ? 's' : ''}</p>
                )}
                {formData.is_draft && (
                  <p className="text-xs text-buddy-orange font-semibold">Saved as draft — not published yet</p>
                )}
              </div>
            </div>

            {error && (
              <div className="p-3 bg-red-500/10 border border-red-500/20 rounded-xl flex items-start gap-2">
                <AlertCircle className="text-red-400 shrink-0 mt-0.5" size={16} />
                <p className="text-sm text-red-400">{error}</p>
              </div>
            )}

            <div>
              <label className="text-sm font-semibold mb-1 block">Cancellation Policy</label>
              <textarea
                className="w-full bg-buddy-surface-raised rounded-xl p-3 text-sm focus:outline-none focus:ring-1 focus:ring-buddy-green min-h-[80px] resize-y"
                placeholder="e.g. Full refund up to 48 hours before start..."
                value={formData.cancellation_policy}
                onChange={(e) => setFormData({ ...formData, cancellation_policy: e.target.value })}
              />
            </div>

            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="is_draft"
                checked={formData.is_draft}
                onChange={(e) => setFormData({ ...formData, is_draft: e.target.checked })}
                className="accent-buddy-green"
              />
              <label htmlFor="is_draft" className="text-sm text-buddy-text-secondary">Save as draft (don't publish yet)</label>
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(3)}>
                Back
              </Button>
              <Button className="flex-1" onClick={handleSubmit} isLoading={isSubmitting} disabled={isSubmitting || !formData.title || !canProceedToStep4}>
                {isEditing ? 'Save Changes' : 'Publish Event'}
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
