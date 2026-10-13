import { useCallback, useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Calendar, Check, MessageCircle, Send, Star, Users, X, Plus } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { gymsApi } from '@/api/gyms';
import type { Gym, GymMembership, GymSchedulePost, GymReview, JoinRequest } from '@/types';
import { RoleDashboardShell, RoleSectionTitle } from './roles/RoleShell';

type Tab = 'members' | 'requests' | 'schedule' | 'reviews';

const TABS: { key: Tab; label: string }[] = [
  { key: 'members', label: 'Members' },
  { key: 'requests', label: 'Join requests' },
  { key: 'schedule', label: 'Schedule' },
  { key: 'reviews', label: 'Reviews' },
];

const toISO = (val: string) => {
  if (!val) return undefined;
  try { return new Date(val).toISOString(); } catch { return undefined; }
};

/**
 * Gym management.
 *
 * Reuses the exact markup, data sources and endpoints `GymDetail` already
 * renders for members, schedule posts and reviews — same avatars, badges,
 * review cards and `gymsApi` calls — and adds the two surfaces an owner needs
 * that `GymDetail` has no affordance for: approving join requests and sending
 * invites. The existing "Manage" button in `GymDetail` pointed here at a route
 * that did not exist, which sent owners into their own profile.
 */
export default function GymManage() {
  const { slug } = useParams();
  const navigate = useNavigate();

  const [gym, setGym] = useState<Gym | null>(null);
  const [members, setMembers] = useState<GymMembership[]>([]);
  const [requests, setRequests] = useState<JoinRequest[]>([]);
  const [schedulePosts, setSchedulePosts] = useState<GymSchedulePost[]>([]);
  const [reviews, setReviews] = useState<GymReview[]>([]);

  const [tab, setTab] = useState<Tab>('members');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const [inviteOpen, setInviteOpen] = useState(false);
  const [inviteTarget, setInviteTarget] = useState('');
  const [inviteBusy, setInviteBusy] = useState(false);

  const [scheduleOpen, setScheduleOpen] = useState(false);
  const [scheduleTitle, setScheduleTitle] = useState('');
  const [scheduleContent, setScheduleContent] = useState('');
  const [scheduleActivity, setScheduleActivity] = useState('other');
  const [scheduleStart, setScheduleStart] = useState('');
  const [scheduleEnd, setScheduleEnd] = useState('');
  const [scheduleBusy, setScheduleBusy] = useState(false);

  const [replyTo, setReplyTo] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');
  const [replyBusy, setReplyBusy] = useState(false);

  const load = useCallback(async () => {
    if (!slug) return;
    setLoading(true);
    setError(null);
    try {
      const detail = await gymsApi.detail(slug);
      setGym(detail.data);
      // Each panel degrades on its own — a missing join-requests endpoint must
      // not blank the member list.
      const [membersRes, requestsRes, postsRes, reviewsRes] = await Promise.all([
        gymsApi.getMembers(slug).catch(() => ({ data: [] as GymMembership[] })),
        gymsApi.getJoinRequests(slug, 'pending').catch(() => ({ data: [] as JoinRequest[] })),
        gymsApi.getSchedulePosts(slug).catch(() => ({ data: [] as GymSchedulePost[] })),
        gymsApi.getReviews(slug).catch(() => ({ data: [] as GymReview[] })),
      ]);
      setMembers(membersRes.data || []);
      setRequests(requestsRes.data || []);
      setSchedulePosts(postsRes.data || []);
      setReviews(reviewsRes.data || []);
    } catch (e: any) {
      setError(e?.response?.data?.message || "Could not load this gym.");
    } finally {
      setLoading(false);
    }
  }, [slug]);

  useEffect(() => { load(); }, [load]);

  const decideRequest = async (request: JoinRequest, decision: 'approved' | 'rejected') => {
    if (!slug || !request.id) return;
    setBusyId(request.id);
    setActionError(null);
    try {
      await gymsApi.manageJoinRequest(slug, request.id, decision);
      setRequests((prev) => prev.filter((r) => r.id !== request.id));
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not update that request.');
    } finally {
      setBusyId(null);
    }
  };

  const sendInvite = async () => {
    if (!slug || !inviteTarget.trim()) return;
    setInviteBusy(true);
    setActionError(null);
    try {
      const value = inviteTarget.trim();
      const payload = value.includes('@') ? { email: value } : { username: value };
      await gymsApi.invite(slug, payload);
      setInviteTarget('');
      setInviteOpen(false);
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not send that invite.');
    } finally {
      setInviteBusy(false);
    }
  };

  const postSchedule = async () => {
    if (!slug) return;
    setScheduleBusy(true);
    setActionError(null);
    try {
      const res = await gymsApi.createSchedulePost(slug, {
        title: scheduleTitle,
        content: scheduleContent,
        activity_type: scheduleActivity,
        location_mode: 'in_house',
        start_time: toISO(scheduleStart),
        end_time: toISO(scheduleEnd),
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      });
      setSchedulePosts((prev) => [res.data, ...prev]);
      setScheduleOpen(false);
      setScheduleTitle('');
      setScheduleContent('');
      setScheduleStart('');
      setScheduleEnd('');
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not post that update.');
    } finally {
      setScheduleBusy(false);
    }
  };

  const submitReply = async (reviewId: string) => {
    if (!slug || !replyText.trim()) return;
    setReplyBusy(true);
    setActionError(null);
    try {
      const res = await gymsApi.replyToReview(slug, reviewId, replyText.trim());
      setReviews((prev) => prev.map((r) => (r.id === reviewId ? res.data : r)));
      setReplyTo(null);
      setReplyText('');
    } catch (e: any) {
      setActionError(e?.response?.data?.message || 'Could not post that reply.');
    } finally {
      setReplyBusy(false);
    }
  };

  const isAdmin = gym?.membership_role === 'owner' || gym?.membership_role === 'co_owner' || gym?.membership_role === 'moderator';

  if (loading) {
    return (
      <RoleDashboardShell title="Manage gym" backTo={gym ? `/gyms/${gym.handle}` : '/gyms'}>
        <div className="space-y-3" role="status" aria-busy="true" aria-label="Loading">
          <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
          <Card className="h-20 animate-pulse bg-buddy-surface-raised" />
        </div>
      </RoleDashboardShell>
    );
  }

  if (error || !gym) {
    return (
      <RoleDashboardShell title="Manage gym" backTo="/gyms">
        <Card className="p-8 text-center">
          <p className="text-sm text-buddy-text-secondary">{error || 'Gym not found.'}</p>
        </Card>
      </RoleDashboardShell>
    );
  }

  return (
    <RoleDashboardShell
      title={gym.name}
      subtitle={`Manage @${gym.handle}`}
      onBack={() => navigate(`/gyms/${gym.handle}`)}
      actions={<Button size="sm" variant="outline" onClick={() => navigate(`/gyms/${gym.handle}`)}>View gym</Button>}
    >
      {!isAdmin && (
        <div className="bg-buddy-orange/10 border border-buddy-orange/20 text-buddy-orange text-xs rounded-xl px-3 py-2">
          You are not an owner or co-owner of this gym, so management actions are limited.
        </div>
      )}
      {actionError && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{actionError}</div>
      )}

      <div className="flex gap-1 bg-buddy-surface rounded-xl p-1 overflow-x-auto">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            aria-pressed={tab === t.key}
            className={`flex-1 min-w-[80px] py-2 px-1 text-xs font-semibold rounded-lg transition-colors ${tab === t.key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text'}`}
          >
            {t.label}
            {t.key === 'requests' && requests.length > 0 ? ` (${requests.length})` : ''}
          </button>
        ))}
      </div>

      {/* Members */}
      {tab === 'members' && (
        <section className="space-y-2">
          <RoleSectionTitle action={<Button size="sm" variant="outline" onClick={() => setInviteOpen(true)}><Send size={12} className="mr-1" /> Invite</Button>}>
            Members ({members.length})
          </RoleSectionTitle>
          {members.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-sm">No members yet.</Card>
          ) : (
            <div className="space-y-2">
              {members.map((m) => (
                <Card key={m.id} className="p-3 flex items-center gap-3" onClick={() => navigate(`/${m.member_data?.username}`)}>
                  <Avatar src={m.member_data?.avatar_url} alt={m.member_data?.display_name || 'Member'} size="sm" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{m.member_data?.display_name}</p>
                    <p className="text-xs text-buddy-text-secondary">@{m.member_data?.username}</p>
                  </div>
                  <Badge
                    variant={m.role === 'owner' ? 'gold' : m.role === 'trainer' ? 'green' : m.role === 'moderator' ? 'blue' : 'silver'}
                    label={m.role.replace('_', ' ')}
                    size="sm"
                  />
                </Card>
              ))}
            </div>
          )}
        </section>
      )}

      {/* Join requests */}
      {tab === 'requests' && (
        <section className="space-y-2">
          <RoleSectionTitle>Join requests ({requests.length})</RoleSectionTitle>
          {requests.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-sm">No pending join requests.</Card>
          ) : (
            <div className="space-y-2">
              {requests.map((r) => (
                <Card key={r.id} className="p-4 space-y-2">
                  <div className="flex items-center gap-3">
                    <Avatar src={r.requester_data?.avatar_url} alt={r.requester_data?.display_name || 'Requester'} size="sm" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{r.requester_data?.display_name}</p>
                      <p className="text-xs text-buddy-text-secondary">@{r.requester_data?.username} · {new Date(r.created_at).toLocaleDateString()}</p>
                    </div>
                  </div>
                  {r.message && <p className="text-xs text-buddy-text-secondary leading-relaxed">{r.message}</p>}
                  {isAdmin && (
                    <div className="flex gap-2 pt-1">
                      <Button size="sm" disabled={busyId === r.id} onClick={() => decideRequest(r, 'approved')}>
                        <Check size={14} className="mr-1" /> Approve
                      </Button>
                      <Button size="sm" variant="destructive" disabled={busyId === r.id} onClick={() => decideRequest(r, 'rejected')}>
                        <X size={14} className="mr-1" /> Reject
                      </Button>
                    </div>
                  )}
                </Card>
              ))}
            </div>
          )}
        </section>
      )}

      {/* Schedule posts */}
      {tab === 'schedule' && (
        <section className="space-y-2">
          <RoleSectionTitle action={isAdmin && <Button size="sm" onClick={() => setScheduleOpen(true)}><Plus size={12} className="mr-1" /> Post</Button>}>
            Schedule updates ({schedulePosts.length})
          </RoleSectionTitle>
          {schedulePosts.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-sm">No schedule updates posted yet.</Card>
          ) : (
            <div className="space-y-3">
              {schedulePosts.map((post) => (
                <Card key={post.id} className="p-4 space-y-3">
                  <div className="flex items-center gap-2">
                    <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name} size="sm" />
                    <div>
                      <p className="text-sm font-medium">{post.author_data?.display_name}</p>
                      <p className="text-xs text-buddy-text-secondary">@{post.author_data?.username} · {new Date(post.created_at).toLocaleDateString()}</p>
                    </div>
                  </div>
                  {post.title && <h3 className="font-semibold text-sm">{post.title}</h3>}
                  <div className="flex flex-wrap gap-2">
                    <Badge variant="blue" label={post.activity_type.replace('_', ' ')} />
                    {post.location_mode && <Badge variant="green" label={post.location_mode.replace('_', ' ')} />}
                    {post.start_time && (
                      <span className="text-xs text-buddy-text-secondary bg-buddy-surface rounded px-2 py-1 flex items-center">
                        <Calendar size={12} className="mr-1" /> {new Date(post.start_time).toLocaleString()}
                      </span>
                    )}
                  </div>
                  <p className="text-sm whitespace-pre-wrap leading-relaxed">{post.content}</p>
                </Card>
              ))}
            </div>
          )}
        </section>
      )}

      {/* Reviews */}
      {tab === 'reviews' && (
        <section className="space-y-2">
          <RoleSectionTitle>Reviews ({reviews.length})</RoleSectionTitle>
          {reviews.length === 0 ? (
            <Card className="p-8 text-center text-buddy-text-secondary text-sm">No reviews yet.</Card>
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
                      <Button size="sm" variant="ghost" onClick={() => setReplyTo(review.id)}>
                        <MessageCircle size={14} className="mr-1" /> Reply
                      </Button>
                    </div>
                  )}
                  {replyTo === review.id && (
                    <div className="mt-2 pt-2 border-t border-buddy-surface-raised space-y-2">
                      <textarea
                        value={replyText}
                        onChange={(e) => setReplyText(e.target.value)}
                        placeholder="Write your response..."
                        aria-label={`Reply to ${review.reviewer_data?.display_name || 'review'}`}
                        rows={3}
                        className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
                      />
                      <div className="flex gap-2">
                        <Button size="sm" disabled={!replyText.trim()} isLoading={replyBusy} onClick={() => submitReply(review.id)}>Post reply</Button>
                        <Button size="sm" variant="ghost" onClick={() => { setReplyTo(null); setReplyText(''); }}>Cancel</Button>
                      </div>
                    </div>
                  )}
                </Card>
              ))}
            </div>
          )}
        </section>
      )}

      {/* Invite modal */}
      <Modal isOpen={inviteOpen} onClose={() => setInviteOpen(false)} title="Invite members" size="sm">
        <div className="space-y-3">
          <p className="text-xs text-buddy-text-secondary">Search by username, or enter an email address.</p>
          <Input label="Username or email" placeholder="karen or karen@example.com" value={inviteTarget} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setInviteTarget(e.target.value)} />
          <div className="flex gap-2">
            <Button className="flex-1" disabled={!inviteTarget.trim()} isLoading={inviteBusy} onClick={sendInvite}><Users size={14} className="mr-1" /> Send invite</Button>
            <Button variant="ghost" onClick={() => setInviteOpen(false)}>Cancel</Button>
          </div>
        </div>
      </Modal>

      {/* Schedule post modal */}
      <Modal isOpen={scheduleOpen} onClose={() => setScheduleOpen(false)} title="Post schedule update" size="sm">
        <div className="space-y-3 max-h-[70vh] overflow-y-auto">
          <Input label="Title (optional)" placeholder="Morning HIIT block" value={scheduleTitle} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setScheduleTitle(e.target.value)} />
          <div className="space-y-1">
            <label htmlFor="gym-schedule-activity" className="block text-sm font-medium text-buddy-text-secondary">Activity type</label>
            <select
              id="gym-schedule-activity"
              value={scheduleActivity}
              onChange={(e) => setScheduleActivity(e.target.value)}
              className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green"
            >
              {['yoga', 'hiit', 'strength', 'cardio', 'live_stream', 'workshop', 'event', 'session', 'other'].map((a) => (
                <option key={a} value={a}>{a.replace('_', ' ')}</option>
              ))}
            </select>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Input label="Start" type="datetime-local" value={scheduleStart} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setScheduleStart(e.target.value)} />
            <Input label="End" type="datetime-local" value={scheduleEnd} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setScheduleEnd(e.target.value)} />
          </div>
          <textarea
            value={scheduleContent}
            onChange={(e) => setScheduleContent(e.target.value)}
            rows={3}
            placeholder="What's the schedule update?"
            aria-label="Schedule update content"
            className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl p-3 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
          />
          <div className="flex gap-2">
            <Button className="flex-1" isLoading={scheduleBusy} onClick={postSchedule}>Post</Button>
            <Button variant="ghost" onClick={() => setScheduleOpen(false)}>Cancel</Button>
          </div>
        </div>
      </Modal>
    </RoleDashboardShell>
  );
}