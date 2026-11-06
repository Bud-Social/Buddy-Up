import { useState, useEffect } from 'react';
import {
  Plus, RefreshCw, Trash2, Edit, Play, Timer, X,
  Wine, Minus, Leaf, Dumbbell, MapPin, AlertCircle, Share2, Clock,
  Heart, Star, MoreHorizontal,
} from 'lucide-react';
import { useCountdownsStore } from '@/store/countdownsStore';
import { useAuthStore } from '@/store/authStore';
import { countdownsApi } from '@/api/countdowns';
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

const WELCOME_STORAGE_KEY = 'buddyup-welcome-seen';
const NAPHTALIE_COUNTDOWNS_CREATED_KEY = 'buddyup-naphtalie-countdowns-created';

const RAINBOW_STEPS = [
  {
    color: 'bg-buddy-red',
    textColor: 'text-white',
    title: 'Step 1: The Broke Ass Era',
    body: 'I hope this raises the bar for every other guy who says they like you. At my broke ass era, I have managed to pull up a welcome on this platform every time you login on this app; imagine what the average financially stronger guy has to do to earn your attention.',
    punchline: 'Broke but ambitious. We like that energy. 💸✨',
  },
  {
    color: 'bg-buddy-orange',
    textColor: 'text-white',
    title: 'Step 2: You Deserve the Love',
    body: 'And the countdown is there for you, do as you wish, just don\'t be harsh on yourself in the process. A reminder when you use this app, you deserve the love that you think straight people, law-abiding and any version of perfect boy you can think of deserves.',
    punchline: 'You deserve love. Even if you\'re not perfect. Especially then. ❤️',
  },
  {
    color: 'bg-buddy-gold',
    textColor: 'text-black',
    title: 'Step 3: First Time Living',
    body: 'It is your first time living, and if by any chance you reincarnated, I hope this is the lifetime to remind you to love yourself even more. Cheer yourself, live for you, fight for you and walk with those who aren\'t scared to say and show how much they appreciate you being in their lives.',
    punchline: 'Self-love is non-negotiable. Period. 🌟',
  },
  {
    color: 'bg-buddy-green',
    textColor: 'text-white',
    title: 'Step 4: What Do You Want?',
    body: 'You are the only one who can explain what it takes to be you. Finally, when you find yourself tearing or smiling, stop and ask, what do I want? Why this? I hope that scares you... yep... had to scare you in the end.',
    punchline: 'Scared? Good. That means it\'s working. 😈',
  },
  {
    color: 'bg-buddy-electric',
    textColor: 'text-white',
    title: 'Step 5: Therapist First',
    body: 'But hey, I hope this does the trick for you to book the next appointment to your therapist while I am still around rather than when I have flown away. You can go ahead and create a countdown! Enjoy No Nut November. You can create one for how long I\'ll last this talking stage before fucking it up or bringing in a third person, oh wait, I already did it, maybe.',
    punchline: 'Therapy first, countdowns second. Priorities! 🛋️',
  },
] as const;

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
  const welcomeInfo = user?.email === 'goddiekevo@gmail.com'
    ? { display_name: 'Naphtalie', nickname: 'Tosiq', auto_buddy_email: 'jmbngugimbugua@gmail.com' }
    : user?.email === 'jmbngugimbugua@gmail.com'
      ? { display_name: 'Automatic Buddy', nickname: 'AutoBuddy', auto_buddy_email: null }
      : user?.email === 'hairplacebnsalon@gmail.com'
        ? { display_name: 'Test User', nickname: 'Tester', auto_buddy_email: null }
        : null;

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
  const [shareCountdown, setShareCountdown] = useState<UserCountdown | null>(null);

  // Welcome flow state
  const [welcomeSeen, setWelcomeSeen] = useState<boolean>(() => {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(WELCOME_STORAGE_KEY) === '1';
    }
    return false;
  });
  const [welcomeStep, setWelcomeStep] = useState<'celebration' | 'options' | 'replay' | null>(null);
  const [welcomeRainbowIndex, setWelcomeRainbowIndex] = useState(0);
  const [welcomeUser, setWelcomeUser] = useState<{ display_name: string; nickname: string } | null>(null);
  const [naphtalieMessage, setNaphtalieMessage] = useState<string | null>(null);
  const [naphtalieCountdownsCreated, setNaphtalieCountdownsCreated] = useState<boolean>(() => {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem(NAPHTALIE_COUNTDOWNS_CREATED_KEY) === '1';
    }
    return false;
  });
  const [welcomeViewedNotified, setWelcomeViewedNotified] = useState(false);
  const [welcomeLoading, setWelcomeLoading] = useState(false);
  const [moreOptionsOpen, setMoreOptionsOpen] = useState<string | null>(null);

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

    if (user?.email && !welcomeSeen && welcomeStep === null) {
      setWelcomeLoading(true);
      countdownsApi.welcomeCheck(user.email).then((res) => {
        if (res.is_welcome_user) {
          setWelcomeUser({ display_name: res.display_name, nickname: res.nickname });
          setWelcomeStep('celebration');
          setWelcomeRainbowIndex(0);
        }
        setWelcomeLoading(false);
      }).catch(() => {
        setWelcomeLoading(false);
      });
    }
  }, [fetchTemplates, fetchCountdowns, user?.email, welcomeSeen, welcomeStep]);

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

  // Progress-based counter color: 25%, 50%, 75%, 100% changes color. Gold at 100%.
  const counterColorForProgress = (pct: number) => {
    if (pct >= 100) return { bg: 'bg-buddy-gold', text: 'text-black', border: 'border-buddy-gold/50' };
    if (pct >= 75) return { bg: 'bg-buddy-green', text: 'text-white', border: 'border-buddy-green/50' };
    if (pct >= 50) return { bg: 'bg-buddy-gold', text: 'text-black', border: 'border-buddy-gold/50' };
    if (pct >= 25) return { bg: 'bg-buddy-orange', text: 'text-white', border: 'border-buddy-orange/50' };
    return { bg: 'bg-buddy-red', text: 'text-white', border: 'border-buddy-red/50' };
  };

  // Days from start_date to present for welcome accounts (Naphtalie/AutoBuddy)
  const daysFromStartToPresent = (startDateStr: string) => {
    const start = new Date(startDateStr);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - start.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  };

  const handleShareCountdown = (c: UserCountdown) => {
    setShareCountdown(c);
    setShareTarget('post');
    const pct = progressPct(c);
    const daysText = c.target_count
      ? `${c.current_count} / ${c.target_count} ${c.unit}`
      : `${c.current_count} ${c.unit}${c.current_count !== 1 ? 's' : ''}`;
    setShareCaption(`📊 ${c.display_reason}
${daysText}
Progress: ${Math.round(pct)}%

#BuddyUp #Countdown #Streak`);
    setShareMedia([]);
    setShareOpen(true);
  };

  const handleShareModalClose = () => {
    setShareOpen(false);
    setShareCaption('');
    setShareMedia([]);
    setShareCountdown(null);
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
  const handleWelcomeNext = async () => {
    if (welcomeRainbowIndex < RAINBOW_STEPS.length - 1) {
      setWelcomeRainbowIndex(welcomeRainbowIndex + 1);
    } else {
      if (welcomeUser && !welcomeViewedNotified) {
        setWelcomeViewedNotified(true);
        try {
          await countdownsApi.welcomeViewed(
            user?.email || '',
            welcomeInfo?.auto_buddy_email || null,
            welcomeUser.display_name
          );
        } catch (err) {
          console.error('Failed to notify automatic buddy:', err);
        }
      }
      setWelcomeStep('options');
    }
  };

  const handleWelcomeReplay = () => {
    setWelcomeStep('replay');
  };

  const handleReplayDismiss = () => {
    setWelcomeStep('options');
  };

  const handleCreateNaphtalieCountdowns = async () => {
    if (naphtalieCountdownsCreated) return;

    try {
      const nnnPayload: CreateUserCountdown = {
        template: null,
        custom_reason: 'your ultimate No Nut November in the dark',
        countdown_type: 'manual',
        unit: 'days',
        target_count: 30,
        start_date: '2026-11-01',
      };
      await createCountdown(nnnPayload);

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
        localStorage.setItem(NAPHTALIE_COUNTDOWNS_CREATED_KEY, '1');
      }
      setNaphtalieCountdownsCreated(true);
      setWelcomeStep(null);
      setNaphtalieMessage("see, he already created it for you ✨");
      fetchCountdowns();
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Failed to create countdowns');
    }
  };

  const filteredCountdowns = countdowns.filter(c => {
    if (countdownFilter === 'all') return true;
    if (countdownFilter === 'active') return !c.completed_at && c.is_active;
    if (countdownFilter === 'completed') return !!c.completed_at;
    if (countdownFilter === 'archived') return !c.is_active && !c.completed_at;
    return true;
  });

  const currentRainbowStep = RAINBOW_STEPS[welcomeRainbowIndex];
  const isLastRainbowStep = welcomeRainbowIndex === RAINBOW_STEPS.length - 1;

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

      {/* Welcome Celebration - Rainbow Steps */}
      {welcomeStep === 'celebration' && currentRainbowStep && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/90 backdrop-blur-md" />
          <div className={`relative ${currentRainbowStep.color} ${currentRainbowStep.textColor} rounded-2xl border border-white/20 p-8 w-full max-w-2xl max-h-[90vh] overflow-y-auto z-[61] shadow-2xl shadow-[0_0_40px_rgba(255,255,255,0.1)]`}>
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <Heart size={24} className={`text-white ${currentRainbowStep.textColor.replace('text-', '')}`} />
                <h2 className="font-display text-xl font-bold">
                  Welcome back, {welcomeUser?.display_name || 'Friend'} 💖 (aka {welcomeUser?.nickname || 'Tosiq'})
                </h2>
              </div>
            </div>

            <div className="space-y-6">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6 border border-white/20">
                <h3 className="text-lg font-semibold mb-3">{currentRainbowStep.title}</h3>
                <p className="text-lg leading-relaxed">{currentRainbowStep.body}</p>
                <div className="mt-4 pt-4 border-t border-white/30">
                  <p className="text-sm font-medium italic opacity-90">{currentRainbowStep.punchline}</p>
                </div>
              </div>

              <div className="flex items-center gap-2 text-xs opacity-80">
                {[...Array(RAINBOW_STEPS.length)].map((_, i) => (
                  <div
                    key={i}
                    className={`w-2 h-2 rounded-full transition-colors ${
                      i <= welcomeRainbowIndex ? 'bg-white' : 'bg-white/30'
                    }`}
                  />
                ))}
                <span>{welcomeRainbowIndex + 1} of {RAINBOW_STEPS.length}</span>
              </div>

              <div className="pt-4 flex justify-end">
                <button
                  onClick={handleWelcomeNext}
                  className="px-6 py-3 bg-white text-buddy-red hover:bg-white/90 rounded-xl font-semibold transition-colors shadow-lg"
                >
                  {isLastRainbowStep ? "I'm ready, let's go 🚀" : 'Next →'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Welcome Options Modal */}
      {welcomeStep === 'options' && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/80 backdrop-blur-sm" onClick={handleWelcomeReplay} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-8 w-full max-w-md z-[61] shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="font-display text-xl font-bold text-buddy-text-primary">What\'s next, {welcomeUser?.nickname || 'Tosiq'}?</h2>
            </div>

            <div className="space-y-4">
              <p className="text-buddy-text-secondary text-sm text-center">
                Your countdowns are waiting to be born. Shall we make them?
              </p>

              <button
                onClick={handleCreateNaphtalieCountdowns}
                disabled={naphtalieCountdownsCreated}
                className={`w-full py-4 rounded-xl font-semibold transition-colors flex items-center justify-center gap-2 ${
                  naphtalieCountdownsCreated
                    ? 'bg-buddy-surface/50 text-buddy-text-secondary border border-buddy-border cursor-not-allowed'
                    : 'bg-buddy-green hover:bg-buddy-green/90 text-white shadow-[0_0_20px_rgba(0,200,150,0.4)]'
                }`}
              >
                <Plus size={18} />
                {naphtalieCountdownsCreated ? 'Countdowns Already Created ✨' : 'Create my countdowns'}
              </button>

              {naphtalieCountdownsCreated ? (
                <p className="text-xs text-buddy-green/90 text-center font-medium mt-2">
                  Your countdowns have already been created. You can find them below.
                </p>
              ) : (
                <button
                  onClick={handleWelcomeReplay}
                  className="w-full py-4 bg-buddy-surface hover:bg-buddy-surface/80 border border-buddy-border text-buddy-text-secondary rounded-xl font-semibold transition-colors"
                >
                  <Clock size={18} className="mr-2" /> Replay the welcome
                </button>
              )}
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
                Oops, Peter didn't think this would be enticing for you, go ahead and call him or prolly send him something nicer... And he means money and money only... not what you're thinking.
              </p>
            </div>

            <div className="flex gap-3">
              <button
                onClick={handleCreateNaphtalieCountdowns}
                disabled={naphtalieCountdownsCreated}
                className={`flex-1 py-4 rounded-xl font-semibold transition-colors ${
                  naphtalieCountdownsCreated
                    ? 'bg-buddy-surface/50 text-buddy-text-secondary border border-buddy-border cursor-not-allowed'
                    : 'bg-buddy-green hover:bg-buddy-green/90 text-white'
                }`}
              >
                {naphtalieCountdownsCreated ? 'Already Created' : 'Fine, create my countdowns'}
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
        {welcomeStep === null && !naphtalieMessage && (
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

      {/* Welcome loading skeleton */}
      {welcomeLoading && welcomeStep === null && !naphtalieMessage && (
        <div className="bg-buddy-surface rounded-xl border border-buddy-border p-4">
          <div className="h-32 flex items-center justify-center text-buddy-text-secondary">
            Checking if you deserve a welcome…
          </div>
        </div>
      )}

      {!welcomeLoading && welcomeStep === null && !naphtalieMessage && (
        <>
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
              {filteredCountdowns.map((c) => {
                const pct = progressPct(c);
                const { bg, text, border } = counterColorForProgress(pct);
                const isWelcomeCountdown = user?.email === 'goddiekevo@gmail.com' || user?.email === 'jmbngugimbugua@gmail.com';
                const actualDays = isWelcomeCountdown ? daysFromStartToPresent(c.start_date) : c.days_since_start;
                const showShare = c.completed_at || c.countdown_type === 'manual';

                return (
                  <div
                    key={c.id}
                    className={`flex items-start gap-4 p-4 rounded-lg border ${
                      c.completed_at ? 'bg-buddy-green/10 border-buddy-green/30' : 'border-buddy-border bg-buddy-bg'
                    }`}
                  >
                    {/* Big round counter - huge for attention, color changes with progress */}
                    <div className="shrink-0">
                      <div className={`relative w-24 h-24 rounded-full border-6 ${bg} ${border} flex flex-col items-center justify-center shadow-lg shadow-${bg.replace('bg-', '')}/30`}>
                        <span className={`text-4xl font-display font-bold ${text}`}>{actualDays}</span>
                        <span className={`text-[11px] uppercase tracking-wider font-bold ${text}`}>{c.unit}</span>
                      </div>
                      {c.completed_at && (
                        <div className="absolute -top-2 -right-2 w-8 h-8 rounded-full bg-buddy-green flex items-center justify-center shadow-lg">
                          <Clock size={14} className="text-white" />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <h4 className="font-medium text-buddy-text-primary">{c.display_reason}</h4>
                        <span className={`text-xs px-2 py-0.5 rounded-full ${c.completed_at ? 'bg-buddy-green text-white' : 'bg-buddy-surface text-buddy-text-secondary border border-buddy-border'}`}>
                          {c.completed_at ? 'Completed' : c.countdown_type === 'manual' ? 'Manual' : 'Automatic'}
                        </span>
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-1">
                        Started {new Date(c.start_date).toLocaleDateString()}
                      </p>
                      <div className="w-full bg-buddy-surface/50 rounded-full h-2.5 mt-3 overflow-hidden">
                        <div
                          className={`h-full transition-all duration-500 ${bg} ${text.replace('text-', 'bg-')}`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <div className="mt-3 text-xs text-buddy-text-secondary font-medium">
                        {c.target_count ? `Target: ${c.target_count} ${c.unit}` : `Day ${actualDays}`}
                      </div>
                    </div>
                    <div className="shrink-0">
                      {/* Share button - standalone, prominent */}
                      {showShare && (
                        <button
                          onClick={() => handleShareCountdown(c)}
                          className="w-full py-2 px-3 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg text-sm font-medium transition-colors shadow-md flex items-center justify-center gap-1.5"
                        >
                          <Share2 size={16} /> Share
                        </button>
                      )}
                      {/* Three dots - More options */}
                      <div className="relative mt-2">
                        <button
                          onClick={(e) => { e.stopPropagation(); setMoreOptionsOpen(c.id); }}
                          className="w-8 h-8 rounded-lg bg-buddy-surface hover:bg-buddy-surface/80 flex items-center justify-center text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
                        >
                          <MoreHorizontal size={16} />
                        </button>
                        {moreOptionsOpen === c.id && (
                          <div className="absolute right-0 mt-2 w-48 bg-buddy-surface rounded-lg border border-buddy-border shadow-xl py-2 z-50">
                            <button
                              onClick={() => { setEditingId(editingId === c.id ? null : c.id); setMoreOptionsOpen(null); }}
                              className="w-full text-left px-3 py-2 text-sm text-buddy-text-secondary hover:bg-buddy-surface/50 hover:text-buddy-text-primary transition-colors flex items-center gap-2"
                            >
                              <Edit size={14} className="w-4 h-4" /> Edit
                            </button>
                            {c.completed_at && (
                              <button
                                onClick={() => { handleRecreate(c); setMoreOptionsOpen(null); }}
                                className="w-full text-left px-3 py-2 text-sm text-buddy-green hover:bg-buddy-green/5 hover:text-buddy-green transition-colors flex items-center gap-2"
                              >
                                <Clock size={14} className="w-4 h-4" /> Recreate
                              </button>
                            )}
                            {c.countdown_type === 'manual' && (
                              <button
                                onClick={() => { handleCheckIn(c.id); setMoreOptionsOpen(null); }}
                                className="w-full text-left px-3 py-2 text-sm text-buddy-green hover:bg-buddy-green/5 hover:text-buddy-green transition-colors flex items-center gap-2"
                              >
                                <Play size={14} className="w-4 h-4" /> Check in
                              </button>
                            )}
                            <button
                              onClick={() => { handleReset(c.id); setMoreOptionsOpen(null); }}
                              className="w-full text-left px-3 py-2 text-sm text-buddy-red hover:bg-buddy-red/5 hover:text-buddy-red transition-colors flex items-center gap-2"
                            >
                              <RefreshCw size={14} className="w-4 h-4" /> Reset
                            </button>
                            <button
                              onClick={() => { handleDelete(c.id); setMoreOptionsOpen(null); }}
                              className="w-full text-left px-3 py-2 text-sm text-buddy-text-secondary hover:bg-buddy-red/5 hover:text-buddy-red transition-colors flex items-center gap-2"
                            >
                              <Trash2 size={14} className="w-4 h-4" /> Delete
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Template cards - AFTER countdowns list */}
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
        </>
      )}

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
              {/* Countdown card preview */}
              {shareCountdown && (
                <div className="bg-buddy-surface/50 rounded-xl p-4 border border-buddy-border/50 flex items-start gap-4">
                  <div className="shrink-0">
                    <div className="w-16 h-16 rounded-2xl bg-buddy-green/10 text-buddy-green flex items-center justify-center">
                      <Timer size={24} />
                    </div>
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                      <h4 className="font-medium text-buddy-text-primary">{shareCountdown.display_reason}</h4>
                      <span className="text-xs px-2 py-0.5 rounded-full bg-buddy-surface text-buddy-text-secondary border border-buddy-border">
                        {shareCountdown.countdown_type === 'manual' ? 'Manual' : 'Automatic'}
                      </span>
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      {shareCountdown.unit} • {shareCountdown.current_count} {shareCountdown.unit}{shareCountdown.current_count !== 1 ? 's' : ''}
                    </p>
                  </div>
                </div>
              )}

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
