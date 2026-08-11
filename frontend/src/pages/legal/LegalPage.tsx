import type { ReactNode } from 'react';

interface LegalPageProps {
  title: string;
  subtitle?: string;
  updatedAt?: string;
  children: ReactNode;
}

/**
 * Shared shell for BuddyUp legal / policy pages.
 * Keeps typography, spacing, and the "last updated" header consistent so the
 * Terms, Privacy, Guidelines, Cookie, Medical Disclaimer and Sponsorship pages
 * all render as a coherent set.
 */
export default function LegalPage({ title, subtitle, updatedAt, children }: LegalPageProps) {
  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-3xl mx-auto px-6 py-16">
        <h1 className="font-display text-4xl font-extrabold mb-2">{title}</h1>
        {subtitle && <p className="text-buddy-text-primary text-sm leading-relaxed">{subtitle}</p>}
        {updatedAt && <p className="text-buddy-text-secondary text-sm mt-1 mb-12">Last updated {updatedAt}</p>}
        <div className="prose prose-invert max-w-none space-y-8 text-sm leading-relaxed text-buddy-text-secondary">
          {children}
        </div>
      </div>
    </div>
  );
}

export function LegalSection({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section>
      <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">{title}</h2>
      {children}
    </section>
  );
}

export function LegalNotice({ children, tone = 'orange' }: { children: ReactNode; tone?: 'orange' | 'red' | 'green' }) {
  const tones = {
    orange: 'border-buddy-orange/30 bg-buddy-orange/5 text-buddy-orange',
    red: 'border-buddy-red/30 bg-buddy-red/5 text-buddy-red',
    green: 'border-buddy-green/30 bg-buddy-green/5 text-buddy-green',
  };
  return <p className={`border rounded-xl px-4 py-3 text-xs leading-relaxed ${tones[tone]}`}>{children}</p>;
}
