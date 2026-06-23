import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement forgot password
    setSent(true);
  };

  if (sent) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
        <Card className="w-full max-w-md p-8 text-center bg-buddy-surface">
          <h1 className="font-display text-2xl font-extrabold mb-4 text-buddy-green">Check Your Email</h1>
          <p className="text-buddy-text-secondary">We've sent a password reset link to {email}</p>
          <Link to="/login" className="mt-6 inline-block text-buddy-green hover:text-buddy-green-deep">
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
        <p className="text-buddy-text-secondary text-center mb-8">Enter your email to receive a reset link</p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            required
          />
          <Button type="submit" className="w-full" size="lg">Send Reset Link</Button>
        </form>

        <div className="mt-6 pt-6 border-t border-buddy-surface-raised text-center text-sm">
          <Link to="/login" className="text-buddy-text-secondary hover:text-buddy-green">Back to Login</Link>
        </div>
      </Card>
    </div>
  );
}
