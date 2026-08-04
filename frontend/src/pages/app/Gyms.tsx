import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Plus, Users, Star, Lock, Globe, EyeOff } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { gymsApi } from '@/api/gyms';
import type { Gym } from '@/types';

export default function Gyms() {
  const navigate = useNavigate();
  const [gyms, setGyms] = useState<Gym[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState<'discover' | 'my_gyms'>('discover');
  const [category, setCategory] = useState('');

  const categories = ['fitness', 'nutrition', 'yoga_wellness', 'strength', 'cardio_running', 'sport_specific', 'mixed', 'other'];

  const fetchGyms = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await gymsApi.list({
        q: search || undefined,
        category: category || undefined,
        my: tab === 'my_gyms',
      });
      setGyms(res.data || []);
    } catch {} finally {
      setIsLoading(false);
    }
  }, [search, category, tab]);

  useEffect(() => { fetchGyms(); }, [fetchGyms]);

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

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
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

      <div className="relative mb-3">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
        <input type="text" value={search} onChange={(e) => setSearch(e.target.value)}
          placeholder="Search gyms..."
          className="w-full bg-buddy-surface border border-transparent rounded-xl pl-10 pr-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30"
        />
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
        <div className="text-center py-20">
          <Users size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary text-lg">
            {tab === 'discover' ? 'No gyms found' : 'You haven\'t joined any gyms yet'}
          </p>
          <Button variant="outline" className="mt-4" onClick={() => navigate('/gyms/create')}>Create a Gym</Button>
        </div>
      ) : (
        <div className="space-y-3">
          {gyms.map((gym) => (
            <Card key={gym.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
              onClick={() => navigate(`/gyms/${gym.handle}`)}>
              <div className="flex items-center gap-3">
                <div className="w-14 h-14 rounded-xl bg-buddy-green/10 flex items-center justify-center flex-shrink-0 text-2xl">
                  {gym.logo_url ? <img src={gym.logo_url} alt="" className="w-full h-full rounded-xl object-cover" /> : '🏋️'}
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
                    {gym.location_city && <span>📍 {gym.location_city}</span>}
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
