import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { authApi } from '@/api';
import { useAuthStore } from '@/store/authStore';

const goals = ['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_wellness', 'nutrition', 'sports_performance', 'rehabilitation', 'mental_health'] as const;
const goalLabels: Record<string, string> = { weight_loss: 'Weight Loss', muscle_gain: 'Muscle Gain', endurance: 'Endurance', flexibility: 'Flexibility', general_wellness: 'General Wellness', nutrition: 'Nutrition', sports_performance: 'Sports Performance', rehabilitation: 'Rehabilitation', mental_health: 'Mental Health' };
const levels = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'athlete'] as const;
const levelLabels: Record<string, string> = { sedentary: 'Sedentary', lightly_active: 'Lightly Active', moderately_active: 'Moderately Active', very_active: 'Very Active', athlete: 'Athlete' };
const workoutTypes = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'martial_arts', 'swimming', 'running', 'cycling', 'other'] as const;
const workoutLabels: Record<string, string> = { weights: 'Weights', cardio: 'Cardio', hiit: 'HIIT', yoga: 'Yoga', pilates: 'Pilates', crossfit: 'CrossFit', martial_arts: 'Martial Arts', swimming: 'Swimming', running: 'Running', cycling: 'Cycling', other: 'Other' };
const diets = ['none', 'vegan', 'vegetarian', 'keto', 'paleo', 'halal', 'kosher', 'gluten_free', 'other'] as const;
const dietLabels: Record<string, string> = { none: 'None', vegan: 'Vegan', vegetarian: 'Vegetarian', keto: 'Keto', paleo: 'Paleo', halal: 'Halal', kosher: 'Kosher', gluten_free: 'Gluten-Free', other: 'Other' };
const times = ['early_morning', 'morning', 'afternoon', 'evening', 'night', 'flexible'] as const;
const timeLabels: Record<string, string> = { early_morning: 'Early Morning', morning: 'Morning', afternoon: 'Afternoon', evening: 'Evening', night: 'Night', flexible: 'Flexible' };

interface OnboardingPlan {
  primary_goal: string;
  recommended_trainer_specialties: string[];
  recommended_gym_categories: string[];
  suggested_workout_plan: { frequency: string; focus: string; sample_split: string[] };
  activity_level_advice: string;
  time_preference_advice: string;
  buddy_matching_hint: string;
  meal_plan_recommendation: string;
  recommended_dietary_tags: string[];
}

