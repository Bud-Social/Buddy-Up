import type { Config } from 'tailwindcss';

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'buddy-green': '#00C896',
        'buddy-green-deep': '#009E78',
        'buddy-electric': '#7B61FF',
        'buddy-orange': '#FF6B35',
        'buddy-black': '#0A0A0A',
        'buddy-surface': '#141414',
        'buddy-surface-raised': '#1E1E1E',
        'buddy-white': '#F8F8F8',
        'buddy-text-primary': '#FFFFFF',
        'buddy-text-secondary': '#A0A0A0',
        'buddy-red': '#FF4757',
        'buddy-gold': '#FFD700',
      },
      fontFamily: {
        display: ['"Syne"', 'sans-serif'],
        heading: ['"Plus Jakarta Sans"', 'sans-serif'],
        body: ['"Inter"', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
        coin: ['"Nunito"', 'sans-serif'],
      },
      minHeight: {
        'touch': '48px',
      },
      minWidth: {
        'touch': '48px',
      },
      spacing: {
        '22': '5.5rem',
      },
    },
  },
  plugins: [],
} satisfies Config;
