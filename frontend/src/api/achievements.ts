import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface AchievementItem {
  id: string;
  code: string;
  title: string;
  description: string;
  icon: string;
  tier: 'bronze' | 'silver' | 'gold' | 'platinum';
  category: string;
  metric: string;
  metric_label: string;
  threshold: number;
  sort_order: number;
  earned: boolean;
  earned_at: string | null;
  progress: number;
  progress_pct: number;
}

export interface AchievementsPayload {
  items: AchievementItem[];
  summary: { total: number; earned: number };
}

const TIER_STYLES: Record<AchievementItem['tier'], { ring: string; text: string; bg: string; label: string }> = {
  bronze: { ring: 'border-amber-700/50', text: 'text-amber-600', bg: 'bg-amber-700/10', label: 'Bronze' },
  silver: { ring: 'border-slate-400/50', text: 'text-slate-300', bg: 'bg-slate-400/10', label: 'Silver' },
  gold: { ring: 'border-buddy-gold/60', text: 'text-buddy-gold', bg: 'bg-buddy-gold/10', label: 'Gold' },
  platinum: { ring: 'border-cyan-300/60', text: 'text-cyan-200', bg: 'bg-cyan-300/10', label: 'Platinum' },
};

export const achievementTierStyle = (tier: AchievementItem['tier']) => TIER_STYLES[tier] ?? TIER_STYLES.bronze;

export const achievementsApi = {
  list: () =>
    apiClient.get<ApiResponse<AchievementsPayload>>('/achievements/').then((r) => r.data),
};
