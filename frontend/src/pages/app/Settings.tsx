import { useState } from 'react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { useAuthStore } from '@/store/authStore';
import { ChevronRight, Shield, Bell, Lock, CreditCard, HelpCircle, User, Eye } from 'lucide-react';

const sections = [
  { id: 'account', label: 'Account', icon: User, desc: 'Edit profile, email, phone, password' },
  { id: 'privacy', label: 'Privacy', icon: Eye, desc: 'Manage visibility, activity status, blocking' },
  { id: 'notifications', label: 'Notifications', icon: Bell, desc: 'Push, email, and in-app preferences' },
  { id: 'security', label: 'Security', icon: Lock, desc: '2FA, active sessions, login alerts' },
  { id: 'subscription', label: 'Subscription & Billing', icon: CreditCard, desc: 'Manage gym subscriptions and billing' },
  { id: 'help', label: 'Help & Safety', icon: HelpCircle, desc: 'Report, guidelines, support, accessibility' },
];

export default function Settings() {
  const [activeSection, setActiveSection] = useState<string | null>(null);
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const logout = useAuthStore((s) => s.logout);

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">Settings</h1>

      {!activeSection && (
        <div className="space-y-2">
          {sections.map(({ id, label, icon: Icon, desc }) => (
            <Card key={id} className="p-4 flex items-center gap-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => setActiveSection(id)}>
              <div className="w-10 h-10 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
                <Icon size={20} className="text-buddy-green" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium">{label}</p>
                <p className="text-xs text-buddy-text-secondary">{desc}</p>
              </div>
              <ChevronRight size={18} className="text-buddy-text-secondary" />
            </Card>
          ))}

          <Button variant="ghost" className="w-full mt-6 text-buddy-red hover:text-buddy-red" onClick={() => { logout(); }}>Sign Out</Button>
        </div>
      )}

      {activeSection === 'account' && (
        <div className="space-y-4">
          <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-2">← Back</Button>
          <h2 className="font-heading text-lg font-semibold">Account</h2>
          <Card className="p-4 space-y-2">
            <p className="text-sm"><span className="text-buddy-text-secondary">Email:</span> {user?.email || '—'}</p>
            <p className="text-sm"><span className="text-buddy-text-secondary">Username:</span> @{profile?.username || '—'}</p>
            <p className="text-sm"><span className="text-buddy-text-secondary">Role:</span> {profile?.role || 'Regular User'}</p>
          </Card>
          <Button variant="outline" className="w-full">Change Password</Button>
          <Button variant="ghost" className="w-full text-buddy-red">Deactivate Account</Button>
          <Button variant="destructive" className="w-full">Delete Account</Button>
        </div>
      )}

      {activeSection === 'privacy' && (
        <div className="space-y-4">
          <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-2">← Back</Button>
          <h2 className="font-heading text-lg font-semibold">Privacy</h2>
          <div className="space-y-3">
            {[
              { label: 'Account visibility', value: 'Public', desc: 'Who can see your profile' },
              { label: 'Who can send buddy requests', value: 'Everyone', desc: '' },
              { label: 'Who can message me', value: 'Buddies Only', desc: '' },
              { label: 'Show activity status', value: 'On', desc: '' },
              { label: 'Show my gyms', value: 'Buddies', desc: '' },
            ].map(({ label, value, desc }) => (
              <Card key={label} className="p-4 flex items-center justify-between">
                <div><p className="text-sm font-medium">{label}</p>{desc && <p className="text-xs text-buddy-text-secondary">{desc}</p>}</div>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-buddy-text-secondary">{value}</span>
                  <ChevronRight size={14} className="text-buddy-text-secondary" />
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}

      {activeSection === 'notifications' && (
        <div className="space-y-4">
          <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-2">← Back</Button>
          <h2 className="font-heading text-lg font-semibold">Notification Preferences</h2>
          <div className="space-y-3">
            {[
              { label: 'Push notifications', key: 'push_enabled' },
              { label: 'Email notifications', key: 'email_enabled' },
              { label: 'In-app notifications', key: 'in_app_enabled' },
            ].map(({ label, key }) => (
              <Card key={key} className="p-4 flex items-center justify-between">
                <span className="text-sm">{label}</span>
                <div className="w-10 h-6 rounded-full bg-buddy-green relative cursor-pointer">
                  <div className="absolute right-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
                </div>
              </Card>
            ))}
          </div>
          <h3 className="font-heading font-semibold text-sm mt-4 mb-2">Per-Category Settings</h3>
          <div className="space-y-2">
            {['Buddy requests', 'Buddy accepted', 'New followers', 'Comments', 'Live starting', 'Session reminders', 'Streak milestones', 'Accountability pings'].map((label) => (
              <Card key={label} className="p-3 flex items-center justify-between">
                <span className="text-sm">{label}</span>
                <div className="w-10 h-6 rounded-full bg-buddy-green relative cursor-pointer">
                  <div className="absolute right-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
                </div>
              </Card>
            ))}
          </div>
          <div className="mt-4">
            <h3 className="font-heading font-semibold text-sm mb-2">Quiet Hours</h3>
            <Card className="p-4">
              <p className="text-sm text-buddy-text-secondary">No notifications between 10 PM and 6 AM</p>
            </Card>
          </div>
        </div>
      )}

      {activeSection === 'security' && (
        <div className="space-y-4">
          <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-2">← Back</Button>
          <h2 className="font-heading text-lg font-semibold">Security</h2>
          <Card className="p-4 space-y-2">
            <p className="text-sm text-buddy-text-secondary">Two-Factor Authentication</p>
            <Button variant="outline" size="sm">Enable 2FA</Button>
          </Card>
          <Card className="p-4">
            <p className="text-sm font-medium mb-2">Active Sessions</p>
            <p className="text-xs text-buddy-text-secondary">Current device · Active now</p>
          </Card>
          <Button variant="destructive" className="w-full">Sign Out All Devices</Button>
        </div>
      )}
    </div>
  );
}
