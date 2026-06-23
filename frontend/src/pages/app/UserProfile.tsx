import { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import { Zap } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { BuddyButton } from '@/components/features/profiles/BuddyButton';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';

export default function UserProfile() {
  const { username } = useParams();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isFollowing, setIsFollowing] = useState(false);
  const [followLoading, setFollowLoading] = useState(false);
  const [pingLoading, setPingLoading] = useState(false);

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

      <div className="grid grid-cols-3 gap-1">
        {Array.from({ length: 9 }).map((_, i) => (
          <div key={i} className="aspect-square bg-buddy-surface rounded-lg" />
        ))}
      </div>
    </div>
  );
}
