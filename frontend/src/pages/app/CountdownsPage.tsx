import { useState } from 'react';
import {
  Plus, RefreshCw, Trash2, Edit, Play, Timer,
} from 'lucide-react';
import { useCountdownsStore } from '@/store/countdownsStore';
import type { UserCountdown, CreateUserCountdown } from '@/types/countdowns';

const TEMPLATE_ICONS: Record<string, string> = {
  sobriety: '🍻',
  no_artificial_sugars: '🍬',
  no_animal_proteins: '🌱',
  gym_attendance: '🏋️',
  walking_days: '🚶',
  no_drugs: '💊',
  no_nut_month: '🥜',
  custom: '📅',
};

export default function CountdownsPage() {
  const { templates, countdowns, loading, error, fetchTemplates, fetchCountdowns, createCountdown, checkIn, resetCountdown, updateCountdown, deleteCountdown } = useCountdownsStore();
  const [creating, setCreating] = useState(false);
  const [newReason, setNewReason] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editReason, setEditReason] = useState('');
  const [editTarget, setEditTarget] = useState('');

  // Initialize on mount
  const initialized = useState(false);
  if (!initialized[0] && typeof window !== 'undefined') {
    fetchTemplates();
    fetchCountdowns();
    initialized[0] = true;
  }

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedTemplate && !newReason.trim()) return;
    const payload: CreateUserCountdown = {
      template: selectedTemplate || null,
      custom_reason: newReason.trim() || undefined,
      countdown_type: 'manual',
      unit: 'days',
    };
    await createCountdown(payload);
    setCreating(false);
    setNewReason('');
    setSelectedTemplate(null);
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
          onClick={() => setCreating(!creating)}
          className="flex items-center gap-2 px-3 py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg text-sm font-medium transition-colors"
        >
          <Plus size={16} /> {creating ? 'Close' : 'New Countdown'}
        </button>
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-error/10 p-3 border border-buddy-error/20 text-buddy-error text-sm">
          {error}
        </div>
      )}

      {/* Create countdown form */}
      {creating && (
        <div className="bg-buddy-surface rounded-xl p-4 border border-buddy-border">
          <h3 className="font-semibold mb-3">New Countdown</h3>
          <form onSubmit={handleCreate} className="space-y-3">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <label className="flex flex-col gap-1.5 text-sm font-medium">
                Template
                <select
                  value={selectedTemplate ?? ''}
                  onChange={(e) => setSelectedTemplate(e.target.value || null)}
                  className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                >
                  <option value="">Choose a reason…</option>
                  {templates.map((t) => (
                    <option key={t.code} value={t.code}>
                      {TEMPLATE_ICONS[t.code] ?? '📅'} {t.title}
                    </option>
                  ))}
                  <option value="custom">📅 Custom reason</option>
                </select>
              </label>
              <label className="flex flex-col gap-1.5 text-sm font-medium">
                Custom reason (when "Custom reason" is selected)
                <input
                  value={newReason}
                  onChange={(e) => setNewReason(e.target.value)}
                  placeholder="e.g. Days without coffee"
                  className="mt-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                />
              </label>
            </div>
            <button
              type="submit"
              disabled={!selectedTemplate && !newReason.trim()}
              className="w-full py-2 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Create Countdown
            </button>
          </form>
        </div>
      )}

      {/* Countdowns list */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-4">
        <h3 className="font-semibold mb-4">Your Countdowns</h3>

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
