import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Star, MapPin, Award } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { ErrorBanner } from '@/components/ui/ErrorBanner';
import { sessionsApi } from '@/api/sessions';
import type { TrainerProfile } from '@/api/sessions';

const specialties = ['strength', 'hypertrophy', 'weight_loss', 'functional', 'athletic', 'prenatal', 'youth', 'senior', 'rehab', 'nutrition', 'online'];

export default function Trainers() {
  const navigate = useNavigate();
  const [trainers, setTrainers] = useState<TrainerProfile[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [specialty, setSpecialty] = useState('');
  const [location, setLocation] = useState('');
  const [verifiedOnly, setVerifiedOnly] = useState(false);
  const [virtualOnly, setVirtualOnly] = useState(false);
  const [mobileOnly, setMobileOnly] = useState(false);

  const fetchTrainers = useCallback(async () => {
    setIsLoading(true);
    setError('');
    try {
      const res = await sessionsApi.getTrainers({
        specialty: specialty || undefined,
        location: location || undefined,
        verified: verifiedOnly || undefined,
        virtual: virtualOnly || undefined,
        mobile: mobileOnly || undefined,
      });
      setTrainers(res.data || []);
    } catch {
      setError('Could not load trainers. Check your connection.');
    } finally {
      setIsLoading(false);
    }
  }, [specialty, location, verifiedOnly, virtualOnly, mobileOnly]);

  useEffect(() => { fetchTrainers(); }, [fetchTrainers]);

  const filtered = search
    ? trainers.filter((t) =>
        t.profile_data.display_name.toLowerCase().includes(search.toLowerCase()) ||
        t.profile_data.username.toLowerCase().includes(search.toLowerCase()))
    : trainers;

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-4">Trainers & Practitioners</h1>

      <div className="relative mb-3">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
        <input type="text" value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search trainers..."
          className="w-full bg-buddy-surface border border-transparent rounded-xl pl-10 pr-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30" />
      </div>

      <div className="flex gap-2 mb-3">
        <input type="text" value={location} onChange={(e) => setLocation(e.target.value)} placeholder="City or country (e.g. Nairobi)"
          className="flex-1 min-w-0 bg-buddy-surface border border-transparent rounded-xl px-4 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30" />
      </div>

      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        {[
          { key: 'verified' as const, label: 'Verified only', active: verifiedOnly, toggle: () => setVerifiedOnly((v) => !v) },
          { key: 'virtual' as const, label: 'Virtual', active: virtualOnly, toggle: () => setVirtualOnly((v) => !v) },
          { key: 'mobile' as const, label: 'Mobile', active: mobileOnly, toggle: () => setMobileOnly((v) => !v) },
        ].map(({ key, label, active, toggle }) => (
          <button key={key} onClick={toggle}
            className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors snap-start ${active ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{label}</button>
        ))}
      </div>

      <div className="flex gap-2 overflow-x-auto pb-3 mb-2 scrollbar-hide snap-x snap-mandatory">
        <button onClick={() => setSpecialty('')} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors snap-start ${!specialty ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>All</button>
        {specialties.map((s) => (
          <button key={s} onClick={() => setSpecialty(s)} className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs whitespace-nowrap capitalize transition-colors snap-start ${specialty === s ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}>{s.replace('_', ' ')}</button>
        ))}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-20 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : filtered.length === 0 ? (
        error ? (
          <ErrorBanner message={error} onRetry={fetchTrainers} />
        ) : (
          <div className="text-center py-20 text-buddy-text-secondary">No trainers found.</div>
        )
      ) : (
        <>
          {error && <ErrorBanner message={error} onRetry={fetchTrainers} className="mb-3" />}
          <div className="space-y-3">
          {filtered.map((t) => (
            <Card key={t.profile_id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer"
              onClick={() => navigate(`/trainers/${t.profile_data.username}`)}>
              <div className="flex items-start gap-3">
                <Avatar src={t.profile_data.avatar_url} alt={t.profile_data.display_name} size="lg" />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h3 className="font-heading font-semibold text-sm">{t.profile_data.display_name}</h3>
                    {t.profile_data.verification_status === 'trainer' && <Badge variant="green" label="Certified" size="sm" />}
                    {t.profile_data.verification_status === 'practitioner' && <Badge variant="gold" label="Practitioner" size="sm" />}
                    {(t.is_virtual || t.session_types?.some((s) => ['1on1_live', 'group_live', 'async', 'nutrition'].includes(s))) && <Badge variant="green" label="Virtual" size="sm" />}
                    {(t.is_mobile || t.session_types?.includes('in_person')) && <Badge variant="gold" label="Mobile" size="sm" />}
                  </div>
                  {t.affiliated_gyms && t.affiliated_gyms.length > 0 && (
                    <p className="text-xs text-buddy-text-secondary mt-0.5 truncate">
                      Affiliated: {t.affiliated_gyms.map((g) => g.name).join(', ')}
                    </p>
                  )}
                  <p className="text-xs text-buddy-text-secondary mt-0.5">@{t.profile_data.username}</p>
                  <div className="flex items-center gap-3 mt-1.5 text-xs text-buddy-text-secondary">
                    {t.review_count > 0 && (
                      <span className="flex items-center gap-1"><Star size={12} className="text-buddy-gold fill-buddy-gold" /> {t.average_rating} ({t.review_count})</span>
                    )}
                    {t.profile_data.location_city && (
                      <span className="flex items-center gap-1"><MapPin size={12} /> {t.profile_data.location_city}</span>
                    )}
                    <span className="flex items-center gap-1"><Award size={12} /> {t.years_experience}y exp</span>
                  </div>
                  {t.specialties?.length > 0 && (
                    <div className="flex flex-wrap gap-1 mt-2">
                      {t.specialties.slice(0, 4).map((s) => (
                        <span key={s} className="text-[10px] bg-buddy-surface-raised px-2 py-0.5 rounded-full capitalize">{s.replace('_', ' ')}</span>
                      ))}
                    </div>
                  )}
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
