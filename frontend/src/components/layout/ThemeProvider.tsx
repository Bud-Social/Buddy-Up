import { useEffect, type ReactNode } from 'react';
import { useThemeStore } from '@/store/themeStore';
export function ThemeProvider({ children }: { children: ReactNode }) {
  const theme = useThemeStore((s) => s.theme);
  useEffect(() => { const r = document.documentElement; if (theme === 'dark') { r.classList.add('dark'); r.classList.remove('light'); } else { r.classList.add('light'); r.classList.remove('dark'); } }, [theme]);
  return <>{children}</>;
}
