import { useThemeStore } from '@/store/themeStore';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'sidebar';
  className?: string;
  type?: 'full' | 'icon' | 'text';
}

const sizeMap = {
  sm: { full: 'h-6', icon: 'h-6', text: 'text-lg' },
  md: { full: 'h-8', icon: 'h-8', text: 'text-xl' },
  lg: { full: 'h-10', icon: 'h-10', text: 'text-2xl' },
  xl: { full: 'h-16 sm:h-20 md:h-24 lg:h-28', icon: 'h-16 sm:h-20 md:h-24 lg:h-28', text: 'text-3xl sm:text-4xl' },
  sidebar: { full: 'h-full w-full', icon: 'h-full w-full', text: 'text-xl' },
};

const getLogoSrc = (theme: string) => {
  switch (theme) {
    case 'ambient': return '/favicon-ambient.png';
    case 'high-contrast': return '/favicon-high-contrast.png';
    case 'dark': return '/favicon-dark.png';
    default: return '/favicon-light.png';
  }
};

export function Logo({ size = 'md', className = '', type = 'full' }: LogoProps) {
  const effectiveTheme = useThemeStore((s) => s.effectiveTheme);

  if (type === 'text') {
    return (
      <span className={`font-display font-extrabold bg-gradient-to-r from-buddy-green to-buddy-electric bg-clip-text text-transparent ${sizeMap[size].text} ${className}`}>
        BuddyUp
      </span>
    );
  }

  const heightClass = sizeMap[size]['icon'];

  const img = (
    <img
      src={getLogoSrc(effectiveTheme)}
      alt="BuddyUp Logo"
      className={`object-contain rounded-xl transition-opacity duration-300 ${heightClass} ${className}`}
    />
  );

  if (type === 'icon') return img;

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      {img}
      <span className={`font-display font-extrabold bg-gradient-to-r from-buddy-green to-buddy-electric bg-clip-text text-transparent ${sizeMap[size].text}`}>
        BuddyUp
      </span>
    </div>
  );
}
