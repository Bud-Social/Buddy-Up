/**
 * CoverPicker — scrub a video to choose a custom cover frame. The chosen
 * offset is stored and converted to a Cloudinary `?so_<seconds>` poster
 * override at publish time.
 */
import { useEffect, useRef, useState } from 'react';
import { Image as ImageIcon } from 'lucide-react';
import { formatMs } from '@/lib/createStudio';

interface CoverPickerProps {
  videoUrl: string;
  durationMs?: number | null;
  /** Currently stored cover offset in seconds (null = auto cover). */
  offsetSec: number | null;
  onChange: (offsetSec: number | null) => void;
}

export function CoverPicker({ videoUrl, durationMs, offsetSec, onChange }: CoverPickerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [probed, setProbed] = useState<number | null>(null);
  const [scrub, setScrub] = useState(offsetSec ?? 0);

  const duration = durationMs ?? probed ?? 0;
  const durationSec = duration / 1000;

  useEffect(() => {
    setScrub(offsetSec ?? 0);
  }, [offsetSec]);

  const applyScrub = (sec: number) => {
    setScrub(sec);
    const el = videoRef.current;
    if (el) el.currentTime = sec;
  };

  return (
    <div className="space-y-3">
      <div className="relative rounded-2xl overflow-hidden bg-black aspect-[9/16] max-h-[46vh] mx-auto w-auto">
        <video
          ref={videoRef}
          src={videoUrl}
          muted
          playsInline
          preload="auto"
          onLoadedMetadata={(e) => {
            const d = e.currentTarget.duration;
            if (Number.isFinite(d) && d > 0) {
              setProbed(Math.round(d * 1000));
              if (offsetSec != null) e.currentTarget.currentTime = offsetSec;
            }
          }}
          className="absolute inset-0 w-full h-full object-contain"
        />
        <div className="absolute top-2 left-2 flex items-center gap-1 px-2 py-1 rounded-full bg-black/50 text-white text-[11px] font-medium">
          <ImageIcon size={11} />
          {offsetSec == null ? 'Auto cover' : `Cover at ${formatMs(scrub * 1000)}`}
        </div>
      </div>

      <input
        type="range"
        min={0}
        max={Math.max(durationSec, 0.1)}
        step={0.1}
        value={Math.min(scrub, durationSec || 0.1)}
        onChange={(e) => applyScrub(Number(e.target.value))}
        onMouseUp={() => onChange(scrub)}
        onTouchEnd={() => onChange(scrub)}
        onKeyUp={() => onChange(scrub)}
        className="w-full accent-buddy-green"
        aria-label="Cover frame position"
        disabled={duration <= 0}
      />

      <div className="flex items-center justify-between text-[11px] font-mono text-buddy-text-secondary">
        <span>0:00.0</span>
        <span className="text-buddy-text-primary font-semibold">{formatMs(scrub * 1000)}</span>
        <span>{formatMs(duration)}</span>
      </div>

      <div className="flex gap-2">
        <button
          onClick={() => { onChange(scrub); }}
          className="flex-1 py-2.5 rounded-xl bg-buddy-green text-buddy-black text-sm font-bold hover:bg-buddy-green/90 transition-colors"
        >
          Use this frame
        </button>
        <button
          onClick={() => { onChange(null); setScrub(0); if (videoRef.current) videoRef.current.currentTime = 0; }}
          className={`flex-1 py-2.5 rounded-xl text-sm font-semibold transition-colors ${
            offsetSec == null ? 'bg-buddy-green/15 text-buddy-green' : 'bg-buddy-surface-raised text-buddy-text-primary hover:bg-buddy-surface'
          }`}
        >
          Auto cover
        </button>
      </div>
    </div>
  );
}
