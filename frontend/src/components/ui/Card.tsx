import { HTMLAttributes, forwardRef } from 'react';
interface CardProps extends HTMLAttributes<HTMLDivElement> { elevated?: boolean; }
export const Card = forwardRef<HTMLDivElement, CardProps>(({ elevated = false, className, children, ...props }, ref) => (
  <div ref={ref} className={`rounded-2xl ${elevated ? 'bg-buddy-surface-raised' : 'bg-buddy-surface'} ${className || ''}`} {...props}>{children}</div>
));
Card.displayName = 'Card';
