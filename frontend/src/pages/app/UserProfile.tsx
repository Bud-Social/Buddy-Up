import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';

export default function UserProfile() {
  const { username } = useParams();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [buddyStatus, setBuddyStatus] = useState<string | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    if (!username) return;
    setIsLoading(true);
    profilesApi.getProfile(username)
      .then((res) => {
        setProfile(res.data);
        if ((res.data as { is_buddy?: boolean }).is_buddy) setBuddyStatus('confirmed');
        else if ((res.data as { buddy_status?: string }).buddy_status === 'pending') setBuddyStatus('pending');
        setIsFollowing((res.data as { is_following?: boolean }).is_following || false);
      })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [username]);

  const handleBuddyAction = async () => {
    if (!username) return;
    setActionLoading(true);
    try {
      if (buddyStatus === 'confirmed') {
        await profilesApi.removeBuddy(username);
        setBuddyStatus(null);
      } else if (buddyStatus === 'pending') {
        // Request already sent - could cancel here
      } else {
        await profilesApi.sendBuddyRequest(username);
        setBuddyStatus('pending');
      }
    } catch {}
    setActionLoading(false);
  };

  const handleFollowToggle = async () => {
    if (!username) return;
    setActionLoading(true);
    try {
      if (isFollowing) {
        await profilesApi.unfollow(username);
        setIsFollowing(false);
      } else {
        await profilesApi.follow(username);
        setIsFollowing(true);
      }
    } catch {}
    setActionLoading(false);
  };

  if (isLoading) return <div className="max-w-lg mx-auto p-4"><div className="animate-pulse space-y-4"><div className="bg-buddy-surface rounded-2xl h-64" /><div className="bg-buddy-surface rounded-2xl h-32" /></div></div>;
  if (!profile) return <div className="max-w-lg mx-auto p-4 text-center py-20"><p className="text-buddy-text-secondary text-lg">User not found</p></div>;

  const badgeConfig = profile.verification_status === 'email' ? { variant: 'blue' as const, label: 'Email Verified', icon: '✓' }
    : profile.verification_status === 'id' ? { variant: 'silver' as const, label: 'ID Verified', icon: '✓' }
    : profile.verification_status === 'trainer' ? { variant: 'green' as const, label: 'Certified Trainer', icon: '✓' }
    : profile.verification_status === 'practitioner' ? { variant: 'gold' as const, label: 'Health Practitioner', icon: '✓' }
    : null;

  return (
    <div className="max-w-lg mx-auto p-4">
      <Card className="p-6 mb-6">
        <div className="text-center mb-4">
          <Avatar src={profile.avatar_url} alt={profile.display_name} size="xl" showRepRing streakProgress={profile.streak_days > 0 ? Math.min(profile.streak_days / 365 * 100, 100) : 0} className="mx-auto" />
          <h2 className="font-heading text-xl font-semibold mt-3">{profile.display_name}</h2>
          <p className="text-buddy-text-secondary text-sm">@{profile.username}</p>
          {badgeConfig && <Badge variant={badgeConfig.variant} label={badgeConfig.label} icon={badgeConfig.icon} className="mt-1" />}
          <p className="text-sm mt-1">{profile.bio || ''}</p>
          <p className="text-xs text-buddy-text-secondary mt-1">
            {profile.location_city && `${profile.location_city}, `}{profile.location_country || ''}
          </p>
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

        <div className="flex gap-2">
          <Button className="flex-1" onClick={handleBuddyAction} isLoading={actionLoading}>
            {buddyStatus === 'confirmed' ? 'Buddied ✓' : buddyStatus === 'pending' ? 'Requested' : 'Buddy Up'}
          </Button>
          <Button variant="outline" className="flex-1" onClick={handleFollowToggle}>
            {isFollowing ? 'Following ✓' : 'Follow'}
          </Button>
        </div>
      </Card>
    </div>
  );
}
