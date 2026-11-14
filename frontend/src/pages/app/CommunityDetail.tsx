import { useState, useEffect, useCallback } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Users, MoreHorizontal, Settings2, Copy,
  MessageCircle, UserPlus, CalendarDays, Video, Clock, Plus, Trash2,
  LogOut, MapPin, Radio,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { CommunityPostCard } from '@/components/features/feed/CommunityPostCard';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import {
  messagingApi, type Community, type CommunityPost, type CommunityEvent,
  type CommunityLive, type CommunitySchedule,
} from '@/api/messaging';
import type { Post } from '@/types/post';

type Tab = 'feed' | 'members' | 'events' | 'schedules' | 'lives';

const TABS: { key: Tab; label: string; icon: typeof Users }[] = [
  { key: 'feed', label: 'Feed', icon: Users },
  { key: 'members', label: 'Members', icon: Users },
  { key: 'events', label: 'Events', icon: CalendarDays },
  { key: 'schedules', label: 'Schedules', icon: Clock },
  { key: 'lives', label: 'Lives', icon: Video },
];

const LIVE_TYPES = [
  'open_sweat', 'buddy_circle', 'gym_live', 'pt_session_live',
  'random_drop', 'practitioner_live', 'audio',
];

const ACTIVITY_TYPES = [
  'yoga', 'hiit', 'strength', 'cardio', 'live_stream',
  'workshop', 'event', 'session', 'other',
];

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

function fromLocalInput(value: string): string | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}

function formatWhen(value: string | null | undefined): string {
  if (!value) return 'No date set';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'No date set';
  return date.toLocaleString(undefined, {
    weekday: 'short', day: 'numeric', month: 'short',
    hour: '2-digit', minute: '2-digit',
  });
}

interface CommunityPostExtended extends CommunityPost {
  community_id?: string;
  community_name?: string;
  community_cover_url?: string;
  repost_count?: number;
  is_saved_by_me?: boolean;
  updated_at?: string;
  view_count?: number;
  is_reposted_by_me?: boolean;
  reposters?: any[];
  reaction_counts?: Record<string, number>;
  user_reaction?: string | null;
}

function mapCommunityPostToPost(cp: CommunityPostExtended): Post {
  return {
    id: cp.id,
    author_data: cp.author_data,
    post_type: 'text',
    body: cp.body,
    is_anonymous: false,
    media_urls: cp.media_url ? [cp.media_url] : [],
    media: [],
    captions: [],
    tags: [],
    workout_log_data: null,
    meal_data: null,
    progress_data: null,
    location_label: '',
    visibility: 'public',
    moderation_status: 'clean',
    comments_disabled: false,
    view_count: cp.view_count ?? 0,
    reaction_counts: cp.reaction_counts || {},
    user_reaction: cp.user_reaction ?? null,
    comment_count: cp.comment_count || 0,
    repost_count: cp.repost_count || 0,
    is_reposted_by_me: cp.is_reposted_by_me || false,
    reposters: cp.reposters || [],
    is_repost: false,
    original_post_id: null,
    quote_body: '',
    is_saved: cp.is_saved_by_me || false,
    is_pinned: cp.is_pinned || false,
    content_rating: 'general',
    created_at: cp.created_at || new Date().toISOString(),
    updated_at: cp.updated_at || cp.created_at || new Date().toISOString(),
    community_id: cp.community_id,
    community_name: cp.community_name,
    gym_tag_id: null,
    gym_tag_name: null,
    shares: [],
    original_post_data: null,
    community_cover_url: cp.community_cover_url ?? null,
    community_slug: null,
    poll: null,
  } as unknown as Post;
}

interface EventDraft {
  title: string; description: string; event_type: string;
  location: string; online_url: string; start: string; end: string; is_free: boolean;
}

interface LiveDraft {
  title: string; live_type: string; category: string; access: string; scheduled: string;
}

interface ScheduleDraft {
  title: string; content: string; activity_type: string; custom_activity_type: string;
  location_mode: string; start: string; end: string; recurrence: string;
  recurrence_days: number[]; max_slots: string;
}

const emptyEventDraft = (): EventDraft => ({
  title: '', description: '', event_type: 'in_person', location: '', online_url: '',
  start: '', end: '', is_free: true,
});

const emptyLiveDraft = (): LiveDraft => ({
  title: '', live_type: 'buddy_circle', category: 'fitness', access: 'public', scheduled: '',
});

const emptyScheduleDraft = (): ScheduleDraft => ({
  title: '', content: '', activity_type: 'other', custom_activity_type: '',
  location_mode: 'in_house', start: '', end: '', recurrence: 'none',
  recurrence_days: [], max_slots: '0',
});

