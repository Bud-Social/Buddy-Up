import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Search, UserPlus, Users } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { profilesApi } from '@/api';
import { useAuthStore } from '@/store/authStore';
import type { Profile } from '@/types';

export default function BuddiesPage() {
  const myProfile = useAuthStore((s) => s.profile);
  const navigate = useNavigate();
  const [buddies, setBuddies] = useState<Profile[]>([]);
  const [pendingProfiles, setPendingProfiles] = useState<Profile[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState<'buddies' | 'pending'>('buddies');

  useEffect(() => {
    if (!myProfile) return;
    setIsLoading(true);
    Promise.all([
      profilesApi.getBuddies(myProfile.username),
      profilesApi.getPendingRequests?.(),
    ]).then(([buddiesRes, pendingRes]) => {
      setBuddies(buddiesRes.data || []);
      if (pendingRes?.data) setPendingProfiles(pendingRes.data);
    }).catch(() => {}).finally(() => setIsLoading(false));
  }, [myProfile]);

  const filtered = tab === 'buddies'
    ? buddies.filter((b) => !search || b.display_name.toLowerCase().includes(search.toLowerCase()) || b.username.toLowerCase().includes(search.toLowerCase()))
    : pendingProfiles.filter((b) => !search || b.display_name.toLowerCase().includes(search.toLowerCase()));

  const handleAccept = async (username: string) => {
    await profilesApi.acceptBuddyRequest(username);
    setPendingProfiles((prev) => prev.filter((p) => p.username !== username));
    // Refresh buddies list
    if (myProfile) {
      const res = await profilesApi.getBuddies(myProfile.username);
      setBuddies(res.data || []);
    }
  };

  const handleDecline = async (username: string) => {
    await profilesApi.declineBuddyRequest(username);
    setPendingProfiles((prev) => prev.filter((p) => p.username !== username));
  };

  if (!myProfile) return null;

  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-2">Buddies</h1>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
        {[
          { key: 'buddies' as const, label: 'All Buddies', icon: Users },
          { key: 'pending' as const, label: 'Pending', icon: UserPlus },
        ].map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-1.5 ${
              tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            <Icon size={14} />
            {label}
          </button>
        ))}
      </div>

      <div className="relative mb-4">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder={`Search ${tab === 'buddies' ? 'buddies' : 'requests'}...`}
          className="w-full bg-buddy-surface border border-transparent rounded-xl pl-10 pr-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30"
        />
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i} className="p-3 animate-pulse"><div className="h-12 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-20">
          <Users size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary">
            {tab === 'buddies' ? 'No buddies yet' : 'No pending requests'}
          </p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">
            {tab === 'buddies' ? 'Find people with similar fitness goals and buddy up!' : 'New requests will appear here'}
          </p>
        </div>
      ) : (
        <div className="space-y-2">
          {filtered.map((p) => (
            <Card
              key={p.user_id}
              className="p-3 flex items-center gap-3 hover:bg-buddy-surface-raised cursor-pointer transition-colors"
              onClick={() => navigate(`/${p.username}`)}
            >
              <Avatar src={p.avatar_url} alt={p.display_name} size="md" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{p.display_name}</p>
                <p className="text-xs text-buddy-text-secondary">@{p.username}</p>
              </div>
              {tab === 'pending' && (
                <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                  <Button size="sm" onClick={(e) => { e.stopPropagation(); handleAccept(p.username); }}>
                    Accept
                  </Button>
                  <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); handleDecline(p.username); }}>
                    Decline
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
