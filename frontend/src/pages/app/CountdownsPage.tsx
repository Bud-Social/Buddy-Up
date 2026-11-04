import { useState, useEffect } from 'react';
import {
  Plus, RefreshCw, Trash2, Edit, Play, Timer, X,
  Wine, Minus, Leaf, Dumbbell, MapPin, AlertCircle, Share2, Clock,
  Heart, Star,
} from 'lucide-react';
import { useCountdownsStore } from '@/store/countdownsStore';
import { useAuthStore } from '@/store/authStore';
import type { UserCountdown, CreateUserCountdown } from '@/types/countdowns';

const TEMPLATE_LUCIDE_ICONS: Record<string, React.ComponentType<any>> = {
  sobriety: Wine,
  no_artificial_sugars: Minus,
  no_animal_proteins: Leaf,
  gym_attendance: Dumbbell,
  walking_days: MapPin,
  no_drugs: AlertCircle,
  no_nut_month: Leaf,
  custom: Plus,
};

const VISIBILITY_OPTIONS: { value: 'public' | 'buddies' | 'followers' | 'private'; label: string; labelText: string }[] = [
  { value: 'public', label: 'Public', labelText: 'Anyone can see' },
  { value: 'buddies', label: 'Buddies Only', labelText: 'Confirmed buddies' },
  { value: 'followers', label: 'Followers', labelText: 'People who follow you' },
  { value: 'private', label: 'Private', labelText: 'Only you can see' },
];

const WELCOME_STORAGE_KEY = 'buddyup-welcome-seen-naphtalie';
const NAPHTALIE_EMAIL = 'goddiekevo@gmail.com';

const WELCOME_CELEBRATION_TEXT = `I hope this raises the bar for every other guys that says they like you. At my broke ass era, I have managed to pull up a welcome on this platform everytime you login on this app; imagine what the average finacially stronger guy has to do to earn your attention. And the countdown is there for you, do as you wish, just don't be harsh on yourself on the process. A reminder when you use this app, you deserve the love that you think straight people, law abiding and any version of perfect boy you can think of deserves. It is your first time living, and if by any chance you reincarnated, I hope this is the lifetime to remind you to love yourself even more. Cheer yourself, live for you, fight for you and walk with those who aren't scared to say and show how much they appreciate you being in their lives. You are the only one who can explain what it takes to be you. Finally, when you find yourself tearing or smiling, stop and ask, what do I want? Why this? I hope that scares you... yeap... had to scare you in the end. But hey, I hope this does the trick for you to book the next appointment to your therapist while I am still around rather than when I have flown away. You can go ahead and create a countdown! Enjoy No Nut November. You can create one of how long I'll last this talking stage before fucking it up or bringing in a third person, oh wait, I already did it, maybe.`;

