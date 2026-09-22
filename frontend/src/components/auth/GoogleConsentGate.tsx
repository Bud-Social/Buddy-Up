import { Link } from 'react-router-dom';
import { Check } from 'lucide-react';
import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';

/**
 * Explicit data-access consent gate shown before a Google credential is ever
 * exchanged for a BuddyUp Fit session. Mirrors Google's sign-in scopes
 * (`openid profile email`) — nothing else is ever requested or read.
 */
const ACCESSED_ITEMS = [
  'Your Google email address — used as your BuddyUp Fit account ID and for security emails.',
  'Your full name — used to pre-fill your display name during onboarding.',
  'Your profile picture — used as your default avatar until you upload one.',
];

interface GoogleConsentGateProps {
  open: boolean;
  /** Whether the sign-in is creating a new account or returning to one. */
  mode?: 'login' | 'signup';
  isLoading?: boolean;
  onAllow: () => void;
  onCancel: () => void;
}

export function GoogleConsentGate({
  open,
  mode = 'login',
  isLoading = false,
  onAllow,
  onCancel,
}: GoogleConsentGateProps) {
  return (
    <Modal isOpen={open} onClose={onCancel} title="Before you continue…" size="sm">
      <p className="text-sm text-buddy-text-secondary mb-4">
        {mode === 'signup'
          ? 'To create your BuddyUp Fit account, we would like to access the following from your Google account:'
          : 'To sign you in, we would like to access the following from your Google account:'}
      </p>
      <ul className="space-y-2.5 mb-4">
        {ACCESSED_ITEMS.map((item) => (
          <li key={item} className="flex items-start gap-2 text-sm text-buddy-text-primary">
            <Check size={16} className="text-buddy-green mt-0.5 flex-shrink-0" />
            <span>{item}</span>
          </li>
        ))}
      </ul>
      <div className="bg-buddy-surface rounded-xl p-3 mb-4">
        <p className="text-xs text-buddy-text-secondary leading-relaxed">
          BuddyUp Fit only uses this information to create or sign in to your account. We never
          post, send, or read anything on your behalf, and we never touch your Google
          contacts, files, or calendar. This is the only data Google shares with us.
        </p>
        <p className="text-xs text-buddy-text-secondary mt-2">
          Sign-in scope: <span className="font-mono text-buddy-text-primary">openid, profile, email</span>
        </p>
      </div>
      <p className="text-xs text-buddy-text-secondary mb-4">
        How we handle this data is described in our{' '}
        <Link to="/privacy" className="text-buddy-green hover:underline" onClick={onCancel}>
          Privacy Policy
        </Link>
        .
      </p>
      <div className="flex gap-2">
        <Button variant="ghost" className="flex-1" onClick={onCancel} disabled={isLoading}>
          Cancel
        </Button>
        <Button className="flex-1" onClick={onAllow} isLoading={isLoading}>
          Allow &amp; continue
        </Button>
      </div>
    </Modal>
  );
}
