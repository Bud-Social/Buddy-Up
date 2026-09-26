import { useState, type FormEvent } from 'react';
import axios from 'axios';
import { Briefcase, Check, MapPin } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Navbar } from '@/components/landing/Navbar';
import { submitCareer } from '@/api/contact';

const ROLES = [
  {
    title: 'Founding Mobile Engineer',
    location: 'Nairobi · Hybrid',
    type: 'Full-time',
    desc: 'Own the BuddyUp Fit mobile experience end to end — ship the PWA and native apps our community trains with daily.',
    points: ['React Native / Flutter shipped to stores', 'Offline-first thinking', 'Product-minded, fast loops'],
  },
  {
    title: 'Backend Engineer (Django)',
    location: 'Nairobi · Hybrid',
    type: 'Full-time',
    desc: 'Scale the APIs behind gyms, lives, bookings, and wallets — reliability first, millions of check-ins later.',
    points: ['Django + Postgres in production', 'Celery, WebSockets, payments', 'You write the tests you ship'],
  },
  {
    title: 'Community & Gym Partnerships Lead',
    location: 'Nairobi · On the ground',
    type: 'Full-time',
    desc: 'Sign the gyms, onboard the coaches, and grow the fitness family across Kenya — our most human role.',
    points: ['Deep Nairobi fitness network', 'Partner onboarding & success', 'Events and launch activations'],
  },
  {
    title: 'Content & Social Lead',
    location: 'Remote · Kenya hours',
    type: 'Full-time',
    desc: 'Turn every workout, trainer story, and gym visit into content the whole country wants to watch.',
    points: ['Short-form native (TikTok/Reels)', 'Sports/fitness fluency', 'Analytics over vanity metrics'],
  },
];

const VALUES = [
  'Consistency over intensity — in product and in people.',
  'Free where it matters. The buddy system never goes behind a paywall.',
  'Verified, not anonymous. Trust is the product.',
  'Built where it\u2019s used — Nairobi first, then the world.',
];

