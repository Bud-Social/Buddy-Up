import type { ArtifactBalance } from '@/types';

const VALUES: Record<keyof ArtifactBalance, number> = { dumbbell: 0.10, barbell: 0.50, burpee: 1.00, squat: 2.50, sprint: 5.00, pr: 10.00, champion: 25.00 };
const ICONS: Record<string, string> = { dumbbell: '🏋️', barbell: '🏆', burpee: '🔥', squat: '🦵', sprint: '🏃', pr: '💎', champion: '🌟' };
const LABELS: Record<string, string> = { dumbbell: 'Dumbbell', barbell: 'Barbell', burpee: 'Burpee', squat: 'Squat', sprint: 'Sprint', pr: 'PR', champion: 'Champion' };

export function totalFiatValue(balance: ArtifactBalance, rate = 1): number {
  return Object.entries(balance).reduce((t, [k, q]) => t + (VALUES[k as keyof ArtifactBalance] || 0) * q, 0) * rate;
}
export function artifactValue(a: keyof ArtifactBalance) { return VALUES[a] || 0; }
export function artifactIcon(a: string) { return ICONS[a] || '💰'; }
export function artifactLabel(a: string) { return LABELS[a] || a; }
export const ARTIFACT_TYPES = ['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'] as const;
