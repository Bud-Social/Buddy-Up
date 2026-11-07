import { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import {
  Users, Shield, ShieldCheck, MoreHorizontal, Settings2, X,
  Copy,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { PostCard } from '@/components/features/feed/PostCard';
import { messagingApi, type Community, type CommunityPost } from '@/api/messaging';
import type { Post } from '@/types/post';

interface CommunityPostExtended extends CommunityPost {
  community_id?: string;
  community_name?: string;
  repost_count?: number;
  is_saved_by_me?: boolean;
  updated_at?: string;
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
    view_count: 0,
    reaction_counts: {},
    user_reaction: cp.is_liked ? 'like' : null,
    comment_count: cp.comment_count || 0,
    repost_count: cp.repost_count || 0,
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
    community_cover_url: null,
    community_slug: null,
    poll: null,
  } as unknown as Post;
}

export default function CommunityDetail() {
  const { communityId } = useParams<{ communityId: string }>();
  const [community, setCommunity] = useState<Community | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [tab, setTab] = useState<'feed' | 'members'>('feed');
  const [showSettings, setShowSettings] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [copyMsg, setCopyMsg] = useState('');
  const [editName, setEditName] = useState('');
  const [editDesc, setEditDesc] = useState('');
  const [editPublic, setEditPublic] = useState(false);
  const [editAvatar, setEditAvatar] = useState('');
  const [searchMember, setSearchMember] = useState('');

  const canManage = community?.membership_role === 'owner' || community?.membership_role === 'admin';
  const isOwner = community?.membership_role === 'owner';

  const filteredMembers = (community?.members ?? []).filter((m) => {
    const q = searchMember.toLowerCase();
    return m.display_name.toLowerCase().includes(q) || m.username.toLowerCase().includes(q);
  });

  const fetchAll = useCallback(() => {
    if (!communityId) return;
    messagingApi.getCommunity(communityId)
      .then(setCommunity)
      .catch(() => {});
    messagingApi.getCommunityPosts(communityId)
      .then((data) => {
        const communityPosts = Array.isArray(data) ? data : [];
        setPosts(communityPosts.map(mapCommunityPostToPost));
      })
      .catch(() => {});
  }, [communityId]);

  useEffect(() => {
    fetchAll();
    const done = setTimeout(() => setIsLoading(false), 400);
    return () => clearTimeout(done);
  }, [fetchAll]);

  const copyInvite = async () => {
    if (!community?.invite_code) return;
    try {
      await navigator.clipboard.writeText(community.invite_code);
      setCopyMsg('Copied!');
      setTimeout(() => setCopyMsg(''), 2000);
    } catch {
      alert('Unable to copy');
    }
  };

  const rotateInvite = async () => {
    if (!communityId) return;
    try {
      await messagingApi.rotateInviteCode(communityId);
      fetchAll();
    } catch {
      alert('Unable to rotate invite code');
    }
  };

  const removeMember = (userId: string) => {
    if (!communityId) return;
    if (!confirm('Are you sure you want to remove this member?')) return;
    messagingApi.removeCommunityMember(communityId, userId).then(fetchAll);
  };

  const setRole = (userId: string, role: 'member' | 'admin') => {
    if (!communityId) return;
    messagingApi.setCommunityRole(communityId, userId, role).then(fetchAll);
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

  return (
    <div className="min-h-screen bg-buddy-background">
      <nav className="border-buddy-border border-b pb-4">
        <div className="max-w-7xl mx-auto px-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {community?.cover_url ? (
              <img src={community.cover_url} alt="" className="w-24 h-10 rounded-t-xl object-cover" />
            ) : (
              <div className="w-24 h-10 rounded-t-xl bg-buddy-surface-raised flex items-center justify-center">
                <Users size={24} className="text-buddy-green" />
              </div>
            )}
            <div>
              <p className="font-display font-semibold truncate">{community?.group_name}</p>
              <p className="text-xs text-buddy-text-secondary">{community?.description || ''}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] text-buddy-text-secondary/70">{community?.member_count || 0} members</span>
          </div>
        </div>
      </nav>

      <main>
        <div className="max-w-7xl mx-auto p-4">
          {isLoading && <div className="min-h-[200px] flex items-center justify-center text-buddy-text-secondary">Loading community…</div>}

          {community && (
            <div className="space-y-6">
              {tab === 'members' && (
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="font-display font-semibold">Members ({community?.member_count || 0})</h2>
                    <button onClick={() => setTab('feed')} className="text-sm text-buddy-green hover:text-buddy-text-primary">Back to Posts</button>
                  </div>
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
                      {m.role === 'owner' && <Shield size={17} className="text-buddy-green shrink-0" />}
                      {m.role === 'admin' && <ShieldCheck size={17} className="text-buddy-green shrink-0" />}
                      {m.role === 'admin' && <span className="text-[11px] text-buddy-text-secondary">Member</span>}
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
                              <>
                                <button onClick={() => setRole(m.user_id, 'member')} className="block w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-buddy-surface-raised">
                                  Make admin
                                </button>
                              </>
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

              {tab === 'feed' && (
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="font-display font-semibold">Posts</h2>
                    {isOwner && (
                      <button onClick={() => setTab('members')} className="text-sm text-buddy-green hover:text-buddy-text-primary">Manage Members</button>
                    )}
                  </div>

                  {posts.length === 0 && (
                    <div className="bg-buddy-surface rounded-2xl p-8 text-center">
                      <Users className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
                      <p className="text-buddy-text-secondary">No posts yet. Create one above!</p>
                    </div>
                  )}

                  {posts.map((post) => (
                    <PostCard
                      key={post.id}
                      post={post}
                      onComment={() => {}}
                      onRemove={() => {}}
                      onRemoveAuthor={() => {}}
                    />
                  ))}
                </div>
              )}
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
                  <label className="flex-1 cursor-pointer text-sm text-buddy-green font-hover:text-buddy-green/90 hover:underline">
                    {editAvatar ? 'Change picture' : 'Add a community picture'}
                    <input
                      type="file"
                      accept="image/jpeg,image/png,image/webp,image/gif"
                      className="hidden"
                      disabled={false}
                      onChange={(e) => { const f = e.target.files?.[0]; if (f) setEditAvatar(URL.createObjectURL(f)); e.target.value = ''; }}
                    />
                  </label>
                </div>
                <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Name</label>
                <input value={editName} onChange={(e) => setEditName(e.target.value)} className="w-full px-3.5 py-2.5 rounded-xl bg-buddy-surface-raised border border-buddy-border text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3" />
                <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Description</label>
                <textarea value={editDesc} onChange={(e) => setEditDesc(e.target.value)} rows={3} className="w-full px-3.5 py-2.5 rounded-xl bg-buddy-surface-raised border border-buddy-border text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3 resize-none" />
                <label className="flex items-center gap-2 text-sm mb-4 cursor-pointer">
                  <input type="checkbox" checked={editPublic} onChange={(e) => setEditPublic(e.target.checked)} className="accent-buddy-green" />
                  Public community
                </label>
                <button onClick={saveSettings} className="w-full py-3 rounded-xl bg-buddy-green text-buddy-black font-semibold">Save Changes</button>
              </div>
            </div>
          )}

          {showInvite && community && (
            <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowInvite(false)}>
              <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5" onClick={(e) => e.stopPropagation()}>
                <div className="flex items-center justify-between mb-4">
                  <h2 className="font-display text-lg font-bold">Invite Members</h2>
                  <button onClick={() => setShowInvite(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
                </div>
                <p className="text-sm text-buddy-text-secondary mb-2">Share this invite code with friends:</p>
                <div className="flex items-center gap-3 bg-buddy-surface-raised rounded-xl px-4 py-3 mb-3">
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
      </main>
    </div>
  );
}
