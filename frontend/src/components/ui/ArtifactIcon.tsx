interface ArtifactIconProps { artifact: string; size?: number; quantity?: number; className?: string; }
const icons: Record<string, string> = { dumbbell: '🏋️', barbell: '🏆', burpee: '🔥', squat: '🦵', sprint: '🏃', pr: '💎', champion: '🌟' };
const labels: Record<string, string> = { dumbbell: 'Dumbbell token', barbell: 'Barbell token', burpee: 'Burpee token', squat: 'Squat token', sprint: 'Sprint token', pr: 'PR token', champion: 'Champion token' };
export function ArtifactIcon({ artifact, size = 24, quantity, className }: ArtifactIconProps) {
  return <span className={`inline-flex items-center gap-1 ${className || ''}`} role="img" aria-label={labels[artifact] || artifact}><span style={{ fontSize: size }}>{icons[artifact] || '💰'}</span>{quantity !== undefined && <span className="font-coin font-bold text-sm text-buddy-text-primary">{quantity}</span>}</span>;
}
