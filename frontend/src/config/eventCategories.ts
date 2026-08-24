export interface EventCategoryConfig {
  key: string;
  label: string;
  section: string;
  icon: string;
  color: string;
}

export const EVENT_CATEGORIES: EventCategoryConfig[] = [
  // Fitness & Gym
  { key: 'fitness', label: 'Fitness', section: 'Fitness & Gym', icon: '🏋️', color: '#00C896' },
  { key: 'weightlifting', label: 'Weightlifting', section: 'Fitness & Gym', icon: '💪', color: '#00C896' },
  { key: 'hiit', label: 'HIIT', section: 'Fitness & Gym', icon: '⚡', color: '#FF6B35' },
  { key: 'crossfit', label: 'CrossFit', section: 'Fitness & Gym', icon: '🤸', color: '#FFD700' },
  { key: 'calisthenics', label: 'Calisthenics', section: 'Fitness & Gym', icon: '🧗', color: '#7B61FF' },
  { key: 'bodybuilding', label: 'Bodybuilding', section: 'Fitness & Gym', icon: '🏆', color: '#FFD700' },

  // Outdoor & Cardio
  { key: 'running', label: 'Running', section: 'Outdoor & Cardio', icon: '🏃', color: '#00C896' },
  { key: 'cycling', label: 'Cycling', section: 'Outdoor & Cardio', icon: '🚴', color: '#7B61FF' },
  { key: 'hiking', label: 'Hiking', section: 'Outdoor & Cardio', icon: '🥾', color: '#FFD700' },
  { key: 'climbing', label: 'Climbing', section: 'Outdoor & Cardio', icon: '🧗', color: '#FF6B35' },
  { key: 'water_sports', label: 'Water Sports', section: 'Outdoor & Cardio', icon: '🏄', color: '#00C896' },
  { key: 'swimming', label: 'Swimming', section: 'Outdoor & Cardio', icon: '🏊', color: '#009E78' },
  { key: 'outdoor', label: 'Outdoor Adventure', section: 'Outdoor & Cardio', icon: '🏕️', color: '#4ADE80' },

  // Mind & Body
  { key: 'yoga', label: 'Yoga', section: 'Mind & Body', icon: '🧘', color: '#7B61FF' },
  { key: 'pilates', label: 'Pilates', section: 'Mind & Body', icon: '✨', color: '#FF6B35' },
  { key: 'meditation', label: 'Meditation', section: 'Mind & Body', icon: '🕯️', color: '#7B61FF' },
  { key: 'wellness', label: 'Wellness & Recovery', section: 'Mind & Body', icon: '🌿', color: '#00C896' },
  { key: 'mental_health', label: 'Mental Health', section: 'Mind & Body', icon: '🧠', color: '#FFD700' },

  // Competitions & Sports
  { key: 'competition', label: 'Competition', section: 'Sports & Competition', icon: '🥇', color: '#FFD700' },
  { key: 'tournament', label: 'Tournament', section: 'Sports & Competition', icon: '🎖️', color: '#FF4757' },
  { key: 'race', label: 'Race & Marathon', section: 'Sports & Competition', icon: '🏁', color: '#00C896' },
  { key: 'boxing', label: 'Boxing & MMA', section: 'Sports & Competition', icon: '🥊', color: '#FF4757' },
  { key: 'football', label: 'Football / Soccer', section: 'Sports & Competition', icon: '⚽', color: '#00C896' },
  { key: 'basketball', label: 'Basketball', section: 'Sports & Competition', icon: '🏀', color: '#FF6B35' },

  // Social & Learning
  { key: 'social', label: 'Social Meetup', section: 'Social & Workshops', icon: '🎉', color: '#FFD700' },
  { key: 'networking', label: 'Networking', section: 'Social & Workshops', icon: '🤝', color: '#7B61FF' },
  { key: 'nutrition', label: 'Nutrition & Cooking', section: 'Social & Workshops', icon: '🥗', color: '#00C896' },
  { key: 'workshop', label: 'Workshop & Clinic', section: 'Social & Workshops', icon: '🎓', color: '#7B61FF' },
  { key: 'seminar', label: 'Seminar', section: 'Social & Workshops', icon: '🎤', color: '#FF6B35' },
  { key: 'party', label: 'Fitness Party / Rave', section: 'Social & Workshops', icon: '🪩', color: '#FF4757' },
  { key: 'other', label: 'Other', section: 'Other', icon: '📌', color: '#A0A0A0' },
];

export const CATEGORY_SECTIONS = [
  'All',
  'Fitness & Gym',
  'Outdoor & Cardio',
  'Mind & Body',
  'Sports & Competition',
  'Social & Workshops',
];
