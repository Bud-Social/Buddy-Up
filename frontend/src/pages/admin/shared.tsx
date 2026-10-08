import { useState, type ReactNode } from 'react';
import { RefreshCw, ShieldAlert, Inbox } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { formatCount, statusLabel, statusVariant } from './format';

/**
 * Status pill for any backend enum. The label is humanised and the colour comes
 * from `statusVariant`, so a value this console has never seen still renders.
 */
export function StatusBadge({ status }: { status: unknown }) {
  const label = statusLabel(status);
  return (
    <Badge variant={statusVariant(status)} label={label.charAt(0).toUpperCase() + label.slice(1)} size="sm" />
  );
}

export function BooleanBadge({ value, trueLabel, falseLabel }: { value: unknown; trueLabel: string; falseLabel?: string }) {
  const isTrue = value === true;
  return (
    <Badge variant={isTrue ? 'green' : 'silver'} label={isTrue ? trueLabel : falseLabel || 'No'} size="sm" />
  );
}

/**
 * Shared building blocks for the admin console pages.
 *
 * Styling vocabulary is borrowed verbatim from `AdminLayout`,
 * `ModerationQueue` and `AdminVerification` so every admin page reads as one
 * surface: Card for panels, Badge for status pills, Button for actions, and the
 * `buddy-*` colour tokens only — no gradients, no glow.
 */

export function AdminPageHeader({
  title,
  description,
  onRefresh,
  refreshing,
  actions,
}: {
  title: string;
  description?: ReactNode;
  onRefresh?: () => void;
  refreshing?: boolean;
  actions?: ReactNode;
}) {
  return (
    <div className="flex items-start justify-between gap-3">
      <div className="min-w-0">
        <h2 className="font-display text-xl sm:text-2xl font-extrabold">{title}</h2>
        {description && <p className="text-xs text-buddy-text-secondary mt-0.5">{description}</p>}
      </div>
      <div className="flex items-center gap-2 flex-shrink-0">
        {actions}
        {onRefresh && (
          <Button variant="outline" size="sm" onClick={onRefresh} isLoading={refreshing}>
            <RefreshCw size={14} className="mr-1" /> Refresh
          </Button>
        )}
      </div>
    </div>
  );
}

export function AdminStatCard({ label, value, sub }: { label: string; value: ReactNode; sub?: ReactNode }) {
  return (
    <Card className="p-4">
      <p className="text-xs text-buddy-text-secondary">{label}</p>
      <p className="font-display font-extrabold text-2xl leading-tight mt-0.5">{value}</p>
      {sub && <p className="text-[11px] text-buddy-text-secondary truncate">{sub}</p>}
    </Card>
  );
}

/** Inline non-blocking error. The server's `message` is shown verbatim. */
export function AdminErrorBanner({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2 flex items-center justify-between gap-3">
      <span className="min-w-0 break-words">{message}</span>
      {onRetry && (
        <Button variant="ghost" size="sm" onClick={onRetry} className="flex-shrink-0">
          <RefreshCw size={12} className="mr-1" /> Retry
        </Button>
      )}
    </div>
  );
}

/** Full-page error state — used when there is nothing at all to show. */
export function AdminErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <Card className="p-8 text-center">
      <ShieldAlert size={32} className="mx-auto text-buddy-red mb-3" />
      <p className="text-sm text-buddy-text-secondary mb-4 break-words">{message}</p>
      {onRetry && (
        <Button variant="outline" size="sm" onClick={onRetry}>
          <RefreshCw size={14} className="mr-1" /> Retry
        </Button>
      )}
    </Card>
  );
}

export function AdminEmptyState({ title, hint, icon }: { title: string; hint?: string; icon?: ReactNode }) {
  return (
    <Card className="p-8 text-center">
      <span className="inline-flex mb-3 text-buddy-green/40">{icon || <Inbox size={32} />}</span>
      <p className="text-sm text-buddy-text-secondary">{title}</p>
      {hint && <p className="text-xs text-buddy-text-secondary/80 mt-1">{hint}</p>}
    </Card>
  );
}

export function AdminSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <div className="space-y-4" role="status" aria-busy="true" aria-label="Loading">
      <Card className="h-24 animate-pulse bg-buddy-surface-raised" />
      {Array.from({ length: rows }).map((_, i) => (
        <Card key={i} className="h-16 animate-pulse bg-buddy-surface-raised" />
      ))}
    </div>
  );
}