export default function CountdownsPage() {
  const {
    countdowns,
    loading,
    error,
    fetchTemplates,
    fetchCountdowns,
    createCountdown,
    checkIn,
    resetCountdown,
    updateCountdown,
    deleteCountdown,
    templates,
  } = useCountdownsStore();

  const user = useAuthStore((s) => s.user);
  const isNaphtalie = user?.email === NAPHTALIE_EMAIL;

  const [creatingTemplateId, setCreatingTemplateId] = useState<string | null>(null);
  const [step, setStep] = useState(1);
  const [newReason, setNewReason] = useState('');
  const [targetCount, setTargetCount] = useState(0);
  const [countdownType, setCountdownType] = useState<'manual' | 'automatic'>('manual');
  const [unit, setUnit] = useState<'days' | 'hours'>('days');
  const [direction, setDirection] = useState<'forward' | 'backward'>('forward');
  const [visibility, setVisibility] = useState<'public' | 'buddies' | 'followers' | 'private'>('private');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editReason, setEditReason] = useState('');
  const [editTarget, setEditTarget] = useState('');

  // Share composer state
  const [shareOpen, setShareOpen] = useState(false);
  const [shareTarget, setShareTarget] = useState<'post' | 'dm' | 'gym' | 'community'>('post');
  const [shareCaption, setShareCaption] = useState('');
  const [shareMedia, setShareMedia] = useState<File[]>([]);
  const [shareLoading, setShareLoading] = useState(false);

  // Welcome flow state for Naphtalie
  const [welcomeSeen, setWelcomeSeen] = useState<boolean>(() => {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(WELCOME_STORAGE_KEY) === '1';
    }
    return false;
  });
  const [welcomeStep, setWelcomeStep] = useState<'celebration' | 'options' | 'replay' | null>(null);
  const [naphtalieMessage, setNaphtalieMessage] = useState<string | null>(null);

  // Countdown filter tabs
  const [countdownFilter, setCountdownFilter] = useState<'all' | 'active' | 'completed' | 'archived'>('all');

  const COUNTDOWN_FILTERS: { key: 'all' | 'active' | 'completed' | 'archived'; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'active', label: 'Active' },
    { key: 'completed', label: 'Completed' },
    { key: 'archived', label: 'Archived' },
  ];

  // Initialize on mount
  useEffect(() => {
    fetchTemplates();
    fetchCountdowns();

    // Show welcome for Naphtalie on first visit
    if (isNaphtalie && !welcomeSeen && welcomeStep === null) {
      setWelcomeStep('celebration');
    }
  }, [fetchTemplates, fetchCountdowns, isNaphtalie, welcomeSeen, welcomeStep]);

  const handleCreate = async () => {
    if (!creatingTemplateId && !newReason.trim()) return;
    const payload: CreateUserCountdown = {
      template: creatingTemplateId || null,
      custom_reason: newReason.trim() || undefined,
      countdown_type: countdownType,
      unit,
      target_count: targetCount > 0 ? targetCount : undefined,
    };
    await createCountdown(payload);
    setCreatingTemplateId(null);
    setNewReason('');
    setTargetCount(0);
    setCountdownType('manual');
    setUnit('days');
    setDirection('forward');
    setVisibility('private');
    setStep(1);
    fetchCountdowns();
  };

  const handleCheckIn = async (id: string) => {
    await checkIn(id);
    fetchCountdowns();
  };

  const handleReset = async (id: string) => {
    if (!window.confirm('Reset this countdown to zero?')) return;
    await resetCountdown(id);
    fetchCountdowns();
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Delete this countdown?')) return;
    await deleteCountdown(id);
    fetchCountdowns();
  };

  const handleRecreate = async (c: UserCountdown) => {
    const payload: CreateUserCountdown = {
      template: c.template || null,
      custom_reason: c.custom_reason || undefined,
      countdown_type: c.countdown_type,
      unit: c.unit,
      target_count: c.target_count,
    };
    await createCountdown(payload);
    setCreatingTemplateId(null);
    setNewReason('');
    setTargetCount(0);
    setCountdownType('manual');
    setUnit('days');
    setDirection('forward');
    setVisibility('private');
    setStep(1);
    fetchCountdowns();
  };

  const handleSaveEdit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingId) return;
    const payload: Partial<CreateUserCountdown> = {};
    if (editReason.trim()) payload.custom_reason = editReason.trim();
    if (editTarget.trim()) payload.target_count = parseInt(editTarget, 10) || 0;
    await updateCountdown(editingId, payload);
    setEditingId(null);
    fetchCountdowns();
  };

  const progressPct = (c: UserCountdown) => {
    if (!c.target_count) return Math.min(100, (c.current_count / Math.max(c.days_since_start, 1)) * 100);
    return Math.min(100, (c.current_count / c.target_count) * 100);
  };

  const handleShareCountdown = (c: UserCountdown) => {
    setShareTarget('post');
    setShareCaption(`${c.display_reason} — ${c.current_count} ${c.unit}${c.current_count !== 1 ? 's' : ''}`);
    setShareMedia([]);
    setShareOpen(true);
  };

  const handleShareModalClose = () => {
    setShareOpen(false);
    setShareCaption('');
    setShareMedia([]);
  };

  const handleMediaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setShareMedia(files);
  };

  const handleShareSubmit = async () => {
    setShareLoading(true);
    try {
      console.log('Sharing countdown:', { target: shareTarget, caption: shareCaption, media: shareMedia });
    } finally {
      setShareLoading(false);
      setShareOpen(false);
      setShareCaption('');
      setShareMedia([]);
    }
  };

  // Welcome flow handlers
  const handleWelcomeContinue = () => {
    setWelcomeStep('options');
  };

  const handleWelcomeReplay = () => {
    setWelcomeStep('replay');
  };

  const handleReplayDismiss = () => {
    setWelcomeStep('options');
  };

  const handleCreateNaphtalieCountdowns = async () => {
    try {
      // Countdown 1: "your ultimate No Nut November in the dark"
      const nnnPayload: CreateUserCountdown = {
        template: null,
        custom_reason: 'your ultimate No Nut November in the dark',
        countdown_type: 'manual',
        unit: 'days',
        target_count: 30,
        start_date: '2026-11-01',
      };
      await createCountdown(nnnPayload);

      // Countdown 2: Talking stage survival
      const tsPayload: CreateUserCountdown = {
        template: null,
        custom_reason: 'How long I will last this talking stage before fucking it up',
        countdown_type: 'manual',
        unit: 'days',
        target_count: 30,
        start_date: '2026-11-01',
      };
      await createCountdown(tsPayload);

      setWelcomeSeen(true);
      if (typeof localStorage !== 'undefined') {
        localStorage.setItem(WELCOME_STORAGE_KEY, '1');
      }
      setWelcomeStep(null);
      setNaphtalieMessage("see, he already created it for you ✨");
      fetchCountdowns();
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Failed to create countdowns');
    }
  };

  const getCountdownIcon = (c: UserCountdown) => {
    const code = c.template_detail?.code || 'custom';
    const Icon = TEMPLATE_LUCIDE_ICONS[code] || Plus;
    return <Icon className="text-2xl" />;
  };

  const filteredCountdowns = countdowns.filter(c => {
    if (countdownFilter === 'all') return true;
    if (countdownFilter === 'active') return !c.completed_at && c.is_active;
    if (countdownFilter === 'completed') return !!c.completed_at;
    if (countdownFilter === 'archived') return !c.is_active && !c.completed_at;
    return true;
  });

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-6">
      {/* Naphtalie welcome message banner */}
      {naphtalieMessage && (
        <div className="bg-buddy-green/20 border border-buddy-green/40 rounded-xl p-4 flex items-start gap-3 animate-pulse">
          <Star size={20} className="text-buddy-green mt-0.5" />
          <div>
            <p className="text-sm font-medium text-buddy-text-primary">{naphtalieMessage}</p>
            <p className="text-xs text-buddy-text-secondary mt-1">Naphtalie (Tosiq), your countdowns are ready. Track them below.</p>
          </div>
        </div>
      )}

      {/* Welcome Celebration Modal - Unskippable (Step 1) */}
      {welcomeStep === 'celebration' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/90 backdrop-blur-md" />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-green/50 p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto z-[61] shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <Heart size={24} className="text-buddy-red animate-bounce" />
                <h2 className="font-display text-2xl font-bold text-buddy-text-primary">
                  Welcome back, Naphtalie 💖 (aka Tosiq)
                </h2>
              </div>
            </div>

            <div className="space-y-6">
              <div className="bg-buddy-surface/50 rounded-xl p-6 border border-buddy-border text-buddy-text-secondary leading-relaxed text-sm italic">
                {WELCOME_CELEBRATION_TEXT}
              </div>

              <div className="bg-buddy-green/10 border border-buddy-green/30 rounded-xl p-4">
                <p className="text-xs text-buddy-green/90 font-medium mb-2">
                  ✨ You are the only one who can explain what it takes to be you. ✨
                </p>
                <p className="text-xs text-buddy-text-secondary">
                  Now go create something beautiful. Or don't. We're not your mom.
                </p>
              </div>

              <div className="pt-4 flex justify-end">
                <button
                  onClick={handleWelcomeContinue}
                  className="px-6 py-3 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-xl font-semibold transition-colors shadow-[0_0_20px_rgba(0,200,150,0.4)]"
                >
                  I'm ready, let's go 🚀
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Welcome Options Modal (Step 2) */}
      {welcomeStep === 'options' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm" onClick={handleWelcomeReplay} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-8 w-full max-w-md z-[61] shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="font-display text-xl font-bold text-buddy-text-primary">What's next, Tosiq?</h2>
            </div>

            <div className="space-y-4">
              <p className="text-buddy-text-secondary text-sm text-center">
                Your countdowns are waiting to be born. Shall we make them?
              </p>

              <button
                onClick={handleCreateNaphtalieCountdowns}
                className="w-full py-4 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-xl font-semibold transition-colors flex items-center justify-center gap-2"
              >
                <Plus size={18} /> Create my countdowns
              </button>

              <button
                onClick={handleWelcomeReplay}
                className="w-full py-4 bg-buddy-surface hover:bg-buddy-surface/80 border border-buddy-border text-buddy-text-secondary rounded-xl font-semibold transition-colors"
              >
                <Clock size={18} className="mr-2" /> Replay the welcome
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Replay Message Modal */}
      {welcomeStep === 'replay' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm" onClick={handleReplayDismiss} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-red/30 p-8 w-full max-w-md z-[61] shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="font-display text-xl font-bold text-buddy-text-primary">Replay? 😅</h2>
            </div>

            <div className="bg-buddy-red/10 border border-buddy-red/30 rounded-xl p-4 mb-6">
              <p className="text-buddy-text-secondary text-sm leading-relaxed italic">
                Oooops, Peter didn't think this would be enticing for you, go ahead and call him or prolly send him something nicer... And he means money and money only... not what you are thinking.
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={handleCreateNaphtalieCountdowns}
                className="flex-1 py-4 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-xl font-semibold transition-colors"
              >
                Fine, create my countdowns
              </button>
              <button
                onClick={handleReplayDismiss}
                className="flex-1 py-4 bg-buddy-surface hover:bg-buddy-surface/80 border border-buddy-border text-buddy-text-secondary rounded-xl font-semibold transition-colors"
              >
                Maybe later
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Countdowns & Streaks</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Track sobriety, diet, gym attendance, walking days and more — manual or automatic.
          </p>
        </div>
        {isNaphtalie && welcomeStep === null && (
          <button
            onClick={() => setWelcomeStep('celebration')}
            className="px-4 py-2 bg-buddy-red hover:bg-buddy-red/90 text-white rounded-lg text-sm font-medium transition-colors"
          >
            Replay welcome 💖
          </button>
        )}
        {!isNaphtalie && (
          <button
            onClick={() => setCreatingTemplateId(null)}
            className="flex items-center gap-2 px-3 py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg text-sm font-medium transition-colors"
          >
            <Plus size={16} /> New Countdown
          </button>
        )}
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-red/10 p-3 border border-buddy-red/20 text-buddy-red text-sm">{error}</div>
      )}

      {/* Countdowns list - FIRST */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-4">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-buddy-text-primary">Your Countdowns</h3>
          <button
            onClick={() => fetchCountdowns()}
            className="text-xs text-buddy-green hover:text-buddy-green/90 flex items-center gap-1"
          >
            <RefreshCw size={14} /> Refresh
          </button>
        </div>

        {loading && <div className="text-buddy-text-secondary">Loading…</div>}

        {/* Filter tabs */}
        <div className="flex gap-1 mb-4">
          {COUNTDOWN_FILTERS.map((f) => (
            <button
              key={f.key}
              onClick={() => setCountdownFilter(f.key)}
              className={`px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                countdownFilter === f.key
                  ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                  : 'text-buddy-text-secondary hover:bg-buddy-surface/50 border-transparent'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>

        {filteredCountdowns.length === 0 && !loading && (
          <div className="text-center py-8 text-buddy-text-secondary">
            <Timer size={32} className="mx-auto mb-2 opacity-50" />
            <p>{countdownFilter === 'all' ? 'No countdowns yet.' : `No ${countdownFilter} countdowns.`} Create one above to start tracking.</p>
          </div>
        )}

        <div className="space-y-3">
          {filteredCountdowns.map((c) => (
            <div
              key={c.id}
              className={`flex items-start gap-3 p-3 rounded-lg border ${
                c.completed_at ? 'bg-buddy-green/10 border-buddy-green/30' : 'border-buddy-border bg-buddy-bg'
              }`}
            >
              <div className="text-2xl shrink-0">{getCountdownIcon(c)}</div>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2">
                  <h4 className="font-medium text-buddy-text-primary">{c.display_reason}</h4>
                  <span className={`text-xs px-2 py-0.5 rounded-full ${
                    c.completed_at ? 'bg-buddy-green text-white' : 'bg-buddy-surface text-buddy-text-secondary border border-buddy-border'
                  }`}>
                    {c.completed_at ? 'Completed' : c.countdown_type === 'manual' ? 'Manual' : 'Automatic'}
                  </span>
                </div>
                <p className="text-xs text-buddy-text-secondary mt-0.5">
                  {c.unit} • Started {new Date(c.start_date).toLocaleDateString()} • {c.current_count} {c.unit}{c.current_count !== 1 ? 's' : ''}
                </p>
                <div className="w-full bg-buddy-surface/50 rounded-full h-2 mt-2 overflow-hidden">
                  <div
                    className="h-full bg-buddy-green transition-all duration-500"
                    style={{ width: `${progressPct(c)}%` }}
                  />
                </div>
                <div className="flex items-center gap-3 mt-2 text-xs">
                  <span className="text-buddy-text-secondary">
                    {c.target_count ? `Target: ${c.target_count} {c.unit}` : `Day ${c.days_since_start}`}
                  </span>
                  {c.countdown_type === 'manual' && (
                    <button
                      onClick={() => handleCheckIn(c.id)}
                      className="flex items-center gap-1 px-3 py-1 bg-buddy-green hover:bg-buddy-green/90 text-white rounded text-xs font-medium transition-colors"
                    >
                      <Play size={12} /> Check in
                    </button>
                  )}
                  <button onClick={() => setEditingId(c.id)} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                    <Edit size={14} className="mr-1" /> Edit
                  </button>
                  {c.completed_at && (
                    <button
                      onClick={() => handleRecreate(c)}
                      className="text-buddy-green hover:text-buddy-green/90 text-sm font-medium"
                    >
                      <Clock className="w-3 h-3 mr-1" /> Recreate
                    </button>
                  )}
                  <button
                    onClick={() => handleReset(c.id)}
                    className="text-buddy-red hover:text-buddy-red/90 text-xs"
                  >
                    <RefreshCw size={14} className="mr-1" /> Reset
                  </button>
                  <button
                    onClick={() => handleDelete(c.id)}
                    className="text-buddy-text-secondary hover:text-buddy-red"
                  >
                    <Trash2 size={14} className="mr-1" /> Delete
                  </button>
                  {c.completed_at || c.countdown_type === 'manual' ? (
                    <button
                      onClick={() => handleShareCountdown(c)}
                      className="flex items-center gap-1 px-3 py-1 bg-buddy-surface hover:bg-buddy-surface/80 text-buddy-text-secondary rounded text-xs font-medium transition-colors"
                    >
                      <Share2 size={14} /> Share
                    </button>
                  ) : null}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Template cards - AFTER countdowns list */}
      {!isNaphtalie || welcomeStep !== null ? (
        <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-buddy-text-primary">Start a New Countdown</h3>
            <span className="text-xs text-buddy-text-secondary">Tap a template to begin</span>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {templates.map((tmpl) => {
              const isSelected = creatingTemplateId === tmpl.id;
              const Icon = TEMPLATE_LUCIDE_ICONS[tmpl.code] || Plus;
              return (
                <button
                  key={tmpl.id}
                  onClick={() => setCreatingTemplateId(tmpl.id)}
                  className={`flex flex-col items-center gap-2 p-4 rounded-xl border border-buddy-border transition-all duration-200 ${
                    isSelected
                      ? 'bg-buddy-green/10 border-buddy-green shadow-[0_0_20px_rgba(0,200,150,0.2)]'
                      : tmpl.color + ' hover:border-buddy-green hover:bg-buddy-surface/50'
                  }`}
                >
                  <div className="w-10 h-10 rounded-lg flex items-center justify-center bg-buddy-surface/50 text-buddy-text-secondary">
                    <Icon className="text-xl" />
                  </div>
                  <div className="font-medium text-sm text-buddy-text-primary">{tmpl.title}</div>
                  <div className="text-xs text-buddy-text-secondary">{tmpl.description}</div>
                </button>
              );
            })}
          </div>
        </div>
      ) : null}

      {/* Create countdown modal (multistep) */}
      {creatingTemplateId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setCreatingTemplateId(null)} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-6 w-full max-w-md max-h-[90vh] overflow-y-auto z-10">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-buddy-text-primary">Create Countdown</h3>
              <button onClick={() => setCreatingTemplateId(null)} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Stepper */}
            <div className="flex items-center gap-2 mb-6">
              {[1, 2, 3].map((s) => (
                <div key={s} className="flex items-center gap-2">
                  <div className={`w-6 h-6 rounded-full border flex items-center justify-center text-xs font-bold ${
                    step >= s ? 'bg-buddy-green text-buddy-white border-buddy-green' : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border'
                  }`}>
                    {s}
                  </div>
                  {s < 3 && <div className="h-px bg-buddy-border w-4"></div>}
                </div>
              ))}
            </div>

            <form onSubmit={(e) => { e.preventDefault(); handleCreate(); }} className="space-y-4">
              {/* Step 1: Template selection */}
              {step === 1 && (
                <div className="space-y-4">
                  <div className="mb-4">
                    <label className="text-sm font-medium text-buddy-text-secondary">Choose a template</label>
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                      {templates.map((tmpl) => {
                        const isSel = creatingTemplateId === tmpl.id;
                        const Icon = TEMPLATE_LUCIDE_ICONS[tmpl.code] || Plus;
                        return (
                          <button
                            key={tmpl.id}
                            type="button"
                            onClick={() => setCreatingTemplateId(tmpl.id)}
                            className={`flex flex-col items-center gap-2 p-3 rounded-xl border transition-colors ${
                              isSel ? 'bg-buddy-green/10 border-buddy-green' : 'bg-buddy-surface border-buddy-border hover:border-buddy-border/50'
                            }`}
                          >
                            <div className="w-8 h-8 rounded-lg flex items-center justify-center bg-buddy-surface/50 text-buddy-text-secondary">
                              <Icon className="text-xl" />
                            </div>
                            <div className="text-xs text-buddy-text-primary">{tmpl.title}</div>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Reason</label>
                    <input
                      value={newReason}
                      onChange={(e) => setNewReason(e.target.value)}
                      placeholder={creatingTemplateId === 'custom' ? 'Enter a custom reason' : templates.find(t => t.id === creatingTemplateId)?.title || ''}
                      className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                    />
                  </div>
                </div>
              )}

              {/* Step 2: Configuration */}
              {step === 2 && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Counting method</label>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => setCountdownType('manual')}
                        className={`px-3 py-2 rounded-lg border transition-colors ${
                          countdownType === 'manual'
                            ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                            : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border'
                        }`}
                      >
                        Manual — I check in manually
                      </button>
                      <button
                        onClick={() => setCountdownType('automatic')}
                        className={`px-3 py-2 rounded-lg border transition-colors ${
                          countdownType === 'automatic'
                            ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                            : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border'
                        }`}
                      >
                        Automatic — count days automatically
                      </button>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Count unit</label>
                    <div className="grid grid-cols-3 gap-2">
                      {['days', 'hours'].map((u) => (
                        <button
                          key={u}
                          onClick={() => setUnit(u as 'days' | 'hours')}
                          className={`px-3 py-2 rounded-lg text-sm transition-colors ${
                            unit === u
                              ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                              : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border hover:bg-buddy-surface/50'
                          }`}
                        >
                          {u.charAt(0).toUpperCase() + u.slice(1)}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Direction</label>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => setDirection('forward')}
                        className={`px-3 py-2 rounded-lg text-sm transition-colors ${
                          direction === 'forward'
                            ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                            : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border hover:bg-buddy-surface/50'
                        }`}
                      >
                        Count up
                      </button>
                      <button
                        onClick={() => setDirection('backward')}
                        className={`px-3 py-2 rounded-lg text-sm transition-colors ${
                          direction === 'backward'
                            ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                            : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border hover:bg-buddy-surface/50'
                        }`}
                      >
                        Count down
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* Step 3: Target & Visibility */}
              {step === 3 && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Target value</label>
                    <input
                      type="number"
                      value={targetCount}
                      onChange={(e) => setTargetCount(parseInt(e.target.value) || 0)}
                      placeholder="0 = no target"
                      className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                    />
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      Leave at 0 to simply count up/down without a target.
                    </p>
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium text-buddy-text-secondary">Who can see this countdown?</label>
                    <div className="grid grid-cols-2 gap-2">
                      {VISIBILITY_OPTIONS.map((v) => (
                        <button
                          key={v.value}
                          onClick={() => setVisibility(v.value)}
                          className={`flex flex-col items-center gap-2 p-3 rounded-xl border transition-colors ${
                            visibility === v.value
                              ? 'bg-buddy-green/10 border-buddy-green'
                              : 'bg-buddy-surface border-buddy-border hover:bg-buddy-surface/50'
                          }`}
                        >
                          <div className="w-8 h-8 rounded-lg flex items-center justify-center bg-buddy-surface/50 text-buddy-text-secondary">
                            <X className="text-sm" />
                          </div>
                          <div className="text-xs text-buddy-text-primary">{v.label}</div>
                          <div className="text-xs text-buddy-text-secondary">{v.labelText}</div>
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              <div className="mt-6 flex justify-between">
                <button
                  type="button"
                  onClick={() => setStep(step > 1 ? step - 1 : step)}
                  disabled={step === 1}
                  className="flex-1 py-2 bg-buddy-surface hover:bg-buddy-surface/80 text-buddy-text-secondary rounded-lg font-medium disabled:opacity-50"
                >
                  Back
                </button>
                <button
                  type="button"
                  onClick={() => {
                    if (step === 3) {
                      handleCreate();
                    } else {
                      setStep(step + 1);
                    }
                  }}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium transition-colors ${
                    step === 3 ? 'bg-buddy-green text-buddy-green border-buddy-green hover:bg-buddy-green/20' : 'bg-buddy-green/20 text-buddy-green border-buddy-green/50 hover:bg-buddy-green/50'
                  }`}
                >
                  {step === 3 ? 'Create Countdown' : 'Next →'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit inline form */}
      {editingId && (
        <div className="bg-buddy-surface rounded-xl p-4 border border-buddy-green/30">
          <h3 className="font-semibold mb-3">Edit Countdown</h3>
          <form onSubmit={handleSaveEdit} className="space-y-3">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <label className="flex flex-col gap-1.5 text-sm font-medium">
                Reason
                <input
                  value={editReason}
                  onChange={(e) => setEditReason(e.target.value)}
                  className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                />
              </label>
              <label className="flex flex-col gap-1.5 text-sm font-medium">
                Target (days)
                <input
                  type="number"
                  value={editTarget}
                  onChange={(e) => setEditTarget(e.target.value)}
                  placeholder="0 = no target"
                  className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                />
              </label>
            </div>
            <div className="flex gap-2">
              <button type="submit" className="flex-1 py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg font-medium">
                Save
              </button>
              <button type="button" onClick={() => setEditingId(null)} className="px-3 py-2 bg-buddy-surface hover:bg-buddy-surface/80 text-buddy-text-secondary rounded-lg font-medium">
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Share composer modal */}
      {shareOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm" onClick={handleShareModalClose} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-6 w-full max-w-md max-h-[90vh] overflow-y-auto z-10">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-buddy-text-primary">Share Countdown</h3>
              <button onClick={handleShareModalClose} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Share as</label>
                <div className="grid grid-cols-2 gap-2">
                  {[
                    { value: 'post' as const, label: 'Post', icon: Share2 },
                    { value: 'dm' as const, label: 'DM', icon: X },
                    { value: 'gym' as const, label: 'Gym Post', icon: X },
                    { value: 'community' as const, label: 'Community Post', icon: X },
                  ].map((opt) => (
                    <button
                      key={opt.value}
                      onClick={() => setShareTarget(opt.value)}
                      className={`px-4 py-2 rounded-lg border transition-colors text-sm font-medium ${
                        shareTarget === opt.value
                          ? 'bg-buddy-green/10 border-buddy-green text-buddy-green'
                          : 'bg-buddy-surface border-buddy-border text-buddy-text-secondary hover:bg-buddy-surface/50'
                      }`}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Caption</label>
                <textarea
                  value={shareCaption}
                  onChange={(e) => setShareCaption(e.target.value)}
                  rows={3}
                  className="w-full mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Media attachments</label>
                <input
                  type="file"
                  multiple
                  accept="image/*,video/*"
                  onChange={handleMediaChange}
                  className="mt-1 block w-full text-sm text-buddy-text-secondary file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-buddy-green file:text-white hover:file:bg-buddy-green/90"
                />
                {shareMedia.length > 0 && (
                  <p className="text-xs text-buddy-text-secondary">{shareMedia.length} file{shareMedia.length !== 1 ? 's' : ''} attached</p>
                )}
              </div>

              <button
                onClick={handleShareSubmit}
                disabled={shareLoading}
                className={`w-full py-3 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 ${
                  shareLoading ? 'bg-buddy-surface text-buddy-text-secondary' : 'bg-buddy-green text-buddy-white hover:bg-buddy-green/90'
                }`}
              >
                {shareLoading ? 'Sharing…' : 'Share'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
