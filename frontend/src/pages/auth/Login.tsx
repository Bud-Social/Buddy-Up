import { useState, useCallback } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Shield } from 'lucide-react';
import { useAuthStore } from '@/store/authStore';
import { authApi } from '@/api';
import { GoogleAuthButton } from '@/components/auth/GoogleAuthButton';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID as string | undefined;

type LoginStep = 'credentials' | 'otp' | 'totp';

export default function Login() {
  const navigate = useNavigate();
  const setTokens = useAuthStore((s) => s.setTokens);
  const setUser = useAuthStore((s) => s.setUser);

  const [step, setStep] = useState<LoginStep>('credentials');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [loginToken, setLoginToken] = useState('');
  const [tempToken, setTempToken] = useState('');
  const [maskedEmail, setMaskedEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [totpCode, setTotpCode] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleCredentialsSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.login({ email, password, remember_me: rememberMe });
      setLoginToken(res.data.login_token);
      setMaskedEmail(res.data.masked_email);
      setStep('otp');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string; data?: { registration_token?: string; email?: string; require_email_verification?: boolean; otp_resent?: boolean } } } })?.response?.data;
      if (data?.data?.require_email_verification && data?.data?.registration_token) {
        // Send the user straight to OTP verification — the notice about the
        // unverified account shows there, not here.
        const fresh = data.data.otp_resent !== false;
        navigate(`/verify-registration-otp?token=${encodeURIComponent(data.data.registration_token)}&email=${encodeURIComponent(data.data.email || email)}&reason=unverified${fresh ? '&fresh=1' : ''}`);
        return;
      }
      setError(data?.message || 'Invalid email or password.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleOtpSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.verifyLoginOtp(loginToken, otp, rememberMe);
      const data = res.data as { require_totp?: boolean; temp_token?: string; access?: string; refresh?: string; user?: import('@/types').User; profile?: import('@/types').Profile };
      if (data.require_totp) {
        setTempToken(data.temp_token || '');
        setStep('totp');
      } else {
        setTokens(data.access!, data.refresh!);
        setUser(data.user!, data.profile!);
        navigate('/feed');
      }
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Verification failed.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleTotpSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.totpChallenge(tempToken, totpCode);
      setTokens(res.data.access, res.data.refresh);
      setUser(res.data.user, res.data.profile);
      navigate('/feed');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Invalid code. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleGoogleSuccess = useCallback(async (credential: string) => {
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.googleLogin(credential);
      const data = res.data as typeof res.data & { require_totp?: boolean; temp_token?: string; require_age_setup?: boolean };
      if (data.require_totp && data.temp_token) {
        setTempToken(data.temp_token);
        setStep('totp');
        return;
      }
      setTokens(res.data.access, res.data.refresh);
      setUser(res.data.user, res.data.profile);
      // New social accounts must complete age verification before mature content.
      if (data.require_age_setup) {
        navigate('/onboarding?step=age');
      } else if ((res.data as { onboarding_required?: boolean }).onboarding_required) {
        navigate('/onboarding');
      } else {
        navigate('/feed');
      }
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string; data?: { registration_token?: string; email?: string; require_email_verification?: boolean; otp_resent?: boolean } } } })?.response?.data;
      if (data?.data?.require_email_verification && data?.data?.registration_token) {
        const fresh = data.data.otp_resent !== false;
        navigate(`/verify-registration-otp?token=${encodeURIComponent(data.data.registration_token)}&email=${encodeURIComponent(data.data.email || email)}&reason=unverified${fresh ? '&fresh=1' : ''}`);
        return;
      }
      setError(data?.message || 'Google login failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  }, [setTokens, setUser, navigate]);

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        {step === 'credentials' && (
          <>
            <h1 className="font-display text-3xl font-extrabold text-center mb-2">
              Welcome <span className="text-buddy-green">Back</span>
            </h1>
            <p className="text-buddy-text-secondary text-center mb-8">Log in to your BuddyUp account</p>

            <form onSubmit={handleCredentialsSubmit} className="space-y-4">
              {error && (
                <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm">{error}</div>
              )}
              <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" required />
              <Input label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Enter your password" required />
              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center gap-2 text-buddy-text-secondary cursor-pointer">
                  <input type="checkbox" checked={rememberMe} onChange={(e) => setRememberMe(e.target.checked)} className="rounded accent-buddy-green" />
                  Remember this device
                </label>
                <Link to="/forgot-password" className="text-buddy-green hover:text-buddy-green-deep">Forgot password?</Link>
              </div>
              <Button type="submit" isLoading={isLoading} className="w-full" size="lg">Log In</Button>
            </form>

            <div className="mt-6 pt-6 border-t border-buddy-surface-raised space-y-3">
              {GOOGLE_CLIENT_ID ? (
                <GoogleAuthButton label="Continue with Google" onSuccess={handleGoogleSuccess} onError={setError} />
              ) : (
                <button type="button" disabled
                  className="w-full flex items-center justify-center gap-3 px-4 py-2.5 rounded-xl border border-buddy-surface-raised text-sm font-medium text-buddy-text-secondary opacity-50 cursor-not-allowed"
                >
                  <svg viewBox="0 0 24 24" className="w-5 h-5"><path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"/><path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                  Continue with Google
                </button>
              )}
              <div className="relative flex items-center gap-3 py-1">
                <div className="flex-1 border-t border-buddy-surface-raised" />
                <span className="text-xs text-buddy-text-secondary">or</span>
                <div className="flex-1 border-t border-buddy-surface-raised" />
              </div>
              <p className="text-center text-sm text-buddy-text-secondary">
                Don't have an account? <Link to="/signup" className="text-buddy-green font-semibold hover:text-buddy-green-deep">Sign Up</Link>
              </p>
            </div>
          </>
        )}

        {step === 'otp' && (
          <>
            <h1 className="font-display text-2xl font-extrabold text-center mb-2">
              Verify <span className="text-buddy-green">Login</span>
            </h1>
            <p className="text-buddy-text-secondary text-center mb-6">
              Enter the code sent to <strong className="text-buddy-text-primary">{maskedEmail}</strong>
            </p>

            {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

            <form onSubmit={handleOtpSubmit} className="space-y-4">
              <Input
                label="OTP Code"
                value={otp}
                onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="000000"
                maxLength={6}
                required
              />
              <Button type="submit" isLoading={isLoading} disabled={otp.length !== 6} className="w-full" size="lg">
                Verify
              </Button>
            </form>

            <div className="mt-4 text-center">
              <button onClick={() => { setStep('credentials'); setError(''); }} className="text-sm text-buddy-text-secondary hover:text-buddy-green">
                Back to Login
              </button>
            </div>
          </>
        )}

        {step === 'totp' && (
          <>
            <Shield size={40} className="text-buddy-electric mx-auto mb-4" />
            <h1 className="font-display text-2xl font-extrabold text-center mb-2">
              Two-Factor <span className="text-buddy-electric">Auth</span>
            </h1>
            <p className="text-buddy-text-secondary text-center mb-6">
              Enter the code from your authenticator app.
            </p>

            {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

            <form onSubmit={handleTotpSubmit} className="space-y-4">
              <Input
                label="Authenticator Code"
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="000000"
                maxLength={6}
                required
              />
              <Button type="submit" isLoading={isLoading} disabled={totpCode.length !== 6} className="w-full" size="lg">
                Verify
              </Button>
            </form>
          </>
        )}
      </Card>
    </div>
  );
}
