import { useThemeStore } from '@/store/themeStore';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'sidebar';
  className?: string;
  type?: 'full' | 'icon';
}

const sizeMap = {
  sm: { full: 'h-6', icon: 'h-6' },
  md: { full: 'h-8', icon: 'h-8' },
  lg: { full: 'h-10', icon: 'h-10' },
  xl: { full: 'h-16 sm:h-20 md:h-24 lg:h-28', icon: 'h-16 sm:h-20 md:h-24 lg:h-28' },
  sidebar: { full: 'h-full w-full', icon: 'h-full w-full' },
};

const isDarkVisual = (theme: string) => theme === 'dark' || theme === 'high-contrast';

export function Logo({ size = 'md', className = '', type = 'full' }: LogoProps) {
  const effectiveTheme = useThemeStore((s) => s.effectiveTheme);

  const logoSrc = type === 'full'
    ? (isDarkVisual(effectiveTheme) ? '/logo-dark.png' : '/logo-light.png')
    : (isDarkVisual(effectiveTheme) ? '/favicon-dark.png' : '/favicon-light.png');

  const heightClass = sizeMap[size][type];

  return (
    <img
      src={logoSrc}
      alt="BuddyUp"
      className={`object-contain rounded-xl transition-opacity duration-300 ${heightClass} ${className}`}
    />
  );
}
