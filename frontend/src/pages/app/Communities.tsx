import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Users, Plus, Compass, Link2, X, Globe, Lock } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { messagingApi, type Community } from '@/api/messaging';

function CommunityCard({ community, onOpen }: { community: Community; onOpen: () => void }) {
  return (
    <Card className="p-4 cursor-pointer hover:border-buddy-green/40 transition-colors" onClick={onOpen}>
      <div className="flex items-center gap-3">
        {community.group_avatar_url || community.cover_url ? (
          <img
            src={community.group_avatar_url || community.cover_url}
            alt={community.group_name}
            className="w-14 h-14 rounded-xl object-cover"
          />
        ) : (
          <div className="w-14 h-14 rounded-xl bg-buddy-surface-raised flex items-center justify-center">
            <Users size={22} className="text-buddy-green" />
          </div>
        )}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2">
            <h3 className="font-display font-bold truncate">{community.group_name}</h3>
            {community.is_public ? (
              <Globe size={13} className="text-buddy-text-secondary shrink-0" />
            ) : (
              <Lock size={13} className="text-buddy-text-secondary shrink-0" />
            )}
          </div>
          {community.description && (
            <p className="text-xs text-buddy-text-secondary truncate mt-0.5">{community.description}</p>
          )}
          <div className="flex items-center gap-2 mt-1.5 text-[11px] text-buddy-text-secondary">
            <span>{community.member_count ?? community.participants_data.length} members</span>
            {community.membership_role && (
              <span className="px-1.5 py-0.5 rounded bg-buddy-green/10 text-buddy-green font-semibold capitalize">
                {community.membership_role}
              </span>
            )}
          </div>
        </div>
      </div>
    </Card>
  );
}

