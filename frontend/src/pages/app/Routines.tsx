import { useCallback, useEffect, useState } from 'react';
import {
  Calendar, Activity, Dumbbell, Heart, X, Plus, Pencil, Check,
  ArrowDown, ArrowUp, Camera, Mic, Video, Trash2, Image as ImageIcon,
  Share2, Bell, Clock, ChevronDown,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Badge } from '@/components/ui/Badge';
import { countdownsApi } from '@/api/countdowns';
import type {
  Routine, CreateRoutine, RoutineType, HighlightKind, RoutineHighlight,
} from '@/types/countdowns';

const ROUTINE_TYPES: { key: RoutineType; label: string; icon: typeof Dumbbell; color: string; bg: string; hint: string }[] = [
  { key: 'walk', label: 'Walking', icon: Activity, color: 'text-buddy-green', bg: 'bg-buddy-green/10', hint: '5,000 steps' },
  { key: 'run', label: 'Running', icon: Activity, color: 'text-buddy-red', bg: 'bg-buddy-red/10', hint: '5 km' },
  { key: 'cycle', label: 'Cycling', icon: Activity, color: 'text-buddy-electric', bg: 'bg-buddy-electric/10', hint: '10 km' },
  { key: 'hike', label: 'Hiking', icon: Activity, color: 'text-buddy-orange', bg: 'bg-buddy-orange/10', hint: '5 km' },
  { key: 'workout', label: 'Workout', icon: Dumbbell, color: 'text-buddy-gold', bg: 'bg-buddy-gold/10', hint: '30 min' },
  { key: 'gym', label: 'Gym', icon: Dumbbell, color: 'text-buddy-blue', bg: 'bg-buddy-blue/10', hint: '4 sessions' },
  { key: 'other', label: 'Other', icon: Activity, color: 'text-buddy-text-secondary', bg: 'bg-buddy-surface-raised', hint: 'Custom' },
];

// Monday first, matching the backend contract (0 = Monday).
const ROUTINE_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const ACTIVATION_OPTIONS = [
  { key: 'week', label: 'Weekly' },
  { key: 'month', label: 'Monthly' },
  { key: 'holiday', label: 'Holiday' },
] as const;
const REMINDER_PRESETS = [0, 5, 15, 30, 60];
const OVERLAY_OPTIONS = [
  { key: 'top', label: 'Top' },
  { key: 'middle', label: 'Middle' },
  { key: 'bottom', label: 'Bottom' },
] as const;

function routineIcon(type: RoutineType) {
  return ROUTINE_TYPES.find((t) => t.key === type)?.icon || Activity;
}

function routineColors(type: RoutineType) {
  return ROUTINE_TYPES.find((t) => t.key === type) || ROUTINE_TYPES[0];
}

