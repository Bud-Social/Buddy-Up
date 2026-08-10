export type AnalyticsPeriod = 'week' | 'month' | 'quarter' | 'year' | 'all';

export interface ActivityTypeBreakdown {
  activity_type?: string;
  label: string;
  count: number;
  distance?: number;
  distance_km?: number;
  duration?: number;
  calories?: number;
}

export interface WorkoutRecent {
  performed_at: string;
  workout_type: string;
  exercise: string;
  duration_minutes: number;
  calories_burned: number | null;
}

export interface WorkoutSummary {
  count: number;
  total_calories_burned: number;
  total_volume: number;
  by_type: ActivityTypeBreakdown[];
  most_trained: string | null;
  recent: WorkoutRecent[];
}

export interface ActivityRecent {
  id: string;
  activity_type: string;
  started_at: string | null;
  duration_seconds: number;
  distance_meters: number;
  distance_km: number;
  avg_pace: number | null;
  calories_burned: number | null;
  route: number[][];
}

export interface ActivitySummary {
  count: number;
  total_distance_km: number;
  total_duration_seconds: number;
  total_calories_burned: number;
  total_steps: number;
  avg_pace: number | null;
  by_type: ActivityTypeBreakdown[];
  recent: ActivityRecent[];
}

export interface MealRecent {
  id: string;
  meal_type: string;
  food_name: string;
  description: string;
  calories: number | null;
  protein_g: number | null;
  carbs_g: number | null;
  fat_g: number | null;
  photo_url: string;
  logged_at: string | null;
}

export interface NutritionSummary {
  count: number;
  total_calories: number;
  total_protein_g: number;
  total_carbs_g: number;
  total_fat_g: number;
  by_type: ActivityTypeBreakdown[];
  avg_daily_calories: number | null;
  recent: MealRecent[];
}

export interface BodySeriesPoint {
  id: string;
  weight_kg: number;
  body_fat_pct: number | null;
  measured_at: string | null;
  photo_url: string;
}

export interface BodySummary {
  count: number;
  start_weight_kg: number | null;
  latest_weight_kg: number | null;
  weight_change_kg: number | null;
  latest_body_fat_pct: number | null;
  series: BodySeriesPoint[];
}

export interface LivesSummary {
  joined_count: number;
  total_duration_seconds: number;
  by_type: ActivityTypeBreakdown[];
}

export interface SpendingCategory {
  category: string;
  quantity: number;
  count: number;
  label: string;
}

export interface SpendingSummary {
  gifts_sent: SpendingCategory;
  gifts_received: SpendingCategory;
  tips_sent: SpendingCategory;
  tips_received: SpendingCategory;
  live_fees: SpendingCategory;
  gym_subscriptions: SpendingCategory;
  session_fees: SpendingCategory;
  marketplace_spend: SpendingCategory;
  total_transactions: number;
  total_artifacts_spent: number;
  breakdown: SpendingCategory[];
}

export interface ProgrammesSummary {
  programmes_purchased: number;
  meal_plans_purchased: number;
  active_enrolments: number;
  completed_enrolments: number;
  avg_progress_pct: number | null;
}

export interface AnalyticsSummaryData {
  period: AnalyticsPeriod;
  user: {
    username: string;
    display_name: string;
    avatar_url: string;
    streak_days: number;
  };
  workouts: WorkoutSummary;
  activity: ActivitySummary;
  nutrition: NutritionSummary;
  body: BodySummary;
  lives: LivesSummary;
  spending: SpendingSummary;
  programmes: ProgrammesSummary;
}

export interface AnalyticsReportResult {
  id: string;
  period: AnalyticsPeriod;
  data: AnalyticsSummaryData;
  image_url: string;
}

export interface ShareReportPayload {
  period: AnalyticsPeriod;
  body?: string;
}

export interface ShareReportResult {
  report_id: string;
  post_id: string;
  image_url: string;
}

export interface ActivityRecordInput {
  activity_type: 'walk' | 'run' | 'hike' | 'cycle';
  started_at?: string;
  duration_seconds: number;
  distance_meters: number;
  avg_pace?: number | null;
  avg_speed_kmh?: number | null;
  calories_burned?: number | null;
  steps?: number | null;
  elevation_gain_m?: number | null;
  route?: number[][];
  notes?: string;
}

export interface WorkoutLogInput {
  workout_type: 'strength' | 'cardio' | 'hiit' | 'yoga' | 'mobility' | 'sport' | 'other';
  exercise?: string;
  sets?: number | null;
  reps?: number | null;
  weight_kg?: number | null;
  duration_minutes?: number;
  calories_burned?: number | null;
  distance_meters?: number | null;
  performed_at?: string;
  notes?: string;
}

export interface MealLogInput {
  meal_type: 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'drink' | 'other';
  food_name?: string;
  description?: string;
  calories?: number | null;
  protein_g?: number | null;
  carbs_g?: number | null;
  fat_g?: number | null;
  photo_url?: string;
  logged_at?: string;
}

export interface BodyMetricInput {
  weight_kg: number;
  body_fat_pct?: number | null;
  photo_url?: string;
  notes?: string;
  measured_at?: string;
}
