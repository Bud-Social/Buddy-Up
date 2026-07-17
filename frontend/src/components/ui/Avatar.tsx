import { useState } from 'react';

interface AvatarProps {
  src?: string; alt: string; size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  showRepRing?: boolean; streakProgress?: number; className?: string;
  onClick?: (e: React.MouseEvent) => void; style?: React.CSSProperties;
  verificationStatus?: string;
}
const sz: Record<string, string> = { xs: 'w-6 h-6', sm: 'w-8 h-8', md: 'w-10 h-10', lg: 'w-14 h-14', xl: 'w-20 h-20' };
const rs: Record<string, string> = { xs: 'w-8 h-8', sm: 'w-10 h-10', md: 'w-12 h-12', lg: 'w-16 h-16', xl: 'w-22 h-22' };

export function Avatar({ src, alt, size = 'md', showRepRing = false, streakProgress = 0, className, onClick, style, verificationStatus }: AvatarProps) {
  const [errored, setErrored] = useState(false);

  const initials = (
    <div className="w-full h-full flex items-center justify-center bg-buddy-green/20 text-buddy-green font-heading font-semibold text-lg">
      {alt.charAt(0).toUpperCase()}
    </div>
  );

  const img = (
    <div
      className={`relative rounded-full bg-buddy-surface overflow-hidden flex-shrink-0 ${sz[size]} ${className || ''}`}
      onClick={onClick} role={onClick ? 'button' : undefined} tabIndex={onClick ? 0 : undefined}
      style={style}
    >
      {src && !errored ? (
        <img
          src={src}
          alt={alt}
          className="w-full h-full object-cover"
          loading="lazy"
          onError={() => setErrored(true)}
        />
      ) : initials}
    </div>
  );

  const badgeEl = verificationStatus === 'trainer' ? (
    <span className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-buddy-green rounded-full border-2 border-buddy-black flex items-center justify-center">
      <span className="text-[6px] font-bold text-buddy-black">✓</span>
    </span>
  ) : verificationStatus === 'practitioner' ? (
    <span className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-buddy-gold rounded-full border-2 border-buddy-black flex items-center justify-center">
      <span className="text-[6px] font-bold text-buddy-black">✓</span>
    </span>
  ) : null;

  if (!showRepRing) {
    if (!badgeEl) return img;
    return (
      <div className="relative inline-flex">
        {img}
        {badgeEl}
      </div>
    );
  }
  const circ = 2 * Math.PI * 20;
  const off = circ - ((streakProgress % 100) / 100) * circ;
  return (
    <div className={`relative inline-flex items-center justify-center ${rs[size]}`}>
      <svg className="absolute inset-0 w-full h-full -rotate-90" viewBox="0 0 44 44">
        <circle cx="22" cy="22" r="20" fill="none" className="stroke-[rgb(var(--buddy-surface-rgb))]" strokeWidth="2.5" />
        <circle cx="22" cy="22" r="20" fill="none" stroke="#00C896" strokeWidth="2.5" strokeLinecap="round" strokeDasharray={circ} strokeDashoffset={off} className="transition-all duration-500" />
      </svg>
      {img}
      {badgeEl}
    </div>
  );
}
