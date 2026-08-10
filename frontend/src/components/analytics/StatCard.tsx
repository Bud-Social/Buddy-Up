import { Card } from '@/components/ui/Card';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface StatCardProps {
  label: string;
  value: string | number;
  sub?: string;
  icon?: React.ReactNode;
  trend?: number | null;
}

export function StatCard({ label, value, sub, icon, trend }: StatCardProps) {
  const TrendIcon = trend && trend > 0 ? TrendingUp : trend && trend < 0 ? TrendingDown : Minus;
  return (
    <Card className="p-4">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">{label}</p>
          <p className="mt-1 text-2xl font-bold font-display text-buddy-text-primary">{value}</p>
          {sub && <p className="mt-1 text-xs text-buddy-text-secondary">{sub}</p>}
        </div>
        {icon && <div className="text-buddy-green">{icon}</div>}
      </div>
      {trend !== undefined && trend !== null && (
        <div className={`mt-2 flex items-center gap-1 text-xs ${trend >= 0 ? 'text-buddy-green' : 'text-buddy-red'}`}>
          <TrendIcon size={14} />
          <span>{Math.abs(trend)}% vs previous</span>
        </div>
      )}
    </Card>
  );
}
