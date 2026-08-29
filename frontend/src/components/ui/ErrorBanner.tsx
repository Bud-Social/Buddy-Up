import { AlertCircle, RefreshCw } from 'lucide-react';
import { Button } from './Button';

interface ErrorBannerProps {
  message: string;
  onRetry: () => void;
  className?: string;
}

export function ErrorBanner({ message, onRetry, className = '' }: ErrorBannerProps) {
  return (
    <div
      className={`flex items-center justify-between gap-3 bg-buddy-red/10 border border-buddy-red/20 rounded-xl px-4 py-3 text-sm text-buddy-red ${className}`}
    >
      <span className="flex items-center gap-2 min-w-0">
        <AlertCircle size={16} className="shrink-0" />
        <span className="truncate">{message}</span>
      </span>
      <Button variant="outline" size="sm" onClick={onRetry} className="shrink-0">
        <RefreshCw size={12} /> Retry
      </Button>
    </div>
  );
}
