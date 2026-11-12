import { useState, useEffect } from 'react';
import {
  Plus, RefreshCw, Trash2, Edit, Play, Timer, X,
  Wine, Minus, Leaf, Dumbbell, MapPin, AlertCircle, Share2, Clock,
  MoreHorizontal, History, Zap,
} from 'lucide-react';
import { useCountdownsStore } from '@/store/countdownsStore';
import { analyticsApi } from '@/api/analytics';
import { countdownsApi } from '@/api/countdowns';
import {
  checkInState, countdownHeadline, progressPct, signalLabel, typeTag,
} from '@/lib/countdownFormat';
import type { UserCountdown, CreateUserCountdown, CountdownEvent } from '@/types/countdowns';

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

const SHARE_VISIBILITY_MAP: Record<string, 'public' | 'buddies' | 'gym_members' | 'private'> = {
  post: 'public',
  dm: 'private',
  gym: 'public',
  community: 'public',
};

export default function CountdownsPage() {
  const {
    countdowns,
    loading,
    error,
    fetchTemplates,
    fetchCountdowns,
    fetchSignals,
    createCountdown,
    checkIn,
    resetCountdown,
    updateCountdown,
    deleteCountdown,
    templates,
    signals,
  } = useCountdownsStore();

  const [creatingTemplateId, setCreatingTemplateId] = useState<string | null>(null);
  const [step, setStep] = useState(1);
  const [newReason, setNewReason] = useState('');
  const [targetCount, setTargetCount] = useState(0);
  const [countdownType, setCountdownType] = useState<'manual' | 'automatic'>('manual');
  const [unit, setUnit] = useState<'days' | 'hours'>('days');
  const [autoSignal, setAutoSignal] = useState('');
  const [direction, setDirection] = useState<'forward' | 'backward'>('forward');
  const [visibility, setVisibility] = useState<'public' | 'buddies' | 'followers' | 'private'>('private');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editReason, setEditReason] = useState('');
  const [editTarget, setEditTarget] = useState('');

  // The stream for one countdown at a time.
  const [historyId, setHistoryId] = useState<string | null>(null);
  const [history, setHistory] = useState<CountdownEvent[]>([]);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [checkInBusy, setCheckInBusy] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  // Share composer state
  const [shareOpen, setShareOpen] = useState(false);
  const [shareTarget, setShareTarget] = useState<'post' | 'dm' | 'gym' | 'community'>('post');
  const [shareCaption, setShareCaption] = useState('');
  const [shareMedia, setShareMedia] = useState<File[]>([]);
  const [shareLoading, setShareLoading] = useState(false);
  const [shareCountdown, setShareCountdown] = useState<UserCountdown | null>(null);

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
    fetchSignals();
  }, [fetchTemplates, fetchCountdowns, fetchSignals]);

  const handleCreate = async () => {
    if (!creatingTemplateId && !newReason.trim()) return;
    // An automatic countdown is defined by what advances it, so it needs a
    // signal before it can be created.
    if (countdownType === 'automatic' && !autoSignal) {
      setActionError('Pick what should advance this countdown.');
      return;
    }
    const payload: CreateUserCountdown = {
      template: creatingTemplateId || null,
      custom_reason: newReason.trim() || undefined,
      countdown_type: countdownType,
      unit,
      target_count: targetCount > 0 ? targetCount : undefined,
      ...(countdownType === 'automatic' ? { auto_advance_signal: autoSignal } : {}),
    };
    await createCountdown(payload);
    setCreatingTemplateId(null);
    setNewReason('');
    setTargetCount(0);
    setCountdownType('manual');
    setUnit('days');
    setAutoSignal('');
    setDirection('forward');
    setVisibility('private');
    setStep(1);
    fetchCountdowns();
  };

  const handleCheckIn = async (id: string) => {
    setCheckInBusy(id);
    setActionError(null);
    try {
      await checkIn(id);
      await fetchCountdowns();
    } catch (err: any) {
      setActionError(err?.response?.data?.message || 'Could not check in.');
    } finally {
      setCheckInBusy(null);
    }
  };

  const handleReset = async (id: string) => {
    if (!window.confirm('Reset this countdown to zero? The streak restarts from now, and the history is kept.')) return;
    setActionError(null);
    try {
      await resetCountdown(id);
      await fetchCountdowns();
      if (historyId === id) await loadHistory(id);
    } catch (err: any) {
      setActionError(err?.response?.data?.message || 'Could not reset.');
    }
  };

  /** Load a countdown's stream — the log of every check-in and reset. */
  const loadHistory = async (id: string) => {
    setHistoryLoading(true);
    try {
      const events = await countdownsApi.listEvents(id, { limit: 50 });
      setHistory(events);
    } catch {
      setHistory([]);
    } finally {
      setHistoryLoading(false);
    }
  };

  const toggleHistory = async (id: string) => {
    if (historyId === id) {
      setHistoryId(null);
      setHistory([]);
      return;
    }
    setHistoryId(id);
    await loadHistory(id);
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
      ...(c.countdown_type === 'automatic' && c.auto_advance_signal
        ? { auto_advance_signal: c.auto_advance_signal }
        : {}),
    };
    await createCountdown(payload);
    setCreatingTemplateId(null);
    setNewReason('');
    setTargetCount(0);
    setCountdownType('manual');
    setUnit('days');
    setAutoSignal('');
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

  const progressPctFor = (c: UserCountdown) => progressPct(c);

  // Progress-based counter color: 25%, 50%, 75%, 100% changes color. Gold at 100%.
  const counterColorForProgress = (pct: number) => {
    if (pct >= 100) return { bg: 'bg-buddy-gold', text: 'text-black', border: 'border-buddy-gold/50' };
    if (pct >= 75) return { bg: 'bg-buddy-green', text: 'text-white', border: 'border-buddy-green/50' };
    if (pct >= 50) return { bg: 'bg-buddy-gold', text: 'text-black', border: 'border-buddy-gold/50' };
    if (pct >= 25) return { bg: 'bg-buddy-orange', text: 'text-white', border: 'border-buddy-orange/50' };
    return { bg: 'bg-buddy-red', text: 'text-white', border: 'border-buddy-red/50' };
  };

  const handleShareCountdown = (c: UserCountdown) => {
    setShareCountdown(c);
    setShareTarget('post');
    const pct = progressPctFor(c);
    const head = countdownHeadline(c);
    const daysText = c.target_count
      ? `${head.value} / ${c.target_count} ${c.unit}`
      : `${head.value} ${c.unit}${head.value !== 1 ? 's' : ''}`;
    setShareCaption(`${c.display_reason}
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
    if (!shareCountdown) return;
    setShareLoading(true);
    try {
      const visibility = SHARE_VISIBILITY_MAP[shareTarget] || 'public';
      const draft = await analyticsApi.sharePrepare({
        kind: 'countdown',
        obj_id: shareCountdown.id,
        visibility,
        body: shareCaption,
      });
      await analyticsApi.sharePublish(draft.draft_id, {
        body: shareCaption,
        visibility,
        media_urls: shareMedia.map((f) => URL.createObjectURL(f)),
        tags: ['countdown', shareCountdown.countdown_type],
      });
      setShareOpen(false);
      setShareCaption('');
      setShareMedia([]);
      setShareCountdown(null);
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Failed to share countdown');
    } finally {
      setShareLoading(false);
    }
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
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Countdowns & Streaks</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Track sobriety, diet, gym attendance, walking days and more — manual or automatic.
          </p>
        </div>
        <button
          onClick={() => setCreatingTemplateId(templates[0]?.id || 'custom')}
          className="flex items-center gap-2 px-3 py-2 bg-buddy-green hover:bg-buddy-green/90 text-buddy-black rounded-lg text-sm font-medium transition-colors"
        >
          <Plus size={16} /> New Countdown
        </button>
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-red/10 p-3 border border-buddy-red/20 text-buddy-red text-sm">{error}</div>
      )}

      {actionError && (
        <div className="rounded-lg bg-buddy-red/10 p-3 border border-buddy-red/20 text-buddy-red text-sm flex items-start gap-2">
          <AlertCircle size={16} className="mt-0.5 shrink-0" />
          <span>{actionError}</span>
        </div>
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
            const pct = progressPctFor(c);
            const { bg, text, border } = counterColorForProgress(pct);
            // The counter is what the user completed; the streak's wall-clock
            // length is shown beside it, because the two move at different
            // times.
            const head = countdownHeadline(c);
            const checkIn = checkInState(c);
            const tag = typeTag(c, signals);
            const showShare = c.completed_at || c.countdown_type === 'manual';

            return (
              <div
                key={c.id}
                className={`flex flex-col sm:flex-row sm:items-start gap-4 p-4 rounded-lg border ${
                  c.completed_at ? 'bg-buddy-green/10 border-buddy-green/30' : 'border-buddy-border bg-buddy-bg'
                }`}
              >
                <div className="flex items-start gap-4 flex-1 min-w-0">
                {/* Big round counter - huge for attention, color changes with progress */}
                <div className="shrink-0 relative">
                  <div className={`w-24 h-24 rounded-full border-6 ${bg} ${border} flex flex-col items-center justify-center shadow-lg`}>
                    <span className={`text-4xl font-display font-bold ${text}`}>{head.value}</span>
                    <span className={`text-[11px] uppercase tracking-wider font-bold ${text}`}>{head.unit}</span>
                  </div>
                  {c.completed_at && (
                    <div className="absolute -top-2 -right-2 w-8 h-8 rounded-full bg-buddy-green flex items-center justify-center shadow-lg">
                      <Clock size={14} className="text-buddy-black" />
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <h4 className="font-medium text-buddy-text-primary">{c.display_reason}</h4>
                    <span className={`text-xs px-2 py-0.5 rounded-full whitespace-nowrap ${c.completed_at ? 'bg-buddy-green text-buddy-black' : tag.className}`}>
                      {c.completed_at ? 'Completed' : tag.text}
                    </span>
                  </div>
                  <p className="text-xs text-buddy-text-secondary mt-1">
                    Started {new Date(c.start_date).toLocaleDateString()}
                    {c.last_reset_at && (
                      <> · last reset {new Date(c.last_reset_at).toLocaleDateString()}</>
                    )}
                  </p>
                  <div className="w-full bg-buddy-surface/50 rounded-full h-2.5 mt-3 overflow-hidden">
                    <div
                      className={`h-full transition-all duration-500 ${bg}`}
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <div className="mt-3 text-xs text-buddy-text-secondary font-medium flex flex-wrap items-center gap-x-3 gap-y-1">
                    {c.target_count ? (
                      <span>Target: {c.target_count} {c.unit}</span>
                    ) : (
                      <span>No target</span>
                    )}
                    <span>
                      Streak: {head.streakUnits} {head.unit}
                      {head.streakUnits !== head.value && (
                        <span className="text-buddy-text-secondary/70"> ({head.value} checked in)</span>
                      )}
                    </span>
                  </div>

                  {/* The stream — every check-in, advance and reset. */}
                  <button
                    onClick={() => toggleHistory(c.id)}
                    aria-expanded={historyId === c.id}
                    className="mt-2 inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary hover:text-buddy-green transition-colors"
                  >
                    <History size={13} />
                    {historyId === c.id ? 'Hide history' : 'History'}
                  </button>
                  {historyId === c.id && (
                    <div className="mt-2 rounded-lg border border-buddy-border bg-buddy-surface/50 p-3">
                      {historyLoading ? (
                        <p className="text-xs text-buddy-text-secondary">Loading history…</p>
                      ) : history.length === 0 ? (
                        <p className="text-xs text-buddy-text-secondary">Nothing recorded yet.</p>
                      ) : (
                        <ol className="space-y-1.5">
                          {history.map((e) => (
                            <li key={e.id} className="flex items-center gap-2 text-xs">
                              <span
                                className={`w-1.5 h-1.5 rounded-full shrink-0 ${
                                  e.event_type === 'reset'
                                    ? 'bg-buddy-red'
                                    : e.event_type === 'auto_advance'
                                      ? 'bg-buddy-electric'
                                      : e.event_type === 'complete'
                                        ? 'bg-buddy-gold'
                                        : 'bg-buddy-green'
                                }`}
                              />
                              <span className="text-buddy-text-primary capitalize">
                                {e.event_type.replace('_', ' ')}
                              </span>
                              <span className="text-buddy-text-secondary">
                                → {e.count_after} {e.unit}
                              </span>
                              {e.run_elapsed_seconds > 0 && (
                                <span className="text-buddy-text-secondary/70">
                                  (ran {Math.round(e.run_elapsed_seconds / 3600)}h)
                                </span>
                              )}
                              <span className="ml-auto text-buddy-text-secondary/60 whitespace-nowrap">
                                {new Date(e.occurred_at).toLocaleString()}
                              </span>
                            </li>
                          ))}
                        </ol>
                      )}
                    </div>
                  )}
                </div>
                </div>
                <div className="shrink-0 flex items-center gap-2 sm:flex-col sm:items-stretch">
                  {/* Check in — the primary action for a manual countdown. */}
                  {c.countdown_type === 'manual' && (
                    <button
                      onClick={() => handleCheckIn(c.id)}
                      disabled={checkIn.locked || checkInBusy === c.id}
                      className={`flex-1 sm:w-full py-2 px-3 rounded-lg text-sm font-medium transition-colors shadow-md flex items-center justify-center gap-1.5 whitespace-nowrap ${
                        checkIn.locked
                          ? 'bg-buddy-surface text-buddy-text-secondary cursor-not-allowed shadow-none'
                          : 'bg-buddy-green hover:bg-buddy-green/90 text-buddy-black'
                      }`}
                    >
                      <Play size={16} /> {checkIn.locked ? checkIn.label : 'Check in'}
                    </button>
                  )}
                  {/* Share button - standalone, prominent */}
                  {showShare && (
                    <button
                      onClick={() => handleShareCountdown(c)}
                      className="flex-1 sm:w-full sm:mt-2 py-2 px-3 bg-buddy-green hover:bg-buddy-green/90 text-buddy-black rounded-lg text-sm font-medium transition-colors shadow-md flex items-center justify-center gap-1.5 whitespace-nowrap"
                    >
                      <Share2 size={16} /> Share
                    </button>
                  )}
                  {/* Three dots - More options */}
                  <div className="relative mt-0 sm:mt-2">
                    <button
                      onClick={(e) => { e.stopPropagation(); setMoreOptionsOpen(moreOptionsOpen === c.id ? null : c.id); }}
                      aria-label="More options"
                      className="w-8 h-8 shrink-0 rounded-lg bg-buddy-surface hover:bg-buddy-surface/80 flex items-center justify-center text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
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
                        {c.countdown_type === 'automatic' && (
                          <p className="px-3 py-2 text-xs text-buddy-text-secondary flex items-start gap-2">
                            <Zap size={13} className="w-4 h-4 mt-0.5 shrink-0 text-buddy-electric" />
                            Advances on: {signalLabel(signals, c.auto_advance_signal)}
                          </p>
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
                    step >= s ? 'bg-buddy-green text-buddy-black border-buddy-green' : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border'
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
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      A check-in unlocks once per {unit === 'hours' ? 'hour' : 'day'}, so the
                      counter follows what you have actually completed.
                    </p>
                  </div>

                  {/* An automatic countdown is defined by what advances it. */}
                  {countdownType === 'automatic' && (
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-buddy-text-secondary">
                        What should advance it?
                      </label>
                      <div className="grid grid-cols-1 gap-2">
                        {signals.map((s) => (
                          <button
                            key={s.key}
                            type="button"
                            onClick={() => setAutoSignal(s.key)}
                            className={`flex items-center gap-2 px-3 py-2 rounded-lg border text-left transition-colors ${
                              autoSignal === s.key
                                ? 'bg-buddy-electric/10 border-buddy-electric text-buddy-text-primary'
                                : 'bg-buddy-surface border-buddy-border text-buddy-text-secondary hover:border-buddy-border/50'
                            }`}
                          >
                            <Zap size={14} className={autoSignal === s.key ? 'text-buddy-electric' : ''} />
                            <span className="text-sm">{s.label}</span>
                          </button>
                        ))}
                      </div>
                      {signals.length === 0 && (
                        <p className="text-xs text-buddy-text-secondary">
                          Loading the signals this countdown can follow…
                        </p>
                      )}
                    </div>
                  )}

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
                  shareLoading ? 'bg-buddy-surface text-buddy-text-secondary' : 'bg-buddy-green text-buddy-black hover:bg-buddy-green/90'
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
