import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Globe, Lock, EyeOff, X, ArrowUp, ArrowDown, Check, AlertCircle, Search } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { gymsApi } from '@/api/gyms';
import type { GymCategory, CityResult, GymCategoryPricing } from '@/types';

const RULE_TEMPLATES = [
  'No harassment or hate speech',
  'Respect all members',
  'No spamming or self-promotion',
  'Keep equipment clean and tidy',
  'Follow trainer instructions',
  'No inappropriate content',
  'Be on time for sessions',
  'No recording without consent',
];

export default function CreateGymPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [name, setName] = useState('');
  const [handle, setHandle] = useState('');
  const [handleAutoGen, setHandleAutoGen] = useState(true);
  const [handleAvailable, setHandleAvailable] = useState<boolean | null>(null);
  const [handleChecking, setHandleChecking] = useState(false);
  const [description, setDescription] = useState('');
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<(string | number)[]>([]);
  const [customCategory, setCustomCategory] = useState('');
  const [categories, setCategories] = useState<GymCategory[]>([]);
  const [accessType, setAccessType] = useState('public');
  const [subscriptionType, setSubscriptionType] = useState('free');
  const [contentRating, setContentRating] = useState<'general' | 'mature'>('general');
  const [locationCity, setLocationCity] = useState('');
  const [locationCountry, setLocationCountry] = useState('');
  const [cityQuery, setCityQuery] = useState('');
  const [cityResults, setCityResults] = useState<CityResult[]>([]);
  const [citySearching, setCitySearching] = useState(false);
  const [showCityDropdown, setShowCityDropdown] = useState(false);
  const [rules, setRules] = useState<string[]>(['']);
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [logoUrl, setLogoUrl] = useState('');
  const [coverUrl, setCoverUrl] = useState('');
  const [categoryPricing, setCategoryPricing] = useState<GymCategoryPricing[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const cityDebounceRef = useRef<ReturnType<typeof setTimeout>>();
  const handleDebounceRef = useRef<ReturnType<typeof setTimeout>>();
  const cityInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    gymsApi.getCategories().then((res) => {
      if (res.success) setCategories(res.data);
    }).catch(() => {});
  }, []);

  const deriveHandle = useCallback((raw: string) => {
    return raw.toLowerCase()
      .replace(/[^a-z0-9\s_-]/g, '')
      .replace(/[\s-]+/g, '_')
      .replace(/_+/g, '_')
      .replace(/^_|_$/g, '')
      .slice(0, 60);
  }, []);

  const checkHandle = useCallback(async (candidate: string) => {
    if (candidate.length < 3) {
      setHandleAvailable(null);
      return;
    }
    setHandleChecking(true);
    try {
      const res = await gymsApi.checkHandle(candidate);
      if (res.success) {
        setHandleAvailable(res.data.available);
        if (!res.data.available && res.data.suggested && handleAutoGen) {
          setHandle(res.data.suggested);
          setHandleAvailable(true);
        }
      }
    } catch {
      setHandleAvailable(null);
    } finally {
      setHandleChecking(false);
    }
  }, [handleAutoGen]);

  const onNameChange = (value: string) => {
    setName(value);
    if (handleAutoGen) {
      const derived = deriveHandle(value);
      setHandle(derived);
      clearTimeout(handleDebounceRef.current);
      handleDebounceRef.current = setTimeout(() => checkHandle(derived), 500);
    }
  };

  const onHandleManualChange = (value: string) => {
    setHandleAutoGen(false);
    const sanitized = value.toLowerCase().replace(/[^a-z0-9_]/g, '');
    setHandle(sanitized);
    clearTimeout(handleDebounceRef.current);
    handleDebounceRef.current = setTimeout(() => checkHandle(sanitized), 500);
  };

  const searchCities = useCallback(async (q: string) => {
    if (q.length < 2) {
      setCityResults([]);
      setCitySearching(false);
      return;
    }
    setCitySearching(true);
    try {
      const res = await gymsApi.searchCities(q);
      if (res.success) setCityResults(res.data);
    } catch {
      setCityResults([]);
    } finally {
      setCitySearching(false);
    }
  }, []);

  const onCityInputChange = (value: string) => {
    setCityQuery(value);
    setShowCityDropdown(true);
    clearTimeout(cityDebounceRef.current);
    cityDebounceRef.current = setTimeout(() => searchCities(value), 300);
  };

  const selectCity = (result: CityResult) => {
    setLocationCity(result.city);
    setLocationCountry(result.country);
    setCityQuery(result.description);
    setShowCityDropdown(false);
  };

  const toggleCategory = (catId: string | number) => {
    setSelectedCategoryIds((prev) =>
      prev.includes(catId) ? prev.filter((id) => id !== catId) : [...prev, catId]
    );
  };

  const addCustomCategory = () => {
    const trimmed = customCategory.trim().toLowerCase().replace(/\s+/g, '_');
    if (!trimmed) return;
    const tempId = `custom_${Date.now()}`;
    const fakeCat: GymCategory = {
      id: tempId, name: trimmed, display_name: customCategory.trim(),
      icon: '', is_active: true,
    };
    setCategories((prev) => [...prev, fakeCat]);
    setSelectedCategoryIds((prev) => [...prev, tempId]);
    setCustomCategory('');
  };

  const pricingForCategory = (catId: string | number) =>
    categoryPricing.find((p) => p.category === catId);

  const updatePricing = (catId: string | number, field: keyof GymCategoryPricing, value: number | boolean | null) => {
    setCategoryPricing((prev) => {
      const existing = prev.find((p) => p.category === catId);
      if (existing) {
        return prev.map((p) => p.category === catId ? { ...p, [field]: value } : p);
      }
      return [...prev, {
        category: catId, fee_per_day: null, fee_per_week: null,
        fee_per_month: null, fee_per_year: null, is_free: false,
        [field]: value,
      } as GymCategoryPricing];
    });
  };

  const addTag = () => {
    const t = tagInput.trim();
    if (t && !tags.includes(t) && tags.length < 10) {
      setTags([...tags, t]);
      setTagInput('');
    }
  };

  const updateRule = (index: number, value: string) => {
    const updated = [...rules];
    updated[index] = value;
    if (index === updated.length - 1 && value && updated.length < 20) updated.push('');
    setRules(updated.filter((r, i) => r || i < updated.length - 1));
  };

  const moveRule = (index: number, direction: -1 | 1) => {
    const target = index + direction;
    if (target < 0 || target >= rules.length) return;
    const updated = [...rules];
    [updated[index], updated[target]] = [updated[target], updated[index]];
    setRules(updated);
  };

  const addRuleTemplate = (template: string) => {
    if (rules.length >= 20) return;
    const lastEmpty = rules.length === 1 && rules[0] === '';
    if (lastEmpty) {
      setRules([template, '']);
    } else {
      setRules([...rules.slice(0, -1), template, '']);
    }
  };

  const categorySuggestions: Record<string, string[]> = {
    fitness: ['cardio', 'hiit', 'functional-training', 'bodyweight'],
    nutrition: ['meal-planning', 'diet-coaching', 'supplements', 'meal-prep'],
    yoga_wellness: ['vinyasa', 'hatha', 'meditation', 'flexibility', 'mindfulness'],
    strength: ['powerlifting', 'bodybuilding', 'strongman', 'resistance-training'],
    cardio_running: ['running', 'cycling', 'endurance', 'marathon-training'],
    sport_specific: ['boxing', 'mma', 'basketball', 'soccer', 'swimming'],
    mixed: ['cross-training', 'general-fitness', 'group-classes'],
  };

  const getSuggestedTags = () => {
    const selectedNames = selectedCategoryIds
      .map((id) => categories.find((c) => c.id === id)?.name)
      .filter(Boolean) as string[];
    const suggestions: string[] = [];
    for (const name of selectedNames) {
      const found = Object.entries(categorySuggestions).find(([key]) => name.includes(key));
      if (found) suggestions.push(...found[1]);
    }
    return [...new Set(suggestions)].slice(0, 5);
  };

  const handleCreate = async () => {
    if (!name.trim() || !handle.trim()) return;
    setIsSubmitting(true);
    setError('');
    try {
      const payload: Record<string, unknown> = {
        name: name.trim(),
        handle: handle.trim().toLowerCase(),
        description: description.trim(),
        category: selectedCategoryIds.map((id) => categories.find((c) => c.id === id)?.name).filter(Boolean).join(',') || 'other',
        category_ids: selectedCategoryIds.filter((id) => !String(id).startsWith('custom_')),
        access_type: accessType,
        subscription_type: subscriptionType,
        content_rating: contentRating,
        location_city: locationCity || undefined,
        location_country: locationCountry || undefined,
        logo_url: logoUrl || undefined,
        cover_url: coverUrl || undefined,
        rules: rules.filter(Boolean),
        tags,
      };

      if (subscriptionType === 'paid' && categoryPricing.length > 0) {
        payload.category_pricing = categoryPricing.map((p) => ({
          category: p.category,
          fee_per_day: p.fee_per_day,
          fee_per_week: p.fee_per_week,
          fee_per_month: p.fee_per_month,
          fee_per_year: p.fee_per_year,
          is_free: p.is_free,
        }));
      }

      await gymsApi.create(payload as never);
      navigate(`/gyms/${handle.trim().toLowerCase()}`);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Failed to create gym.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const isStep1Valid = name.trim() && handle.trim() && selectedCategoryIds.length > 0;
  const canGoNext = step === 1 ? isStep1Valid : true;

  const handleCheckIcon = handleChecking
    ? <AlertCircle size={16} className="text-yellow-400 animate-pulse" />
    : handleAvailable === true
      ? <Check size={16} className="text-buddy-green" />
      : handleAvailable === false
        ? <X size={16} className="text-buddy-red" />
        : null;

  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">←</button>
          <h1 className="font-display text-2xl font-extrabold">Create Gym</h1>
        </div>

        <div className="flex gap-1 mb-6">
          {[1, 2, 3].map((s) => (
            <div key={s} className={`flex-1 h-1 rounded-full ${s <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
          ))}
        </div>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        {step === 1 && (
          <div className="space-y-4">
            <Input label="Gym Name" value={name} onChange={(e) => onNameChange(e.target.value)}
              placeholder="e.g., Iron Core Gym" maxLength={60} required />

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Gym Handle</label>
              <div className="relative">
                <Input value={handle} onChange={(e) => onHandleManualChange(e.target.value)}
                  placeholder="e.g., iron_core" maxLength={60}
                  helperText="Unique handle for @gymhandle tags. Auto-generated from name." required />
                <div className="absolute right-3 top-1/2 -translate-y-1/2">
                  {handleCheckIcon}
                </div>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Description</label>
              <textarea value={description} onChange={(e) => setDescription(e.target.value)}
                placeholder="What's your gym about?"
                className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none h-24"
                maxLength={500} />
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Categories (select all that apply)</label>
              <div className="flex flex-wrap gap-2">
                {categories.map((c) => (
                  <button key={c.id} onClick={() => toggleCategory(c.id)}
                    className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${
                      selectedCategoryIds.includes(c.id)
                        ? 'bg-buddy-green text-buddy-black font-medium'
                        : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                  >{c.display_name}</button>
                ))}
              </div>
              {selectedCategoryIds.some((id) => {
                const cat = categories.find((c) => c.id === id);
                return cat && cat.name === 'other';
              }) && (
                <div className="flex gap-2 mt-2">
                  <Input value={customCategory} onChange={(e) => setCustomCategory(e.target.value)}
                    placeholder="Enter custom category name..." />
                  <Button variant="outline" size="sm" onClick={addCustomCategory} disabled={!customCategory.trim()}>
                    Add
                  </Button>
                </div>
              )}
              {selectedCategoryIds.length > 0 && (
                <div className="flex flex-wrap gap-1 mt-2">
                  {selectedCategoryIds.map((id) => {
                    const cat = categories.find((c) => c.id === id);
                    return cat ? (
                      <span key={id} className="text-xs bg-buddy-green/10 text-buddy-green px-2 py-0.5 rounded-full flex items-center gap-1">
                        {cat.display_name}
                        <button onClick={() => toggleCategory(id)} className="hover:text-buddy-red">×</button>
                      </span>
                    ) : null;
                  })}
                </div>
              )}
            </div>

            <Button className="w-full" size="lg" onClick={() => setStep(2)} disabled={!canGoNext}>Next</Button>
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
                    className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${
                      accessType === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                    }`}>
                    <div className="flex items-center gap-3">
                      <Icon size={20} className="text-buddy-green" />
                      <div>
                        <p className="font-medium text-sm">{label}</p>
                        <p className="text-xs text-buddy-text-secondary">{desc}</p>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Content Rating</label>
              <div className="space-y-2">
                {[
                  { value: 'general' as const, icon: EyeOff, label: 'General (All Ages)', desc: 'Standard fitness content, visible to everyone' },
                  { value: 'mature' as const, icon: Lock, label: 'Mature (18+)', desc: 'Nude/suggestive content, age-gated to verified adults only' },
                ].map(({ value, icon: Icon, label, desc }) => (
                  <button key={value} onClick={() => setContentRating(value)}
                    className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${
                      contentRating === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                    }`}>
                    <div className="flex items-center gap-3">
                      <Icon size={20} className="text-buddy-green" />
                      <div>
                        <p className="font-medium text-sm">{label}</p>
                        <p className="text-xs text-buddy-text-secondary">{desc}</p>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Subscription Model</label>
              <div className="space-y-2">
                {[
                  { value: 'public', icon: Globe, label: 'Public', desc: 'Anyone can find and join this gym' },
                  { value: 'private', icon: Lock, label: 'Private', desc: 'Users must request to join. You approve.' },
                  { value: 'secret', icon: EyeOff, label: 'Secret', desc: 'Invite-only. Not discoverable.' },
                ].map(({ value, icon: Icon, label, desc }) => (
                  <button key={value} onClick={() => setAccessType(value)}
                    className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${
                      accessType === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                    }`}>
                    <div className="flex items-center gap-3">
                      <Icon size={20} className="text-buddy-green" />
                      <div>
                        <p className="font-medium text-sm">{label}</p>
                        <p className="text-xs text-buddy-text-secondary">{desc}</p>
                      </div>
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
                    className={`px-4 py-2 rounded-full text-sm capitalize transition-colors ${
                      subscriptionType === s ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                  >{s === 'paid' ? 'Paid (Membership)' : 'Free'}</button>
                ))}
              </div>
            </div>

            {subscriptionType === 'paid' && selectedCategoryIds.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-2">
                  Category Pricing — set fees per category
                </label>
                <div className="space-y-3">
                  {selectedCategoryIds
                    .filter((id) => !String(id).startsWith('custom_'))
                    .map((catId) => {
                      const cat = categories.find((c) => c.id === catId);
                      if (!cat) return null;
                      const pricing = pricingForCategory(catId);
                      return (
                        <div key={catId} className="bg-buddy-surface rounded-xl p-3 space-y-2">
                          <p className="text-sm font-medium capitalize">{cat.display_name}</p>
                          <div className="grid grid-cols-4 gap-2">
                            {(['day', 'week', 'month', 'year'] as const).map((period) => (
                              <div key={period}>
                                <label className="text-[10px] text-buddy-text-secondary block mb-0.5">
                                  Per {period}
                                </label>
                                <input
                                  type="number" min="0" step="0.01"
                                  value={(pricing?.[`fee_per_${period}` as keyof GymCategoryPricing] as number | null) ?? ''}
                                  onChange={(e) => updatePricing(catId, `fee_per_${period}`, e.target.value ? parseFloat(e.target.value) : null)}
                                  disabled={pricing?.is_free}
                                  className="w-full bg-buddy-black rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary border border-buddy-surface-raised focus:outline-none focus:ring-1 focus:ring-buddy-green/30 disabled:opacity-40"
                                  placeholder="0"
                                />
                              </div>
                            ))}
                          </div>
                          <label className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                            <input type="checkbox" checked={pricing?.is_free ?? false}
                              onChange={(e) => updatePricing(catId, 'is_free', e.target.checked)}
                              className="rounded border-buddy-surface-raised" />
                            Free category
                          </label>
                        </div>
                      );
                    })}
                  {selectedCategoryIds.some((id) => String(id).startsWith('custom_')) && (
                    <p className="text-xs text-buddy-text-secondary">
                      Custom categories use the general gym pricing set via <strong>monthly_fee_artifacts</strong>.
                    </p>
                  )}
                </div>
              </div>
            )}

            <div className="relative">
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Location (optional)</label>
              <div className="relative">
                <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
                <Input
                  ref={cityInputRef}
                  value={cityQuery}
                  onChange={(e) => onCityInputChange(e.target.value)}
                  onFocus={() => cityResults.length > 0 && setShowCityDropdown(true)}
                  onBlur={() => setTimeout(() => setShowCityDropdown(false), 200)}
                  placeholder="Search for a city..."
                  className="pl-9"
                />
              </div>
              {showCityDropdown && (cityResults.length > 0 || citySearching) && (
                <div className="absolute z-10 mt-1 w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl shadow-lg max-h-48 overflow-y-auto">
                  {citySearching ? (
                    <div className="p-3 text-xs text-buddy-text-secondary text-center">Searching...</div>
                  ) : (
                    cityResults.map((r) => (
                      <button key={r.place_id} onMouseDown={() => selectCity(r)}
                        className="w-full text-left px-3 py-2 text-sm text-buddy-text-primary hover:bg-buddy-surface transition-colors">
                        {r.description}
                      </button>
                    ))
                  )}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                Community Rules
                <span className="text-xs text-buddy-text-secondary/60 ml-1">(up to 20, drag to reorder)</span>
              </label>
              <div className="flex flex-wrap gap-1 mb-2">
                {RULE_TEMPLATES.map((template) => (
                  <button key={template} onClick={() => addRuleTemplate(template)}
                    className="text-[10px] bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full transition-colors">
                    + {template}
                  </button>
                ))}
              </div>
              <div className="space-y-1">
                {rules.map((rule, i) => (
                  <div key={i} className="flex items-center gap-1">
                    <span className="text-[10px] text-buddy-text-secondary/40 w-4 text-right shrink-0">{i + 1}</span>
                    <input
                      value={rule}
                      onChange={(e) => updateRule(i, e.target.value)}
                      placeholder={`Rule ${i + 1}`}
                      maxLength={200}
                      className="flex-1 bg-buddy-surface rounded-lg px-3 py-2 text-xs text-buddy-text-primary placeholder:text-buddy-text-secondary/30 focus:outline-none focus:ring-1 focus:ring-buddy-green/30 border border-transparent focus:border-buddy-green/20"
                    />
                    <div className="flex gap-0.5 shrink-0">
                      <button onClick={() => moveRule(i, -1)} disabled={i === 0}
                        className="p-1 rounded hover:bg-buddy-surface text-buddy-text-secondary/40 hover:text-buddy-text-secondary disabled:opacity-20">
                        <ArrowUp size={12} />
                      </button>
                      <button onClick={() => moveRule(i, 1)} disabled={i >= rules.length - 1}
                        className="p-1 rounded hover:bg-buddy-surface text-buddy-text-secondary/40 hover:text-buddy-text-secondary disabled:opacity-20">
                        <ArrowDown size={12} />
                      </button>
                    </div>
                    <span className="text-[10px] text-buddy-text-secondary/30 w-6 text-right shrink-0">{rule.length}/200</span>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                Tags
                <span className="text-xs text-buddy-text-secondary/60 ml-1">(up to 10)</span>
              </label>
              <p className="text-[11px] text-buddy-text-secondary/50 mb-2">
                Tags help users discover your gym through search. Be specific — use
                <span className="text-buddy-text-secondary"> strength-training </span>
                instead of just
                <span className="text-buddy-text-secondary"> fitness</span>.
                Tags are indexed for full-text search across the platform.
              </p>
              {tags.length > 0 && (
                <div className="flex gap-1 mb-2 flex-wrap">
                  {tags.map((tag) => (
                    <span key={tag} className="text-xs bg-buddy-green/10 text-buddy-green px-3 py-1 rounded-full flex items-center gap-1">
                      {tag}
                      <button onClick={() => setTags(tags.filter((t) => t !== tag))} className="hover:text-buddy-red">×</button>
                    </span>
                  ))}
                </div>
              )}
              <div className="flex gap-2">
                <Input value={tagInput} onChange={(e) => setTagInput(e.target.value)} placeholder="Add tag..."
                  onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())} />
                <Button variant="outline" size="sm" onClick={addTag}>Add</Button>
              </div>
              <div className="flex items-center gap-2 mt-1">
                <div className="flex-1 h-1 bg-buddy-surface rounded-full overflow-hidden">
                  <div className="h-full bg-buddy-green transition-all"
                    style={{ width: `${(tags.length / 10) * 100}%` }} />
                </div>
                <span className="text-[10px] text-buddy-text-secondary/50">{tags.length}/10</span>
              </div>
              {getSuggestedTags().length > 0 && (
                <div className="mt-2">
                  <p className="text-[10px] text-buddy-text-secondary/50 mb-1">Suggested based on categories:</p>
                  <div className="flex gap-1 flex-wrap">
                    {getSuggestedTags().map((s) => (
                      <button key={s} onClick={() => {
                        if (!tags.includes(s) && tags.length < 10) setTags([...tags, s]);
                      }}
                        className="text-[10px] bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full">
                        + {s}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => setStep(1)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" onClick={() => setStep(3)} disabled={!canGoNext}>Next</Button>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-5">
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Gym Logo URL</label>
                <Input value={logoUrl} onChange={(e) => setLogoUrl(e.target.value)} placeholder="https://example.com/logo.png" />
                {logoUrl && (
                  <img src={logoUrl} alt="Gym logo preview" className="mt-3 h-20 w-20 rounded-full object-cover border border-buddy-surface" />
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Cover Image URL</label>
                <Input value={coverUrl} onChange={(e) => setCoverUrl(e.target.value)} placeholder="https://example.com/cover.jpg" />
                {coverUrl && (
                  <div className="mt-3 overflow-hidden rounded-2xl border border-buddy-surface">
                    <img src={coverUrl} alt="Gym cover preview" className="h-40 w-full object-cover" />
                  </div>
                )}
              </div>
            </div>

            <div className="rounded-3xl border border-buddy-surface p-4 bg-buddy-surface-raised space-y-3">
              <p className="text-sm font-semibold">Review your gym</p>
              <div className="grid gap-3 text-sm text-buddy-text-secondary">
                <div>
                  <p className="font-medium text-buddy-text-primary">Name</p>
                  <p>{name || '—'}</p>
                </div>
                <div>
                  <p className="font-medium text-buddy-text-primary">Handle</p>
                  <p>@{handle || '—'}</p>
                </div>
                <div>
                  <p className="font-medium text-buddy-text-primary">Description</p>
                  <p>{description || 'No description yet.'}</p>
                </div>
                <div>
                  <p className="font-medium text-buddy-text-primary">Categories</p>
                  <p>{selectedCategoryIds.length > 0 ? selectedCategoryIds.map((id) => categories.find((c) => c.id === id)?.display_name).filter(Boolean).join(', ') : 'None selected'}</p>
                </div>
                <div>
                  <p className="font-medium text-buddy-text-primary">Access</p>
                  <p>{accessType.charAt(0).toUpperCase() + accessType.slice(1)}</p>
                </div>
                <div>
                  <p className="font-medium text-buddy-text-primary">Subscription</p>
                  <p>{subscriptionType === 'paid' ? 'Paid membership' : 'Free'}</p>
                </div>
                {locationCity && (
                  <div>
                    <p className="font-medium text-buddy-text-primary">Location</p>
                    <p>{locationCity}{locationCountry ? `, ${locationCountry}` : ''}</p>
                  </div>
                )}
                {tags.length > 0 && (
                  <div>
                    <p className="font-medium text-buddy-text-primary">Tags</p>
                    <p>{tags.join(', ')}</p>
                  </div>
                )}
              </div>
            </div>

            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => setStep(2)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" onClick={handleCreate} isLoading={isSubmitting}>Create Gym</Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