export default function CommunityDetail() {
  const { communityId } = useParams<{ communityId: string }>();
  const navigate = useNavigate();

  const [community, setCommunity] = useState<Community | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [events, setEvents] = useState<CommunityEvent[]>([]);
  const [lives, setLives] = useState<CommunityLive[]>([]);
  const [schedules, setSchedules] = useState<CommunitySchedule[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>('feed');

  const [showSettings, setShowSettings] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [copyMsg, setCopyMsg] = useState('');
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  const [searchMember, setSearchMember] = useState('');
  const [menuMemberId, setMenuMemberId] = useState<string | null>(null);

  const [editName, setEditName] = useState('');
  const [editDesc, setEditDesc] = useState('');
  const [editPublic, setEditPublic] = useState(false);
  const [editAvatar, setEditAvatar] = useState('');

  const [activityModal, setActivityModal] = useState<'event' | 'live' | 'schedule' | null>(null);
  const [eventDraft, setEventDraft] = useState<EventDraft>(emptyEventDraft());
  const [liveDraft, setLiveDraft] = useState<LiveDraft>(emptyLiveDraft());
  const [scheduleDraft, setScheduleDraft] = useState<ScheduleDraft>(emptyScheduleDraft());
  const [activityBusy, setActivityBusy] = useState(false);
  const [activityError, setActivityError] = useState<string | null>(null);

  const role = community?.my_role ?? community?.membership_role ?? null;
  const isMember = Boolean(role);
  const canManage = role === 'owner' || role === 'admin';
  const isOwner = role === 'owner';

  const fetchAll = useCallback(() => {
    if (!communityId) return;
    setLoadError(null);
    Promise.all([
      messagingApi.getCommunity(communityId),
      messagingApi.getCommunityPosts(communityId),
      messagingApi.getCommunityEvents(communityId),
      messagingApi.getCommunitySchedules(communityId),
      messagingApi.getCommunityLives(communityId),
    ])
      .then(([communityData, postData, eventData, scheduleData, liveData]) => {
        setCommunity(communityData);
        setPosts((Array.isArray(postData) ? postData : []).map(mapCommunityPostToPost));
        setEvents(Array.isArray(eventData) ? eventData : []);
        setSchedules(Array.isArray(scheduleData) ? scheduleData : []);
        setLives(Array.isArray(liveData) ? liveData : []);
      })
      .catch((error: any) => {
        setLoadError(error?.response?.data?.message || 'Could not load this community.');
      })
      .finally(() => setIsLoading(false));
  }, [communityId]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  const openSettings = () => {
    setEditName(community?.group_name || '');
    setEditDesc(community?.description || '');
    setEditPublic(community?.is_public ?? false);
    setEditAvatar(community?.group_avatar_url || '');
    setShowSettings(true);
  };

  const saveSettings = async () => {
    if (!communityId) return;
    try {
      await messagingApi.updateCommunity(communityId, {
        name: editName,
        description: editDesc,
        is_public: editPublic,
        ...(editAvatar ? { group_avatar_url: editAvatar } : {}),
      });
      setShowSettings(false);
      fetchAll();
    } catch {
      setLoadError('Failed to save settings.');
    }
  };

  const join = async () => {
    if (!communityId) return;
    try {
      await messagingApi.joinCommunity(communityId);
      fetchAll();
    } catch {
      setLoadError('Could not join this community.');
    }
  };

  const leave = async () => {
    if (!communityId) return;
    if (!window.confirm('Leave this community?')) return;
    try {
      await messagingApi.leaveCommunity(communityId);
      fetchAll();
    } catch {
      setLoadError('Could not leave this community.');
    }
  };

  const copyInvite = async () => {
    if (!community?.invite_code) return;
    try {
      await navigator.clipboard.writeText(community.invite_code);
      setCopyMsg('Copied!');
      setTimeout(() => setCopyMsg(''), 2000);
    } catch {
      setCopyMsg('Copy failed');
    }
  };

  const rotateInvite = async () => {
    if (!communityId) return;
    try {
      await messagingApi.rotateInviteCode(communityId);
      fetchAll();
    } catch {
      setCopyMsg('Could not rotate the invite code');
    }
  };

  const removeMember = (userId: string) => {
    if (!communityId) return;
    if (!window.confirm('Remove this member?')) return;
    messagingApi.removeCommunityMember(communityId, userId).then(fetchAll);
  };

  const setRole = (userId: string, next: 'admin' | 'member') => {
    if (!communityId) return;
    messagingApi.setCommunityRole(communityId, userId, next).then(fetchAll);
  };

  const toggleLike = async (postId: string) => {
    if (!communityId) return;
    try {
      await messagingApi.togglePostLike(communityId, postId);
      setPosts((prev) => prev.map((p) => {
        if (p.id !== postId) return p;
        const wasLiked = p.user_reaction === '💪';
        return {
          ...p,
          user_reaction: wasLiked ? null : '💪',
          reaction_counts: {
            ...p.reaction_counts,
            '💪': (p.reaction_counts?.['💪'] || 0) + (wasLiked ? -1 : 1),
          },
        };
      }));
    } catch { /* noop */ }
  };

  const toggleRepost = async (postId: string) => {
    if (!communityId) return;
    try {
      await messagingApi.repostCommunityPost(communityId, postId);
      setPosts((prev) => prev.map((p) => {
        if (p.id !== postId) return p;
        const wasReposted = p.is_reposted_by_me;
        return {
          ...p,
          is_reposted_by_me: !wasReposted,
          repost_count: Math.max(0, (p.repost_count || 0) + (wasReposted ? -1 : 1)),
        };
      }));
    } catch { /* noop */ }
  };

  const toggleSave = async (postId: string) => {
    if (!communityId) return;
    try {
      await messagingApi.saveCommunityPost(communityId, postId);
      setPosts((prev) => prev.map((p) => {
        if (p.id !== postId) return p;
        const wasSaved = p.is_saved;
        return {
          ...p,
          is_saved: !wasSaved,
          save_count: Math.max(0, (p.save_count || 0) + (wasSaved ? -1 : 1)),
        };
      }));
    } catch { /* noop */ }
  };

  const toggleReact = async (postId: string, reaction: string) => {
    if (!communityId) return;
    try {
      await messagingApi.reactCommunityPost(communityId, postId, reaction);
      setPosts((prev) => prev.map((p) => {
        if (p.id !== postId) return p;
        const wasReacted = p.user_reaction === reaction;
        const counts = { ...p.reaction_counts };
        if (wasReacted) {
          counts[reaction] = Math.max(0, (counts[reaction] || 1) - 1);
          if (counts[reaction] === 0) delete counts[reaction];
        } else {
          counts[reaction] = (counts[reaction] || 0) + 1;
        }
        return { ...p, user_reaction: wasReacted ? null : reaction, reaction_counts: counts };
      }));
    } catch { /* noop */ }
  };

  // ── Activity CRUD ──────────────────────────────────────────────────────
  const openActivity = (kind: 'event' | 'live' | 'schedule') => {
    setActivityError(null);
    setActivityModal(kind);
  };

  const submitActivity = async () => {
    if (!communityId || !activityModal) return;
    setActivityBusy(true);
    setActivityError(null);
    try {
      if (activityModal === 'event') {
        const start = fromLocalInput(eventDraft.start);
        const end = fromLocalInput(eventDraft.end);
        if (!eventDraft.title.trim() || !start || !end) {
          setActivityError('Title, start and end are required.');
          return;
        }
        await messagingApi.createCommunityEvent(communityId, {
          title: eventDraft.title.trim(),
          description: eventDraft.description,
          event_type: eventDraft.event_type as 'in_person' | 'online' | 'hybrid',
          location: eventDraft.location,
          online_url: eventDraft.online_url,
          start_datetime: start,
          end_datetime: end,
          is_free: eventDraft.is_free,
        });
      } else if (activityModal === 'live') {
        if (!liveDraft.title.trim()) {
          setActivityError('A title is required.');
          return;
        }
        await messagingApi.createCommunityLive(communityId, {
          title: liveDraft.title.trim(),
          live_type: liveDraft.live_type,
          category: liveDraft.category,
          access: liveDraft.access,
          scheduled_for: fromLocalInput(liveDraft.scheduled),
        });
      } else {
        const start = fromLocalInput(scheduleDraft.start);
        const end = fromLocalInput(scheduleDraft.end);
        await messagingApi.createCommunitySchedule(communityId, {
          title: scheduleDraft.title,
          content: scheduleDraft.content,
          activity_type: scheduleDraft.activity_type,
          custom_activity_type: scheduleDraft.custom_activity_type,
          location_mode: scheduleDraft.location_mode,
          start_time: start,
          end_time: end,
          recurrence: scheduleDraft.recurrence,
          recurrence_days: scheduleDraft.recurrence_days,
          max_slots: Number(scheduleDraft.max_slots || 0),
        });
      }
      setActivityModal(null);
      fetchAll();
    } catch (error: any) {
      setActivityError(error?.response?.data?.message || 'Could not save that activity.');
    } finally {
      setActivityBusy(false);
    }
  };

  const deleteEvent = (eventId: string) => {
    if (!communityId || !window.confirm('Remove this event?')) return;
    messagingApi.deleteCommunityEvent(communityId, eventId)
      .then(() => setEvents((prev) => prev.filter((e) => e.id !== eventId)))
      .catch(() => setActivityError('Could not remove that event.'));
  };

  const deleteLive = (liveId: string) => {
    if (!communityId || !window.confirm('Remove this live?')) return;
    messagingApi.deleteCommunityLive(communityId, liveId)
      .then(() => setLives((prev) => prev.filter((l) => l.id !== liveId)))
      .catch(() => setActivityError('Could not remove that live.'));
  };

  const deleteSchedule = (scheduleId: string) => {
    if (!communityId || !window.confirm('Remove this session?')) return;
    messagingApi.deleteCommunitySchedule(communityId, scheduleId)
      .then(() => setSchedules((prev) => prev.filter((s) => s.id !== scheduleId)))
      .catch(() => setActivityError('Could not remove that session.'));
  };

  const filteredMembers = (community?.members ?? []).filter((m) => {
    const q = searchMember.toLowerCase();
    return m.display_name.toLowerCase().includes(q) || m.username.toLowerCase().includes(q);
  });

  const shareableRows = tab === 'feed' ? posts.length
    : tab === 'members' ? filteredMembers.length
    : tab === 'events' ? events.length
    : tab === 'schedules' ? schedules.length
    : lives.length;

  return (
    <div className="min-h-screen bg-buddy-black text-buddy-text-primary">
      {/* ── Hero ─────────────────────────────────────────────────────── */}
      <header className="bg-buddy-surface">
        <div className="h-32 sm:h-40 w-full overflow-hidden bg-buddy-surface-raised">
          {community?.cover_url ? (
            <img src={community.cover_url} alt="" className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <Users size={40} className="text-buddy-green/40" />
            </div>
          )}
        </div>

        <div className="max-w-2xl mx-auto px-4 pb-4">
          <div className="flex items-end gap-3 -mt-7">
            <div className="w-16 h-16 rounded-2xl overflow-hidden bg-buddy-surface-raised border-2 border-buddy-surface shrink-0">
              {community?.group_avatar_url ? (
                <img src={community.group_avatar_url} alt="" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <Users size={22} className="text-buddy-green" />
                </div>
              )}
            </div>
            <div className="flex-1 min-w-0 pb-0.5">
              <h1 className="font-display text-lg sm:text-xl font-bold truncate">
                {community?.group_name || 'Community'}
              </h1>
              <p className="text-xs text-buddy-text-secondary">
                {community?.member_count || 0} members · {community?.is_public ? 'Public' : 'Private'}
              </p>
            </div>
          </div>

          {community?.description && (
            <p className="mt-3 text-sm text-buddy-text-secondary">{community.description}</p>
          )}

          <div className="mt-3 flex flex-wrap gap-2">
            {isMember ? (
              <>
                <Button size="sm" onClick={() => community && navigate(`/messages/${community.id}`)}>
                  <MessageCircle size={14} className="mr-1" /> Chat
                </Button>
                {canManage && (
                  <>
                    <Button size="sm" variant="outline" onClick={() => setShowInvite(true)}>
                      <UserPlus size={14} className="mr-1" /> Invite
                    </Button>
                    <Button size="sm" variant="outline" onClick={openSettings}>
                      <Settings2 size={14} className="mr-1" /> Settings
                    </Button>
                  </>
                )}
                <Button size="sm" variant="ghost" onClick={leave}>
                  <LogOut size={14} className="mr-1" /> Leave
                </Button>
              </>
            ) : (
              <Button size="sm" onClick={join} isLoading={isLoading}>
                <UserPlus size={14} className="mr-1" /> Join community
              </Button>
            )}
          </div>
        </div>
      </header>

      {/* ── Tabs (sticky, attached to the top while the body scrolls) ── */}
      <nav className="sticky top-0 z-20 bg-buddy-black/95 backdrop-blur border-b border-buddy-surface">
        <div className="max-w-2xl mx-auto px-4 flex gap-1 overflow-x-auto">
          {TABS.map(({ key, label, icon: Icon }) => (
            <button
              key={key}
              type="button"
              onClick={() => setTab(key)}
              className={`flex items-center gap-1.5 px-3 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${
                tab === key
                  ? 'border-buddy-green text-buddy-green font-semibold'
                  : 'border-transparent text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              <Icon size={15} />
              {label}
              {key === 'members' && community?.member_count != null && (
                <span className="text-[10px] text-buddy-text-secondary">{community.member_count}</span>
              )}
            </button>
          ))}
        </div>
      </nav>

      {/* ── Body ─────────────────────────────────────────────────────── */}
      <main className="max-w-2xl mx-auto px-4 pt-4 pb-24">
        {loadError && (
          <div className="mb-3 bg-buddy-red/10 border border-buddy-red/30 text-buddy-red text-sm rounded-xl px-3 py-2" role="alert">
            {loadError}
          </div>
        )}

        {isLoading ? (
          <div className="py-16 text-center text-buddy-text-secondary text-sm">Loading community…</div>
        ) : !community ? (
          <Card className="p-8 text-center text-buddy-text-secondary text-sm">
            This community could not be found.
          </Card>
        ) : (
          <>
            {/* Feed */}
            {tab === 'feed' && (
              <section className="space-y-3">
                {posts.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary text-sm">
                    <Users className="mx-auto mb-3 text-buddy-text-secondary/60" size={28} />
                    {isMember
                      ? 'No posts yet. Start the conversation.'
                      : 'No posts to show. Join to see what members share.'}
                  </Card>
                ) : (
                  posts.map((post) => (
                    <CommunityPostCard
                      key={post.id}
                      post={post}
                      communityId={communityId}
                      isMember={isMember}
                      onLike={() => toggleLike(post.id)}
                      onRepost={() => toggleRepost(post.id)}
                      onSave={() => toggleSave(post.id)}
                      onReact={(reaction) => toggleReact(post.id, reaction)}
                      onComment={() => setCommentPostId(post.id)}
                      onRemove={() => {}}
                      onRemoveAuthor={() => {}}
                    />
                  ))
                )}
              </section>
            )}

            {/* Members */}
            {tab === 'members' && (
              <section className="space-y-3">
                <Input
                  placeholder="Search members…"
                  value={searchMember}
                  onChange={(e) => setSearchMember(e.target.value)}
                />
                {filteredMembers.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary text-sm">
                    {isMember ? 'No members match.' : 'The member list is visible to members only.'}
                  </Card>
                ) : (
                  filteredMembers.map((member) => (
                    <Card key={member.user_id} className="p-3 flex items-center gap-3">
                      <Avatar
                        src={member.avatar_url}
                        alt={member.display_name}
                        size="md"
                        verificationStatus={member.verification_status}
                      />
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold truncate">{member.display_name}</p>
                        <p className="text-xs text-buddy-text-secondary truncate">@{member.username}</p>
                      </div>
                      {member.role === 'owner' && <Badge variant="gold" label="Owner" />}
                      {member.role === 'admin' && <Badge variant="green" label="Admin" />}
                      {canManage && member.role !== 'owner' && (
                        <div className="relative shrink-0">
                          <button
                            type="button"
                            aria-label={`Manage ${member.display_name}`}
                            onClick={() => setMenuMemberId(menuMemberId === member.user_id ? null : member.user_id)}
                            className="p-2 rounded-full text-buddy-text-secondary hover:bg-buddy-surface-raised"
                          >
                            <MoreHorizontal size={16} />
                          </button>
                          {menuMemberId === member.user_id && (
                            <div className="absolute right-0 top-9 z-30 w-44 bg-buddy-surface-raised border border-buddy-surface rounded-xl shadow-2xl p-1.5">
                              {member.role === 'admin' ? (
                                <button
                                  onClick={() => { setMenuMemberId(null); setRole(member.user_id, 'member'); }}
                                  className="block w-full text-left px-3 py-2 rounded-lg text-xs hover:bg-buddy-surface"
                                >
                                  Demote to member
                                </button>
                              ) : (
                                <button
                                  onClick={() => { setMenuMemberId(null); setRole(member.user_id, 'admin'); }}
                                  className="block w-full text-left px-3 py-2 rounded-lg text-xs hover:bg-buddy-surface"
                                >
                                  Make admin
                                </button>
                              )}
                              {isOwner && (
                                <button
                                  onClick={() => {
                                    setMenuMemberId(null);
                                    if (window.confirm('Transfer ownership to this member?')) {
                                      messagingApi.transferCommunityOwnership(community.id, member.user_id).then(fetchAll);
                                    }
                                  }}
                                  className="block w-full text-left px-3 py-2 rounded-lg text-xs hover:bg-buddy-surface"
                                >
                                  Transfer ownership
                                </button>
                              )}
                              <button
                                onClick={() => { setMenuMemberId(null); removeMember(member.user_id); }}
                                className="block w-full text-left px-3 py-2 rounded-lg text-xs text-buddy-red hover:bg-buddy-surface"
                              >
                                Remove member
                              </button>
                            </div>
                          )}
                        </div>
                      )}
                    </Card>
                  ))
                )}
              </section>
            )}

            {/* Events */}
            {tab === 'events' && (
              <section className="space-y-3">
                <div className="flex items-center justify-between gap-2">
                  <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Events</h2>
                  {canManage && (
                    <Button size="sm" onClick={() => openActivity('event')}>
                      <Plus size={13} className="mr-1" /> Add event
                    </Button>
                  )}
                </div>
                {events.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary text-sm">
                    No upcoming events.
                  </Card>
                ) : (
                  events.map((event) => (
                    <Card key={event.id} className="p-4 space-y-2">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 rounded-xl bg-buddy-green/15 text-buddy-green flex items-center justify-center shrink-0">
                          <CalendarDays size={18} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-semibold">{event.title}</p>
                          <p className="text-xs text-buddy-text-secondary">{formatWhen(event.start_datetime)}</p>
                          {event.location && (
                            <p className="text-xs text-buddy-text-secondary flex items-center gap-1 mt-0.5">
                              <MapPin size={11} /> {event.location}
                            </p>
                          )}
                          {event.online_url && (
                            <p className="text-xs text-buddy-green truncate">{event.online_url}</p>
                          )}
                        </div>
                        {canManage && (
                          <button
                            type="button"
                            aria-label={`Remove ${event.title}`}
                            onClick={() => deleteEvent(event.id)}
                            className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-red hover:bg-buddy-surface-raised"
                          >
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                      {event.description && (
                        <p className="text-xs text-buddy-text-secondary">{event.description}</p>
                      )}
                      <div className="flex flex-wrap gap-1.5">
                        <Badge variant="silver" label={event.event_type.replace('_', ' ')} />
                        {event.is_free && <Badge variant="green" label="Free" />}
                        {event.capacity > 0 && <Badge variant="blue" label={`${event.spots_remaining ?? event.capacity} spots`} />}
                      </div>
                    </Card>
                  ))
                )}
              </section>
            )}

            {/* Schedules */}
            {tab === 'schedules' && (
              <section className="space-y-3">
                <div className="flex items-center justify-between gap-2">
                  <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Schedule</h2>
                  {canManage && (
                    <Button size="sm" onClick={() => openActivity('schedule')}>
                      <Plus size={13} className="mr-1" /> Add session
                    </Button>
                  )}
                </div>
                {schedules.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary text-sm">
                    No sessions scheduled.
                  </Card>
                ) : (
                  schedules.map((slot) => (
                    <Card key={slot.id} className="p-4 flex items-start gap-3">
                      <div className="w-10 h-10 rounded-xl bg-buddy-electric/15 text-buddy-electric flex items-center justify-center shrink-0">
                        <Clock size={18} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold truncate">
                          {slot.title || slot.custom_activity_type || slot.activity_type}
                        </p>
                        <p className="text-xs text-buddy-text-secondary">
                          {formatWhen(slot.start_time)}
                          {slot.recurrence && slot.recurrence !== 'none' ? ` · ${slot.recurrence}` : ''}
                        </p>
                        {slot.content && (
                          <p className="text-xs text-buddy-text-secondary mt-1">{slot.content}</p>
                        )}
                      </div>
                      {canManage && (
                        <button
                          type="button"
                          aria-label="Remove session"
                          onClick={() => deleteSchedule(slot.id)}
                          className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-red hover:bg-buddy-surface-raised"
                        >
                          <Trash2 size={14} />
                        </button>
                      )}
                    </Card>
                  ))
                )}
              </section>
            )}

            {/* Lives */}
            {tab === 'lives' && (
              <section className="space-y-3">
                <div className="flex items-center justify-between gap-2">
                  <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Lives</h2>
                  {canManage && (
                    <Button size="sm" onClick={() => openActivity('live')}>
                      <Plus size={13} className="mr-1" /> Schedule a live
                    </Button>
                  )}
                </div>
                {lives.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary text-sm">
                    No lives scheduled.
                  </Card>
                ) : (
                  lives.map((live) => (
                    <Card key={live.id} className="p-4 flex items-start gap-3">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                        live.status === 'live' ? 'bg-buddy-red/15 text-buddy-red' : 'bg-buddy-green/15 text-buddy-green'
                      }`}>
                        <Radio size={18} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold truncate">{live.title}</p>
                        <p className="text-xs text-buddy-text-secondary">
                          {live.status === 'live' ? 'Live now' : formatWhen(live.scheduled_for)}
                        </p>
                      </div>
                      {live.status === 'live' && <Badge variant="red" label="LIVE" />}
                      {canManage && (
                        <button
                          type="button"
                          aria-label="Remove live"
                          onClick={() => deleteLive(live.id)}
                          className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-red hover:bg-buddy-surface-raised"
                        >
                          <Trash2 size={14} />
                        </button>
                      )}
                    </Card>
                  ))
                )}
              </section>
            )}

            {shareableRows > 0 && tab !== 'feed' && (
              <p className="text-center text-[11px] text-buddy-text-secondary/60 pt-2">
                {shareableRows} {shareableRows === 1 ? 'item' : 'items'}
              </p>
            )}
          </>
        )}
      </main>

      {/* ── Settings ──────────────────────────────────────────────────── */}
      <Modal isOpen={showSettings} onClose={() => setShowSettings(false)} title="Community settings" size="lg">
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="w-16 h-16 rounded-2xl overflow-hidden bg-buddy-surface-raised shrink-0">
              {editAvatar ? (
                <img src={editAvatar} alt="" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <Users size={24} className="text-buddy-green" />
                </div>
              )}
            </div>
            <Input
              label="Community picture URL"
              value={editAvatar}
              onChange={(e) => setEditAvatar(e.target.value)}
              placeholder="https://…"
            />
          </div>
          <Input label="Name" value={editName} onChange={(e) => setEditName(e.target.value)} />
          <div>
            <label htmlFor="community-description" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Description
            </label>
            <textarea
              id="community-description"
              value={editDesc}
              onChange={(e) => setEditDesc(e.target.value)}
              rows={3}
              className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
            />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={editPublic}
              onChange={(e) => setEditPublic(e.target.checked)}
              className="accent-buddy-green"
            />
            Public community (anyone can find and read it)
          </label>
          <Button className="w-full" onClick={saveSettings}>Save changes</Button>
        </div>
      </Modal>

      {/* ── Invite ───────────────────────────────────────────────────── */}
      <Modal isOpen={showInvite} onClose={() => setShowInvite(false)} title="Invite members">
        <div className="space-y-3">
          <p className="text-sm text-buddy-text-secondary">Share this invite code:</p>
          <div className="flex items-center gap-3 bg-buddy-surface rounded-xl px-4 py-3">
            <span className="flex-1 font-mono tracking-[0.3em] text-center font-bold break-all">
              {community?.invite_code || '—'}
            </span>
            <button onClick={copyInvite} aria-label="Copy invite code" className="text-buddy-green hover:text-buddy-green/80">
              <Copy size={18} />
            </button>
          </div>
          {copyMsg && <p className="text-xs text-buddy-green">{copyMsg}</p>}
          {canManage && (
            <Button variant="outline" className="w-full" onClick={rotateInvite}>
              Generate a new code
            </Button>
          )}
        </div>
      </Modal>

      {/* ── Activity creation ────────────────────────────────────────── */}
      <Modal
        isOpen={!!activityModal}
        onClose={() => setActivityModal(null)}
        title={
          activityModal === 'event' ? 'Add community event'
            : activityModal === 'live' ? 'Schedule a live'
              : 'Add a schedule session'
        }
        size="lg"
      >
        <div className="space-y-3 max-h-[70vh] overflow-y-auto">
          {activityError && (
            <p className="text-xs text-buddy-red" role="alert">{activityError}</p>
          )}

          {activityModal === 'event' && (
            <>
              <Input
                label="Title"
                value={eventDraft.title}
                onChange={(e) => setEventDraft({ ...eventDraft, title: e.target.value })}
                placeholder="Saturday long run"
              />
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Description</label>
                <textarea
                  value={eventDraft.description}
                  onChange={(e) => setEventDraft({ ...eventDraft, description: e.target.value })}
                  rows={3}
                  className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Format</label>
                  <select
                    value={eventDraft.event_type}
                    onChange={(e) => setEventDraft({ ...eventDraft, event_type: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  >
                    <option value="in_person">In person</option>
                    <option value="online">Online</option>
                    <option value="hybrid">Hybrid</option>
                  </select>
                </div>
                <Input
                  label="Location"
                  value={eventDraft.location}
                  onChange={(e) => setEventDraft({ ...eventDraft, location: e.target.value })}
                  placeholder="Meeting point"
                />
                <Input
                  label="Online link (optional)"
                  value={eventDraft.online_url}
                  onChange={(e) => setEventDraft({ ...eventDraft, online_url: e.target.value })}
                  placeholder="https://…"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Starts</label>
                  <input
                    type="datetime-local"
                    aria-label="Starts"
                    value={eventDraft.start}
                    onChange={(e) => setEventDraft({ ...eventDraft, start: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Ends</label>
                  <input
                    type="datetime-local"
                    aria-label="Ends"
                    value={eventDraft.end}
                    onChange={(e) => setEventDraft({ ...eventDraft, end: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  />
                </div>
              </div>
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={eventDraft.is_free}
                  onChange={(e) => setEventDraft({ ...eventDraft, is_free: e.target.checked })}
                  className="accent-buddy-green"
                />
                Free to attend
              </label>
            </>
          )}

          {activityModal === 'live' && (
            <>
              <Input
                label="Title"
                value={liveDraft.title}
                onChange={(e) => setLiveDraft({ ...liveDraft, title: e.target.value })}
                placeholder="Mobility Q&A"
                maxLength={80}
              />
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Type</label>
                  <select
                    value={liveDraft.live_type}
                    onChange={(e) => setLiveDraft({ ...liveDraft, live_type: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  >
                    {LIVE_TYPES.map((type) => (
                      <option key={type} value={type}>{type.replace(/_/g, ' ')}</option>
                    ))}
                  </select>
                </div>
                <Input
                  label="Category"
                  value={liveDraft.category}
                  onChange={(e) => setLiveDraft({ ...liveDraft, category: e.target.value })}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Starts (optional)</label>
                <input
                  type="datetime-local"
                  aria-label="Starts"
                  value={liveDraft.scheduled}
                  onChange={(e) => setLiveDraft({ ...liveDraft, scheduled: e.target.value })}
                  className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Audience</label>
                <select
                  value={liveDraft.access}
                  onChange={(e) => setLiveDraft({ ...liveDraft, access: e.target.value })}
                  className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                >
                  <option value="public">Public</option>
                  <option value="buddies">Buddies only</option>
                  <option value="gym_members">Members only</option>
                  <option value="private">Only me</option>
                </select>
              </div>
            </>
          )}

          {activityModal === 'schedule' && (
            <>
              <Input
                label="Session title"
                value={scheduleDraft.title}
                onChange={(e) => setScheduleDraft({ ...scheduleDraft, title: e.target.value })}
                placeholder="Tempo run"
              />
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Details</label>
                <textarea
                  value={scheduleDraft.content}
                  onChange={(e) => setScheduleDraft({ ...scheduleDraft, content: e.target.value })}
                  rows={2}
                  className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Activity</label>
                  <select
                    value={scheduleDraft.activity_type}
                    onChange={(e) => setScheduleDraft({ ...scheduleDraft, activity_type: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  >
                    {ACTIVITY_TYPES.map((type) => (
                      <option key={type} value={type}>{type.replace(/_/g, ' ')}</option>
                    ))}
                  </select>
                </div>
                <Input
                  label="Custom activity (optional)"
                  value={scheduleDraft.custom_activity_type}
                  onChange={(e) => setScheduleDraft({ ...scheduleDraft, custom_activity_type: e.target.value })}
                />
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Where</label>
                  <select
                    value={scheduleDraft.location_mode}
                    onChange={(e) => setScheduleDraft({ ...scheduleDraft, location_mode: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  >
                    <option value="in_house">In person</option>
                    <option value="online">Online</option>
                    <option value="hybrid">Hybrid</option>
                  </select>
                </div>
                <Input
                  label="Max slots (0 = unlimited)"
                  type="number"
                  value={scheduleDraft.max_slots}
                  onChange={(e) => setScheduleDraft({ ...scheduleDraft, max_slots: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Starts</label>
                  <input
                    type="datetime-local"
                    aria-label="Starts"
                    value={scheduleDraft.start}
                    onChange={(e) => setScheduleDraft({ ...scheduleDraft, start: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Ends</label>
                  <input
                    type="datetime-local"
                    aria-label="Ends"
                    value={scheduleDraft.end}
                    onChange={(e) => setScheduleDraft({ ...scheduleDraft, end: e.target.value })}
                    className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Repeats</label>
                <select
                  value={scheduleDraft.recurrence}
                  onChange={(e) => setScheduleDraft({ ...scheduleDraft, recurrence: e.target.value })}
                  className="w-full bg-buddy-surface border border-transparent rounded-xl p-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                >
                  {['none', 'daily', 'weekly', 'monthly', 'yearly'].map((value) => (
                    <option key={value} value={value}>{value}</option>
                  ))}
                </select>
              </div>
              {scheduleDraft.recurrence === 'weekly' && (
                <div>
                  <p className="text-sm font-medium text-buddy-text-secondary mb-1.5">On these days</p>
                  <div className="flex flex-wrap gap-1.5">
                    {WEEKDAYS.map((day, index) => {
                      const active = scheduleDraft.recurrence_days.includes(index);
                      return (
                        <button
                          key={day}
                          type="button"
                          onClick={() => setScheduleDraft({
                            ...scheduleDraft,
                            recurrence_days: active
                              ? scheduleDraft.recurrence_days.filter((d) => d !== index)
                              : [...scheduleDraft.recurrence_days, index],
                          })}
                          className={`px-3 py-1.5 rounded-full text-xs ${
                            active ? 'bg-buddy-green text-buddy-black font-semibold' : 'bg-buddy-surface text-buddy-text-secondary'
                          }`}
                        >
                          {day}
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}
            </>
          )}

          <div className="flex gap-2 pt-2">
            <Button
              className="flex-1"
              onClick={submitActivity}
              isLoading={activityBusy}
              disabled={activityBusy}
            >
              Save
            </Button>
            <Button variant="ghost" onClick={() => setActivityModal(null)}>Cancel</Button>
          </div>
        </div>
      </Modal>

      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          communityId={communityId}
          isOpen={!!commentPostId}
          onClose={() => setCommentPostId(null)}
        />
      )}
    </div>
  );
}