export default function Onboarding() {
  const navigate = useNavigate();
  const setProfile = useAuthStore((s) => s.setProfile);
  const [step, setStep] = useState(1);
  const [selectedGoals, setSelectedGoals] = useState<string[]>([]);
  const [activityLevel, setActivityLevel] = useState('');
  const [selectedWorkouts, setSelectedWorkouts] = useState<string[]>([]);
  const [diet, setDiet] = useState('none');
  const [preferredTime, setPreferredTime] = useState('flexible');
  const [isLoading, setIsLoading] = useState(false);
  const [plan, setPlan] = useState<OnboardingPlan | null>(null);

  const toggleMulti = (item: string, selected: string[], setter: (v: string[]) => void) => {
    setter(selected.includes(item) ? selected.filter((s) => s !== item) : [...selected, item]);
  };

  const handleComplete = async () => {
    setIsLoading(true);
    try {
      const res = await authApi.completeOnboarding({
        primary_goal: selectedGoals,
        activity_level: activityLevel,
        preferred_workouts: selectedWorkouts,
        dietary_preference: diet,
        preferred_time: preferredTime,
      });
      const data = res.data as any;
      if (data?.profile) {
        setProfile(data.profile);
      } else {
        setProfile(res.data);
      }
      if (data?.onboarding_plan) {
        setPlan(data.onboarding_plan);
        setStep(6);
      } else {
        navigate('/feed');
      }
    } catch {
      navigate('/feed');
    } finally {
      setIsLoading(false);
    }
  };

  const totalSteps = plan ? 6 : 5;

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-lg p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Set Your <span className="text-buddy-green">Goals</span>
        </h1>
        {step < 6 && (
          <>
            <p className="text-buddy-text-secondary text-center mb-2">Step {step} of {totalSteps}</p>
            <div className="flex gap-1 mb-6">
              {Array.from({ length: totalSteps }).map((_, i) => (
                <div key={i} className={`flex-1 h-1 rounded-full ${i < step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
              ))}
            </div>
          </>
        )}

        {step === 1 && (
          <div className="space-y-4">
            <p className="font-heading font-semibold text-lg">What are your primary fitness goals?</p>
            <div className="flex flex-wrap gap-2">
              {goals.map((g) => (
                <button key={g} onClick={() => toggleMulti(g, selectedGoals, setSelectedGoals)}
                  className={`px-4 py-2 rounded-full text-sm transition-colors ${selectedGoals.includes(g) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{goalLabels[g]}</button>
              ))}
            </div>
            <Button className="w-full mt-4" size="lg" disabled={selectedGoals.length === 0} onClick={() => setStep(2)}>Next</Button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-4">
            <p className="font-heading font-semibold text-lg">Current activity level?</p>
            <div className="grid grid-cols-1 gap-2">
              {levels.map((l) => (
                <button key={l} onClick={() => setActivityLevel(l)}
                  className={`px-4 py-3 rounded-xl text-sm text-left transition-colors ${activityLevel === l ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{levelLabels[l]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(1)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={!activityLevel} onClick={() => setStep(3)}>Next</Button>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-4">
            <p className="font-heading font-semibold text-lg">Preferred workout types?</p>
            <div className="flex flex-wrap gap-2">
              {workoutTypes.map((w) => (
                <button key={w} onClick={() => toggleMulti(w, selectedWorkouts, setSelectedWorkouts)}
                  className={`px-4 py-2 rounded-full text-sm transition-colors ${selectedWorkouts.includes(w) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{workoutLabels[w]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(2)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={selectedWorkouts.length === 0} onClick={() => setStep(4)}>Next</Button>
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-4">
            <p className="font-heading font-semibold text-lg">Dietary preference?</p>
            <div className="flex flex-wrap gap-2">
              {diets.map((d) => (
                <button key={d} onClick={() => setDiet(d)}
                  className={`px-4 py-2 rounded-full text-sm transition-colors ${diet === d ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{dietLabels[d]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(3)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" onClick={() => setStep(5)}>Next</Button>
            </div>
          </div>
        )}

        {step === 5 && (
          <div className="space-y-4">
            <p className="font-heading font-semibold text-lg">Preferred training time?</p>
            <div className="grid grid-cols-3 gap-2">
              {times.map((t) => (
                <button key={t} onClick={() => setPreferredTime(t)}
                  className={`px-3 py-3 rounded-xl text-sm text-center transition-colors ${preferredTime === t ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{timeLabels[t]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(4)} className="flex-1">Back</Button>
              <Button onClick={handleComplete} isLoading={isLoading} className="flex-1" size="lg">Complete Setup</Button>
            </div>
          </div>
        )}

        {step === 6 && plan && (
          <div className="space-y-5 max-h-[60vh] overflow-y-auto pr-1">
            <p className="text-buddy-green font-heading font-semibold text-lg text-center">Your Personalised Plan</p>

            <div>
              <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-1">Recommended Workout Plan</p>
              <p className="text-sm font-medium">{plan.suggested_workout_plan.frequency} — {plan.suggested_workout_plan.focus}</p>
              <div className="flex flex-wrap gap-1 mt-2">
                {plan.suggested_workout_plan.sample_split.map((day: string, i: number) => (
                  <span key={i} className="text-xs px-2 py-1 rounded-full bg-buddy-surface-raised text-buddy-text-secondary">{day}</span>
                ))}
              </div>
            </div>

            <div>
              <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-1">Trainers & Gym Focus</p>
              <div className="flex flex-wrap gap-1">
                {plan.recommended_trainer_specialties.map((s: string) => (
                  <span key={s} className="text-xs px-2 py-1 rounded-md bg-buddy-green/10 text-buddy-green">{s.replace(/_/g, ' ')}</span>
                ))}
              </div>
              <div className="flex flex-wrap gap-1 mt-1">
                {plan.recommended_gym_categories.map((c: string) => (
                  <span key={c} className="text-xs px-2 py-1 rounded-md bg-buddy-surface-raised text-buddy-text-secondary">{c}</span>
                ))}
              </div>
            </div>

            <div>
              <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-1">Activity Advice</p>
              <p className="text-sm">{plan.activity_level_advice}</p>
            </div>

            <div>
              <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-1">Meal Plan Direction</p>
              <p className="text-sm">{plan.meal_plan_recommendation}</p>
            </div>

            <div>
              <p className="text-xs text-buddy-text-secondary uppercase tracking-wider mb-1">Buddy Matching</p>
              <p className="text-sm">{plan.buddy_matching_hint}</p>
            </div>

            <Button className="w-full" size="lg" onClick={() => navigate('/feed')}>
              Start Your Journey
            </Button>
          </div>
        )}
      </Card>
    </div>
  );
}
