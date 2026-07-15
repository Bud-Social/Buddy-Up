import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Check, Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { sessionsApi, type TrainerProfile } from '@/api/sessions';
import { useAuthStore } from '@/store/authStore';

const SESSION_TYPES = [
  { value: '1on1_live', label: '1:1 Live' },
  { value: 'group_live', label: 'Group Live' },
  { value: 'async', label: 'Async Programme' },
  { value: 'nutrition', label: 'Nutrition Consultation' },
  { value: 'in_person', label: 'In-Person' },
];

const DURATIONS = [30, 60, 90] as const;

export default function CreateSessionOffering() {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const [specialtyInput, setSpecialtyInput] = useState('');
  const [specialties, setSpecialties] = useState<string[]>([]);
  const [languageInput, setLanguageInput] = useState('');
  const [languages, setLanguages] = useState<string[]>([]);
  const [sessionTypes, setSessionTypes] = useState<string[]>([]);
  const [pricing, setPricing] = useState<Record<string, number>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!profile || (profile.role !== 'trainer' && profile.role !== 'practitioner')) {
      setIsLoading(false);
      return;
    }

    sessionsApi.getTrainer(profile.username)
      .then((res) => {
        const trainer = res.data;
        setSpecialties(trainer.specialties || []);
        setLanguages(trainer.languages || []);
        setSessionTypes(trainer.session_types || []);
        const pricingValues: Record<string, number> = {};
        Object.entries(trainer.pricing || {}).forEach(([key, value]) => {
          if (value && typeof value === 'object' && typeof value.quantity === 'number') {
            pricingValues[key] = value.quantity;
          }
        });
        setPricing(pricingValues);
      })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [profile]);

  const addSpecialty = () => {
    const value = specialtyInput.trim();
    if (!value || specialties.includes(value)) return;
    setSpecialties((prev) => [...prev, value]);
    setSpecialtyInput('');
  };

  const addLanguage = () => {
    const value = languageInput.trim();
    if (!value || languages.includes(value)) return;
    setLanguages((prev) => [...prev, value]);
    setLanguageInput('');
  };

  const toggleSessionType = (type: string) => {
    setSessionTypes((prev) =>
      prev.includes(type) ? prev.filter((item) => item !== type) : [...prev, type]
    );
  };

  const setPricingQuantity = (type: string, duration: number, quantity: number) => {
    const key = `${type}_${duration}`;
    setPricing((prev) => ({ ...prev, [key]: quantity }));
  };

  const handleSave = async () => {
    if (!profile || (profile.role !== 'trainer' && profile.role !== 'practitioner')) return;
    setIsSubmitting(true);
    setError('');

    const payload: Record<string, unknown> = {
      specialties,
      languages,
      session_types: sessionTypes,
      pricing: Object.fromEntries(
        Object.entries(pricing).map(([key, quantity]) => [key, { artifact_type: 'dumbbell', quantity }])
      ),
    };

    try {
      await sessionsApi.updateTrainer(profile.username, payload as Partial<TrainerProfile>);
      navigate('/sessions');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Failed to save session offering.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!profile) {
    return (
      <div className="max-w-lg mx-auto p-4">
        <p className="text-buddy-text-secondary">Please sign in to manage your session offerings.</p>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="max-w-lg mx-auto p-4">
        <p className="text-buddy-text-secondary">Loading session offering details…</p>
      </div>
    );
  }

  if (profile.role !== 'trainer' && profile.role !== 'practitioner') {
    return (
      <div className="max-w-lg mx-auto p-4">
        <p className="text-buddy-text-secondary">Only verified trainers and practitioners can publish session offerings.</p>
      </div>
    );
  }

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">←</button>
        <h1 className="font-display text-2xl font-extrabold">Create Session Offering</h1>
      </div>

      {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

      <div className="space-y-5">
        <div>
          <p className="text-sm font-medium text-buddy-text-secondary mb-2">Specialties</p>
          <div className="flex gap-2 mb-3 flex-wrap">
            {specialties.map((specialty) => (
              <span key={specialty} className="text-xs bg-buddy-surface px-3 py-1 rounded-full flex items-center gap-2">
                {specialty}
                <button onClick={() => setSpecialties(specialties.filter((item) => item !== specialty))} className="text-buddy-red">×</button>
              </span>
            ))}
          </div>
          <div className="flex gap-2">
            <Input value={specialtyInput} onChange={(e) => setSpecialtyInput(e.target.value)} placeholder="Add specialty" onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addSpecialty())} />
            <Button variant="outline" size="sm" onClick={addSpecialty}>
              <Plus size={16} /> Add
            </Button>
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-buddy-text-secondary mb-2">Languages</p>
          <div className="flex gap-2 mb-3 flex-wrap">
            {languages.map((language) => (
              <span key={language} className="text-xs bg-buddy-surface px-3 py-1 rounded-full flex items-center gap-2">
                {language}
                <button onClick={() => setLanguages(languages.filter((item) => item !== language))} className="text-buddy-red">×</button>
              </span>
            ))}
          </div>
          <div className="flex gap-2">
            <Input value={languageInput} onChange={(e) => setLanguageInput(e.target.value)} placeholder="Add language" onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addLanguage())} />
            <Button variant="outline" size="sm" onClick={addLanguage}>
              <Plus size={16} /> Add
            </Button>
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-buddy-text-secondary mb-2">Session Types</p>
          <div className="grid grid-cols-2 gap-2">
            {SESSION_TYPES.map(({ value, label }) => (
              <button key={value} type="button" onClick={() => toggleSessionType(value)}
                className={`rounded-2xl border px-3 py-2 text-sm text-left transition ${sessionTypes.includes(value) ? 'border-buddy-green bg-buddy-green/5 text-buddy-text-primary' : 'border-buddy-surface text-buddy-text-secondary hover:border-buddy-text-secondary/50'}`}>
                {label}
              </button>
            ))}
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-buddy-text-secondary mb-2">Pricing (quantity of dumbbells per session)</p>
          {sessionTypes.length === 0 ? (
            <p className="text-xs text-buddy-text-secondary/60">Select session types to configure pricing.</p>
          ) : (
            <div className="space-y-3">
              {sessionTypes.map((type) => (
                <div key={type} className="rounded-2xl border border-buddy-surface p-4">
                  <p className="text-sm font-semibold mb-3">{SESSION_TYPES.find((item) => item.value === type)?.label || type}</p>
                  <div className="grid grid-cols-3 gap-3">
                    {DURATIONS.map((duration) => {
                      const key = `${type}_${duration}`;
                      return (
                        <label key={key} className="space-y-2 text-sm text-buddy-text-secondary">
                          <span>{duration} min</span>
                          <Input type="number" min={0} step={1} value={pricing[key] ?? ''}
                            onChange={(e) => setPricingQuantity(type, duration, e.target.value ? parseInt(e.target.value, 10) : 0)}
                            placeholder="0" />
                        </label>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="flex gap-3">
          <Button variant="ghost" onClick={() => navigate('/sessions')} className="flex-1">Cancel</Button>
          <Button className="flex-1" size="lg" onClick={handleSave} isLoading={isSubmitting}>
            <Check size={16} className="mr-2" /> Save Offerings
          </Button>
        </div>
      </div>
    </div>
  );
}
