import { ButtonHTMLAttributes, forwardRef } from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
}

const v: Record<ButtonVariant, string> = {
  primary: 'bg-buddy-green text-buddy-black hover:bg-buddy-green-deep font-semibold',
  secondary: 'bg-buddy-electric text-white hover:opacity-90',
  outline: 'border border-buddy-green text-buddy-green hover:bg-buddy-green/10',
  ghost: 'text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface',
  destructive: 'bg-buddy-red text-white hover:opacity-90',
};
const s: Record<ButtonSize, string> = {
  sm: 'px-3 py-1.5 text-sm rounded-lg',
  md: 'px-5 py-2.5 text-base rounded-xl',
  lg: 'px-8 py-3.5 text-lg rounded-xl',
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', isLoading, className, children, disabled, ...props }, ref) => (
    <button
      ref={ref}
      className={`inline-flex items-center justify-center gap-2 font-body font-medium transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed min-h-touch min-w-touch ${v[variant]} ${s[size]} ${className || ''}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
      ) : children}
    </button>
  ),
);
Button.displayName = 'Button';
