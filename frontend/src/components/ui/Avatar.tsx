interface AvatarProps {
  src?: string; alt: string; size?: 'sm' | 'md' | 'lg' | 'xl';
  showRepRing?: boolean; streakProgress?: number; className?: string;
}
const sz: Record<string, string> = { sm: 'w-8 h-8', md: 'w-10 h-10', lg: 'w-14 h-14', xl: 'w-20 h-20' };
const rs: Record<string, string> = { sm: 'w-10 h-10', md: 'w-12 h-12', lg: 'w-16 h-16', xl: 'w-22 h-22' };

export function Avatar({ src, alt, size = 'md', showRepRing = false, streakProgress = 0, className }: AvatarProps) {
  const img = (
    <div className={`rounded-full bg-buddy-surface overflow-hidden flex-shrink-0 ${sz[size]} ${className || ''}`}>
      {src ? <img src={src} alt={alt} className="w-full h-full object-cover" loading="lazy" /> : (
        <div className="w-full h-full flex items-center justify-center bg-buddy-green/20 text-buddy-green font-heading font-semibold text-lg">
          {alt.charAt(0).toUpperCase()}
        </div>
      )}
    </div>
  );
  if (!showRepRing) return img;
  const circ = 2 * Math.PI * 20;
  const off = circ - ((streakProgress % 100) / 100) * circ;
  return (
    <div className={`relative inline-flex items-center justify-center ${rs[size]}`}>
      <svg className="absolute inset-0 w-full h-full -rotate-90" viewBox="0 0 44 44">
        <circle cx="22" cy="22" r="20" fill="none" stroke="#1E1E1E" strokeWidth="2.5" />
        <circle cx="22" cy="22" r="20" fill="none" stroke="#00C896" strokeWidth="2.5" strokeLinecap="round" strokeDasharray={circ} strokeDashoffset={off} className="transition-all duration-500" />
      </svg>
      {img}
    </div>
  );
}
