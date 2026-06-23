import { useState, useEffect, useCallback } from 'react';
import { Radio, Calendar, Play, Clock, Users, Dumbbell, Flame } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { livesApi } from '@/api/lives';
import type { BuddyLive } from '@/types/live';

type Tab = 'live' | 'upcoming' | 'replays';

export default function Lives() {
  const [tab, setTab] = useState<Tab>('live');
  const [lives, setLives] = useState<BuddyLive[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showStartLive, setShowStartLive] = useState(false);
  const [showRandomDrop, setShowRandomDrop] = useState(false);

  const fetchLives = useCallback(async (t: Tab) => {
    setIsLoading(true);
    try {
      const res = await livesApi.browse({ tab: t === 'upcoming' ? 'scheduled' : t });
      setLives(res.data || []);
    } catch {} finally {
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
            <Card key={live.id} className="p-4 hover:bg-buddy-surface-raised transition-colors cursor-pointer">
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
                      <Button size="sm" className="ml-auto">Join</Button>
                    )}
                    {live.status === 'scheduled' && (
                      <Button size="sm" variant="outline" className="ml-auto">RSVP</Button>
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
    </div>
  );
}

function StartLiveSheet({ onClose }: { onClose: () => void }) {
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('strength');
  const [liveType, setLiveType] = useState('open_sweat');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const categories = ['strength', 'cardio', 'hiit', 'yoga', 'pilates', 'stretching', 'nutrition_talk', 'q&a', 'challenge', 'other'];
  const liveTypes = [
    { value: 'open_sweat', label: 'Open Sweat', emoji: '🏋️', desc: 'Public, free, up to 4 hours' },
    { value: 'buddy_circle', label: 'Buddy Circle', emoji: '🤝', desc: 'Buddies only, up to 2 hours' },
  ];

  const handleStart = async () => {
    if (!title.trim()) return;
    setIsSubmitting(true);
    try {
      await livesApi.startLive({ title: title.trim(), live_type: liveType, category });
      onClose();
    } catch {} finally { setIsSubmitting(false); }
  };

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-buddy-black">
      <div className="flex items-center justify-between p-4 border-b border-buddy-surface">
        <button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">Cancel</button>
        <h2 className="font-heading font-semibold">Start a Buddy Live</h2>
        <Button size="sm" onClick={handleStart} isLoading={isSubmitting} disabled={!title.trim()}>Go Live</Button>
      </div>
      <div className="flex-1 overflow-y-auto p-4 space-y-5">
        <div>
          <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Title</label>
          <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} maxLength={80}
            placeholder="e.g., Monday Morning HIIT 💪"
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
            {liveTypes.map(({ value, label, emoji, desc }) => (
              <button key={value} onClick={() => setLiveType(value)}
                className={`w-full p-4 rounded-xl border-2 text-left transition-colors ${
                  liveType === value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface hover:border-buddy-text-secondary/30'
                }`}
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{emoji}</span>
                  <div>
                    <p className="font-medium text-sm">{label}</p>
                    <p className="text-xs text-buddy-text-secondary">{desc}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function RandomDropSheet({ onClose }: { onClose: () => void }) {
  const [step, setStep] = useState<'configure' | 'searching' | 'matched'>('configure');
  const [activityType, setActivityType] = useState('hiit');
  const [duration, setDuration] = useState(30);
  const [countdown, setCountdown] = useState(180);

  const activities = ['weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit', 'running', 'cycling', 'other'];

  const handleDropIn = async () => {
    setStep('searching');
    setCountdown(180);
    try {
      await livesApi.startRandomDrop({ activity_type: activityType, duration });
      pollStatus();
    } catch { setStep('configure'); }
  };

  const pollStatus = async () => {
    const interval = setInterval(async () => {
      setCountdown((c) => c - 1);
      try {
        const res = await livesApi.getRandomDropStatus();
        if (res.data?.status === 'matched') {
          clearInterval(interval);
          setStep('matched');
        } else if (res.data?.status === 'not_searching') {
          clearInterval(interval);
          setStep('configure');
        }
      } catch {}
    }, 2000);
  };

  const handleCancel = () => {
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
              <span className="text-6xl">🎲</span>
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
              <span className="text-4xl absolute inset-0 flex items-center justify-center">🔍</span>
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
            <span className="text-6xl">🎉</span>
            <div>
              <h3 className="font-heading text-xl font-semibold text-buddy-green">Match Found!</h3>
              <p className="text-buddy-text-secondary text-sm mt-1">You've been matched with workout buddies!</p>
            </div>
            <Button className="w-full" size="lg">Join Session</Button>
            <Button variant="ghost" onClick={() => setStep('configure')}>Start New Search</Button>
          </div>
        )}
      </div>
    </div>
  );
}
