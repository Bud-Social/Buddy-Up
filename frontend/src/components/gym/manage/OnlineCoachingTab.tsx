import { useEffect, useState, useCallback, useRef } from 'react';
import { Check, Plus, Trash2, Wifi, Search, X } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { gymsApi } from '@/api/gyms';
import { profilesApi } from '@/api/profiles';
import type { GymMembership, GymOnlineCoach, Profile } from '@/types';

const COMMON_TYPES = [
  '1:1 coaching',
  'workout plans',
  'form reviews',
  'nutrition guidance',
  'live classes',
  'check-ins',
];

interface OnlineCoachingTabProps {
  slug: string;
  canManage: boolean;
  members: GymMembership[];
}

/**
 * Online delivery settings.
 *
 * A gym that sells remote coaching has to say two things before it can be
 * booked: that it offers online sessions at all, and which formats it sells.
 * The roster below is restricted by the server to active members, so this tab
 * offers members rather than a free-text name and never lets an owner list
 * somebody who is not actually part of the gym.
 */
export function OnlineCoachingTab({ slug, canManage }: OnlineCoachingTabProps) {
  const [offers, setOffers] = useState(false);
  const [types, setTypes] = useState<string[]>([]);
  const [coaches, setCoaches] = useState<GymOnlineCoach[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [newType, setNewType] = useState('');
  const [coachUsername, setCoachUsername] = useState('');
  const [coachSpecialties, setCoachSpecialties] = useState('');
  const [selectedCoach, setSelectedCoach] = useState<Profile | null>(null);
  const [searchResults, setSearchResults] = useState<Profile[]>([]);
  const [searching, setSearching] = useState(false);
  const [addingCoach, setAddingCoach] = useState(false);
  const searchDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);

  const onSearchChange = useCallback((value: string) => {
    setCoachUsername(value);
    setSelectedCoach(null);
    if (searchDebounce.current) clearTimeout(searchDebounce.current);
    const q = value.trim();
    if (!q || q.length < 2) {
      setSearchResults([]);
      setSearching(false);
      return;
    }
    setSearching(true);
    searchDebounce.current = setTimeout(async () => {
      try {
        const res = await profilesApi.searchProfiles({ q, limit: 6 });
        setSearchResults(res.data || []);
      } catch {
        setSearchResults([]);
      } finally {
        setSearching(false);
      }
    }, 250);
  }, []);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await gymsApi.getOnlineCoaching(slug);
      setOffers(res.data.offers_online_coaching);
      setTypes(res.data.coaching_types || []);
      setCoaches(res.data.coaches || []);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not load online coaching settings.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [slug]); // eslint-disable-line react-hooks/exhaustive-deps

  const persist = async (patch: { offers_online_coaching?: boolean; coaching_types?: string[] }) => {
    setSaving(true);
    setError(null);
    try {
      await gymsApi.updateOnlineCoaching(slug, patch);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not save online coaching settings.');
      await load();
    } finally {
      setSaving(false);
    }
  };

  const toggleOffers = async () => {
    const next = !offers;
    setOffers(next);
    await persist({ offers_online_coaching: next });
  };

  const addType = async (value: string) => {
    const trimmed = value.trim();
    if (!trimmed || types.includes(trimmed) || types.length >= 20) return;
    const next = [...types, trimmed];
    setTypes(next);
    setNewType('');
    await persist({ coaching_types: next });
  };

  const removeType = async (value: string) => {
    const next = types.filter((t) => t !== value);
    setTypes(next);
    await persist({ coaching_types: next });
  };

  const addCoach = async () => {
    const identifier = selectedCoach?.user_id || coachUsername.trim();
    if (!identifier) return;
    setAddingCoach(true);
    setError(null);
    try {
      const res = await gymsApi.addOnlineCoach(slug, {
        ...(selectedCoach ? { user_id: selectedCoach.user_id } : { username: identifier }),
        specialties: coachSpecialties.split(',').map((s) => s.trim()).filter(Boolean),
        is_available: true,
      });
      setCoaches((prev) => {
        const rest = prev.filter((c) => c.id !== res.data.id);
        return [res.data, ...rest];
      });
      setCoachUsername('');
      setCoachSpecialties('');
      setSelectedCoach(null);
      setSearchResults([]);
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not add that coach.');
    } finally {
      setAddingCoach(false);
    }
  };

  const removeCoach = async (coach: GymOnlineCoach) => {
    setError(null);
    try {
      await gymsApi.removeOnlineCoach(slug, coach.id);
      setCoaches((prev) => prev.filter((c) => c.id !== coach.id));
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Could not remove that coach.');
    }
  };

  if (loading) {
    return <Card className="h-24 animate-pulse bg-buddy-surface-raised" />;
  }

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-bold text-buddy-text-secondary uppercase">Online coaching</h2>

      {error && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">
          {error}
        </div>
      )}

      <Card className="p-4 flex items-start gap-3">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${offers ? 'bg-buddy-green/15 text-buddy-green' : 'bg-buddy-surface-raised text-buddy-text-secondary'}`}>
          <Wifi size={18} />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium">Offer online Coaching &amp; workouts</p>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Members can book remote sessions with your roster and buy workout plans.
          </p>
        </div>
        <button
          type="button"
          role="switch"
          aria-checked={offers}
          aria-label="Offer online coaching"
          onClick={toggleOffers}
          disabled={!canManage || saving}
          className={`relative w-11 h-6 rounded-full transition-colors flex-shrink-0 ${
            offers ? 'bg-buddy-green' : 'bg-buddy-surface-raised'
          } ${!canManage ? 'opacity-40' : ''}`}
        >
          <span
            className={`absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white transition-transform ${
              offers ? 'translate-x-5' : ''
            }`}
          />
        </button>
      </Card>

      <Card className="p-4 space-y-3">
        <div>
          <p className="text-sm font-medium">What you sell online</p>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            These appear as filters and booking options on your gym page.
          </p>
        </div>
        {types.length > 0 && (
          <div className="flex flex-wrap gap-1.5">
            {types.map((type) => (
              <span key={type} className="inline-flex items-center gap-1 text-xs bg-buddy-green/10 text-buddy-green px-2.5 py-1 rounded-full">
                {type}
                {canManage && (
                  <button onClick={() => removeType(type)} aria-label={`Remove ${type}`} className="hover:text-buddy-red">×</button>
                )}
              </span>
            ))}
          </div>
        )}
        {canManage && (
          <div className="flex gap-2">
            <Input
              value={newType}
              onChange={(e) => setNewType(e.target.value)}
              placeholder="Add a coaching type…"
              onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addType(newType))}
            />
            <Button variant="outline" size="sm" onClick={() => addType(newType)} disabled={!newType.trim()}>
              Add
            </Button>
          </div>
        )}
        <div className="flex flex-wrap gap-1">
          {COMMON_TYPES.filter((t) => !types.includes(t)).map((t) => (
            <button
              key={t}
              type="button"
              disabled={!canManage}
              onClick={() => addType(t)}
              className="text-[10px] bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary px-2 py-0.5 rounded-full disabled:opacity-40"
            >
              + {t}
            </button>
          ))}
        </div>
      </Card>

      <Card className="p-4 space-y-3">
        <div>
          <p className="text-sm font-medium">Available online coaches ({coaches.length})</p>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Only active members can be listed. Add them here and they receive
            online booking requests.
          </p>
        </div>

        {coaches.length === 0 ? (
          <p className="text-xs text-buddy-text-secondary py-2">No coaches listed yet.</p>
        ) : (
          <div className="space-y-2">
            {coaches.map((coach) => (
              <div key={coach.id} className="flex items-center gap-2">
                <Avatar src={coach.coach_data?.avatar_url} alt={coach.coach_data?.display_name || 'Coach'} size="sm" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">
                    {coach.coach_data?.display_name || coach.coach_data?.username}
                  </p>
                  <p className="text-xs text-buddy-text-secondary truncate">
                    {coach.specialties?.length ? coach.specialties.join(' · ') : `@${coach.coach_data?.username}`}
                  </p>
                </div>
                {coach.approval_status === 'pending' ? (
                  <Badge variant="silver" label="Pending approval" />
                ) : (
                  <Badge variant="green" label="Coach" />
                )}
                {coach.coach_data?.verification_status === 'trainer' && (
                  <Badge variant="blue" label="Verified trainer" />
                )}
                {canManage && (
                  <Button size="sm" variant="ghost" aria-label="Remove coach" onClick={() => removeCoach(coach)}>
                    <Trash2 size={14} />
                  </Button>
                )}
              </div>
            ))}
          </div>
        )}

        {canManage && (
          <div className="space-y-2 pt-2 border-t border-buddy-surface">
            <p className="text-[10px] uppercase text-buddy-text-secondary">Add a trainer</p>
            <p className="text-[10px] text-buddy-text-secondary/70">Only trainers can be listed — the trainer gets an approval notification and appears as pending until they accept.</p>
            <div className="relative">
              <Search size={14} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
              <input
                value={selectedCoach ? `@${selectedCoach.username}` : coachUsername}
                onChange={(e) => onSearchChange(e.target.value)}
                placeholder="Start typing a name or username…"
                aria-label="Coach search"
                className="w-full bg-buddy-surface rounded-xl pl-8 pr-8 py-2 text-xs placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
              />
              {selectedCoach && (
                <button className="absolute right-2 top-1/2 -translate-y-1/2 text-buddy-text-secondary hover:text-buddy-text-primary" onClick={() => setSelectedCoach(null)} aria-label="Clear selection">
                  <X size={14} />
                </button>
              )}
              {searching && <div className="absolute right-8 top-1/2 -translate-y-1/2 w-3.5 h-3.5 border-2 border-buddy-green/30 border-t-buddy-green rounded-full animate-spin" />}
              {searchResults.length > 0 && !selectedCoach && (
                <div className="absolute z-20 top-full mt-1 w-full bg-buddy-surface-raised rounded-xl border border-buddy-surface overflow-hidden shadow-2xl max-h-48 overflow-y-auto">
                  {searchResults.map((p) => (
                    <button
                      key={p.user_id}
                      onMouseDown={(e) => { e.preventDefault(); setSelectedCoach(p); setCoachUsername(`@${p.username}`); setSearchResults([]); }}
                      className="flex w-full items-center gap-2 px-2 py-1.5 text-left hover:bg-buddy-surface"
                    >
                      <Avatar src={p.avatar_url} alt={p.display_name || p.username} size="xs" />
                      <span className="min-w-0 flex-1">
                        <span className="block text-xs font-medium truncate">{p.display_name || p.username}</span>
                        <span className="block text-[9px] text-buddy-text-secondary truncate">@{p.username}{p.role ? ` · ${p.role}` : ''}</span>
                      </span>
                    </button>
                  ))}
                </div>
              )}
            </div>
            <Input
              value={coachSpecialties}
              onChange={(e) => setCoachSpecialties(e.target.value)}
              placeholder="Coaching categories — e.g. strength, mobility (comma separated)"
            />
            <Button size="sm" onClick={addCoach} disabled={(!selectedCoach && !coachUsername.trim()) || addingCoach} isLoading={addingCoach}>
              <Plus size={12} className="mr-1" /> Add coach
            </Button>
          </div>
        )}
      </Card>

      {offers && (
        <Card className="p-3 bg-buddy-green/5 border border-buddy-green/20 flex items-center gap-2">
          <Check size={14} className="text-buddy-green" />
          <p className="text-xs text-buddy-text-secondary">
            Online coaching is live on your gym page.
          </p>
        </Card>
      )}
    </section>
  );
}

export default OnlineCoachingTab;
