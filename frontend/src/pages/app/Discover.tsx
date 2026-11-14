import { useState, useEffect, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import {MessageCircle,Trophy,Utensils, Search, Users, Dumbbell, Radio, TrendingUp, X, Hash, Ticket, Tag, Handshake, UserCheck, LayoutGrid, User, MapPin, type LucideIcon } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Card } from '@/components/ui/Card';
import { useToast } from '@/components/ui/Toast';
import { InterestChips } from '@/components/profile/InterestChips';
import { GymCard } from '@/components/gym/GymCard';
import { profilesApi } from '@/api';
import { gymsApi } from '@/api';
import { livesApi } from '@/api';
import { track } from '@/lib/analytics';
import { rankByAffinity } from '@/lib/discoverRank';
import { useAuthStore } from '@/store/authStore';
import { PostCard } from '@/components/features/feed/PostCard';
import { CommentSheet } from '@/components/features/feed/CommentSheet';
import type { DiscoverTrending } from '@/api/profiles';
import type { Profile } from '@/types';
import type { Gym } from '@/types';
import type { BuddyLive } from '@/types/live';

type DiscoverTab = 'all' | 'people' | 'gyms' | 'lives' | 'topics' | 'communities';

/**
 * A suggestion the user can pick instead of typing.
 *
 * Each one does something real: it narrows the search, or it opens the
 * place where that thing lives. A tab that only says "browse gyms" gives
 * the user nothing to act on.
 */
interface Suggestion {
  label: string;
  /** Vector glyph so the row reads at a glance — an emoji does not inherit theme colour. */
  icon?: LucideIcon;
  onPick: () => void;
}

/** The roles a profile can hold — what someone can be found by. */
const ROLE_SUGGESTIONS = [
  { label: 'Trainers', role: 'trainer' },
  { label: 'Practitioners', role: 'practitioner' },
  { label: 'Distributors', role: 'distributor' },
];

/**
 * The categories a gym can have, for when the platform has none of its own.
 *
 * A tab with nothing to offer is the same as a tab that does not exist,
 * so there is always something to pick.
 */
const FALLBACK_GYM_CATEGORIES = [
  { name: 'fitness', display_name: 'Fitness' },
  { name: 'strength', display_name: 'Strength & weights' },
  { name: 'crossfit', display_name: 'CrossFit' },
  { name: 'yoga', display_name: 'Yoga & pilates' },
  { name: 'boxing', display_name: 'Boxing & martial arts' },
  { name: 'running', display_name: 'Running' },
  { name: 'swimming', display_name: 'Swimming' },
  { name: 'climbing', display_name: 'Climbing' },
];

/** Topics worth offering when nothing is trending yet. */
const FALLBACK_TOPICS = [
  'fitness', 'workout', 'running', 'gym', 'yoga', 'nutrition', 'marathon', 'recovery',
];

