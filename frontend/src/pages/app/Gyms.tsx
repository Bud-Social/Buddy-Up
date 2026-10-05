import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Plus, Users, Star, Lock, Globe, EyeOff, MapPin, Dumbbell, LocateFixed, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ErrorBanner } from '@/components/ui/ErrorBanner';
import { NearbyNotice } from '@/components/ui/NearbyNotice';
import { gymsApi } from '@/api/gyms';
import { requestLocation, formatDistance, type GeoMeta } from '@/lib/geo';
import type { Gym } from '@/types';

type FormatTab = 'all' | 'virtual' | 'hybrid' | 'physical';

export default function Gyms() {
  const navigate = useNavigate();
  const [gyms, setGyms] = useState<Gym[]>([]);
  const [geo, setGeo] = useState<GeoMeta | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState<'discover' | 'my_gyms'>('discover');
  const [format, setFormat] = useState<FormatTab>('all');
  const [category, setCategory] = useState('');
  const [city, setCity] = useState('');
  const [verifiedOnly, setVerifiedOnly] = useState(false);
  const [ordering, setOrdering] = useState<'members' | 'rating' | 'newest' | 'nearest'>('members');
  const [coords, setCoords] = useState<{ lat: number; lng: number } | null>(null);
  const [locStatus, setLocStatus] = useState<'idle' | 'locating' | 'ready' | 'denied'>('idle');
  const [radius, setRadius] = useState<'auto' | 5 | 10>('auto');

  const categories = ['fitness', 'nutrition', 'yoga_wellness', 'strength', 'cardio_running', 'sport_specific', 'mixed', 'other'];
  const formats: Array<{ key: FormatTab; label: string }> = [
    { key: 'all', label: 'All' },
    { key: 'virtual', label: 'Virtual' },
    { key: 'hybrid', label: 'Hybrid' },
    { key: 'physical', label: 'Physical' },
  ];

  const fetchGyms = useCallback(async () => {
    setIsLoading(true);
    setError('');
    try {
      const useGeo = coords !== null && format !== 'virtual';
      const res = await gymsApi.list({
        q: search || undefined,
        category: category || undefined,
        my: tab === 'my_gyms',
        city: city || undefined,
        delivery: format === 'all' ? undefined : format,
        verified: verifiedOnly || undefined,
        ordering: useGeo && ordering === 'members' ? 'nearest' : ordering,
        lat: useGeo ? coords.lat : undefined,
        lng: useGeo ? coords.lng : undefined,
        radius_km: useGeo && radius !== 'auto' ? radius : undefined,
      });
      const list = res.data || [];
      // Client-side nearest sort as a safety net (backend sorts the page too).
      if (useGeo) {
        list.sort((a, b) => (a.distance_km ?? Infinity) - (b.distance_km ?? Infinity));
      }
      setGyms([...list]);
      setGeo(res.geo ?? null);
    } catch {
      setError('Could not load gyms. Check your connection.');
    } finally {
      setIsLoading(false);
    }
  }, [search, category, tab, city, format, verifiedOnly, ordering, coords, radius]);

  useEffect(() => { fetchGyms(); }, [fetchGyms]);

  const locate = async () => {
    setLocStatus('locating');
    try {
      const c = await requestLocation();
      setCoords(c);
      setLocStatus('ready');
      setOrdering('nearest');
    } catch {
      setLocStatus('denied');
    }
  };

  const showDistance = format !== 'virtual';

  const accessIcon = (type: string) => {
    if (type === 'public') return <Globe size={12} />;
    if (type === 'private') return <Lock size={12} />;
    return <EyeOff size={12} />;
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center justify-between mb-4">
        <h1 className="font-display text-2xl font-extrabold">Gyms</h1>
        <Button size="sm" className="gap-1.5" onClick={() => navigate('/gyms/create')}>
          <Plus size={14} /> Create
        </Button>
      </div>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-3">
        {[
          { key: 'discover' as const, label: 'Discover' },
          { key: 'my_gyms' as const, label: 'My Gyms' },
        ].map(({ key, label }) => (
          <button key={key} onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
              tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >{label}</button>
        ))}
      </div>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-3" role="tablist" aria-label="Gym format">
        {formats.map(({ key, label }) => (
          <button key={key} role="tab" aria-selected={format === key} onClick={() => setFormat(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
              format === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >{label}</button>
        ))}
      </div>

      <NearbyNotice geo={coords ? geo : null} kind="gyms" />

      <div className="relative mb-3">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
        <input type="text" value={search} onChange={(e) => setSearch(e.target.value)}
          placeholder="Search gyms..."
          className="w-full bg-buddy-surface border border-transparent rounded-xl pl-10 pr-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30"
        />
      </div>

      <div className="flex gap-2 mb-3">
        <input type="text" value={city} onChange={(e) => setCity(e.target.value)}
          placeholder="City (e.g. Nairobi)"
          className="flex-1 min-w-0 bg-buddy-surface border border-transparent rounded-xl px-4 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30"
        />
        <select value={ordering} onChange={(e) => setOrdering(e.target.value as typeof ordering)}
          className="bg-buddy-surface border border-transparent rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary focus:outline-none focus:border-buddy-green/30"
          aria-label="Sort gyms"
        >
          <option value="members">Most members</option>
          <option value="rating">Top rated</option>
          <option value="newest">Newest</option>
          <option value="nearest">Nearest</option>
        </select>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        <button
          onClick={coords ? () => { setCoords(null); setLocStatus('idle'); setGeo(null); } : locate}
          disabled={locStatus === 'locating'}
          className={`flex-shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors snap-start ${
            coords ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
          }`}
        >
          {locStatus === 'locating' ? <Loader2 size={12} className="animate-spin" /> : <LocateFixed size={12} />}
          {coords ? 'Near me ✓' : locStatus === 'denied' ? 'GPS blocked — tap to retry' : 'Near me'}
        </button>
        {coords && (
          <select value={String(radius)} onChange={(e) => setRadius(e.target.value === 'auto' ? 'auto' : Number(e.target.value) as 5 | 10)}
            className="flex-shrink-0 bg-buddy-surface border border-buddy-surface rounded-full px-3 py-1.5 text-xs text-buddy-text-primary focus:outline-none"
            aria-label="Search radius"
          >
            <option value="auto">Auto radius (5–10 km)</option>
            <option value={5}>5 km</option>
            <option value={10}>10 km</option>
          </select>
        )}
        <button onClick={() => setVerifiedOnly((v) => !v)}
          className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors snap-start ${verifiedOnly ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
        >Verified only</button>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        <button onClick={() => setCategory('')}
          className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors snap-start ${!category ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
        >All</button>
        {categories.map((c) => (
          <button key={c} onClick={() => setCategory(c)}
            className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs capitalize whitespace-nowrap transition-colors snap-start ${category === c ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{c.replace('_', ' ')}</button>
        ))}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : gyms.length === 0 ? (
        error ? (
          <ErrorBanner message={error} onRetry={fetchGyms} />
        ) : (
          <div className="text-center py-20">
            <Users size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
            <p className="text-buddy-text-secondary text-lg">
              {tab === 'discover' ? 'No gyms found' : 'You haven\'t joined any gyms yet'}
            </p>
            <Button variant="outline" className="mt-4" onClick={() => navigate('/gyms/create')}>Create a Gym</Button>
          </div>
        )
      ) : (
        <>
          {error && <ErrorBanner message={error} onRetry={fetchGyms} className="mb-3" />}
          <div className="space-y-3">
          {gyms.map((gym) => (
            <Card key={gym.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
              onClick={() => navigate(`/gyms/${gym.handle}`)}>
              <div className="flex items-center gap-3">
                <div className="w-14 h-14 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0 text-buddy-green">
                  {gym.logo_url ? <img src={gym.logo_url} alt="" className="w-full h-full rounded-xl object-cover" /> : <Dumbbell size={26} />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h3 className="font-heading font-semibold text-sm truncate">{gym.name}</h3>
                    {gym.is_verified && <Badge variant="green" label="Verified" size="sm" />}
                    {gym.subscription_type === 'paid' && <Badge variant="gold" label="Paid" size="sm" />}
                  </div>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">@{gym.handle} · {gym.category.replace('_', ' ')}</p>
                  <div className="flex items-center gap-3 mt-1.5 text-xs text-buddy-text-secondary">
                    <span className="flex items-center gap-1"><Users size={12} /> {gym.member_count}</span>
                    {gym.is_reviews_enabled && gym.average_rating !== undefined && (
                      <span className="flex items-center gap-1 text-yellow-500">
                        <Star size={12} className="fill-current" /> {gym.average_rating.toFixed(1)} ({gym.review_count})
                      </span>
                    )}
                    <span className="flex items-center gap-1">{accessIcon(gym.access_type)} {gym.access_type}</span>
                    {gym.delivery_modes?.includes('virtual') && <Badge variant="gold" label="Virtual" size="sm" />}
                    {gym.delivery_modes?.includes('hybrid') && <Badge variant="green" label="Hybrid" size="sm" />}
                    {showDistance && gym.distance_km !== undefined && gym.distance_km !== null && (
                      <span className="flex items-center gap-1 text-buddy-green font-medium">
                        <MapPin size={12} /> {formatDistance(gym.distance_km)}
                      </span>
                    )}
                    {gym.location_city && (gym.distance_km === undefined || gym.distance_km === null) && (
                      <span className="flex items-center gap-1"><MapPin size={12} /> {gym.location_city}</span>
                    )}
                  </div>
                </div>
              </div>
            </Card>
          ))}
          </div>
        </>
      )}
    </div>
  );
}
