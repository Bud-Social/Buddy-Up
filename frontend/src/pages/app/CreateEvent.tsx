import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar as CalendarIcon, Clock, MapPin, Link as LinkIcon, AlertCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { gymsApi, marketplaceApi } from '@/api';
import type { Gym } from '@/types';

const EVENT_CATEGORIES = [
  'fitness', 'wellness', 'nutrition', 'mindfulness', 'challenge', 'community', 'other',
];

const PRICE_ARTIFACTS = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;

export default function CreateEvent() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [myGyms, setMyGyms] = useState<Gym[]>([]);
  const [selectedGym, setSelectedGym] = useState('');
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
    price_artifacts: PRICE_ARTIFACTS.reduce((acc, type) => ({ ...acc, [type]: 0 }), {} as Record<string, number>),
  });

  useEffect(() => {
    gymsApi.list({ my: true })
      .then((res) => {
        const adminGyms = (res.data || []).filter((g) => ['owner', 'co_owner', 'moderator'].includes(g.membership_role || ''));
        setMyGyms(adminGyms);
      })
      .catch(() => {});
  }, []);

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
        is_published: true,
      };

      if (selectedGym) payload.gym_id = selectedGym;
      if (formData.event_type !== 'online') payload.location = formData.location;
      if (formData.event_type !== 'in_person') payload.online_url = formData.online_url;

      if (!formData.is_free) {
        const artifacts: Record<string, number> = {};
        PRICE_ARTIFACTS.forEach((type) => {
          const quantity = formData.price_artifacts[type];
          if (quantity > 0) artifacts[type] = quantity;
        });
        payload.ticket_price_artifacts = artifacts;
      }

      const res = await marketplaceApi.createEvent(payload);
      navigate(`/marketplace/events/${res.data.id}`);
    } catch (err: any) {
      setError(err?.message || 'Failed to create event.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-lg mx-auto p-4 pb-20">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="text-buddy-text-secondary hover:text-buddy-text-primary transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-2xl font-bold">Create Event</h1>
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
              <label className="text-sm font-semibold mb-1 block">Cover Photo URL</label>
              <Input type="url" placeholder="https://..." value={formData.cover_image_url} onChange={(e) => setFormData({ ...formData, cover_image_url: e.target.value })} />
              {formData.cover_image_url && (
                <div className="mt-4 overflow-hidden rounded-xl border border-buddy-surface">
                  <img src={formData.cover_image_url} alt="Cover preview" className="w-full h-48 object-cover" />
                </div>
              )}
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
            )}

            {myGyms.length > 0 && (
              <div>
                <label className="text-sm font-semibold mb-1 block">Host as Gym (Optional)</label>
                <select
                  className="w-full rounded-xl bg-buddy-surface border border-buddy-surface-raised px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
                  value={selectedGym}
                  onChange={(e) => setSelectedGym(e.target.value)}
                >
                  <option value="">Personal Event</option>
                  {myGyms.map((gym) => (
                    <option key={gym.id} value={gym.id}>{gym.name}</option>
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
                  </div>
                )}
              </div>
            </div>

            {error && (
              <div className="p-3 bg-red-500/10 border border-red-500/20 rounded-xl flex items-start gap-2">
                <AlertCircle className="text-red-400 shrink-0 mt-0.5" size={16} />
                <p className="text-sm text-red-400">{error}</p>
              </div>
            )}

            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep(3)}>
                Back
              </Button>
              <Button className="flex-1" onClick={handleSubmit} isLoading={isSubmitting} disabled={isSubmitting || !formData.title || !canProceedToStep4}>
                Publish Event
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
