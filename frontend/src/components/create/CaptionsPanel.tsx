/**
 * CaptionsPanel — per-clip timed captions for the Bud Press studio.
 *
 * Review & style step: captions are added to the active clip BEFORE posting
 * (transcribe the trimmed snippet, review each line, fix timing, pick a
 * style) — never "generated after publish". The parent owns the per-clip
 * lists; this panel edits exactly one clip's list at a time.
 */
import { Captions, Loader2, Plus, RotateCcw, Trash2, X } from 'lucide-react';
import {
  CAPTION_PRESETS,
  CAPTION_PLACEMENTS,
  formatMs,
  type CaptionsStyle,
  type CaptionPlacement,
} from '@/lib/createStudio';

export interface CaptionSegment {
  id: string;
  start_ms: number;
  end_ms: number;
  text: string;
}

export type AutoCaptionStatus = 'idle' | 'working' | 'error' | 'done';

export interface AutoCaptionJob {
  status: AutoCaptionStatus;
  error?: string | null;
}

interface CaptionsPanelProps {
  hasVideo: boolean;
  autoCaptions: boolean;
  onToggleAuto: (on: boolean) => void;
  segments: CaptionSegment[];
  onChangeSegments: (segments: CaptionSegment[]) => void;
  style?: CaptionsStyle | null;
  onStyleChange?: (style: CaptionsStyle) => void;
  /** Human label for the active clip ("Clip 2 of 3"). */
  clipLabel?: string;
  /** Auto-caption run state for the active clip (button states). */
  autoJob?: AutoCaptionJob | null;
  /** Start (or retry) transcription for the active clip. */
  onGenerateAuto?: () => void;
  /** Cancel a running transcription for the active clip. */
  onCancelAuto?: () => void;
}

