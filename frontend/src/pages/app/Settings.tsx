import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { ChevronRight, Shield, Bell, Lock, CreditCard, HelpCircle, User, Eye, Moon, Sun, Globe, Trash2, UserX, Download, Smartphone, CheckCircle, XCircle, Camera, Loader, LogOut, Activity, Monitor, Contrast, BrainCircuit } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Avatar } from '@/components/ui/Avatar';
import { CropModal } from '@/components/ui/CropModal';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { useThemeStore } from '@/store/themeStore';
import { profilesApi, authApi, notificationsApi, activityApi } from '@/api';
import type { NotificationPreferences } from '@/api/notifications';
import type { ActivityEvent } from '@/api/activity';
import { AgeVerificationCard, BadgeApplicationForm } from '@/components/settings/VerificationCards';
import { PasskeyCard, RecoveryCodesCard } from '@/components/settings/SecurityExtras';

const sections = [
  { id: 'account', label: 'Account', icon: User, desc: 'Profile, email, phone, linked accounts' },
  { id: 'verifications', label: 'Verifications', icon: Shield, desc: 'Age & professional verification' },
  { id: 'privacy', label: 'Privacy', icon: Eye, desc: 'Manage visibility, activity status, blocking' },
  { id: 'notifications', label: 'Notifications', icon: Bell, desc: 'Push, email, and in-app preferences' },
  { id: 'security', label: 'Security', icon: Lock, desc: '2FA, active sessions, login alerts' },
  { id: 'blocked', label: 'Blocked Users', icon: UserX, desc: 'Manage blocked accounts' },
  { id: 'activity', label: 'Activity Log', icon: Activity, desc: 'View your account activity history' },
  { id: 'content', label: 'Content Preferences', icon: Globe, desc: 'Mature content, profanity filter, language' },
  { id: 'billing', label: 'Subscription & Billing', icon: CreditCard, desc: 'Manage gym subscriptions and billing' },
  { id: 'appearance', label: 'Appearance', icon: Sun, desc: 'Dark/light mode, accessibility' },
  { id: 'help', label: 'Help & Safety', icon: HelpCircle, desc: 'Report, guidelines, support, accessibility' },
  { id: 'data', label: 'Your Data', icon: Download, desc: 'Export data, deactivate, or delete account' },
];

