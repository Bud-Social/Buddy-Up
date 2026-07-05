import { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Radio, Play, Clock, Users, Loader, Zap } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { BuddyButton } from '@/components/features/profiles/BuddyButton';
import { profilesApi } from '@/api';
import { livesApi } from '@/api/lives';
import ReplayPlayer from '@/components/live/ReplayPlayer';
import type { Profile } from '@/types';
import type { BuddyLive } from '@/types/live';

type ProfileTab = 'posts' | 'lives';

export default function UserProfile() {
  const { username } = useParams();
  const navigate = useNavigate();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isFollowing, setIsFollowing] = useState(false);
  const [followLoading, setFollowLoading] = useState(false);
  const [pingLoading, setPingLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<ProfileTab>('posts');

  const [lives, setLives] = useState<BuddyLive[]>([]);
  const [livesLoading, setLivesLoading] = useState(false);
  const [replayLive, setReplayLive] = useState<BuddyLive | null>(null);

  const fetchProfile = useCallback(async () => {
    if (!username) return;
    setIsLoading(true);
    try {
      const res = await profilesApi.getProfile(username);
      setProfile(res.data);
      setIsFollowing((res.data as { is_following?: boolean }).is_following || false);
    } catch {} finally {
      setIsLoading(false);
    }
  }, [username]);

  useEffect(() => { fetchProfile(); }, [fetchProfile]);

  const handleFollowToggle = async () => {
    if (!username) return;
    setFollowLoading(true);
    try {
      if (isFollowing) {
        await profilesApi.unfollow(username);
        setIsFollowing(false);
      } else {
        await profilesApi.follow(username);
        setIsFollowing(true);
      }
    } catch {} finally {
      setFollowLoading(false);
    }
  };

  const handlePing = async () => {
    if (!username) return;
    setPingLoading(true);
    try {
      await profilesApi.ping(username, "How's your workout going? 💪");
    } catch {} finally {
      setPingLoading(false);
    }
  };

  const fetchLives = async () => {
    if (!profile?.username) return;
    setLivesLoading(true);
    try {
      const res = await livesApi.getUserLives(profile.username);
      setLives(res.data || []);
    } catch {} finally {
      setLivesLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'lives' && profile?.username) fetchLives();
  }, [activeTab, profile?.username]);

  if (isLoading) return (
    <div className="max-w-lg mx-auto p-4">
      <div className="animate-pulse space-y-4">
        <div className="bg-buddy-surface rounded-2xl h-72" />
        <div className="bg-buddy-surface rounded-2xl h-32" />
      </div>
    </div>
  );

  if (!profile) return (
    <div className="max-w-lg mx-auto p-4 text-center py-20">
      <p className="text-buddy-text-secondary text-lg">User not found</p>
      <p className="text-buddy-text-secondary/50 text-sm mt-1">The profile you're looking for doesn't exist or was removed.</p>
    </div>
  );

  const badgeConfig = profile.verification_status === 'email' ? { variant: 'blue' as const, label: 'Email Verified', icon: '✓' }
    : profile.verification_status === 'id' ? { variant: 'silver' as const, label: 'ID Verified', icon: '✓' }
    : profile.verification_status === 'trainer' ? { variant: 'green' as const, label: 'Certified Trainer', icon: '✓' }
    : profile.verification_status === 'practitioner' ? { variant: 'gold' as const, label: 'Health Practitioner', icon: '✓' }
    : null;

  const isBuddy = (profile as { is_buddy?: boolean }).is_buddy;

  return (
    <div className="max-w-lg mx-auto p-4">
      <Card className="p-6 mb-6">
        <div className="text-center mb-4">
          <Avatar
            src={profile.avatar_url}
            alt={profile.display_name}
            size="xl"
            showRepRing
            streakProgress={profile.streak_days > 0 ? Math.min(profile.streak_days / 365 * 100, 100) : 0}
            className="mx-auto"
          />
          <h2 className="font-heading text-xl font-semibold mt-3">{profile.display_name}</h2>
          <p className="text-buddy-text-secondary text-sm">@{profile.username}</p>
          {badgeConfig && <Badge variant={badgeConfig.variant} label={badgeConfig.label} icon={badgeConfig.icon} className="mt-1.5" />}
          {profile.role !== 'user' && (
            <p className="text-xs text-buddy-electric mt-1">
              {profile.role === 'trainer' ? 'Personal Trainer' : 'Health Practitioner'}
            </p>
          )}
          {profile.bio && <p className="text-sm mt-2 px-4">{profile.bio}</p>}
          {profile.location_city && (
            <p className="text-xs text-buddy-text-secondary mt-1">
              📍 {profile.location_city}{profile.location_country && `, ${profile.location_country}`}
            </p>
          )}
          <p className="text-xs text-buddy-text-secondary mt-1">Buddy since 2025</p>
        </div>

        <div className="flex gap-3 mb-4">
          {[
            { value: profile.buddy_count, label: 'Buddies' },
            { value: profile.following_count, label: 'Following' },
            { value: profile.follower_count, label: 'Followers' },
          ].map(({ value, label }) => (
            <div key={label} className="flex-1 text-center bg-buddy-surface-raised rounded-xl py-2">
              <p className="font-mono font-bold text-lg">{value}</p>
              <p className="text-xs text-buddy-text-secondary">{label}</p>
            </div>
          ))}
        </div>

        {profile.streak_days > 0 && (
          <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl px-4 py-2.5 mb-4 text-center">
            <span className="text-lg">🔥</span>
            <span className="font-mono font-bold text-buddy-orange ml-1">{profile.streak_days}</span>
            <span className="text-sm text-buddy-text-secondary ml-1">day streak</span>
          </div>
        )}

        <BuddyButton profile={profile} size="md" />

        <div className="flex gap-2 mt-2">
          <Button
            variant="ghost"
            size="sm"
            className="flex-1"
            onClick={handleFollowToggle}
            isLoading={followLoading}
          >
            {isFollowing ? 'Following ✓' : 'Follow'}
          </Button>

          {isBuddy && (
            <Button
              variant="ghost"
              size="sm"
              className="flex-1"
              onClick={handlePing}
              isLoading={pingLoading}
            >
              <Zap size={14} className="mr-1" />
              Ping
            </Button>
          )}
        </div>
      </Card>

      <div className="flex border-b border-buddy-surface mb-4">
        {(['posts', 'lives'] as ProfileTab[]).map((tab) => (
          <button key={tab} onClick={() => setActiveTab(tab)}
            className={`flex-1 pb-3 text-sm font-medium capitalize ${activeTab === tab ? 'text-buddy-green border-b-2 border-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{tab}</button>
        ))}
      </div>

      {activeTab === 'lives' ? (
        livesLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader size={24} className="animate-spin text-buddy-text-secondary" />
          </div>
        ) : lives.length === 0 ? (
          <div className="text-center py-20">
            <Radio size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-buddy-text-secondary">No lives yet</p>
          </div>
        ) : (
          <div className="space-y-3">
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
      ) : (
        <div className="grid grid-cols-3 gap-1">
          {Array.from({ length: 9 }).map((_, i) => (
            <div key={i} className="aspect-square bg-buddy-surface rounded-lg" />
          ))}
        </div>
      )}

      {replayLive && (
        <ReplayPlayer
          title={replayLive.title}
          hostName={replayLive.host?.display_name || 'Unknown'}
          replayUrl={replayLive.replay_url}
          muxPlaybackId={replayLive.mux_playback_id}
          onClose={() => setReplayLive(null)}
        />
      )}
    </div>
  );
}
