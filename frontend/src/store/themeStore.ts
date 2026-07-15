import { create } from 'zustand';

export type Theme = 'dark' | 'light' | 'high-contrast' | 'ambient';

interface ThemeState {
  theme: Theme;
  effectiveTheme: Theme;
  toggle: () => void;
  setTheme: (theme: Theme) => void;
}

const computeEffective = (theme: Theme): Theme => theme;

const getInit = (): Theme => {
  if (typeof window === 'undefined') return 'dark';
  const s = localStorage.getItem('buddyup-theme');
  const valid: Theme[] = ['dark', 'light', 'high-contrast', 'ambient'];
  return valid.includes(s as Theme) ? (s as Theme) : 'dark';
};

export const useThemeStore = create<ThemeState>((set) => {
  const initial = getInit();
  return {
    theme: initial,
    effectiveTheme: computeEffective(initial),
    toggle: () =>
      set((s) => {
        const order: Theme[] = ['dark', 'light', 'high-contrast', 'ambient'];
        const idx = order.indexOf(s.theme);
        const next = order[(idx + 1) % order.length];
        localStorage.setItem('buddyup-theme', next);
        return { theme: next, effectiveTheme: computeEffective(next) };
      }),
    setTheme: (theme) => {
      localStorage.setItem('buddyup-theme', theme);
      set({ theme, effectiveTheme: computeEffective(theme) });
    },
  };
});