export default function Settings() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [activeSection, setActiveSection] = useState<string | null>(null);
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const setProfile = useAuthStore((s) => s.setProfile);
  const logout = useAuthStore((s) => s.logout);
  const theme = useThemeStore((s) => s.theme);
  const setTheme = useThemeStore((s) => s.setTheme);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const [blockedUsers, setBlockedUsers] = useState<unknown[]>([]);
  const [deleteConfirm, setDeleteConfirm] = useState('');
  const [isDeactivating, setIsDeactivating] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [exportMessage, setExportMessage] = useState('');

  const [totpEnabled, setTotpEnabled] = useState(false);
  const [totpDisablePassword, setTotpDisablePassword] = useState('');
  const [totpDisableError, setTotpDisableError] = useState('');
  const [isDisablingTotp, setIsDisablingTotp] = useState(false);

  const [notifPrefs, setNotifPrefs] = useState<NotificationPreferences | null>(null);
  const [notifLoading, setNotifLoading] = useState(false);

  const [consentStatus, setConsentStatus] = useState<Awaited<ReturnType<typeof authApi.getConsentStatus>>['data'] | null>(null);
  const [consentLoading, setConsentLoading] = useState(false);

  const [sessions, setSessions] = useState<Array<{ id: string; device_name: string; ip_address: string; location: string; last_active: string; is_current: boolean }>>([]);
  const [sessionsLoading, setSessionsLoading] = useState(false);
  const [logoutAllLoading, setLogoutAllLoading] = useState(false);

  const [changePwForm, setChangePwForm] = useState({ current_password: '', new_password: '', confirm: '' });
  const [changePwLoading, setChangePwLoading] = useState(false);
  const [changePwError, setChangePwError] = useState('');
  const [changePwSuccess, setChangePwSuccess] = useState('');

  const [privacyForm, setPrivacyForm] = useState({
    privacy_level: profile?.privacy_level || 'public' as 'public' | 'private',
    show_active_status: profile?.show_active_status ?? true,
    is_anonymous_posting: profile?.is_anonymous_posting ?? false,
  });
  const [privacySaving, setPrivacySaving] = useState(false);
  const [privacySaved, setPrivacySaved] = useState(false);

  const [activityEvents, setActivityEvents] = useState<ActivityEvent[]>([]);
  const [activityLoading, setActivityLoading] = useState(false);
  const [activityType, setActivityType] = useState('');

  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [cropImage, setCropImage] = useState<string | null>(null);

  useEffect(() => {
    if (activeSection === 'blocked') {
      profilesApi.getBlocked().then((res) => setBlockedUsers(res.data || [])).catch(() => {});
    }
    if (activeSection === 'security') {
      setTotpEnabled(user?.totp_enabled || false);
      setSessionsLoading(true);
      authApi.getSessions().then((res) => setSessions(res.data || [])).catch(() => {}).finally(() => setSessionsLoading(false));
    }
    if (activeSection === 'notifications') {
      setNotifLoading(true);
      notificationsApi.getPreferences().then((res) => setNotifPrefs(res.data)).catch(() => {}).finally(() => setNotifLoading(false));
    }
    if (activeSection === 'privacy') {
      setPrivacyForm({
        privacy_level: profile?.privacy_level || 'public',
        show_active_status: profile?.show_active_status ?? true,
        is_anonymous_posting: profile?.is_anonymous_posting ?? false,
      });
    }
    if (activeSection === 'activity') {
      setActivityLoading(true);
      activityApi.getActivityLog(activityType || undefined).then((res) => setActivityEvents(res.data || [])).catch(() => {}).finally(() => setActivityLoading(false));
    }
    if (activeSection === 'data' && !consentStatus) {
      setConsentLoading(true);
      authApi.getConsentStatus().then((res) => setConsentStatus(res.data)).catch(() => {}).finally(() => setConsentLoading(false));
    }
  }, [activeSection, user, profile, consentStatus]);

  const handleAvatarFileSelected = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const url = URL.createObjectURL(file);
    setCropImage(url);
    e.target.value = '';
  };

  const handleAvatarCropDone = async (blob: Blob) => {
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' });
    setUploadingAvatar(true);
    try {
      const res = await profilesApi.uploadAvatar(file);
      setProfile({ ...profile!, avatar_url: res.data.avatar_url });
      toast('success', 'Avatar updated');
    } catch {
      toast('error', 'Failed to upload avatar');
    } finally {
      setUploadingAvatar(false);
      setCropImage(null);
    }
  };

  const handleDeactivate = async () => {
    setIsDeactivating(true);
    try {
      await authApi.deactivateAccount();
      toast('success', 'Account deactivated');
      logout();
      navigate('/');
    } catch {
      toast('error', 'Failed to deactivate account');
    } finally {
      setIsDeactivating(false);
    }
  };

  const handleDelete = async () => {
    if (deleteConfirm !== 'delete my account') return;
    try {
      await authApi.deleteAccount(deleteConfirm);
      toast('success', 'Account deleted');
      logout();
      navigate('/');
    } catch {
      toast('error', 'Failed to delete account');
    }
  };

  const handleExport = async () => {
    setIsExporting(true);
    setExportMessage('');
    try {
      await authApi.exportData();
      setExportMessage('Data export requested. You will receive a download link via email when ready.');
      toast('success', 'Export requested');
    } catch {
      setExportMessage('Failed to request export. Please try again.');
      toast('error', 'Export failed');
    } finally {
      setIsExporting(false);
    }
  };

  const handleDisableTotp = async () => {
    setTotpDisableError('');
    setIsDisablingTotp(true);
    try {
      await authApi.disableTotp(totpDisablePassword);
      setTotpEnabled(false);
      setTotpDisablePassword('');
      toast('success', '2FA disabled');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setTotpDisableError(data?.message || 'Failed to disable 2FA.');
    } finally {
      setIsDisablingTotp(false);
    }
  };

  const handleChangePassword = async () => {
    setChangePwError('');
    setChangePwSuccess('');
    if (changePwForm.new_password !== changePwForm.confirm) {
      setChangePwError('Passwords do not match.');
      return;
    }
    if (changePwForm.new_password.length < 8) {
      setChangePwError('Password must be at least 8 characters.');
      return;
    }
    setChangePwLoading(true);
    try {
      // Social sign-ups have no password yet — the endpoint accepts a new
      // password without the current one for those accounts.
      const hasPassword = user?.has_password ?? true;
      if (hasPassword) {
        await authApi.changePassword(changePwForm.current_password, changePwForm.new_password);
      } else {
        await authApi.setPassword(changePwForm.new_password);
      }
      setChangePwSuccess(hasPassword ? 'Password changed successfully.' : 'Password set successfully. You can now log in with your email and password.');
      toast('success', hasPassword ? 'Password changed' : 'Password set');
      setChangePwForm({ current_password: '', new_password: '', confirm: '' });
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setChangePwError(data?.message || 'Failed to change password.');
    } finally {
      setChangePwLoading(false);
    }
  };

  const handlePrivacySave = async () => {
    setPrivacySaving(true);
    setPrivacySaved(false);
    try {
      const res = await profilesApi.updateProfile(privacyForm);
      setProfile(res.data);
      setPrivacySaved(true);
      toast('success', 'Privacy settings saved');
      setTimeout(() => setPrivacySaved(false), 2000);
    } catch {
      toast('error', 'Failed to save privacy settings');
    } finally {
      setPrivacySaving(false);
    }
  };

  const handleNotifToggle = async (key: keyof NotificationPreferences) => {
    if (!notifPrefs) return;
    const updated = { ...notifPrefs, [key]: !notifPrefs[key] };
    setNotifPrefs(updated);
    try {
      const res = await notificationsApi.updatePreferences({ [key]: updated[key] });
      setNotifPrefs(res.data);
    } catch {
      toast('error', 'Failed to update notification setting');
    }
  };

  const handleLogoutAll = async () => {
    setLogoutAllLoading(true);
    try {
      await authApi.logoutAllSessions();
      setSessions([]);
      toast('success', 'Signed out of all devices');
    } catch {
      toast('error', 'Failed to sign out other devices');
    } finally {
      setLogoutAllLoading(false);
    }
  };

  if (!activeSection) {
    return (
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
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
          {user?.is_staff && (
            <Card className="p-4 flex items-center gap-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
              onClick={() => navigate('/admin')}>
              <div className="w-10 h-10 rounded-xl bg-buddy-electric/10 flex items-center justify-center flex-shrink-0">
                <BrainCircuit size={20} className="text-buddy-electric" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-medium text-sm">ML Admin</p>
                <p className="text-xs text-buddy-text-secondary">Model registry, training runs & system health</p>
              </div>
              <ChevronRight size={18} className="text-buddy-text-secondary" />
            </Card>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24">
      <Button variant="ghost" onClick={() => setActiveSection(null)} className="mb-4">← Settings</Button>

      {activeSection === 'account' && (
        <div className="space-y-6">
          <h2 className="font-heading text-xl font-semibold">Account</h2>
          <Card className="p-6 text-center">
            <div className="relative inline-block">
              <Avatar src={profile?.avatar_url} alt={profile?.display_name || 'You'} size="xl" showRepRing className="mx-auto mb-3" />
              <button onClick={() => avatarInputRef.current?.click()}
                className="absolute bottom-2 right-0 p-1.5 rounded-full bg-buddy-green text-buddy-black hover:bg-buddy-green-deep transition-colors z-10"
                disabled={uploadingAvatar}>
                {uploadingAvatar ? <Loader size={14} className="animate-spin" /> : <Camera size={14} />}
              </button>
              <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarFileSelected} />
            </div>
            <h3 className="font-heading font-semibold">{profile?.display_name}</h3>
            <p className="text-sm text-buddy-text-secondary">@{profile?.username}</p>
            <Button variant="outline" size="sm" className="mt-3" onClick={() => navigate('/profile/edit')}>Edit Profile</Button>
          </Card>
          <Card className="p-4 space-y-3">
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Email</span><span className="text-sm">{user?.email || '—'}</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Phone</span><span className="text-sm">{user?.phone || 'Not set'}</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Role</span><span className="text-sm capitalize">{profile?.role || 'User'}</span></div>
            <div className="flex justify-between"><span className="text-sm text-buddy-text-secondary">Verified</span><span className="text-sm">{profile?.verification_status || 'None'}</span></div>
          </Card>
          <div className="space-y-2">
            {changePwSuccess && <p className="text-xs text-buddy-green">{changePwSuccess}</p>}
            {changePwError && <p className="text-xs text-buddy-red">{changePwError}</p>}
            {!(user?.has_password === false) && (
              <Input type="password" value={changePwForm.current_password} onChange={(e) => setChangePwForm(p => ({ ...p, current_password: e.target.value }))} placeholder="Current password" />
            )}
            {user?.has_password === false && (
              <p className="text-xs text-buddy-text-secondary">You signed up with a social account — set a password to also log in with your email.</p>
            )}
            <Input type="password" value={changePwForm.new_password} onChange={(e) => setChangePwForm(p => ({ ...p, new_password: e.target.value }))} placeholder="New password (min 8 chars)" />
            <Input type="password" value={changePwForm.confirm} onChange={(e) => setChangePwForm(p => ({ ...p, confirm: e.target.value }))} placeholder="Confirm new password" />
            <Button variant="outline" className="w-full" size="sm" onClick={handleChangePassword} isLoading={changePwLoading}>
              {user?.has_password === false ? 'Set Password' : 'Change Password'}
            </Button>
          </div>
          <Card className="p-4">
            <button
              onClick={() => { logout(); navigate('/login'); }}
              className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl border border-buddy-red/40 text-buddy-red hover:bg-buddy-red/10 transition-colors text-sm font-semibold"
            >
              <LogOut size={15} /> Sign Out
            </button>
            <p className="text-[11px] text-buddy-text-secondary mt-2 text-center">
              You can also sign out of every device from Security → Sessions.
            </p>
          </Card>
        </div>
      )}

      {activeSection === 'privacy' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Privacy</h2>
          {privacySaved && <p className="text-xs text-buddy-green">Privacy settings saved.</p>}
          <Card className="p-4 space-y-4">
            <div className="flex items-center justify-between">
              <div><p className="text-sm font-medium">Account visibility</p><p className="text-xs text-buddy-text-secondary">Who can see your profile</p></div>
              <select value={privacyForm.privacy_level} onChange={(e) => setPrivacyForm(p => ({ ...p, privacy_level: e.target.value as 'public' | 'private' }))}
                className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-1.5 border border-buddy-surface text-buddy-text-primary outline-none">
                <option value="public">Public</option>
                <option value="private">Private</option>
              </select>
            </div>
            <div className="flex items-center justify-between">
              <div><p className="text-sm font-medium">Show activity status</p><p className="text-xs text-buddy-text-secondary">Display when you're online</p></div>
              <button onClick={() => setPrivacyForm(p => ({ ...p, show_active_status: !p.show_active_status }))}
                className={`w-10 h-6 rounded-full relative transition-colors ${privacyForm.show_active_status ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
                <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${privacyForm.show_active_status ? 'right-0.5' : 'left-0.5'}`} />
              </button>
            </div>
            <div className="flex items-center justify-between">
              <div><p className="text-sm font-medium">Anonymous posting</p><p className="text-xs text-buddy-text-secondary">Post without showing your identity</p></div>
              <button onClick={() => setPrivacyForm(p => ({ ...p, is_anonymous_posting: !p.is_anonymous_posting }))}
                className={`w-10 h-6 rounded-full relative transition-colors ${privacyForm.is_anonymous_posting ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
                <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${privacyForm.is_anonymous_posting ? 'right-0.5' : 'left-0.5'}`} />
              </button>
            </div>
          </Card>
          <Button variant="outline" className="w-full" size="sm" onClick={handlePrivacySave} isLoading={privacySaving}>Save Privacy Settings</Button>
        </div>
      )}

      {activeSection === 'verifications' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Verifications</h2>
          <AgeVerificationCard />
          <Card className="p-4 space-y-4">
            <div>
              <p className="text-sm font-medium">Professional Verification</p>
              <p className="text-xs text-buddy-text-secondary mb-2">Apply for a Trainer or Practitioner badge. Required for hosting paid sessions.</p>
              <BadgeApplicationForm />
            </div>
          </Card>
        </div>
      )}

      {activeSection === 'notifications' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Notifications</h2>
          {notifLoading ? (
            <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
          ) : notifPrefs ? (
            <>
              <Card className="p-4 space-y-4">
                <h3 className="font-heading text-sm font-semibold">Channels</h3>
                {[
                  { key: 'push_enabled' as keyof NotificationPreferences, label: 'Push notifications' },
                  { key: 'email_enabled' as keyof NotificationPreferences, label: 'Email notifications' },
                  { key: 'in_app_enabled' as keyof NotificationPreferences, label: 'In-app notifications' },
                ].map(({ key, label }) => (
                  <div key={key} className="flex items-center justify-between">
                    <span className="text-sm">{label}</span>
                    <button onClick={() => handleNotifToggle(key)}
                      className={`w-10 h-6 rounded-full relative transition-colors ${notifPrefs[key] ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
                      <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${notifPrefs[key] ? 'right-0.5' : 'left-0.5'}`} />
                    </button>
                  </div>
                ))}
              </Card>
              <Card className="p-4 space-y-3">
                <h3 className="font-heading text-sm font-semibold">Categories</h3>
                {([
                  { key: 'buddy_request_push' as keyof NotificationPreferences, label: 'Buddy requests' },
                  { key: 'buddy_accepted_push' as keyof NotificationPreferences, label: 'Buddy accepted' },
                  { key: 'new_follower_push' as keyof NotificationPreferences, label: 'New followers' },
                  { key: 'comment_push' as keyof NotificationPreferences, label: 'Comments' },
                  { key: 'live_starting_push' as keyof NotificationPreferences, label: 'Live starting' },
                  { key: 'session_reminder_push' as keyof NotificationPreferences, label: 'Session reminders' },
                  { key: 'streak_milestone_push' as keyof NotificationPreferences, label: 'Streak milestones' },
                  { key: 'accountability_ping_push' as keyof NotificationPreferences, label: 'Accountability pings' },
                ] as const).map(({ key, label }) => (
                  <div key={key} className="flex items-center justify-between">
                    <span className="text-sm">{label}</span>
                    <button onClick={() => handleNotifToggle(key)}
                      className={`w-10 h-6 rounded-full relative transition-colors ${notifPrefs[key] ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
                      <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${notifPrefs[key] ? 'right-0.5' : 'left-0.5'}`} />
                    </button>
                  </div>
                ))}
              </Card>
              {(notifPrefs.quiet_hours_start || notifPrefs.quiet_hours_end) && (
                <Card className="p-4">
                  <p className="text-sm font-medium mb-1">Quiet Hours</p>
                  <p className="text-xs text-buddy-text-secondary">
                    No notifications: {notifPrefs.quiet_hours_start || '--'} – {notifPrefs.quiet_hours_end || '--'}
                  </p>
                </Card>
              )}
            </>
          ) : (
            <Card className="p-8 text-center"><p className="text-sm text-buddy-text-secondary">Could not load preferences.</p></Card>
          )}
        </div>
      )}

      {activeSection === 'security' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Security</h2>

          <PasskeyCard />
          {totpEnabled && <RecoveryCodesCard />}

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
                    <><CheckCircle size={14} className="text-buddy-green" /><span className="text-xs text-buddy-green font-medium">Enabled</span></>
                  ) : (
                    <><XCircle size={14} className="text-buddy-text-secondary" /><span className="text-xs text-buddy-text-secondary">Disabled</span></>
                  )}
                </div>
              </div>
            </div>
            <div className="mt-3 space-y-2">
              {totpEnabled ? (
                <>
                  <Button variant="ghost" size="sm" className="text-buddy-red" onClick={() => setTotpDisablePassword(' ')}>Disable 2FA</Button>
                  {totpDisablePassword.length > 0 && (
                    <div className="space-y-2 pt-2 border-t border-buddy-surface-raised">
                      <p className="text-xs text-buddy-text-secondary">Enter your password to disable 2FA:</p>
                      <Input type="password" value={totpDisablePassword} onChange={(e) => setTotpDisablePassword(e.target.value)} placeholder="Current password" />
                      {totpDisableError && <p className="text-xs text-buddy-red">{totpDisableError}</p>}
                      <div className="flex gap-2">
                        <Button size="sm" variant="ghost" onClick={() => { setTotpDisablePassword(''); setTotpDisableError(''); }}>Cancel</Button>
                        <Button size="sm" variant="destructive" onClick={handleDisableTotp} isLoading={isDisablingTotp} disabled={!totpDisablePassword}>Confirm Disable</Button>
                      </div>
                    </div>
                  )}
                </>
              ) : (
                <Button variant="outline" size="sm" onClick={() => navigate('/totp-setup')}><Smartphone size={14} className="mr-1" /> Enable 2FA</Button>
              )}
            </div>
          </Card>

          <Card className="p-4">
            <p className="text-sm font-medium mb-3">Active Sessions</p>
            {sessionsLoading ? (
              <Loader size={20} className="animate-spin text-buddy-text-secondary mx-auto" />
            ) : sessions.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">No active sessions found.</p>
            ) : (
              <div className="space-y-3">
                {sessions.map((s) => (
                  <div key={s.id} className="flex items-center justify-between text-sm">
                    <div className="min-w-0">
                      <p className="truncate">{s.device_name || 'Unknown device'}</p>
                      <p className="text-xs text-buddy-text-secondary">{s.ip_address} · {new Date(s.last_active).toLocaleDateString()}</p>
                    </div>
                    {s.is_current ? (
                      <span className="text-xs text-buddy-green flex-shrink-0">Active now</span>
                    ) : (
                      <span className="text-xs text-buddy-text-secondary flex-shrink-0">Last seen {new Date(s.last_active).toLocaleDateString()}</span>
                    )}
                  </div>
                ))}
              </div>
            )}
          </Card>

          <Button variant="destructive" className="w-full" size="sm" onClick={handleLogoutAll} isLoading={logoutAllLoading}>
            <LogOut size={14} className="mr-1" /> Sign Out All Devices
          </Button>
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

      {activeSection === 'activity' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Activity Log</h2>
          <Card className="p-3">
            <select value={activityType} onChange={(e) => { setActivityType(e.target.value); setActivityLoading(true); activityApi.getActivityLog(e.target.value || undefined).then((res) => setActivityEvents(res.data || [])).catch(() => {}).finally(() => setActivityLoading(false)); }}
              className="w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none">
              <option value="">All activity</option>
              <option value="login">Logins</option>
              <option value="password_changed">Password changes</option>
              <option value="2fa_enabled">2FA enabled</option>
              <option value="2fa_disabled">2FA disabled</option>
              <option value="profile_updated">Profile updates</option>
              <option value="avatar_updated">Avatar changes</option>
              <option value="post_created">Posts created</option>
              <option value="buddy_request_sent">Buddy requests</option>
              <option value="account_deactivated">Account deactivated</option>
            </select>
          </Card>
          {activityLoading ? (
            <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
          ) : activityEvents.length === 0 ? (
            <Card className="p-8 text-center"><Activity size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" /><p className="text-sm text-buddy-text-secondary">No activity recorded yet</p></Card>
          ) : (
            <div className="space-y-2">
              {activityEvents.map((e) => (
                <Card key={e.id} className="p-3">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-sm font-medium capitalize">{e.event_type.replace(/_/g, ' ')}</p>
                      <p className="text-xs text-buddy-text-secondary">{new Date(e.created_at).toLocaleString()}</p>
                      {e.ip_address && <p className="text-xs text-buddy-text-secondary">IP: {e.ip_address}</p>}
                    </div>
                    <span className="text-[10px] text-buddy-text-secondary bg-buddy-surface-raised px-2 py-0.5 rounded-full capitalize">
                      {e.event_type.replace(/_/g, ' ')}
                    </span>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      )}

      {activeSection === 'content' && (
        <div className="space-y-4">
          <h2 className="font-heading text-xl font-semibold">Content Preferences</h2>
          <Card className="p-4 space-y-4">
            <div className="flex items-center justify-between">
              <div><p className="text-sm font-medium">Mature content</p><p className="text-xs text-buddy-text-secondary">Sensitive health & transformation content (18+ only)</p></div>
              <div className="w-10 h-6 rounded-full bg-buddy-surface-raised relative">
                <div className="absolute left-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
              </div>
            </div>
            <div className="flex items-center justify-between">
              <div><p className="text-sm font-medium">Profanity filter</p><p className="text-xs text-buddy-text-secondary">Filter explicit language in your feed</p></div>
              <div className="w-10 h-6 rounded-full bg-buddy-green relative">
                <div className="absolute right-0.5 top-0.5 w-5 h-5 rounded-full bg-white shadow" />
              </div>
            </div>
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
          <Card className="p-4 space-y-3">
            <p className="text-sm font-medium mb-1">Theme</p>
            <div className="grid grid-cols-2 gap-2">
              {[
                { value: 'dark' as const, label: 'Dark', icon: Moon, desc: 'Dark backgrounds, light text' },
                { value: 'light' as const, label: 'Light', icon: Sun, desc: 'Light backgrounds, dark text' },
                { value: 'high-contrast' as const, label: 'High Contrast', icon: Contrast, desc: 'Maximum contrast ratio' },
                { value: 'ambient' as const, label: 'Ambient', icon: Monitor, desc: 'Glowing bluish night mode' },
              ].map(({ value, label, icon: Icon, desc }) => (
                <button key={value} onClick={() => setTheme(value)}
                  className={`flex flex-col items-start gap-1 p-3 rounded-xl border text-left transition-colors ${theme === value ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface hover:border-buddy-text-secondary/30'}`}>
                  <Icon size={20} className={theme === value ? 'text-buddy-green' : 'text-buddy-text-secondary'} />
                  <span className="text-sm font-medium">{label}</span>
                  <span className="text-[10px] text-buddy-text-secondary leading-tight">{desc}</span>
                </button>
              ))}
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
              { label: 'Help Centre', desc: 'FAQs, reporting, and support contacts', link: '/help' },
              { label: 'Report a Problem', desc: 'Report bugs, abusive content, or safety concerns', onClick: () => window.open('mailto:support@buddyup.app') },
              { label: 'Community Guidelines', desc: 'Read our rules for respectful interaction', link: '/community-guidelines' },
              { label: 'Safety Centre', desc: 'Resources and tools for staying safe', link: '/community-guidelines' },
              { label: 'Medical Disclaimer', desc: 'Scope of health and wellness information', link: '/medical-disclaimer' },
              { label: 'Sponsorship Policy', desc: 'Gifting and disclosure requirements', link: '/sponsorship-policy' },
              { label: 'Adult Content Policy', desc: 'Rules for the age-gated Mature category', link: '/adult-content-policy' },
              { label: 'Terms of Service', desc: 'Our terms and conditions', link: '/terms' },
              { label: 'Privacy Policy', desc: 'How we handle your data', link: '/privacy' },
              { label: 'Cookie Policy', desc: 'How we use cookies', link: '/cookie-policy' },
              { label: 'Contact Support', desc: 'Email us at support@buddyup.app', onClick: () => window.open('mailto:support@buddyup.app') },
            ].map(({ label, desc, link, onClick }) => (
              <Card key={label} className="p-4 hover:bg-buddy-surface-raised cursor-pointer transition-colors"
                onClick={() => { if (onClick) onClick(); else if (link) navigate(link); }}>
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
            <p className="text-sm font-medium mb-1">Consent & Policy Versions</p>
            <p className="text-xs text-buddy-text-secondary mb-3">The version of each policy you accepted at registration.</p>
            {consentLoading ? (
              <p className="text-xs text-buddy-text-secondary">Loading consent status…</p>
            ) : consentStatus ? (
              <div className="space-y-1.5">
                {Object.entries(consentStatus.policies).map(([key, p]) => (
                  <div key={key} className="flex items-center justify-between gap-3 text-xs">
                    <span className="text-buddy-text-primary capitalize">{key.replace(/_/g, ' ')}</span>
                    <span className="flex items-center gap-2 text-buddy-text-secondary">
                      {p.up_to_date
                        ? <CheckCircle size={13} className="text-buddy-green" />
                        : <XCircle size={13} className="text-buddy-orange" />}
                      v{p.accepted_version || '—'} / current v{p.current_version}
                    </span>
                  </div>
                ))}
                {consentStatus.requires_parental_coowner && (
                  <p className={`text-xs mt-2 ${consentStatus.guardian_verified ? 'text-buddy-green' : 'text-buddy-orange'}`}>
                    {consentStatus.guardian_verified
                      ? 'Parental co-owner verified.'
                      : 'This account requires parental co-owner verification. Contact support to complete it.'}
                  </p>
                )}
              </div>
            ) : (
              <p className="text-xs text-buddy-text-secondary">Could not load consent status.</p>
            )}
          </Card>

          <Card className="p-4">
            <p className="text-sm font-medium mb-1">Export Your Data</p>
            <p className="text-xs text-buddy-text-secondary mb-3">Download all your data as a JSON archive. Includes profile, posts, messages, transactions, and sessions.</p>
            {exportMessage && <p className="text-xs text-buddy-green mb-2">{exportMessage}</p>}
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

      {cropImage && (
        <CropModal
          imageUrl={cropImage}
          onCrop={handleAvatarCropDone}
          onClose={() => { setCropImage(null); URL.revokeObjectURL(cropImage); }}
        />
      )}
    </div>
  );
}
