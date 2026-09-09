import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Camera, Loader, LogOut } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Avatar } from '@/components/ui/Avatar';
import { CropModal } from '@/components/ui/CropModal';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { profilesApi, authApi } from '@/api';
import { SectionShell } from './SectionShell';

export default function Account() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const profile = useAuthStore((s) => s.profile);
  const user = useAuthStore((s) => s.user);
  const setProfile = useAuthStore((s) => s.setProfile);
  const logout = useAuthStore((s) => s.logout);
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [cropImage, setCropImage] = useState<string | null>(null);
  const [changePwForm, setChangePwForm] = useState({ current_password: '', new_password: '', confirm: '' });
  const [changePwLoading, setChangePwLoading] = useState(false);
  const [changePwError, setChangePwError] = useState('');
  const [changePwSuccess, setChangePwSuccess] = useState('');

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

  return (
    <SectionShell title="Account">
      <div className="space-y-6">
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
      {cropImage && (
        <CropModal
          imageUrl={cropImage}
          onCrop={handleAvatarCropDone}
          onClose={() => { setCropImage(null); URL.revokeObjectURL(cropImage); }}
        />
      )}
    </SectionShell>
  );
}
