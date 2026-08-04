import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Users, Dumbbell, Radio, TrendingUp, X, Hash, Ticket, Tag } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Card } from '@/components/ui/Card';
import { profilesApi } from '@/api';
import { gymsApi } from '@/api';
import { livesApi } from '@/api';
import type { DiscoverTrending } from '@/api/profiles';
import type { Profile } from '@/types';
import type { Gym } from '@/types';
import type { BuddyLive } from '@/types/live';

type DiscoverTab = 'people' | 'gyms' | 'lives';

export default function Discover() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<DiscoverTab>('people');
  const [query, setQuery] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const [trending, setTrending] = useState<DiscoverTrending | null>(null);

  const [people, setPeople] = useState<Profile[]>([]);
  const [gyms, setGyms] = useState<Gym[]>([]);
  const [lives, setLives] = useState<BuddyLive[]>([]);

  const tabs: { key: DiscoverTab; label: string; icon: typeof Users }[] = [
    { key: 'people', label: 'People', icon: Users },
    { key: 'gyms', label: 'Gyms', icon: Dumbbell },
    { key: 'lives', label: 'Trending Lives', icon: Radio },
  ];

  const doSearch = useCallback(async (q: string) => {
    setIsSearching(true);
    try {
      if (activeTab === 'people') {
        const res = await profilesApi.searchProfiles({ q, limit: 20 });
        setPeople(res.data);
      } else if (activeTab === 'gyms') {
        const res = await gymsApi.list({ q });
        setGyms(res.data);
      } else if (activeTab === 'lives') {
        const res = await livesApi.browse({ tab: 'live' });
        setLives((res.data || []).filter((l) =>
          l.title.toLowerCase().includes(q.toLowerCase()) ||
          l.host.display_name.toLowerCase().includes(q.toLowerCase()),
        ));
      }
    } catch {} finally {
      setIsSearching(false);
    }
  }, [activeTab]);

  useEffect(() => {
    if (query.length >= 2) {
      const timer = setTimeout(() => doSearch(query), 300);
      return () => clearTimeout(timer);
    }
  }, [query, doSearch]);

  useEffect(() => {
    if (query.length >= 2) return;
    profilesApi.getDiscoverTrending().then((res) => setTrending(res.data)).catch(() => {});
  }, [query.length]);

  useEffect(() => {
    if (query.length >= 2) return;
    if (activeTab === 'people') {
      setIsSearching(true);
      profilesApi.getRecommendations()
        .then((res) => setPeople((res.data || []).map((r) => r.profile)))
        .catch(() => setPeople([]))
        .finally(() => setIsSearching(false));
    } else if (activeTab === 'gyms') {
      setIsSearching(true);
      gymsApi.list({})
        .then((res) => setGyms(res.data || []))
        .catch(() => setGyms([]))
        .finally(() => setIsSearching(false));
    } else if (activeTab === 'lives') {
      livesApi.browse({ tab: 'live' }).then((res) => setLives(res.data || [])).catch(() => {});
    }
  }, [activeTab, query.length]);

  return (
    <div className="max-w-2xl lg:max-w-3xl xl:max-w-4xl mx-auto p-4 space-y-6">
      <h1 className="font-display text-2xl font-extrabold">Discover</h1>

      <div className="relative">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-buddy-text-secondary" />
        <input
          type="text"
          placeholder="Search users, trainers, gyms..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full bg-buddy-surface border border-transparent rounded-2xl pl-12 pr-12 py-3 text-buddy-text-primary placeholder:text-buddy-text-secondary/50 font-body transition-colors focus:outline-none focus:ring-2 focus:ring-buddy-green/30 focus:border-transparent"
        />
        {query.length > 0 && (
          <button
            onClick={() => setQuery('')}
            aria-label="Clear search"
            className="absolute right-3 top-1/2 -translate-y-1/2 w-6 h-6 flex items-center justify-center rounded-full bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {query.length < 2 && !isSearching && (
        <div className="flex items-center gap-2">
          <TrendingUp className="w-4 h-4 text-buddy-green" />
          <p className="text-sm font-medium text-buddy-text-primary">
            {activeTab === 'people' && 'Recommended for you'}
            {activeTab === 'gyms' && 'Browse gyms'}
            {activeTab === 'lives' && 'Trending live sessions'}
          </p>
        </div>
      )}

      <div className="flex gap-2">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`flex items-center gap-2 px-4 py-2 rounded-full font-medium text-sm transition-colors ${
                isActive
                  ? 'bg-buddy-green text-buddy-black'
                  : 'bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              <Icon className="w-4 h-4" />
              {tab.label}
            </button>
          );
        })}
      </div>

      {isSearching && (
        <div className="flex justify-center py-12">
          <div className="w-6 h-6 border-2 border-buddy-green border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {!isSearching && query.length < 2 && trending && (
        <div className="space-y-6">
          {trending.hashtags.length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Hash className="w-4 h-4 text-buddy-green" /> Trending Challenges
              </p>
              <div className="flex flex-wrap gap-2">
                {trending.hashtags.map((h) => (
                  <button key={h.tag} onClick={() => setQuery(`#${h.tag}`)}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-buddy-surface text-sm hover:bg-buddy-surface-raised transition-colors">
                    <span className="text-buddy-green font-medium">#{h.tag}</span>
                    <span className="text-xs text-buddy-text-secondary">{h.count}</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {trending.posts.length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <TrendingUp className="w-4 h-4 text-buddy-green" /> Trending Posts
              </p>
              <div className="space-y-2">
                {trending.posts.slice(0, 3).map((post) => (
                  <Card key={post.id} className="p-4">
                    <div className="flex items-center gap-3">
                      <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || ''} size="sm" />
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium truncate">{post.author_data?.display_name}</p>
                        {post.body && <p className="text-sm text-buddy-text-secondary line-clamp-2 mt-0.5">{post.body}</p>}
                        <p className="text-xs text-buddy-text-secondary/60 mt-1">
                          {Object.values(post.reaction_counts || {}).reduce((s, n) => s + (n as number), 0)} reactions
                        </p>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {trending.offers.length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Tag className="w-4 h-4 text-buddy-green" /> Trending Giveaways & Offers
              </p>
              <div className="space-y-2">
                {trending.offers.map((offer, i) => {
                  if (offer.type === 'discount_code') {
                    const d = offer.data;
                    const discount = d.discount_type === 'percentage' ? `${d.discount_pct}% off` : 'Discount';
                    return (
                      <Card key={`${offer.type}-${i}`} className="p-4 flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-buddy-gold/15 text-buddy-gold flex items-center justify-center shrink-0"><Ticket size={18} /></div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-semibold">{discount} <span className="text-buddy-gold font-mono">"{d.code}"</span></p>
                          {d.description && <p className="text-xs text-buddy-text-secondary truncate mt-0.5">{d.description}</p>}
                        </div>
                        <Button size="sm" variant="outline" onClick={() => navigate('/marketplace')}>Use offer</Button>
                      </Card>
                    );
                  }
                  const e = offer.data;
                  return (
                    <Card key={`${offer.type}-${i}`} className="p-4 flex items-center gap-3 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/marketplace/events/${e.id}`)}>
                      <div className="w-10 h-10 rounded-xl bg-buddy-green/15 text-buddy-green flex items-center justify-center shrink-0"><Ticket size={18} /></div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold truncate">{e.title}</p>
                        <p className="text-xs text-buddy-text-secondary mt-0.5">Free event · {new Date(e.start_datetime).toLocaleDateString()}</p>
                      </div>
                      <Button size="sm" variant="outline">View</Button>
                    </Card>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      )}

      {!isSearching && query.length < 2 && activeTab === 'people' && people.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <TrendingUp className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
          <p className="text-buddy-text-secondary">No recommended users right now. Try searching instead.</p>
        </div>
      )}

      {!isSearching && query.length < 2 && activeTab === 'gyms' && gyms.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <TrendingUp className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
          <p className="text-buddy-text-secondary">No gyms to browse right now. Try searching instead.</p>
        </div>
      )}

      {!isSearching && activeTab === 'people' && people.length > 0 && (
        <div className="space-y-3">
          {people.map((p) => (
            <Card key={p.user_id} className="p-4 flex items-center gap-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/${p.username}`)}>
              <Avatar src={p.avatar_url} alt={p.display_name} size="lg" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="font-heading font-semibold truncate">{p.display_name}</p>
                  {p.verification_status === 'trainer' && <Badge variant="green" label="Trainer" />}
                  {p.verification_status === 'practitioner' && <Badge variant="gold" label="Practitioner" />}
                  {p.verification_status === 'id' && <Badge variant="silver" label="Verified" />}
                </div>
                <p className="text-sm text-buddy-text-secondary">@{p.username}</p>
                {p.bio && <p className="text-sm text-buddy-text-secondary truncate mt-1">{p.bio}</p>}
                <div className="flex gap-4 mt-2 text-xs text-buddy-text-secondary">
                  <span>{p.buddy_count} buddies</span>
                  <span>{p.follower_count} followers</span>
                  {p.location_city && <span>{p.location_city}</span>}
                </div>
              </div>
              <Button variant="ghost" size="sm" onClick={(e) => { e.stopPropagation(); navigate(`/${p.username}`); }}>
                View
              </Button>
            </Card>
          ))}
        </div>
      )}

      {!isSearching && activeTab === 'gyms' && gyms.length > 0 && (
        <div className="space-y-3">
          {gyms.map((g) => (
            <Card key={g.id} className="p-4 flex items-center gap-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/gyms/${g.handle}`)}>
              <Avatar src={g.logo_url} alt={g.name} size="lg" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="font-heading font-semibold truncate">{g.name}</p>
                  {g.is_verified && <Badge variant="green" label="Verified" />}
                </div>
                <p className="text-sm text-buddy-text-secondary">@{g.handle}</p>
                {g.description && <p className="text-sm text-buddy-text-secondary truncate mt-1">{g.description}</p>}
                <div className="flex gap-4 mt-2 text-xs text-buddy-text-secondary">
                  <span>{g.member_count} members</span>
                  <span>{g.active_today} active today</span>
                  {g.location_city && <span>{g.location_city}</span>}
                </div>
              </div>
              <Button variant="ghost" size="sm" onClick={(e) => { e.stopPropagation(); navigate(`/gyms/${g.handle}`); }}>
                View
              </Button>
            </Card>
          ))}
        </div>
      )}

      {!isSearching && activeTab === 'lives' && (
        <div className="space-y-3">
          {lives.length === 0 && query.length < 2 && (
            <div className="bg-buddy-surface rounded-2xl p-8 text-center">
              <Radio className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
              <p className="text-buddy-text-secondary">No live sessions right now.</p>
            </div>
          )}
          {lives.length === 0 && query.length >= 2 && (
            <div className="bg-buddy-surface rounded-2xl p-8 text-center">
              <p className="text-buddy-text-secondary">No matching live sessions found.</p>
            </div>
          )}
          {lives.map((l) => (
            <Card key={l.id} className="p-4 flex items-center gap-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/live/${l.id}`)}>
              <Avatar src={l.host.avatar_url} alt={l.host.display_name} size="lg" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="font-heading font-semibold truncate">{l.title}</p>
                  {l.status === 'live' && (
                    <span className="flex items-center gap-1 text-xs text-buddy-red font-medium">
                      <span className="w-2 h-2 bg-buddy-red rounded-full animate-pulse" />
                      LIVE
                    </span>
                  )}
                </div>
                <p className="text-sm text-buddy-text-secondary">{l.host.display_name}</p>
                <div className="flex gap-4 mt-2 text-xs text-buddy-text-secondary">
                  <span>{l.viewer_peak} viewers</span>
                  <span className="capitalize">{l.live_type.replace(/_/g, ' ')}</span>
                  {l.category && <span>{l.category}</span>}
                </div>
              </div>
              <Button size="sm" onClick={(e) => { e.stopPropagation(); navigate(`/live/${l.id}`); }}>
                Join
              </Button>
            </Card>
          ))}
        </div>
      )}

      {!isSearching && query.length >= 2 && activeTab === 'people' && people.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <p className="text-buddy-text-secondary">No users found for "{query}".</p>
        </div>
      )}

      {!isSearching && query.length >= 2 && activeTab === 'gyms' && gyms.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <p className="text-buddy-text-secondary">No gyms found for "{query}".</p>
        </div>
      )}
    </div>
  );
}
