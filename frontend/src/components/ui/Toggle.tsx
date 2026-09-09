import { forwardRef } from 'react';

export interface ToggleProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'onChange' | 'checked' | 'value' | 'type'> {
  /** Controlled state of the switch. */
  checked: boolean;
  /** Called with the next state when the toggle is activated. */
  onCheckedChange: (checked: boolean) => void;
  /** Accessible name — announced by screen readers (no visible label required). */
  label: string;
}

/**
 * Accessible switch used across Settings.
 *
 * A11y contract:
 * - native <button> so Space/Enter activate it and it is keyboard focusable;
 * - role="switch" + aria-checked conveys on/off state;
 * - aria-label names it for screen readers (no visible label required);
 * - focus-visible ring for keyboard users; disabled renders at 40% opacity.
 */
export const Toggle = forwardRef<HTMLButtonElement, ToggleProps>(
  ({ checked, onCheckedChange, label, disabled, className = '', ...props }, ref) => (
    <button
      ref={ref}
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={() => onCheckedChange(!checked)}
      className={`relative inline-flex h-6 w-11 flex-shrink-0 items-center rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-buddy-green/60 focus-visible:ring-offset-2 focus-visible:ring-offset-buddy-black disabled:cursor-not-allowed disabled:opacity-40 ${
        checked ? 'bg-buddy-green' : 'border border-buddy-surface bg-buddy-surface-raised'
      } ${className}`}
      {...props}
    >
      <span
        aria-hidden="true"
        className={`inline-block h-5 w-5 transform rounded-full bg-white shadow transition-transform ${
          checked ? 'translate-x-5' : 'translate-x-0.5'
        }`}
      />
    </button>
  ),
);
Toggle.displayName = 'Toggle';
