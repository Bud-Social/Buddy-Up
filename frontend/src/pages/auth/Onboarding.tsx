import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { authApi } from '@/api';
import { useAuthStore } from '@/store/authStore';

const TERMS_VERSION = '2026-08-v1';

const goals = ['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_wellness', 'nutrition', 'sports_performance', 'rehabilitation', 'mental_health'] as const;
const goalLabels: Record<string, string> = { weight_loss: 'Weight Loss', muscle_gain: 'Muscle Gain', endurance: 'Endurance', flexibility: 'Flexibility', general_wellness: 'General Wellness', nutrition: 'Nutrition', sports_performance: 'Sports Performance', rehabilitation: 'Rehabilitation', mental_health: 'Mental Health' };
const levels = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'athlete'] as const;
const levelLabels: Record<string, string> = { sedentary: 'Sedentary', lightly_active: 'Lightly Active', moderately_active: 'Moderately Active', very_active: 'Very Active', athlete: 'Athlete' };
const workoutTypes = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'martial_arts', 'swimming', 'running', 'cycling', 'other'] as const;
const workoutLabels: Record<string, string> = { weights: 'Weights', cardio: 'Cardio', hiit: 'HIIT', yoga: 'Yoga', pilates: 'Pilates', crossfit: 'CrossFit', martial_arts: 'Martial Arts', swimming: 'Swimming', running: 'Running', cycling: 'Cycling', other: 'Other' };
const diets = ['none', 'vegan', 'vegetarian', 'keto', 'paleo', 'halal', 'kosher', 'gluten_free', 'other'] as const;
const dietLabels: Record<string, string> = { none: 'None', vegan: 'Vegan', vegetarian: 'Keto', keto: 'Keto', paleo: 'Paleo', halal: 'Halal', kosher: 'Kosher', gluten_free: 'Gluten-Free', other: 'Other' };
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

/**
 * Required-once onboarding pipeline:
 *   [age] → terms & consents → profile essentials → goals/interests → plan
 * The router sends every new (or incomplete) account here before the feed.
 */