export default function Careers() {
  const [role, setRole] = useState(ROLES[0].title);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [portfolioUrl, setPortfolioUrl] = useState('');
  const [resumeFile, setResumeFile] = useState<File | null>(null);
  const [message, setMessage] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [error, setError] = useState('');

  const MAX_RESUME_BYTES = 5 * 1024 * 1024;

  function readFileAsBase64(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = typeof reader.result === 'string' ? reader.result : '';
        resolve(result.includes(',') ? result.split(',')[1] : result);
      };
      reader.onerror = () => reject(new Error('unreadable'));
      reader.readAsDataURL(file);
    });
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setError('');
    try {
      let resume: { name: string; type: string; data: string } | undefined;
      if (resumeFile) {
        if (resumeFile.size > MAX_RESUME_BYTES) {
          setError('Resume must be under 5MB.');
          setStatus('error');
          return;
        }
        resume = {
          name: resumeFile.name,
          type: resumeFile.type,
          data: await readFileAsBase64(resumeFile),
        };
      }
      await submitCareer({
        name: name.trim(),
        email: email.trim(),
        role,
        portfolio_url: portfolioUrl.trim() || undefined,
        resume,
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

  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      <Navbar />
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-4xl mx-auto px-6 pt-28 pb-12 text-center relative z-10">
          <Briefcase size={44} className="mx-auto text-buddy-green mb-5" />
          <h1 className="font-display text-4xl sm:text-5xl font-extrabold text-white mb-5 leading-tight">
            Help a million people find their<br />
            <span className="text-buddy-green">fitness family.</span>
          </h1>
          <p className="text-lg text-buddy-text-secondary max-w-2xl mx-auto leading-relaxed">
            We&apos;re building the app that makes consistency social. Come build it with us —
            from Nairobi, for Kenya first, then the world.
          </p>
        </div>
      </header>

      <section className="max-w-4xl mx-auto px-6 py-10">
        <div className="grid sm:grid-cols-2 gap-3">
          {VALUES.map((v) => (
            <div key={v} className="flex items-start gap-2 text-sm text-buddy-text-secondary">
              <Check size={16} className="text-buddy-green mt-0.5 flex-shrink-0" />
              <span>{v}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="max-w-4xl mx-auto px-6 py-10">
        <h2 className="font-display text-2xl font-extrabold mb-6">Open roles</h2>
        <div className="space-y-4">
          {ROLES.map((r) => (
            <Card key={r.title} className="p-6 bg-buddy-surface">
              <div className="flex flex-wrap items-start justify-between gap-3 mb-2">
                <h3 className="font-heading text-lg font-semibold">{r.title}</h3>
                <span className="text-[11px] font-semibold uppercase tracking-wide border border-buddy-green/30 bg-buddy-green/10 text-buddy-green rounded-full px-2.5 py-1">
                  {r.type}
                </span>
              </div>
              <p className="flex items-center gap-1.5 text-xs text-buddy-text-secondary mb-3">
                <MapPin size={12} /> {r.location}
              </p>
              <p className="text-sm text-buddy-text-secondary mb-4">{r.desc}</p>
              <ul className="space-y-1.5 mb-5">
                {r.points.map((p) => (
                  <li key={p} className="flex items-start gap-2 text-sm">
                    <Check size={14} className="text-buddy-green mt-0.5 flex-shrink-0" />
                    <span>{p}</span>
                  </li>
                ))}
              </ul>
              <Button
                variant="outline"
                onClick={() => {
                  setRole(r.title);
                  setStatus('idle');
                  document.getElementById('career-apply')?.scrollIntoView({ behavior: 'smooth' });
                }}
              >
                Apply for this role
              </Button>
            </Card>
          ))}
        </div>
      </section>

      <section id="career-apply" className="max-w-2xl mx-auto px-6 py-10 scroll-mt-16">
        <Card className="p-6 sm:p-8 bg-buddy-surface">
          {status === 'done' ? (
            <div className="flex items-start gap-3" role="status">
              <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                <Check size={20} className="text-buddy-green" />
              </span>
              <div>
                <p className="font-heading font-semibold">Application received</p>
                <p className="text-sm text-buddy-text-secondary">
                  Thanks for applying — we reply to shortlisted candidates.
                </p>
              </div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-3 text-left">
              <h3 className="font-heading text-xl font-semibold">Apply now</h3>
              <div className="w-full">
                <label htmlFor="career-role" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                  Role
                </label>
                <select
                  id="career-role"
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                  className="w-full appearance-none bg-buddy-black border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
                >
                  {ROLES.map((r) => (
                    <option key={r.title} value={r.title}>{r.title}</option>
                  ))}
                </select>
              </div>
              <div className="grid sm:grid-cols-2 gap-3">
                <Input label="Full name" type="text" required value={name} onChange={(e) => setName(e.target.value)} placeholder="Wanjiku Mwangi" autoComplete="name" />
                <Input label="Email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" autoComplete="email" />
              </div>
              <Input label="Portfolio / LinkedIn / GitHub (optional)" type="url" value={portfolioUrl} onChange={(e) => setPortfolioUrl(e.target.value)} placeholder="https://…" />
              <div className="w-full">
                <label htmlFor="career-resume" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                  Resume (PDF or Word, max 5MB, optional)
                </label>
                <input
                  id="career-resume"
                  type="file"
                  accept=".pdf,.doc,.docx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  onChange={(e) => setResumeFile(e.target.files?.[0] ?? null)}
                  className="w-full bg-buddy-black border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-secondary file:mr-3 file:rounded-lg file:border-0 file:bg-buddy-green/15 file:px-3 file:py-1.5 file:text-sm file:font-medium file:text-buddy-green focus:outline-none focus:ring-2 focus:ring-buddy-green/30 min-h-touch"
                />
                {resumeFile && (
                  <p className="text-xs text-buddy-text-secondary mt-1.5">
                    Attached: {resumeFile.name} ({Math.round(resumeFile.size / 1024)} KB)
                  </p>
                )}
              </div>
              <div className="w-full">
                <label htmlFor="career-message" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                  Why you? (cover note)
                </label>
                <textarea
                  id="career-message"
                  required
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Your experience, your fitness story, why BuddyUp Fit…"
                  rows={4}
                  maxLength={2000}
                  className="w-full bg-buddy-black border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none min-h-touch"
                />
              </div>
              {status === 'error' && (
                <p className="text-sm text-red-500" role="alert">{error}</p>
              )}
              <Button type="submit" className="w-full" disabled={status === 'loading'}>
                {status === 'loading' ? 'Sending…' : 'Submit application'}
              </Button>
            </form>
          )}
        </Card>
      </section>
    </div>
  );
}
