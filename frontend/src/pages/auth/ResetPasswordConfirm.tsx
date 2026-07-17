import { useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { authApi } from '@/api';
import { getPasswordStrength } from '@/utils/passwordStrength';

export default function ResetPasswordConfirm() {
  const [searchParams] = useSearchParams();
  const email = searchParams.get('email') || '';

  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const pwStrength = getPasswordStrength(newPassword);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (newPassword !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setIsLoading(true);
    try {
      await authApi.resetPassword(otp, newPassword);
      setSuccess(true);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Reset failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
        <Card className="w-full max-w-md p-8 text-center bg-buddy-surface">
          <div className="w-16 h-16 rounded-full bg-buddy-green/10 flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-buddy-green" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" /></svg>
          </div>
          <h1 className="font-display text-2xl font-extrabold mb-2 text-buddy-green">Password Reset</h1>
          <p className="text-buddy-text-secondary mb-6">Your password has been reset successfully.</p>
          <p className="text-xs text-buddy-orange mb-4">If you had two-factor authentication enabled, it has been disabled for security. You can re-enable it from Settings after logging in.</p>
          <Link to="/login"><Button className="w-full">Log In</Button></Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <h1 className="font-display text-2xl font-extrabold text-center mb-2">
          Reset <span className="text-buddy-green">Password</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-6">
          Enter the OTP sent to {email ? <strong className="text-buddy-text-primary">{email}</strong> : 'your email'} and your new password.
        </p>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="OTP Code"
            value={otp}
            onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
            placeholder="000000"
            maxLength={6}
            required
          />
          <div>
            <Input
              label="New Password"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Min 8 characters"
              required
            />
            {newPassword.length > 0 && (
              <div className="mt-2">
                <div className="h-1.5 bg-buddy-surface-raised rounded-full overflow-hidden">
                  <div className={`h-full transition-all duration-300 ${pwStrength.color}`} style={{ width: `${pwStrength.score}%` }} />
                </div>
                <p className="text-xs mt-1" style={{ color: pwStrength.color.replace('bg-', '#').replace('buddy-green', '00C896').replace('buddy-red', 'FF4757').replace('buddy-orange', 'FF6B35').replace('buddy-electric', '7B61FF') }}>{pwStrength.label}</p>
              </div>
            )}
          </div>
          <Input
            label="Confirm Password"
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            placeholder="Repeat your password"
            required
          />
          <Button type="submit" isLoading={isLoading} disabled={!otp || !newPassword || newPassword !== confirmPassword} className="w-full" size="lg">
            Reset Password
          </Button>
        </form>

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <Link to="/login" className="text-buddy-text-secondary hover:text-buddy-green">Back to Login</Link>
        </div>
      </Card>
    </div>
  );
}
