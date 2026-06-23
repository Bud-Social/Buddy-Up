interface RepRingProps { progress: number; size?: number; strokeWidth?: number; className?: string; }
export function RepRing({ progress, size = 44, strokeWidth = 2.5, className }: RepRingProps) {
  const r = (size - strokeWidth) / 2; const c = 2 * Math.PI * r; const o = c - (Math.min(progress, 100) / 100) * c;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className={`-rotate-90 ${className || ''}`} aria-label={`Streak progress: ${progress}%`}>
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#1E1E1E" strokeWidth={strokeWidth} />
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#00C896" strokeWidth={strokeWidth} strokeLinecap="round" strokeDasharray={c} strokeDashoffset={o} className="transition-all duration-700 ease-out" />
    </svg>
  );
}
