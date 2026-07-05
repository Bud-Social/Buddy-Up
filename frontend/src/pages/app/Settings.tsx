import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronRight, Shield, Bell, Lock, CreditCard, HelpCircle, User, Eye, Moon, Sun, Globe, Volume2, Trash2, UserX, Download, Smartphone, CheckCircle, XCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Avatar } from '@/components/ui/Avatar';
import { useAuthStore } from '@/store/authStore';
import { useThemeStore } from '@/store/themeStore';
import { profilesApi, authApi } from '@/api';

const sections = [
  { id: 'account', label: 'Account', icon: User, desc: 'Profile, email, phone, linked accounts' },
  { id: 'privacy', label: 'Privacy', icon: Eye, desc: 'Manage visibility, activity status, blocking' },
  { id: 'notifications', label: 'Notifications', icon: Bell, desc: 'Push, email, and in-app preferences' },
  { id: 'security', label: 'Security', icon: Lock, desc: '2FA, active sessions, login alerts' },
  { id: 'blocked', label: 'Blocked Users', icon: UserX, desc: 'Manage blocked accounts' },
  { id: 'content', label: 'Content Preferences', icon: Globe, desc: 'Mature content, profanity filter, language' },
  { id: 'billing', label: 'Subscription & Billing', icon: CreditCard, desc: 'Manage gym subscriptions and billing' },
  { id: 'appearance', label: 'Appearance', icon: Sun, desc: 'Dark/light mode, accessibility' },
  { id: 'help', label: 'Help & Safety', icon: HelpCircle, desc: 'Report, guidelines, support, accessibility' },
  { id: 'data', label: 'Your Data', icon: Download, desc: 'Export data, deactivate, or delete account' },
];

