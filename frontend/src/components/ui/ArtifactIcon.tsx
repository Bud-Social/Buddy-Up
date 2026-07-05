import { Dumbbell, Trophy, Flame, PersonStanding, Footprints, Gem, Star } from 'lucide-react';

interface ArtifactIconProps { artifact: string; size?: number; quantity?: number; className?: string; }

const iconMap: Record<string, typeof Dumbbell> = {
  dumbbell: Dumbbell,
  barbell: Trophy,
  burpee: Flame,
  squat: PersonStanding,
  sprint: Footprints,
  pr: Gem,
  champion: Star,
};

const labels: Record<string, string> = {
  dumbbell: 'Dumbbell token', barbell: 'Barbell token', burpee: 'Burpee token',
  squat: 'Squat token', sprint: 'Sprint token', pr: 'PR token', champion: 'Champion token',
};

const colors: Record<string, string> = {
  dumbbell: '#22c55e', barbell: '#f59e0b', burpee: '#ef4444',
  squat: '#3b82f6', sprint: '#a855f7', pr: '#06b6d4', champion: '#facc15',
};

export function ArtifactIcon({ artifact, size = 24, quantity, className }: ArtifactIconProps) {
  const Icon = iconMap[artifact];
  const color = colors[artifact];
  return (
    <span className={`inline-flex items-center gap-1 ${className || ''}`} role="img" aria-label={labels[artifact] || artifact}>
      {Icon ? <Icon size={size} color={color} strokeWidth={1.8} /> : <span style={{ fontSize: size }}>💰</span>}
      {quantity !== undefined && <span className="font-coin font-bold text-sm text-buddy-text-primary">{quantity}</span>}
    </span>
  );
}
