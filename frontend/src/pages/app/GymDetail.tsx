import { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Users, Radio, Info, MessageCircle, Settings, LogOut, Star, Calendar, StarHalf, Heart, Send, MapPin, Tag, Crown, BookOpen, Lock, Zap, AlertCircle, Search, X, Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { gymsApi, livesApi, profilesApi, marketplaceApi } from '@/api';
import type { Gym, GymMembership, Profile } from '@/types';
import type { BuddyLive } from '@/types/live';
import type { GymSchedulePost, GymReview } from '@/types/gym';
import { GymDiscoursePost } from '@/components/features/gyms/GymDiscoursePost';
import { PostComposer } from '@/components/features/feed/PostComposer';

type GymTab = 'feed' | 'schedule' | 'lives' | 'members' | 'reviews' | 'about' | 'events';

export default function GymDetail() {
  const { slug } = useParams();
  const navigate = useNavigate();
  const [gym, setGym] = useState<Gym | null>(null);
  const [members, setMembers] = useState<GymMembership[]>([]);
  const [schedule, setSchedule] = useState<BuddyLive[]>([]);
  const [activeTab, setActiveTab] = useState<GymTab>('feed');
  const [isLoading, setIsLoading] = useState(true);
  const [memberCount, setMemberCount] = useState(0);
  const [showGoLive, setShowGoLive] = useState(false);
  const [liveTitle, setLiveTitle] = useState('');
  const [liveSubmitting, setLiveSubmitting] = useState(false);

  // New states
  const [schedulePosts, setSchedulePosts] = useState<GymSchedulePost[]>([]);
  const [reviews, setReviews] = useState<GymReview[]>([]);
  const [events, setEvents] = useState<any[]>([]);
  
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [scheduleTitle, setScheduleTitle] = useState('');
  const [scheduleContent, setScheduleContent] = useState('');
  const [scheduleActivity, setScheduleActivity] = useState('other');
  const [scheduleCustomActivity, setScheduleCustomActivity] = useState('');
  const [scheduleLocationMode, setScheduleLocationMode] = useState('in_house');
  const [scheduleStartTime, setScheduleStartTime] = useState('');
  const [scheduleEndTime, setScheduleEndTime] = useState('');
  const [scheduleRecurrence, setScheduleRecurrence] = useState('none');
  const [scheduleRecurrenceEnd, setScheduleRecurrenceEnd] = useState('');
  const [scheduleMaxSlots, setScheduleMaxSlots] = useState('');
  
  const [feedPosts, setFeedPosts] = useState<any[]>([]);

  const [showReviewModal, setShowReviewModal] = useState(false);
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewComment, setReviewComment] = useState('');

  const [showReplyModal, setShowReplyModal] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');
  
  const [showDonateModal, setShowDonateModal] = useState(false);
  const [donateAmount, setDonateAmount] = useState('');
  const [donateMessage, setDonateMessage] = useState('');
  
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [inviteInput, setInviteInput] = useState('');
  const [inviteSubmitting, setInviteSubmitting] = useState(false);
  const [inviteSearchResults, setInviteSearchResults] = useState<Profile[]>([]);
  const [inviteSelectedUsers, setInviteSelectedUsers] = useState<Profile[]>([]);
  const [inviteSearchLoading, setInviteSearchLoading] = useState(false);
  const inviteDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  
  const [actionSubmitting, setActionSubmitting] = useState(false);
  const [scheduleError, setScheduleError] = useState<string | null>(null);

  useEffect(() => {
    if (!slug) return;
    setIsLoading(true);
    gymsApi.detail(slug)
      .then((res) => {
        setGym(res.data);
        setMemberCount(res.data?.member_count || 0);
        return Promise.all([
          gymsApi.getMembers(slug),
          livesApi.getGymSchedule(res.data.id),
          gymsApi.getSchedulePosts(slug).catch(() => ({ data: [] })),
          gymsApi.getReviews(slug).catch(() => ({ data: [] })),
          gymsApi.getGymFeed(slug).catch(() => ({ data: [] })),
          gymsApi.getEvents(slug).catch(() => ({ data: [] })),
        ]);
      })
      .then(([membersRes, scheduleRes, postsRes, reviewsRes, feedRes, eventsRes]) => {
        setMembers(membersRes.data || []);
        setSchedule(scheduleRes.data || []);
        setSchedulePosts(postsRes.data || []);
        setReviews(reviewsRes.data || []);
        setFeedPosts(feedRes.data || []);
        setEvents(eventsRes.data || []);
      })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, [slug]);

  const handleJoin = async () => {
    if (!slug) return;
    try {
      await gymsApi.join(slug);
      const res = await gymsApi.detail(slug);
      setGym(res.data);
      setMemberCount((c) => c + 1);
    } catch {}
  };

  const handleLeave = async () => {
    if (!slug) return;
    try {
      await gymsApi.leave(slug);
      const res = await gymsApi.detail(slug);
      setGym(res.data);
      setMemberCount((c) => Math.max(0, c - 1));
    } catch {}
  };

  const handleInvite = async () => {
    if (!slug) return;
    // Send to selected users or email fallback
    const targets = inviteSelectedUsers.length > 0
      ? inviteSelectedUsers
      : inviteInput.trim() ? [{ username: inviteInput.trim() } as Profile] : [];
    if (targets.length === 0) return;
    setInviteSubmitting(true);
    try {
      for (const target of targets) {
        const isEmail = !target.username && inviteInput.includes('@');
        const payload = isEmail
          ? { email: inviteInput.trim() }
          : { username: target.username };
        await gymsApi.invite(slug, payload);
      }
      setShowInviteModal(false);
      setInviteInput('');
      setInviteSelectedUsers([]);
      setInviteSearchResults([]);
      alert(`${targets.length} invite(s) sent!`);
    } catch (e: any) {
      alert(e?.response?.data?.message || 'Failed to send invite.');
    } finally {
      setInviteSubmitting(false);
    }
  };

  const searchInviteUsers = useCallback((q: string) => {
    if (inviteDebounce.current) clearTimeout(inviteDebounce.current);
    if (!q.trim() || q.includes('@')) {
      setInviteSearchResults([]);
      return;
    }
    inviteDebounce.current = setTimeout(async () => {
      setInviteSearchLoading(true);
      try {
        const res = await profilesApi.searchProfiles({ q, limit: 8 });
        const results = (res.data || []).filter(
          (p: Profile) => !inviteSelectedUsers.find(s => s.username === p.username)
        );
        setInviteSearchResults(results);
      } catch {} finally {
        setInviteSearchLoading(false);
      }
    }, 200);
  }, [inviteSelectedUsers]);

  const handleReviewReply = async (reviewId: string) => {
    if (!slug || !replyText.trim()) return;
    setActionSubmitting(true);
    try {
      const res = await gymsApi.replyToReview(slug, reviewId, replyText);
      setReviews(reviews.map(r => r.id === reviewId ? res.data : r));
      setShowReplyModal(null);
      setReplyText('');
    } catch {}
    setActionSubmitting(false);
  };

  const toISO = (val: string) => {
    if (!val) return undefined;
    try { return new Date(val).toISOString(); } catch { return undefined; }
  };

  const handleScheduleSubmit = async () => {
    if (!slug || !scheduleActivity) return;
    setScheduleError(null);
    setActionSubmitting(true);
    try {
      const res = await gymsApi.createSchedulePost(slug, {
        title: scheduleTitle,
        content: scheduleContent,
        activity_type: scheduleActivity,
        custom_activity_type: scheduleCustomActivity,
        location_mode: scheduleLocationMode,
        start_time: toISO(scheduleStartTime),
        end_time: toISO(scheduleEndTime),
        recurrence: scheduleRecurrence,
        recurrence_end_date: scheduleRecurrenceEnd || undefined,
        max_slots: parseInt(scheduleMaxSlots) || 0,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      });
      setSchedulePosts([res.data, ...schedulePosts]);
      setShowScheduleModal(false);
      setScheduleTitle('');
      setScheduleContent('');
      setScheduleActivity('other');
      setScheduleCustomActivity('');
      setScheduleLocationMode('in_house');
      setScheduleStartTime('');
      setScheduleEndTime('');
      setScheduleRecurrence('none');
      setScheduleRecurrenceEnd('');
      setScheduleMaxSlots('');
    } catch (e: any) {
      const errData = e?.response?.data;
      const msg = errData?.message || errData?.errors || (typeof errData === 'string' ? errData : null) || 'Failed to create schedule post. Please try again.';
      setScheduleError(typeof msg === 'object' ? JSON.stringify(msg) : msg);
    }
    setActionSubmitting(false);
  };

  if (isLoading) return <div className="max-w-lg mx-auto p-4"><div className="animate-pulse space-y-4"><div className="bg-buddy-surface rounded-2xl h-48" /><div className="bg-buddy-surface rounded-2xl h-64" /></div></div>;
  if (!gym) return <div className="max-w-lg mx-auto p-4 text-center py-20"><p className="text-buddy-text-secondary">Gym not found</p></div>;

  const isOwner = gym.membership_role === 'owner' || gym.membership_role === 'co_owner';
  const isAdmin = isOwner || gym.membership_role === 'moderator';

  const tabs: { key: GymTab; label: string; icon: typeof Users }[] = [
    { key: 'feed', label: 'Feed', icon: MessageCircle },
    { key: 'schedule', label: 'Schedule', icon: Calendar },
    { key: 'events', label: 'Events', icon: Tag },
    { key: 'lives', label: 'Lives', icon: Radio },
    { key: 'members', label: 'Members', icon: Users },
    ...(gym.is_reviews_enabled ? [{ key: 'reviews' as GymTab, label: 'Reviews', icon: StarHalf }] : []),
    { key: 'about', label: 'About', icon: Info },
  ];

  return (
    <div className="max-w-lg mx-auto">
      {/* Header */}
      <div className="relative h-40 bg-gradient-to-b from-buddy-surface to-buddy-black">
        {gym.cover_url && <img src={gym.cover_url} alt="" className="w-full h-full object-cover" />}
        <div className="absolute bottom-4 left-4 flex items-end gap-3">
          <div className="w-16 h-16 rounded-xl bg-buddy-green/10 flex items-center justify-center text-3xl border-2 border-buddy-black">
            {gym.logo_url ? <img src={gym.logo_url} alt="" className="w-full h-full rounded-xl object-cover" /> : '🏋️'}
          </div>
          <div>
            <h1 className="font-heading text-xl font-semibold">{gym.name}</h1>
            <p className="text-xs text-buddy-text-secondary">@{gym.handle} · {memberCount} members</p>
            {gym.is_reviews_enabled && gym.average_rating !== undefined && gym.average_rating > 0 && (
              <div className="flex items-center gap-2 mt-1">
                <span className="flex items-center gap-1 text-sm text-yellow-500 font-medium">
                  <Star size={14} className="fill-current" /> {gym.average_rating.toFixed(1)}
                </span>
                {gym.recent_reviewers && gym.recent_reviewers.length > 0 && (
                  <div className="flex -space-x-2">
                    {gym.recent_reviewers.map((r, i) => (
                      <Avatar key={i} src={r.avatar_url} alt={r.display_name} size="sm" className="w-6 h-6 border-2 border-buddy-black" />
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="p-4">
        {/* Join/Leave + Admin buttons */}
        <div className="flex gap-2 mb-4">
          {gym.is_member ? (
            <>
              {!isOwner && <Button variant="outline" size="sm" onClick={handleLeave}><LogOut size={14} className="mr-1" /> Leave</Button>}
              {isAdmin && <Button variant="outline" size="sm" onClick={() => navigate(`/gyms/${slug}/manage`)}><Settings size={14} className="mr-1" /> Manage</Button>}
            </>
          ) : (
            <Button size="sm" className="flex-1" onClick={handleJoin}>{gym.access_type === 'public' ? 'Join Gym' : 'Request to Join'}</Button>
          )}
          {gym.is_donations_enabled && (
            <Button size="sm" variant="outline" onClick={() => setShowDonateModal(true)} className="text-buddy-pink border-buddy-pink/30 hover:bg-buddy-pink/10">
              <Heart size={14} className="mr-1" /> Donate
            </Button>
          )}
          <Button size="sm" variant="ghost"><Star size={14} /></Button>
        </div>

        {/* Tabs — horizontally scrollable, spacious */}
        <div className="-mx-4 px-4 overflow-x-auto scrollbar-hide mb-5">
          <div className="flex gap-1 border-b border-buddy-surface min-w-max">
            {tabs.map(({ key, label, icon: Icon }) => (
              <button key={key} onClick={() => setActiveTab(key)}
                className={`flex items-center gap-2 px-4 py-3 text-sm font-medium whitespace-nowrap flex-shrink-0 border-b-2 transition-all ${
                  activeTab === key
                    ? 'text-buddy-green border-buddy-green'
                    : 'text-buddy-text-secondary border-transparent hover:text-buddy-text-primary'
                }`}
              >
                <Icon size={15} /> {label}
              </button>
            ))}
          </div>
        </div>

        {/* Feed tab */}
        {activeTab === 'feed' && (
          <div className="space-y-4">
            {gym.is_member && (
              <PostComposer
                gymId={gym.id}
                gymName={gym.name}
                placeholder="Share an update, ask a question, or start a discussion..."
                onPost={(post) => setFeedPosts(prev => [post, ...prev])}
                hideVisibility
              />
            )}
            
            {feedPosts.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No discussions yet in this gym.</div>
            ) : (
              <div className="space-y-3">
                {feedPosts.map((post) => (
                  <GymDiscoursePost key={post.id} post={post} isAdmin={isAdmin} gymName={gym.name}
                    onPin={(id, pinned) => setFeedPosts(prev => prev.map(p => p.id === id ? { ...p, is_pinned: pinned } : p).sort((a, b) => (b.is_pinned ? 1 : 0) - (a.is_pinned ? 1 : 0)))} />
                ))}
              </div>
            )}
          </div>
        )}

        {/* Schedule Tab */}
        {activeTab === 'schedule' && (
          <div className="space-y-4">
            {isAdmin && (
              <Button className="w-full gap-1.5" size="sm" onClick={() => setShowScheduleModal(true)}>
                <Calendar size={14} /> Post Schedule Update
              </Button>
            )}
            
            {schedulePosts.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No schedule updates posted yet.</div>
            ) : (
              <div className="space-y-3">
                {schedulePosts.map((post) => (
                  <Card key={post.id} className="p-4 space-y-3">
                    <div className="flex items-center gap-2">
                      <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name} size="sm" />
                      <div>
                        <p className="text-sm font-medium">{post.author_data?.display_name}</p>
                        <p className="text-xs text-buddy-text-secondary">
                          @{post.author_data?.username} · {new Date(post.created_at).toLocaleDateString()}
                        </p>
                      </div>
                    </div>
                    {post.title && <h3 className="font-semibold text-sm">{post.title}</h3>}
                    <div className="flex flex-wrap gap-2 mb-2">
                      <Badge variant="blue" label={post.activity_type.replace('_', ' ')} />
                      {post.location_mode && <Badge variant="green" label={post.location_mode.replace('_', ' ')} />}
                      {post.start_time && (
                        <span className="text-xs text-buddy-text-secondary bg-buddy-surface rounded px-2 py-1 flex items-center">
                          <Calendar size={12} className="mr-1" /> {new Date(post.start_time).toLocaleString()}
                        </span>
                      )}
                      {post.recurrence && post.recurrence !== 'none' && (
                        <span className="text-xs text-buddy-electric bg-buddy-electric/10 rounded px-2 py-1 flex items-center capitalize">
                          Repeats {post.recurrence}
                        </span>
                      )}
                    </div>
                    <p className="text-sm whitespace-pre-wrap leading-relaxed mb-3">{post.content}</p>
                    
                    <div className="flex items-center justify-between mt-3 pt-3 border-t border-buddy-surface">
                      <div className="flex flex-col">
                        <span className="text-xs text-buddy-text-secondary">Enrolled</span>
                        <span className="text-sm font-semibold">{post.enrollment_count || 0} {post.max_slots > 0 ? `/ ${post.max_slots}` : ''}</span>
                      </div>
                      
                      <Button size="sm" 
                        variant={post.is_enrolled ? "outline" : "primary"}
                        disabled={post.is_enrolled || (post.max_slots > 0 && (post.enrollment_count || 0) >= post.max_slots)}
                        onClick={() => {
                          if (!slug || post.is_enrolled) return;
                          gymsApi.enrollScheduleSlot(slug, post.id).then(() => {
                            setSchedulePosts(schedulePosts.map(p => p.id === post.id ? { ...p, is_enrolled: true, enrollment_count: (p.enrollment_count || 0) + 1 } : p));
                          }).catch((e: any) => alert(e?.response?.data?.message || 'Failed to enroll'));
                        }}
                      >
                        {post.is_enrolled ? 'Enrolled' : (post.max_slots > 0 && (post.enrollment_count || 0) >= post.max_slots) ? 'Full' : 'Enroll Now'}
                      </Button>
                    </div>
                  </Card>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Lives tab */}
        {activeTab === 'lives' && (
          <div className="space-y-3">
            {isAdmin && (
              <Button className="w-full gap-1.5" size="sm" onClick={() => setShowGoLive(true)}>
                <Radio size={14} /> Go Live
              </Button>
            )}
            {schedule.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No scheduled lives.</div>
            ) : (
              schedule.map((live) => (
                <Card key={live.id} className="p-3 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-buddy-green/10 flex items-center justify-center flex-shrink-0">
                    <Radio size={16} className="text-buddy-green" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{live.title}</p>
                    <p className="text-xs text-buddy-text-secondary">{new Date(live.scheduled_for || '').toLocaleDateString()} · {live.category}</p>
                  </div>
                  <Button size="sm" variant={live.has_rsvped ? 'primary' : 'outline'}
                    onClick={() => livesApi.rsvpLive(live.id).then(() => {
                      livesApi.getGymSchedule(gym.id).then((r) => setSchedule(r.data || []));
                    })}>
                    {live.has_rsvped ? 'RSVPed' : 'RSVP'}
                  </Button>
                </Card>
              ))
            )}

            {/* Go Live Modal */}
            {showGoLive && (
              <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => setShowGoLive(false)}>
                <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4" onClick={(e) => e.stopPropagation()}>
                  <h2 className="text-lg font-semibold">Start a Gym Live</h2>
                  <input type="text" value={liveTitle} onChange={(e) => setLiveTitle(e.target.value)} maxLength={80}
                    placeholder="Live title..."
                    className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
                  <div className="flex gap-2">
                    <Button className="flex-1" disabled={!liveTitle.trim()} isLoading={liveSubmitting}
                      onClick={async () => {
                        if (!liveTitle.trim() || !gym) return;
                        setLiveSubmitting(true);
                        try {
                          const res = await livesApi.startLive({
                            title: liveTitle.trim(),
                            live_type: 'gym_live',
                            category: 'other',
                            gym_id: gym.id,
                          });
                          setShowGoLive(false);
                          setLiveTitle('');
                          navigate(`/live/${res.data.live.id}`);
                        } catch {} finally { setLiveSubmitting(false); }
                      }}>
                      Go Live
                    </Button>
                    <Button variant="ghost" onClick={() => setShowGoLive(false)}>Cancel</Button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Members tab */}
        {activeTab === 'members' && (
          <div className="space-y-4">
            {gym.is_member && (
              <Button className="w-full gap-1.5" size="sm" onClick={() => setShowInviteModal(true)}>
                <Send size={14} /> Invite Member
              </Button>
            )}
            
            <div className="space-y-2">
            {members.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No members yet.</div>
            ) : (
              members.map((m) => (
                <Card key={m.id} className="p-3 flex items-center gap-3"
                  onClick={() => navigate(`/${m.member_data?.username}`)}>
                  <Avatar src={m.member_data?.avatar_url} alt={m.member_data?.display_name || 'Member'} size="sm" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium">{m.member_data?.display_name}</p>
                    <p className="text-xs text-buddy-text-secondary">@{m.member_data?.username}</p>
                  </div>
                  <Badge variant={m.role === 'owner' ? 'gold' : m.role === 'trainer' ? 'green' : m.role === 'moderator' ? 'blue' : 'silver'}
                    label={m.role.replace('_', ' ')} size="sm" />
                </Card>
              ))
            )}
            </div>
          </div>
        )}

        {/* Reviews tab */}
        {activeTab === 'reviews' && (
          <div className="space-y-4">
            {gym.is_member && (
              <Button className="w-full gap-1.5" size="sm" onClick={() => setShowReviewModal(true)}>
                <StarHalf size={14} /> Write a Review
              </Button>
            )}
            
            {reviews.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No reviews yet.</div>
            ) : (
              <div className="space-y-3">
                {reviews.map((review) => (
                  <Card key={review.id} className="p-4 space-y-3">
                    <div className="flex items-center gap-2">
                      <Avatar src={review.reviewer_data?.avatar_url} alt={review.reviewer_data?.display_name} size="sm" />
                      <div className="flex-1">
                        <p className="text-sm font-medium">{review.reviewer_data?.display_name}</p>
                        <div className="flex items-center gap-1 text-xs text-buddy-text-secondary">
                          @{review.reviewer_data?.username} · 
                          <span className="flex text-yellow-400">
                            {Array.from({ length: review.rating }).map((_, i) => <Star key={i} size={10} fill="currentColor" />)}
                          </span>
                        </div>
                      </div>
                    </div>
                    {review.comment && <p className="text-sm leading-relaxed">{review.comment}</p>}
                    
                    {review.reply_text && (
                      <div className="mt-3 bg-buddy-surface rounded-lg p-3 border-l-2 border-buddy-green ml-4">
                        <div className="flex items-center gap-2 mb-1">
                          <Avatar src={review.replied_by_data?.avatar_url} alt={review.replied_by_data?.display_name || 'Gym Admin'} size="sm" className="w-5 h-5" />
                          <span className="text-xs font-semibold">{review.replied_by_data?.display_name || 'Gym Admin'}</span>
                          <span className="text-[10px] text-buddy-text-secondary">replied</span>
                        </div>
                        <p className="text-sm text-buddy-text-secondary leading-relaxed">{review.reply_text}</p>
                      </div>
                    )}

                    {isAdmin && !review.reply_text && (
                      <div className="flex justify-end mt-2">
                        <Button size="sm" variant="ghost" onClick={() => setShowReplyModal(review.id)}>
                          <MessageCircle size={14} className="mr-1" /> Reply
                        </Button>
                      </div>
                    )}
                  </Card>
                ))}
              </div>
            )}
            
            {/* Reply Modal */}
            {showReplyModal && (
              <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => setShowReplyModal(null)}>
                <div className="bg-buddy-surface rounded-2xl p-6 max-w-md w-full space-y-4" onClick={(e) => e.stopPropagation()}>
                  <h2 className="text-lg font-semibold">Reply to Review</h2>
                  <textarea
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                    placeholder="Write your response..."
                    className="w-full bg-buddy-black rounded-xl p-3 text-sm focus:outline-none focus:ring-1 focus:ring-buddy-green resize-none"
                    rows={4}
                  />
                  <div className="flex justify-end gap-2">
                    <Button variant="ghost" onClick={() => { setShowReplyModal(null); setReplyText(''); }}>Cancel</Button>
                    <Button onClick={() => handleReviewReply(showReplyModal)} disabled={!replyText.trim() || actionSubmitting} isLoading={actionSubmitting}>
                      Post Reply
                    </Button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Events Tab */}
        {activeTab === 'events' && (
          <div className="space-y-4 pb-4">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold flex items-center gap-2"><Tag className="text-buddy-electric" size={20} /> Gym Events</h2>
              {isAdmin && (
                <Button size="sm" onClick={() => { setScheduleActivity('event'); setShowScheduleModal(true); }}>
                  <Plus size={16} className="mr-1" /> Create Event
                </Button>
              )}
            </div>

            {events.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary bg-buddy-surface rounded-2xl">
                <Tag size={32} className="mx-auto mb-3 opacity-20" />
                <p>No upcoming events.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {events.map((event) => (
                  <Card key={event.id} className="p-4 flex flex-col sm:flex-row gap-4 relative overflow-hidden group">
                    <div className="w-full sm:w-24 h-32 sm:h-24 flex-shrink-0 bg-buddy-surface-raised rounded-xl overflow-hidden relative">
                      {event.cover_image_url ? (
                        <img src={event.cover_image_url} alt={event.title} className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center">
                          <Tag size={24} className="text-buddy-text-secondary opacity-50" />
                        </div>
                      )}
                      <div className="absolute top-2 left-2 px-2 py-0.5 bg-buddy-black/80 backdrop-blur-sm rounded text-[10px] font-bold uppercase tracking-wider text-buddy-gold">
                        {event.event_type.replace('_', ' ')}
                      </div>
                    </div>
                    
                    <div className="flex-1 min-w-0 flex flex-col justify-between">
                      <div>
                        <h3 className="font-semibold text-lg leading-tight mb-1 truncate">{event.title}</h3>
                        <p className="text-xs text-buddy-text-secondary line-clamp-2">{event.description || 'No description provided.'}</p>
                      </div>
                      
                      <div className="mt-3 flex items-center justify-between">
                        <div className="flex flex-col gap-1">
                          <div className="flex items-center gap-1.5 text-xs text-buddy-text-primary">
                            <Calendar size={14} className="text-buddy-green" />
                            {new Date(event.start_datetime).toLocaleDateString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                          </div>
                          {event.location && (
                            <div className="flex items-center gap-1.5 text-xs text-buddy-text-secondary">
                              <MapPin size={14} /> <span className="truncate max-w-[120px]">{event.location}</span>
                            </div>
                          )}
                        </div>
                        
                        <div className="flex flex-col items-end gap-2">
                          <div className="text-sm font-bold text-buddy-green">
                            {event.is_free ? 'Free' : Object.entries(event.ticket_price_artifacts || {}).map(([k, v]) => `${v} ${k}s`).join(', ')}
                          </div>
                          <Button size="sm" variant={event.is_registered ? 'outline' : 'primary'} onClick={async () => {
                              try {
                                await marketplaceApi.buyEventTicket(event.id);
                                const res = await gymsApi.getEvents(slug!);
                                setEvents(res.data);
                              } catch (e: any) {
                                alert(e?.response?.data?.message || 'Failed to register for event.');
                              }
                          }}>
                            {event.is_registered ? 'Registered' : (event.is_free ? 'RSVP' : 'Buy Ticket')}
                          </Button>
                        </div>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            )}
          </div>
        )}

        {/* About tab — premium grid layout */}
        {activeTab === 'about' && (
          <div className="space-y-4 pb-4">
            {/* Description */}
            {gym.description && (
              <Card className="p-5">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-7 h-7 rounded-lg bg-buddy-green/10 flex items-center justify-center"><BookOpen size={14} className="text-buddy-green" /></div>
                  <h3 className="font-heading font-semibold text-sm">About</h3>
                </div>
                <p className="text-sm text-buddy-text-secondary leading-relaxed">{gym.description}</p>
              </Card>
            )}

            {/* Info grid */}
            <div className="grid grid-cols-2 gap-3">
              <Card className="p-4 flex flex-col gap-1">
                <div className="w-7 h-7 rounded-lg bg-buddy-electric/10 flex items-center justify-center mb-1"><Tag size={13} className="text-buddy-electric" /></div>
                <p className="text-xs text-buddy-text-secondary">Category</p>
                <p className="text-sm font-semibold capitalize">{gym.category?.replace(/_/g, ' ') || '—'}</p>
              </Card>
              <Card className="p-4 flex flex-col gap-1">
                <div className="w-7 h-7 rounded-lg bg-buddy-orange/10 flex items-center justify-center mb-1"><Lock size={13} className="text-buddy-orange" /></div>
                <p className="text-xs text-buddy-text-secondary">Access</p>
                <p className="text-sm font-semibold capitalize">{gym.access_type?.replace(/_/g, ' ') || '—'}</p>
              </Card>
              <Card className="p-4 col-span-2 flex items-center gap-3">
                <div className="w-7 h-7 rounded-lg bg-buddy-gold/10 flex items-center justify-center flex-shrink-0"><Zap size={13} className="text-buddy-gold" /></div>
                <div>
                  <p className="text-xs text-buddy-text-secondary">Subscription</p>
                  <p className="text-sm font-semibold capitalize">{gym.subscription_type?.replace(/_/g, ' ') || 'Free'}</p>
                </div>
              </Card>
            </div>

            {/* Gym Rules */}
            {gym.rules?.length > 0 && (
              <Card className="p-5">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-7 h-7 rounded-lg bg-red-500/10 flex items-center justify-center"><AlertCircle size={13} className="text-red-400" /></div>
                  <h3 className="font-heading font-semibold text-sm">Gym Rules</h3>
                </div>
                <ol className="space-y-2">
                  {gym.rules.map((rule, i) => (
                    <li key={i} className="flex items-start gap-3">
                      <span className="w-5 h-5 rounded-full bg-buddy-surface-raised text-[11px] font-bold flex items-center justify-center flex-shrink-0 mt-0.5 text-buddy-green">{i + 1}</span>
                      <span className="text-sm text-buddy-text-secondary leading-relaxed">{rule}</span>
                    </li>
                  ))}
                </ol>
              </Card>
            )}

            {/* Tags */}
            {gym.tags?.length > 0 && (
              <Card className="p-4">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-7 h-7 rounded-lg bg-buddy-green/10 flex items-center justify-center"><Tag size={13} className="text-buddy-green" /></div>
                  <h3 className="font-heading font-semibold text-sm">Tags</h3>
                </div>
                <div className="flex flex-wrap gap-2">
                  {gym.tags.map((tag) => (
                    <span key={tag} className="text-xs bg-buddy-green/10 text-buddy-green border border-buddy-green/20 px-3 py-1 rounded-full font-medium">{tag}</span>
                  ))}
                </div>
              </Card>
            )}

            {/* Leadership */}
            {gym.owner_data?.length > 0 && (
              <Card className="p-5">
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-7 h-7 rounded-lg bg-buddy-gold/10 flex items-center justify-center"><Crown size={13} className="text-buddy-gold" /></div>
                  <h3 className="font-heading font-semibold text-sm">Gym Leadership</h3>
                </div>
                <div className="space-y-3">
                  {gym.owner_data.map((o) => (
                    <div key={o.user_id} className="flex items-center gap-3">
                      <Avatar src={o.avatar_url} alt={o.display_name} size="md" />
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold truncate">{o.display_name}</p>
                        <p className="text-xs text-buddy-text-secondary">@{o.username}</p>
                      </div>
                      <span className="text-[10px] bg-buddy-gold/10 text-buddy-gold border border-buddy-gold/20 px-2 py-0.5 rounded-full capitalize font-medium">{o.role}</span>
                    </div>
                  ))}
                </div>
              </Card>
            )}
          </div>
        )}
      </div>

      {/* Schedule Post Modal */}
      {showScheduleModal && (
        <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => setShowScheduleModal(false)}>
          <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4" onClick={(e) => e.stopPropagation()}>
            <h2 className="text-lg font-semibold">Post Schedule Update</h2>
            <input type="text" value={scheduleTitle} onChange={(e) => setScheduleTitle(e.target.value)} maxLength={150}
              placeholder="Title (optional)"
              className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Activity Type</label>
                <select value={scheduleActivity} onChange={(e) => setScheduleActivity(e.target.value)}
                  className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
                  <option value="yoga">Yoga Class</option>
                  <option value="hiit">HIIT Session</option>
                  <option value="strength">Strength & Conditioning</option>
                  <option value="cardio">Cardio Class</option>
                  <option value="live_stream">Live Stream</option>
                  <option value="workshop">Workshop / Seminar</option>
                  <option value="event">Special Event</option>
                  <option value="session">Session</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Location</label>
                <select value={scheduleLocationMode} onChange={(e) => setScheduleLocationMode(e.target.value)}
                  className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
                  <option value="in_house">In House</option>
                  <option value="online">Online</option>
                  <option value="hybrid">Hybrid</option>
                </select>
              </div>
            </div>
            {scheduleActivity === 'other' && (
              <input type="text" value={scheduleCustomActivity} onChange={(e) => setScheduleCustomActivity(e.target.value)}
                placeholder="Custom Activity Name"
                className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
            )}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Start Time</label>
                <input type="datetime-local" value={scheduleStartTime} onChange={(e) => setScheduleStartTime(e.target.value)}
                   className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              </div>
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">End Time</label>
                <input type="datetime-local" value={scheduleEndTime} onChange={(e) => setScheduleEndTime(e.target.value)}
                  className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Recurrence</label>
                <select value={scheduleRecurrence} onChange={(e) => setScheduleRecurrence(e.target.value)}
                  className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30">
                  <option value="none">None</option>
                  <option value="daily">Daily</option>
                  <option value="weekly">Weekly</option>
                  <option value="monthly">Monthly</option>
                </select>
              </div>
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Max Slots (0 for unlim)</label>
                <input type="number" value={scheduleMaxSlots} onChange={(e) => setScheduleMaxSlots(e.target.value)}
                  placeholder="Unlimited"
                  className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              </div>
            </div>

            {scheduleRecurrence !== 'none' && (
              <div className="space-y-1">
                <label className="text-xs text-buddy-text-secondary">Recurrence End Date</label>
                <input type="date" value={scheduleRecurrenceEnd} onChange={(e) => setScheduleRecurrenceEnd(e.target.value)}
                   className="w-full bg-buddy-black rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              </div>
            )}
            <textarea value={scheduleContent} onChange={(e) => setScheduleContent(e.target.value)} rows={3}
              placeholder="What's the schedule update?"
              className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none" />

            {/* Error display */}
            {scheduleError && (
              <div className="flex items-start gap-2 bg-red-500/10 border border-red-500/20 rounded-xl px-3 py-2 text-sm text-red-400">
                <AlertCircle size={14} className="flex-shrink-0 mt-0.5" />
                <span>{scheduleError}</span>
              </div>
            )}
            
            <div className="flex gap-2">
              <Button className="flex-1 gap-1" disabled={actionSubmitting} isLoading={actionSubmitting}
                onClick={handleScheduleSubmit}>
                <Send size={14} /> Post
              </Button>
              <Button variant="ghost" onClick={() => { setShowScheduleModal(false); setScheduleError(null); }}>Cancel</Button>
            </div>
          </div>
        </div>
      )}

      {/* Review Modal */}
      {showReviewModal && (
        <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => setShowReviewModal(false)}>
          <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4" onClick={(e) => e.stopPropagation()}>
            <h2 className="text-lg font-semibold">Write a Review</h2>
            
            <div className="flex gap-2 justify-center py-2">
              {[1, 2, 3, 4, 5].map((star) => (
                <button key={star} onClick={() => setReviewRating(star)} className="focus:outline-none">
                  <Star size={24} className={star <= reviewRating ? 'text-yellow-400 fill-current' : 'text-buddy-text-secondary'} />
                </button>
              ))}
            </div>

            <textarea value={reviewComment} onChange={(e) => setReviewComment(e.target.value)} rows={4}
              placeholder="Tell others what you think..."
              className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none" />
            
            <div className="flex gap-2">
              <Button className="flex-1" isLoading={actionSubmitting}
                onClick={async () => {
                  if (!slug) return;
                  setActionSubmitting(true);
                  try {
                    await gymsApi.createReview(slug, {
                      rating: reviewRating,
                      comment: reviewComment.trim(),
                    });
                    const res = await gymsApi.getReviews(slug);
                    setReviews(res.data || []);
                    setShowReviewModal(false);
                  } catch (e: any) {
                    alert(e.response?.data?.message || 'Failed to submit review');
                  } finally { setActionSubmitting(false); }
                }}>
                Submit Review
              </Button>
              <Button variant="ghost" onClick={() => setShowReviewModal(false)}>Cancel</Button>
            </div>
          </div>
        </div>
      )}

      {/* Donate Modal */}
      {showDonateModal && (
        <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => setShowDonateModal(false)}>
          <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4" onClick={(e) => e.stopPropagation()}>
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <Heart className="text-buddy-pink" /> Donate to {gym.name}
            </h2>
            <p className="text-sm text-buddy-text-secondary">Support this gym by sending a donation from your wallet.</p>
            
            <div className="relative">
              <span className="absolute left-4 top-3 font-medium text-buddy-text-secondary">KES</span>
              <input type="number" value={donateAmount} onChange={(e) => setDonateAmount(e.target.value)}
                placeholder="0.00" min="0" step="1"
                className="w-full bg-buddy-black rounded-xl pl-14 pr-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-pink/30" />
            </div>

            <textarea value={donateMessage} onChange={(e) => setDonateMessage(e.target.value)} rows={2}
              placeholder="Leave a supportive message... (optional)"
              className="w-full bg-buddy-black rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-pink/30 resize-none" />
            
            <div className="flex gap-2">
              <Button className="flex-1 bg-buddy-pink hover:bg-buddy-pink/90 text-white" disabled={!donateAmount || Number(donateAmount) <= 0} isLoading={actionSubmitting}
                onClick={async () => {
                  if (!donateAmount || Number(donateAmount) <= 0 || !slug) return;
                  setActionSubmitting(true);
                  try {
                    await gymsApi.donate(slug, {
                      amount: Number(donateAmount),
                      message: donateMessage.trim(),
                    });
                    alert('Donation successful! Thank you.');
                    setShowDonateModal(false);
                    setDonateAmount('');
                    setDonateMessage('');
                  } catch (e: any) {
                    alert(e.response?.data?.message || 'Failed to process donation');
                  } finally { setActionSubmitting(false); }
                }}>
                Donate KES {donateAmount || '0'}
              </Button>
              <Button variant="ghost" onClick={() => setShowDonateModal(false)}>Cancel</Button>
            </div>
          </div>
        </div>
      )}

      {/* Invite Modal — fuzzy search with multi-select */}
      {showInviteModal && (
        <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={() => { setShowInviteModal(false); setInviteSearchResults([]); setInviteInput(''); setInviteSelectedUsers([]); }}>
          <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4" onClick={(e) => e.stopPropagation()}>
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <Send className="text-buddy-green" size={20} /> Invite Members
            </h2>
            <p className="text-sm text-buddy-text-secondary">Search by username or enter an email address to invite.</p>

            {/* Selected user chips */}
            {inviteSelectedUsers.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {inviteSelectedUsers.map(u => (
                  <span key={u.username} className="flex items-center gap-1.5 bg-buddy-green/15 text-buddy-green text-xs px-3 py-1.5 rounded-full font-medium">
                    <Avatar src={u.avatar_url} alt={u.display_name} size="xs" className="w-4 h-4" />
                    @{u.username}
                    <button onClick={() => { setInviteSelectedUsers(prev => prev.filter(p => p.username !== u.username)); }} className="ml-0.5 hover:text-white transition-colors">
                      <X size={12} />
                    </button>
                  </span>
                ))}
              </div>
            )}

            {/* Search input */}
            <div className="relative">
              <div className="flex items-center gap-2 bg-buddy-black rounded-xl px-3 py-2 focus-within:ring-2 focus-within:ring-buddy-green/30">
                <Search size={16} className="text-buddy-text-secondary flex-shrink-0" />
                <input
                  type="text"
                  value={inviteInput}
                  onChange={(e) => {
                    setInviteInput(e.target.value);
                    searchInviteUsers(e.target.value);
                  }}
                  placeholder={inviteSelectedUsers.length > 0 ? 'Add more...' : 'Search username or type email...'}
                  className="flex-1 bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 outline-none"
                />
                {inviteSearchLoading && <div className="w-4 h-4 border-2 border-buddy-green/40 border-t-buddy-green rounded-full animate-spin flex-shrink-0" />}
              </div>

              {/* Dropdown results */}
              {inviteSearchResults.length > 0 && (
                <div className="absolute top-full left-0 right-0 mt-1 bg-buddy-surface-raised border border-buddy-surface rounded-xl overflow-hidden shadow-2xl z-10">
                  {inviteSearchResults.map((user) => (
                    <button
                      key={user.username}
                      onClick={() => {
                        setInviteSelectedUsers(prev => [...prev, user]);
                        setInviteSearchResults(prev => prev.filter(p => p.username !== user.username));
                        setInviteInput('');
                      }}
                      className="w-full flex items-center gap-3 px-3 py-2.5 hover:bg-buddy-green/10 transition-colors text-left"
                    >
                      <Avatar src={user.avatar_url} alt={user.display_name || user.username} size="sm" />
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium truncate">{user.display_name}</p>
                        <p className="text-xs text-buddy-text-secondary">@{user.username}</p>
                      </div>
                      <Plus size={16} className="text-buddy-green flex-shrink-0" />
                    </button>
                  ))}
                </div>
              )}
            </div>

            <div className="flex gap-2">
              <Button
                className="flex-1"
                disabled={(inviteSelectedUsers.length === 0 && !inviteInput.trim()) || inviteSubmitting}
                isLoading={inviteSubmitting}
                onClick={handleInvite}
              >
                {inviteSelectedUsers.length > 0 ? `Send ${inviteSelectedUsers.length} Invite(s)` : 'Send Invite'}
              </Button>
              <Button variant="ghost" onClick={() => { setShowInviteModal(false); setInviteInput(''); setInviteSelectedUsers([]); setInviteSearchResults([]); }}>Cancel</Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
