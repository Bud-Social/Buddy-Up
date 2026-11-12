export type CountdownUnit = 'days' | 'hours';
export type CountdownType = 'manual' | 'automatic';

export interface CountdownTemplate {
  id: string;
  code: string;
  title: string;
  description: string;
  unit: CountdownUnit;
  default_target: number;
  icon: string;
  color: string;
  is_active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface UserCountdown {
  id: string;
  template: string | null;
  template_detail: CountdownTemplate | null;
  custom_reason: string;
  countdown_type: CountdownType;
  unit: CountdownUnit;
  current_count: number;
  target_count: number;
  start_date: string;
  last_checkin_at: string | null;
  last_auto_advance_at: string | null;
  auto_advance_signal: string | null;
  is_active: boolean;
  completed_at: string | null;
  days_since_start: number;
  display_reason: string;
  display_icon: string;
  created_at: string;
  updated_at: string;
  /** Whole units completed since the current streak began. */
  elapsed_units: number;
  /** When the current streak began. */
  run_started_at: string | null;
  /** How long the current streak has lasted, in seconds. */
  run_elapsed_seconds: number;
  /** When the next manual check-in unlocks (null when it is open). */
  next_checkin_at: string | null;
  /** When the countdown was last reset. */
  last_reset_at: string | null;
}

/** One entry in a countdown's stream. */
export interface CountdownEvent {
  id: string;
  countdown: string;
  event_type: 'create' | 'checkin' | 'reset' | 'auto_advance' | 'complete' | 'edit';
  count_after: number;
  /** Seconds since the previous event on this countdown. */
  elapsed_seconds: number;
  /** Seconds since the current streak began. */
  run_elapsed_seconds: number;
  unit: CountdownUnit;
  note: string;
  occurred_at: string;
}

/** A signal an automatic countdown can advance on. */
export interface CountdownSignal {
  key: string;
  label: string;
  unit: CountdownUnit;
}

export interface CreateUserCountdown {
  template?: string | null;
  custom_reason?: string;
  countdown_type?: CountdownType;
  unit?: CountdownUnit;
  target_count?: number;
  start_date?: string;
  /** Required for automatic countdowns — what advances them. */
  auto_advance_signal?: string;
}

export interface UpdateUserCountdown {
  custom_reason?: string;
  countdown_type?: CountdownType;
  unit?: CountdownUnit;
  target_count?: number;
  start_date?: string;
  is_active?: boolean;
  auto_advance_signal?: string;
}

export type RoutineType = 'walk' | 'run' | 'cycle' | 'hike' | 'workout';

export interface Routine {
  id: string;
  type: RoutineType;
  name: string;
  target: number;
  unit: string;
  days: number[];
  streak: number;
  completed_today: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CreateRoutine {
  type: RoutineType;
  name: string;
  target: number;
  unit: string;
  days?: number[];
  streak?: number;
  completed_today?: boolean;
}

export interface CountdownCheckInResult {
  success: boolean;
  data: UserCountdown;
  message: string;
}

export interface CountdownResetResult {
  success: boolean;
  data: UserCountdown;
  message: string;
}

export interface CountdownAutoAdvanceResult {
  success: boolean;
  data: { advanced_ids: string[]; count: number };
  message: string;
}

export const DEFAULT_COUNTDOWN_TEMPLATES: Partial<CountdownTemplate>[] = [
  {
    code: 'sobriety',
    title: 'Sobriety',
    unit: 'days',
    description: 'Days since last drink.',
    icon: '🍻',
    color: '#ef4444',
    default_target: 0,
    sort_order: 1,
  },
  {
    code: 'no_artificial_sugars',
    title: 'No Artificial Sugars',
    unit: 'days',
    description: 'Days without artificial sweeteners.',
    icon: '🍬',
    color: '#f59e0b',
    default_target: 0,
    sort_order: 2,
  },
  {
    code: 'no_animal_proteins',
    title: 'No Animal Proteins',
    unit: 'days',
    description: 'Days without meat, fish, eggs, or dairy.',
    icon: '🌱',
    color: '#22c55e',
    default_target: 0,
    sort_order: 3,
  },
  {
    code: 'gym_attendance',
    title: 'Gym Attendance',
    unit: 'days',
    description: 'Consecutive days with a gym visit.',
    icon: '🏋️',
    color: '#3b82f6',
    default_target: 0,
    sort_order: 4,
  },
  {
    code: 'walking_days',
    title: 'Walking Days',
    unit: 'days',
    description: 'Days with a logged walk.',
    icon: '🚶',
    color: '#10b981',
    default_target: 0,
    sort_order: 5,
  },
  {
    code: 'no_drugs',
    title: 'No Drugs',
    unit: 'days',
    description: 'Days drug-free.',
    icon: '💊',
    color: '#dc2626',
    default_target: 0,
    sort_order: 6,
  },
  {
    code: 'no_nut_month',
    title: "No Nut Month",
    unit: 'days',
    description: 'Days without nuts.',
    icon: '🥜',
    color: '#a855f7',
    default_target: 30,
    sort_order: 7,
  },
  {
    code: 'custom',
    title: 'Custom Reason',
    unit: 'days',
    description: 'Your own countdown reason.',
    icon: '📅',
    color: '#6b7280',
    default_target: 0,
    sort_order: 99,
  },
] as const;
