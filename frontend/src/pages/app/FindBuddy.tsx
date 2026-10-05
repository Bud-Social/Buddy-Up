import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, LocateFixed, Loader2, Footprints, Camera, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { NearbyNotice } from '@/components/ui/NearbyNotice';
import { useToast } from '@/components/ui/Toast';
import { InterestChips } from '@/components/profile/InterestChips';
import { profilesApi, BUDDY_INTENTS, BUDDY_MODES, BUDDY_GOALS, BUDDY_VISIBILITY, type NearbyBuddy, type BuddySearchProfile } from '@/api/profiles';
import { feedApi } from '@/api/feed';
import { requestLocation, type GeoMeta } from '@/lib/geo';
import { track } from '@/lib/analytics';

/**
 * Find a buddy — declare what you're looking for (walk/run/gym/hike/...)
 * and see people near you looking for the same. Radius-only GPS.
 */
export default function FindBuddy() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [buddies, setBuddies] = useState<NearbyBuddy[]>([]);
  const [geo, setGeo] = useState<GeoMeta | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [intent, setIntent] = useState<string | null>('walk');
  const [customIntent, setCustomIntent] = useState('');
  const [mode, setMode] = useState<string | null>(null);
  const [nowOnly, setNowOnly] = useState(false);
  const [lookingNow, setLookingNow] = useState(false);
  const [coords, setCoords] = useState<{ lat: number; lng: number } | null>(null);
  const [locStatus, setLocStatus] = useState<'idle' | 'locating' | 'denied'>('idle');
  const [radius, setRadius] = useState<'auto' | 5 | 10>('auto');
  const [requested, setRequested] = useState<Set<string>>(new Set());
  // Setup editor state
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [bio, setBio] = useState('');
  const [goals, setGoals] = useState<string[]>([]);
  const [dob, setDob] = useState('');
  const [ageBand, setAgeBand] = useState('');
  const [photos, setPhotos] = useState<string[]>([]);
  const [pace, setPace] = useState('');
  const [neighbourhood, setNeighbourhood] = useState('');
  const [visibility, setVisibility] = useState('public');
  const [incognito, setIncognito] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const fetchBuddies = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await profilesApi.getNearbyBuddies({
        intent: intent || undefined,
        mode: mode || undefined,
        lat: coords?.lat,
        lng: coords?.lng,
        radius_km: coords && radius !== 'auto' ? radius : undefined,
        now: nowOnly || undefined,
      });
      setBuddies(res.data || []);
      setGeo(res.geo ?? null);
    } catch {
      setBuddies([]);
    } finally {
      setIsLoading(false);
    }
  }, [intent, mode, coords, radius, nowOnly]);

  useEffect(() => { fetchBuddies(); }, [fetchBuddies]);

  useEffect(() => {
    profilesApi.getSearchProfile().then((res) => {
      const sp = res.data as BuddySearchProfile;
      if (!sp) return;
      setBio(sp.bio || '');
      setGoals(sp.goals || []);
      setAgeBand(sp.age_band || '');
      setPhotos(sp.photos || []);
      setPace(sp.pace || '');
      setNeighbourhood(sp.neighbourhood || '');
      setVisibility(sp.visibility || 'public');
      setIncognito(!!sp.incognito);
      setLookingNow(!!sp.available_now);
      if (sp.intents?.length) setIntent(sp.intents[0]);
      if (sp.custom_intent) setCustomIntent(sp.custom_intent);
      if (sp.modes?.length) setMode(sp.modes[0]);
      if (sp.latitude && sp.longitude) setCoords({ lat: Number(sp.latitude), lng: Number(sp.longitude) });
    }).catch(() => {});
  }, []);

  const locate = async () => {
    setLocStatus('locating');
    try {
      const c = await requestLocation();
      setCoords(c);
      setLocStatus('idle');
      track('buddy.locate', { surface: 'find_buddy' });
    } catch {
      setLocStatus('denied');
    }
  };

  const toggleGoal = (g: string) =>
    setGoals((prev) => (prev.includes(g) ? prev.filter((x) => x !== g) : [...prev, g].slice(0, 5)));

  const addPhotos = async (files: FileList | null) => {
    if (!files?.length) return;
    const remaining = 4 - photos.length;
    if (remaining <= 0) {
      toast('error', 'Up to 4 search profile photos.');
      return;
    }
    setUploading(true);
    try {
      const urls: string[] = [];
      for (const f of Array.from(files).slice(0, remaining)) {
        const res = await feedApi.uploadPostMedia(f);
        if (res.data?.url) urls.push(res.data.url);
      }
      setPhotos((prev) => [...prev, ...urls].slice(0, 4));
    } catch {
      toast('error', 'Photo upload failed.');
    } finally {
      setUploading(false);
    }
  };

  const saveProfile = async (looking?: boolean) => {
    setSaving(true);
    try {
      const res = await profilesApi.updateSearchProfile({
        intents: intent ? [intent] : [],
        custom_intent: intent === 'other' ? customIntent.trim() : '',
        modes: mode ? [mode] : [],
        bio: bio.trim().slice(0, 140),
        goals,
        photos,
        pace: pace.trim(),
        neighbourhood: neighbourhood.trim(),
        visibility,
        incognito,
        available_now: looking ?? lookingNow,
        ...(dob ? { dob } : {}),
        ...(coords ? { latitude: coords.lat, longitude: coords.lng } : {}),
      } as Partial<BuddySearchProfile> & { dob?: string });
      const sp = res.data as BuddySearchProfile;
      if (sp.age_band) setAgeBand(sp.age_band);
      if (typeof sp.available_now === 'boolean') setLookingNow(sp.available_now);
      if (typeof sp.match_count === 'number' && (looking ?? lookingNow)) {
        toast('success', sp.match_count > 0 ? `${sp.match_count} buddie(s) nearby looking too 👀` : 'You’re visible as looking now (2h).');
      } else {
        toast('success', 'Search profile saved.');
      }
      fetchBuddies();
    } catch (err) {
      const msg = (err as { response?: { data?: { errors?: unknown; message?: string } } })?.response?.data?.message;
      toast('error', msg || 'Could not save search profile.');
    } finally {
      setSaving(false);
    }
  };

  const toggleLooking = async () => {
    const next = !lookingNow;
    setLookingNow(next);
    await saveProfile(next);
  };

  const sendRequest = async (username: string) => {
    try {
      await profilesApi.sendBuddyRequest(username);
      setRequested((prev) => new Set(prev).add(username));
      toast('success', `Buddy request sent to @${username}`);
    } catch {
      toast('error', 'Could not send buddy request.');
    }
  };

  return (
    <div className="max-w-lg lg:max-w-2xl mx-auto p-4 space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-2xl font-extrabold flex items-center gap-2">
          <Footprints className="text-buddy-green" /> Find a buddy
        </h1>
        <Button size="sm" variant={lookingNow ? 'ghost' : 'outline'} onClick={toggleLooking} disabled={saving}>
          {lookingNow ? 'Looking ✓ (tap to stop)' : 'I’m looking now'}
        </Button>
      </div>

      <div>
        <p className="text-xs font-medium text-buddy-text-secondary mb-2">I’m looking for</p>
        <div className="flex flex-wrap gap-2">
          {BUDDY_INTENTS.map((i) => (
            <button key={i} onClick={() => setIntent(intent === i ? null : i)}
              className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${intent === i ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
            >{i.replace('_', ' ')}</button>
          ))}
        </div>
        {intent === 'other' && (
          <input type="text" value={customIntent} onChange={(e) => setCustomIntent(e.target.value)}
            placeholder="Describe what you're looking for…"
            maxLength={100}
            className="mt-2 w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-2.5 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30"
          />
        )}
      </div>

      <div>
        <p className="text-xs font-medium text-buddy-text-secondary mb-2">How</p>
        <div className="flex flex-wrap gap-2">
          {BUDDY_MODES.map((m) => (
            <button key={m} onClick={() => setMode(mode === m ? null : m)}
              className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${mode === m ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
            >{m.replace('_', ' ')}</button>
          ))}
          <button onClick={() => setNowOnly((v) => !v)}
            className={`px-3 py-1.5 rounded-full text-xs transition-colors ${nowOnly ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >Available now</button>
          <button onClick={coords ? () => { setCoords(null); setGeo(null); } : locate}
            disabled={locStatus === 'locating'}
            className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs transition-colors ${coords ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >
            {locStatus === 'locating' ? <Loader2 size={12} className="animate-spin" /> : <LocateFixed size={12} />}
            {coords ? 'Near me ✓' : locStatus === 'denied' ? 'GPS blocked — retry' : 'Near me'}
          </button>
          {coords && (
            <select value={String(radius)} onChange={(e) => setRadius(e.target.value === 'auto' ? 'auto' : Number(e.target.value) as 5 | 10)}
              className="bg-buddy-surface border border-buddy-surface rounded-full px-3 py-1.5 text-xs focus:outline-none" aria-label="Search radius">
              <option value="auto">Auto radius (5–10 km)</option>
              <option value={5}>5 km</option>
              <option value={10}>10 km</option>
            </select>
          )}
        </div>
      </div>

      <Card className="p-4">
        <button onClick={() => setEditing((v) => !v)} className="w-full flex items-center justify-between">
          <span className="text-sm font-semibold">My buddy search profile {ageBand && <span className="text-buddy-text-secondary font-normal">· {ageBand}</span>}</span>
          <span className="text-xs text-buddy-green font-medium">{editing ? 'Hide' : 'Set up'}</span>
        </button>
        {editing && (
          <div className="mt-3 space-y-3">
            <textarea value={bio} onChange={(e) => setBio(e.target.value)} maxLength={140} rows={2}
              placeholder="Find-buddy bio — e.g. easy 5k at 6am, all paces welcome…"
              className="w-full bg-buddy-surface-raised rounded-xl px-4 py-2.5 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none focus:border-buddy-green/30" />
            <div>
              <p className="text-xs font-medium text-buddy-text-secondary mb-1.5">What I want to achieve (up to 5)</p>
              <div className="flex flex-wrap gap-2">
                {BUDDY_GOALS.map((g) => (
                  <button key={g} onClick={() => toggleGoal(g)}
                    className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${goals.includes(g) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'}`}
                  >{g.replace(/_/g, ' ')}</button>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <label className="text-xs text-buddy-text-secondary">Birth date (for age band {ageBand || '—'})
                <input type="date" value={dob} onChange={(e) => setDob(e.target.value)}
                  className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary focus:outline-none" />
              </label>
              <label className="text-xs text-buddy-text-secondary">Pace
                <input type="text" value={pace} onChange={(e) => setPace(e.target.value)} placeholder="Easy / steady / brisk"
                  className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none" />
              </label>
            </div>
            <label className="block text-xs text-buddy-text-secondary">Neighbourhood
              <input type="text" value={neighbourhood} onChange={(e) => setNeighbourhood(e.target.value)} placeholder="Kileleshwa"
                className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none" />
            </label>
            <div>
              <p className="text-xs font-medium text-buddy-text-secondary mb-1.5">Search photos ({photos.length}/4)</p>
              <div className="flex gap-2 flex-wrap">
                {photos.map((u) => (
                  <div key={u} className="relative w-16 h-16 rounded-xl overflow-hidden">
                    <img src={u} alt="" className="w-full h-full object-cover" />
                    <button onClick={() => setPhotos((prev) => prev.filter((x) => x !== u))}
                      aria-label="Remove photo" className="absolute top-0.5 right-0.5 p-0.5 rounded-full bg-black/60 text-white">
                      <X size={12} />
                    </button>
                  </div>
                ))}
                {photos.length < 4 && (
                  <button onClick={() => fileRef.current?.click()} disabled={uploading}
                    className="w-16 h-16 rounded-xl border border-dashed border-buddy-surface-raised flex items-center justify-center text-buddy-text-secondary hover:text-buddy-green">
                    {uploading ? <Loader2 size={16} className="animate-spin" /> : <Camera size={16} />}
                  </button>
                )}
              </div>
              <input ref={fileRef} type="file" accept="image/*" multiple className="hidden" onChange={(e) => { addPhotos(e.target.files); e.target.value = ''; }} />
            </div>
            <div className="grid grid-cols-2 gap-2">
              <label className="text-xs text-buddy-text-secondary">Who can find me
                <select value={visibility} onChange={(e) => setVisibility(e.target.value)}
                  className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm focus:outline-none">
                  {BUDDY_VISIBILITY.map((v) => <option key={v} value={v}>{v === 'buddies' ? 'Buddies only' : v[0].toUpperCase() + v.slice(1)}</option>)}
                </select>
              </label>
              <label className="text-xs text-buddy-text-secondary flex items-end gap-2 pb-2.5 cursor-pointer">
                <input type="checkbox" checked={incognito} onChange={(e) => setIncognito(e.target.checked)} className="w-4 h-4 accent-buddy-green" />
                Incognito (browse unseen)
              </label>
            </div>
            <Button size="sm" className="w-full" onClick={() => saveProfile()} disabled={saving}>
              {saving ? 'Saving…' : 'Save search profile'}
            </Button>
          </div>
        )}
      </Card>

      <NearbyNotice geo={coords ? geo : null} kind="buddies" />

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : buddies.length === 0 ? (
        <div className="text-center py-16">
          <Users size={44} className="mx-auto text-buddy-text-secondary/30 mb-3" />
          <p className="text-buddy-text-secondary">Nobody nearby for this yet — try another intent or widen the search.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {buddies.map((b) => (
            <Card key={b.profile.user_id} className="p-4 cursor-pointer hover:bg-buddy-surface-raised transition-colors"
              onClick={() => navigate(`/${b.profile.username}`)}>
              <div className="flex items-center gap-3">
                <Avatar src={b.photos?.[0] || b.profile.avatar_url} alt={b.profile.display_name} size="lg" />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="font-heading font-semibold text-sm truncate">{b.profile.display_name}</p>
                    {b.available_now && <Badge variant="green" label="Now" size="sm" />}
                    {b.age_band && <Badge variant="silver" label={b.age_band} size="sm" />}
                  </div>
                  <p className="text-xs text-buddy-text-secondary">@{b.profile.username}</p>
                  {(b.custom_intent || (b.intents?.length > 0)) && (
                    <p className="text-xs text-buddy-text-primary mt-0.5 truncate">
                      Wants: {b.custom_intent || b.intents.map((x) => x.replace('_', ' ')).join(', ')}
                    </p>
                  )}
                  {b.bio && <p className="text-xs text-buddy-text-secondary truncate mt-0.5">{b.bio}</p>}
                  <p className="text-xs text-buddy-green mt-0.5">{b.explanation}</p>
                  <div className="mt-1.5"><InterestChips preferences={b.profile.preferences} /></div>
                </div>
                <Button size="sm" variant={requested.has(b.profile.username) ? 'ghost' : 'outline'}
                  disabled={requested.has(b.profile.username)}
                  onClick={(e) => { e.stopPropagation(); sendRequest(b.profile.username); }}>
                  {requested.has(b.profile.username) ? 'Requested' : 'Buddy Up'}
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
