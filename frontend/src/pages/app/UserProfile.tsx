import { useState, useEffect, useCallback, useMemo } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import {
  Radio,
  Play,
  Clock,
  Users,
  Loader,
  Zap,
  MessageCircle,
  ArrowLeft,
  UserPlus,
  UserCheck,
  Repeat,
  ExternalLink,
  MapPin,
  Calendar,
  Dumbbell,
  Sparkles,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { BuddyButton } from '@/components/features/profiles/BuddyButton';
import { useToast } from '@/components/ui/Toast';
import { InterestChips } from '@/components/profile/InterestChips';
import { profilesApi, messagingApi } from '@/api';
import { livesApi } from '@/api/lives';
import ReplayPlayer from '@/components/live/ReplayPlayer';
import type { Profile, Post } from '@/types';
import type { BuddyLive } from '@/types/live';
import { PostCard } from '@/components/features/feed/PostCard';
import { CommentSheet } from '@/components/features/feed/CommentSheet';

type ProfileTab = 'posts' | 'reposts' | 'interests' | 'lives';

export default function UserProfile() {
  const { username } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { toast } = useToast();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isFollowing, setIsFollowing] = useState(false);
  const [followLoading, setFollowLoading] = useState(false);
  const [pingLoading, setPingLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<ProfileTab>('posts');

  const [lives, setLives] = useState<BuddyLive[]>([]);
  const [livesLoading, setLivesLoading] = useState(false);
  const [replayLive, setReplayLive] = useState<BuddyLive | null>(null);
  const [messageLoading, setMessageLoading] = useState(false);

  const [allPosts, setAllPosts] = useState<Post[]>([]);
  const [postsLoading, setPostsLoading] = useState(false);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);

  /** Back returns to the swipe origin when present. */
  const handleBack = () => {
    const returnTo = (location.state as { returnTo?: string } | null)?.returnTo;
    if (returnTo) navigate(returnTo);
    else navigate(-1);
  };

  const fetchProfile = useCallback(async () => {
    if (!username) return;
    setIsLoading(true);
    try {
      const res = await profilesApi.getProfile(username);
      setProfile(res.data);
      setIsFollowing(res.data.is_following || false);
    } catch {
      toast('error', 'Failed to load profile');
    } finally {
      setIsLoading(false);
    }
  }, [username, toast]);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  const handleFollowToggle = async () => {
    if (!username || followLoading) return;
    setFollowLoading(true);
    try {
      if (isFollowing) {
        await profilesApi.unfollow(username);
        setIsFollowing(false);
        setProfile((prev) =>
          prev
            ? {
                ...prev,
                is_following: false,
                follower_count: Math.max(0, (prev.follower_count || 1) - 1),
              }
            : null
        );
        toast('info', `Unfollowed @${profile?.username || username}`);
      } else {
        await profilesApi.follow(username);
        setIsFollowing(true);
        setProfile((prev) =>
          prev
            ? {
                ...prev,
                is_following: true,
                follower_count: (prev.follower_count || 0) + 1,
              }
            : null
        );
        toast('success', `Following @${profile?.username || username}! 🎉`);
      }
    } catch {
      toast('error', 'Failed to update follow status');
    } finally {
      setFollowLoading(false);
    }
  };

  const handlePing = async () => {
    if (!username || pingLoading) return;
    setPingLoading(true);
    try {
      await profilesApi.ping(username, "How's your workout going? 💪");
      toast('success', `Ping sent to @${profile?.username || username}! 👋`);
    } catch {
      toast('error', 'Failed to send ping');
    } finally {
      setPingLoading(false);
    }
  };

  const handleMessage = async () => {
    if (!username || messageLoading) return;
    setMessageLoading(true);
    try {
      await messagingApi.startConversation([username]);
      navigate(`/messages?user=${username}`);
    } catch {
      toast('error', 'Failed to start conversation');
    } finally {
      setMessageLoading(false);
    }
  };

  const fetchLives = async () => {
    if (!profile?.username) return;
    setLivesLoading(true);
    try {
      const res = await livesApi.getUserLives(profile.username);
      setLives(res.data || []);
    } catch {
      toast('error', 'Failed to load live sessions');
    } finally {
      setLivesLoading(false);
    }
  };

  const fetchPosts = async () => {
    if (!profile?.username) return;
    setPostsLoading(true);
    try {
      const res = await profilesApi.getProfilePosts(profile.username);
      setAllPosts(res.data || []);
    } catch {
      toast('error', 'Failed to load posts');
    } finally {
      setPostsLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'lives' && profile?.username) fetchLives();
    if ((activeTab === 'posts' || activeTab === 'reposts' || activeTab === 'interests') && profile?.username) {
      if (!allPosts.length) fetchPosts();
    }
  }, [activeTab, profile?.username]);

  // Derived filtered posts & reposts
  const regularPosts = useMemo(
    () => allPosts.filter((p) => !p.is_repost),
    [allPosts]
  );
  const reposts = useMemo(
    () => allPosts.filter((p) => p.is_repost),
    [allPosts]
  );

  // Derived tags & workout types
  const extractedTags = useMemo(() => {
    const tags = new Set<string>();
    allPosts.forEach((post) => {
      (post.tags || []).forEach((t) => tags.add(t));
    });
    return Array.from(tags);
  }, [allPosts]);

  if (isLoading) {
    return (
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
        <div className="animate-pulse space-y-4">
          <div className="bg-buddy-surface rounded-2xl h-64" />
          <div className="bg-buddy-surface rounded-2xl h-32" />
        </div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 text-center py-20">
        <p className="text-buddy-text-secondary text-lg">User not found</p>
        <p className="text-buddy-text-secondary/50 text-sm mt-1">
          The profile you're looking for doesn't exist or was removed.
        </p>
      </div>
    );
  }

  const badgeConfig =
    profile.verification_status === 'email'
      ? { variant: 'blue' as const, label: 'Email Verified', icon: '✓' }
      : profile.verification_status === 'id'
      ? { variant: 'silver' as const, label: 'ID Verified', icon: '✓' }
      : profile.verification_status === 'trainer'
      ? { variant: 'green' as const, label: 'Certified Trainer', icon: '✓' }
      : profile.verification_status === 'practitioner'
      ? { variant: 'gold' as const, label: 'Health Practitioner', icon: '✓' }
      : null;

  const isBuddy = profile.is_buddy;

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      {/* Back Button */}
      <button
        onClick={handleBack}
        className="flex items-center gap-1.5 text-sm text-buddy-text-secondary hover:text-buddy-text-primary mb-3 transition-colors active:scale-95"
        aria-label="Go back"
      >
        <ArrowLeft size={16} /> Back
      </button>

      {/* Main Profile Card */}
      <Card className="p-6 mb-6 overflow-hidden relative">
        {/* Cover Photo Backdrop */}
        {profile.cover_url && (
          <div className="absolute top-0 left-0 right-0 h-24 overflow-hidden opacity-30">
            <img
              src={profile.cover_url}
              alt="Cover"
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-b from-transparent to-buddy-surface" />
          </div>
        )}

        <div className="flex items-start gap-4 mb-4 relative z-10">
          <div className="relative inline-block flex-shrink-0">
            <Avatar
              src={profile.avatar_url}
              alt={profile.display_name}
              size="xl"
              showRepRing
              streakProgress={
                profile.streak_days > 0
                  ? Math.min((profile.streak_days / 365) * 100, 100)
                  : 0
              }
              verificationStatus={profile.verification_status}
            />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <h2 className="font-heading text-xl font-semibold truncate">
                {profile.display_name}
              </h2>
              {profile.pronouns && (
                <span className="text-xs text-buddy-text-secondary">
                  ({profile.pronouns})
                </span>
              )}
            </div>
            <p className="text-buddy-text-secondary text-sm">@{profile.username}</p>
            {badgeConfig && (
              <Badge
                variant={badgeConfig.variant}
                label={badgeConfig.label}
                icon={badgeConfig.icon}
                className="mt-1"
              />
            )}
            <p className="text-sm text-buddy-text-primary mt-2">
              {profile.bio || 'No bio yet'}
            </p>

            {/* Profile Meta Details */}
            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-2 text-xs text-buddy-text-secondary">
              {profile.location_city && (
                <span className="inline-flex items-center gap-1">
                  <MapPin size={12} className="text-buddy-green" />
                  {profile.location_city}
                  {profile.location_country ? `, ${profile.location_country}` : ''}
                </span>
              )}
              <span className="inline-flex items-center gap-1">
                <Dumbbell size={12} className="text-buddy-green" />
                {profile.role === 'trainer'
                  ? 'Personal Trainer'
                  : profile.role === 'practitioner'
                  ? 'Health Practitioner'
                  : 'Buddy Member'}
              </span>
              {profile.external_link && (
                <a
                  href={profile.external_link.startsWith('http') ? profile.external_link : `https://${profile.external_link}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1 text-buddy-green hover:underline"
                >
                  <ExternalLink size={12} />
                  {profile.external_link.replace(/^https?:\/\//, '').split('/')[0]}
                </a>
              )}
              <span className="inline-flex items-center gap-1 text-buddy-text-secondary/70">
                <Calendar size={12} />
                Joined 2026
              </span>
            </div>
          </div>
        </div>

        {/* Stats Row */}
        <div className="grid grid-cols-3 gap-2 mb-4">
          {[
            { value: profile.buddy_count, label: 'Buddies', to: null as string | null },
            {
              value: profile.following_count,
              label: 'Following',
              to: `/${profile.username}/following`,
            },
            {
              value: profile.follower_count,
              label: 'Followers',
              to: `/${profile.username}/followers`,
            },
          ].map(({ value, label, to }) =>
            to ? (
              <button
                key={label}
                onClick={() => navigate(to)}
                className="text-center bg-buddy-surface-raised hover:bg-buddy-surface rounded-xl py-2 transition-all active:scale-95"
                title={`View ${label.toLowerCase()}`}
              >
                <p className="font-mono font-bold text-lg">{value}</p>
                <p className="text-xs text-buddy-text-secondary">{label}</p>
              </button>
            ) : (
              <div
                key={label}
                className="text-center bg-buddy-surface-raised rounded-xl py-2"
              >
                <p className="font-mono font-bold text-lg">{value}</p>
                <p className="text-xs text-buddy-text-secondary">{label}</p>
              </div>
            )
          )}
        </div>

        {/* Workout Streak Highlight */}
        {profile.streak_days > 0 && (
          <div className="bg-buddy-orange/10 border border-buddy-orange/20 rounded-xl px-4 py-2.5 mb-4 flex items-center justify-center gap-2">
            <span className="text-lg animate-pulse">🔥</span>
            <span className="font-mono font-bold text-buddy-orange">
              {profile.streak_days}
            </span>
            <span className="text-sm text-buddy-text-secondary">
              day workout streak
            </span>
          </div>
        )}

        {/* Action Buttons with Micro-Animations */}
        <div className="space-y-2">
          {/* Main Buddy Button */}
          <BuddyButton
            profile={profile}
            size="md"
            onStateChange={(state) => {
              setProfile((prev) =>
                prev
                  ? {
                      ...prev,
                      is_buddy: state === 'confirmed',
                      buddy_status: state === 'none' ? undefined : state,
                      buddy_count:
                        state === 'confirmed'
                          ? (prev.buddy_count || 0) + 1
                          : prev.buddy_count,
                    }
                  : null
              );
            }}
          />

          {/* Sub Action Buttons: Follow, Ping, Message */}
          <div className="flex gap-2">
            <Button
              variant={isFollowing ? 'outline' : 'primary'}
              size="sm"
              className={`flex-1 gap-1.5 transition-all duration-200 active:scale-95 ${
                isFollowing
                  ? 'border-buddy-border text-buddy-text-secondary hover:text-buddy-text-primary'
                  : 'bg-buddy-green text-buddy-black'
              }`}
              onClick={handleFollowToggle}
              isLoading={followLoading}
            >
              {isFollowing ? (
                <>
                  <UserCheck size={14} className="text-buddy-green" />
                  Following
                </>
              ) : (
                <>
                  <UserPlus size={14} />
                  Follow
                </>
              )}
            </Button>

            <Button
              variant="outline"
              size="sm"
              className="gap-1.5 border-buddy-border hover:border-buddy-green/40 active:scale-95 transition-all"
              onClick={handleMessage}
              isLoading={messageLoading}
            >
              <MessageCircle size={14} />
              Message
            </Button>

            {isBuddy && (
              <Button
                variant="outline"
                size="sm"
                className="gap-1.5 border-buddy-border hover:border-buddy-gold/40 active:scale-95 transition-all"
                onClick={handlePing}
                isLoading={pingLoading}
              >
                <Zap size={14} className="text-buddy-gold fill-buddy-gold/20" />
                Ping
              </Button>
            )}
          </div>
        </div>
      </Card>

      {/* Tabs */}
      <div className="flex border-b border-buddy-surface mb-4">
        {(
          [
            { id: 'posts', label: `Posts (${regularPosts.length})` },
            { id: 'reposts', label: `Reposts (${reposts.length})` },
            { id: 'interests', label: 'Interests & Info' },
            { id: 'lives', label: `Lives (${lives.length})` },
          ] as { id: ProfileTab; label: string }[]
        ).map(({ id, label }) => (
          <button
            key={id}
            onClick={() => setActiveTab(id)}
            className={`flex-1 pb-3 text-sm font-medium transition-colors ${
              activeTab === id
                ? 'text-buddy-green border-b-2 border-buddy-green font-semibold'
                : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === 'posts' ? (
        postsLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader size={24} className="animate-spin text-buddy-text-secondary" />
          </div>
        ) : regularPosts.length === 0 ? (
          <div className="text-center py-20">
            <MessageCircle size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-buddy-text-secondary">No posts yet</p>
          </div>
        ) : (
          <div className="space-y-3">
            {regularPosts.map((post) => (
              <PostCard key={post.id} post={post} onComment={setCommentPostId} />
            ))}
          </div>
        )
      ) : activeTab === 'reposts' ? (
        postsLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader size={24} className="animate-spin text-buddy-text-secondary" />
          </div>
        ) : reposts.length === 0 ? (
          <div className="text-center py-20">
            <Repeat size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-buddy-text-secondary">No reposts yet</p>
          </div>
        ) : (
          <div className="space-y-3">
            {reposts.map((post) => (
              <PostCard key={post.id} post={post} onComment={setCommentPostId} />
            ))}
          </div>
        )
      ) : activeTab === 'interests' ? (
        <Card className="p-6 space-y-6">
          {/* Preferences & Goals */}
          <div>
            <div className="flex items-center gap-2 mb-3">
              <Sparkles size={16} className="text-buddy-green" />
              <h3 className="font-heading font-semibold text-sm">
                Workout Preferences & Goals
              </h3>
            </div>
            {profile.preferences &&
            (profile.preferences.primary_goal?.length ||
              profile.preferences.preferred_workouts?.length ||
              profile.preferences.custom_interests) ? (
              <InterestChips
                preferences={profile.preferences}
                showLocation
                city={profile.location_city}
              />
            ) : (
              <p className="text-xs text-buddy-text-secondary">
                No specific fitness preferences shared yet.
              </p>
            )}
          </div>

          {/* Activity Tags from Posts */}
          {extractedTags.length > 0 && (
            <div>
              <h4 className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-2">
                Frequently Tagged Topics
              </h4>
              <div className="flex flex-wrap gap-1.5">
                {extractedTags.map((tag) => (
                  <span
                    key={tag}
                    className="text-xs px-2.5 py-1 rounded-full bg-buddy-surface-raised text-buddy-text-secondary"
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Account Details & Role */}
          <div className="border-t border-buddy-surface pt-4 text-xs space-y-2 text-buddy-text-secondary">
            <div className="flex justify-between">
              <span>Account Type</span>
              <span className="font-medium text-buddy-text-primary capitalize">
                {profile.role.replace(/_/g, ' ')}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Content Rating</span>
              <span className="font-medium text-buddy-text-primary uppercase">
                {profile.content_rating || 'General'}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Privacy Level</span>
              <span className="font-medium text-buddy-text-primary capitalize">
                {profile.privacy_level || 'Public'}
              </span>
            </div>
          </div>
        </Card>
      ) : (
        /* Lives Tab */
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
              <Card
                key={live.id}
                className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
                onClick={() =>
                  live.status === 'live' ? navigate(`/live/${live.id}`) : null
                }
              >
                <div className="flex items-start gap-3">
                  <div className="relative">
                    <Avatar
                      src={live.host?.avatar_url}
                      alt={live.host?.display_name || 'User'}
                      size="lg"
                    />
                    {live.status === 'live' && (
                      <div className="absolute -top-1 -right-1 w-4 h-4 bg-buddy-red rounded-full border-2 border-buddy-black animate-pulse" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-heading font-semibold text-sm truncate">
                      {live.title}
                    </h3>
                    <p className="text-xs text-buddy-text-secondary mt-0.5 capitalize">
                      {live.live_type.replace(/_/g, ' ')} · {live.category}
                    </p>
                    <div className="flex items-center gap-3 mt-2 text-xs text-buddy-text-secondary">
                      <span className="flex items-center gap-1">
                        <Users size={12} /> {live.viewer_peak || 0}
                      </span>
                      {live.status === 'live' && (
                        <span className="flex items-center gap-1 text-buddy-red">
                          <Radio size={12} /> LIVE
                        </span>
                      )}
                      {live.scheduled_for && (
                        <span className="flex items-center gap-1">
                          <Clock size={12} />{' '}
                          {new Date(live.scheduled_for).toLocaleDateString()}
                        </span>
                      )}
                      {live.status === 'ended' && live.replay_url && (
                        <Button
                          size="sm"
                          variant="outline"
                          className="ml-auto gap-1.5"
                          onClick={(e) => {
                            e.stopPropagation();
                            setReplayLive(live);
                          }}
                        >
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
      )}

      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
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
