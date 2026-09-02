import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Camera, ArrowLeft, Save, Loader, AtSign, Sparkles } from 'lucide-react';
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

  // ── Username change (throttled server-side: 3/day) ──
  const [username, setUsername] = useState(profile?.username || '');
  const [usernameState, setUsernameState] = useState<'idle' | 'checking' | 'available' | 'taken' | 'invalid'>('idle');
  const [changingUsername, setChangingUsername] = useState(false);

  useEffect(() => {
    if (!username || username === (profile?.username || '')) { setUsernameState('idle'); return; }
    if (!/^[a-z0-9_]{3,30}$/.test(username)) { setUsernameState('invalid'); return; }
    setUsernameState('checking');
    const t = setTimeout(() => {
      profilesApi.checkUsername(username)
        .then((res) => setUsernameState(res.data?.available ? 'available' : 'taken'))
        .catch(() => setUsernameState('idle'));
    }, 350);
    return () => clearTimeout(t);
  }, [username, profile?.username]);

  const handleUsernameChange = async () => {
    setChangingUsername(true);
    try {
      const res = await profilesApi.changeUsername(username);
      setProfile(res.data);
      toast('success', 'Username updated');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      toast('error', data?.message || 'Could not change username. Daily limit is 3 changes.');
    } finally {
      setChangingUsername(false);
    }
  };

  // ── Interests (buddy matching) ──
  const GOALS = ['weight_loss', 'muscle_gain', 'endurance', 'flexibility', 'general_wellness', 'nutrition', 'sports_performance', 'rehabilitation', 'mental_health'];
  const GOAL_LABELS: Record<string, string> = { weight_loss: 'Weight Loss', muscle_gain: 'Muscle Gain', endurance: 'Endurance', flexibility: 'Flexibility', general_wellness: 'General Wellness', nutrition: 'Nutrition', sports_performance: 'Sports Performance', rehabilitation: 'Rehabilitation', mental_health: 'Mental Health' };
  const WORKOUTS = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'martial_arts', 'swimming', 'running', 'cycling', 'other'];
  const WORKOUT_LABELS: Record<string, string> = { weights: 'Weights', cardio: 'Cardio', hiit: 'HIIT', yoga: 'Yoga', pilates: 'Pilates', crossfit: 'CrossFit', martial_arts: 'Martial Arts', swimming: 'Swimming', running: 'Running', cycling: 'Cycling', other: 'Other' };
  const prefs = profile?.preferences || {};
  const [goals, setGoals] = useState<string[]>(prefs.primary_goal || []);
  const [workouts, setWorkouts] = useState<string[]>(prefs.preferred_workouts || []);
  const [customInterest, setCustomInterest] = useState(prefs.custom_interests || '');
  const [savingInterests, setSavingInterests] = useState(false);

  const toggle = (item: string, list: string[], set: (v: string[]) => void) =>
    set(list.includes(item) ? list.filter((i) => i !== item) : [...list, item]);

  const handleSaveInterests = async () => {
    setSavingInterests(true);
    try {
      await profilesApi.updateInterests({
        primary_goal: goals,
        preferred_workouts: workouts,
        ...(customInterest.trim() && { custom_interests: customInterest.trim() }),
        ...(prefs.activity_level ? { activity_level: prefs.activity_level } : {}),
        ...(prefs.dietary_preference ? { dietary_preference: prefs.dietary_preference } : {}),
        ...(prefs.preferred_time ? { preferred_time: prefs.preferred_time } : {}),
      });
      setProfile({ ...profile!, preferences: { ...prefs, primary_goal: goals, preferred_workouts: workouts, custom_interests: customInterest.trim() || undefined } });
      toast('success', 'Interests updated');
    } catch {
      toast('error', 'Could not update interests');
    } finally {
      setSavingInterests(false);
    }
  };

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

      <Card className="p-4 mb-4 space-y-3">
        <h2 className="font-heading font-semibold text-sm flex items-center gap-1.5"><AtSign size={14} /> Username</h2>
        <div>
          <Input value={username} onChange={(e) => setUsername(e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, ''))} maxLength={30} />
          <p className={`text-xs mt-1 ${usernameState === 'available' ? 'text-buddy-green' : usernameState === 'taken' || usernameState === 'invalid' ? 'text-red-400' : 'text-buddy-text-secondary'}`}>
            {username === (profile?.username || '') && 'Your current username'}
            {username !== (profile?.username || '') && usernameState === 'available' && '✓ Username available'}
            {usernameState === 'taken' && '✗ That username is already taken'}
            {usernameState === 'invalid' && '3–30 characters — letters, numbers, underscores.'}
            {usernameState === 'checking' && 'Checking availability…'}
          </p>
        </div>
        <p className="text-xs text-buddy-text-secondary">Usernames can be changed up to 3 times per day to prevent impersonation and name-squatting.</p>
        <Button size="sm" variant="outline"
          disabled={username === (profile?.username || '') || usernameState !== 'available'}
          isLoading={changingUsername}
          onClick={handleUsernameChange}>
          Update Username
        </Button>
      </Card>

      <Card className="p-4 mb-4 space-y-4">
        <h2 className="font-heading font-semibold text-sm flex items-center gap-1.5"><Sparkles size={14} /> Interests</h2>
        <p className="text-xs text-buddy-text-secondary -mt-2">Helps Buddies with matching goals find you.</p>
        <div>
          <p className="text-xs text-buddy-text-secondary mb-2">Goals</p>
          <div className="flex flex-wrap gap-2">
            {GOALS.map((g) => (
              <button key={g} type="button" onClick={() => toggle(g, goals, setGoals)}
                className={`px-3 py-1.5 rounded-full text-xs transition-colors ${goals.includes(g) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}>
                {GOAL_LABELS[g]}
              </button>
            ))}
          </div>
        </div>
        <div>
          <p className="text-xs text-buddy-text-secondary mb-2">Workout types</p>
          <div className="flex flex-wrap gap-2">
            {WORKOUTS.map((w) => (
              <button key={w} type="button" onClick={() => toggle(w, workouts, setWorkouts)}
                className={`px-3 py-1.5 rounded-full text-xs transition-colors ${workouts.includes(w) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'}`}>
                {WORKOUT_LABELS[w]}
              </button>
            ))}
          </div>
        </div>
        {workouts.includes('other') && (
          <div>
            <Input label="Other interests" value={customInterest} onChange={(e) => setCustomInterest(e.target.value)}
              placeholder="e.g. climbing, dance, calisthenics…" maxLength={200} />
            <p className="text-xs text-buddy-text-secondary mt-1">Separate multiple interests with commas.</p>
          </div>
        )}
        <Button size="sm" variant="outline" onClick={handleSaveInterests} isLoading={savingInterests}>Save Interests</Button>
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
