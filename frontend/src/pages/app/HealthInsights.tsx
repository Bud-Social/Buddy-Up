import { useState, useEffect } from 'react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { feedApi } from '@/api/feed';
import { Skeleton } from '@/components/ui/Skeleton';

interface HealthInsights {
  period: string;
  generated_at: string;
  workout_summary: {
    total_workouts: number;
    total_volume: number;
    unique_exercises: number;
    exercise_names: string[];
    most_trained_exercise: string | null;
    most_trained_count: number;
    highest_volume_exercise: string | null;
    highest_volume_amount: number;
  };
  streak_summary: {
    current_streak: number;
    longest_streak: number;
    is_active: boolean;
  };
  meal_summary: {
    total_meals_logged: number;
    total_calories_estimated: number;
    unique_meal_types: string[];
  };
  achievements: Array<{ id: string; label: string; icon: string }>;
  narrative: string;
}

export default function HealthInsights() {
  const [period, setPeriod] = useState<'weekly' | 'monthly'>('weekly');
  const [loading, setLoading] = useState(true);
  const [insights, setInsights] = useState<HealthInsights | null>(null);

  useEffect(() => {
    setLoading(true);
    feedApi.getHealthInsights(period)
      .then((res) => {
        if (res.success && res.data) {
          setInsights(res.data);
        }
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [period]);

  return (
    <div className="p-4 space-y-4 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-2xl font-bold">Health Insights</h1>
        <div className="flex gap-2">
          <Button
            size="sm"
            variant={period === 'weekly' ? 'primary' : 'outline'}
            onClick={() => setPeriod('weekly')}
          >
            Weekly
          </Button>
          <Button
            size="sm"
            variant={period === 'monthly' ? 'primary' : 'outline'}
            onClick={() => setPeriod('monthly')}
          >
            Monthly
          </Button>
        </div>
      </div>

      {loading ? (
        <Card className="p-6 space-y-4">
          <Skeleton className="h-6 w-3/4" />
          <Skeleton className="h-4 w-full" />
          <Skeleton className="h-4 w-5/6" />
          <Skeleton className="h-4 w-2/3" />
        </Card>
      ) : insights ? (
        <>
          {/* Narrative Summary */}
          <Card className="p-6 bg-gradient-to-br from-buddy-green/10 to-buddy-surface">
            <p className="font-heading font-semibold text-lg mb-2">Your {period} Summary</p>
            <p className="text-buddy-text-primary leading-relaxed">{insights.narrative}</p>
          </Card>

          {/* Achievements */}
          {insights.achievements.length > 0 && (
            <Card className="p-6">
              <p className="font-heading font-semibold text-lg mb-3">Achievements</p>
              <div className="flex flex-wrap gap-3">
                {insights.achievements.map((ach) => (
                  <div
                    key={ach.id}
                    className="flex items-center gap-2 px-3 py-2 rounded-lg bg-buddy-surface-raised border border-buddy-green/30"
                  >
                    <span className="text-2xl">{ach.icon}</span>
                    <span className="text-sm font-medium">{ach.label}</span>
                  </div>
                ))}
              </div>
            </Card>
          )}

          {/* Workout Summary */}
          <Card className="p-6">
            <p className="font-heading font-semibold text-lg mb-4">Workout Summary</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Total Workouts</p>
                <p className="text-2xl font-bold text-buddy-green">{insights.workout_summary.total_workouts}</p>
              </div>
              <div>
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Total Volume</p>
                <p className="text-2xl font-bold text-buddy-green">{insights.workout_summary.total_volume.toLocaleString()} kg</p>
              </div>
              <div>
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Unique Exercises</p>
                <p className="text-2xl font-bold">{insights.workout_summary.unique_exercises}</p>
              </div>
              {insights.workout_summary.most_trained_exercise && (
                <div>
                  <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Most Trained</p>
                  <p className="text-lg font-semibold truncate">
                    {insights.workout_summary.most_trained_exercise} ({insights.workout_summary.most_trained_count}x)
                  </p>
                </div>
              )}
            </div>
            {insights.workout_summary.exercise_names.length > 0 && (
              <div className="mt-4">
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-2">Exercises Logged</p>
                <div className="flex flex-wrap gap-1">
                  {insights.workout_summary.exercise_names.map((ex) => (
                    <span key={ex} className="text-xs px-2 py-1 rounded-md bg-buddy-surface-raised text-buddy-text-secondary">
                      {ex}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </Card>

          {/* Streak Summary */}
          <Card className="p-6">
            <p className="font-heading font-semibold text-lg mb-4">Streak</p>
            <div className="flex items-center gap-4">
              <div className="text-center">
                <p className="text-3xl font-bold text-buddy-green">{insights.streak_summary.current_streak}</p>
                <p className="text-xs text-buddy-text-secondary">Current Streak (days)</p>
              </div>
              {insights.streak_summary.longest_streak > insights.streak_summary.current_streak && (
                <div className="text-center">
                  <p className="text-2xl font-semibold">{insights.streak_summary.longest_streak}</p>
                  <p className="text-xs text-buddy-text-secondary">Longest Streak</p>
                </div>
              )}
            </div>
            {insights.streak_summary.is_active && (
              <p className="mt-3 text-sm text-buddy-green">🔥 Keep the momentum going!</p>
            )}
          </Card>

          {/* Meal Summary */}
          <Card className="p-6">
            <p className="font-heading font-semibold text-lg mb-4">Nutrition</p>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Meals Logged</p>
                <p className="text-2xl font-bold">{insights.meal_summary.total_meals_logged}</p>
              </div>
              <div>
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider">Est. Calories</p>
                <p className="text-2xl font-bold">
                  {insights.meal_summary.total_calories_estimated > 0
                    ? insights.meal_summary.total_calories_estimated.toLocaleString()
                    : '—'}
                </p>
              </div>
            </div>
            {insights.meal_summary.unique_meal_types.length > 0 && (
              <div className="mt-4">
                <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-2">Meal Types</p>
                <div className="flex flex-wrap gap-1">
                  {insights.meal_summary.unique_meal_types.map((type) => (
                    <span key={type} className="text-xs px-2 py-1 rounded-md bg-buddy-surface-raised text-buddy-text-secondary capitalize">
                      {type}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </Card>
        </>
      ) : (
        <Card className="p-6 text-center">
          <p className="text-buddy-text-secondary">Unable to load insights. Please try again later.</p>
        </Card>
      )}
    </div>
  );
}