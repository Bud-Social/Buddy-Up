import { create } from 'zustand';
type Theme = 'dark' | 'light';
interface ThemeState { theme: Theme; toggle: () => void; setTheme: (theme: Theme) => void; }

const getInit = (): Theme => {
  if (typeof window === 'undefined') return 'dark';
  const s = localStorage.getItem('buddyup-theme');
  return (s === 'light' || s === 'dark') ? s : 'dark';
};

export const useThemeStore = create<ThemeState>((set) => ({
  theme: getInit(),
  toggle: () => set((s) => { const n = s.theme === 'dark' ? 'light' : 'dark'; localStorage.setItem('buddyup-theme', n); return { theme: n }; }),
  setTheme: (theme) => { localStorage.setItem('buddyup-theme', theme); set({ theme }); },
}));
