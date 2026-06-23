import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Globe, Lock, EyeOff, Image } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { gymsApi } from '@/api/gyms';

const categories = ['fitness', 'nutrition', 'yoga_wellness', 'strength', 'cardio_running', 'sport_specific', 'mixed', 'other'];

export default function CreateGymPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [name, setName] = useState('');
  const [handle, setHandle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('fitness');
  const [accessType, setAccessType] = useState('public');
  const [subscriptionType, setSubscriptionType] = useState('free');
  const [location, setLocation] = useState('');
  const [rules, setRules] = useState<string[]>(['']);
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleCreate = async () => {
    if (!name.trim() || !handle.trim()) return;
    setIsSubmitting(true);
    setError('');
    try {
      await gymsApi.create({
        name: name.trim(),
        handle: handle.trim().toLowerCase(),
        description: description.trim(),
        category,
        access_type: accessType,
        subscription_type: subscriptionType,
        location_city: location || undefined,
        rules: rules.filter(Boolean),
        tags,
      });
      navigate(`/gyms/${handle.trim().toLowerCase()}`);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Failed to create gym.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const addTag = () => {
    if (tagInput.trim() && !tags.includes(tagInput.trim()) && tags.length < 10) {
      setTags([...tags, tagInput.trim()]);
      setTagInput('');
    }
  };

  const updateRule = (index: number, value: string) => {
    const updated = [...rules];
    updated[index] = value;
    if (index === updated.length - 1 && value && updated.length < 10) updated.push('');
    setRules(updated.filter((r, i) => r || i < updated.length - 1));
  };

  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-lg mx-auto p-4">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">←</button>
          <h1 className="font-display text-2xl font-extrabold">Create Gym</h1>
        </div>

        <div className="flex gap-1 mb-6">
          {[1, 2].map((s) => (
            <div key={s} className={`flex-1 h-1 rounded-full ${s <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
          ))}
        </div>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        {step === 1 && (
          <div className="space-y-4">
            <Input label="Gym Name" value={name} onChange={(e) => setName(e.target.value)}
              placeholder="e.g., Iron Core Gym" maxLength={60} required />
            <Input label="Gym Handle" value={handle} onChange={(e) => setHandle(e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, ''))}
              placeholder="e.g., iron_core" maxLength={60} helperText="Unique handle for @gymhandle tags" required />
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Description</label>
              <textarea value={description} onChange={(e) => setDescription(e.target.value)}
                placeholder="What's your gym about?"
                className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-24"
                maxLength={500} />
            </div>
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Category</label>
              <div className="flex flex-wrap gap-2">
                {categories.map((c) => (
                  <button key={c} onClick={() => setCategory(c)}
                    className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${category === c ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
                  >{c.replace('_', ' ')}</button>
                ))}
              </div>
            </div>
            <Button className="w-full" size="lg" onClick={() => setStep(2)} disabled={!name || !handle}>Next</Button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Access Type</label>
              <div className="space-y-2">
                {[
                  { value: 'public', icon: Globe, label: 'Public', desc: 'Anyone can find and join this gym' },
                  { value: 'private', icon: Lock, label: 'Private', desc: 'Users must request to join. You approve.' },
                  { value: 'secret', icon: EyeOff, label: 'Secret', desc: 'Invite-only. Not discoverable.' },
                ].map(({ value, icon: Icon, label, desc }) => (
                  <button key={value} onClick={() => setAccessType(value)}
                    className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${accessType === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
                    <div className="flex items-center gap-3"><Icon size={20} className="text-buddy-green" />
                      <div><p className="font-medium text-sm">{label}</p><p className="text-xs text-buddy-text-secondary">{desc}</p></div>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Subscription Model</label>
              <div className="flex flex-wrap gap-2">
                {['free', 'paid'].map((s) => (
                  <button key={s} onClick={() => setSubscriptionType(s)}
                    className={`px-4 py-2 rounded-full text-sm capitalize transition-colors ${subscriptionType === s ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
                  >{s}</button>
                ))}
              </div>
            </div>

            <Input label="Location (optional)" value={location} onChange={(e) => setLocation(e.target.value)} placeholder="City, Country" />

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Community Rules (up to 10)</label>
              {rules.map((rule, i) => (
                <Input key={i} value={rule} onChange={(e) => updateRule(i, e.target.value)}
                  placeholder={`Rule ${i + 1}`} className="mb-2" />
              ))}
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Tags (up to 10)</label>
              <div className="flex gap-2 mb-2 flex-wrap">
                {tags.map((tag) => (
                  <span key={tag} className="text-xs bg-buddy-green/10 text-buddy-green px-3 py-1 rounded-full flex items-center gap-1">{tag}
                    <button onClick={() => setTags(tags.filter((t) => t !== tag))} className="hover:text-buddy-red">×</button>
                  </span>
                ))}
              </div>
              <div className="flex gap-2">
                <Input value={tagInput} onChange={(e) => setTagInput(e.target.value)} placeholder="Add tag..."
                  onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())} />
                <Button variant="outline" size="sm" onClick={addTag}>Add</Button>
              </div>
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => setStep(1)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" onClick={handleCreate} isLoading={isSubmitting}>Create Gym</Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
