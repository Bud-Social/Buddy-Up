import type { LucideIcon } from 'lucide-react';
import {
  Dumbbell, Zap, Boxes, Trophy, Footprints, Bike, Mountain,
  Sailboat, MountainSnow, Tent, Flower2, Sparkles, Flame, Brain,
  Medal, Swords, Flag, HandMetal, CircleDot, PartyPopper, Handshake,
  Salad, GraduationCap, Mic2, Disc3, Pin,
} from 'lucide-react';

export interface EventCategoryConfig {
  key: string;
  label: string;
  section: string;
  /** Legacy emoji (kept for callers that render text). */
  icon: string;
  /** Crisp vector alternative — preferred in UI. */
  Icon?: LucideIcon;
  color: string;
}

export const EVENT_CATEGORIES: EventCategoryConfig[] = [
  // Fitness & Gym
  { key: 'fitness', label: 'Fitness', section: 'Fitness & Gym', icon: '🏋️', Icon: Dumbbell, color: '#00C896' },
  { key: 'weightlifting', label: 'Weightlifting', section: 'Fitness & Gym', icon: '💪', Icon: Dumbbell, color: '#00C896' },
  { key: 'hiit', label: 'HIIT', section: 'Fitness & Gym', icon: '⚡', Icon: Zap, color: '#FF6B35' },
  { key: 'crossfit', label: 'CrossFit', section: 'Fitness & Gym', icon: '🤸', Icon: Boxes, color: '#FFD700' },
  { key: 'calisthenics', label: 'Calisthenics', section: 'Fitness & Gym', icon: '🧗', Icon: Boxes, color: '#7B61FF' },
  { key: 'bodybuilding', label: 'Bodybuilding', section: 'Fitness & Gym', icon: '🏆', Icon: Trophy, color: '#FFD700' },

  // Outdoor & Cardio
  { key: 'running', label: 'Running', section: 'Outdoor & Cardio', icon: '🏃', Icon: Footprints, color: '#00C896' },
  { key: 'cycling', label: 'Cycling', section: 'Outdoor & Cardio', icon: '🚴', Icon: Bike, color: '#7B61FF' },
  { key: 'hiking', label: 'Hiking', section: 'Outdoor & Cardio', icon: '🥾', Icon: Mountain, color: '#FFD700' },
  { key: 'climbing', label: 'Climbing', section: 'Outdoor & Cardio', icon: '🧗', Icon: MountainSnow, color: '#FF6B35' },
  { key: 'water_sports', label: 'Water Sports', section: 'Outdoor & Cardio', icon: '🏄', Icon: Sailboat, color: '#00C896' },
  { key: 'swimming', label: 'Swimming', section: 'Outdoor & Cardio', icon: '🏊', Icon: Sailboat, color: '#009E78' },
  { key: 'outdoor', label: 'Outdoor Adventure', section: 'Outdoor & Cardio', icon: '🏕️', Icon: Tent, color: '#4ADE80' },

  // Mind & Body
  { key: 'yoga', label: 'Yoga', section: 'Mind & Body', icon: '🧘', Icon: Flower2, color: '#7B61FF' },
  { key: 'pilates', label: 'Pilates', section: 'Mind & Body', icon: '✨', Icon: Sparkles, color: '#FF6B35' },
  { key: 'meditation', label: 'Meditation', section: 'Mind & Body', icon: '🕯️', Icon: Flame, color: '#7B61FF' },
  { key: 'wellness', label: 'Wellness & Recovery', section: 'Mind & Body', icon: '🌿', Icon: Flower2, color: '#00C896' },
  { key: 'mental_health', label: 'Mental Health', section: 'Mind & Body', icon: '🧠', Icon: Brain, color: '#FFD700' },

  // Competitions & Sports
  { key: 'competition', label: 'Competition', section: 'Sports & Competition', icon: '🥇', Icon: Medal, color: '#FFD700' },
  { key: 'tournament', label: 'Tournament', section: 'Sports & Competition', icon: '🎖️', Icon: Swords, color: '#FF4757' },
  { key: 'race', label: 'Race & Marathon', section: 'Sports & Competition', icon: '🏁', Icon: Flag, color: '#00C896' },
  { key: 'boxing', label: 'Boxing & MMA', section: 'Sports & Competition', icon: '🥊', Icon: HandMetal, color: '#FF4757' },
  { key: 'football', label: 'Football / Soccer', section: 'Sports & Competition', icon: '⚽', Icon: CircleDot, color: '#00C896' },
  { key: 'basketball', label: 'Basketball', section: 'Sports & Competition', icon: '🏀', Icon: CircleDot, color: '#FF6B35' },

  // Social & Learning
  { key: 'social', label: 'Social Meetup', section: 'Social & Workshops', icon: '🎉', Icon: PartyPopper, color: '#FFD700' },
  { key: 'networking', label: 'Networking', section: 'Social & Workshops', icon: '🤝', Icon: Handshake, color: '#7B61FF' },
  { key: 'nutrition', label: 'Nutrition & Cooking', section: 'Social & Workshops', icon: '🥗', Icon: Salad, color: '#00C896' },
  { key: 'workshop', label: 'Workshop & Clinic', section: 'Social & Workshops', icon: '🎓', Icon: GraduationCap, color: '#7B61FF' },
  { key: 'seminar', label: 'Seminar', section: 'Social & Workshops', icon: '🎤', Icon: Mic2, color: '#FF6B35' },
  { key: 'party', label: 'Fitness Party / Rave', section: 'Social & Workshops', icon: '🪩', Icon: Disc3, color: '#FF4757' },
  { key: 'other', label: 'Other', section: 'Other', icon: '📌', Icon: Pin, color: '#A0A0A0' },
];

export const CATEGORY_SECTIONS = [
  'All',
  'Fitness & Gym',
  'Outdoor & Cardio',
  'Mind & Body',
  'Sports & Competition',
  'Social & Workshops',
];
