import {
  Activity, Bell, CreditCard, Download, Eye, Globe, HelpCircle, Lock,
  Shield, Sun, User, UserX, UsersRound,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

export interface SettingsSectionMeta {
  id: string;
  label: string;
  icon: LucideIcon;
  desc: string;
}

/** Ordered metadata for the Settings hub grid and the /settings/:section router. */
export const SETTINGS_SECTIONS: SettingsSectionMeta[] = [
  { id: 'account', label: 'Account', icon: User, desc: 'Profile, email, phone, linked accounts' },
  { id: 'verifications', label: 'Verifications', icon: Shield, desc: 'Age & professional verification' },
  { id: 'privacy', label: 'Privacy', icon: Eye, desc: 'Visibility, activity status, content rating' },
  { id: 'notifications', label: 'Notifications', icon: Bell, desc: 'Push, email, quiet hours, categories' },
  { id: 'security', label: 'Security', icon: Lock, desc: '2FA, passkeys, active sessions' },
  { id: 'blocked', label: 'Blocked Users', icon: UserX, desc: 'Manage blocked accounts' },
  { id: 'activity', label: 'Activity Log', icon: Activity, desc: 'View your account activity history' },
  { id: 'content', label: 'Content Preferences', icon: Globe, desc: 'Mature content, profanity filter' },
  { id: 'billing', label: 'Subscription & Billing', icon: CreditCard, desc: 'Wallet and gym subscriptions' },
  { id: 'appearance', label: 'Appearance', icon: Sun, desc: 'Theme, reduced motion, accessibility' },
  { id: 'family', label: 'Family', icon: UsersRound, desc: 'Guardian links and parental co-ownership' },
  { id: 'help', label: 'Help & Safety', icon: HelpCircle, desc: 'Report, guidelines, support, accessibility' },
  { id: 'data', label: 'Your Data', icon: Download, desc: 'Export data, deactivate, or delete account' },
];

/** Pure: valid section ids map to themselves; anything else is null so the
 * router can redirect /settings/<bad> → /settings. */
export function resolveSettingsSection(section: string | undefined): SettingsSectionMeta | null {
  if (!section) return null;
  return SETTINGS_SECTIONS.find((s) => s.id === section) ?? null;
}
