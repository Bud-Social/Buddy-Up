type BadgeVariant = 'blue' | 'silver' | 'green' | 'gold' | 'orange' | 'red' | 'electric';
interface BadgeProps { variant: BadgeVariant; label: string; icon?: string; size?: 'sm' | 'md'; className?: string; }
const vs: Record<BadgeVariant, string> = {
  blue: 'bg-blue-500/20 text-blue-400 border-blue-500/30', silver: 'bg-slate-400/20 text-slate-300 border-slate-400/30',
  green: 'bg-buddy-green/20 text-buddy-green border-buddy-green/30', gold: 'bg-buddy-gold/20 text-buddy-gold border-buddy-gold/30',
  orange: 'bg-buddy-orange/20 text-buddy-orange border-buddy-orange/30', red: 'bg-buddy-red/20 text-buddy-red border-buddy-red/30',
  electric: 'bg-buddy-electric/20 text-buddy-electric border-buddy-electric/30',
};
export function Badge({ variant, label, icon, size = 'sm', className }: BadgeProps) {
  return <span className={`inline-flex items-center gap-1 font-medium border rounded-full ${size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-3 py-1 text-sm'} ${vs[variant]} ${className || ''}`}>{icon && <span aria-hidden="true">{icon}</span>}{label}</span>;
}
