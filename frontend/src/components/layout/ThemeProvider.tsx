import { useEffect, type ReactNode } from 'react';
import { useThemeStore } from '@/store/themeStore';

interface ThemeColors {
  bg: string;
  surface: string;
  surfaceRaised: string;
  white: string;
  text: string;
  textSecondary: string;
  border: string;
}

const themes: Record<string, ThemeColors> = {
  dark: {
    bg: '#0A0A0A',
    surface: '#141414',
    surfaceRaised: '#1E1E1E',
    white: '#F8F8F8',
    text: '#FFFFFF',
    textSecondary: '#A0A0A0',
    border: '#1E1E1E',
  },
  light: {
    bg: '#F5F5F5',
    surface: '#FFFFFF',
    surfaceRaised: '#EEEEEE',
    white: '#0A0A0A',
    text: '#1A1A1A',
    textSecondary: '#666666',
    border: '#E0E0E0',
  },
  'high-contrast': {
    bg: '#000000',
    surface: '#0A0A0A',
    surfaceRaised: '#141414',
    white: '#FFFFFF',
    text: '#FFFFFF',
    textSecondary: '#C8C8C8',
    border: '#FFFFFF',
  },
  ambient: {
    bg: '#080C1A',
    surface: '#0F1628',
    surfaceRaised: '#171F38',
    white: '#DCE8FF',
    text: '#D0DEFF',
    textSecondary: '#7B94CC',
    border: '#1E2D52',
  },
};
const metaColors: Record<string, string> = {
  dark: '#0A0A0A',
  light: '#F8F8F8',
  'high-contrast': '#000000',
  ambient: '#080C1A',
};

const favicons: Record<string, string> = {
  dark: '/favicon-dark.png',
  light: '/favicon-light.png',
  'high-contrast': '/favicon-dark.png',
  ambient: '/favicon-dark.png',
};

function hexAlpha(hex: string, alpha: number): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}

function generateThemeCSS(colors: ThemeColors): string {
  const o = (a: number) => hexAlpha(colors.bg, a);
  const s = (a: number) => hexAlpha(colors.surface, a);
  const ts = (a: number) => hexAlpha(colors.textSecondary, a);
  const sr = colors.surfaceRaised;
  const t = colors.text;
  const ts2 = colors.textSecondary;
  const b = colors.border;

  return `
.bg-buddy-black{background-color:${colors.bg}!important}
.bg-buddy-black\\/40{background-color:${o(0.4)}!important}
.bg-buddy-black\\/50{background-color:${o(0.5)}!important}
.bg-buddy-black\\/60{background-color:${o(0.6)}!important}
.bg-buddy-black\\/70{background-color:${o(0.7)}!important}
.bg-buddy-black\\/80{background-color:${o(0.8)}!important}
.bg-buddy-black\\/90{background-color:${o(0.9)}!important}
.bg-buddy-black\\/95{background-color:${o(0.95)}!important}
.bg-buddy-surface{background-color:${colors.surface}!important}
.bg-buddy-surface\\/50{background-color:${s(0.5)}!important}
.bg-buddy-surface-raised{background-color:${sr}!important}
.bg-buddy-white{background-color:${colors.white}!important}
.text-buddy-text-primary{color:${t}!important}
.text-buddy-text-secondary{color:${ts2}!important}
.text-buddy-text-secondary\\/30{color:${ts(0.3)}!important}
.text-buddy-text-secondary\\/40{color:${ts(0.4)}!important}
.text-buddy-text-secondary\\/50{color:${ts(0.5)}!important}
.text-buddy-white{color:${colors.white}!important}
.border-buddy-surface{border-color:${b}!important}
.border-buddy-surface-raised{border-color:${sr}!important}
.border-buddy-black{border-color:${colors.bg}!important}
.hover\\:bg-buddy-surface-raised:hover{background-color:${sr}!important}
.hover\\:text-buddy-text-primary:hover{color:${t}!important}
.hover\\:border-buddy-text-secondary\\/30:hover{border-color:${ts(0.3)}!important}
.hover\\:bg-buddy-surface:hover{background-color:${colors.surface}!important}
.from-buddy-black\\/80{--tw-gradient-from:${o(0.8)}!important}
.via-buddy-black\\/40{--tw-gradient-to:${o(0.4)}!important}
.from-buddy-black\\/90{--tw-gradient-from:${o(0.9)}!important}
.via-buddy-black\\/60{--tw-gradient-to:${o(0.6)}!important}
.placeholder-buddy-text-secondary\\/50::placeholder{color:${ts(0.5)}!important}
.placeholder-buddy-text-secondary\\/30::placeholder{color:${ts(0.3)}!important}
body{background-color:${colors.bg}!important;color:${t}!important}
`;
}

const STYLE_ID = 'buddyup-theme-override';

export function ThemeProvider({ children }: { children: ReactNode }) {
  const effectiveTheme = useThemeStore((s) => s.effectiveTheme);

  useEffect(() => {
    const r = document.documentElement;
    r.className = effectiveTheme;

    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', metaColors[effectiveTheme] || '#0A0A0A');
    }

    const favicon = document.querySelector('link[rel="icon"]') as HTMLLinkElement | null;
    if (favicon) {
      favicon.href = favicons[effectiveTheme] || '/favicon-dark.png';
    }

    let style = document.getElementById(STYLE_ID) as HTMLStyleElement;
    if (!style) {
      style = document.createElement('style');
      style.id = STYLE_ID;
      document.head.appendChild(style);
    }
    style.textContent = generateThemeCSS(themes[effectiveTheme] || themes.dark);
  }, [effectiveTheme]);

  return <>{children}</>;
}
