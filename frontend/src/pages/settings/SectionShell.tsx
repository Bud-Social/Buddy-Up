import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { ChevronLeft } from 'lucide-react';

/** Shared chrome for every /settings/:section sub-page: back link + title. */
export function SectionShell({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24">
      <Link
        to="/settings"
        className="inline-flex items-center gap-1 text-sm text-buddy-text-secondary hover:text-buddy-text-primary transition-colors mb-4"
      >
        <ChevronLeft size={16} /> Settings
      </Link>
      <h2 className="font-heading text-xl font-semibold mb-4">{title}</h2>
      {children}
    </div>
  );
}
