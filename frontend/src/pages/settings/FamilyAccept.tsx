import { useState } from 'react';
import { Navigate, useNavigate, useSearchParams } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { guardiansApi } from '@/api';
import { SectionShell } from './SectionShell';

/** Public guardian-invite landing (/settings/family/accept?token=…).
 * Logged-out visitors are sent to /login?next=<this URL> so the token
 * survives the round-trip; logged-in users set the teen password here. */
export default function FamilyAccept() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [searchParams] = useSearchParams();

  const token = searchParams.get('token') || '';
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [done, setDone] = useState(false);

  if (!isAuthenticated) {
    const next = `/settings/family/accept${token ? `?token=${encodeURIComponent(token)}` : ''}`;
    return <Navigate to={`/login?next=${encodeURIComponent(next)}`} replace />;
  }

  if (!token) {
    return (
      <SectionShell title="Accept Family Invite">
        <Card className="p-6 text-center">
          <p className="text-sm text-buddy-red mb-2">This invite link is missing its token.</p>
          <Button size="sm" variant="outline" onClick={() => navigate('/settings/family')}>Back to Family</Button>
        </Card>
      </SectionShell>
    );
  }

  const handleAccept = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (password.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }
    if (password !== confirm) {
      setError('Passwords do not match.');
      return;
    }
    setSubmitting(true);
    try {
      await guardiansApi.acceptInvite(token, password);
      setDone(true);
      toast('success', 'Invite accepted — your account is ready.');
      setTimeout(() => navigate('/settings/family'), 1200);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Invalid or expired invite link.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <SectionShell title="Accept Family Invite">
      <Card className="p-6">
        {done ? (
          <p className="text-sm text-buddy-green text-center">Invite accepted! Taking you to Family settings…</p>
        ) : (
          <>
            <p className="text-sm text-buddy-text-secondary mb-4">
              Welcome to BuddyUp Fit! Set a password to activate the account linked to your guardian.
            </p>
            <form onSubmit={handleAccept} className="space-y-3">
              {error && (
                <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm">{error}</div>
              )}
              <Input type="password" label="New password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="At least 8 characters" required />
              <Input type="password" label="Confirm password" value={confirm} onChange={(e) => setConfirm(e.target.value)} placeholder="Repeat your password" required />
              <Button type="submit" className="w-full" size="lg" isLoading={submitting}>Accept Invite</Button>
            </form>
          </>
        )}
      </Card>
    </SectionShell>
  );
}
