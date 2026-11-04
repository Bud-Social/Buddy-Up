import { useState, useEffect } from 'react';
import {
  Plus, RefreshCw, Trash2, Edit, Play, Timer, X,
  Wine, Minus, Leaf, Dumbbell, MapPin, AlertCircle,
} from 'lucide-react';
import { useCountdownsStore } from '@/store/countdownsStore';
import type { UserCountdown, CreateUserCountdown } from '@/types/countdowns';

const TEMPLATE_ICONS: Record<string, React.ComponentType<any>> = {
  sobriety: Wine,
  no_artificial_sugars: Minus,
  no_animal_proteins: Leaf,
  gym_attendance: Dumbbell,
  walking_days: MapPin,
  no_drugs: AlertCircle,
  no_nut_month: Leaf,
  custom: Plus,
};

const TEMPLATE_COLORS: Record<string, string> = {
  sobriety: 'bg-buddy-red/10 text-buddy-red',
  no_artificial_sugars: 'bg-buddy-orange/10 text-buddy-orange',
  no_animal_proteins: 'bg-buddy-green/10 text-buddy-green',
  gym_attendance: 'bg-buddy-electric/10 text-buddy-electric',
  walking_days: 'bg-buddy-green/10 text-buddy-green',
  no_drugs: 'bg-buddy-red/10 text-buddy-red',
  no_nut_month: 'bg-buddy-gold/10 text-buddy-gold',
  custom: 'bg-buddy-text-secondary/10 text-buddy-text-secondary',
};

const VISIBILITY_OPTIONS: { value: 'public' | 'buddies' | 'followers' | 'private'; label: string; labelText: string }[] = [
  { value: 'public', label: 'Public', labelText: 'Anyone can see' },
  { value: 'buddies', label: 'Buddies Only', labelText: 'Confirmed buddies' },
  { value: 'followers', label: 'Followers', labelText: 'People who follow you' },
  { value: 'private', label: 'Private', labelText: 'Only you can see' },
];

export default function CountdownsPage() {
  const { countdowns, loading, error, fetchTemplates, fetchCountdowns, createCountdown, checkIn, resetCountdown, updateCountdown, deleteCountdown, templates } = useCountdownsStore();
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

  // Initialize on mount
  useEffect(() => {
    fetchTemplates();
    fetchCountdowns();
  }, [fetchTemplates, fetchCountdowns]);

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

  const startEdit = (c: UserCountdown) => {
    setEditingId(c.id);
    setEditReason(c.custom_reason || c.template_detail?.title || '');
    setEditTarget(String(c.target_count || ''));
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
          onClick={() => setCreatingTemplateId(null)}
          className="flex items-center gap-2 px-3 py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg text-sm font-medium transition-colors"
        >
          <Plus size={16} /> New Countdown
        </button>
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-error/10 p-3 border border-buddy-error/20 text-buddy-error text-sm">{error}</div>
      )}

      {/* Template cards */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-buddy-text-primary">Start a New Countdown</h3>
          <span className="text-xs text-buddy-text-secondary">Tap a template to begin</span>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {templates.map((tmpl) => {
            const isSelected = creatingTemplateId === tmpl.id;
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
                <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${tmpl.color.replace('/10', '/20')} ${tmpl.color.split(' ')[0]}`}>
                  {(() => { const Icon = TEMPLATE_ICONS[tmpl.code]; return <Icon className="text-xl" />; })()}
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
                    step >= s ? 'bg-buddy-green text-buddy-white border-buddy-green' : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border'
                  }`}>
                    {s}
                  </div>
                  {s < 3 && <div className="h-px bg-buddy-border w-4"></div>}
                </div>
              ))}
            </div>

            <form onSubmit={(e) => {
              e.preventDefault();
              handleCreate();
            }} className="space-y-4">
              {/* Step 1: Template selection */}
              {step === 1 && (
                <div className="space-y-4">
                  <div className="mb-4">
                    <label className="text-sm font-medium text-buddy-text-secondary">Choose a template</label>
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                      {templates.map((tmpl) => {
                        const isSel = creatingTemplateId === tmpl.id;
                        return (
                          <button
                            key={tmpl.id}
                            type="button"
                            onClick={() => setCreatingTemplateId(tmpl.id)}
                            className={`flex flex-col items-center gap-2 p-3 rounded-xl border transition-colors ${
                              isSel ? 'bg-buddy-green/10 border-buddy-green' : 'bg-buddy-surface border-buddy-border hover:border-buddy-border/50'
                            }`}
                          >
                            <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${TEMPLATE_COLORS[tmpl.code]?.replace('/10', '/20')} ${TEMPLATE_COLORS[tmpl.code]?.split(' ')[0]}`}>
                              {(() => { const Icon = TEMPLATE_ICONS[tmpl.code]; return <Icon className="text-xl" />; })()}
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
                      {(['days', 'hours'] as const).map((u) => (
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

      {/* Countdowns list */}
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

        {countdowns.length === 0 && !loading && (
          <div className="text-center py-8 text-buddy-text-secondary">
            <Timer size={32} className="mx-auto mb-2 opacity-50" />
            <p>No countdowns yet. Create one above to start tracking.</p>
          </div>
        )}

        <div className="space-y-3">
          {countdowns.map((c) => (
            <div
              key={c.id}
              className={`flex items-start gap-3 p-3 rounded-lg border ${
                c.completed_at ? 'bg-buddy-green/10 border-buddy-green/30' : 'border-buddy-border bg-buddy-bg'
              }`}
            >
              <div className="text-2xl shrink-0">{c.display_icon}</div>
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
                  <button onClick={() => startEdit(c)} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                    <Edit size={14} className="mr-1" /> Edit
                  </button>
                  <button
                    onClick={() => handleReset(c.id)}
                    className="text-buddy-error hover:text-buddy-error/90"
                  >
                    <RefreshCw size={14} className="mr-1" /> Reset
                  </button>
                  <button
                    onClick={() => handleDelete(c.id)}
                    className="text-buddy-text-secondary hover:text-buddy-error"
                  >
                    <Trash2 size={14} className="mr-1" /> Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

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
    </div>
  );
}