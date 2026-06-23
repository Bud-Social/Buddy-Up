import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { useAuthStore } from '@/store/authStore';
import { useThemeStore } from '@/store/themeStore';
import { profilesApi } from '@/api';

type ProfileTab = 'posts' | 'lives' | 'gyms' | 'achievements';

export default function Profile() {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const setProfile = useAuthStore((s) => s.setProfile);
  const logout = useAuthStore((s) => s.logout);
  const theme = useThemeStore((s) => s.theme);
  const toggleTheme = useThemeStore((s) => s.toggle);

  const [activeTab, setActiveTab] = useState<ProfileTab>('posts');
  const [isEditing, setIsEditing] = useState(false);
  const [editBio, setEditBio] = useState(profile?.bio || '');
  const [editDisplayName, setEditDisplayName] = useState(profile?.display_name || '');
  const [isSaving, setIsSaving] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const res = await profilesApi.updateProfile({ bio: editBio, display_name: editDisplayName });
      setProfile(res.data);
      setIsEditing(false);
    } catch {} finally {
      setIsSaving(false);
    }
  };

  if (!profile) return null;

  const badgeConfig = profile.verification_status === 'email' ? { variant: 'blue' as const, label: 'Email Verified', icon: '✓' }
    : profile.verification_status === 'id' ? { variant: 'silver' as const, label: 'ID Verified', icon: '✓' }
    : profile.verification_status === 'trainer' ? { variant: 'green' as const, label: 'Certified Trainer', icon: '✓' }
    : profile.verification_status === 'practitioner' ? { variant: 'gold' as const, label: 'Health Practitioner', icon: '✓' }
    : null;

  return (
    <div className="max-w-lg mx-auto p-4">
      <Card className="p-6 mb-6">
        <div className="flex items-start gap-4 mb-4">
          <Avatar src={profile.avatar_url} alt={profile.display_name} size="xl" showRepRing streakProgress={profile.streak_days > 0 ? Math.min(profile.streak_days / 365 * 100, 100) : 0} />
          <div className="flex-1 min-w-0">
            {isEditing ? (
              <div className="space-y-2">
                <Input value={editDisplayName} onChange={(e) => setEditDisplayName(e.target.value)} placeholder="Display name" />
                <Input value={editBio} onChange={(e) => setEditBio(e.target.value)} placeholder="Bio" />
                <div className="flex gap-2">
                  <Button size="sm" onClick={handleSave} isLoading={isSaving}>Save</Button>
                  <Button size="sm" variant="ghost" onClick={() => setIsEditing(false)}>Cancel</Button>
                </div>
              </div>
            ) : (
              <>
                <h2 className="font-heading text-xl font-semibold truncate">{profile.display_name}</h2>
                <p className="text-buddy-text-secondary text-sm">@{profile.username}</p>
                {badgeConfig && <Badge variant={badgeConfig.variant} label={badgeConfig.label} icon={badgeConfig.icon} className="mt-1" />}
                <p className="text-sm text-buddy-text-primary mt-1">{profile.bio || 'No bio yet'}</p>
                <p className="text-xs text-buddy-text-secondary mt-1">
                  {profile.location_city && `${profile.location_city} · `}{profile.role === 'trainer' ? 'Personal Trainer' : profile.role === 'practitioner' ? 'Health Practitioner' : 'Regular User'}
                </p>
              </>
            )}
          </div>
        </div>

        <div className="flex gap-3 mb-4">
          {[
            { value: profile.buddy_count, label: 'Buddies' },
            { value: profile.following_count, label: 'Following' },
            { value: profile.follower_count, label: 'Followers' },
            { value: profile.gym_count, label: 'Gyms' },
          ].map(({ value, label }) => (
            <div key={label} className="flex-1 text-center bg-buddy-surface-raised rounded-xl py-2">
              <p className="font-mono font-bold text-lg">{value}</p>
              <p className="text-xs text-buddy-text-secondary">{label}</p>
            </div>
          ))}
        </div>

        {profile.streak_days > 0 && (
          <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl px-4 py-3 mb-4 text-center">
            <span className="text-lg">🔥</span>
            <span className="font-mono font-bold text-buddy-orange ml-1">{profile.streak_days}</span>
            <span className="text-sm text-buddy-text-secondary ml-1">day streak</span>
          </div>
        )}

        {!isEditing && <Button variant="outline" className="w-full mb-2" onClick={() => { setEditBio(profile.bio || ''); setEditDisplayName(profile.display_name); setIsEditing(true); }}>Edit Profile</Button>}
        <div className="flex gap-2">
          <Button variant="ghost" size="sm" className="flex-1" onClick={toggleTheme}>
            {theme === 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode'}
          </Button>
          <Button variant="ghost" size="sm" className="flex-1 text-buddy-red hover:text-buddy-red" onClick={handleLogout}>Sign Out</Button>
        </div>
      </Card>

      <div className="flex border-b border-buddy-surface mb-4">
        {(['posts', 'lives', 'gyms', 'achievements'] as ProfileTab[]).map((tab) => (
          <button key={tab} onClick={() => setActiveTab(tab)}
            className={`flex-1 pb-3 text-sm font-medium capitalize ${activeTab === tab ? 'text-buddy-green border-b-2 border-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{tab}</button>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-1">
        {Array.from({ length: 9 }).map((_, i) => (
          <div key={i} className="aspect-square bg-buddy-surface rounded-lg" />
        ))}
      </div>
    </div>
  );
}
