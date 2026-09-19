import { useState, type FormEvent } from 'react';
import axios from 'axios';
import { BellRing, Check } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { joinWaitlist } from '@/api/waitlist';

export function WaitlistForm() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [message, setMessage] = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setMessage('');
    try {
      const [res] = await Promise.all([
        joinWaitlist({ email: email.trim(), name: name.trim() }),
        // Mirror to Google Sheet if webhook is configured (fire-and-forget, no-cors)
        (() => {
          const sheetsUrl = import.meta.env.VITE_GOOGLE_SHEETS_WEBHOOK_URL;
          if (!sheetsUrl) return Promise.resolve();
          const fd = new FormData();
          fd.append('name', name.trim());
          fd.append('email', email.trim());
          fd.append('source', 'landing');
          return fetch(sheetsUrl, { method: 'POST', mode: 'no-cors', body: fd }).catch(() => {});
        })(),
      ]);
      setMessage(res.message || 'You joined the waitlist.');
      setStatus('done');
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const errors = err.response?.data?.errors;
        const first = errors ? Object.values(errors).flat()[0] : null;
        setMessage(
          (typeof first === 'string' ? first : null)
          || err.response?.data?.message
          || 'Something went wrong. Please try again.',
        );
      } else {
        setMessage('Something went wrong. Please try again.');
      }
      setStatus('error');
    }
  }

  if (status === 'done') {
    return (
      <div className="flex items-start gap-3 bg-buddy-surface-raised rounded-2xl p-5" role="status">
        <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
          <Check size={20} className="text-buddy-green" />
        </span>
        <div>
          <p className="font-heading font-semibold">You&apos;re on the list</p>
          <p className="text-sm text-buddy-text-secondary">{message} We&apos;ll email you when it&apos;s your turn.</p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3" noValidate={false}>
      <div className="flex items-center gap-2 mb-1">
        <BellRing size={20} className="text-buddy-green" />
        <h3 className="font-heading font-semibold">Join the Waiting List</h3>
      </div>
      <p className="text-sm text-buddy-text-secondary">
        We launch in November 2026. Join the list and be first through the door.
      </p>
      <Input
        label="Name (optional)"
        type="text"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Alex"
        autoComplete="name"
      />
      <Input
        label="Email"
        type="email"
        required
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="you@example.com"
        autoComplete="email"
      />
      {status === 'error' && (
        <p className="text-sm text-red-500" role="alert">{message}</p>
      )}
      <Button type="submit" className="w-full" disabled={status === 'loading'}>
        {status === 'loading' ? 'Joining…' : 'Notify me'}
      </Button>
    </form>
  );
}
