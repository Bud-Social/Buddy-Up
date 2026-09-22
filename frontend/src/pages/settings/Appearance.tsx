import { useState } from 'react';
import { Contrast, Monitor, Moon, Sun } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Toggle } from '@/components/ui/Toggle';
import { useThemeStore } from '@/store/themeStore';
import {
  isReducedMotionEnabled, setReducedMotionEnabled,
} from '@/lib/reducedMotion';
import { SectionShell } from './SectionShell';

const THEMES = [
  { value: 'dark' as const, label: 'Dark', icon: Moon, desc: 'Dark backgrounds, light text' },
  { value: 'light' as const, label: 'Light', icon: Sun, desc: 'Light backgrounds, dark text' },
  { value: 'high-contrast' as const, label: 'High Contrast', icon: Contrast, desc: 'Maximum contrast ratio' },
  { value: 'ambient' as const, label: 'Ambient', icon: Monitor, desc: 'Glowing bluish night mode' },
];

export default function Appearance() {
  const theme = useThemeStore((s) => s.theme);
  const setTheme = useThemeStore((s) => s.setTheme);
  const appIcon = useThemeStore((s) => s.appIcon);
  const setAppIcon = useThemeStore((s) => s.setAppIcon);
  const [reducedMotion, setReducedMotion] = useState(isReducedMotionEnabled());

  const handleReducedMotion = (checked: boolean) => {
    setReducedMotion(checked);
    setReducedMotionEnabled(checked);
  };

  return (
    <SectionShell title="Appearance">
      <div className="space-y-4">
        <Card className="p-4 space-y-3">
          <p className="text-sm font-medium mb-1">Theme</p>
          <div className="grid grid-cols-2 gap-2">
            {THEMES.map(({ value, label, icon: Icon, desc }) => (
              <button key={value} onClick={() => setTheme(value)}
                aria-pressed={theme === value}
                className={`flex flex-col items-start gap-1 p-3 rounded-xl border text-left transition-colors ${theme === value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
                <Icon size={20} className={theme === value ? 'text-buddy-green' : 'text-buddy-text-secondary'} />
                <span className="text-sm font-medium">{label}</span>
                <span className="text-[10px] text-buddy-text-secondary leading-tight">{desc}</span>
              </button>
            ))}
          </div>
        </Card>

        <Card className="p-4 space-y-3">
          <p className="text-sm font-medium mb-1">App icon</p>
          <div className="grid grid-cols-2 gap-2">
            {[
              { value: 'logo' as const, label: 'BuddyUp logo', desc: 'The platform mark', src: '/icons/icon-192.png' },
              { value: 'clock' as const, label: 'Clock', desc: 'Alternate stopwatch mark', src: '/icons/icon-clock-192.png' },
            ].map(({ value, label, desc, src }) => (
              <button key={value} onClick={() => setAppIcon(value)}
                aria-pressed={appIcon === value}
                className={`flex items-center gap-3 p-3 rounded-xl border text-left transition-colors ${appIcon === value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
                <img src={src} alt="" className="w-10 h-10 rounded-xl flex-shrink-0" />
                <span>
                  <span className="block text-sm font-medium">{label}</span>
                  <span className="block text-[10px] text-buddy-text-secondary leading-tight">{desc}</span>
                </span>
              </button>
            ))}
          </div>
          <p className="text-[11px] text-buddy-text-secondary">Changes your tab icon and home-screen icon on this device.</p>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div className="pr-3">
              <p className="text-sm font-medium">Reduced Motion</p>
              <p className="text-xs text-buddy-text-secondary">Minimise animations and transitions across the app (on this device).</p>
            </div>
            <Toggle checked={reducedMotion} onCheckedChange={handleReducedMotion} label="Reduced motion" />
          </div>
        </Card>

        <Card className="p-4">
          <p className="text-sm font-medium mb-1">Accessibility</p>
          <p className="text-xs text-buddy-text-secondary">WCAG AA compliant. Touch targets minimum 48px. Screen reader support.</p>
          <button onClick={() => window.open('mailto:support@buddyup.com?subject=Accessibility', '_blank')}
            className="text-xs text-buddy-green hover:text-buddy-green-deep mt-2">
            Report an accessibility issue
          </button>
        </Card>
      </div>
    </SectionShell>
  );
}
