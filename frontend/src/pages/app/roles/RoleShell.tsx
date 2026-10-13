import type { ReactNode } from 'react';
import { ChevronLeft } from 'lucide-react';

/**
 * Shared chrome for the four role dashboards (courier, organiser, stations,
 * gym manage).
 *
 * Mirrors the `CreatorStudio` seller-hub pattern exactly — same max-width
 * ramp, same `font-display` title, same rounded-full back button — so the
 * dashboards read as one family with the seller hub rather than as a separate
 * admin surface. `buddy-*` colour tokens only: no gradients, no glow.
 */
export function RoleDashboardShell({
  title,
  subtitle,
  onBack,
  backTo,
  actions,
  children,
}: {
  title: string;
  subtitle?: ReactNode;
  /** Preferred: an in-app path to navigate back to. */
  backTo?: string;
  /** Fallback for a page with no route to return to (uses history). */
  onBack?: () => void;
  actions?: ReactNode;
  children: ReactNode;
}) {
  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-4xl mx-auto p-4 space-y-4 pb-20">
      <div className="flex items-start justify-between gap-3 mb-1">
        <div className="flex items-center gap-3 min-w-0">
          <BackButton backTo={backTo} onBack={onBack} />
          <div className="min-w-0">
            <h1 className="font-display text-2xl font-extrabold truncate">{title}</h1>
            {subtitle && <p className="text-xs text-buddy-text-secondary mt-0.5">{subtitle}</p>}
          </div>
        </div>
        {actions && <div className="flex items-center gap-2 flex-shrink-0">{actions}</div>}
      </div>
      {children}
    </div>
  );
}

export function BackButton({ backTo, onBack }: { backTo?: string; onBack?: () => void }) {
  return (
    <button
      onClick={() => {
        if (backTo && typeof window !== 'undefined' && window.history?.length) window.history.back();
        else onBack?.();
      }}
      aria-label="Go back"
      className="p-2 rounded-full hover:bg-buddy-surface flex-shrink-0"
    >
      <ChevronLeft size={20} />
    </button>
  );
}

/** Section heading used inside a role dashboard. Matches CreatorStudio's style. */
export function RoleSectionTitle({ children, action }: { children: ReactNode; action?: ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-2">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">{children}</h2>
      {action}
    </div>
  );
}