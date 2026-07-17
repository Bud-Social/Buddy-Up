import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Radio, Calendar, Play, Clock, Users, Dumbbell, Flame,
  Globe, UsersRound, Building2, Monitor, Search, X,
  Repeat, Shuffle, CheckCircle, AlertCircle,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { livesApi } from '@/api/lives';
import { profilesApi } from '@/api';
import ReplayPlayer from '@/components/live/ReplayPlayer';
import type { BuddyLive } from '@/types/live';
import type { Profile } from '@/types';

type Tab = 'live' | 'upcoming' | 'replays';

export default function Lives() {
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('live');
  const [lives, setLives] = useState<BuddyLive[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showStartLive, setShowStartLive] = useState(false);
  const [showRandomDrop, setShowRandomDrop] = useState(false);
  const [replayLive, setReplayLive] = useState<BuddyLive | null>(null);
  const [error, setError] = useState('');

  const fetchLives = useCallback(async (t: Tab) => {
    setIsLoading(true);
    setError('');
    try {
      const res = await livesApi.browse({ tab: t === 'upcoming' ? 'scheduled' : t });
      setLives(res.data || []);
    } catch {
      setError('Failed to load lives. Check your connection.');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { fetchLives(tab); }, [tab, fetchLives]);

  const tabs: { key: Tab; label: string; icon: typeof Radio }[] = [
    { key: 'live', label: 'Live Now', icon: Radio },
    { key: 'upcoming', label: 'Upcoming', icon: Calendar },
    { key: 'replays', label: 'Replays', icon: Play },
  ];

  const liveTypeBadge = (type: string) => {
    const map: Record<string, { variant: 'green' | 'orange' | 'gold' | 'blue' | 'silver' | 'red'; label: string }> = {
      open_sweat: { variant: 'green', label: 'Open Sweat' },
      buddy_circle: { variant: 'blue', label: 'Buddy Circle' },
      gym_live: { variant: 'gold', label: 'Gym Live' },
      pt_session_live: { variant: 'orange', label: 'PT Session' },
      random_drop: { variant: 'silver', label: 'Random Drop' },
      practitioner_live: { variant: 'gold', label: 'Practitioner' },
    };
    const b = map[type] || { variant: 'blue' as const, label: type };
    return <Badge variant={b.variant} label={b.label} size="sm" />;
  };

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-extrabold">Buddy Lives</h1>
        <div className="flex gap-2">
          <Button size="sm" variant="secondary" className="gap-1.5" onClick={() => setShowRandomDrop(true)}>
            <Flame size={14} /> Drop In
          </Button>
          <Button size="sm" className="gap-1.5" onClick={() => setShowStartLive(true)}>
            <Radio size={14} /> Go Live
          </Button>
        </div>
      </div>

      <div className="flex rounded-xl bg-buddy-surface p-1 mb-4">
        {tabs.map(({ key, label, icon: Icon }) => (
          <button key={key} onClick={() => setTab(key)}
            className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors flex items-center justify-center gap-1.5 ${
              tab === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            <Icon size={14} /> {label}
          </button>
        ))}
      </div>

      {error && (
        <div className="flex items-center gap-2 bg-buddy-red/10 border border-buddy-red/20 rounded-xl px-4 py-3 mb-4 text-sm text-buddy-red">
          <AlertCircle size={16} /> {error}
        </div>
      )}

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-24 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : lives.length === 0 ? (
        <div className="text-center py-20">
          <Radio size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary text-lg">
            {tab === 'live' ? 'No live sessions right now' : tab === 'upcoming' ? 'No upcoming lives' : 'No replays yet'}
          </p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">
            {tab === 'live' ? 'Be the first to start a Buddy Live!' : 'Schedule a live session for your community.'}
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {lives.map((live) => (
            <Card key={live.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer" onClick={() => live.status === 'live' ? navigate(`/live/${live.id}`) : null}>
              <div className="flex items-start gap-3">
                <div className="relative">
                  <Avatar src={live.host?.avatar_url} alt={live.host?.display_name || 'User'} size="lg" />
                  {live.status === 'live' && (
                    <div className="absolute -top-1 -right-1 w-4 h-4 bg-buddy-red rounded-full border-2 border-buddy-black animate-pulse" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    {liveTypeBadge(live.live_type)}
                    {live.artifact_fee && Object.keys(live.artifact_fee).length > 0 && (
                      <span className="text-xs text-buddy-gold font-coin">💰 Paid</span>
                    )}
                  </div>
                  <h3 className="font-heading font-semibold text-sm truncate">{live.title}</h3>
                  <p className="text-xs text-buddy-text-secondary mt-0.5">
                    {live.host?.display_name} · {live.category}
                  </p>
                  <div className="flex items-center gap-4 mt-2 text-xs text-buddy-text-secondary">
                    <span className="flex items-center gap-1">
                      <Users size={12} /> {live.viewer_peak || 0}
                    </span>
                    {live.status === 'live' && (
                      <span className="flex items-center gap-1 text-buddy-red">
                        <Radio size={12} /> LIVE
                      </span>
                    )}
                    {live.scheduled_for && (
                      <span className="flex items-center gap-1">
                        <Clock size={12} /> {new Date(live.scheduled_for).toLocaleDateString()}
                      </span>
                    )}
                    {live.status === 'live' && (
                      <Button size="sm" className="ml-auto" onClick={(e) => { e.stopPropagation(); navigate(`/live/${live.id}`); }}>Join</Button>
                    )}
                    {live.status === 'scheduled' && (
                      <Button size="sm" variant={live.has_rsvped ? 'primary' : 'outline'} className="ml-auto gap-1"
                        onClick={(e) => { e.stopPropagation(); livesApi.rsvpLive(live.id).then(() => fetchLives(tab)); }}>
                        {live.has_rsvped ? 'RSVPed' : 'RSVP'}
                      </Button>
                    )}
                    {live.status === 'ended' && live.replay_url && (
                      <Button size="sm" variant="outline" className="ml-auto gap-1.5" onClick={(e) => { e.stopPropagation(); setReplayLive(live); }}>
                        <Play size={12} /> Watch
                      </Button>
                    )}
                  </div>
                  {live.equipment_list?.length > 0 && (
                    <div className="flex gap-1 mt-2">
                      {live.equipment_list.map((e) => (
                        <span key={e} className="text-xs bg-buddy-surface-raised px-2 py-0.5 rounded-full">{e}</span>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {showStartLive && <StartLiveSheet onClose={() => setShowStartLive(false)} />}
      {showRandomDrop && <RandomDropSheet onClose={() => setShowRandomDrop(false)} />}
      {replayLive && (
        <ReplayPlayer
          title={replayLive.title}
          hostName={replayLive.host?.display_name || 'Unknown'}
          replayUrl={replayLive.replay_url}
          muxPlaybackId={replayLive.mux_playback_id}
          onClose={() => setReplayLive(null)}
        />
      )}
    </div>
  );
}

function StartLiveSheet({ onClose }: { onClose: () => void }) {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('strength');
  const [liveType, setLiveType] = useState('open_sweat');
  const [access, setAccess] = useState('public');
  const [equipment, setEquipment] = useState<string[]>([]);
  const [scheduledFor, setScheduledFor] = useState('');
  const [isRecurring, setIsRecurring] = useState(false);
  const [recurrenceRule, setRecurrenceRule] = useState('weekly');
  const [coHostSearch, setCoHostSearch] = useState('');
  const [coHostResults, setCoHostResults] = useState<Profile[]>([]);
  const [coHosts, setCoHosts] = useState<Profile[]>([]);
  const [gymId] = useState('');
  const [feeDumbbell, setFeeDumbbell] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');

  const categories = ['strength', 'cardio', 'hiit', 'yoga', 'pilates', 'stretching', 'nutrition_talk', 'q&a', 'challenge', 'other'];
  const equipOptions = ['dumbbells', 'barbell', 'kettlebell', 'resistance bands', 'yoga mat', 'medicine ball', 'jump rope', 'battle ropes', 'box', 'bench'];
  const liveTypes = [
    { value: 'open_sweat', label: 'Open Sweat', icon: Radio, desc: 'Public, free, up to 4 hours' },
    { value: 'buddy_circle', label: 'Buddy Circle', icon: Users, desc: 'Buddies only, up to 2 hours' },
    { value: 'gym_live', label: 'Gym Live', icon: Building2, desc: 'For gym members, scheduled' },
    { value: 'pt_session_live', label: 'PT Session', icon: Dumbbell, desc: 'Personal trainer led session' },
    { value: 'practitioner_live', label: 'Practitioner', icon: Monitor, desc: 'Health & wellness session' },
  ];

  const toggleEquipment = (item: string) => {
    setEquipment((prev) => prev.includes(item) ? prev.filter((e) => e !== item) : [...prev, item]);
  };

  const handleCoHostSearch = async (q: string) => {
    setCoHostSearch(q);
    if (q.length < 2) { setCoHostResults([]); return; }
    try {
      const res = await profilesApi.searchProfiles({ q, limit: 5 });
      setCoHostResults(res.data || []);
    } catch { setCoHostResults([]); }
  };

  const addCoHost = (p: Profile) => {
    if (!coHosts.find((c) => c.user_id === p.user_id)) {
      setCoHosts([...coHosts, p]);
    }
    setCoHostSearch('');
    setCoHostResults([]);
  };

  const removeCoHost = (id: string) => {
    setCoHosts(coHosts.filter((c) => c.user_id !== id));
  };

  const handleStart = async () => {
    if (!title.trim()) return;
    setIsSubmitting(true);
    setSubmitError('');
    try {
      const payload: import('@/api/lives').StartLivePayload = {
        title: title.trim(),
        live_type: liveType,
        category,
        access,
        equipment_list: equipment,
        co_hosts: coHosts.map((c) => c.user_id),
        scheduled_for: scheduledFor || undefined,
        is_recurring: isRecurring,
        recurrence_rule: isRecurring ? recurrenceRule : '',
        gym_id: gymId || undefined,
        artifact_fee: feeDumbbell > 0 ? { dumbbell: feeDumbbell } : undefined,
      };
      const res = await livesApi.startLive(payload);
      onClose();
      navigate(`/live/${res.data.live.id}`);
    } catch (err: any) {
      const msg = err?.response?.data?.message;
      if (err?.response?.status === 409) {
        setSubmitError(msg || 'You already have an active live session. End it first.');
      } else {
        setSubmitError('Failed to start live. Please try again.');
      }
    } finally { setIsSubmitting(false); }
  };

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-buddy-black">
      <div className="flex items-center justify-between p-4 border-b border-buddy-surface">
        <button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">Cancel</button>
        <h2 className="font-heading font-semibold">Start a Buddy Live</h2>
        <Button size="sm" onClick={handleStart} isLoading={isSubmitting} disabled={!title.trim()}>Go Live</Button>
      </div>
      <div className="flex-1 overflow-y-auto p-4 space-y-5 pb-24">
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Title</label>
          <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} maxLength={80}
            placeholder="e.g., Monday Morning HIIT"
            className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Category</label>
          <div className="flex flex-wrap gap-2">
            {categories.map((c) => (
              <button key={c} onClick={() => setCategory(c)}
                className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${
                  category === c ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                }`}
              >{c.replace('_', ' ')}</button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Live Type</label>
          <div className="space-y-2">
            {liveTypes.map(({ value, label, icon: Icon, desc }) => (
              <button key={value} onClick={() => setLiveType(value)}
                className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${
                  liveType === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon size={22} className={liveType === value ? 'text-buddy-green' : 'text-buddy-text-secondary'} />
                  <div>
                    <p className="font-medium text-sm">{label}</p>
                    <p className="text-xs text-buddy-text-secondary">{desc}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Access</label>
          <div className="flex gap-2">
            {[
              { value: 'public', label: 'Public', icon: Globe },
              { value: 'buddies', label: 'Buddies Only', icon: UsersRound },
            ].map(({ value, label, icon: Icon }) => (
              <button key={value} onClick={() => setAccess(value)}
                className={`flex-1 p-3 rounded-xl border-2 text-center transition-colors ${
                  access === value ? 'border-buddy-green bg-buddy-green/5 text-buddy-green' : 'border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                }`}
              >
                <Icon size={18} className="mx-auto mb-1" />
                <p className="text-xs font-medium">{label}</p>
              </button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Equipment Needed</label>
          <div className="flex flex-wrap gap-2">
            {equipOptions.map((item) => (
              <button key={item} onClick={() => toggleEquipment(item)}
                className={`px-3 py-1.5 rounded-full text-xs capitalize transition-colors ${
                  equipment.includes(item) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                }`}
              >{item}</button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Co-hosts</label>
          <div className="relative">
            <div className="flex flex-wrap gap-1 mb-2">
              {coHosts.map((c) => (
                <span key={c.user_id} className="flex items-center gap-1 text-xs bg-buddy-surface px-2 py-1 rounded-full">
                  {c.display_name}
                  <button onClick={() => removeCoHost(c.user_id)} className="hover:text-buddy-red"><X size={12} /></button>
                </span>
              ))}
            </div>
            <div className="relative">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-buddy-text-secondary" />
              <input type="text" value={coHostSearch} onChange={(e) => handleCoHostSearch(e.target.value)}
                placeholder="Search users..."
                className="w-full bg-buddy-surface rounded-xl pl-9 pr-4 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              {coHostResults.length > 0 && (
                <div className="absolute top-full mt-1 left-0 right-0 bg-buddy-surface rounded-xl shadow-lg z-10 border border-buddy-surface-raised overflow-hidden">
                  {coHostResults.map((p) => (
                    <button key={p.user_id} onClick={() => addCoHost(p)}
                      className="flex items-center gap-2 w-full px-3 py-2 text-sm hover:bg-buddy-surface-raised text-left">
                      <Avatar src={p.avatar_url} alt={p.display_name} size="sm" />
                      <span>{p.display_name}</span>
                      <span className="text-buddy-text-secondary text-xs">@{p.username}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Schedule (optional)</label>
          <input type="datetime-local" value={scheduledFor} onChange={(e) => setScheduledFor(e.target.value)}
            className="w-full bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
          {scheduledFor && (
            <label className="flex items-center gap-2 mt-2 text-sm text-buddy-text-secondary cursor-pointer">
              <input type="checkbox" checked={isRecurring} onChange={(e) => setIsRecurring(e.target.checked)} className="accent-buddy-green" />
              <Repeat size={14} /> Repeat
              {isRecurring && (
                <select value={recurrenceRule} onChange={(e) => setRecurrenceRule(e.target.value)}
                  className="bg-buddy-surface rounded-lg px-2 py-1 text-xs text-buddy-text-primary focus:outline-none">
                  <option value="daily">Daily</option>
                  <option value="weekly">Weekly</option>
                  <option value="monthly">Monthly</option>
                </select>
              )}
            </label>
          )}
        </div>
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Entry Fee (optional)</label>
          <div className="flex items-center gap-2">
            <input type="number" min="0" value={feeDumbbell} onChange={(e) => setFeeDumbbell(Math.max(0, parseInt(e.target.value) || 0))}
              placeholder="0"
              className="w-24 bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
            <span className="text-sm text-buddy-text-secondary"><Dumbbell size={14} className="inline mr-1" />Dumbbells</span>
          </div>
        </div>
        {submitError && (
          <div className="flex items-center gap-2 bg-buddy-red/10 border border-buddy-red/20 rounded-xl px-4 py-3 text-sm text-buddy-red">
            <AlertCircle size={16} /> {submitError}
          </div>
        )}
      </div>
    </div>
  );
}

function RandomDropSheet({ onClose }: { onClose: () => void }) {
  const navigate = useNavigate();
  const [step, setStep] = useState<'configure' | 'searching' | 'matched'>('configure');
  const [activityType, setActivityType] = useState('hiit');
  const [duration, setDuration] = useState(30);
  const [countdown, setCountdown] = useState(180);
  const [matchedLiveId, setMatchedLiveId] = useState<string | null>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval>>();

  const activities = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'running', 'cycling', 'other'];

  const handleDropIn = async () => {
    setStep('searching');
    setCountdown(180);
    try {
      await livesApi.startRandomDrop({ activity_type: activityType, duration });
      pollStatus();
    } catch { setStep('configure'); }
  };

  const pollStatus = () => {
    intervalRef.current = setInterval(async () => {
      setCountdown((c) => c - 1);
      try {
        const res = await livesApi.getRandomDropStatus();
        if (res.data?.status === 'matched') {
          clearInterval(intervalRef.current);
          setMatchedLiveId(res.data.live_id || null);
          setStep('matched');
        } else if (res.data?.status === 'not_searching') {
          clearInterval(intervalRef.current);
          setStep('configure');
        }
      } catch {}
    }, 2000);
  };

  useEffect(() => {
    return () => clearInterval(intervalRef.current);
  }, []);

  const handleCancel = () => {
    clearInterval(intervalRef.current);
    livesApi.cancelRandomDrop();
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-buddy-black">
      <div className="flex items-center justify-between p-4 border-b border-buddy-surface">
        <button onClick={handleCancel} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">Cancel</button>
        <h2 className="font-heading font-semibold">Random Drop</h2>
        <div className="w-8" />
      </div>

      <div className="flex-1 flex flex-col items-center justify-center p-6">
        {step === 'configure' && (
          <div className="w-full space-y-6">
            <div className="text-center">
              <Shuffle size={48} className="mx-auto text-buddy-green mb-4" />
              <h3 className="font-heading text-xl font-semibold mt-4">Random Drop</h3>
              <p className="text-buddy-text-secondary text-sm mt-1">Get matched with random workout buddies!</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Activity Type</label>
              <div className="flex flex-wrap gap-2">
                {activities.map((a) => (
                  <button key={a} onClick={() => setActivityType(a)}
                    className={`px-4 py-2 rounded-full text-sm capitalize transition-colors ${
                      activityType === a ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                  >{a}</button>
                ))}
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-2">Duration</label>
              <div className="flex gap-2">
                {[15, 30, 45].map((d) => (
                  <button key={d} onClick={() => setDuration(d)}
                    className={`flex-1 py-3 rounded-xl border-2 text-center transition-colors ${
                      duration === d ? 'border-buddy-green bg-buddy-green/5 text-buddy-green' : 'border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                  >{d} min</button>
                ))}
              </div>
            </div>
            <Button className="w-full" size="lg" onClick={handleDropIn}>
              <Flame size={18} className="mr-2" /> Drop In
            </Button>
            <p className="text-xs text-buddy-text-secondary text-center">
              You'll be matched with 2–15 compatible users. <br />No hosts — everyone's equal.
            </p>
          </div>
        )}

        {step === 'searching' && (
          <div className="text-center space-y-6">
            <div className="relative">
              <div className="w-24 h-24 rounded-full border-4 border-buddy-surface border-t-buddy-green animate-spin mx-auto" />
              <Search size={28} className="absolute inset-0 m-auto text-buddy-text-secondary" />
            </div>
            <div>
              <h3 className="font-heading text-xl font-semibold">Searching for workout buddies…</h3>
              <p className="text-buddy-text-secondary text-sm mt-1">Finding people who match your vibe</p>
            </div>
            <div className="flex items-center gap-2 justify-center">
              <span className="font-mono text-2xl font-bold text-buddy-green">{Math.floor(countdown / 60)}:{(countdown % 60).toString().padStart(2, '0')}</span>
            </div>
            <Button variant="ghost" onClick={handleCancel}>Cancel Search</Button>
          </div>
        )}

        {step === 'matched' && (
          <div className="text-center space-y-6">
            <CheckCircle size={56} className="mx-auto text-buddy-green" />
            <div>
              <h3 className="font-heading text-xl font-semibold text-buddy-green">Match Found!</h3>
              <p className="text-buddy-text-secondary text-sm mt-1">You've been matched with workout buddies!</p>
            </div>
            <Button className="w-full" size="lg" onClick={() => { navigate(`/live/${matchedLiveId}`); }}>Join Session</Button>
            <Button variant="ghost" onClick={() => setStep('configure')}>Start New Search</Button>
          </div>
        )}
      </div>
    </div>
  );
}
