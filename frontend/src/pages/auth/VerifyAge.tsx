import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Logo } from '@/components/ui/Logo';
import { authApi } from '@/api/auth';
import { calculateAge } from '@/utils/ageCheck';

export default function VerifyAge() {
  const navigate = useNavigate();
  const location = useLocation();
  const params = new URLSearchParams(location.search);
  const redirectTo = params.get('redirect') || '/signup';

  const [day, setDay] = useState('');
  const [month, setMonth] = useState('');
  const [year, setYear] = useState('');
  const [error, setError] = useState('');
  const [, setIsLoading] = useState(false);

  const currentYear = new Date().getFullYear();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    const d = parseInt(day);
    const m = parseInt(month);
    const y = parseInt(year);

    if (!d || !m || !y || d < 1 || d > 31 || m < 1 || m > 12 || y < 1900 || y > currentYear) {
      setError('Please enter a valid date of birth.');
      setIsLoading(false);
      return;
    }

    const dob = new Date(y, m - 1, d);
    const age = calculateAge(dob);

    if (age < 16) {
      setError('BuddyUp is for users aged 16 and over. You cannot create an account at this time.');
      setIsLoading(false);
      return;
    }

    try {
      const dobStr = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      await authApi.verifyAge(dobStr);
      navigate(redirectTo);
    } catch {
      setError('Could not verify age. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8">
        <div className="flex justify-center mb-6">
          <Logo />
        </div>

        <h1 className="font-display text-3xl font-extrabold text-center mb-2">Age Verification</h1>
        <p className="text-buddy-text-secondary text-center mb-8">
          Please enter your date of birth to continue.
        </p>

        {error && (
          <div className="bg-buddy-red/10 border border-buddy-red/30 rounded-xl p-4 mb-6">
            <p className="text-buddy-red text-sm">{error}</p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div className="grid grid-cols-3 gap-3">
            <Input
              label="Day"
              placeholder="DD"
              value={day}
              onChange={(e) => setDay(e.target.value.replace(/\D/g, '').slice(0, 2))}
              maxLength={2}
            />
            <Input
              label="Month"
              placeholder="MM"
              value={month}
              onChange={(e) => setMonth(e.target.value.replace(/\D/g, '').slice(0, 2))}
              maxLength={2}
            />
            <Input
              label="Year"
              placeholder="YYYY"
              value={year}
              onChange={(e) => setYear(e.target.value.replace(/\D/g, '').slice(0, 4))}
              maxLength={4}
            />
          </div>

          <Button type="submit" className="w-full" size="lg">
            Verify & Continue
          </Button>
        </form>
      </Card>
    </div>
  );
}
