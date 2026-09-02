import { MapPin, Sparkles } from 'lucide-react';
import type { Profile } from '@/types';

const GOAL_LABELS: Record<string, string> = {
  weight_loss: 'Weight Loss', muscle_gain: 'Muscle Gain', endurance: 'Endurance',
  flexibility: 'Flexibility', general_wellness: 'General Wellness', nutrition: 'Nutrition',
  sports_performance: 'Sports Performance', rehabilitation: 'Rehabilitation', mental_health: 'Mental Health',
};

const WORKOUT_LABELS: Record<string, string> = {
  weights: 'Weights', cardio: 'Cardio', hiit: 'HIIT', yoga: 'Yoga', pilates: 'Pilates',
  crossfit: 'CrossFit', martial_arts: 'Martial Arts', swimming: 'Swimming', running: 'Running',
  cycling: 'Cycling', other: 'Other',
};

const DIET_LABELS: Record<string, string> = {
  none: '', vegan: 'Vegan', vegetarian: 'Vegetarian', keto: 'Keto', paleo: 'Paleo',
  halal: 'Halal', kosher: 'Kosher', gluten_free: 'Gluten-Free', other: 'Special Diet',
};

const LEVEL_LABELS: Record<string, string> = {
  sedentary: 'Getting Started', lightly_active: 'Lightly Active', moderately_active: 'Moderately Active',
  very_active: 'Very Active', athlete: 'Athlete',
};

const TIME_LABELS: Record<string, string> = {
  early_morning: 'Early Bird', morning: 'Mornings', afternoon: 'Afternoons',
  evening: 'Evenings', night: 'Night Owl', flexible: 'Flexible',
};

const titleize = (s: string) => s.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

/**
 * Interest chips from a member's onboarding preferences. Powers buddy
 * matching surfaces: profile pages, discover cards, onboarding preview.
 */
export function InterestChips({ preferences, showLocation, city }: {
  preferences?: Profile['preferences'];
  showLocation?: boolean;
  city?: string;
}) {
  if (!preferences) return null;
  const goals = (preferences.primary_goal || []).map((g) => GOAL_LABELS[g] || titleize(g));
  const workouts = (preferences.preferred_workouts || []).map((w) => WORKOUT_LABELS[w] || titleize(w));
  const diet = DIET_LABELS[preferences.dietary_preference || ''] || '';
  const level = LEVEL_LABELS[preferences.activity_level || ''] || '';
  const time = TIME_LABELS[preferences.preferred_time || ''] || '';
  const custom = (preferences.custom_interests || '').split(',').map((s) => s.trim()).filter(Boolean);

  const chips: { label: string; tone: 'green' | 'blue' | 'orange' | 'gray' }[] = [
    ...goals.map((label) => ({ label, tone: 'green' as const })),
    ...workouts.map((label) => ({ label, tone: 'blue' as const })),
    ...custom.map((label) => ({ label, tone: 'orange' as const })),
    ...(level ? [{ label: level, tone: 'gray' as const }] : []),
    ...(diet ? [{ label: diet, tone: 'gray' as const }] : []),
    ...(time ? [{ label: time, tone: 'gray' as const }] : []),
  ];

  if (!chips.length && !(showLocation && city)) return null;

  return (
    <div className="flex flex-wrap gap-1.5 items-center">
      {showLocation && city && (
        <span className="inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-full bg-buddy-surface text-buddy-text-secondary">
          <MapPin size={10} /> {city}
        </span>
      )}
      {chips.map((c, i) => (
        <span key={`${c.label}-${i}`} className={`text-[11px] px-2 py-0.5 rounded-full ${
          c.tone === 'green' ? 'bg-buddy-green/10 text-buddy-green'
            : c.tone === 'blue' ? 'bg-buddy-electric/10 text-buddy-electric'
              : c.tone === 'orange' ? 'bg-buddy-orange/10 text-buddy-orange'
                : 'bg-buddy-surface text-buddy-text-secondary'
        }`}>
          {c.label}
        </span>
      ))}
    </div>
  );
}

export function InterestHint() {
  return (
    <p className="inline-flex items-center gap-1 text-[10px] text-buddy-text-secondary/70">
      <Sparkles size={9} /> Shared interests make great buddies
    </p>
  );
}
