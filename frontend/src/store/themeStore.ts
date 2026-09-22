import { create } from 'zustand';

export type Theme = 'dark' | 'light' | 'high-contrast' | 'ambient';
export type AppIcon = 'logo' | 'clock';

interface ThemeState {
  theme: Theme;
  effectiveTheme: Theme;
  appIcon: AppIcon;
  toggle: () => void;
  setTheme: (theme: Theme) => void;
  setAppIcon: (icon: AppIcon) => void;
}

const computeEffective = (theme: Theme): Theme => theme;

const getInit = (): Theme => {
  if (typeof window === 'undefined') return 'dark';
  const s = localStorage.getItem('buddyup-theme');
  const valid: Theme[] = ['dark', 'light', 'high-contrast', 'ambient'];
  return valid.includes(s as Theme) ? (s as Theme) : 'dark';
};

const getInitIcon = (): AppIcon => {
  if (typeof window === 'undefined') return 'logo';
  const s = localStorage.getItem('buddyup-app-icon');
  return s === 'clock' ? 'clock' : 'logo';
};

export const useThemeStore = create<ThemeState>((set) => {
  const initial = getInit();
  return {
    theme: initial,
    effectiveTheme: computeEffective(initial),
    appIcon: getInitIcon(),
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
    setAppIcon: (appIcon) => {
      localStorage.setItem('buddyup-app-icon', appIcon);
      set({ appIcon });
    },
  };
});