export default function Settings() {
  const navigate = useNavigate();
  const [activeSection, setActiveSection] = useState<string | null>(null);
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const setProfile = useAuthStore((s) => s.setProfile);
  const logout = useAuthStore((s) => s.logout);
  const theme = useThemeStore((s) => s.theme);
  const toggleTheme = useThemeStore((s) => s.toggle);
  const [blockedUsers, setBlockedUsers] = useState<unknown[]>([]);
  const [deleteConfirm, setDeleteConfirm] = useState('');
  const [isDeactivating, setIsDeactivating] = useState(false);
  const [isExporting, setIsExporting] = useState(false);

  const [totpEnabled, setTotpEnabled] = useState(false);
  const [totpDisablePassword, setTotpDisablePassword] = useState('');
  const [totpDisableError, setTotpDisableError] = useState('');
  const [isDisablingTotp, setIsDisablingTotp] = useState(false);

  useEffect(() => {
    if (activeSection === 'blocked') {
      profilesApi.getBlocked().then((res) => setBlockedUsers(res.data || [])).catch(() => {});
    }
    if (activeSection === 'security') {
      setTotpEnabled(user?.totp_enabled || false);
    }
  }, [activeSection, user]);

  const handleDeactivate = async () => {
    setIsDeactivating(true);
    try { await authApi.logout(); logout(); navigate('/'); } catch {} finally { setIsDeactivating(false); }
  };

  const handleDelete = async () => {
    if (deleteConfirm !== 'delete my account') return;
    try { await authApi.logout(); logout(); navigate('/'); } catch {}
  };

  const handleExport = async () => {
    setIsExporting(true);
    try {
      setTimeout(() => setIsExporting(false), 2000);
    } catch { setIsExporting(false); }
  };

  const handleDisableTotp = async () => {
    setTotpDisableError('');
    setIsDisablingTotp(true);
    try {
      await authApi.disableTotp(totpDisablePassword);
      setTotpEnabled(false);
      setTotpDisablePassword('');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setTotpDisableError(data?.message || 'Failed to disable 2FA.');
    } finally {
      setIsDisablingTotp(false);
    }
  };

  if (!activeSection) {
    return (
      <div className="max-w-lg mx-auto p-4">
        <h1 className="font-display text-2xl font-extrabold mb-6">Settings</h1>
        <div className="space-y-2">
          {sections.map(({ id, label, icon: Icon, desc }) => (
            <Card key={id} className="p-4 flex items-center gap-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
              onClick={() => setActiveSection(id)}>
              <div className="w-10 h-10 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
                <Icon size={20} className="text-buddy-green" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium text-sm">{label}</p>
                <p className="text-xs text-buddy-text-secondary">{desc}</p>
              </div>
              <ChevronRight size={18} className="text-buddy-text-secondary" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg mx-auto p-4">
      <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-4">← Settings</Button>

      {activeSection === 'account' && (
        <div className="space-y-6">
          <h2 className="font-heading text-xl font-semibold">Account</h2>
          <Card className="p-6 text-center">
            <Avatar src={profile?.avatar_url} alt={profile?.display_name || 'You'} size="xl" showRepRing className="mx-auto mb-3" />
            <h3 className="font-heading font-semibold">{profile?.display_name}</h3>
            <p className="text-sm text-buddy-text-secondary">@{profile?.username}</p>
            <Button variant="outline" size="sm" className="mt-3" onClick={() => navigate('/profile/edit')}>Edit Profile</Button>
          </Card>
          <Card className="p-4 space-y-3">
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Email</span><span className="text-sm">{user?.email || '—'}</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Phone</span><span className="text-sm">Not set</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Role</span><span className="text-sm capitalize">{profile?.role || 'User'}</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Verified</span><span className="text-sm">{profile?.verification_status || 'None'}</span></div>
          </Card>
          <Button variant="outline" className="w-full" size="sm">Change Password</Button>
        </div>
      )}

      {activeSection === 'privacy' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Privacy</h2>
          {[
            { label: 'Account visibility', desc: 'Who can see your profile', value: 'Public' },
            { label: 'Who can send buddy requests', desc: '', value: 'Everyone' },
            { label: 'Who can message me', desc: '', value: 'Buddies Only' },
            { label: 'Show activity status', desc: 'Display when you\'re online', value: 'On' },
            { label: 'Show my gyms', desc: 'Who sees your gym memberships', value: 'Buddies' },
            { label: 'Allow anonymous posting', desc: 'Post without showing your identity', value: 'Off' },
            { label: 'Data for personalisation', desc: 'Use your data to improve recommendations', value: 'On' },
          ].map(({ label, desc, value }) => (
            <Card key={label} className="p-4">
              <div className="flex justify-between items-center">
                <div><p className="text-sm font-medium">{label}</p>{desc && <p className="text-xs text-buddy-text-secondary">{desc}</p>}</div>
                <div className="flex items-center gap-2">
                  <span className="text-xs text-buddy-text-secondary">{value}</span>
                  <ChevronRight size={14} className="text-buddy-text-secondary" />
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {activeSection === 'notifications' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Notifications</h2>
          <Card className="p-4 space-y-4">
            {['Push notifications', 'Email notifications', 'In-app notifications'].map((label) => (
              <div key={label} className="flex items-center justify-between">
                <span className="text-sm">{label}</span>
                <div className="w-10 h-6 rounded-full bg-buddy-green relative">
                  <div className="absolute right-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
                </div>
              </div>
            ))}
          </Card>
          <h3 className="font-heading font-semibold text-sm mt-4">Per-Category Settings</h3>
          <Card className="p-4 space-y-3">
            {['Buddy requests', 'Buddy accepted', 'New followers', 'Comments', 'Live starting', 'Session reminders', 'Streak milestones', 'Accountability pings'].map((label) => (
              <div key={label} className="flex items-center justify-between">
                <span className="text-sm">{label}</span>
                <div className="w-10 h-6 rounded-full bg-buddy-green relative">
                  <div className="absolute right-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
                </div>
              </div>
            ))}
          </Card>
          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Quiet Hours</p>
            <p className="text-xs text-buddy-text-secondary">No notifications: 10 PM – 6 AM</p>
          </Card>
        </div>
      )}

      {activeSection === 'security' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Security</h2>

          <Card className="p-4">
            <div className="flex items-start gap-3">
              <Smartphone size={20} className="text-buddy-green mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Two-Factor Authentication</p>
                <p className="text-xs text-buddy-text-secondary mt-0.5">
                  {totpEnabled ? 'Your account is protected with an authenticator app.' : 'Add an extra layer of security to your account.'}
                </p>
                <div className="flex items-center gap-2 mt-2">
                  {totpEnabled ? (
                    <>
                      <CheckCircle size={14} className="text-buddy-green" />
                      <span className="text-xs text-buddy-green font-medium">Enabled</span>
                    </>
                  ) : (
                    <>
                      <XCircle size={14} className="text-buddy-text-secondary" />
                      <span className="text-xs text-buddy-text-secondary">Disabled</span>
                    </>
                  )}
                </div>
              </div>
            </div>
            <div className="mt-3 space-y-2">
              {totpEnabled ? (
                <>
                  <Button variant="ghost" size="sm" className="text-buddy-red" onClick={() => setTotpDisablePassword(' ')}>
                    Disable 2FA
                  </Button>
                  {totpDisablePassword.length > 0 && (
                    <div className="space-y-2 pt-2 border-t border-buddy-surface-raised">
                      <p className="text-xs text-buddy-text-secondary">Enter your password to disable 2FA:</p>
                      <Input
                        type="password"
                        value={totpDisablePassword}
                        onChange={(e) => setTotpDisablePassword(e.target.value)}
                        placeholder="Current password"
                      />
                      {totpDisableError && <p className="text-xs text-buddy-red">{totpDisableError}</p>}
                      <div className="flex gap-2">
                        <Button size="sm" variant="ghost" onClick={() => { setTotpDisablePassword(''); setTotpDisableError(''); }}>Cancel</Button>
                        <Button size="sm" variant="destructive" onClick={handleDisableTotp} isLoading={isDisablingTotp} disabled={!totpDisablePassword}>
                          Confirm Disable
                        </Button>
                      </div>
                    </div>
                  )}
                </>
              ) : (
                <Button variant="outline" size="sm" onClick={() => navigate('/totp-setup')}>
                  <Smartphone size={14} className="mr-1" /> Enable 2FA
                </Button>
              )}
            </div>
          </Card>

          <Card className="p-4">
            <p className="text-sm font-medium mb-2">Active Sessions</p>
            <div className="space-y-2">
              <div className="flex items-center justify-between text-sm">
                <span>Current device · Windows</span>
                <span className="text-xs text-buddy-green">Active now</span>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Login Alerts</p>
            <p className="text-xs text-buddy-text-secondary">Get notified when your account is accessed from a new device or location.</p>
          </Card>
          <Button variant="destructive" className="w-full" size="sm">Sign Out All Devices</Button>
        </div>
      )}

      {activeSection === 'blocked' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Blocked Users</h2>
          {blockedUsers.length === 0 ? (
            <Card className="p-8 text-center"><UserX size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" /><p className="text-sm text-buddy-text-secondary">No blocked users</p></Card>
          ) : (
            (blockedUsers as { username: string; display_name: string; avatar_url: string }[]).map((u) => (
              <Card key={u.username} className="p-3 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Avatar src={u.avatar_url} alt={u.display_name} size="sm" />
                  <p className="text-sm font-medium">{u.display_name}</p>
                </div>
                <Button size="sm" variant="ghost" onClick={() => profilesApi.unblock(u.username)}>Unblock</Button>
              </Card>
            ))
          )}
        </div>
      )}

      {activeSection === 'content' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Content Preferences</h2>
          <Card className="p-4 space-y-3">
            {[
              { label: 'Mature content', desc: 'Sensitive health & transformation content (18+ only)', on: false },
              { label: 'Profanity filter', desc: 'Filter explicit language in your feed', on: true },
            ].map(({ label, desc, on }) => (
              <div key={label} className="flex items-center justify-between">
                <div><p className="text-sm font-medium">{label}</p><p className="text-xs text-buddy-text-secondary">{desc}</p></div>
                <div className={`w-10 h-6 rounded-full relative ${on ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
                  <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${on ? 'right-0.5' : 'left-0.5'}`} />
                </div>
              </div>
            ))}
          </Card>
        </div>
      )}

      {activeSection === 'billing' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Subscription & Billing</h2>
          <Card className="p-4 space-y-2">
            <div className="flex justify-between"><span className="text-sm">Current Plan</span><span className="text-sm font-medium text-buddy-green">Free</span></div>
            <p className="text-xs text-buddy-text-secondary">Upgrade to Premium or Trainer Pro for more features.</p>
          </Card>
          <Card className="p-4 space-y-2">
            <p className="text-sm font-medium">Active Gym Subscriptions</p>
            <p className="text-xs text-buddy-text-secondary">No active paid gym subscriptions.</p>
          </Card>
          <Card className="p-4 space-y-2">
            <p className="text-sm font-medium">Billing History</p>
            <p className="text-xs text-buddy-text-secondary">View all transactions in your Wallet.</p>
            <Button variant="outline" size="sm" onClick={() => navigate('/wallet')}>Go to Wallet</Button>
          </Card>
        </div>
      )}

      {activeSection === 'appearance' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Appearance</h2>
          <Card className="p-4 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                {theme === 'dark' ? <Moon size={20} className="text-buddy-electric" /> : <Sun size={20} className="text-buddy-gold" />}
                <p className="text-sm font-medium">{theme === 'dark' ? 'Dark Mode' : 'Light Mode'}</p>
              </div>
              <button onClick={toggleTheme} className="text-sm text-buddy-green hover:text-buddy-green-deep">
                Switch to {theme === 'dark' ? 'Light' : 'Dark'}
              </button>
            </div>
          </Card>
          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Reduced Motion</p>
            <p className="text-xs text-buddy-text-secondary">Respects your system preference for reduced motion.</p>
          </Card>
          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Accessibility</p>
            <p className="text-xs text-buddy-text-secondary">WCAG AA compliant. Touch targets minimum 48px. Screen reader support.</p>
          </Card>
        </div>
      )}

      {activeSection === 'help' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Help & Safety</h2>
          <div className="space-y-2">
            {[
              { label: 'Report a Problem', desc: 'Report bugs, abusive content, or safety concerns' },
              { label: 'Community Guidelines', desc: 'Read our rules for respectful interaction' },
              { label: 'Safety Centre', desc: 'Resources and tools for staying safe', link: '/community-guidelines' },
              { label: 'Terms of Service', desc: 'Our terms and conditions', link: '/terms' },
              { label: 'Privacy Policy', desc: 'How we handle your data', link: '/privacy' },
              { label: 'Cookie Policy', desc: 'How we use cookies', link: '/cookie-policy' },
              { label: 'Contact Support', desc: 'Email us at support@buddyup.app' },
            ].map(({ label, desc, link }) => (
              <Card key={label} className="p-4 hover:bg-buddy-surface-raised cursor-pointer transition-colors"
                onClick={() => link && navigate(link)}>
                <p className="text-sm font-medium">{label}</p>
                <p className="text-xs text-buddy-text-secondary">{desc}</p>
              </Card>
            ))}
          </div>
        </div>
      )}

      {activeSection === 'data' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Your Data</h2>

          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Export Your Data</p>
            <p className="text-xs text-buddy-text-secondary mb-3">Download all your data as a JSON archive. Includes profile, posts, messages, transactions, and sessions.</p>
            <Button variant="outline" size="sm" onClick={handleExport} isLoading={isExporting}>
              <Download size={14} className="mr-1" /> Request Export
            </Button>
          </Card>

          <Card className="p-4 border-buddy-orange/30 bg-buddy-orange/5">
            <p className="text-sm font-medium text-buddy-orange">Deactivate Account</p>
            <p className="text-xs text-buddy-text-secondary mb-3">Your profile will be hidden but recoverable for 30 days. Log in during this period to reactivate.</p>
            <Button variant="ghost" size="sm" className="text-buddy-orange" onClick={handleDeactivate} isLoading={isDeactivating}>
              Deactivate Account
            </Button>
          </Card>

          <Card className="p-4 border-buddy-red/30 bg-buddy-red/5">
            <p className="text-sm font-medium text-buddy-red">Delete Account</p>
            <p className="text-xs text-buddy-text-secondary mb-3">Permanently delete your account and all associated data. This cannot be undone. 30-day grace period applies.</p>
            <Input value={deleteConfirm} onChange={(e) => setDeleteConfirm(e.target.value)}
              placeholder='Type "delete my account" to confirm' className="mb-3" />
            <Button variant="destructive" size="sm" onClick={handleDelete} disabled={deleteConfirm !== 'delete my account'}>
              <Trash2 size={14} className="mr-1" /> Delete Account
            </Button>
          </Card>
        </div>
      )}
    </div>
  );
}
