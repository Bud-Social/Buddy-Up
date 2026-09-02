/**
 * CaptionsPanel — auto-captions toggle plus a manual timed-segment editor
 * for power users. Auto captions generate after publish and become
 * editable on the post itself.
 */
import { Plus, Trash2 } from 'lucide-react';
import { formatMs } from '@/lib/createStudio';

export interface CaptionSegment {
  id: string;
  start_ms: number;
  end_ms: number;
  text: string;
}

interface CaptionsPanelProps {
  hasVideo: boolean;
  autoCaptions: boolean;
  onToggleAuto: (on: boolean) => void;
  segments: CaptionSegment[];
  onChangeSegments: (segments: CaptionSegment[]) => void;
}

const LANGUAGES = 'English (more languages coming)';

export function CaptionsPanel({ hasVideo, autoCaptions, onToggleAuto, segments, onChangeSegments }: CaptionsPanelProps) {
  const update = (id: string, patch: Partial<CaptionSegment>) =>
    onChangeSegments(segments.map((s) => (s.id === id ? { ...s, ...patch } : s)));

  const remove = (id: string) => onChangeSegments(segments.filter((s) => s.id !== id));

  const add = () =>
    onChangeSegments([
      ...segments,
      { id: crypto.randomUUID(), start_ms: 0, end_ms: 0, text: '' },
    ]);

  return (
    <div className="space-y-4">
      {hasVideo && (
        <button
          onClick={() => onToggleAuto(!autoCaptions)}
          className="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl bg-buddy-surface-raised text-left"
          aria-pressed={autoCaptions}
        >
          <div className="flex-1">
            <p className="text-sm font-semibold text-buddy-text-primary">Auto-captions</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              Generated after publish in {LANGUAGES}, then editable on the post.
            </p>
          </div>
          <span
            className={`relative inline-flex h-6 w-11 shrink-0 rounded-full transition-colors ${autoCaptions ? 'bg-buddy-green' : 'bg-buddy-surface'}`}
          >
            <span
              className={`absolute top-0.5 left-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform ${autoCaptions ? 'translate-x-5' : ''}`}
            />
          </span>
        </button>
      )}

      <div>
        <div className="flex items-center justify-between mb-2">
          <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide">
            Manual caption segments
          </p>
          <button
            onClick={add}
            className="flex items-center gap-1 text-xs font-semibold text-buddy-green hover:underline"
          >
            <Plus size={13} /> Add
          </button>
        </div>
        <p className="text-[11px] text-buddy-text-secondary mb-2">
          Optional — add your own timed lines (start/end in seconds). Leave empty to rely on auto-captions.
        </p>

        {segments.length === 0 ? (
          <div className="rounded-xl border border-dashed border-buddy-surface-raised py-6 text-center text-xs text-buddy-text-secondary">
            No manual segments yet.
          </div>
        ) : (
          <div className="space-y-2">
            {segments.map((seg) => (
              <div key={seg.id} className="rounded-xl bg-buddy-surface-raised p-2.5 space-y-2">
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    min={0}
                    step={0.1}
                    value={seg.start_ms ? seg.start_ms / 1000 : ''}
                    onChange={(e) => update(seg.id, { start_ms: Math.round(Number(e.target.value) * 1000) })}
                    placeholder="Start"
                    className="w-20 bg-buddy-surface rounded-lg px-2 py-1.5 text-xs font-mono outline-none focus:ring-1 focus:ring-buddy-green/40"
                    aria-label="Segment start (seconds)"
                  />
                  <span className="text-buddy-text-secondary text-xs">→</span>
                  <input
                    type="number"
                    min={0}
                    step={0.1}
                    value={seg.end_ms ? seg.end_ms / 1000 : ''}
                    onChange={(e) => update(seg.id, { end_ms: Math.round(Number(e.target.value) * 1000) })}
                    placeholder="End"
                    className="w-20 bg-buddy-surface rounded-lg px-2 py-1.5 text-xs font-mono outline-none focus:ring-1 focus:ring-buddy-green/40"
                    aria-label="Segment end (seconds)"
                  />
                  <span className="text-[10px] text-buddy-text-secondary flex-1 truncate">
                    {seg.end_ms > seg.start_ms ? formatMs(seg.end_ms - seg.start_ms) : ''}
                  </span>
                  <button
                    onClick={() => remove(seg.id)}
                    className="p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-red"
                    aria-label="Remove segment"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
                <textarea
                  value={seg.text}
                  onChange={(e) => update(seg.id, { text: e.target.value })}
                  rows={2}
                  placeholder="Caption text…"
                  className="w-full bg-buddy-surface rounded-lg px-2.5 py-1.5 text-sm outline-none resize-none focus:ring-1 focus:ring-buddy-green/40"
                  aria-label="Segment text"
                />
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
