import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Camera, ArrowLeft, Save, Loader } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { CropModal } from '@/components/ui/CropModal';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';

export default function EditProfile() {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const setProfile = useAuthStore((s) => s.setProfile);
  const { toast } = useToast();
  const avatarInputRef = useRef<HTMLInputElement>(null);
  const coverInputRef = useRef<HTMLInputElement>(null);

  const [form, setForm] = useState({
    display_name: profile?.display_name || '',
    bio: profile?.bio || '',
    pronouns: profile?.pronouns || '',
    location_city: profile?.location_city || '',
    location_country: profile?.location_country || '',
    external_link: profile?.external_link || '',
    privacy_level: profile?.privacy_level || 'public' as Profile['privacy_level'],
    show_active_status: profile?.show_active_status ?? true,
    is_anonymous_posting: profile?.is_anonymous_posting ?? false,
  });
  const [saving, setSaving] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [uploadingCover, setUploadingCover] = useState(false);
  const [avatarUrl, setAvatarUrl] = useState(profile?.avatar_url || '');
  const [coverUrl, setCoverUrl] = useState(profile?.cover_url || '');
  const [cropImage, setCropImage] = useState<string | null>(null);

  if (!profile) {
    navigate('/profile');
    return null;
  }

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
      setAvatarUrl(res.data.avatar_url);
      setProfile({ ...profile!, avatar_url: res.data.avatar_url });
      toast('success', 'Avatar updated');
    } catch {
      toast('error', 'Failed to upload avatar');
    } finally {
      setUploadingAvatar(false);
      setCropImage(null);
    }
  };

  const handleCoverUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingCover(true);
    try {
      const res = await profilesApi.uploadCover(file);
      setCoverUrl(res.data.cover_url);
      setProfile({ ...profile!, cover_url: res.data.cover_url });
      toast('success', 'Cover photo updated');
    } catch {
      toast('error', 'Failed to upload cover');
    } finally {
      setUploadingCover(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await profilesApi.updateProfile(form);
      setProfile(res.data);
      toast('success', 'Profile saved');
      navigate('/profile');
    } catch {
      toast('error', 'Failed to save profile');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 pb-24">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate('/profile')} className="p-1 rounded-lg text-buddy-text-secondary hover:text-buddy-text-primary">
          <ArrowLeft size={22} />
        </button>
        <h1 className="font-display text-xl font-extrabold flex-1">Edit Profile</h1>
        <Button size="sm" onClick={handleSave} isLoading={saving}>
          <Save size={14} className="mr-1" /> Save
        </Button>
      </div>

      <Card className="p-0 mb-6 overflow-hidden">
        <div className="relative h-28 bg-gradient-to-r from-buddy-green/20 to-buddy-electric/20">
          {coverUrl && <img src={coverUrl} alt="" className="w-full h-full object-cover" />}
          <button onClick={() => coverInputRef.current?.click()}
            className="absolute bottom-2 right-2 p-1.5 rounded-full bg-black/60 text-white hover:bg-black/80 transition-colors"
            disabled={uploadingCover}>
            {uploadingCover ? <Loader size={14} className="animate-spin" /> : <Camera size={14} />}
          </button>
          <input ref={coverInputRef} type="file" accept="image/*" className="hidden" onChange={handleCoverUpload} />
        </div>
        <div className="px-4 pb-4">
          <div className="relative -mt-10 w-20 h-20 mb-3">
            <Avatar src={avatarUrl} alt={form.display_name} size="xl" className="ring-4 ring-buddy-black" />
            <button onClick={() => avatarInputRef.current?.click()}
              className="absolute bottom-0 right-0 p-1.5 rounded-full bg-buddy-green text-buddy-black hover:bg-buddy-green-deep transition-colors z-10"
              disabled={uploadingAvatar}>
              {uploadingAvatar ? <Loader size={14} className="animate-spin" /> : <Camera size={14} />}
            </button>
            <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarFileSelected} />
          </div>
        </div>
      </Card>

      <Card className="p-4 mb-4 space-y-4">
        <h2 className="font-heading font-semibold text-sm">Basic Info</h2>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">Display Name</label>
          <Input value={form.display_name} onChange={(e) => setForm(p => ({ ...p, display_name: e.target.value }))} maxLength={50} />
        </div>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">Bio</label>
          <Input value={form.bio} onChange={(e) => setForm(p => ({ ...p, bio: e.target.value }))} maxLength={200} />
        </div>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">Pronouns</label>
          <Input value={form.pronouns} onChange={(e) => setForm(p => ({ ...p, pronouns: e.target.value }))} placeholder="e.g. they/them, he/him, she/her" maxLength={30} />
        </div>
      </Card>

      <Card className="p-4 mb-4 space-y-4">
        <h2 className="font-heading font-semibold text-sm">Location</h2>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">City</label>
          <Input value={form.location_city} onChange={(e) => setForm(p => ({ ...p, location_city: e.target.value }))} maxLength={100} />
        </div>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">Country</label>
          <Input value={form.location_country} onChange={(e) => setForm(p => ({ ...p, location_country: e.target.value }))} maxLength={100} />
        </div>
      </Card>

      <Card className="p-4 mb-4">
        <h2 className="font-heading font-semibold text-sm mb-4">Links</h2>
        <div>
          <label className="text-xs text-buddy-text-secondary mb-1 block">External Link</label>
          <Input value={form.external_link} onChange={(e) => setForm(p => ({ ...p, external_link: e.target.value }))} placeholder="https://" />
        </div>
      </Card>

      <Card className="p-4 mb-4 space-y-4">
        <h2 className="font-heading font-semibold text-sm">Privacy</h2>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm">Profile Visibility</p>
            <p className="text-xs text-buddy-text-secondary">Public = anyone can see; Private = buddies only</p>
          </div>
          <select value={form.privacy_level} onChange={(e) => setForm(p => ({ ...p, privacy_level: e.target.value as Profile['privacy_level'] }))}
            className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-1.5 border border-buddy-surface text-buddy-text-primary outline-none">
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
        </div>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm">Show Active Status</p>
            <p className="text-xs text-buddy-text-secondary">Display when you're online</p>
          </div>
          <button onClick={() => setForm(p => ({ ...p, show_active_status: !p.show_active_status }))}
            className={`w-10 h-6 rounded-full relative transition-colors ${form.show_active_status ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
            <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${form.show_active_status ? 'right-0.5' : 'left-0.5'}`} />
          </button>
        </div>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm">Anonymous Posting</p>
            <p className="text-xs text-buddy-text-secondary">Post without showing your identity</p>
          </div>
          <button onClick={() => setForm(p => ({ ...p, is_anonymous_posting: !p.is_anonymous_posting }))}
            className={`w-10 h-6 rounded-full relative transition-colors ${form.is_anonymous_posting ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`}>
            <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow transition-all ${form.is_anonymous_posting ? 'right-0.5' : 'left-0.5'}`} />
          </button>
        </div>
      </Card>

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