export default function Discover() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState<DiscoverTab>('all');
  const [query, setQuery] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const [trending, setTrending] = useState<DiscoverTrending | null>(null);
  const [buddyRequested, setBuddyRequested] = useState<Set<string>>(new Set());
  const [showAllPeople, setShowAllPeople] = useState(false);
  const [commentPostId, setCommentPostId] = useState<string | null>(null);
  // Narrowings the user can pick from the suggestions.
  const [roleFilter, setRoleFilter] = useState<string>('');
  const [gymCategory, setGymCategory] = useState<string>('');
  const [gymCity, setGymCity] = useState<string>('');
  // Where the user is, so "near me" means something to them.
  const [cityFilter, setCityFilter] = useState<string>('');
  const [gymCategories, setGymCategories] = useState<{ name: string; display_name: string }[]>([]);

  const handleBuddyUp = async (username: string) => {
    try {
      await profilesApi.sendBuddyRequest(username);
      setBuddyRequested((prev) => new Set(prev).add(username));
      toast('success', `Buddy request sent to @${username}`);
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      toast('error', data?.message || 'Could not send buddy request.');
    }
  };

  const [people, setPeople] = useState<Profile[]>([]);
  const [gyms, setGyms] = useState<Gym[]>([]);
  const [lives, setLives] = useState<BuddyLive[]>([]);
  // People arrive pre-ranked from the AI embeddings recommender; the other
  // tabs get a client-side interest-affinity blend over global order.
  const myPrefs = useAuthStore((s) => s.profile?.preferences);

  const tabs: { key: DiscoverTab; label: string; icon: typeof Users }[] = [
    { key: 'all', label: 'All', icon: LayoutGrid },
    { key: 'people', label: 'People', icon: Users },
    { key: 'gyms', label: 'Gyms', icon: Dumbbell },
    { key: 'lives', label: 'Lives', icon: Radio },
    { key: 'topics', label: 'Topics', icon: Hash },
    { key: 'communities', label: 'Communities', icon: MessageCircle },
  ];

  const doSearch = useCallback(async (q: string) => {
    setIsSearching(true);
    try {
      if (activeTab === 'people' || activeTab === 'all') {
        const res = await profilesApi.searchProfiles({
          q,
          limit: 20,
          ...(roleFilter ? { role: roleFilter } : {}),
          ...(cityFilter ? { location: cityFilter } : {}),
        });
        setPeople(res.data);
      }
      if (activeTab === 'gyms' || activeTab === 'all') {
        const res = await gymsApi.list({
          q,
          ...(gymCategory ? { category: gymCategory } : {}),
          ...(gymCity ? { city: gymCity } : {}),
        });
        setGyms(res.data);
      }
      if (activeTab === 'lives' || activeTab === 'all') {
        const res = await livesApi.browse({ tab: 'live' });
        setLives((res.data || []).filter((l) =>
          l.title.toLowerCase().includes(q.toLowerCase()) ||
          l.host.display_name.toLowerCase().includes(q.toLowerCase()),
        ));
      }
      // topics + communities filter client-side from trending (see filteredTopics/ filteredCommunities).
    } catch {} finally {
      setIsSearching(false);
    }
  }, [activeTab, roleFilter, cityFilter, gymCategory, gymCity]);

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

  // The gym categories, so the Gyms tab can suggest a real category.
  useEffect(() => {
    gymsApi.getCategories()
      .then((res) => setGymCategories(res.data || []))
      .catch(() => {});
  }, []);

  // The user's own city, so "near me" is a real place.
  useEffect(() => {
    const city = useAuthStore.getState().profile?.location_city;
    if (city) setCityFilter(city);
  }, []);

  useEffect(() => {
    track('discover.tab_view', { properties: { tab: activeTab } });
  }, [activeTab]);

  /**
   * What this tab suggests, when there is no query yet.
   *
   * Each suggestion narrows the list or opens the place the thing lives —
   * a tab should offer something specific, not just a heading.
   */
  const suggestions: Suggestion[] = useMemo(() => {
    const out: Suggestion[] = [];

    if (activeTab === 'people' || activeTab === 'all') {
      for (const r of ROLE_SUGGESTIONS) {
        out.push({
          label: r.label,
          icon: User,
          onPick: () => { setRoleFilter(r.role); setQuery(''); },
        });
      }
      if (cityFilter) {
        out.push({
          label: `Near ${cityFilter}`,
          icon: MapPin,
          onPick: () => { setCityFilter(cityFilter); setQuery(''); },
        });
      }
    }

    if (activeTab === 'gyms' || activeTab === 'all') {
      const categories = gymCategories.length ? gymCategories : FALLBACK_GYM_CATEGORIES;
      for (const c of categories.slice(0, 6)) {
        out.push({
          label: c.display_name || c.name,
          icon: Dumbbell,
          onPick: () => { setGymCategory(c.name); setQuery(''); },
        });
      }
      if (cityFilter) {
        out.push({
          label: `Gyms near ${cityFilter}`,
          icon: MapPin,
          onPick: () => { setGymCity(cityFilter); setQuery(''); },
        });
      }
    }

    if (activeTab === 'lives' || activeTab === 'all') {
      const liveNow = lives.filter((l) => l.status === 'live');
      if (liveNow.length > 0) {
        out.push({
          label: `Live now (${liveNow.length})`,
          icon: Radio,
          onPick: () => { setQuery(''); },
        });
      }
      const categories = Array.from(new Set(lives.map((l) => l.category).filter(Boolean)));
      for (const c of categories.slice(0, 4)) {
        out.push({
          label: c,
          icon: Radio,
          onPick: () => { setQuery(c); },
        });
      }
    }

    if (activeTab === 'topics' || activeTab === 'all') {
      const hashtags = trending?.hashtags ?? [];
      if (hashtags.length) {
        for (const h of hashtags.slice(0, 6)) {
          out.push({
            label: `#${h.tag}`,
            icon: Hash,
            onPick: () => { setQuery(`#${h.tag}`); },
          });
        }
      } else {
        for (const t of FALLBACK_TOPICS) {
          out.push({
            label: `#${t}`,
            icon: Hash,
            onPick: () => { setQuery(`#${t}`); },
          });
        }
      }
    }

    if (activeTab === 'communities' || activeTab === 'all') {
      for (const c of (trending?.communities ?? []).slice(0, 5)) {
        out.push({
          label: c.group_name,
          icon: Users,
          onPick: () => navigate(`/communities/${c.id}`),
        });
      }
    }

    // The All tab would otherwise list everything at once, which is no
    // better than no list at all.
    return activeTab === 'all' ? out.slice(0, 10) : out;
  }, [
    activeTab, cityFilter, gymCategories, lives, trending, navigate,
  ]);

  const filteredTopics = useMemo(() => {
    const tags = trending?.hashtags ?? [];
    const list = query.length < 2
      ? tags
      : tags.filter((h) => h.tag.toLowerCase().includes(query.replace(/^#/, '').toLowerCase()));
    return rankByAffinity(list, (h) => h.tag, myPrefs);
  }, [trending, query, myPrefs]);

  const filteredCommunities = useMemo(() => {
    const list = trending?.communities ?? [];
    const filtered = query.length < 2
      ? list
      : list.filter((c) => c.group_name.toLowerCase().includes(query.toLowerCase()));
    return rankByAffinity(filtered, (c) => c.group_name, myPrefs);
  }, [trending, query, myPrefs]);

  const rankedGyms = useMemo(
    () => rankByAffinity(gyms, (g) => `${g.name} ${g.category} ${(g.tags || []).join(' ')}`, myPrefs),
    [gyms, myPrefs],
  );

  const rankedLives = useMemo(
    () => rankByAffinity(lives, (l) => `${l.title} ${l.category || ''} ${l.host.display_name}`, myPrefs),
    [lives, myPrefs],
  );

  useEffect(() => {
    if (query.length >= 2) return;
    if (activeTab === 'people' || activeTab === 'all') {
      setIsSearching(true);
      if (roleFilter || cityFilter) {
        // A narrowing is in play — search within it rather than falling
        // back to the generic recommendations.
        profilesApi.searchProfiles({
          q: '',
          limit: 20,
          ...(roleFilter ? { role: roleFilter } : {}),
          ...(cityFilter ? { location: cityFilter } : {}),
        })
          .then((res) => setPeople(res.data || []))
          .catch(() => setPeople([]))
          .finally(() => setIsSearching(false));
      } else {
        profilesApi.getRecommendations()
          .then((res) => setPeople((res.data || []).map((r) => r.profile)))
          .catch(() => setPeople([]))
          .finally(() => setIsSearching(false));
      }
    }
    if (activeTab === 'gyms' || activeTab === 'all') {
      if (activeTab !== 'all') setIsSearching(true);
      gymsApi.list({
        ...(gymCategory ? { category: gymCategory } : {}),
        ...(gymCity ? { city: gymCity } : {}),
      })
        .then((res) => setGyms(res.data || []))
        .catch(() => setGyms([]))
        .finally(() => { if (activeTab !== 'all') setIsSearching(false); });
    }
    if (activeTab === 'lives' || activeTab === 'all') {
      livesApi.browse({ tab: 'live' }).then((res) => setLives(res.data || [])).catch(() => {});
    }
  }, [activeTab, query.length, roleFilter, cityFilter, gymCategory, gymCity]);

  /**
   * Switch tab.
   *
   * A narrowing only applies to the tab it came from — a role filter has
   * no meaning under Gyms — so it is cleared when the tab changes.
   */
  const switchTab = (tab: DiscoverTab) => {
    setActiveTab(tab);
    setRoleFilter('');
    setGymCategory('');
    setGymCity('');
    if (tab !== 'people' && tab !== 'all') setCityFilter('');
  };

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
            {activeTab === 'all' && 'For you today'}
            {activeTab === 'people' && (
              <>Recommended for you · <button onClick={() => navigate('/buddies/find')} className="text-buddy-green font-medium">Find nearby →</button></>
            )}
            {activeTab === 'gyms' && 'Browse gyms'}
            {activeTab === 'lives' && 'Trending live sessions'}
            {activeTab === 'topics' && 'Trending topics'}
            {activeTab === 'communities' && 'Active communities'}
          </p>
        </div>
      )}

      <div className="flex gap-1 overflow-x-auto pb-1 scrollbar-hide">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => switchTab(tab.key)}
              className={`flex items-center gap-2 px-3 py-1.5 rounded-full font-medium text-sm whitespace-nowrap transition-colors ${
                isActive
                  ? 'bg-buddy-green text-buddy-black'
                  : 'bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary hover:bg-buddy-surface/50'
              }`}
            >
              <Icon className="w-4 h-4" />
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* What this tab suggests — so a tap on a tab offers something to
          act on rather than only a heading. */}
      {query.length < 2 && !isSearching && suggestions.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary">
            {activeTab === 'all' ? 'Suggested for you' : `Suggested ${tabs.find((t) => t.key === activeTab)?.label.toLowerCase()}`}
          </p>
          <div className="flex flex-wrap gap-2">
            {suggestions.map((s) => (
              <button
                key={s.label}
                onClick={s.onPick}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-buddy-surface text-sm text-buddy-text-primary hover:bg-buddy-surface-raised hover:text-buddy-green transition-colors"
              >
                {s.icon && <s.icon size={13} strokeWidth={2} aria-hidden="true" />}
                {s.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* The narrowing in play, so it is never a silent filter. */}
      {(roleFilter || cityFilter || gymCategory || gymCity) && (
        <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
          <span>Filtered by</span>
          {[roleFilter, cityFilter, gymCategory, gymCity].filter(Boolean).map((f) => (
            <button
              key={f}
              onClick={() => {
                setRoleFilter('');
                setCityFilter('');
                setGymCategory('');
                setGymCity('');
              }}
              className="inline-flex items-center gap-1 px-2 py-1 rounded-full bg-buddy-green/15 text-buddy-green"
            >
              {f}
              <X size={11} />
            </button>
          ))}
        </div>
      )}

      {isSearching && (
        <div className="flex justify-center py-12">
          <div className="w-6 h-6 border-2 border-buddy-green border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* The mixed feed belongs to the All tab — the other tabs show their
          own content below. */}
      {!isSearching && query.length < 2 && activeTab === 'all' && trending && (
        <div className="space-y-6">
          {(trending.hashtags ?? []).length > 0 && (
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

          {(trending.posts ?? []).length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <TrendingUp className="w-4 h-4 text-buddy-green" /> Trending Posts
              </p>
              <div className="space-y-3">
                {trending.posts
                  .slice()
                  .sort((a, b) => {
                    const aScore = (a.reaction_counts ? Object.values(a.reaction_counts).reduce((s, v) => s + v, 0) : 0) + (a.comment_count || 0) + (a.repost_count || 0) + (a.save_count || 0);
                    const bScore = (b.reaction_counts ? Object.values(b.reaction_counts).reduce((s, v) => s + v, 0) : 0) + (b.comment_count || 0) + (b.repost_count || 0) + (b.save_count || 0);
                    return bScore - aScore;
                  })
                  .slice(0, 3).map((post) => (
                  <PostCard key={post.id} post={post} onComment={setCommentPostId} />
                ))}
              </div>
            </div>
          )}

          {(trending.discussions?.length ?? 0) > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <MessageCircle className="w-4 h-4 text-buddy-green" /> Hot Discussions
              </p>
              <div className="space-y-3">
                {trending.discussions!.slice(0, 3).map((post) => (
                  <PostCard key={post.id} post={post} onComment={setCommentPostId} />
                ))}
              </div>
            </div>
          )}

          {(trending.communities?.length ?? 0) > 0 && (
            <div className="space-y-4">
              <div className="flex items-center justify-between mb-2">
                <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary">
                  <Users className="w-4 h-4 text-buddy-green" /> Active Communities
                </p>
                <button onClick={() => setActiveTab('communities')} className="text-xs text-buddy-green font-medium">
                  See all
                </button>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {trending.communities!.map((c) => (
                  <Card key={c.id} className="p-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors group" onClick={() => navigate(`/communities/${c.id}`)}>
                    <div className="aspect-video rounded-xl bg-buddy-surface-raised overflow-hidden mb-3 relative group-hover:scale-95 transition-transform duration-200">
                      {c.cover_url ? (
                        <img src={c.cover_url} alt="" className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full bg-buddy-surface-raised flex items-center justify-center">
                          <span className="text-[12px] font-bold text-buddy-green">
                            {c.group_name.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      )}
                      <div className="absolute top-2 right-2 bg-buddy-black/60 backdrop-blur-sm px-2 py-1 rounded-md">
                        <span className="text-[10px] font-bold text-white">{c.member_count || 0} members</span>
                      </div>
                    </div>
                    <p className="font-semibold text-buddy-text-primary truncate">{c.group_name}</p>
                    {c.description && (
                      <p className="text-[12px] text-buddy-text-secondary line-clamp-2 mt-1">{c.description}</p>
                    )}
                    <div className="flex items-center gap-2 mt-2 pt-2 border-t border-buddy-border/50">
                      <span className="text-[10px] text-buddy-text-secondary/70">{c.role?.toUpperCase() || 'MEMBER'}</span>
                      <span className="ml-auto text-[10px] text-buddy-text-secondary/70">{c.post_count || 0} posts</span>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {(trending.challenges?.length ?? 0) > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Trophy className="w-4 h-4 text-buddy-gold" /> Challenges & Competitions
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {(trending.challenges as Array<Record<string, unknown>>).slice(0, 4).map((ev) => {
                  const id = String(ev.id ?? '');
                  const title = String(ev.title ?? 'Challenge');
                  const attendees = Number(ev.attendee_count ?? 0);
                  return (
                    <Card key={id} className="p-3 cursor-pointer hover:border-buddy-green/30 transition-colors"
                      onClick={() => navigate(`/marketplace/events/${id}`)}>
                      <p className="text-sm font-medium truncate">{title}</p>
                      <p className="text-xs text-buddy-text-secondary mt-0.5">{attendees} joined</p>
                    </Card>
                  );
                })}
              </div>
            </div>
          )}

          {(trending.lives?.length ?? 0) > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Radio className="w-4 h-4 text-buddy-red" /> Lives Now & Upcoming
              </p>
              <div className="flex flex-wrap gap-2">
                {trending.lives!.slice(0, 5).map((lv) => (
                  <button key={lv.id} onClick={() => navigate(`/live/${lv.id}`)}
                    className="px-3 py-1.5 rounded-full bg-buddy-surface text-sm hover:bg-buddy-surface-raised transition-colors max-w-[220px] truncate">
                    {lv.status === 'live' ? '🔴 ' : ''}{lv.title}
                  </button>
                ))}
              </div>
            </div>
          )}

          {(trending.meal_plans?.length ?? 0) > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Utensils className="w-4 h-4 text-buddy-green" /> Popular Meal Plans
              </p>
              <div className="flex flex-wrap gap-2">
                {(trending.meal_plans as Array<Record<string, unknown>>).slice(0, 5).map((mp) => {
                  const id = String(mp.id ?? '');
                  const title = String(mp.title ?? 'Meal plan');
                  return (
                    <button key={id} onClick={() => navigate(`/marketplace/meal-plans/${id}`)}
                      className="px-3 py-1.5 rounded-full bg-buddy-surface text-sm hover:bg-buddy-surface-raised transition-colors max-w-[240px] truncate">
                      {title}
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {(trending.offers ?? []).length > 0 && (
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

      {!isSearching && (activeTab === 'people' || (activeTab === 'all' && query.length >= 2)) && people.length > 0 && (
        <div className="space-y-3">
          {people.slice(0, showAllPeople ? people.length : 4).map((p) => {
            const requested = buddyRequested.has(p.username);
            const isBuddy = p.is_buddy || p.buddy_status === 'accepted';
            return (
              <Card key={p.user_id} className="p-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/${p.username}`)}>
                <div className="flex items-start gap-4">
                  <Avatar src={p.avatar_url} alt={p.display_name} size="lg" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="font-heading font-semibold truncate">{p.display_name}</p>
                      {p.verification_status === 'trainer' && <Badge variant="green" label="Trainer" />}
                      {p.verification_status === 'practitioner' && <Badge variant="gold" label="Practitioner" />}
                      {p.verification_status === 'id' && <Badge variant="silver" label="Verified" />}
                    </div>
                    <p className="text-sm text-buddy-text-secondary">@{p.username}</p>
                    {p.bio && <p className="text-sm text-buddy-text-secondary line-clamp-2 mt-1">{p.bio}</p>}
                    <div className="mt-2">
                      <InterestChips preferences={p.preferences} showLocation city={p.location_city} />
                    </div>
                    <div className="flex gap-4 mt-2 text-xs text-buddy-text-secondary">
                      <span>{p.buddy_count} buddies</span>
                      <span>{p.follower_count} followers</span>
                    </div>
                  </div>
                  <div className="flex flex-col gap-2 shrink-0" onClick={(e) => e.stopPropagation()}>
                    {isBuddy ? (
                      <Button variant="outline" size="sm" disabled>
                        <UserCheck size={14} className="mr-1" /> Buddies
                      </Button>
                    ) : (
                      <Button
                        variant={requested ? 'ghost' : 'outline'}
                        size="sm"
                        disabled={requested}
                        onClick={() => handleBuddyUp(p.username)}
                      >
                        <Handshake size={14} className="mr-1" /> {requested ? 'Requested' : 'Buddy Up'}
                      </Button>
                    )}
                    <Button variant="ghost" size="sm" onClick={() => navigate(`/${p.username}`)}>
                      View
                    </Button>
                  </div>
                </div>
              </Card>
            );
          })}
          {people.length > 4 && (
            <Button
              variant="outline"
              className="w-full"
              onClick={() => setShowAllPeople((v) => !v)}
            >
              {showAllPeople ? 'Show less' : `See more (${people.length - 4} more)`}
            </Button>
          )}
        </div>
      )}

      {!isSearching && (activeTab === 'gyms' || (activeTab === 'all' && query.length >= 2)) && rankedGyms.length > 0 && (
        <div className="space-y-3">
          {rankedGyms.map((g) => (
            <GymCard key={g.id} gym={g} onClick={() => navigate(`/gyms/${g.handle}`)} />
          ))}
        </div>
      )}

      {!isSearching && (activeTab === 'lives' || (activeTab === 'all' && query.length >= 2)) && (
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
          {rankedLives.map((l) => (
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

      {!isSearching && (activeTab === 'topics' || (activeTab === 'all' && query.length >= 2)) && (
        <div className="space-y-3">
          {filteredTopics.length === 0 && (
            <div className="bg-buddy-surface rounded-2xl p-8 text-center">
              <Hash className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
              <p className="text-buddy-text-secondary">
                {query.length >= 2 ? `No topics found for "${query}".` : 'No trending topics right now.'}
              </p>
            </div>
          )}
          {filteredTopics.length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Hash className="w-4 h-4 text-buddy-green" /> Trending Topics
              </p>
              <div className="flex flex-wrap gap-2">
                {filteredTopics.map((h) => (
                  <button key={h.tag} onClick={() => { track('discover.topic_click', { properties: { tag: h.tag } }); setQuery(`#${h.tag}`); }}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-buddy-surface text-sm hover:bg-buddy-surface-raised transition-colors">
                    <span className="text-buddy-green font-medium">#{h.tag}</span>
                    <span className="text-xs text-buddy-text-secondary">{h.count}</span>
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

            {!isSearching && (activeTab === 'communities' || (activeTab === 'all' && query.length >= 2)) && (
        <div className="space-y-3">
          {filteredCommunities.length === 0 && (
            <div className="bg-buddy-surface rounded-2xl p-8 text-center">
              <Users className="w-10 h-10 text-buddy-text-secondary mx-auto mb-3" />
              <p className="text-buddy-text-secondary">
                {query.length >= 2 ? `No communities found for "${query}".` : 'No active communities right now.'}
              </p>
            </div>
          )}
          {filteredCommunities.length > 0 && (
            <div>
              <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary mb-2">
                <Users className="w-4 h-4 text-buddy-green" /> Active Communities
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredCommunities.map((c) => (
                  <Card key={c.id} className="p-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors group" onClick={() => { track('discover.community_click', { object_id: c.id }); navigate(`/communities/${c.id}`); }}>
                    <div className="aspect-video rounded-xl bg-buddy-surface-raised overflow-hidden mb-3 relative group-hover:scale-95 transition-transform duration-200">
                      {c.cover_url ? (
                        <img src={c.cover_url} alt="" className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full bg-buddy-surface-raised flex items-center justify-center">
                          <span className="text-[16px] font-bold text-buddy-green">
                            {c.group_name.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      )}
                      <div className="absolute top-2 right-2 bg-buddy-black/60 backdrop-blur-sm px-2 py-1 rounded-md">
                        <span className="text-[10px] font-bold text-white">{c.member_count || 0} members</span>
                      </div>
                    </div>
                    <p className="font-semibold text-buddy-text-primary truncate">{c.group_name}</p>
                    {(c as any).description && (
                      <p className="text-[12px] text-buddy-text-secondary line-clamp-2 mt-1">{(c as any).description}</p>
                    )}
                    <div className="flex items-center gap-2 mt-2 pt-2 border-t border-buddy-border/50">
                      <span className="text-[10px] text-buddy-text-secondary/70">{(c as any).role?.toUpperCase() || (c as any).my_role?.toUpperCase() || 'MEMBER'}</span>
                      <span className="ml-auto text-[10px] text-buddy-text-secondary/70">{(c as any).post_count || 0} posts</span>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {!isSearching && query.length < 2 && activeTab === 'all' && (
        <div className="space-y-6">
          {people.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2">
                <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary">
                  <Users className="w-4 h-4 text-buddy-green" /> People for you
                </p>
                <button onClick={() => setActiveTab('people')} className="text-xs text-buddy-green font-medium">See all</button>
              </div>
              <div className="space-y-3">
                {people.slice(0, 2).map((p) => (
                  <Card key={p.user_id} className="p-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors" onClick={() => navigate(`/${p.username}`)}>
                    <div className="flex items-center gap-3">
                      <Avatar src={p.avatar_url} alt={p.display_name} size="lg" />
                      <div className="flex-1 min-w-0">
                        <p className="font-heading font-semibold truncate">{p.display_name}</p>
                        <p className="text-sm text-buddy-text-secondary">@{p.username} · {p.buddy_count} buddies</p>
                      </div>
                      <Button variant="ghost" size="sm" onClick={(e) => { e.stopPropagation(); navigate(`/${p.username}`); }}>View</Button>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}
          {rankedLives.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2">
                <p className="flex items-center gap-2 text-sm font-medium text-buddy-text-primary">
                  <Radio className="w-4 h-4 text-buddy-red" /> Live now
                </p>
                <button onClick={() => setActiveTab('lives')} className="text-xs text-buddy-green font-medium">See all</button>
              </div>
              <div className="flex flex-wrap gap-2">
                {rankedLives.slice(0, 5).map((lv) => (
                  <button key={lv.id} onClick={() => navigate(`/live/${lv.id}`)}
                    className="px-3 py-1.5 rounded-full bg-buddy-surface text-sm hover:bg-buddy-surface-raised transition-colors max-w-[220px] truncate">
                    {lv.status === 'live' ? '🔴 ' : ''}{lv.title}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* onComment is optional on PostCard and the handler ends in a silent
          `onComment?.()`, so without this the comment button on a trending post
          fires analytics and appears to do nothing. */}
      {commentPostId && (
        <CommentSheet
          postId={commentPostId}
          isOpen
          onClose={() => setCommentPostId(null)}
        />
      )}

      {!isSearching && query.length >= 2 && activeTab === 'people' && people.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <p className="text-buddy-text-secondary">No users found for "{query}".</p>
        </div>
      )}

      {!isSearching && query.length >= 2 && (activeTab === 'gyms' || activeTab === 'all') && gyms.length === 0 && (
        <div className="bg-buddy-surface rounded-2xl p-8 text-center">
          <p className="text-buddy-text-secondary">No gyms found for "{query}".</p>
        </div>
      )}
    </div>
  );
}
