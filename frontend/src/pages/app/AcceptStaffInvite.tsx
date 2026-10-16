import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ShieldCheck, MailWarning, CheckCircle2, Clock } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { adminPortalApi, adminPortalErrorMessage } from '@/api/adminPortal';
import { useAuthStore } from '@/store/authStore';

/**
 * The public face of staff onboarding.
 *
 * Three states, and the distinction matters: a *live* invitation that this
 * browser is signed in as the invited address can be claimed; a live invitation
 * for a different address can be read but not claimed; a dead one explains
 * itself. Collapsing these into one "invalid" screen would leave a real new hire
 * with no idea whether the problem is the link, the expiry, or signing in as the
 * wrong person.
 *
 * The accept call itself enforces the email match server-side. This screen only
 * decides what to *offer*, so a mismatch cannot be talked around here.
 */
type State =
  | { kind: 'loading' }
  | { kind: 'unusable'; message: string }
  | { kind: 'live'; email: string; role: string; roleDisplay: string; invitedBy: string | null }
  | { kind: 'wrong-account'; email: string; roleDisplay: string; signedInAs: string }
  | { kind: 'claimed'; roleDisplay: string };

export default function AcceptStaffInvite() {
  const { token } = useParams<{ token: string }>();
  const navigate = useNavigate();
  const { user, isAuthenticated } = useAuthStore();

  const [state, setState] = useState<State>({ kind: 'loading' });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const signedInAs = user?.email ?? null;

  const load = useCallback(async () => {
    if (!token) {
      setState({ kind: 'unusable', message: 'This link is missing its invitation code.' });
      return;
    }
    setState({ kind: 'loading' });
    try {
      const res = await adminPortalApi.getStaffInvitationPreview(token);
      const data = res.data;
      if (!data?.is_live) {
        const why =
          data?.status === 'expired'
            ? 'This invitation has expired. Ask whoever invited you for a new one.'
            : data?.status === 'revoked'
              ? 'This invitation was withdrawn.'
              : data?.status === 'accepted'
                ? 'This invitation has already been used.'
                : 'This invitation is no longer valid.';
        setState({ kind: 'unusable', message: why });
        return;
      }

      const roleDisplay = data.role_display || data.role;
      if (!isAuthenticated) {
        setState({ kind: 'live', email: data.email, role: data.role, roleDisplay, invitedBy: data.invited_by ?? null });
        return;
      }
      if ((signedInAs || '').toLowerCase() !== data.email.toLowerCase()) {
        setState({ kind: 'wrong-account', email: data.email, roleDisplay, signedInAs: signedInAs || 'your account' });
        return;
      }
      setState({ kind: 'live', email: data.email, role: data.role, roleDisplay, invitedBy: data.invited_by ?? null });
    } catch (e: unknown) {
      setState({
        kind: 'unusable',
        message: adminPortalErrorMessage(e, 'This invitation link could not be read.'),
      });
    }
  }, [token, isAuthenticated, signedInAs]);

  useEffect(() => { load(); }, [load]);

  const accept = async () => {
    if (!token) return;
    setBusy(true);
    setError(null);
    try {
      await adminPortalApi.acceptStaffInvitation(token);
      setState((prev) =>
        prev.kind === 'live' ? { kind: 'claimed', roleDisplay: prev.roleDisplay } : prev,
      );
    } catch (e: unknown) {
      setError(adminPortalErrorMessage(e, 'Could not accept this invitation.'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="min-h-screen bg-buddy-bg flex items-center justify-center p-6">
      <Card className="w-full max-w-md p-6 space-y-4">
        <div className="flex items-center gap-2">
          <ShieldCheck className="text-buddy-green" size={22} />
          <h1 className="font-display text-lg font-extrabold">Staff invitation</h1>
        </div>

        {state.kind === 'loading' && (
          <p className="text-sm text-buddy-text-secondary">Checking this invitation…</p>
        )}

        {state.kind === 'unusable' && (
          <div className="space-y-3">
            <div className="flex items-start gap-2 text-sm text-buddy-orange">
              <MailWarning size={16} className="mt-0.5 shrink-0" />
              <p>{state.message}</p>
            </div>
            <Button variant="ghost" onClick={() => navigate('/feed')}>Go to Buddy Up</Button>
          </div>
        )}

        {state.kind === 'wrong-account' && (
          <div className="space-y-3">
            <p className="text-sm text-buddy-text-secondary">
              You are signed in as <strong>{state.signedInAs}</strong>, but this
              invitation was sent to <strong>{state.email}</strong>.
            </p>
            <p className="text-xs text-buddy-text-secondary">
              Sign out and sign back in with the invited address to accept it. This
              check is what stops a forwarded link from granting the wrong person
              access.
            </p>
            <Button variant="ghost" onClick={() => navigate('/login')}>Sign in again</Button>
          </div>
        )}

        {state.kind === 'live' && (
          <div className="space-y-3">
            <p className="text-sm text-buddy-text-secondary">
              You have been invited to administer Buddy Up as
            </p>
            <div className="flex items-center gap-2">
              <Badge variant="gold" label={state.roleDisplay} />
            </div>
            <p className="text-xs text-buddy-text-secondary">
              Invited for <strong>{state.email}</strong>
              {state.invitedBy ? <> by {state.invitedBy}</> : null}.
            </p>

            {!isAuthenticated && (
              <p className="text-xs text-buddy-text-secondary">
                Create your account with this email address, then come back to this
                link to finish. Your access is not active until you do.
              </p>
            )}

            {error && (
              <div className="bg-buddy-orange/10 border border-buddy-orange/20 text-buddy-orange text-xs rounded-xl px-3 py-2">
                {error}
              </div>
            )}

            {isAuthenticated ? (
              <Button className="w-full" isLoading={busy} onClick={accept}>
                Accept and open the console
              </Button>
            ) : (
              <div className="flex flex-col gap-2">
                <Button
                  className="w-full"
                  onClick={() => navigate(`/signup?email=${encodeURIComponent(state.email)}`)}
                >
                  Create the account
                </Button>
                <Button variant="ghost" onClick={() => navigate('/login')}>
                  I already have an account
                </Button>
              </div>
            )}
          </div>
        )}

        {state.kind === 'claimed' && (
          <div className="space-y-3">
            <div className="flex items-start gap-2 text-sm text-buddy-green">
              <CheckCircle2 size={16} className="mt-0.5 shrink-0" />
              <p>Your {state.roleDisplay} access is active.</p>
            </div>
            <p className="text-xs text-buddy-text-secondary flex items-center gap-1.5">
              <Clock size={12} />
              The admin console is now available to you.
            </p>
            <Button className="w-full" onClick={() => navigate('/admin')}>
              Open the admin console
            </Button>
          </div>
        )}
      </Card>
    </div>
  );
}