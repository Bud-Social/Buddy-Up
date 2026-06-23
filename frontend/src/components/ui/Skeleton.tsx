interface SkeletonProps { className?: string; variant?: 'text' | 'circular' | 'rectangular'; width?: string | number; height?: string | number; }
const vc: Record<string, string> = { text: 'rounded h-4', circular: 'rounded-full', rectangular: 'rounded-xl' };
export function Skeleton({ className, variant = 'rectangular', width, height }: SkeletonProps) {
  return <div className={`animate-pulse bg-buddy-surface-raised ${vc[variant]} ${className || ''}`} style={{ width, height }} role="status" aria-label="Loading" />;
}
