import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Radio, Play, Clock, Users, Camera, Settings, Moon, Sun, Monitor, Contrast, Loader, MessageCircle, Shield } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { CropModal } from '@/components/ui/CropModal';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { useThemeStore } from '@/store/themeStore';
import { profilesApi } from '@/api';
import { gymsApi } from '@/api/gyms';
import { livesApi } from '@/api/lives';
import ReplayPlayer from '@/components/live/ReplayPlayer';
import type { BuddyLive } from '@/types/live';
import type { Post } from '@/types';
import type { Gym } from '@/types';
import { PostCard } from '@/components/features/feed/PostCard';

type ProfileTab = 'posts' | 'lives' | 'gyms' | 'achievements';

export default function Profile() {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const setProfile = useAuthStore((s) => s.setProfile);
  const theme = useThemeStore((s) => s.theme);
  const toggleTheme = useThemeStore((s) => s.toggle);
  const { toast } = useToast();
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const [activeTab, setActiveTab] = useState<ProfileTab>('posts');
  const [isEditing, setIsEditing] = useState(false);
  const [editBio, setEditBio] = useState(profile?.bio || '');
  const [editDisplayName, setEditDisplayName] = useState(profile?.display_name || '');
  const [isSaving, setIsSaving] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [avatarUrl, setAvatarUrl] = useState(profile?.avatar_url || '');

  const [lives, setLives] = useState<BuddyLive[]>([]);
  const [livesLoading, setLivesLoading] = useState(false);
  const [replayLive, setReplayLive] = useState<BuddyLive | null>(null);

  const [posts, setPosts] = useState<Post[]>([]);
  const [postsLoading, setPostsLoading] = useState(false);

  const [gyms, setGyms] = useState<Gym[]>([]);
  const [gymsLoading, setGymsLoading] = useState(false);

  const [cropImage, setCropImage] = useState<string | null>(null);

  const fetchLives = async () => {
    if (!profile?.username) return;
    setLivesLoading(true);
    try {
      const res = await livesApi.getUserLives(profile.username, { tab: 'all' });
      setLives(res.data || []);
    } catch {
      toast('error', 'Failed to load lives');
    } finally {
      setLivesLoading(false);
    }
  };

  const fetchPosts = async () => {
    if (!profile?.username) return;
    setPostsLoading(true);
    try {
      const res = await profilesApi.getProfilePosts(profile.username);
      setPosts(res.data || []);
    } catch (err: unknown) {
      const status = (err as { response?: { status?: number } })?.response?.status;
      if (!status || status >= 500) {
        toast('error', 'Could not load posts — tap to retry');
      } else {
        toast('error', 'Failed to load posts');
      }
    } finally {
      setPostsLoading(false);
    }
  };

  const fetchGyms = async () => {
    setGymsLoading(true);
    try {
      const res = await gymsApi.list({ my: true });
      setGyms(res.data || []);
    } catch {
      toast('error', 'Failed to load gyms');
    } finally {
      setGymsLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'lives') fetchLives();
    if (activeTab === 'posts') fetchPosts();
    if (activeTab === 'gyms') fetchGyms();
  }, [activeTab]);

  const handleAvatarFileSelected = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const url = URL.createObjectURL(file);
    setCropImage(url);
    e.target.value = '';
  };

  const handleCropDone = async (blob: Blob) => {
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' });
    setUploadingAvatar(true);
    try {
      const res = await profilesApi.uploadAvatar(file);
      // Cache-bust so any deterministic legacy URL still refreshes visually.
      const fresh = res.data.avatar_url.includes('?')
        ? res.data.avatar_url
        : `${res.data.avatar_url}?v=${Date.now()}`;
      setAvatarUrl(fresh);
      setProfile({ ...profile!, avatar_url: fresh });
      toast('success', 'Avatar updated');
    } catch {
      toast('error', 'Failed to upload avatar');
    } finally {
      setUploadingAvatar(false);
      setCropImage(null);
      URL.revokeObjectURL(cropImage || '');
    }
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const res = await profilesApi.updateProfile({ bio: editBio, display_name: editDisplayName });
      setProfile(res.data);
      setIsEditing(false);
      toast('success', 'Profile updated');
    } catch {
      toast('error', 'Failed to save profile');
    } finally {
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
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <Card className="p-6 mb-6">
        <div className="flex items-start gap-4 mb-4">
          <div className="relative inline-block flex-shrink-0">
            <Avatar src={avatarUrl} alt={profile.display_name} size="xl" showRepRing streakProgress={profile.streak_days > 0 ? Math.min(profile.streak_days / 365 * 100, 100) : 0} verificationStatus={profile.verification_status} />
            <button onClick={() => avatarInputRef.current?.click()}
              className="absolute bottom-0 right-0 p-1.5 rounded-full bg-buddy-green text-buddy-black hover:bg-buddy-green-deep transition-colors shadow-lg z-10"
              disabled={uploadingAvatar}>
              {uploadingAvatar ? <Loader size={14} className="animate-spin" /> : <Camera size={14} />}
            </button>
            <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarFileSelected} />
          </div>
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

        <div className="grid grid-cols-4 gap-2 mb-4">
          {([
            { value: profile.buddy_count, label: 'Buddies', to: '/buddies' },
            { value: profile.following_count, label: 'Following', to: `/${profile.username}/following` },
            { value: profile.follower_count, label: 'Followers', to: `/${profile.username}/followers` },
            { value: profile.gym_count, label: 'Gyms', to: '/gyms?mine=1' },
          ] as { value: number; label: string; to: string }[]).map(({ value, label, to }) => (
            <button
              key={label}
              onClick={() => navigate(to)}
              className="text-center bg-buddy-surface-raised hover:bg-buddy-surface rounded-xl py-2 transition-colors"
              title={`View ${label.toLowerCase()}`}
            >
              <p className="font-mono font-bold text-lg">{value}</p>
              <p className="text-xs text-buddy-text-secondary">{label}</p>
            </button>
          ))}
        </div>

        {profile.streak_days > 0 && (
          <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl px-4 py-3 mb-4 text-center">
            <span className="text-lg">🔥</span>
            <span className="font-mono font-bold text-buddy-orange ml-1">{profile.streak_days}</span>
            <span className="text-sm text-buddy-text-secondary ml-1">day streak</span>
          </div>
        )}

        {!isEditing && (
          <div className="flex gap-2 mb-2">
            <Button variant="outline" className="flex-1" onClick={() => setIsEditing(true)}>Edit Profile</Button>
            <Button variant="outline" onClick={() => navigate('/verification')} className="flex-1 gap-1.5" disabled={profile.verification_status !== 'none' && profile.verification_status !== 'email'}>
              <Shield size={16} />
              Verify
            </Button>
            <Button variant="outline" onClick={() => navigate('/settings')} aria-label="Settings">
              <Settings size={16} />
            </Button>
          </div>
        )}
        <div className="flex gap-2">
          <Button variant="ghost" size="sm" className="flex-1 gap-1.5" onClick={toggleTheme}>
            {theme === 'dark' && <><Moon size={14} /> Dark</>}
            {theme === 'light' && <><Sun size={14} /> Light</>}
            {theme === 'high-contrast' && <><Contrast size={14} /> High Contrast</>}
            {theme === 'ambient' && <><Monitor size={14} /> Ambient</>}
          </Button>
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
        {activeTab === 'posts' ? (
          postsLoading ? (
            <div className="col-span-3 flex items-center justify-center py-20">
              <Loader size={24} className="animate-spin text-buddy-text-secondary" />
            </div>
          ) : posts.length === 0 ? (
            <div className="col-span-3 text-center py-20">
              <MessageCircle size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
              <p className="text-buddy-text-secondary">No posts yet</p>
            </div>
          ) : (
            <div className="col-span-3 space-y-2">
              {posts.map((post) => (
                <PostCard key={post.id} post={post} />
              ))}
            </div>
          )
        ) : activeTab === 'lives' ? (
          livesLoading ? (
            <div className="col-span-3 flex items-center justify-center py-20">
              <Loader size={24} className="animate-spin text-buddy-text-secondary" />
            </div>
          ) : lives.length === 0 ? (
            <div className="col-span-3 text-center py-20">
              <Radio size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
              <p className="text-buddy-text-secondary">No lives yet</p>
              <Button size="sm" variant="outline" className="mt-3" onClick={() => navigate('/lives')}>Start a Live</Button>
            </div>
          ) : (
            <div className="col-span-3 space-y-3">
              {lives.map((live) => (
                <Card key={live.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
                  onClick={() => live.status === 'live' ? navigate(`/live/${live.id}`) : null}>
                  <div className="flex items-start gap-3">
                    <div className="relative">
                      <Avatar src={live.host?.avatar_url} alt={live.host?.display_name || 'User'} size="lg" />
                      {live.status === 'live' && (
                        <div className="absolute -top-1 -right-1 w-4 h-4 bg-buddy-red rounded-full border-2 border-buddy-black animate-pulse" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-heading font-semibold text-sm truncate">{live.title}</h3>
                      <p className="text-xs text-buddy-text-secondary mt-0.5 capitalize">{live.live_type.replace(/_/g, ' ')} · {live.category}</p>
                      <div className="flex items-center gap-3 mt-2 text-xs text-buddy-text-secondary">
                        <span className="flex items-center gap-1"><Users size={12} /> {live.viewer_peak || 0}</span>
                        {live.status === 'live' && <span className="flex items-center gap-1 text-buddy-red"><Radio size={12} /> LIVE</span>}
                        {live.scheduled_for && <span className="flex items-center gap-1"><Clock size={12} /> {new Date(live.scheduled_for).toLocaleDateString()}</span>}
                        {live.status === 'ended' && live.replay_url && (
                          <Button size="sm" variant="outline" className="ml-auto gap-1.5"
                            onClick={(e) => { e.stopPropagation(); setReplayLive(live); }}>
                            <Play size={12} /> Watch
                          </Button>
                        )}
                      </div>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          )
        ) : activeTab === 'gyms' ? (
          gymsLoading ? (
            <div className="col-span-3 flex items-center justify-center py-20">
              <Loader size={24} className="animate-spin text-buddy-text-secondary" />
            </div>
          ) : gyms.length === 0 ? (
            <div className="col-span-3 text-center py-20">
              <p className="text-buddy-text-secondary">No gyms joined yet</p>
              <Button size="sm" variant="outline" className="mt-3" onClick={() => navigate('/gyms')}>Browse Gyms</Button>
            </div>
          ) : (
            <div className="col-span-3 space-y-2">
              {gyms.map((gym) => (
                <Card key={gym.id} className="p-3 flex items-center gap-3 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
                  onClick={() => navigate(`/gym/${gym.handle}`)}>
                  <Avatar src={gym.logo_url} alt={gym.name} size="md" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{gym.name}</p>
                    <p className="text-xs text-buddy-text-secondary truncate">{gym.location_city}{gym.location_country ? `, ${gym.location_country}` : ''}</p>
                  </div>
                  <span className="text-xs text-buddy-text-secondary">{gym.member_count} members</span>
                </Card>
              ))}
            </div>
          )
        ) : (
          <div className="col-span-3 text-center py-20">
            <p className="text-buddy-text-secondary">Achievements coming soon</p>
          </div>
        )}
      </div>

      {replayLive && (
        <ReplayPlayer
          title={replayLive.title}
          hostName={replayLive.host?.display_name || 'Unknown'}
          replayUrl={replayLive.replay_url}
          muxPlaybackId={replayLive.mux_playback_id}
          onClose={() => setReplayLive(null)}
        />
      )}

      {cropImage && (
        <CropModal
          imageUrl={cropImage}
          onCrop={handleCropDone}
          onClose={() => { setCropImage(null); URL.revokeObjectURL(cropImage); }}
        />
      )}
    </div>
  );
}
