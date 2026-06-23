import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Users, Radio, Info, MessageCircle, Settings, LogOut, Shield, Star } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { gymsApi, livesApi } from '@/api';
import type { Gym, GymMembership } from '@/types';
import type { BuddyLive } from '@/types/live';

type GymTab = 'feed' | 'lives' | 'members' | 'about';

export default function GymDetail() {
  const { slug } = useParams();
  const navigate = useNavigate();
  const [gym, setGym] = useState<Gym | null>(null);
  const [members, setMembers] = useState<GymMembership[]>([]);
  const [schedule, setSchedule] = useState<BuddyLive[]>([]);
  const [activeTab, setActiveTab] = useState<GymTab>('feed');
  const [isLoading, setIsLoading] = useState(true);
  const [memberCount, setMemberCount] = useState(0);

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
        ]);
      })
      .then(([membersRes, scheduleRes]) => {
        setMembers(membersRes.data || []);
        setSchedule(scheduleRes.data || []);
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

  if (isLoading) return <div className="max-w-lg mx-auto p-4"><div className="animate-pulse space-y-4"><div className="bg-buddy-surface rounded-2xl h-48" /><div className="bg-buddy-surface rounded-2xl h-64" /></div></div>;
  if (!gym) return <div className="max-w-lg mx-auto p-4 text-center py-20"><p className="text-buddy-text-secondary">Gym not found</p></div>;

  const isOwner = gym.membership_role === 'owner' || gym.membership_role === 'co_owner';
  const isAdmin = isOwner || gym.membership_role === 'moderator';

  const tabs: { key: GymTab; label: string; icon: typeof Users }[] = [
    { key: 'feed', label: 'Feed', icon: MessageCircle },
    { key: 'lives', label: 'Lives', icon: Radio },
    { key: 'members', label: 'Members', icon: Users },
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
          <Button size="sm" variant="ghost"><Star size={14} /></Button>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-buddy-surface mb-4">
          {tabs.map(({ key, label, icon: Icon }) => (
            <button key={key} onClick={() => setActiveTab(key)}
              className={`flex-1 pb-3 text-xs font-medium flex items-center justify-center gap-1.5 ${
                activeTab === key ? 'text-buddy-green border-b-2 border-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            ><Icon size={14} /> {label}</button>
          ))}
        </div>

        {/* Feed tab */}
        {activeTab === 'feed' && (
          <div className="space-y-3">
            <button className="w-full bg-buddy-surface hover:bg-buddy-surface-raised rounded-xl p-4 text-left text-sm text-buddy-text-secondary">
              Share an update with the gym...
            </button>
            <div className="text-center py-12 text-buddy-text-secondary text-sm">No posts yet in this gym.</div>
          </div>
        )}

        {/* Lives tab */}
        {activeTab === 'lives' && (
          <div className="space-y-3">
            {schedule.length === 0 ? (
              <div className="text-center py-12 text-buddy-text-secondary text-sm">No scheduled lives. {isAdmin && 'Schedule one now!'}</div>
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
                  <Button size="sm" variant="outline">RSVP</Button>
                </Card>
              ))
            )}
          </div>
        )}

        {/* Members tab */}
        {activeTab === 'members' && (
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
        )}

        {/* About tab */}
        {activeTab === 'about' && (
          <div className="space-y-4">
            {gym.description && <Card className="p-4"><p className="text-sm">{gym.description}</p></Card>}
            <Card className="p-4 space-y-2">
              <p className="text-sm"><span className="text-buddy-text-secondary">Category:</span> {gym.category.replace('_', ' ')}</p>
              <p className="text-sm"><span className="text-buddy-text-secondary">Access:</span> {gym.access_type}</p>
              <p className="text-sm"><span className="text-buddy-text-secondary">Subscription:</span> {gym.subscription_type.replace('_', ' ')}</p>
            </Card>
            {gym.rules?.length > 0 && (
              <Card className="p-4">
                <h3 className="font-heading font-semibold text-sm mb-2">Gym Rules</h3>
                <ol className="list-decimal list-inside space-y-1">
                  {gym.rules.map((rule, i) => (
                    <li key={i} className="text-sm text-buddy-text-secondary">{rule}</li>
                  ))}
                </ol>
              </Card>
            )}
            {gym.tags?.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {gym.tags.map((tag) => (
                  <span key={tag} className="text-xs bg-buddy-surface px-3 py-1 rounded-full">{tag}</span>
                ))}
              </div>
            )}
            {gym.owner_data?.length > 0 && (
              <Card className="p-4">
                <h3 className="font-heading font-semibold text-sm mb-2">Owners</h3>
                {gym.owner_data.map((o) => (
                  <div key={o.user_id} className="flex items-center gap-2 mb-2">
                    <Avatar src={o.avatar_url} alt={o.display_name} size="sm" />
                    <div>
                      <p className="text-sm font-medium">{o.display_name}</p>
                      <p className="text-xs text-buddy-text-secondary">@{o.username} · {o.role}</p>
                    </div>
                  </div>
                ))}
              </Card>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
