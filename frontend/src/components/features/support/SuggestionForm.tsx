import { useState, type FormEvent } from 'react';
import axios from 'axios';
import { Check, Lightbulb } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { submitSuggestion } from '@/api/contact';

const CATEGORIES = [
  { value: 'gyms', label: 'Gyms' },
  { value: 'trainers', label: 'Trainers & Coaches' },
  { value: 'events', label: 'Events' },
  { value: 'programmes', label: 'Programmes' },
  { value: 'analytics', label: 'Activity Analytics' },
  { value: 'app', label: 'App Experience' },
  { value: 'other', label: 'Other' },
];

export function SuggestionForm({ onDone }: { onDone?: () => void }) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('other');
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [message, setMessage] = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setMessage('');
    try {
      const res = await submitSuggestion({
        title: title.trim(),
        description: description.trim(),
        category,
        email: email.trim() || undefined,
      });
      setMessage(res.message || 'Thanks — your suggestion is in.');
      setStatus('done');
      onDone?.();
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
          <p className="font-heading font-semibold">Suggestion received</p>
          <p className="text-sm text-buddy-text-secondary">{message}</p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3 text-left">
      <div className="flex items-center gap-2 mb-1">
        <Lightbulb size={20} className="text-buddy-green" />
        <h3 className="font-heading font-semibold">Suggest a feature</h3>
      </div>
      <Input
        label="What should we build?"
        type="text"
        required
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="e.g. Corporate step challenges"
        maxLength={120}
      />
      <div className="w-full">
        <label htmlFor="suggest-description" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
          Tell us more
        </label>
        <textarea
          id="suggest-description"
          required
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Who is it for, and what would it unlock?"
          rows={3}
          maxLength={2000}
          className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none min-h-touch"
        />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="w-full">
          <label htmlFor="suggest-category" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
            Area
          </label>
          <select
            id="suggest-category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
          >
            {CATEGORIES.map((c) => (
              <option key={c.value} value={c.value}>{c.label}</option>
            ))}
          </select>
        </div>
        <Input
          label="Email (optional)"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
        />
      </div>
      {status === 'error' && (
        <p className="text-sm text-red-500" role="alert">{message}</p>
      )}
      <Button type="submit" className="w-full" disabled={status === 'loading'}>
        {status === 'loading' ? 'Sending…' : 'Send suggestion'}
      </Button>
    </form>
  );
}
