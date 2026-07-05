import { useState } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Shield } from 'lucide-react';
import { authApi } from '@/api';
import { useAuthStore } from '@/store/authStore';

export default function TotpChallenge() {
  const navigate = useNavigate();
  const location = useLocation();
  const setTokens = useAuthStore((s) => s.setTokens);
  const setUser = useAuthStore((s) => s.setUser);

  const tempToken = (location.state as { temp_token?: string })?.temp_token || '';

  const [code, setCode] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const res = await authApi.totpChallenge(tempToken, code);
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

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <Shield size={40} className="text-buddy-electric mx-auto mb-4" />
        <h1 className="font-display text-2xl font-extrabold text-center mb-2">
          Two-Factor <span className="text-buddy-electric">Authentication</span>
        </h1>
        <p className="text-buddy-text-secondary text-center mb-6">
          Enter the code from your authenticator app.
        </p>

        {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm mb-4">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Authenticator Code"
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
            placeholder="000000"
            maxLength={6}
            required
          />
          <Button type="submit" isLoading={isLoading} disabled={code.length !== 6} className="w-full" size="lg">
            Verify
          </Button>
        </form>

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <Link to="/login" className="text-buddy-text-secondary hover:text-buddy-green">
            Back to Login
          </Link>
        </div>
      </Card>
    </div>
  );
}
