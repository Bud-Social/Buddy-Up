import { useState, useMemo, useCallback } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Dumbbell, GraduationCap, Stethoscope } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { getPasswordStrength } from '@/utils/passwordStrength';
import { calculateAge } from '@/utils/ageCheck';
import { authApi } from '@/api';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID as string | undefined;

function GoogleSignUpButton() {
  const handleClick = useCallback(() => {
    if (!window.google?.accounts?.oauth2) return;
    const client = window.google.accounts.oauth2.initTokenClient({
      client_id: GOOGLE_CLIENT_ID!,
      scope: 'openid profile email',
      callback: (response) => {
        if (response.id_token) {
          // TODO: handle Google registration
          window.location.href = `/signup?google_token=${encodeURIComponent(response.id_token)}`;
        }
      },
    });
    client.requestAccessToken();
  }, []);

  return (
    <button type="button" onClick={handleClick}
      className="w-full flex items-center justify-center gap-3 px-4 py-2.5 rounded-xl border border-buddy-surface-raised hover:bg-buddy-surface transition-colors text-sm font-medium text-buddy-text-primary"
    >
      <svg viewBox="0 0 24 24" className="w-5 h-5 shrink-0"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
      Sign up with Google
    </button>
  );
}

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

        <div className="space-y-3 mb-6">
          {GOOGLE_CLIENT_ID && <GoogleSignUpButton />}
          <div className="relative flex items-center gap-3">
            <div className="flex-1 border-t border-buddy-surface-raised" />
            <span className="text-xs text-buddy-text-secondary">or</span>
            <div className="flex-1 border-t border-buddy-surface-raised" />
          </div>
        </div>

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