export default function Onboarding() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const setProfile = useAuthStore((s) => s.setProfile);
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);

  // Step "age" only when arriving with ?step=age or an unconfirmed adult flag.
  const needsAge = searchParams.get('step') === 'age' || user?.is_adult === false;

  const [step, setStep] = useState<number>(needsAge ? 0 : 1);
  const totalSteps = 7; // age(0) + terms + profile + goals + level + workouts + diet/time

  // Age step
  const [dob, setDob] = useState('');
  const [dobError, setDobError] = useState('');

  // Terms step
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [acceptPrivacy, setAcceptPrivacy] = useState(false);
  const [acceptGuidelines, setAcceptGuidelines] = useState(false);
  const [marketingConsent, setMarketingConsent] = useState(false);

  // Profile essentials
  const [displayName, setDisplayName] = useState(profile?.display_name ?? '');
  const [username, setUsername] = useState(profile?.username ?? '');
  const [city, setCity] = useState(profile?.location_city ?? '');
  const [bio, setBio] = useState('');
  const [profileError, setProfileError] = useState('');

  // Preferences
  const [selectedGoals, setSelectedGoals] = useState<string[]>([]);
  const [activityLevel, setActivityLevel] = useState('');
  const [selectedWorkouts, setSelectedWorkouts] = useState<string[]>([]);
  const [diet, setDiet] = useState('none');
  const [preferredTime, setPreferredTime] = useState('flexible');
  const [isLoading, setIsLoading] = useState(false);
  const [plan, setPlan] = useState<OnboardingPlan | null>(null);
  const [error, setError] = useState('');

  const toggleMulti = (item: string, selected: string[], setter: (v: string[]) => void) => {
    setter(selected.includes(item) ? selected.filter((s) => s !== item) : [...selected, item]);
  };

  const submitAge = async () => {
    setDobError('');
    if (!dob) { setDobError('Enter your date of birth.'); return; }
    setIsLoading(true);
    try {
      const res = await authApi.socialAgeSetup(dob);
      if (res.data?.profile) setProfile(res.data.profile);
      setStep(1);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message
        || 'Could not verify your date of birth. Please try again.';
      setDobError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  const usernameValid = /^[a-zA-Z0-9_]{3,30}$/.test(username);
  const displayNameValid = displayName.trim().length >= 2;
  const validateProfileStep = () => {
    if (!displayNameValid) { setProfileError('Display name needs at least 2 characters.'); return false; }
    if (!usernameValid) { setProfileError('Username must be 3–30 letters, numbers or underscores.'); return false; }
    setProfileError('');
    return true;
  };
  const termsStepValid = acceptTerms && acceptPrivacy && acceptGuidelines;

  const handleComplete = async () => {
    setIsLoading(true);
    setError('');
    try {
      const res = await authApi.completeOnboarding({
        primary_goal: selectedGoals,
        activity_level: activityLevel,
        preferred_workouts: selectedWorkouts,
        dietary_preference: diet,
        preferred_time: preferredTime,
        terms_version: TERMS_VERSION,
        marketing_consent: marketingConsent,
        display_name: displayName.trim(),
        username: username.trim().toLowerCase(),
        location_city: city.trim(),
        bio: bio.trim(),
      });
      const data = res.data as unknown as { profile?: typeof profile; onboarding_plan?: OnboardingPlan };
      if (data?.profile) setProfile(data.profile);
      if (data?.onboarding_plan) {
        setPlan(data.onboarding_plan);
        setStep(8);
      } else {
        navigate('/feed');
      }
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string; errors?: Record<string, string[]> } } })?.response?.data;
      const fieldMsg = msg?.errors ? Object.values(msg.errors).flat()[0] : undefined;
      setError(fieldMsg || msg?.message || 'Something went wrong. Please try again.');
      setStep(2); // send them back to the profile step to fix it
    } finally {
      setIsLoading(false);
    }
  };

  const Progress = ({ current }: { current: number }) => (
    <>
      <p className="text-buddy-text-secondary text-center mb-2">Step {current} of {totalSteps}</p>
      <div className="flex gap-1 mb-6">
        {Array.from({ length: totalSteps }).map((_, i) => (
          <div key={i} className={`flex-1 h-1 rounded-full ${i < current ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
        ))}
      </div>
    </>
  );

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-lg p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Welcome to <span className="text-buddy-green">BuddyUp</span>
        </h1>

        {/* ── AGE ── */}
        {step === 0 && (
          <div className="space-y-4">
            <Progress current={1} />
            <p className="font-heading font-semibold text-lg">Confirm your date of birth</p>
            <p className="text-sm text-buddy-text-secondary">
              Used only for age-appropriate content. We store a secure hash, never the date itself.
            </p>
            <Input type="date" value={dob} onChange={(e) => setDob(e.target.value)} max="2012-12-31" />
            {dobError && <p className="text-sm text-red-400">{dobError}</p>}
            <Button className="w-full" size="lg" disabled={!dob || isLoading} onClick={submitAge} isLoading={isLoading}>
              Continue
            </Button>
          </div>
        )}

        {/* ── TERMS ── */}
        {step === 1 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 2 : 1} />
            <p className="font-heading font-semibold text-lg">Before you start</p>
            {[
              { checked: acceptTerms, set: setAcceptTerms, label: 'I accept the Terms of Service', link: '/terms' },
              { checked: acceptPrivacy, set: setAcceptPrivacy, label: 'I accept the Privacy Policy (how your data is used and protected)', link: '/privacy' },
              { checked: acceptGuidelines, set: setAcceptGuidelines, label: 'I agree to the Community Guidelines (respect, no harassment, health-claim honesty)', link: '/community-guidelines' },
            ].map(({ checked, set, label, link }) => (
              <label key={link} className="flex items-start gap-3 text-sm cursor-pointer text-buddy-text-primary">
                <input type="checkbox" checked={checked} onChange={(e) => set(e.target.checked)} className="mt-0.5 accent-buddy-green w-4 h-4" />
                <span>
                  {label.split('(')[0]}
                  <a href={link} target="_blank" rel="noreferrer" className="text-buddy-green hover:underline ml-1">read</a>
                  {label.includes('(') && <span className="text-buddy-text-secondary"> ({label.split('(')[1]}</span>}
                </span>
              </label>
            ))}
            <label className="flex items-start gap-3 text-sm cursor-pointer text-buddy-text-secondary">
              <input type="checkbox" checked={marketingConsent} onChange={(e) => setMarketingConsent(e.target.checked)} className="mt-0.5 accent-buddy-green w-4 h-4" />
              <span>Send me occasional product updates and training tips (optional)</span>
            </label>
            <div className="flex gap-3 mt-4">
              {needsAge && <Button variant="ghost" onClick={() => setStep(0)} className="flex-1">Back</Button>}
              <Button className="flex-1" size="lg" disabled={!termsStepValid} onClick={() => setStep(2)}>Next</Button>
            </div>
          </div>
        )}

        {/* ── PROFILE ── */}
        {step === 2 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 3 : 2} />
            <p className="font-heading font-semibold text-lg">Set up your profile</p>
            <Input
              label="Display name"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="e.g. Jane K."
              required
            />
            {!displayNameValid && displayName.length > 0 && (
              <p className="text-xs text-red-400 -mt-2">At least 2 characters.</p>
            )}
            <Input
              label="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, ''))}
              placeholder="fitness_fan"
              helperText="3–30 characters — letters, numbers, underscores."
              required
            />
            {!usernameValid && username.length > 0 && (
              <p className="text-xs text-red-400 -mt-2">Letters, numbers and underscores only (3–30).</p>
            )}
            <Input label="City (optional)" value={city} onChange={(e) => setCity(e.target.value)} placeholder="Nairobi" />
            <Input label="Short bio (optional)" value={bio} onChange={(e) => setBio(e.target.value)} placeholder="5k beginner, gym 3×/week…" maxLength={200} />
            {(profileError || error) && step === 2 && <p className="text-sm text-red-400">{profileError || error}</p>}
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(needsAge ? 0 : 1)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={!displayNameValid || !usernameValid}
                onClick={() => { if (validateProfileStep()) setStep(3); }}>Next</Button>
            </div>
          </div>
        )}

        {/* ── GOALS ── */}
        {step === 3 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 4 : 3} />
            <p className="font-heading font-semibold text-lg">What are your primary fitness goals?</p>
            <div className="flex flex-wrap gap-2">
              {goals.map((g) => (
                <button key={g} onClick={() => toggleMulti(g, selectedGoals, setSelectedGoals)}
                  className={`px-4 py-2 rounded-full text-sm transition-colors ${selectedGoals.includes(g) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{goalLabels[g]}</button>
              ))}
            </div>
            <p className="text-xs text-buddy-text-secondary mt-2">These power your recommendations — pick everything that applies.</p>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(2)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={selectedGoals.length === 0} onClick={() => setStep(4)}>Next</Button>
            </div>
          </div>
        )}

        {/* ── ACTIVITY LEVEL ── */}
        {step === 4 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 5 : 4} />
            <p className="font-heading font-semibold text-lg">Current activity level?</p>
            <div className="grid grid-cols-1 gap-2">
              {levels.map((l) => (
                <button key={l} onClick={() => setActivityLevel(l)}
                  className={`px-4 py-3 rounded-xl text-sm text-left transition-colors ${activityLevel === l ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{levelLabels[l]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(3)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={!activityLevel} onClick={() => setStep(5)}>Next</Button>
            </div>
          </div>
        )}

        {/* ── WORKOUT TYPES ── */}
        {step === 5 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 6 : 5} />
            <p className="font-heading font-semibold text-lg">Preferred workout types?</p>
            <div className="flex flex-wrap gap-2">
              {workoutTypes.map((w) => (
                <button key={w} onClick={() => toggleMulti(w, selectedWorkouts, setSelectedWorkouts)}
                  className={`px-4 py-2 rounded-full text-sm transition-colors ${selectedWorkouts.includes(w) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{workoutLabels[w]}</button>
              ))}
            </div>
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(4)} className="flex-1">Back</Button>
              <Button className="flex-1" size="lg" disabled={selectedWorkouts.length === 0} onClick={() => setStep(6)}>Next</Button>
            </div>
          </div>
        )}

        {/* ── DIET + TIME ── */}
        {step === 6 && (
          <div className="space-y-4">
            <Progress current={needsAge ? 7 : 6} />
            <p className="font-heading font-semibold text-lg">Dietary preference &amp; training time</p>
            <div className="flex flex-wrap gap-2">
              {diets.map((d) => (
                <button key={d} onClick={() => setDiet(d)}
                  className={`px-3 py-1.5 rounded-full text-xs transition-colors ${diet === d ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{dietLabels[d] ?? d}</button>
              ))}
            </div>
            <div className="grid grid-cols-3 gap-2 pt-2">
              {times.map((t) => (
                <button key={t} onClick={() => setPreferredTime(t)}
                  className={`px-3 py-3 rounded-xl text-sm text-center transition-colors ${preferredTime === t ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}
                >{timeLabels[t]}</button>
              ))}
            </div>
            {error && <p className="text-sm text-red-400">{error}</p>}
            <div className="flex gap-3 mt-4">
              <Button variant="ghost" onClick={() => setStep(5)} className="flex-1">Back</Button>
              <Button onClick={handleComplete} isLoading={isLoading} className="flex-1" size="lg">Complete Setup</Button>
            </div>
          </div>
        )}

        {/* ── PLAN ── */}
        {step === 8 && plan && (
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
