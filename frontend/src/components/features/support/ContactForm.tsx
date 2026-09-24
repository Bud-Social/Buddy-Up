import { useState, type FormEvent } from 'react';
import axios from 'axios';
import { Check, Mail } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { submitContact } from '@/api/contact';
import { CONTACT_EMAILS, mailtoLink } from '@/config/contact';

const TOPICS = [
  { value: 'general', label: 'General' },
  { value: 'support', label: 'Support' },
  { value: 'gyms', label: 'Gyms & Partnerships' },
  { value: 'trainers', label: 'Trainers' },
  { value: 'press', label: 'Press' },
];

export function ContactForm() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [topic, setTopic] = useState('general');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [error, setError] = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setError('');
    try {
      await submitContact({
        name: name.trim(),
        email: email.trim(),
        topic,
        subject: subject.trim() || undefined,
        message: message.trim(),
      });
      setStatus('done');
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const errors = err.response?.data?.errors;
        const first = errors ? Object.values(errors).flat()[0] : null;
        setError(
          (typeof first === 'string' ? first : null)
          || err.response?.data?.message
          || 'Something went wrong. Please try again.',
        );
      } else {
        setError('Something went wrong. Please try again.');
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
          <p className="font-heading font-semibold">Message received</p>
          <p className="text-sm text-buddy-text-secondary">
            Thanks for reaching out — we reply within two business days.
          </p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3 text-left">
      <div className="flex items-center gap-2 mb-1">
        <Mail size={18} className="text-buddy-green" />
        <h3 className="font-heading font-semibold text-sm">Send us a message</h3>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Name"
          type="text"
          required
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
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="w-full">
          <label htmlFor="contact-topic" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
            Topic
          </label>
          <select
            id="contact-topic"
            value={topic}
            onChange={(e) => setTopic(e.target.value)}
            className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
          >
            {TOPICS.map((t) => (
              <option key={t.value} value={t.value}>{t.label}</option>
            ))}
          </select>
        </div>
        <Input
          label="Subject (optional)"
          type="text"
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
          placeholder="Quick summary"
          maxLength={120}
        />
      </div>
      <div className="w-full">
        <label htmlFor="contact-message" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
          Message
        </label>
        <textarea
          id="contact-message"
          required
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="How can we help?"
          rows={3}
          maxLength={2000}
          className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none min-h-touch"
        />
      </div>
      {status === 'error' && (
        <p className="text-sm text-red-500" role="alert">
          {error}{' '}
          <a href={mailtoLink('direct', `Contact form — ${topic}`)} className="underline hover:no-underline">
            Or email us directly at {CONTACT_EMAILS.direct}
          </a>
        </p>
      )}
      <Button type="submit" className="w-full" disabled={status === 'loading'}>
        {status === 'loading' ? 'Sending…' : 'Send message'}
      </Button>
    </form>
  );
}