export function CaptionsPanel({
  hasVideo, autoCaptions, onToggleAuto, segments, onChangeSegments, style, onStyleChange,
  clipLabel, autoJob, onGenerateAuto, onCancelAuto,
}: CaptionsPanelProps) {
  const update = (id: string, patch: Partial<CaptionSegment>) =>
    onChangeSegments(segments.map((s) => (s.id === id ? { ...s, ...patch } : s)));

  const remove = (id: string) => onChangeSegments(segments.filter((s) => s.id !== id));

  const add = () =>
    onChangeSegments([
      ...segments,
      { id: crypto.randomUUID(), start_ms: 0, end_ms: 0, text: '' },
    ]);

  const autoStatus: AutoCaptionStatus = autoJob?.status ?? 'idle';
  const currentStyle: CaptionsStyle = style ?? { preset: 'classic' };
  const patchStyle = (patch: Partial<CaptionsStyle>) =>
    onStyleChange?.({ ...currentStyle, ...patch });

  return (
    <div className="space-y-4">
      <div>
        <p className="text-sm font-semibold text-buddy-text-primary">
          Review &amp; style{clipLabel ? ` — ${clipLabel}` : ''}
        </p>
        <p className="text-[11px] text-buddy-text-secondary mt-0.5">
          Captions ship with this clip — review each line, fix the timing, then pick a style below.
        </p>
      </div>

      {hasVideo && onGenerateAuto && (
        <div className="rounded-2xl bg-buddy-surface-raised p-3 space-y-2">
          {autoStatus === 'working' ? (
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-sm">
                <Loader2 size={15} className="animate-spin text-buddy-green shrink-0" />
                <span className="font-semibold text-buddy-text-primary flex-1">
                  Transcribing{clipLabel ? ` ${clipLabel}` : ''}…
                </span>
                {onCancelAuto && (
                  <button
                    onClick={onCancelAuto}
                    className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg bg-buddy-surface text-xs font-semibold text-buddy-text-secondary hover:text-buddy-red"
                  >
                    <X size={13} /> Cancel
                  </button>
                )}
              </div>
              <p className="text-[11px] text-buddy-text-secondary">
                Listening to the trimmed snippet — lines appear here for review as soon as it finishes.
              </p>
            </div>
          ) : (
            <button
              onClick={onGenerateAuto}
              className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green text-buddy-black text-sm font-bold hover:bg-buddy-green/90 transition-colors"
            >
              {autoStatus === 'error' ? <RotateCcw size={15} /> : <Captions size={15} />}
              {autoStatus === 'error'
                ? 'Retry auto-captions'
                : segments.length > 0
                  ? 'Regenerate auto-captions'
                  : `Auto-captions${clipLabel ? ` for ${clipLabel}` : ''}`}
            </button>
          )}
          {autoStatus === 'error' && autoJob?.error && (
            <p className="text-[11px] text-buddy-red" role="alert">{autoJob.error}</p>
          )}
          {autoStatus === 'done' && (
            <p className="text-[11px] text-buddy-green">
              Done — review the lines below and fix anything the mic misheard.
            </p>
          )}
          {autoStatus === 'idle' && (
            <p className="text-[11px] text-buddy-text-secondary">
              Listens to the trimmed snippet and drafts timed lines you can edit.
            </p>
          )}
        </div>
      )}

      {hasVideo && (
        <button
          onClick={() => onToggleAuto(!autoCaptions)}
          className="w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl bg-buddy-surface-raised text-left"
          aria-pressed={autoCaptions}
        >
          <div className="flex-1">
            <p className="text-sm font-semibold text-buddy-text-primary">Backfill empty clips</p>
            <p className="text-[11px] text-buddy-text-secondary mt-0.5">
              Automatically add captions to clips left without any.
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
            Caption style
          </p>
        </div>
        <div className="flex gap-1.5 flex-wrap">
          {CAPTION_PRESETS.map((preset) => (
            <button
              key={preset.id}
              onClick={() => patchStyle({
                preset: preset.id,
                ...(preset.font ? { font: preset.font } : {}),
                color: preset.color,
                bg: preset.bg,
              })}
              className={`px-3 py-1.5 rounded-full text-[11px] font-medium transition-colors ${
                (currentStyle.preset ?? 'classic') === preset.id
                  ? 'bg-buddy-green text-buddy-black font-semibold'
                  : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {preset.label}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-3 mt-2.5">
          <span className="text-[11px] text-buddy-text-secondary w-12 shrink-0">Size</span>
          <input
            type="range"
            min={0.8}
            max={1.6}
            step={0.1}
            value={currentStyle.size ?? 1}
            onChange={(e) => patchStyle({ size: Number(e.target.value) })}
            className="flex-1 accent-buddy-green"
            aria-label="Caption size"
          />
          <span className="text-[11px] font-mono text-buddy-text-secondary w-8 text-right">
            {Math.round((currentStyle.size ?? 1) * 100)}%
          </span>
        </div>
        <div className="flex items-center gap-1.5 mt-2">
          <span className="text-[11px] text-buddy-text-secondary w-12 shrink-0">Place</span>
          {CAPTION_PLACEMENTS.map((p: { id: CaptionPlacement; label: string }) => (
            <button
              key={p.id}
              onClick={() => patchStyle({ placement: p.id === 'bottom' ? undefined : p.id })}
              className={`px-3 py-1 rounded-full text-[11px] font-medium transition-colors ${
                (currentStyle.placement ?? 'bottom') === p.id
                  ? 'bg-buddy-green text-buddy-black font-semibold'
                  : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      <div>
        <div className="flex items-center justify-between mb-2">
          <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide">
            Caption lines{segments.length > 0 ? ` (${segments.length})` : ''}
          </p>
          <button
            onClick={add}
            className="flex items-center gap-1 text-xs font-semibold text-buddy-green hover:underline"
          >
            <Plus size={13} /> Add
          </button>
        </div>
        <p className="text-[11px] text-buddy-text-secondary mb-2">
          Timed lines for this clip (start/end in seconds). Edit text inline — changes preview live in the editor.
        </p>

        {segments.length === 0 ? (
          <div className="rounded-xl border border-dashed border-buddy-surface-raised py-6 text-center text-xs text-buddy-text-secondary">
            No lines yet — run auto-captions or add one manually.
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
