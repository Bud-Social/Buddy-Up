import { useState, useMemo } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Dumbbell, GraduationCap, Stethoscope } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { getPasswordStrength } from '@/utils/passwordStrength';
import { calculateAge } from '@/utils/ageCheck';
import { authApi } from '@/api';

export default function Register() {
  const navigate = useNavigate();

  const [step, setStep] = useState(1);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [acceptedTerms, setAcceptedTerms] = useState(false);
  const [accepted16, setAccepted16] = useState(false);
  const [dobDay, setDobDay] = useState('');
  const [dobMonth, setDobMonth] = useState('');
  const [dobYear, setDobYear] = useState('');
  const [username, setUsername] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState<string>('user');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [ageError, setAgeError] = useState('');

  const pwStrength = useMemo(() => getPasswordStrength(password), [password]);

  const handleAgeCheck = (e: React.FormEvent) => {
    e.preventDefault();
    setAgeError('');
    const d = parseInt(dobDay), m = parseInt(dobMonth), y = parseInt(dobYear);
    if (!d || !m || !y || d < 1 || d > 31 || m < 1 || m > 12 || y < 1900 || y > 2020) {
      setAgeError('Please enter a valid date of birth.');
      return;
    }
    const dob = new Date(y, m - 1, d);
    const age = calculateAge(dob);
    if (age < 16) {
      setAgeError('BuddyUp is for users aged 16 and over. You cannot create an account at this time.');
      return;
    }
    setStep(3);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const d = parseInt(dobDay), m = parseInt(dobMonth), y = parseInt(dobYear);
      const dob = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const res = await authApi.register({
        email, password, dob, username, display_name: displayName || username, role,
        accepted_terms: acceptedTerms, accepted_privacy: true, accepted_guidelines: true, is_16_plus: true,
      });
      navigate(`/verify-registration-otp?token=${encodeURIComponent(res.data.registration_token)}&email=${encodeURIComponent(res.data.email)}`);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Registration failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Join <span className="text-buddy-green">BuddyUp</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-6">
          Step {step} of 3: {step === 1 ? 'Account Details' : step === 2 ? 'Age Verification' : 'Profile Setup'}
        </p>

        <div className="flex gap-1 mb-6">
          {[1, 2, 3].map((s) => (
            <div key={s} className={`flex-1 h-1 rounded-full ${s <= step ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
          ))}
        </div>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}
        {ageError && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{ageError}</div>}

        {step === 1 && (
          <form onSubmit={(e) => { e.preventDefault(); setStep(2); }} className="space-y-4">
            <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" required />
            <div>
              <Input label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Min 8 characters" required />
              {password.length > 0 && (
                <div className="mt-2">
                  <div className="h-1.5 bg-buddy-surface-raised rounded-full overflow-hidden">
                    <div className={`h-full transition-all duration-300 ${pwStrength.color}`} style={{ width: `${pwStrength.score}%` }} />
                  </div>
                  <p className="text-xs mt-1" style={{ color: pwStrength.color.replace('bg-', '#').replace('buddy-green', '00C896').replace('buddy-red', 'FF4757').replace('buddy-orange', 'FF6B35').replace('buddy-electric', '7B61FF') }}>{pwStrength.label}</p>
                </div>
              )}
            </div>
            <label className="flex items-start gap-2 text-sm text-buddy-text-secondary cursor-pointer">
              <input type="checkbox" checked={acceptedTerms} onChange={(e) => setAcceptedTerms(e.target.checked)} className="mt-1 rounded accent-buddy-green" />
              <span>I agree to the <Link to="/terms" className="text-buddy-green">Terms</Link>, <Link to="/privacy" className="text-buddy-green">Privacy</Link>, and <Link to="/community-guidelines" className="text-buddy-green">Community Guidelines</Link></span>
            </label>
            <label className="flex items-center gap-2 text-sm text-buddy-text-secondary cursor-pointer">
              <input type="checkbox" checked={accepted16} onChange={(e) => setAccepted16(e.target.checked)} className="rounded accent-buddy-green" />
              <span>I am 16 years of age or older</span>
            </label>
            <Button type="submit" disabled={!acceptedTerms || !accepted16 || !email || !password} className="w-full" size="lg">Continue</Button>
          </form>
        )}

        {step === 2 && (
          <form onSubmit={handleAgeCheck} className="space-y-4">
            <p className="text-sm text-buddy-text-secondary">Enter your date of birth to verify your age.</p>
            <div className="grid grid-cols-3 gap-3">
              <Input label="Day" type="number" min={1} max={31} value={dobDay} onChange={(e) => setDobDay(e.target.value)} placeholder="DD" required />
              <Input label="Month" type="number" min={1} max={12} value={dobMonth} onChange={(e) => setDobMonth(e.target.value)} placeholder="MM" required />
              <Input label="Year" type="number" value={dobYear} onChange={(e) => setDobYear(e.target.value)} placeholder="YYYY" required />
            </div>
            <p className="text-xs text-buddy-orange">BuddyUp is for users aged 16 and over. Underage accounts will be blocked.</p>
            <div className="flex gap-3">
              <Button variant="ghost" type="button" onClick={() => setStep(1)} className="flex-1">Back</Button>
              <Button type="submit" className="flex-1" size="lg">Verify Age</Button>
            </div>
          </form>
        )}

        {step === 3 && (
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input label="Username" value={username} onChange={(e) => setUsername(e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, ''))} placeholder="fitness_fan" helperText="3–30 characters, letters, numbers, underscores" required minLength={3} maxLength={30} />
            <Input label="Display Name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} placeholder="Your name or alias" required maxLength={50} />
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">I am a...</label>
              <div className="grid grid-cols-3 gap-2">
                {[
                  { value: 'user', label: 'Regular User', icon: Dumbbell },
                  { value: 'trainer', label: 'Trainer', icon: GraduationCap },
                  { value: 'practitioner', label: 'Health Pro', icon: Stethoscope },
                ].map(({ value, label, icon: Icon }) => (
                  <button key={value} type="button" onClick={() => setRole(value)} className={`p-3 rounded-xl border-2 text-center text-sm transition-colors ${role === value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface-raised hover:border-buddy-text-secondary/30'}`}>
                    <div className="mb-1 flex justify-center"><Icon size={20} className={role === value ? 'text-buddy-green' : 'text-buddy-text-secondary'} /></div>
                    <div className="font-medium text-xs">{label}</div>
                  </button>
                ))}
              </div>
              {role !== 'user' && <p className="mt-2 text-xs text-buddy-orange">Trainer & Practitioner accounts require verification. You'll start as a Regular User.</p>}
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" type="button" onClick={() => setStep(2)} className="flex-1">Back</Button>
              <Button type="submit" isLoading={isLoading} disabled={!username || !displayName} className="flex-1" size="lg">Create Account</Button>
            </div>
          </form>
        )}

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <p className="text-buddy-text-secondary">
            Already have an account? <Link to="/login" className="text-buddy-green font-semibold hover:text-buddy-green-deep">Log In</Link>
          </p>
        </div>
      </Card>
    </div>
  );
}
