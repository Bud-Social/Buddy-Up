import { useState, type FormEvent } from 'react';
import axios from 'axios';
import { BellRing, Check } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { joinWaitlist } from '@/api/waitlist';
import { COUNTRIES } from '@/config/countries';
import { useVisitorCountry } from '@/hooks/useVisitorCountry';

export function WaitlistForm() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [country, setCountry] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [message, setMessage] = useState('');
  // Best-effort guess (Vercel geo header / browser locale) to pre-select
  // the country; the user can always change it and must confirm it.
  const visitorCountry = useVisitorCountry();
  const countryGuess = country || visitorCountry || '';

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setMessage('');
    try {
      // The signup is written by the same-origin Vercel function (api/waitlist.ts)
      // to Supabase, which also mirrors to Google Sheets server-side — the
      // webhook URL and service key are deliberately not in the client bundle.
      const res = await joinWaitlist({
        email: email.trim(),
        name: name.trim(),
        country: countryGuess,
      });
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
        We are launching in November. Join the list and be first through the door.
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
      <div className="w-full">
        <label
          htmlFor="waitlist-country"
          className="block text-sm font-medium text-buddy-text-secondary mb-1.5"
        >
          Country
        </label>
        <select
          id="waitlist-country"
          required
          value={countryGuess}
          onChange={(e) => setCountry(e.target.value)}
          className={`w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent ${COUNTRIES.includes(countryGuess) ? '' : 'text-buddy-text-secondary/50'}`}
        >
          <option value="" disabled>
            Select your country…
          </option>
          {COUNTRIES.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </div>
      {status === 'error' && (
        <p className="text-sm text-red-500" role="alert">{message}</p>
      )}
      <Button type="submit" className="w-full" disabled={status === 'loading'}>
        {status === 'loading' ? 'Joining…' : 'Notify me'}
      </Button>
    </form>
  );
}