export default function Routines() {
  const [routines, setRoutines] = useState<Routine[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [customType, setCustomType] = useState('');
  const [showCustomInput, setShowCustomInput] = useState(false);

  // Routine editor + studio modal
  const [editing, setEditing] = useState<Routine | null>(null);
  const [draft, setDraft] = useState<CreateRoutine>({ type: 'walk', target: 30, unit: 'min' });
  const [studioTab, setStudioTab] = useState<'edit' | 'highlights' | 'share'>('edit');
  const [highlightTab, setHighlightTab] = useState<HighlightKind>('photo');
  const [highlights, setHighlights] = useState<RoutineHighlight[]>([]);
  const [highlightBusy, setHighlightBusy] = useState(false);
  const [studioError, setStudioError] = useState<string | null>(null);

  // Share controls
  const [shareAsStory, setShareAsStory] = useState(true);
  const [shareOverlay, setShareOverlay] = useState<'top' | 'middle' | 'bottom'>('middle');
  const [shareVisibility, setShareVisibility] = useState('public');
  const [shareBody, setShareBody] = useState('');
  const [shareBusy, setShareBusy] = useState(false);
  const [shareMessage, setShareMessage] = useState<string | null>(null);

  // Check-in modal for manual routines
  const [checkInRoutine, setCheckInRoutine] = useState<Routine | null>(null);
  const [checkInNote, setCheckInNote] = useState('');
  const [checkInValue, setCheckInValue] = useState('');
  const [checkInBusy, setCheckInBusy] = useState(false);

  const fetchRoutines = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await countdownsApi.listRoutines();
      setRoutines(Array.isArray(data) ? data : []);
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Failed to load routines');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchRoutines();
  }, [fetchRoutines]);

  // ── Create ────────────────────────────────────────────────────────────
  const addRoutine = async (typeKey: RoutineType, customName?: string) => {
    const typeInfo = ROUTINE_TYPES.find((t) => t.key === typeKey) || ROUTINE_TYPES[0];
    if (typeKey === 'other' && !customName?.trim()) {
      setShowCustomInput(true);
      return;
    }
    const payload: CreateRoutine = {
      type: typeKey,
      custom_name: typeKey === 'other' ? customName?.trim() : '',
      name: typeKey === 'other' ? customName?.trim() || 'Custom' : typeInfo.label,
      target: typeKey === 'walk' ? 5000
        : typeKey === 'run' || typeKey === 'hike' ? 5
        : typeKey === 'cycle' ? 10
        : typeKey === 'gym' ? 4
        : typeKey === 'workout' ? 30 : 10,
      unit: typeKey === 'walk' ? 'steps'
        : typeKey === 'run' || typeKey === 'cycle' || typeKey === 'hike' ? 'km'
        : typeKey === 'gym' ? 'sessions' : 'min',
      days: [],
    };
    try {
      const created = await countdownsApi.createRoutine(payload);
      setRoutines((prev) => [...prev, created]);
      setCustomType('');
      setShowCustomInput(false);
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Failed to create routine');
    }
  };

  const submitCustom = () => {
    const trimmed = customType.trim();
    if (!trimmed) return;
    addRoutine('other', trimmed);
  };

  // ── Edit / studio ─────────────────────────────────────────────────────
  const openStudio = async (routine: Routine, tab: typeof studioTab = 'edit') => {
    setStudioError(null);
    setShareMessage(null);
    setEditing(routine);
    setStudioTab(tab);
    setShareBody(`${routine.display_name} — ${routine.streak} day streak.`);
    setDraft({
      type: routine.type,
      name: routine.name,
      custom_name: routine.custom_name,
      target: routine.target,
      unit: routine.unit,
      days: [...routine.days],
      target_day: routine.target_day,
      time_of_day: routine.time_of_day ? routine.time_of_day.slice(0, 5) : null,
      reminder_minutes: [...routine.reminder_minutes],
      activation: routine.activation,
      tracking: routine.tracking,
    });
    try {
      const items = await countdownsApi.listRoutineHighlights(routine.id);
      setHighlights(items);
    } catch {
      setHighlights([]);
    }
  };

  const saveDraft = async () => {
    if (!editing) return;
    setStudioError(null);
    try {
      const updated = await countdownsApi.updateRoutine(editing.id, draft);
      setRoutines((prev) => prev.map((r) => (r.id === editing.id ? updated : r)));
      setEditing(updated);
    } catch (err: any) {
      setStudioError(err?.response?.data?.message || 'Could not save the routine.');
    }
  };

  const toggleDraftDay = (dayIndex: number) => {
    setDraft((prev) => ({
      ...prev,
      days: (prev.days || []).includes(dayIndex)
        ? (prev.days || []).filter((d) => d !== dayIndex)
        : [...(prev.days || []), dayIndex].sort((a, b) => a - b),
    }));
  };

  const toggleReminder = (minutes: number) => {
    setDraft((prev) => ({
      ...prev,
      reminder_minutes: (prev.reminder_minutes || []).includes(minutes)
        ? (prev.reminder_minutes || []).filter((m) => m !== minutes)
        : [...(prev.reminder_minutes || []), minutes].sort((a, b) => a - b),
    }));
  };

  // ── Reorder ──────────────────────────────────────────────────────────
  const move = async (routineId: string, direction: -1 | 1) => {
    const index = routines.findIndex((r) => r.id === routineId);
    const target = index + direction;
    if (index < 0 || target < 0 || target >= routines.length) return;
    const reordered = [...routines];
    const [moved] = reordered.splice(index, 1);
    reordered.splice(target, 0, moved);
    setRoutines(reordered);
    try {
      const saved = await countdownsApi.reorderRoutines(reordered.map((r) => r.id));
      setRoutines(saved);
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Could not save the order');
      fetchRoutines();
    }
  };

  const toggleDay = async (routineId: string, dayIndex: number) => {
    const routine = routines.find((r) => r.id === routineId);
    if (!routine) return;
    const newDays = routine.days.includes(dayIndex)
      ? routine.days.filter((d) => d !== dayIndex)
      : [...routine.days, dayIndex].sort((a, b) => a - b);
    try {
      const updated = await countdownsApi.updateRoutine(routineId, { days: newDays });
      setRoutines((prev) => prev.map((r) => (r.id === routineId ? updated : r)));
    } catch {
      setError('Failed to update routine');
    }
  };

  const deleteRoutine = async (id: string) => {
    if (!window.confirm('Delete this routine?')) return;
    try {
      await countdownsApi.deleteRoutine(id);
      setRoutines((prev) => prev.filter((r) => r.id !== id));
    } catch {
      setError('Failed to delete routine');
    }
  };

  // ── Check-in ─────────────────────────────────────────────────────────
  const checkIn = async (routine: Routine) => {
    if (routine.tracking === 'manual') {
      setCheckInRoutine(routine);
      setCheckInNote('');
      setCheckInValue('');
      return;
    }
    setCheckInBusy(true);
    try {
      const result = await countdownsApi.checkInRoutine(routine.id);
      setRoutines((prev) => prev.map((r) => (r.id === routine.id ? result.routine : r)));
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Could not check in');
    } finally {
      setCheckInBusy(false);
    }
  };

  const submitManualCheckIn = async () => {
    if (!checkInRoutine) return;
    setCheckInBusy(true);
    try {
      const result = await countdownsApi.checkInRoutine(checkInRoutine.id, {
        note: checkInNote,
        value: checkInValue ? Number(checkInValue) : undefined,
      });
      setRoutines((prev) => prev.map((r) => (r.id === checkInRoutine.id ? result.routine : r)));
      setCheckInRoutine(null);
    } catch (err: any) {
      setStudioError(err?.response?.data?.message || 'Could not record that check-in.');
    } finally {
      setCheckInBusy(false);
    }
  };

  // ── Highlights ───────────────────────────────────────────────────────
  const uploadHighlight = async (file: File) => {
    if (!editing) return;
    setHighlightBusy(true);
    try {
      const created = await countdownsApi.uploadRoutineHighlight(editing.id, highlightTab, file);
      setHighlights((prev) => [created, ...prev]);
      // Keep the row card's tally fresh without a refetch.
      setRoutines((prev) => prev.map((r) =>
        r.id === editing.id ? { ...r, highlights: [created, ...r.highlights] } : r,
      ));
    } catch (err: any) {
      setStudioError(err?.response?.data?.message || 'Could not upload that highlight.');
    } finally {
      setHighlightBusy(false);
    }
  };

  const removeHighlight = async (highlight: RoutineHighlight) => {
    if (!editing) return;
    try {
      await countdownsApi.deleteRoutineHighlight(editing.id, highlight.id);
      setHighlights((prev) => prev.filter((h) => h.id !== highlight.id));
      setRoutines((prev) => prev.map((r) =>
        r.id === editing.id ? { ...r, highlights: r.highlights.filter((h) => h.id !== highlight.id) } : r,
      ));
    } catch {
      setStudioError('Could not remove that highlight.');
    }
  };

  // ── Share ────────────────────────────────────────────────────────────
  const share = async () => {
    if (!editing) return;
    setShareBusy(true);
    setShareMessage(null);
    try {
      const highlight = highlights[0];
      const result = await countdownsApi.shareRoutine(editing.id, {
        as_story: shareAsStory,
        overlay_position: shareOverlay,
        visibility: shareVisibility,
        media_url: highlight?.file_url || undefined,
        body: shareBody,
      });
      setShareMessage(`Shared as ${shareAsStory ? 'a story' : 'a post'} (${result.post_type}).`);
    } catch (err: any) {
      setStudioError(err?.response?.data?.message || 'Could not share the routine.');
    } finally {
      setShareBusy(false);
    }
  };

  const today = (new Date().getDay() + 6) % 7; // Monday = 0
  const visibleHighlights = highlights.filter((h) => h.kind === highlightTab);

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Routines</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Build recurring habits — walking, running, gym and your own. Set targets,
            reminders and the day that matters.
          </p>
        </div>
        <Button size="lg" onClick={() => document.getElementById('routine-types')?.scrollIntoView({ behavior: 'smooth' })}>
          <Plus size={16} className="mr-1" /> New Routine
        </Button>
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-red/10 p-3 border border-buddy-red/20 text-buddy-red text-sm" role="alert">
          {error}
        </div>
      )}

      {/* Quick-add */}
      <Card id="routine-types" className="p-5 space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-semibold">Routine types</h3>
          <span className="text-xs text-buddy-text-secondary">Pick one to start tracking</span>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-7 gap-3">
          {ROUTINE_TYPES.map((t) => (
            <button
              key={t.key}
              type="button"
              onClick={() => addRoutine(t.key)}
              className={`flex flex-col items-center gap-2 p-3 rounded-xl border border-buddy-surface-raised ${t.bg} ${t.color} hover:border-buddy-green transition-colors`}
            >
              <t.icon size={22} />
              <span className="font-medium text-xs text-buddy-text-primary">{t.label}</span>
              <span className="text-[10px] text-buddy-text-secondary">{t.hint}</span>
            </button>
          ))}
        </div>
        {(showCustomInput || customType) && (
          <div className="flex gap-2">
            <Input
              value={customType}
              onChange={(e) => setCustomType(e.target.value)}
              placeholder="Custom routine name (e.g. Cold shower)"
              onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), submitCustom())}
              autoFocus
            />
            <Button onClick={submitCustom} disabled={!customType.trim()}>Add</Button>
          </div>
        )}
      </Card>

      {/* List */}
      <Card className="p-5 space-y-4">
        <h3 className="font-semibold">Your Routines</h3>
        {loading ? (
          <div className="text-center py-12 text-buddy-text-secondary text-sm">Loading routines…</div>
        ) : routines.length === 0 ? (
          <div className="text-center py-12 text-buddy-text-secondary text-sm">
            <Calendar size={48} className="mx-auto mb-3 opacity-50" />
            <p>No routines yet. Create one above to start building habits.</p>
          </div>
        ) : (
          <ol className="space-y-3">
            {routines.map((routine) => {
              const typeInfo = routineColors(routine.type);
              const Icon = routineIcon(routine.type);
              const activeToday = routine.days.includes(today);
              return (
                <li
                  key={routine.id}
                  className={`p-4 rounded-xl border transition-colors ${
                    routine.completed_today
                      ? 'bg-buddy-green/10 border-buddy-green/30'
                      : 'border-buddy-surface-raised bg-buddy-surface'
                  }`}
                >
                  <div className="flex items-start gap-3">
                    {/* Reorder */}
                    <div className="flex flex-col pt-1 shrink-0">
                      <button type="button" aria-label="Move up" onClick={() => move(routine.id, -1)} className="p-1 text-buddy-text-secondary hover:text-buddy-text-primary">
                        <ArrowUp size={14} />
                      </button>
                      <button type="button" aria-label="Move down" onClick={() => move(routine.id, 1)} className="p-1 text-buddy-text-secondary hover:text-buddy-text-primary">
                        <ArrowDown size={14} />
                      </button>
                    </div>

                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${typeInfo.bg} ${typeInfo.color}`}>
                      <Icon size={20} />
                    </div>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h4 className={`font-medium truncate ${routine.completed_today ? 'line-through text-buddy-text-secondary' : ''}`}>
                          {routine.display_name}
                        </h4>
                        <Badge variant="silver" label={routine.activation} />
                        {routine.tracking === 'manual' && <Badge variant="gold" label="Off-app" />}
                        {activeToday && <Badge variant="green" label="Today" />}
                      </div>
                      <p className="text-xs text-buddy-text-secondary mt-0.5">
                        {routine.target} {routine.unit} · {routine.streak} day streak
                        {routine.time_of_day ? ` · ${routine.time_of_day.slice(0, 5)}` : ''}
                        {routine.reminder_minutes.length > 0 && ` · reminder ${routine.reminder_minutes.join('/')}m`}
                      </p>
                    </div>

                    <div className="flex items-center gap-1 shrink-0">
                      <button
                        type="button"
                        onClick={() => checkIn(routine)}
                        disabled={checkInBusy}
                        aria-label={`Check in ${routine.display_name}`}
                        className={`p-2 rounded-lg transition-colors ${
                          routine.completed_today
                            ? 'bg-buddy-green text-buddy-black'
                            : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-green'
                        }`}
                      >
                        <Check size={16} />
                      </button>
                      <button
                        type="button"
                        aria-label={`Edit ${routine.display_name}`}
                        onClick={() => openStudio(routine, 'edit')}
                        className="p-2 rounded-lg text-buddy-text-secondary hover:bg-buddy-surface-raised"
                      >
                        <Pencil size={16} />
                      </button>
                      <button
                        type="button"
                        aria-label={`Share ${routine.display_name}`}
                        onClick={() => openStudio(routine, 'share')}
                        className="p-2 rounded-lg text-buddy-text-secondary hover:bg-buddy-surface-raised"
                      >
                        <Share2 size={16} />
                      </button>
                      <button
                        type="button"
                        aria-label={`Delete ${routine.display_name}`}
                        onClick={() => deleteRoutine(routine.id)}
                        className="p-2 rounded-lg text-buddy-text-secondary hover:text-buddy-red"
                      >
                        <X size={16} />
                      </button>
                    </div>
                  </div>

                  {/* Day strip: today carries the arrow + active colour; the
                      target day is marked with a dot. */}
                  <div className="mt-3 flex items-center gap-1 flex-wrap">
                    {ROUTINE_DAYS.map((day, index) => {
                      const isActive = routine.days.includes(index);
                      const isTarget = routine.target_day === index;
                      const isToday = index === today;
                      return (
                        <button
                          key={day}
                          type="button"
                          onClick={() => toggleDay(routine.id, index)}
                          aria-label={`${day}${isActive ? ' (active)' : ''}${isTarget ? ' (target day)' : ''}`}
                          className={`relative w-8 h-8 rounded-md text-[10px] font-semibold flex flex-col items-center justify-center transition-colors ${
                            isActive
                              ? 'bg-buddy-green text-buddy-black'
                              : 'bg-buddy-surface-raised text-buddy-text-secondary/60'
                          } ${isToday ? 'ring-2 ring-buddy-green' : ''}`}
                        >
                          {day}
                          {isToday && <ChevronDown size={8} className="absolute -top-1.5 text-buddy-green" />}
                          {isTarget && <span className="absolute bottom-0.5 w-1 h-1 rounded-full bg-buddy-gold" />}
                        </button>
                      );
                    })}
                  </div>

                  {routine.completed_today && (
                    <div className="mt-3 flex items-center gap-2 text-xs text-buddy-green">
                      <Heart size={14} className="fill-buddy-green" />
                      <span>Completed today</span>
                    </div>
                  )}
                </li>
              );
            })}
          </ol>
        )}
      </Card>

      {/* ── Manual check-in ───────────────────────────────────────────── */}
      <Modal isOpen={!!checkInRoutine} onClose={() => setCheckInRoutine(null)} title="Log a session">
        <div className="space-y-3">
          <p className="text-sm text-buddy-text-secondary">
            {checkInRoutine?.display_name} — manual routines are logged by hand.
          </p>
          <Input
            label={`Value (${checkInRoutine?.unit || 'reps'}, optional)`}
            type="number"
            value={checkInValue}
            onChange={(e) => setCheckInValue(e.target.value)}
          />
          <div>
            <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Note</label>
            <textarea
              value={checkInNote}
              onChange={(e) => setCheckInNote(e.target.value)}
              rows={2}
              className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
              placeholder="How did it go?"
            />
          </div>
          <Button className="w-full" onClick={submitManualCheckIn} isLoading={checkInBusy}>
            <Check size={14} className="mr-1" /> Save check-in
          </Button>
        </div>
      </Modal>

      {/* ── Studio modal: edit / highlights / share ────────────────────── */}
      <Modal isOpen={!!editing} onClose={() => setEditing(null)} title={editing?.display_name || 'Routine'} size="lg">
        {editing && (
          <div className="space-y-4">
            <div className="flex gap-1 border-b border-buddy-surface">
              {([
                { key: 'edit', label: 'Edit' },
                { key: 'highlights', label: `Highlights (${highlights.length})` },
                { key: 'share', label: 'Share' },
              ] as const).map(({ key, label }) => (
                <button
                  key={key}
                  type="button"
                  onClick={() => setStudioTab(key)}
                  className={`px-4 py-2 text-sm border-b-2 -mb-px transition-colors ${
                    studioTab === key
                      ? 'border-buddy-green text-buddy-green font-semibold'
                      : 'border-transparent text-buddy-text-secondary'
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>

            {studioError && (
              <p className="text-xs text-buddy-red" role="alert">{studioError}</p>
            )}

            {/* Edit tab */}
            {studioTab === 'edit' && (
              <div className="space-y-3 max-h-[60vh] overflow-y-auto">
                {draft.type === 'other' && (
                  <Input
                    label="Custom name"
                    value={draft.custom_name || ''}
                    onChange={(e) => setDraft({ ...draft, custom_name: e.target.value })}
                  />
                )}
                <Input
                  label="Name"
                  value={draft.name || ''}
                  onChange={(e) => setDraft({ ...draft, name: e.target.value })}
                />
                <div className="grid grid-cols-2 gap-3">
                  <Input
                    label="Target"
                    type="number"
                    value={String(draft.target)}
                    onChange={(e) => setDraft({ ...draft, target: Number(e.target.value || 0) })}
                  />
                  <Input
                    label="Unit"
                    value={draft.unit}
                    onChange={(e) => setDraft({ ...draft, unit: e.target.value })}
                  />
                </div>

                <div>
                  <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">Active days</p>
                  <div className="flex gap-1">
                    {ROUTINE_DAYS.map((day, index) => {
                      const active = (draft.days || []).includes(index);
                      return (
                        <button
                          key={day}
                          type="button"
                          onClick={() => toggleDraftDay(index)}
                          className={`w-8 h-8 rounded-md text-[10px] font-semibold ${
                            active ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-text-secondary'
                          }`}
                        >
                          {day}
                        </button>
                      );
                    })}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Target day</label>
                    <select
                      value={draft.target_day ?? ''}
                      onChange={(e) => setDraft({ ...draft, target_day: e.target.value === '' ? null : Number(e.target.value) })}
                      className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                    >
                      <option value="">None</option>
                      {ROUTINE_DAYS.map((day, index) => (
                        <option key={day} value={index}>{day}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                      <Clock size={12} className="inline mr-1" />Time of day
                    </label>
                    <input
                      type="time"
                      value={draft.time_of_day || ''}
                      onChange={(e) => setDraft({ ...draft, time_of_day: e.target.value || null })}
                      className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                    />
                  </div>
                </div>

                <div>
                  <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">
                    <Bell size={12} className="inline mr-1" />Reminders before
                  </p>
                  <div className="flex gap-1 flex-wrap">
                    {REMINDER_PRESETS.map((minutes) => {
                      const active = (draft.reminder_minutes || []).includes(minutes);
                      return (
                        <button
                          key={minutes}
                          type="button"
                          onClick={() => toggleReminder(minutes)}
                          className={`px-3 py-1.5 rounded-full text-xs ${
                            active ? 'bg-buddy-green text-buddy-black font-semibold' : 'bg-buddy-surface text-buddy-text-secondary'
                          }`}
                        >
                          {minutes === 0 ? 'At start' : `${minutes}m`}
                        </button>
                      );
                    })}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Activation</label>
                    <select
                      value={draft.activation || 'week'}
                      onChange={(e) => setDraft({ ...draft, activation: e.target.value as CreateRoutine['activation'] })}
                      className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                    >
                      {ACTIVATION_OPTIONS.map((option) => (
                        <option key={option.key} value={option.key}>{option.label}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Tracking</label>
                    <select
                      value={draft.tracking || 'app'}
                      onChange={(e) => setDraft({ ...draft, tracking: e.target.value as CreateRoutine['tracking'] })}
                      className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                    >
                      <option value="app">In-app</option>
                      <option value="manual">Manual / off-app</option>
                    </select>
                  </div>
                </div>

                <Button className="w-full" onClick={saveDraft}>Save changes</Button>
              </div>
            )}

            {/* Highlights tab */}
            {studioTab === 'highlights' && (
              <div className="space-y-3">
                <div className="flex gap-1">
                  {(['photo', 'voice', 'video'] as HighlightKind[]).map((kind) => {
                    const Icon = kind === 'photo' ? Camera : kind === 'voice' ? Mic : Video;
                    return (
                      <button
                        key={kind}
                        type="button"
                        onClick={() => setHighlightTab(kind)}
                        className={`flex items-center gap-1.5 px-3 py-2 rounded-full text-xs capitalize ${
                          highlightTab === kind
                            ? 'bg-buddy-green text-buddy-black font-semibold'
                            : 'bg-buddy-surface text-buddy-text-secondary'
                        }`}
                      >
                        <Icon size={12} /> {kind}
                      </button>
                    );
                  })}
                </div>
                <label className="flex items-center justify-center gap-2 w-full py-3 rounded-xl border border-dashed border-buddy-surface-raised text-sm text-buddy-text-secondary cursor-pointer hover:border-buddy-green">
                  {highlightBusy ? 'Uploading…' : `Add a ${highlightTab} highlight`}
                  <input
                    type="file"
                    className="hidden"
                    disabled={highlightBusy}
                    accept={highlightTab === 'photo' ? 'image/*' : highlightTab === 'video' ? 'video/*' : 'audio/*'}
                    capture={highlightTab === 'voice' ? undefined : 'environment'}
                    onChange={(e) => e.target.files?.[0] && uploadHighlight(e.target.files[0])}
                  />
                </label>
                {visibleHighlights.length === 0 ? (
                  <p className="text-center text-xs text-buddy-text-secondary py-6">
                    No {highlightTab} highlights yet.
                  </p>
                ) : (
                  <div className="grid grid-cols-3 gap-2">
                    {visibleHighlights.map((item) => (
                      <div key={item.id} className="relative aspect-square rounded-xl overflow-hidden bg-buddy-surface group">
                        {item.kind === 'photo' && (
                          <img src={item.file_url} alt={item.caption || 'Highlight'} className="w-full h-full object-cover" loading="lazy" />
                        )}
                        {item.kind === 'video' && (
                          <video src={item.file_url} className="w-full h-full object-cover" muted playsInline />
                        )}
                        {item.kind === 'voice' && (
                          <div className="w-full h-full flex items-center justify-center"><Mic size={28} className="text-buddy-green" /></div>
                        )}
                        <button
                          type="button"
                          aria-label="Remove highlight"
                          onClick={() => removeHighlight(item)}
                          className="absolute top-1 right-1 p-1.5 rounded-full bg-black/70 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          <Trash2 size={12} />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Share tab */}
            {studioTab === 'share' && (
              <div className="space-y-4">
                <div>
                  <p className="text-sm font-medium text-buddy-text-secondary mb-1">Metrics overlay</p>
                  <p className="text-xs text-buddy-text-secondary/70 mb-2">
                    Where the streak card sits on your {shareAsStory ? 'story' : 'post'}.
                  </p>
                  <div className="grid grid-cols-3 gap-2">
                    {OVERLAY_OPTIONS.map((option) => (
                      <button
                        key={option.key}
                        type="button"
                        onClick={() => setShareOverlay(option.key)}
                        className={`py-2 rounded-xl text-xs border transition-colors ${
                          shareOverlay === option.key
                            ? 'border-buddy-green bg-buddy-green/10 text-buddy-green font-semibold'
                            : 'border-buddy-surface-raised text-buddy-text-secondary'
                        }`}
                      >
                        {option.label}
                      </button>
                    ))}
                  </div>
                </div>

                <label className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={shareAsStory}
                    onChange={(e) => setShareAsStory(e.target.checked)}
                    className="accent-buddy-green"
                  />
                  Share as a story (moment) instead of a feed post
                </label>

                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Visibility</label>
                  <select
                    value={shareVisibility}
                    onChange={(e) => setShareVisibility(e.target.value)}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  >
                    <option value="public">Public</option>
                    <option value="buddies">Buddies only</option>
                    <option value="gym_members">Gym members</option>
                    <option value="private">Private</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Caption</label>
                  <textarea
                    value={shareBody}
                    onChange={(e) => setShareBody(e.target.value)}
                    rows={2}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
                  />
                </div>

                {highlights.length > 0 && (
                  <p className="text-xs text-buddy-text-secondary flex items-center gap-2">
                    <ImageIcon size={12} /> Using {highlights[0].kind} highlight as media ({highlights.length} saved)
                  </p>
                )}

                {shareMessage && <p className="text-xs text-buddy-green">{shareMessage}</p>}
                <Button className="w-full" onClick={share} isLoading={shareBusy}>
                  <Share2 size={14} className="mr-1" /> Share
                </Button>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
