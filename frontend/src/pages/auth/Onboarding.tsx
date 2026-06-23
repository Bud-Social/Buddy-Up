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
      setProfile(res.data);
      navigate('/feed');
    } catch {
      navigate('/feed');
    } finally {
      setIsLoading(false);
    }
  };

  const totalSteps = 5;

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-lg p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Set Your <span className="text-buddy-green">Goals</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-2">Step {step} of {totalSteps}</p>
        <div className="flex gap-1 mb-6">
          {Array.from({ length: totalSteps }).map((_, i) => (
            <div key={i} className={`flex-1 h-1 rounded-full ${i < step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
          ))}
        </div>

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
      </Card>
    </div>
  );
}
