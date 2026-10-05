import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, LocateFixed, Loader2, Footprints, Camera, X, MessageCircle, Heart } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { NearbyNotice } from '@/components/ui/NearbyNotice';
import { useToast } from '@/components/ui/Toast';
import { profilesApi, BUDDY_INTENTS, BUDDY_MODES, BUDDY_GOALS, BUDDY_VISIBILITY, type NearbyBuddy, type BuddySearchProfile } from '@/api/profiles';
import { messagingApi } from '@/api';
import { feedApi } from '@/api/feed';
import { requestLocation, type GeoMeta } from '@/lib/geo';
import { track } from '@/lib/analytics';

/**
 * Find a buddy — declare what you're looking for (walk/run/gym/hike/...)
 * and see people near you looking for the same. Radius-only GPS.
 */
function formatUntil(iso: string | null | undefined): string | null {
  if (!iso) return null;
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return null;
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

/** Prefer the server's message — the interest endpoint explains every refusal. */
function serverMessage(err: unknown, fallback: string): string {
  const e = err as { response?: { data?: { message?: string } } } | null;
  const m = e?.response?.data?.message;
  return typeof m === 'string' && m.length > 0 ? m : fallback;
}

/** "1.3 km" / "<1 km" — null when the search API could not band the distance. */
export function formatDistanceBadge(km: number | null | undefined): string | null {
  if (km == null || !Number.isFinite(km) || km < 0) return null;
  if (km < 1) return '<1 km';
  if (km < 10) return `${km.toFixed(1)} km`;
  return `${Math.round(km)} km`;
}

/** Closest first — the tile leads with the distance badge. */
export function sortByDistance(buddies: NearbyBuddy[]): NearbyBuddy[] {
  return [...buddies].sort((a, b) => {
    const x = a.distance_km;
    const y = b.distance_km;
    if (x == null && y == null) return 0;
    if (x == null) return 1;
    if (y == null) return -1;
    return x - y;
  });
}

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
  // Setup editor state
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [displayName, setDisplayName] = useState('');
  const [bio, setBio] = useState('');
  const [goals, setGoals] = useState<string[]>([]);
  const [dob, setDob] = useState('');
  const [ageBand, setAgeBand] = useState('');
  const [photos, setPhotos] = useState<string[]>([]);
  const [pace, setPace] = useState('');
  const [neighbourhood, setNeighbourhood] = useState('');
  const [visibility, setVisibility] = useState('public');
  const [incognito, setIncognito] = useState(false);
  const [hasSavedProfile, setHasSavedProfile] = useState(false);
  const [matchCount, setMatchCount] = useState<number | null>(null);
  const [availableUntil, setAvailableUntil] = useState<string | null>(null);
  const [msgSending, setMsgSending] = useState<Set<string>>(new Set());
  const [likeBusy, setLikeBusy] = useState<Set<string>>(new Set());
  const fileRef = useRef<HTMLInputElement>(null);
  const editorRef = useRef<HTMLDivElement>(null);

  const openEditor = () => {
    setEditing(true);
    // Editor may have just mounted — defer scroll until after render.
    setTimeout(() => {
      editorRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 50);
  };

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
    (async () => {
      try {
        const res = await profilesApi.getSearchProfile();
        const sp = res.data as BuddySearchProfile;
        if (!sp) return;
        let name = sp.display_name || '';
        if (!name.trim()) {
          // Default display name = linked account's.
          try {
            const me = await profilesApi.getMyProfile();
            name = me.data?.display_name || me.data?.username || '';
          } catch {
            name = '';
          }
        }
        setDisplayName(name);
        setBio(sp.bio || '');
        setGoals(sp.goals || []);
        setAgeBand(sp.age_band || '');
        setPhotos(sp.photos || []);
        setPace(sp.pace || '');
        setNeighbourhood(sp.neighbourhood || '');
        setVisibility(sp.visibility || 'public');
        setIncognito(!!sp.incognito);
        setLookingNow(!!sp.available_now);
        setAvailableUntil(sp.available_until ?? null);
        if (sp.search_radius_km === 5 || sp.search_radius_km === 10) {
          setRadius(sp.search_radius_km);
        }
        if (sp.intents?.length) setIntent(sp.intents[0]);
        if (sp.custom_intent) setCustomIntent(sp.custom_intent);
        if (sp.modes?.length) setMode(sp.modes[0]);
        if (sp.latitude && sp.longitude) setCoords({ lat: Number(sp.latitude), lng: Number(sp.longitude) });
        if (sp.intents?.length) setHasSavedProfile(true);
        if (typeof sp.match_count === 'number') setMatchCount(sp.match_count);
      } catch {
        // No saved profile yet — editor stays open for setup.
      }
    })();
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
        display_name: displayName.trim().slice(0, 50),
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
        search_radius_km: radius === 'auto' ? null : radius,
        ...(dob ? { dob } : {}),
        ...(coords ? { latitude: coords.lat, longitude: coords.lng } : {}),
      } as Partial<BuddySearchProfile> & { dob?: string });
      const sp = res.data as BuddySearchProfile;
      if (sp.age_band) setAgeBand(sp.age_band);
      if (typeof sp.available_now === 'boolean') setLookingNow(sp.available_now);
      setAvailableUntil(sp.available_until ?? null);
      if (typeof sp.match_count === 'number') setMatchCount(sp.match_count);
      setHasSavedProfile(true);
      setEditing(false);
      if (typeof sp.match_count === 'number' && (looking ?? lookingNow)) {
        toast('success', sp.match_count > 0 ? `${sp.match_count} buddie(s) nearby looking too 👀` : 'You’re visible as looking now (2h).');
      } else {
        toast('success', 'Search profile saved.');
      }
      await fetchBuddies();
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

  /** Optimistic interest toggle — rolls back and surfaces the server's message on failure. */
  const toggleLike = async (buddy: NearbyBuddy) => {
    const username = buddy.profile.username;
    if (likeBusy.has(username)) return;
    const wasLiked = !!buddy.liked_by_me;
    const patch = (b: NearbyBuddy) => ({ ...b, liked_by_me: !wasLiked });
    setLikeBusy((prev) => new Set(prev).add(username));
    setBuddies((prev) => prev.map((b) => (b.profile.username === username ? patch(b) : b)));
    try {
      const res = wasLiked ? await profilesApi.unlikeBuddy(username) : await profilesApi.likeBuddy(username);
      const likedMe = res.data?.liked_me;
      if (typeof likedMe === 'boolean') {
        setBuddies((prev) => prev.map((b) => (b.profile.username === username ? { ...patch(b), liked_me: likedMe } : b)));
      }
    } catch (err) {
      setBuddies((prev) => prev.map((b) => (b.profile.username === username ? { ...b, liked_by_me: wasLiked } : b)));
      toast('error', serverMessage(err, wasLiked ? 'Could not undo interest.' : 'Could not show interest.'));
    } finally {
      setLikeBusy((prev) => {
        const next = new Set(prev);
        next.delete(username);
        return next;
      });
    }
  };

  const handleMessage = async (username: string) => {
    if (msgSending.has(username)) return;
    setMsgSending((prev) => new Set(prev).add(username));
    try {
      const res = await messagingApi.startConversation([username], undefined, 'discovery');
      const convoId = res.data?.id;
      navigate(convoId ? `/messages/${convoId}` : `/messages?user=${username}`);
    } catch (err) {
      const status = (err as { response?: { status?: number } })?.response?.status;
      if (status === 403) toast('error', 'Buddy up first to chat');
      else toast('error', 'Failed to start conversation');
    } finally {
      setMsgSending((prev) => {
        const next = new Set(prev);
        next.delete(username);
        return next;
      });
    }
  };

  return (
    <div className="max-w-lg lg:max-w-2xl mx-auto p-4 space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="font-display text-2xl font-extrabold flex items-center gap-2">
          <Footprints className="text-buddy-green" /> Find a buddy
        </h1>
        <div className="flex items-center gap-2">
          <Button size="sm" variant={lookingNow ? 'ghost' : 'outline'} onClick={toggleLooking} disabled={saving}>
            {lookingNow ? 'Looking ✓ (tap to stop)' : 'I’m looking now'}
          </Button>
          <button
            type="button"
            aria-label="Buddy messages"
            onClick={() => navigate('/buddies/messages')}
            className="p-2 rounded-full border border-buddy-surface text-buddy-text-secondary hover:text-buddy-green hover:border-buddy-green/40 transition-colors"
          >
            <MessageCircle size={16} />
          </button>
        </div>
      </div>

      {!editing && hasSavedProfile && (
        <Card className="p-4">
          <div className="flex items-start gap-3">
            <Avatar src={photos[0]} alt="Your buddy profile" size="lg" />
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-semibold">{displayName || 'Your buddy profile'}</p>
                <button onClick={openEditor}
                  className="text-xs text-buddy-green font-medium hover:underline">
                  Edit
                </button>
              </div>
              {bio ? (
                <p className="text-xs text-buddy-text-primary mt-1 line-clamp-2">{bio}</p>
              ) : (
                <p className="text-xs text-buddy-text-secondary mt-1">No bio yet — tap Edit to add one.</p>
              )}
              <div className="flex flex-wrap gap-1.5 mt-2">
                {intent && <Badge variant="green" label={intent === 'other' && customIntent ? customIntent : intent.replace('_', ' ')} size="sm" />}
                {mode && <Badge variant="silver" label={mode.replace('_', ' ')} size="sm" />}
                {goals.map((g) => (
                  <Badge key={g} variant="silver" label={g.replace(/_/g, ' ')} size="sm" />
                ))}
                {ageBand && <Badge variant="silver" label={ageBand} size="sm" />}
                <Badge variant={visibility === 'public' ? 'green' : 'silver'} label={visibility === 'buddies' ? 'Buddies only' : visibility[0].toUpperCase() + visibility.slice(1)} size="sm" />
                {incognito && <Badge variant="gold" label="Incognito" size="sm" />}
                {lookingNow && <Badge variant="green" label="Looking now" size="sm" />}
              </div>
              {lookingNow && formatUntil(availableUntil) && (
                <p className="text-xs text-buddy-green font-medium mt-1.5">Looking until {formatUntil(availableUntil)}</p>
              )}
              {typeof matchCount === 'number' && matchCount > 0 && (
                <p className="text-xs text-buddy-green font-medium mt-2">{matchCount} {matchCount === 1 ? 'buddy nearby' : 'buddies nearby'}</p>
              )}
              <div className="flex items-center justify-between mt-2">
                <p className="text-xs text-buddy-text-secondary">
                  Privacy: {visibility === 'buddies' ? 'Buddies only' : visibility[0].toUpperCase() + visibility.slice(1)}{incognito ? ' · Incognito on' : ''}
                </p>
                <button onClick={openEditor}
                  className="text-xs text-buddy-green font-medium hover:underline">
                  Manage
                </button>
              </div>
            </div>
          </div>
        </Card>
      )}

      {typeof matchCount === 'number' && matchCount > 0 && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 rounded-xl px-4 py-2.5 text-center">
          <p className="text-xs text-buddy-green font-medium">{matchCount} {matchCount === 1 ? 'buddy nearby looking too 👀' : 'buddies nearby looking too 👀'}</p>
        </div>
      )}

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

      {(editing || !hasSavedProfile) && (
      <Card ref={editorRef} className="p-4 scroll-mt-4">
        <button onClick={() => setEditing((v) => !v)} className="w-full flex items-center justify-between">
          <span className="text-sm font-semibold">My buddy search profile {ageBand && <span className="text-buddy-text-secondary font-normal">· {ageBand}</span>}</span>
          <span className="text-xs text-buddy-green font-medium">{editing ? 'Hide' : 'Set up'}</span>
        </button>
        {editing && (
          <div className="mt-3 space-y-3">
            <label className="block text-xs text-buddy-text-secondary">Display name (shown on buddy search)
              <input type="text" value={displayName} onChange={(e) => setDisplayName(e.target.value)}
                placeholder="e.g. Dawn Runner"
                maxLength={50}
                className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm placeholder:text-buddy-text-secondary/50 focus:outline-none" />
            </label>
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
      )}

      <NearbyNotice geo={coords ? geo : null} kind="buddies" />

      {isLoading ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3" aria-label="Finding buddies">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="aspect-[3/4] rounded-2xl bg-buddy-surface border border-buddy-surface-raised animate-pulse" />
          ))}
        </div>
      ) : buddies.length === 0 ? (
        <div className="text-center py-16">
          <Users size={44} className="mx-auto text-buddy-text-secondary/30 mb-3" />
          {!intent ? (
            <p className="text-buddy-text-secondary">Pick an intent above to find your buddies — e.g. walk, run or gym.</p>
          ) : !coords ? (
            <p className="text-buddy-text-secondary">Tap <span className="font-medium text-buddy-text-primary">Near me</span> to find {intent.replace('_', ' ')} buddies around you.</p>
          ) : (
            <p className="text-buddy-text-secondary">Nobody nearby for this yet — try another intent or widen the search.</p>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          {sortByDistance(buddies).map((b) => {
            const username = b.profile.username;
            const name = b.display_name || b.profile.display_name || username;
            const photo = b.photos?.[0] || b.profile.avatar_url;
            const distance = formatDistanceBadge(b.distance_km);
            const intents = b.custom_intent
              ? [b.custom_intent]
              : (b.intents || []).slice(0, 2).map((x) => x.replace(/_/g, ' '));
            const goals = (b.goals || []).slice(0, 2).map((g) => g.replace(/_/g, ' '));
            const mode = (b.modes || [])[0]?.replace(/_/g, ' ');
            const liked = !!b.liked_by_me;
            const likedMe = !!b.liked_me;
            const busy = likeBusy.has(username);
            return (
              <div
                key={b.profile.user_id}
                className="relative flex flex-col aspect-[3/4] rounded-2xl overflow-hidden bg-buddy-surface border border-buddy-surface-raised"
              >
                <div className="relative flex-1 min-h-0">
                  {photo ? (
                    <img src={photo} alt="" loading="lazy" className="absolute inset-0 w-full h-full object-cover" />
                  ) : (
                    <span className="absolute inset-0 flex items-center justify-center bg-buddy-surface-raised font-display text-4xl font-bold text-buddy-green/70">
                      {name.charAt(0).toUpperCase()}
                    </span>
                  )}

                  <span
                    data-testid={`distance-${username}`}
                    className="pointer-events-none absolute top-2 right-2 inline-flex items-center gap-1 rounded-md bg-buddy-black/75 px-1.5 py-0.5 font-mono text-[11px] font-bold text-buddy-green tabular-nums"
                  >
                    <LocateFixed size={10} aria-hidden="true" />
                    {distance ?? 'Nearby'}
                  </span>
                  {b.available_now && (
                    <span className="pointer-events-none absolute top-2 left-2 rounded-md bg-buddy-green px-1.5 py-0.5 text-[10px] font-bold text-buddy-black">
                      Available now
                    </span>
                  )}
                </div>

                <div className="pointer-events-none flex flex-col gap-1 bg-buddy-surface px-2.5 py-2">
                  <div className="min-w-0">
                    <p className="truncate text-[13px] font-semibold leading-tight text-buddy-text-primary">{name}</p>
                    <p className="truncate text-[10px] leading-tight text-buddy-text-secondary">
                      {[b.age_band, mode].filter(Boolean).join(' · ') || `@${username}`}
                    </p>
                  </div>
                  {intents.length > 0 && (
                    <p className="truncate text-[11px] leading-tight text-buddy-green">{intents.join(' · ')}</p>
                  )}
                  {goals.length > 0 && (
                    <p className="truncate text-[10px] leading-tight text-buddy-text-secondary">{goals.join(' · ')}</p>
                  )}
                  {/* relative z-10 so these sit above the card-body overlay and
                      stay clickable; the rest of the caption passes clicks through. */}
                  <div className="pointer-events-auto relative z-10 mt-auto flex items-center justify-end gap-1 pt-1">
                    <button
                      aria-label={`Message @${username}`}
                      disabled={msgSending.has(username)}
                      onClick={() => handleMessage(username)}
                      className="p-2 rounded-full bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-green transition-colors disabled:opacity-50"
                    >
                      {msgSending.has(username)
                        ? <Loader2 size={14} className="animate-spin" />
                        : <MessageCircle size={14} />}
                    </button>
                    <span className="relative">
                      <button
                        aria-label={liked ? `Remove interest in @${username}` : `Show interest in @${username}`}
                        aria-pressed={liked}
                        disabled={busy}
                        onClick={() => toggleLike(b)}
                        className={`p-2 rounded-full transition-colors disabled:opacity-50 ${
                          liked
                            ? 'bg-buddy-red/15 text-buddy-red'
                            : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-red'
                        }`}
                      >
                        <Heart size={14} fill={liked ? 'currentColor' : 'none'} />
                      </button>
                      {likedMe && !liked && (
                        <span className="absolute -top-1.5 -right-1.5 rounded-full bg-buddy-gold px-1.5 py-0.5 text-[9px] font-bold leading-none text-buddy-black">
                          Liked you
                        </span>
                      )}
                    </span>
                  </div>
                </div>

                {/* Card body → the full find-a-buddy profile. Last in the tab
                    order so the row actions stay reachable. */}
                <button
                  type="button"
                  onClick={() => navigate(`/buddies/find/${username}`)}
                  aria-label={`Open ${name}'s buddy profile, @${username}`}
                  className="absolute inset-0 focus-visible:outline focus-visible:outline-2 focus-visible:outline-buddy-green"
                />
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
