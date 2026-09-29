import { useEffect, useMemo, useRef, useState } from 'react';
import { Pause, Play } from 'lucide-react';
import { formatDuration } from '@/components/analytics/format';

interface ReplayPoint { lat: number; lng: number; t: number; }

const SPEEDS = [0.5, 1, 2, 4] as const;

/** Animated route replay: play/pause, scrub, and speed control over a
 * recorded [lat, lng, ts] track. Routes without usable timestamps fall back
 * to even spacing across the activity duration. */
export function RouteReplayMap({ route, durationSeconds, height = 220 }: {
  route: number[][];
  durationSeconds: number;
  height?: number;
}) {
  const [progress, setProgress] = useState(0); // 0..1
  const [playing, setPlaying] = useState(false);
  const [speed, setSpeed] = useState<number>(1);
  const rafRef = useRef(0);
  const lastTsRef = useRef(0);
  // Full activity length in ms (timestamps if sane, else wall duration).
  const totalMs = Math.max(durationSeconds * 1000, 1000);

  const points = useMemo<ReplayPoint[]>(() => {
    const pts = (route || [])
      .filter((p) => Array.isArray(p) && typeof p[0] === 'number' && typeof p[1] === 'number')
      .map((p) => ({ lat: p[0], lng: p[1], t: typeof p[2] === 'number' ? p[2] : NaN }));
    if (pts.length === 0) return [];
    const times = pts.map((p) => p.t).filter((t) => Number.isFinite(t));
    const span = times.length >= 2 ? Math.max(...times) - Math.min(...times) : 0;
    if (span > 1000) {
      const base = Math.min(...times);
      return pts.map((p, i) => ({ ...p, t: Number.isFinite(p.t) ? p.t - base : (span * i) / Math.max(pts.length - 1, 1) }));
    }
    // No usable timestamps: spread evenly across the activity duration.
    return pts.map((p, i) => ({ ...p, t: (totalMs * i) / Math.max(pts.length - 1, 1) }));
  }, [route, totalMs]);

  const span = points.length > 0 ? Math.max(points[points.length - 1].t, 1) : 1;

  // Projection (mirrors SvgRouteMap so replay matches the static map).
  const { toX, toY, pathAll } = useMemo(() => {
    const lats = points.map((p) => p.lat);
    const lngs = points.map((p) => p.lng);
    const minLat = Math.min(...lats);
    const maxLat = Math.max(...lats);
    const minLng = Math.min(...lngs);
    const maxLng = Math.max(...lngs);
    const pad = 16;
    const x = (lng: number) => pad + ((lng - minLng) / (maxLng - minLng || 1)) * (640 - pad * 2);
    const y = (lat: number) => pad + ((maxLat - lat) / (maxLat - minLat || 1)) * (height - pad * 2);
    return {
      toX: x, toY: y,
      pathAll: points.map((p, i) => `${i === 0 ? 'M' : 'L'} ${x(p.lng).toFixed(1)} ${y(p.lat).toFixed(1)}`).join(' '),
    };
  }, [points, height]);

  const atTime = (ms: number): ReplayPoint => {
    if (points.length === 0) return { lat: 0, lng: 0, t: 0 };
    if (ms <= 0) return points[0];
    if (ms >= span) return points[points.length - 1];
    let i = 0;
    while (i < points.length - 2 && points[i + 1].t < ms) i++;
    const a = points[i];
    const b = points[i + 1];
    const f = (ms - a.t) / Math.max(b.t - a.t, 1e-6);
    return { lat: a.lat + (b.lat - a.lat) * f, lng: a.lng + (b.lng - a.lng) * f, t: ms };
  };

  // Playback clock: simulated ms advance in real time (scaled).
  useEffect(() => {
    if (!playing) return;
    lastTsRef.current = performance.now();
    const tick = (now: number) => {
      const dt = now - lastTsRef.current;
      lastTsRef.current = now;
      setProgress((prev) => {
        const next = prev + (dt * speed) / span;
        if (next >= 1) {
          setPlaying(false);
          return 1;
        }
        return next;
      });
      rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafRef.current);
  }, [playing, speed, span]);

  useEffect(() => () => cancelAnimationFrame(rafRef.current), []);
  useEffect(() => { setProgress(0); setPlaying(false); }, [route]);

  if (points.length < 2) return null;
  const marker = atTime(progress * span);
  const donePath = points.length > 1
    ? points
      .filter((p) => p.t <= progress * span)
      .concat([marker])
      .map((p, i) => `${i === 0 ? 'M' : 'L'} ${toX(p.lng).toFixed(1)} ${toY(p.lat).toFixed(1)}`)
      .join(' ')
    : '';
  const elapsedMs = progress * span;
  // Map track-time back onto wall duration for the readout.
  const wallSecs = Math.round((elapsedMs / span) * (durationSeconds || 0));

  return (
    <div className="rounded-xl overflow-hidden border border-buddy-surface-raised bg-[#101418]">
      <svg viewBox={`0 0 640 ${height}`} preserveAspectRatio="xMidYMid meet" className="w-full h-full" style={{ height: height - 64 }}>
        <defs>
          <pattern id="replay-grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1E242B" strokeWidth="1" />
          </pattern>
        </defs>
        <rect width="640" height={height - 64} fill="#101418" />
        <rect width="640" height={height - 64} fill="url(#replay-grid)" />
        <path d={pathAll} fill="none" stroke="#2A3340" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round" />
        {donePath && (
          <path d={donePath} fill="none" stroke="#00C896" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round" />
        )}
        <circle cx={toX(points[0].lng)} cy={toY(points[0].lat)} r="6" fill="#00C896" stroke="#0A0A0A" strokeWidth="2" />
        <circle cx={toX(marker.lng)} cy={toY(marker.lat)} r="9" fill="#00C896" stroke="#0A0A0A" strokeWidth="3" />
      </svg>
      <div className="px-3 py-2 bg-buddy-surface/95 border-t border-buddy-surface-raised">
        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              if (progress >= 1) setProgress(0);
              setPlaying((v) => !v);
            }}
            aria-label={playing ? 'Pause replay' : 'Play replay'}
            className="w-9 h-9 rounded-full bg-buddy-green text-buddy-black flex items-center justify-center flex-shrink-0 hover:brightness-110 transition-all"
          >
            {playing ? <Pause size={16} /> : <Play size={16} className="ml-0.5" />}
          </button>
          <input
            type="range"
            min={0}
            max={1000}
            value={Math.round(progress * 1000)}
            onChange={(e) => {
              setProgress(Number(e.target.value) / 1000);
              setPlaying(false);
            }}
            aria-label="Replay position"
            className="flex-1 accent-[#00C896]"
          />
          <span className="text-xs font-mono text-buddy-text-secondary whitespace-nowrap">
            {formatDuration(wallSecs)}
          </span>
          <div className="flex gap-1">
            {SPEEDS.map((s) => (
              <button
                key={s}
                onClick={() => setSpeed(s)}
                className={`text-[11px] px-1.5 py-0.5 rounded-md transition-colors ${speed === s ? 'bg-buddy-green/15 text-buddy-green font-semibold' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
              >
                {s}×
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
