import { FormEvent, useEffect, useMemo, useState } from 'react';
import {
  Loader2, Plus, Users, Globe, Lock, Link2, Unlink, Send, Check, Sparkles, Heart, MessageCircle,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';
import { gymInsightsApi, gymFeedApi, type GymLinkedCommunity, type GymDiscoverableCommunity, type GymCommunitiesPayload } from '@/api/gyms';
import { messagingApi, type CommunityPost } from '@/api/messaging';
import { CommentSheet } from '@/components/features/feed/CommentSheet';

interface CommunitiesTabProps {
  slug: string;
}

function timeAgo(iso: string | null) {
  if (!iso) return '';
  const s = Math.max(0, (Date.now() - new Date(iso).getTime()) / 1000);
  if (s < 60) return 'just now';
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  if (s < 7 * 86400) return `${Math.floor(s / 86400)}d ago`;
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

/**
 * Communities — the shared clubhouses a gym can form or join. Linking a
 * community makes it appear on the gym's page for members; creating one mints
 * a public community owned by the gym and records it as the primary link.
 */
export function CommunitiesTab({ slug }: CommunitiesTabProps) {
  const [payload, setPayload] = useState<GymCommunitiesPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const [createOpen, setCreateOpen] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [isPublic, setIsPublic] = useState(true);
  const [createBusy, setCreateBusy] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);

  const [activeId, setActiveId] = useState<string | null>(null);
  const [posts, setPosts] = useState<CommunityPost[] | null>(null);
  const [postsLoading, setPostsLoading] = useState(false);
  const [draft, setDraft] = useState('');
  const [postBusy, setPostBusy] = useState(false);
  const [gymLiked, setGymLiked] = useState<Set<string>>(new Set());
  const [commentTarget, setCommentTarget] = useState<{ postId: string; communityId: string } | null>(null);

  const load = () => {
    setLoading(true);
    setError(null);
    gymInsightsApi.communities(slug)
      .then((res) => setPayload(res.data ?? null))
      .catch((e: any) => setError(e?.response?.data?.message || 'Could not load communities.'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { if (slug) load(); /* eslint-disable-line react-hooks/exhaustive-deps */ }, [slug]);

  const linked = payload?.linked ?? [];
  const discoverable = payload?.discoverable ?? [];
  const active = useMemo(() => linked.find((c) => c.id === activeId) ?? null, [linked, activeId]);

  const loadPosts = (communityId: string) => {
    setPostsLoading(true);
    setPosts(null);
    messagingApi.getCommunityPosts(communityId)
      .then((rows) => setPosts(rows.slice(0, 15)))
      .catch(() => setPosts([]))
      .finally(() => setPostsLoading(false));
  };

  const toggleFeed = (communityId: string) => {
    if (activeId === communityId) {
      setActiveId(null);
      setPosts(null);
      return;
    }
    setActiveId(communityId);
    loadPosts(communityId);
  };

  const submitCreate = async (e: FormEvent) => {
    e.preventDefault();
    if (!name.trim()) { setCreateError('Give the community a name.'); return; }
    setCreateBusy(true);
    setCreateError(null);
    try {
      await gymInsightsApi.createCommunity(slug, { name: name.trim(), description: description.trim(), is_public: isPublic });
      setCreateOpen(false);
      setName(''); setDescription(''); setIsPublic(true);
      load();
    } catch (e: any) {
      setCreateError(e?.response?.data?.message || 'Could not create that community.');
    } finally {
      setCreateBusy(false);
    }
  };

  const linkCommunity = async (community: GymDiscoverableCommunity) => {
    setBusyId(community.id);
    setError(null);
    setNotice(null);
    try {
      await gymInsightsApi.linkCommunity(slug, community.id);
      setNotice(`Request sent to ${community.name} — their owner or an admin will review it. You'll be notified when they decide.`);
      load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not link that community.');
    } finally {
      setBusyId(null);
    }
  };

  const unlinkCommunity = async (community: GymLinkedCommunity) => {
    if (!window.confirm(`Unlink ${community.name}? The community itself stays — it just stops being attached to this gym.`)) return;
    setBusyId(community.id);
    setError(null);
    try {
      await gymInsightsApi.unlinkCommunity(slug, community.id);
      if (activeId === community.id) { setActiveId(null); setPosts(null); }
      load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not unlink that community.');
    } finally {
      setBusyId(null);
    }
  };

  const joinLeave = async (community: GymLinkedCommunity) => {
    setBusyId(community.id);
    setError(null);
    try {
      if (community.is_member) {
        await messagingApi.leaveCommunity(community.id);
      } else {
        await messagingApi.joinCommunity(community.id);
      }
      load();
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not update your membership.');
    } finally {
      setBusyId(null);
    }
  };

  const submitPost = async (e: FormEvent) => {
    e.preventDefault();
    if (!active || !draft.trim()) return;
    setPostBusy(true);
    setError(null);
    try {
      await messagingApi.createCommunityPost(active.id, { body: draft.trim() });
      setDraft('');
      loadPosts(active.id);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not post that.');
    } finally {
      setPostBusy(false);
    }
  };

  const handleGymLike = (post: CommunityPost) => {
    if (!active) return;
    gymFeedApi.reactCommunityPost(slug, active.id, post.id, 'like')
      .then((res) => {
        setGymLiked((prev) => {
          const next = new Set(prev);
          if (res?.is_reacted) next.add(post.id); else next.delete(post.id);
          return next;
        });
        if (typeof res?.like_count === 'number') {
          setPosts((prev) => prev?.map((p) => (p.id === post.id ? { ...p, like_count: res.like_count as number } : p)) ?? prev);
        }
      })
      .catch(() => {});
  };

  if (loading) {
    return (
      <div className="grid gap-3 animate-pulse">
        <div className="h-10 bg-buddy-surface rounded-2xl" />
        <div className="h-40 bg-buddy-surface rounded-2xl" />
        <div className="h-40 bg-buddy-surface rounded-2xl" />
      </div>
    );
  }

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <p className="text-[10px] uppercase text-buddy-text-secondary flex items-center gap-1.5"><Users size={12} /> Communities your gym can form or join</p>
        <Button size="sm" onClick={() => setCreateOpen(true)}><Plus size={14} className="mr-1" />New community</Button>
      </div>

      {notice && <p className="text-[11px] text-buddy-green bg-buddy-green/10 border border-buddy-green/20 rounded-lg px-2 py-1.5" role="status">{notice}</p>}
      {error && <p className="text-[11px] text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-2 py-1.5" role="alert">{error}</p>}

      {/* Linked communities */}
      {linked.length > 0 ? (
        <div className="space-y-2">
          {linked.map((community) => (
            <Card key={community.id} className="p-3">
              <div className="flex items-start gap-2.5">
                <Avatar src={community.avatar_url} alt={community.name} size="md" />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-1.5 flex-wrap">
                    <p className="text-xs font-bold truncate">{community.name}</p>
                    {community.status === 'pending' && <span className="text-[9px] uppercase font-bold text-buddy-gold bg-buddy-gold/10 border border-buddy-gold/20 rounded-full px-1.5 py-0.5">Pending approval</span>}
                    {community.is_gym_formed && <span className="text-[9px] uppercase font-bold text-buddy-green bg-buddy-green/10 border border-buddy-green/20 rounded-full px-1.5 py-0.5 flex items-center gap-0.5"><Sparkles size={9} />Gym-formed</span>}
                    {community.is_primary && community.status === 'active' && <span className="text-[9px] uppercase font-bold text-buddy-gold bg-buddy-gold/10 border border-buddy-gold/20 rounded-full px-1.5 py-0.5">Primary</span>}
                    <span className="text-[9px] uppercase font-semibold text-buddy-text-secondary bg-buddy-surface border border-buddy-surface-raised rounded-full px-1.5 py-0.5 flex items-center gap-0.5">{community.is_public ? <Globe size={9} /> : <Lock size={9} />}{community.is_public ? 'Public' : 'Private'}</span>
                  </div>
                  {community.description && <p className="text-[10px] text-buddy-text-secondary mt-0.5 line-clamp-2">{community.description}</p>}
                  <p className="text-[9px] text-buddy-text-secondary/80 mt-1 tabular-nums">{community.member_count} member{community.member_count === 1 ? '' : 's'}{typeof community.post_count === 'number' ? ` · ${community.post_count} posts` : ''}</p>
                  <div className="flex items-center gap-1.5 mt-2 flex-wrap">
                    <button onClick={() => toggleFeed(community.id)} className="px-2.5 py-1 rounded-lg text-[10px] font-semibold bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary transition-colors">
                      {activeId === community.id ? 'Hide feed' : 'View feed & post'}
                    </button>
                    {community.status !== 'pending' && (
                      <button
                        onClick={() => joinLeave(community)}
                        disabled={busyId === community.id}
                        className={`px-2.5 py-1 rounded-lg text-[10px] font-semibold transition-colors ${community.is_member ? 'bg-buddy-surface text-buddy-text-primary' : 'bg-buddy-green text-buddy-black'}`}
                      >
                        {busyId === community.id ? '…' : community.is_member ? 'Leave' : 'Join'}
                      </button>
                    )}
                    <button
                      onClick={() => unlinkCommunity(community)}
                      disabled={busyId === community.id}
                      aria-label={community.status === 'pending' ? 'Cancel request' : 'Unlink community'}
                      title={community.status === 'pending' ? 'Cancel request' : 'Unlink community'}
                      className="px-2 py-1 rounded-lg text-[10px] font-semibold text-buddy-red/80 hover:text-buddy-red hover:bg-buddy-red/10 transition-colors"
                    >
                      {busyId === community.id ? <Loader2 size={11} className="animate-spin" /> : <Unlink size={11} />}
                    </button>
                  </div>
                </div>
              </div>

              {/* Community feed + composer */}
              {activeId === community.id && (
                <div className="mt-3 border-t border-buddy-surface-raised pt-3">
                  <form onSubmit={submitPost} className="flex items-start gap-2">
                    <div className="flex-1 min-w-0">
                      <textarea
                        value={draft}
                        onChange={(e) => setDraft(e.target.value)}
                        placeholder={`Post to ${community.name}…`}
                        rows={2}
                        maxLength={1000}
                        className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40 resize-none"
                      />
                    </div>
                    <Button type="submit" size="sm" isLoading={postBusy} disabled={!draft.trim()} aria-label="Post to community"><Send size={12} /></Button>
                  </form>

                  {postsLoading ? (
                    <p className="text-[10px] text-buddy-text-secondary/70 py-3 text-center"><Loader2 size={12} className="animate-spin inline" /> Loading posts…</p>
                  ) : posts && posts.length > 0 ? (
                    <div className="mt-2 max-h-80 overflow-y-auto divide-y divide-buddy-surface-raised">
                      {posts.map((post) => (
                        <div key={post.id} className="py-2 flex items-start gap-2">
                          <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || post.author_data?.username || 'member'} size="xs" />
                          <div className="min-w-0 flex-1">
                            <div className="flex items-baseline gap-2">
                              <p className="text-[10px] font-semibold">{post.author_data?.display_name || post.author_data?.username}</p>
                              <p className="text-[9px] text-buddy-text-secondary/70">{timeAgo(post.created_at)}</p>
                            </div>
                            <p className="text-[11px] text-buddy-text-primary mt-0.5 whitespace-pre-wrap">{post.body}</p>
                            <div className="flex items-center gap-4 mt-1.5">
                              <button
                                onClick={() => handleGymLike(post)}
                                className={`flex items-center gap-1 text-[10px] transition-colors ${gymLiked.has(post.id) ? 'text-buddy-electric' : 'text-buddy-text-secondary hover:text-buddy-electric'}`}
                                aria-label="Like as gym"
                                title="Like as gym"
                              >
                                <Heart size={11} className={gymLiked.has(post.id) ? 'fill-buddy-electric' : ''} />
                                <span className="tabular-nums">{post.like_count}</span>
                              </button>
                              <button
                                onClick={() => setCommentTarget({ postId: post.id, communityId: community.id })}
                                className="flex items-center gap-1 text-[10px] text-buddy-text-secondary hover:text-buddy-green transition-colors"
                                aria-label="Comment as gym"
                                title="Comment as gym"
                              >
                                <MessageCircle size={11} />
                                <span className="tabular-nums">{post.comment_count}</span>
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-[10px] text-buddy-text-secondary/70 py-3 text-center">No posts yet — be the first to say something.</p>
                  )}
                </div>
              )}
            </Card>
          ))}
        </div>
      ) : (
        <Card className="p-6 text-center">
          <Users size={24} className="mx-auto text-buddy-text-secondary/40 mb-2" />
          <p className="text-xs font-semibold">No communities yet</p>
          <p className="text-[10px] text-buddy-text-secondary mt-1">Form your own with “New community”, or link one below — a local run club, a lifting cohort, anything your members belong to.</p>
        </Card>
      )}

      {/* Discover & link */}
      <div>
        <p className="text-[10px] uppercase text-buddy-text-secondary mb-1.5 flex items-center gap-1.5"><Link2 size={12} /> Discover &amp; link a community</p>
        {discoverable.length > 0 ? (
          <div className="grid md:grid-cols-2 gap-2">
            {discoverable.map((community) => (
              <Card key={community.id} className="p-3 flex items-start gap-2.5">
                <Avatar src={community.avatar_url} alt={community.name} size="md" />
                <div className="min-w-0 flex-1">
                  <p className="text-[11px] font-bold truncate">{community.name}</p>
                  {community.description && <p className="text-[10px] text-buddy-text-secondary mt-0.5 line-clamp-2">{community.description}</p>}
                  <p className="text-[9px] text-buddy-text-secondary/80 mt-1 tabular-nums">{community.member_count} members</p>
                  <button
                    onClick={() => linkCommunity(community)}
                    disabled={busyId === community.id}
                    className="mt-2 inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[10px] font-semibold bg-buddy-green text-buddy-black disabled:opacity-60"
                  >
                    {busyId === community.id ? <><Loader2 size={11} className="animate-spin" /> Linking…</> : <><Check size={11} /> Link to gym</>}
                  </button>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <p className="text-[10px] text-buddy-text-secondary/70">No public communities to discover right now.</p>
        )}
      </div>

      {/* Gym-identity comment sheet (like, reply, comment all land as the gym) */}
      {commentTarget && (
        <CommentSheet
          postId={commentTarget.postId}
          communityId={commentTarget.communityId}
          gymSlug={slug}
          gymName={slug}
          isOpen
          onClose={() => {
            setCommentTarget(null);
            if (activeId) loadPosts(activeId);
          }}
        />
      )}

      {/* Create modal */}
      <Modal isOpen={createOpen} onClose={() => setCreateOpen(false)} title="Create a gym community" size="sm">
        <form onSubmit={submitCreate} className="space-y-3">
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Community name — e.g. Saturday Runners"
            maxLength={100}
            className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40"
            autoFocus
          />
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="What's this community about?"
            rows={3}
            maxLength={500}
            className="w-full bg-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40 resize-none"
          />
          <label className="flex items-center justify-between gap-3 text-xs cursor-pointer">
            <span className="flex items-center gap-2">{isPublic ? <Globe size={12} /> : <Lock size={12} />} {isPublic ? 'Public — anyone can join' : 'Private — invite only'}</span>
            <input type="checkbox" className="accent-buddy-green" checked={isPublic} onChange={(e) => setIsPublic(e.target.checked)} aria-label="Public community" />
          </label>
          {createError && <p className="text-[11px] text-buddy-red" role="alert">{createError}</p>}
          <div className="flex items-center justify-end gap-2">
            <button type="button" onClick={() => setCreateOpen(false)} className="px-3 py-1.5 rounded-lg text-xs text-buddy-text-secondary hover:text-buddy-text-primary">Cancel</button>
            <Button type="submit" isLoading={createBusy} disabled={!name.trim()}>Create community</Button>
          </div>
        </form>
      </Modal>
    </section>
  );
}
