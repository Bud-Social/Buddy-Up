import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import {
  getAlwaysShowSensitive, isRevealed, markRevealed,
  setAlwaysShowSensitive, sensitiveLabel, type SensitiveKind,
} from '@/lib/sensitive';

interface SensitiveGateProps {
  postId: string;
  blurred: boolean;
  kind: SensitiveKind;
  children: (revealed: boolean) => React.ReactNode;
}

/**
 * X/IG-style sensitive gate: blurred content + reason + tap-to-reveal.
 * Reveal persists per-post; "Always show" persists globally.
 */
export function SensitiveGate({ postId, blurred, kind, children }: SensitiveGateProps) {
  const [revealed, setRevealed] = useState(() => !blurred || getAlwaysShowSensitive() || isRevealed(postId));
  const [alwaysShow, setAlwaysShow] = useState(() => getAlwaysShowSensitive());

  if (!blurred || revealed) return <>{children(true)}</>;

  const { title, detail } = sensitiveLabel(kind);

  const reveal = () => {
    markRevealed(postId);
    setRevealed(true);
  };

  const toggleAlways = () => {
    const next = !alwaysShow;
    setAlwaysShow(next);
    setAlwaysShowSensitive(next);
    if (next) setRevealed(true);
  };

  return (
    <div className="relative">
      <div aria-hidden className="pointer-events-none select-none">
        {children(false)}
      </div>
      <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 bg-black/45 p-4 text-center rounded-xl">
        <p className="text-sm font-semibold text-white">{title}</p>
        <p className="text-xs text-white/80 max-w-xs">{detail}</p>
        <div className="flex items-center gap-2 mt-1">
          <button
            onClick={(e) => { e.stopPropagation(); reveal(); }}
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full bg-white text-sm text-black font-medium hover:bg-white/90 transition-colors"
          >
            <Eye size={15} /> Show
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); toggleAlways(); }}
            title="Remember my choice for all sensitive posts"
            className="inline-flex items-center gap-1.5 px-3 py-2 rounded-full bg-white/15 text-xs text-white font-medium hover:bg-white/25 transition-colors"
          >
            {alwaysShow ? <EyeOff size={13} /> : <Eye size={13} />}
            {alwaysShow ? 'Always on' : 'Always show'}
          </button>
        </div>
      </div>
    </div>
  );
}
