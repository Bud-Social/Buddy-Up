import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { authApi } from '@/api';
import { useAuthStore } from '@/store/authStore';

export default function VerifyRegistrationOtp() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const setTokens = useAuthStore((s) => s.setTokens);
  const setUser = useAuthStore((s) => s.setUser);

  const regToken = searchParams.get('token') || '';
  const email = searchParams.get('email') || '';

  const [otp, setOtp] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [resending, setResending] = useState(false);
  const [cooldown, setCooldown] = useState(0);

  useEffect(() => {
    if (cooldown > 0) {
      const t = setInterval(() => setCooldown((c) => c - 1), 1000);
      return () => clearInterval(t);
    }
  }, [cooldown]);

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.verifyRegistrationOtp(regToken, otp);
      setTokens(res.data.access, res.data.refresh);
      setUser(res.data.user, res.data.profile);
      navigate('/onboarding');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Verification failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResend = async () => {
    setResending(true);
    try {
      await authApi.resendOtp('email');
      setCooldown(60);
    } catch {
      setError('Failed to resend OTP. Please try again.');
    } finally {
      setResending(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Verify Your <span className="text-buddy-green">Email</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-6">
          Enter the 6-digit code sent to <strong className="text-buddy-text-primary">{email}</strong>
        </p>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        <form onSubmit={handleVerify} className="space-y-4">
          <Input
            label="OTP Code"
            value={otp}
            onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
            placeholder="000000"
            maxLength={6}
            required
            helperText="Check your email for the 6-digit code"
          />
          <Button type="submit" isLoading={isLoading} disabled={otp.length !== 6} className="w-full" size="lg">
            Verify Email
          </Button>
        </form>

        <div className="mt-4 text-center">
          <button
            onClick={handleResend}
            disabled={cooldown > 0 || resending}
            className="text-sm text-buddy-green hover:text-buddy-green-deep disabled:text-buddy-text-secondary/50 disabled:cursor-not-allowed"
          >
            {cooldown > 0 ? `Resend in ${cooldown}s` : resending ? 'Sending...' : 'Resend OTP'}
          </button>
        </div>

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <Link to="/login" className="text-buddy-text-secondary hover:text-buddy-green">
            Back to Login
          </Link>
        </div>
      </Card>
    </div>
  );
}
