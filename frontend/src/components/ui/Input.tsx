import { InputHTMLAttributes, forwardRef } from 'react';
interface InputProps extends InputHTMLAttributes<HTMLInputElement> { label?: string; error?: string; helperText?: string; }
export const Input = forwardRef<HTMLInputElement, InputProps>(({ label, error, helperText, className, id, ...props }, ref) => {
  const inputId = id || label?.toLowerCase().replace(/\s+/g, '-');
  return (
    <div className="w-full">
      {label && <label htmlFor={inputId} className="block text-sm font-medium text-buddy-text-secondary mb-1.5">{label}</label>}
      <input ref={ref} id={inputId} className={`w-full bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary placeholder:text-buddy-text-secondary/50 font-body transition-colors focus:outline-none focus:ring-2 focus:border-transparent min-h-touch ${error ? 'border-buddy-red focus:ring-buddy-red/30' : 'border-transparent focus:ring-buddy-green/30'} ${className || ''}`} {...props} />
      {error && <p className="mt-1 text-sm text-buddy-red">{error}</p>}
      {helperText && !error && <p className="mt-1 text-sm text-buddy-text-secondary">{helperText}</p>}
    </div>
  );
});
Input.displayName = 'Input';