/**
 * Page-size-agnostic pager. Uses the envelope's `next`/`previous` presence so
 * it stays correct even if the server's page size differs from our guess.
 */
export function AdminPagination({
  page,
  pageCount,
  count,
  onPage,
  busy,
}: {
  page: number;
  pageCount: number;
  count: number;
  onPage: (page: number) => void;
  busy?: boolean;
}) {
  if (count === 0) return null;
  return (
    <div className="flex items-center justify-between gap-3 pt-1">
      <p className="text-[11px] text-buddy-text-secondary">
        Page {page} of {pageCount} · {formatCount(count)} total
      </p>
      <div className="flex items-center gap-2">
        <Button variant="ghost" size="sm" disabled={busy || page <= 1} onClick={() => onPage(page - 1)}>
          Previous
        </Button>
        <Button variant="ghost" size="sm" disabled={busy || page >= pageCount} onClick={() => onPage(page + 1)}>
          Next
        </Button>
      </div>
    </div>
  );
}

export function SearchField({
  value,
  onChange,
  placeholder,
  label,
}: {
  value: string;
  onChange: (value: string) => void;
  placeholder: string;
  label?: string;
}) {
  return (
    <div className="relative">
      {label && <span className="sr-only">{label}</span>}
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        aria-label={label || placeholder}
        className="w-full sm:w-64 bg-buddy-surface-raised border border-buddy-surface rounded-xl pl-3 pr-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
      />
    </div>
  );
}

export function FilterSelect({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string;
  options: Array<{ value: string; label: string }>;
  onChange: (value: string) => void;
}) {
  return (
    <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
      <span className="sr-only sm:not-sr-only">{label}</span>
      <select
        value={value}
        aria-label={label}
        onChange={(e) => onChange(e.target.value)}
        className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs text-buddy-text-primary focus:outline-none focus:border-buddy-green"
      >
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
    </label>
  );
}

/** Chip row used for single-select filters (mirrors ModerationQueue's). */
export function FilterChips({
  options,
  value,
  onChange,
}: {
  options: Array<{ value: string; label: string }>;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      {options.map((o) => (
        <button
          key={o.value}
          type="button"
          onClick={() => onChange(o.value)}
          aria-pressed={value === o.value}
          className={`text-xs px-2.5 py-1 rounded-lg transition-colors ${
            value === o.value
              ? 'bg-buddy-green/15 text-buddy-green font-semibold'
              : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'
          }`}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

/** Simple key/value row used in detail panels. */
export function DataRow({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-3 py-1.5 border-b border-buddy-surface last:border-0">
      <span className="text-xs text-buddy-text-secondary flex-shrink-0">{label}</span>
      <span className="text-xs text-buddy-text-primary text-right min-w-0 break-words">{children}</span>
    </div>
  );
}

/**
 * Compact inline action panel for "enter a reason and approve/reject".
 * Extracted so each review queue behaves identically.
 */
export function ReasonPrompt({
  open,
  action,
  placeholder,
  busy,
  submitLabel,
  onSubmit,
  onCancel,
}: {
  open: boolean;
  action: 'approved' | 'rejected';
  placeholder: string;
  busy?: boolean;
  submitLabel: string;
  onSubmit: (reason: string) => void;
  onCancel: () => void;
}) {
  const [reason, setReason] = useState('');
  if (!open) return null;
  return (
    <div className="mt-3 pt-3 border-t border-buddy-surface">
      <label className="block text-xs text-buddy-text-secondary mb-1.5">
        Reason {action === 'rejected' ? '(sent to the applicant)' : '(internal note)'}
      </label>
      <textarea
        autoFocus
        rows={2}
        value={reason}
        onChange={(e) => setReason(e.target.value)}
        placeholder={placeholder}
        aria-label={action === 'rejected' ? 'Rejection reason' : 'Internal note'}
        className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
      />
      <div className="flex items-center gap-2 mt-2">
        <Button
          size="sm"
          variant={action === 'rejected' ? 'destructive' : 'primary'}
          isLoading={busy}
          disabled={action === 'rejected' && !reason.trim()}
          onClick={() => onSubmit(reason.trim())}
        >
          {submitLabel}
        </Button>
        <Button variant="ghost" size="sm" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </div>
  );
}