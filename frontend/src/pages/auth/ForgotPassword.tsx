import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { authApi } from '@/api';

export default function ForgotPassword() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      await authApi.forgotPassword(email);
      setSent(true);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Something went wrong. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (sent) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
        <Card className="w-full max-w-md p-8 text-center bg-buddy-surface">
          <h1 className="font-display text-2xl font-extrabold mb-4 text-buddy-green">Check Your Email</h1>
          <p className="text-buddy-text-secondary mb-6">
            We've sent a password reset OTP to <strong className="text-buddy-text-primary">{email}</strong>.
            Please check your inbox and use the code to reset your password.
          </p>
          <Button className="w-full mb-3" onClick={() => navigate(`/reset-password?email=${encodeURIComponent(email)}`)}>
            Enter Reset Code
          </Button>
          <Link to="/login" className="block text-sm text-buddy-green hover:text-buddy-green-deep">
            Back to Login
          </Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <h1 className="font-display text-3xl font-extrabold text-center mb-2">
          Forgot <span className="text-buddy-green">Password</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-8">Enter your email to receive a reset OTP code</p>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            required
          />
          <Button type="submit" isLoading={isLoading} className="w-full" size="lg">Send Reset OTP</Button>
        </form>

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <Link to="/login" className="text-buddy-text-secondary hover:text-buddy-green">Back to Login</Link>
        </div>
      </Card>
    </div>
  );
}