export default function Communities() {
  const navigate = useNavigate();
  const [mine, setMine] = useState<Community[]>([]);
  const [discover, setDiscover] = useState<Community[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [showJoin, setShowJoin] = useState(false);
  const [showDiscover, setShowDiscover] = useState(false);
  const [createName, setCreateName] = useState('');
  const [createDesc, setCreateDesc] = useState('');
  const [createPublic, setCreatePublic] = useState(true);
  const [createAvatarUrl, setCreateAvatarUrl] = useState('');
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const [inviteCode, setInviteCode] = useState('');
  const [busy, setBusy] = useState(false);

  const handleAvatarPicked = async (file: File | undefined) => {
    if (!file) return;
    setUploadingAvatar(true);
    try {
      const res = await messagingApi.uploadAttachment(file);
      setCreateAvatarUrl(res.data?.url ?? '');
    } catch {
      alert('Image upload failed');
    } finally {
      setUploadingAvatar(false);
    }
  };

  const fetchCommunities = useCallback(() => {
    messagingApi.getCommunities()
      .then((res) => {
        setMine(res.mine);
        setDiscover(res.discover);
      })
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  useEffect(() => { fetchCommunities(); }, [fetchCommunities]);

  const handleCreate = async () => {
    if (!createName.trim()) return alert('Enter a community name');
    setBusy(true);
    try {
      const community = await messagingApi.createCommunity({
        name: createName.trim(),
        description: createDesc.trim(),
        is_public: createPublic,
        ...(createAvatarUrl ? { group_avatar_url: createAvatarUrl } : {}),
      });
      setShowCreate(false);
      setCreateName('');
      setCreateDesc('');
      setCreateAvatarUrl('');
      navigate(`/communities/${community.id}`);
    } catch {
      alert('Failed to create community');
    } finally {
      setBusy(false);
    }
  };

  const handleJoin = async () => {
    if (!inviteCode.trim()) return alert('Enter an invite code');
    setBusy(true);
    try {
      const community = await messagingApi.joinCommunityByCode(inviteCode.trim());
      setShowJoin(false);
      setInviteCode('');
      navigate(`/communities/${community.id}`);
    } catch {
      alert('Invalid invite code');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface transition-colors">
            <ArrowLeft size={20} />
          </button>
          <h1 className="font-display text-2xl font-extrabold">Communities</h1>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => { setShowDiscover(true); fetchCommunities(); }}
            className="p-2 rounded-full hover:bg-buddy-surface transition-colors text-buddy-green"
            title="Explore communities"
          >
            <Compass size={20} />
          </button>
          <button
            onClick={() => setShowJoin(true)}
            className="p-2 rounded-full hover:bg-buddy-surface transition-colors text-buddy-green"
            title="Join by invite code"
          >
            <Link2 size={20} />
          </button>
          <button
            onClick={() => setShowCreate(true)}
            className="p-2 rounded-full hover:bg-buddy-surface transition-colors text-buddy-green"
            title="Create community"
          >
            <Plus size={20} />
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-14 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : (
        <div className="space-y-3">
          <h2 className="text-sm font-semibold text-buddy-text-secondary uppercase tracking-wider">My Communities</h2>
          {mine.length === 0 ? (
            <Card className="p-6 flex flex-col items-center justify-center py-14 text-buddy-text-secondary">
              <Users size={44} className="mb-3 opacity-30" />
              <p className="font-medium mb-1">No communities yet</p>
              <p className="text-sm mb-4">Create one or join with an invite code</p>
              <button onClick={() => setShowCreate(true)} className="text-buddy-green text-sm font-medium hover:underline">
                Create a community
              </button>
            </Card>
          ) : (
            mine.map((c) => (
              <CommunityCard key={c.id} community={c} onOpen={() => navigate(`/communities/${c.id}`)} />
            ))
          )}

          {discover.length > 0 && (
            <>
              <h2 className="text-sm font-semibold text-buddy-text-secondary uppercase tracking-wider pt-4">
                Discover
              </h2>
              {discover.map((c) => (
                <CommunityCard key={c.id} community={c} onOpen={() => navigate(`/communities/${c.id}`)} />
              ))}
            </>
          )}
        </div>
      )}

      {showDiscover && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowDiscover(false)}>
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5 max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display text-lg font-bold">Explore Communities</h2>
              <button onClick={() => setShowDiscover(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
            </div>
            {discover.length === 0 ? (
              <p className="text-sm text-buddy-text-secondary py-8 text-center">No public communities to explore yet.</p>
            ) : (
              <div className="space-y-2">
                {discover.map((c) => (
                  <Card
                    key={c.id}
                    className="p-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
                    onClick={() => { setShowDiscover(false); navigate(`/communities/${c.id}`); }}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3 min-w-0">
                        {c.group_avatar_url || c.cover_url ? (
                          <img
                            src={c.group_avatar_url || c.cover_url}
                            alt={c.group_name}
                            className="w-10 h-10 rounded-lg object-cover shrink-0"
                          />
                        ) : (
                          <div className="w-10 h-10 rounded-lg bg-buddy-surface-raised flex items-center justify-center shrink-0">
                            <Users size={18} className="text-buddy-green" />
                          </div>
                        )}
                        <div className="min-w-0">
                          <p className="font-semibold truncate">{c.group_name}</p>
                          <p className="text-xs text-buddy-text-secondary truncate">
                            {c.member_count ?? c.participants_data.length} members
                            {c.description ? ` · ${c.description}` : ''}
                          </p>
                        </div>
                      </div>
                      <button
                        onClick={(e) => { e.stopPropagation(); messagingApi.joinCommunity(c.id).then(() => { setShowDiscover(false); navigate(`/communities/${c.id}`); }); }}
                        className="text-xs font-semibold text-buddy-green bg-buddy-green/10 px-3 py-1.5 rounded-full hover:bg-buddy-green/20 transition-colors"
                      >
                        Join
                      </button>
                    </div>
                  </Card>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {showJoin && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowJoin(false)}>
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display text-lg font-bold">Join by Invite Code</h2>
              <button onClick={() => setShowJoin(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
            </div>
            <input
              value={inviteCode}
              onChange={(e) => setInviteCode(e.target.value.toUpperCase())}
              placeholder="e.g. ABC12345"
              className="w-full px-3 py-2.5 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-4 font-mono tracking-widest"
            />
            <button
              onClick={handleJoin}
              disabled={busy || !inviteCode.trim()}
              className="w-full py-2.5 rounded-xl bg-buddy-green text-buddy-black font-semibold disabled:opacity-40"
            >
              {busy ? 'Joining…' : 'Join'}
            </button>
          </div>
        </div>
      )}

      {showCreate && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-4" onClick={() => setShowCreate(false)}>
          <div className="w-full max-w-md bg-buddy-surface rounded-2xl p-5" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display text-lg font-bold">Create Community</h2>
              <button onClick={() => setShowCreate(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
            </div>
            <div className="flex items-center gap-4 mb-4">
              {createAvatarUrl ? (
                <img src={createAvatarUrl} alt="" className="w-16 h-16 rounded-2xl object-cover shrink-0" />
              ) : (
                <div className="w-16 h-16 rounded-2xl bg-buddy-surface-raised flex items-center justify-center shrink-0">
                  <Users size={26} className="text-buddy-green" />
                </div>
              )}
              <label className="flex-1 cursor-pointer text-sm text-buddy-green font-medium hover:underline">
                {uploadingAvatar ? 'Uploading…' : createAvatarUrl ? 'Change picture' : 'Add a community picture'}
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
            <input
              value={createName}
              onChange={(e) => setCreateName(e.target.value)}
              placeholder="e.g. Barbell Club"
              className="w-full px-3 py-2.5 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3"
            />
            <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Description</label>
            <textarea
              value={createDesc}
              onChange={(e) => setCreateDesc(e.target.value)}
              placeholder="What is this community about?"
              rows={3}
              className="w-full px-3 py-2.5 rounded-xl bg-buddy-surface-raised text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/40 mb-3 resize-none"
            />
            <label className="flex items-center gap-2 text-sm mb-4 cursor-pointer">
              <input type="checkbox" checked={createPublic} onChange={(e) => setCreatePublic(e.target.checked)} className="accent-buddy-green" />
              Public community (anyone can discover and join)
            </label>
            <button
              onClick={handleCreate}
              disabled={busy || !createName.trim()}
              className="w-full py-2.5 rounded-xl bg-buddy-green text-buddy-black font-semibold disabled:opacity-40"
            >
              {busy ? 'Creating…' : 'Create'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}