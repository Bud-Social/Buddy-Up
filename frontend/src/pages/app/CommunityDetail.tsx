import { useState, useEffect, useCallback } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft, Users, MessageCircle, Heart, Pin, Copy,
  Shield, ShieldCheck, MoreHorizontal, Send, Settings2, X,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { PostComposer } from '@/components/features/feed/PostComposer';
import { messagingApi, type Community, type CommunityPost } from '@/api/messaging';
import { useAuthStore } from '@/store/authStore';

function timeAgo(iso: string): string {
  const seconds = Math.floor((Date.now() - new Date(iso).getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const mins = Math.floor(seconds / 60);
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d`;
  return new Date(iso).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function PostCard({
  post, community, canManage, onLike, onRefresh,
}: {
  post: CommunityPost;
  community: Community | null;
  canManage: boolean;
  onLike: () => void;
  onRefresh: () => void;
}) {
  const [showComments, setShowComments] = useState(false);
  const [commentText, setCommentText] = useState('');
  const [comments, setComments] = useState(post.comments ?? []);
  const [busy, setBusy] = useState(false);
  const currentUserId = useAuthStore((s) => s.profile?.user_id);
  const isAuthor = post.author_id === currentUserId;

  const loadComments = useCallback(() => {
    messagingApi.getPostComments(community?.id ?? '', post.id)
      .then(setComments)
      .catch(() => {});
  }, [community?.id, post.id]);

  useEffect(() => {
    if (showComments) loadComments();
  }, [showComments, loadComments]);

  const addComment = async () => {
    if (!commentText.trim()) return;
    setBusy(true);
    try {
      await messagingApi.addPostComment(community?.id ?? '', post.id, commentText.trim());
      setCommentText('');
      loadComments();
      onRefresh();
    } catch {
      alert('Failed to add comment');
    } finally {
      setBusy(false);
    }
  };

  const togglePin = async () => {
    try {
      await messagingApi.updateCommunityPost(community?.id ?? '', post.id, { is_pinned: !post.is_pinned });
      onRefresh();
    } catch { /* noop */ }
  };

  const deletePost = async () => {
    if (!confirm('Delete this post?')) return;
    try {
      await messagingApi.deleteCommunityPost(community?.id ?? '', post.id);
      onRefresh();
    } catch { /* noop */ }
  };

  return (
    <Card className="p-4">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2.5 min-w-0">
          {post.author_data.avatar_url ? (
            <img src={post.author_data.avatar_url} alt="" className="w-9 h-9 rounded-full object-cover" />
          ) : (
            <div className="w-9 h-9 rounded-full bg-buddy-surface-raised flex items-center justify-center">
              <Users size={16} className="text-buddy-green" />
            </div>
          )}
          <div className="min-w-0">
            <div className="flex items-center gap-1.5">
              <p className="font-semibold text-sm">{post.author_data.display_name}</p>
              {post.is_pinned && <Pin size={12} className="text-buddy-gold shrink-0" />}
            </div>
            <p className="text-xs text-buddy-text-secondary">@{post.author_data.username} · {timeAgo(post.created_at)}</p>
          </div>
        </div>
        {canManage && (
          <div className="relative group">
            <button className="p-1.5 rounded-full hover:bg-buddy-surface transition-colors text-buddy-text-secondary">
              <MoreHorizontal size={16} />
            </button>
            <div className="hidden group-hover:block absolute right-0 top-8 z-10 bg-buddy-surface rounded-xl shadow-2xl border border-buddy-surface-raised p-1.5 min-w-[140px]">
              <button onClick={togglePin} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-buddy-surface-raised">
                {post.is_pinned ? 'Unpin' : 'Pin'} post
              </button>
              <button onClick={deletePost} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs text-buddy-red hover:bg-buddy-surface-raised">
                Delete post
              </button>
            </div>
          </div>
        )}
      </div>

      {post.body && <p className="mt-3 text-sm whitespace-pre-wrap">{post.body}</p>}
      {post.media_url && (
        <img src={post.media_url} alt="" className="mt-3 rounded-xl w-full object-cover max-h-96" />
      )}

      <div className="flex items-center gap-4 mt-3 pt-3 border-t border-buddy-surface">
        <button onClick={onLike} className={`flex items-center gap-1.5 text-xs font-medium transition-colors ${post.is_liked ? 'text-buddy-red' : 'text-buddy-text-secondary hover:text-buddy-red'}`}>
          <Heart size={15} fill={post.is_liked ? 'currentColor' : 'none'} />
          {post.like_count}
        </button>
        <button onClick={() => setShowComments((s) => !s)} className="flex items-center gap-1.5 text-xs font-medium text-buddy-text-secondary hover:text-buddy-green transition-colors">
          <MessageCircle size={15} />
          {post.comment_count}
        </button>
        {isAuthor && <span className="text-[11px] text-buddy-text-secondary/60 ml-auto">You</span>}
      </div>

      {showComments && (
        <div className="mt-3 space-y-2.5">
          {comments.map((c) => (
            <div key={c.id} className="flex gap-2">
              <div className="min-w-0 flex-1 bg-buddy-surface rounded-xl px-3 py-2">
                <p className="text-xs font-semibold">{c.author_data.display_name}</p>
                <p className="text-sm">{c.body}</p>
              </div>
            </div>
          ))}
          <div className="flex items-center gap-2">
            <input
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') addComment(); }}
              placeholder="Write a comment…"
              className="flex-1 px-3 py-2 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40"
            />
            <button
              onClick={addComment}
              disabled={busy || !commentText.trim()}
              className="p-2 rounded-full bg-buddy-green text-buddy-black disabled:opacity-40"
            >
              <Send size={15} />
            </button>
          </div>
        </div>
      )}
    </Card>
  );
}

export default function CommunityDetail() {
  const { communityId } = useParams<{ communityId: string }>();
  const navigate = useNavigate();
  const [community, setCommunity] = useState<Community | null>(null);
  const [posts, setPosts] = useState<CommunityPost[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [tab, setTab] = useState<'feed' | 'members'>('feed');
  const [showSettings, setShowSettings] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [copyMsg, setCopyMsg] = useState('');
  const [editName, setEditName] = useState('');
  const [editDesc, setEditDesc] = useState('');
  const [editPublic, setEditPublic] = useState(false);
  const [editAvatar, setEditAvatar] = useState('');
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [isJoining, setIsJoining] = useState(false);
  const [searchMember, setSearchMember] = useState('');

  const filteredMembers = (community?.members ?? []).filter((m) => {
    const q = searchMember.toLowerCase();
    return m.display_name.toLowerCase().includes(q) || m.username.toLowerCase().includes(q);
  });

  const canManage = community?.membership_role === 'owner' || community?.membership_role === 'admin';
  const isOwner = community?.membership_role === 'owner';
  const isMember = !!community?.membership_role;

  const setRole = async (userId: string, role: 'admin' | 'member') => {
    if (!communityId) return;
    try {
      await messagingApi.setCommunityRole(communityId, userId, role);
      fetchAll();
    } catch { /* noop */ }
  };

  const removeMember = async (userId: string) => {
    if (!communityId) return;
    const member = (community?.members ?? []).find((m) => m.user_id === userId);
    if (!confirm(`Remove ${member?.display_name ?? 'this member'} from the community?`)) return;
    try {
      await messagingApi.removeCommunityMember(communityId, userId);
      fetchAll();
    } catch { /* noop */ }
  };

  const fetchAll = useCallback(() => {
    if (!communityId) return;
    messagingApi.getCommunity(communityId)
      .then(setCommunity)
      .catch(() => {});
    messagingApi.getCommunityPosts(communityId)
      .then(setPosts)
      .catch(() => {});
  }, [communityId]);

  useEffect(() => {
    fetchAll();
    const done = setTimeout(() => setIsLoading(false), 400);
    return () => clearTimeout(done);
  }, [fetchAll]);

  const handleJoin = async () => {
    if (!communityId) return;
    setIsJoining(true);
    try {
      await messagingApi.joinCommunity(communityId);
      fetchAll();
    } catch {
      alert('Unable to join');
    } finally {
      setIsJoining(false);
    }
  };

  const toggleLike = async (postId: string) => {
    if (!communityId) return;
    try {
      await messagingApi.togglePostLike(communityId, postId);
      setPosts((prev) => prev.map((p) => p.id === postId ? { ...p, is_liked: !p.is_liked, like_count: p.like_count + (p.is_liked ? -1 : 1) } : p));
    } catch { /* noop */ }
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
      alert('Failed to save');
    }
  };

  const handleAvatarPicked = async (file: File | undefined) => {
    if (!file) return;
    setUploadingAvatar(true);
    try {
      const res = await messagingApi.uploadAttachment(file);
      setEditAvatar(res.data?.url ?? '');
    } catch {
      alert('Image upload failed');
    } finally {
      setUploadingAvatar(false);
    }
  };

  const openSettings = () => {
    if (!community) return;
    setEditName(community.group_name);
    setEditDesc(community.description);
    setEditPublic(community.is_public);
    setEditAvatar(community.group_avatar_url || '');
    setShowSettings(true);
  };

  const copyInvite = () => {
    if (!community) return;
    navigator.clipboard.writeText(community.invite_code);
    setCopyMsg('Copied!');
    setTimeout(() => setCopyMsg(''), 1500);
  };

  const rotateInvite = async () => {
    if (!communityId) return;
    try {
      const res = await messagingApi.rotateInviteCode(communityId);
      setCommunity((c) => c ? { ...c, invite_code: res.invite_code } : c);
      setCopyMsg('New code generated');
      setTimeout(() => setCopyMsg(''), 2000);
    } catch { /* noop */ }
  };

  if (isLoading && !community) {
    return (
      <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
        <div className="h-48 rounded-2xl bg-buddy-surface animate-pulse mb-4" />
        <div className="space-y-3">{Array.from({ length: 3 }).map((_, i) => (
          <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
        ))}</div>
      </div>
    );
  }

  if (!community) {
    return (
      <div className="max-w-lg lg:max-w-2xl mx-auto p-4">
        <div className="flex flex-col items-center py-20 text-buddy-text-secondary">
          <Users size={48} className="mb-4 opacity-30" />
          <p className="text-lg font-medium mb-1">Community not found</p>
          <button onClick={() => navigate('/communities')} className="text-buddy-green text-sm font-medium hover:underline">Back to Communities</button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center gap-3 mb-4">
        <button onClick={() => navigate('/communities')} className="p-2 rounded-full hover:bg-buddy-surface transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="font-display text-xl font-extrabold truncate">{community.group_name}</h1>
        {isMember && (
          <button onClick={() => setShowInvite(true)} className="p-2 rounded-full hover:bg-buddy-surface transition-colors text-buddy-green ml-auto" title="Invite code">
            <Copy size={18} />
          </button>
        )}
        {canManage && (
          <button onClick={openSettings} className="p-2 rounded-full hover:bg-buddy-surface transition-colors text-buddy-green" title="Community settings">
            <Settings2 size={19} />
          </button>
        )}
      </div>

      <Card className="overflow-hidden mb-4">
        {community.cover_url ? (
          <img src={community.cover_url} alt="" className="h-40 w-full object-cover" />
        ) : (
          <div className="h-40 w-full bg-gradient-to-br from-buddy-green/20 to-buddy-surface-raised flex items-center justify-center">
            <Users size={48} className="text-buddy-green/60" />
          </div>
        )}
        <div className="p-4">
          <div className="flex items-center gap-3 mb-1">
            {community.group_avatar_url ? (
              <img src={community.group_avatar_url} alt={community.group_name} className="w-12 h-12 rounded-xl object-cover shrink-0" />
            ) : (
              <div className="w-12 h-12 rounded-xl bg-buddy-surface-raised flex items-center justify-center shrink-0">
                <Users size={20} className="text-buddy-green" />
              </div>
            )}
            <span className="font-display text-lg font-bold truncate">{community.group_name}</span>
            <span className="text-[11px] text-buddy-text-secondary shrink-0">{community.is_public ? 'Public' : 'Private'}</span>
          </div>
          {community.description && <p className="text-sm text-buddy-text-secondary mb-2">{community.description}</p>}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3 text-xs text-buddy-text-secondary">
              <span className="flex items-center gap-1"><Users size={13} /> {community.member_count ?? community.participants_data.length} members</span>
              {community.membership_role && (
                <span className="px-2 py-0.5 rounded-full bg-buddy-green/10 text-buddy-green font-semibold capitalize">{community.membership_role}</span>
              )}
            </div>
            {!isMember && (
              <button
                onClick={handleJoin}
                disabled={isJoining}
                className="px-4 py-2 rounded-xl bg-buddy-green text-buddy-black text-sm font-semibold disabled:opacity-40"
              >
                {isJoining ? 'Joining…' : 'Join Community'}
              </button>
            )}
          </div>
        </div>
      </Card>

      <div className="flex items-center gap-1 mb-4 bg-buddy-surface rounded-xl p-1">
        <button
          onClick={() => setTab('feed')}
          className={`flex-1 py-2 rounded-lg text-sm font-semibold transition-colors ${tab === 'feed' ? 'bg-buddy-surface-raised text-buddy-green' : 'text-buddy-text-secondary'}`}
        >
          Feed
        </button>
        <button
          onClick={() => setTab('members')}
          className={`flex-1 py-2 rounded-lg text-sm font-semibold transition-colors ${tab === 'members' ? 'bg-buddy-surface-raised text-buddy-green' : 'text-buddy-text-secondary'}`}
        >
          Members
        </button>
      </div>

      {tab === 'feed' && (
        <>
          {isMember && (
            <div className="mb-4">
              <PostComposer
                placeholder="Share your workout, question, or update with the community..."
                onPost={() => fetchAll()}
              />
            </div>
          )}
          <div className="space-y-3">
            {posts.length === 0 ? (
              <Card className="p-6 text-center text-buddy-text-secondary py-14">
                <MessageCircle size={40} className="mx-auto mb-3 opacity-30" />
                <p className="font-medium mb-1">No posts yet</p>
                {isMember && <p className="text-sm">Be the first to share something</p>}
              </Card>
            ) : (
              posts.map((post) => (
                <PostCard
                  key={post.id}
                  post={post}
                  community={community}
                  canManage={canManage}
                  onLike={() => toggleLike(post.id)}
                  onRefresh={fetchAll}
                />
              ))
            )}
          </div>
        </>
      )}

      {tab === 'members' && (
        <div className="space-y-3">
          <input
            type="text"
            placeholder="Search members…"
            value={searchMember}
            onChange={(e) => setSearchMember(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl bg-buddy-surface-raised border border-buddy-border text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40"
          />
          {filteredMembers.map((m) => (
            <Card key={m.user_id} className="p-3 flex items-center gap-3">
              {m.avatar_url ? (
                <img src={m.avatar_url} alt="" className="w-10 h-10 rounded-full object-cover" />
              ) : (
                <div className="w-10 h-10 rounded-full bg-buddy-surface-raised flex items-center justify-center">
                  <Users size={18} className="text-buddy-green" />
                </div>
              )}
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-sm truncate">{m.display_name}</p>
                <p className="text-xs text-buddy-text-secondary truncate">@{m.username}</p>
              </div>
              {m.role === 'owner' && <Shield size={17} className="text-buddy-gold shrink-0" />}
              {m.role === 'admin' && <ShieldCheck size={17} className="text-buddy-green shrink-0" />}
              {m.role === 'member' && <span className="text-[11px] text-buddy-text-secondary">Member</span>}
              {isOwner && m.role !== 'owner' && (
                <div className="relative group shrink-0">
                  <button className="p-1.5 rounded-full hover:bg-buddy-surface transition-colors text-buddy-text-secondary">
                    <MoreHorizontal size={16} />
                  </button>
                  <div className="hidden group-hover:block absolute right-0 top-8 z-10 bg-buddy-surface rounded-xl shadow-2xl border border-buddy-surface-raised p-1.5 min-w-[160px]">
                    {m.role === 'admin' ? (
                      <>
                        <button onClick={() => setRole(m.user_id, 'member')} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-buddy-surface-raised">
                          Demote to member
                        </button>
                        <button onClick={() => messagingApi.transferCommunityOwnership(community?.id ?? '', m.user_id).then(fetchAll)} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-buddy-surface-raised">
                          Transfer ownership
                        </button>
                      </>
                    ) : (
                      <button onClick={() => setRole(m.user_id, 'admin')} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-buddy-surface-raised">
                        Make admin
                      </button>
                    )}
                    <button onClick={() => removeMember(m.user_id)} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs text-buddy-red hover:bg-buddy-surface-raised">
                      Remove member
                    </button>
                  </div>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}

      {showSettings && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowSettings(false)}>
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display text-lg font-bold">Community Settings</h2>
              <button onClick={() => setShowSettings(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><Settings2 size={20} /></button>
            </div>
            <div className="flex items-center gap-4 mb-4">
              {editAvatar ? (
                <img src={editAvatar} alt="" className="w-16 h-16 rounded-2xl object-cover shrink-0" />
              ) : (
                <div className="w-16 h-16 rounded-2xl bg-buddy-surface-raised flex items-center justify-center shrink-0">
                  <Users size={26} className="text-buddy-green" />
                </div>
              )}
              <label className="flex-1 cursor-pointer text-sm text-buddy-green font-medium hover:underline">
                {uploadingAvatar ? 'Uploading…' : editAvatar ? 'Change picture' : 'Add a community picture'}
                <input
                  type="file"
                  accept="image/jpeg,image/png,image/webp,image/gif"
                  className="hidden"
                  disabled={uploadingAvatar}
                  onChange={(e) => { handleAvatarPicked(e.target.files?.[0]); e.target.value = ''; }}
                />
              </label>
            </div>
            <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Name</label>
            <input value={editName} onChange={(e) => setEditName(e.target.value)} className="w-full px-3 py-2.5 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3" />
            <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Description</label>
            <textarea value={editDesc} onChange={(e) => setEditDesc(e.target.value)} rows={3} className="w-full px-3 py-2.5 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3 resize-none" />
            <label className="flex items-center gap-2 text-sm mb-4 cursor-pointer">
              <input type="checkbox" checked={editPublic} onChange={(e) => setEditPublic(e.target.checked)} className="accent-buddy-green" />
              Public community
            </label>
            <button onClick={saveSettings} className="w-full py-2.5 rounded-xl bg-buddy-green text-buddy-black font-semibold">Save Changes</button>
          </div>
        </div>
      )}

      {showInvite && community && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowInvite(false)}>
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display text-lg font-bold">Invite Members</h2>
              <button onClick={() => setShowInvite(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X size={20} />
              </button>
            </div>
            <p className="text-sm text-buddy-text-secondary mb-2">Share this invite code with friends:</p>
            <div className="flex items-center gap-2 bg-buddy-surface-raised rounded-xl px-4 py-3 mb-3">
              <span className="flex-1 font-mono tracking-[0.3em] text-center font-bold">{community.invite_code}</span>
              <button onClick={copyInvite} className="text-buddy-green hover:text-buddy-green/80" title="Copy">
                <Copy size={18} />
              </button>
            </div>
            {copyMsg && <p className="text-xs text-buddy-green mb-3">{copyMsg}</p>}
            {canManage && (
              <button onClick={rotateInvite} className="w-full py-2.5 rounded-xl bg-buddy-surface-raised text-sm font-semibold hover:bg-buddy-surface transition-colors">
                Generate new code
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
}