/**
 * TrimEditor — TikTok-style dual-thumb trim over a video's duration with
 * a loop preview that only plays between the in/out points.
 */
import { useEffect, useRef, useState } from 'react';
import { Scissors } from 'lucide-react';
import { clampTrim, moveThumb, formatMs, MAX_TRIM_MS } from '@/lib/createStudio';

export interface TrimRangeValue {
  start_ms: number;
  end_ms: number;
}

interface TrimEditorProps {
  videoUrl: string;
  /** Known duration (ms). Probed from the preview element when absent. */
  durationMs?: number | null;
  trim: TrimRangeValue;
  onChange: (trim: TrimRangeValue, meta: { clamped: boolean }) => void;
  onDuration?: (durationMs: number) => void;
}

export function TrimEditor({ videoUrl, durationMs, trim, onChange, onDuration }: TrimEditorProps) {
  const trackRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const dragRef = useRef<'start' | 'end' | null>(null);
  const [probedDuration, setProbedDuration] = useState<number | null>(null);
  const [warn, setWarn] = useState(false);

  const duration = durationMs ?? probedDuration ?? 0;

  // Loop preview: only play between the in/out points.
  useEffect(() => {
    const el = videoRef.current;
    if (!el || duration <= 0) return;
    const onTime = () => {
      const t = el.currentTime * 1000;
      if (t >= trim.end_ms - 30 || t < trim.start_ms - 250) {
        el.currentTime = trim.start_ms / 1000;
      }
    };
    el.addEventListener('timeupdate', onTime);
    if (el.currentTime * 1000 < trim.start_ms - 250 || el.currentTime * 1000 > trim.end_ms) {
      el.currentTime = trim.start_ms / 1000;
    }
    el.play().catch(() => {});
    return () => el.removeEventListener('timeupdate', onTime);
  }, [trim.start_ms, trim.end_ms, duration]);

  const posToMs = (clientX: number): number => {
    const rect = trackRef.current?.getBoundingClientRect();
    if (!rect || rect.width === 0) return 0;
    const ratio = Math.min(1, Math.max(0, (clientX - rect.left) / rect.width));
    return ratio * duration;
  };

  const commit = (which: 'start' | 'end', posMs: number) => {
    if (duration <= 0) return;
    const next = moveThumb(which, posMs, trim, duration);
    setWarn(next.clamped);
    onChange({ start_ms: next.start_ms, end_ms: next.end_ms }, { clamped: next.clamped });
  };

  const startDrag = (which: 'start' | 'end') => (e: React.PointerEvent) => {
    e.preventDefault();
    e.stopPropagation();
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    dragRef.current = which;
  };

  const onMove = (e: React.PointerEvent) => {
    if (!dragRef.current) return;
    commit(dragRef.current, posToMs(e.clientX));
  };

  const endDrag = () => {
    dragRef.current = null;
  };

  const onTrackDown = (e: React.PointerEvent) => {
    const t = posToMs(e.clientX);
    const which: 'start' | 'end' =
      Math.abs(t - trim.start_ms) <= Math.abs(t - trim.end_ms) ? 'start' : 'end';
    dragRef.current = which;
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    commit(which, t);
  };

  const pct = (ms: number) => (duration > 0 ? `${(ms / duration) * 100}%` : '0%');
  const selectedMs = Math.max(0, trim.end_ms - trim.start_ms);
  const overCap = selectedMs > MAX_TRIM_MS;

  return (
    <div className="space-y-3">
      <div className="relative rounded-2xl overflow-hidden bg-black aspect-[9/16] max-h-[46vh] mx-auto w-auto">
        <video
          ref={videoRef}
          src={videoUrl}
          muted
          loop
          playsInline
          preload="auto"
          onLoadedMetadata={(e) => {
            const d = e.currentTarget.duration;
            if (Number.isFinite(d) && d > 0) {
              const ms = Math.round(d * 1000);
              setProbedDuration(ms);
              onDuration?.(ms);
              // First probe: initialise an out point if unset.
              if (trim.end_ms <= 0) {
                const init = clampTrim(trim.start_ms, ms, ms);
                onChange({ start_ms: init.start_ms, end_ms: init.end_ms }, { clamped: init.clamped });
              }
            }
          }}
          className="absolute inset-0 w-full h-full object-contain"
        />
        <div className="absolute top-2 left-2 flex items-center gap-1 px-2 py-1 rounded-full bg-black/50 text-white text-[11px] font-medium">
          <Scissors size={11} />
          {formatMs(selectedMs)} selected
        </div>
      </div>

      {/* Dual-thumb track */}
      <div
        ref={trackRef}
        onPointerDown={onTrackDown}
        onPointerMove={onMove}
        onPointerUp={endDrag}
        onPointerCancel={endDrag}
        className="relative h-10 select-none touch-none cursor-pointer"
        role="group"
        aria-label="Trim range"
      >
        <div className="absolute top-1/2 -translate-y-1/2 left-0 right-0 h-1.5 rounded-full bg-buddy-surface-raised" />
        <div
          className="absolute top-1/2 -translate-y-1/2 h-1.5 rounded-full bg-buddy-green"
          style={{ left: pct(trim.start_ms), width: pct(selectedMs) }}
        />
        {(['start', 'end'] as const).map((which) => (
          <div
            key={which}
            onPointerDown={startDrag(which)}
            onPointerMove={onMove}
            onPointerUp={endDrag}
            onPointerCancel={endDrag}
            className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 w-5 h-9 rounded-lg bg-buddy-green shadow-lg cursor-grab active:cursor-grabbing flex items-center justify-center touch-none"
            style={{ left: pct(which === 'start' ? trim.start_ms : trim.end_ms) }}
            role="slider"
            aria-label={which === 'start' ? 'Trim start' : 'Trim end'}
            aria-valuemin={0}
            aria-valuemax={Math.round(duration)}
            aria-valuenow={Math.round(which === 'start' ? trim.start_ms : trim.end_ms)}
            tabIndex={0}
          >
            <div className="w-0.5 h-4 bg-buddy-black/60 rounded-full" />
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between text-[11px] font-mono text-buddy-text-secondary">
        <span>IN {formatMs(trim.start_ms)}</span>
        <span className="text-buddy-text-primary font-semibold">
          {formatMs(selectedMs)} / {formatMs(duration)}
        </span>
        <span>OUT {formatMs(trim.end_ms)}</span>
      </div>

      {(overCap || warn) && (
        <p className="text-xs text-buddy-orange">
          Trims are capped at 3:00 — your selection was clamped to fit.
        </p>
      )}
    </div>
  );
}
