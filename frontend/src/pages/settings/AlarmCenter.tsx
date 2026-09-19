import { useEffect, useRef, useState } from 'react';
import { Loader, Mic, Play, Send, Share2, Square, Trash2, Upload } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Toggle } from '@/components/ui/Toggle';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { alarmsApi, profilesApi } from '@/api';
import type { Alarm, AlarmSound, AlarmSuggestion, SoundShare, SuggestionDecision } from '@/api/alarms';
import type { Profile } from '@/types';
import { useAuthStore } from '@/store/authStore';
import { useVoiceRecorder } from '@/hooks/useVoiceRecorder';
import { MAX_SOUND_MS, playAlarmSound, scheduleAlarm, stopAllAlarms } from '@/lib/alarmPlayer';
import { SectionShell } from './SectionShell';

// ── Day-mask helpers (Mon=1 … Sun=64) ──────────────────────────────────────

export const DAY_LABELS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] as const;

/** Expand a bitmask into 7 booleans, Mon-first. */
export function maskToDays(mask: number): boolean[] {
  return DAY_LABELS.map((_, i) => Boolean(mask & (1 << i)));
}

/** Flip one day-bit (index 0=Mon … 6=Sun). */
export function toggleDayBit(mask: number, index: number): number {
  return mask ^ (1 << index);
}

/** Human summary: "Every day", "Weekdays", "Weekends", "Mon, Wed", "Once". */
export function formatDays(mask: number): string {
  if (mask === 0) return 'Once';
  if (mask === 127) return 'Every day';
  if (mask === 31) return 'Weekdays';
  if (mask === 96) return 'Weekends';
  return DAY_LABELS.filter((_, i) => mask & (1 << i)).join(', ');
}

/** Next Date matching a "HH:MM" time + days mask (mask 0 = next occurrence). */
export function nextFireDate(time: string, daysMask: number, from: Date = new Date()): Date | null {
  const m = /^(\d{1,2}):(\d{2})/.exec(time);
  if (!m) return null;
  const hh = Math.min(23, parseInt(m[1], 10));
  const mm = Math.min(59, parseInt(m[2], 10));
  for (let offset = 0; offset < 8; offset += 1) {
    const d = new Date(from);
    d.setDate(from.getDate() + offset);
    d.setHours(hh, mm, 0, 0);
    if (d <= from) continue;
    if (daysMask === 0) return d;
    const idx = (d.getDay() + 6) % 7; // Mon=0 … Sun=6
    if (daysMask & (1 << idx)) return d;
  }
  return null;
}

const MAX_UPLOAD_BYTES = 10 * 1024 * 1024;

const inputCls =
  'w-full bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none';

/** Best-effort duration probe; resolves 0 when the file can't be measured. */
function probeAudioDurationMs(file: File): Promise<number> {
  return new Promise((resolve) => {
    let settled = false;
    const done = (ms: number) => {
      if (settled) return;
      settled = true;
      URL.revokeObjectURL(url);
      resolve(ms);
    };
    const url = URL.createObjectURL(file);
    try {
      const el = new Audio();
      el.preload = 'metadata';
      el.onloadedmetadata = () => done(Number.isFinite(el.duration) ? el.duration * 1000 : 0);
      el.onerror = () => done(0);
      el.src = url;
      setTimeout(() => done(0), 5000);
    } catch {
      done(0);
    }
  });
}

// ── Small building blocks ──────────────────────────────────────────────────

function SoundPreview({ url, label }: { url: string; label: string }) {
  const [playing, setPlaying] = useState(false);
  const stopRef = useRef<(() => void) | null>(null);

  useEffect(
    () => () => {
      stopRef.current?.();
      stopRef.current = null;
    },
    [],
  );

  const toggle = () => {
    if (playing) {
      stopRef.current?.();
      stopRef.current = null;
      setPlaying(false);
    } else {
      stopAllAlarms();
      stopRef.current = playAlarmSound(url);
      setPlaying(true);
    }
  };

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={playing ? `Stop preview of ${label}` : `Preview ${label}`}
      className="p-2 rounded-full border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary hover:border-buddy-text-secondary/40 transition-colors"
    >
      {playing ? <Square size={14} /> : <Play size={14} />}
    </button>
  );
}

function BuddyPicker({
  buddies,
  value,
  onChange,
  label,
}: {
  buddies: Profile[];
  value: string;
  onChange: (v: string) => void;
  label: string;
}) {
  const matched = buddies.some((b) => b.user_id === value);
  return (
    <div className="space-y-2">
      {buddies.length > 0 ? (
        <select
          aria-label={label}
          value={matched ? value : ''}
          onChange={(e) => onChange(e.target.value)}
          className={inputCls}
        >
          <option value="">Choose a buddy…</option>
          {buddies.map((b) => (
            <option key={b.user_id} value={b.user_id}>
              {b.display_name} (@{b.username})
            </option>
          ))}
        </select>
      ) : (
        <p className="text-xs text-buddy-text-secondary">No buddies yet — paste a profile ID below.</p>
      )}
      <Input
        placeholder="Or paste a profile ID"
        aria-label={`${label} (profile ID)`}
        value={matched ? '' : value}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}

// ── Main page ──────────────────────────────────────────────────────────────

export default function AlarmCenter() {
  const { toast } = useToast();
  const myProfile = useAuthStore((s) => s.profile);

  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [alarms, setAlarms] = useState<Alarm[]>([]);
  const [sounds, setSounds] = useState<AlarmSound[]>([]);
  const [inbox, setInbox] = useState<SoundShare[]>([]);
  const [suggestions, setSuggestions] = useState<AlarmSuggestion[]>([]);
  const [buddies, setBuddies] = useState<Profile[]>([]);
  const [ringing, setRinging] = useState<{ alarmId: string; label: string; time: string } | null>(null);

  // Add-alarm form
  const [newTime, setNewTime] = useState('07:00');
  const [newDays, setNewDays] = useState(127);
  const [newLabel, setNewLabel] = useState('');
  const [newSoundId, setNewSoundId] = useState('');
  const [newSnooze, setNewSnooze] = useState(5);
  const [creating, setCreating] = useState(false);

  // Upload
  const fileRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [uploadName, setUploadName] = useState('');
  const [uploadVisibility, setUploadVisibility] = useState('private');

  // Record
  const recorder = useVoiceRecorder();
  const [recordName, setRecordName] = useState('');
  const [savingRecording, setSavingRecording] = useState(false);

  // Share row
  const [shareOpenFor, setShareOpenFor] = useState<string | null>(null);
  const [shareRecipient, setShareRecipient] = useState('');
  const [sharing, setSharing] = useState(false);

  // Suggestion form
  const [sugRecipient, setSugRecipient] = useState('');
  const [sugTitle, setSugTitle] = useState('');
  const [sugNote, setSugNote] = useState('');
  const [sugUrl, setSugUrl] = useState('');
  const [sendingSug, setSendingSug] = useState(false);

  // ── Load everything ──
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setLoadError(false);
    const username = myProfile?.username;
    Promise.all([
      alarmsApi.getAlarms().then((r) => r.data),
      alarmsApi.getSounds().then((r) => r.data),
      alarmsApi.getSharesInbox().then((r) => r.data),
      alarmsApi.getSuggestions().then((r) => (Array.isArray(r.data) ? r.data : [])),
      username ? profilesApi.getBuddies(username).then((r) => r.data) : Promise.resolve([] as Profile[]),
    ])
      .then(([a, s, inboxShares, sugs, buddyList]) => {
        if (cancelled) return;
        setAlarms(a);
        setSounds(s);
        setInbox(inboxShares);
        setSuggestions(sugs);
        setBuddies(buddyList);
      })
      .catch(() => {
        if (!cancelled) setLoadError(true);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [myProfile?.username]);

  // ── 30s auto-stop for recordings ──
  const { state: recState, durationMs: recMs } = recorder;
  useEffect(() => {
    if (recState === 'recording' && recMs >= MAX_SOUND_MS) recorder.stop();
  }, [recState, recMs, recorder]);

  // ── Ring enabled alarms while this page is open (best-effort) ──
  useEffect(() => {
    if (alarms.length === 0) return;
    const cancels = alarms
      .filter((a) => a.enabled)
      .map((alarm) => {
        const fireAt = nextFireDate(alarm.time, alarm.days_mask);
        if (!fireAt) return () => undefined;
        return scheduleAlarm(fireAt, () => {
          setRinging({ alarmId: alarm.id, label: alarm.label, time: alarm.time });
          playAlarmSound(alarm.sound?.audio_url ?? '');
        });
      });
    return () => {
      cancels.forEach((c) => c());
    };
  }, [alarms]);

  // Never leave audio playing after leaving the page.
  useEffect(() => () => stopAllAlarms(), []);

  // ── Alarms CRUD (optimistic toggle/delete with rollback, like Notifications) ──
  const handleToggleAlarm = async (alarm: Alarm) => {
    const previous = alarms;
    setAlarms((prev) => prev.map((a) => (a.id === alarm.id ? { ...a, enabled: !a.enabled } : a)));
    try {
      const res = await alarmsApi.updateAlarm(alarm.id, { enabled: !alarm.enabled });
      setAlarms((prev) => prev.map((a) => (a.id === alarm.id ? res.data : a)));
    } catch {
      setAlarms(previous);
      toast('error', 'Failed to update alarm');
    }
  };

  const handleDeleteAlarm = async (alarm: Alarm) => {
    const previous = alarms;
    setAlarms((prev) => prev.filter((a) => a.id !== alarm.id));
    try {
      await alarmsApi.deleteAlarm(alarm.id);
      toast('success', 'Alarm deleted');
    } catch {
      setAlarms(previous);
      toast('error', 'Failed to delete alarm');
    }
  };

  const handleCreateAlarm = async () => {
    if (!newTime) {
      toast('error', 'Pick a time for your alarm');
      return;
    }
    setCreating(true);
    try {
      const res = await alarmsApi.createAlarm({
        time: newTime,
        days_mask: newDays,
        label: newLabel.trim() || undefined,
        sound: newSoundId || null,
        enabled: true,
        snooze_minutes: newSnooze,
      });
      setAlarms((prev) => [...prev, res.data]);
      setNewLabel('');
      setNewSoundId('');
      toast('success', 'Alarm set — sleep tight, champ');
    } catch {
      toast('error', 'Failed to create alarm');
    } finally {
      setCreating(false);
    }
  };

  // ── Sounds: upload + record ──
  const handleFilePicked = async (file: File) => {
    if (!file.type.startsWith('audio/')) {
      toast('error', 'That file is not audio — pick a sound file');
      return;
    }
    if (file.size > MAX_UPLOAD_BYTES) {
      toast('error', 'Sound file is too big (max 10 MB)');
      return;
    }
    const durationMs = await probeAudioDurationMs(file);
    if (durationMs > MAX_SOUND_MS) {
      toast('error', `Sound is longer than ${MAX_SOUND_MS / 1000}s — trim it and try again`);
      return;
    }
    setUploading(true);
    try {
      const res = await alarmsApi.uploadSound(file, uploadName.trim() || file.name, uploadVisibility);
      setSounds((prev) => [...prev, res.data]);
      setUploadName('');
      toast('success', 'Sound uploaded');
    } catch {
      toast('error', 'Failed to upload sound');
    } finally {
      setUploading(false);
      if (fileRef.current) fileRef.current.value = '';
    }
  };

  const handleSaveRecording = async () => {
    if (!recorder.audioBlob) return;
    if (recorder.durationMs > MAX_SOUND_MS) {
      toast('error', `Recording is longer than ${MAX_SOUND_MS / 1000}s`);
      return;
    }
    setSavingRecording(true);
    try {
      const file = new File([recorder.audioBlob], `${recordName.trim() || 'alarm-sound'}.webm`, {
        type: recorder.audioBlob.type || 'audio/webm',
      });
      const res = await alarmsApi.uploadSound(file, recordName.trim() || 'My recording', 'private');
      setSounds((prev) => [...prev, res.data]);
      setRecordName('');
      recorder.reset();
      toast('success', 'Recording saved as a sound');
    } catch {
      toast('error', 'Failed to save recording');
    } finally {
      setSavingRecording(false);
    }
  };

  // ── Shares ──
  const handleShareSound = async (soundId: string) => {
    if (!shareRecipient.trim()) {
      toast('error', 'Choose a buddy to share with');
      return;
    }
    setSharing(true);
    try {
      await alarmsApi.shareSound(soundId, shareRecipient.trim());
      setShareOpenFor(null);
      setShareRecipient('');
      toast('success', 'Sound shared');
    } catch {
      toast('error', 'Failed to share sound');
    } finally {
      setSharing(false);
    }
  };

  const handleRespondShare = async (share: SoundShare, accept: boolean) => {
    const previous = inbox;
    setInbox((prev) => prev.filter((s) => s.id !== share.id));
    try {
      const res = await alarmsApi.respondToShare(share.id, accept);
      const sound = res.data?.sound ?? share.sound;
      if (accept && sound) {
        setSounds((prev) => (prev.some((s) => s.id === sound.id) ? prev : [...prev, sound]));
        toast('success', 'Sound added to your collection');
      } else {
        toast('success', accept ? 'Share accepted' : 'Share declined');
      }
    } catch {
      setInbox(previous);
      toast('error', 'Failed to respond to share');
    }
  };

  // ── Suggestions ──
  const handleSendSuggestion = async () => {
    if (!sugRecipient.trim() || !sugTitle.trim()) {
      toast('error', 'Pick a buddy and give your suggestion a title');
      return;
    }
    if (sugUrl.trim() && !/^https?:\/\//i.test(sugUrl.trim())) {
      toast('error', 'Link must start with http:// or https://');
      return;
    }
    setSendingSug(true);
    try {
      await alarmsApi.sendSuggestion({
        recipient_profile_id: sugRecipient.trim(),
        title: sugTitle.trim(),
        note: sugNote.trim() || undefined,
        url: sugUrl.trim() || undefined,
      });
      setSugRecipient('');
      setSugTitle('');
      setSugNote('');
      setSugUrl('');
      toast('success', 'Suggestion sent');
    } catch {
      toast('error', 'Failed to send suggestion');
    } finally {
      setSendingSug(false);
    }
  };

  const handleRespondSuggestion = async (id: string, decision: SuggestionDecision) => {
    const previous = suggestions;
    setSuggestions((prev) => prev.filter((s) => s.id !== id));
    try {
      await alarmsApi.respondToSuggestion(id, decision);
      toast('success', decision === 'accept' ? 'Suggestion accepted' : decision === 'decline' ? 'Suggestion declined' : 'Suggestion dismissed');
    } catch {
      setSuggestions(previous);
      toast('error', 'Failed to respond');
    }
  };

  const mySounds = sounds.filter((s) => s.is_mine);

  return (
    <SectionShell title="Alarm Center">
      {loading ? (
        <Card className="p-8 text-center">
          <Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" />
        </Card>
      ) : loadError ? (
        <Card className="p-8 text-center space-y-3">
          <p className="text-sm text-buddy-text-secondary">Could not load your alarms.</p>
          <Button variant="outline" size="sm" onClick={() => window.location.reload()}>
            Try Again
          </Button>
        </Card>
      ) : (
        <div className="space-y-4">
          {ringing && (
            <Card className="p-4 border border-buddy-green/50 space-y-2" role="alert">
              <p className="font-heading text-sm font-semibold">
                Ringing: {ringing.time}
                {ringing.label ? ` — ${ringing.label}` : ''}
              </p>
              <p className="text-xs text-buddy-text-secondary">Your alarm is going off. Rise and grind!</p>
              <Button
                size="sm"
                onClick={() => {
                  stopAllAlarms();
                  setRinging(null);
                }}
              >
                <Square size={14} /> Stop
              </Button>
            </Card>
          )}

          {/* (a) My alarms */}
          <Card className="p-4 space-y-4">
            <h3 className="font-heading text-sm font-semibold">My alarms</h3>
            {alarms.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">No alarms yet — set your first one below.</p>
            ) : (
              <ul className="space-y-3">
                {alarms.map((alarm) => (
                  <li key={alarm.id} className="flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-sm font-semibold">
                        {alarm.time}
                        {alarm.label ? <span className="font-normal text-buddy-text-secondary"> — {alarm.label}</span> : null}
                      </p>
                      <p className="text-xs text-buddy-text-secondary">
                        {formatDays(alarm.days_mask)}
                        {alarm.sound ? ` · ${alarm.sound.name}` : ' · Default sound'}
                        {` · Snooze ${alarm.snooze_minutes}m`}
                      </p>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Toggle
                        checked={alarm.enabled}
                        onCheckedChange={() => handleToggleAlarm(alarm)}
                        label={`Enable alarm at ${alarm.time}`}
                      />
                      <button
                        type="button"
                        onClick={() => handleDeleteAlarm(alarm)}
                        aria-label={`Delete alarm at ${alarm.time}`}
                        className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-red transition-colors"
                      >
                        <Trash2 size={15} />
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
            <div className="pt-2 border-t border-buddy-surface space-y-3">
              <p className="text-xs font-semibold text-buddy-text-secondary">New alarm</p>
              <div className="flex items-center gap-3">
                <label className="space-y-1">
                  <span className="text-xs text-buddy-text-secondary">Time</span>
                  <input
                    type="time"
                    value={newTime}
                    onChange={(e) => setNewTime(e.target.value)}
                    className="bg-buddy-surface-raised text-sm rounded-lg px-3 py-2 border border-buddy-surface text-buddy-text-primary outline-none"
                  />
                </label>
                <label className="space-y-1 w-24">
                  <span className="text-xs text-buddy-text-secondary">Snooze (min)</span>
                  <input
                    type="number"
                    min={1}
                    max={30}
                    value={newSnooze}
                    onChange={(e) => setNewSnooze(Math.min(30, Math.max(1, Number(e.target.value) || 1)))}
                    className={inputCls}
                  />
                </label>
              </div>
              <div className="flex flex-wrap gap-1.5" role="group" aria-label="Repeat days">
                {DAY_LABELS.map((day, i) => {
                  const active = Boolean(newDays & (1 << i));
                  return (
                    <button
                      key={day}
                      type="button"
                      aria-pressed={active}
                      aria-label={`Repeat on ${day}`}
                      onClick={() => setNewDays((m) => toggleDayBit(m, i))}
                      className={`px-2.5 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                        active
                          ? 'bg-buddy-green text-buddy-black'
                          : 'border border-buddy-surface text-buddy-text-secondary hover:border-buddy-text-secondary/40'
                      }`}
                    >
                      {day}
                    </button>
                  );
                })}
              </div>
              <Input placeholder="Label (optional, e.g. Leg day)" value={newLabel} onChange={(e) => setNewLabel(e.target.value)} aria-label="Alarm label" />
              <label className="block space-y-1">
                <span className="text-xs text-buddy-text-secondary">Sound</span>
                <select aria-label="Alarm sound" value={newSoundId} onChange={(e) => setNewSoundId(e.target.value)} className={inputCls}>
                  <option value="">Default sound</option>
                  {sounds.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                      {s.is_mine ? '' : ' (shared)'}
                    </option>
                  ))}
                </select>
              </label>
              <Button size="sm" onClick={handleCreateAlarm} isLoading={creating}>
                Set alarm
              </Button>
            </div>
          </Card>

          {/* (b) My sounds */}
          <Card className="p-4 space-y-4">
            <h3 className="font-heading text-sm font-semibold">My sounds</h3>
            <div className="space-y-2">
              <Input placeholder="Sound name (optional)" value={uploadName} onChange={(e) => setUploadName(e.target.value)} aria-label="Uploaded sound name" />
              <div className="flex items-center gap-2">
                <label className="flex-1 space-y-1">
                  <span className="text-xs text-buddy-text-secondary">Who can see it</span>
                  <select aria-label="Sound visibility" value={uploadVisibility} onChange={(e) => setUploadVisibility(e.target.value)} className={inputCls}>
                    <option value="private">Just me</option>
                    <option value="buddies">My buddies</option>
                    <option value="public">Everyone</option>
                  </select>
                </label>
                <div className="pt-5">
                  <Button size="sm" variant="outline" onClick={() => fileRef.current?.click()} isLoading={uploading}>
                    <Upload size={14} /> Upload
                  </Button>
                </div>
              </div>
              <input
                ref={fileRef}
                type="file"
                accept="audio/*"
                className="hidden"
                aria-label="Choose an audio file"
                onChange={(e) => {
                  const f = e.target.files?.[0];
                  if (f) void handleFilePicked(f);
                }}
              />
              <p className="text-[11px] text-buddy-text-secondary">Max {MAX_SOUND_MS / 1000}s and 10 MB — short and punchy wakes you up best.</p>
            </div>
            <div className="pt-2 border-t border-buddy-surface space-y-2">
              <p className="text-xs font-semibold text-buddy-text-secondary">Record a sound (max {MAX_SOUND_MS / 1000}s)</p>
              <div className="flex items-center gap-2">
                {recState === 'recording' ? (
                  <Button size="sm" variant="destructive" onClick={recorder.stop}>
                    <Square size={14} /> Stop ({Math.floor(recMs / 1000)}s)
                  </Button>
                ) : recState === 'done' ? (
                  <>
                    <Button size="sm" variant="outline" onClick={recorder.reset}>
                      Discard
                    </Button>
                    <Button size="sm" onClick={() => void handleSaveRecording()} isLoading={savingRecording} disabled={!recorder.audioBlob}>
                      Save
                    </Button>
                  </>
                ) : (
                  <Button size="sm" variant="outline" onClick={() => void recorder.start()}>
                    <Mic size={14} /> Record
                  </Button>
                )}
                {recorder.audioUrl && (
                  <audio src={recorder.audioUrl} controls className="h-8 max-w-[180px]" aria-label="Recording preview" />
                )}
              </div>
              {recState === 'done' && (
                <Input placeholder="Recording name (optional)" value={recordName} onChange={(e) => setRecordName(e.target.value)} aria-label="Recording name" />
              )}
            </div>
            {mySounds.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">No custom sounds yet — upload or record your wake-up anthem.</p>
            ) : (
              <ul className="space-y-3">
                {mySounds.map((sound) => (
                  <li key={sound.id} className="space-y-2">
                    <div className="flex items-center justify-between gap-3">
                      <div className="min-w-0">
                        <p className="text-sm truncate">{sound.name}</p>
                        <p className="text-xs text-buddy-text-secondary">
                          {sound.duration_ms != null ? `${Math.round(sound.duration_ms / 1000)}s · ` : ''}
                          {sound.visibility}
                        </p>
                      </div>
                      <div className="flex items-center gap-1 flex-shrink-0">
                        <SoundPreview url={sound.audio_url} label={sound.name} />
                        <button
                          type="button"
                          onClick={() => setShareOpenFor((cur) => (cur === sound.id ? null : sound.id))}
                          aria-label={`Share ${sound.name}`}
                          className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
                        >
                          <Share2 size={14} />
                        </button>
                      </div>
                    </div>
                    {shareOpenFor === sound.id && (
                      <div className="space-y-2 pl-1">
                        <BuddyPicker buddies={buddies} value={shareRecipient} onChange={setShareRecipient} label={`Share ${sound.name} with`} />
                        <Button size="sm" variant="outline" onClick={() => void handleShareSound(sound.id)} isLoading={sharing}>
                          <Send size={14} /> Send sound
                        </Button>
                      </div>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </Card>

          {/* (c) Shared with me */}
          <Card className="p-4 space-y-3">
            <h3 className="font-heading text-sm font-semibold">Shared with me</h3>
            {inbox.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">Nothing shared yet — your buddies are holding out on you.</p>
            ) : (
              <ul className="space-y-3">
                {inbox.map((share) => (
                  <li key={share.id} className="flex items-center justify-between gap-3">
                    <div className="min-w-0 flex items-center gap-2">
                      <SoundPreview url={share.sound.audio_url} label={share.sound.name} />
                      <div className="min-w-0">
                        <p className="text-sm truncate">{share.sound.name}</p>
                        <p className="text-xs text-buddy-text-secondary">
                          from {share.sender.display_name || share.sender.username || 'a buddy'}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Button size="sm" onClick={() => void handleRespondShare(share, true)}>
                        Accept
                      </Button>
                      <Button size="sm" variant="ghost" onClick={() => void handleRespondShare(share, false)}>
                        Decline
                      </Button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </Card>

          {/* (d) Suggestions */}
          <Card className="p-4 space-y-4">
            <h3 className="font-heading text-sm font-semibold">Suggestions</h3>
            {suggestions.length === 0 ? (
              <p className="text-xs text-buddy-text-secondary">No suggestions right now.</p>
            ) : (
              <ul className="space-y-3">
                {suggestions.map((sug) => (
                  <li key={sug.id} className="space-y-1">
                    <p className="text-sm font-medium">{sug.title}</p>
                    {sug.note ? <p className="text-xs text-buddy-text-secondary">{sug.note}</p> : null}
                    <p className="text-xs text-buddy-text-secondary">
                      {sug.sender?.display_name || sug.sender?.username ? `from ${sug.sender.display_name || sug.sender.username} · ` : ''}
                      {sug.url ? (
                        <a href={sug.url} target="_blank" rel="noreferrer" className="text-buddy-green hover:text-buddy-green-deep underline">
                          Open link
                        </a>
                      ) : (
                        sug.status
                      )}
                    </p>
                    <div className="flex items-center gap-2">
                      <Button size="sm" variant="outline" onClick={() => void handleRespondSuggestion(sug.id, 'accept')}>
                        Accept
                      </Button>
                      <Button size="sm" variant="ghost" onClick={() => void handleRespondSuggestion(sug.id, 'decline')}>
                        Decline
                      </Button>
                      <Button size="sm" variant="ghost" onClick={() => void handleRespondSuggestion(sug.id, 'dismiss')}>
                        Dismiss
                      </Button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
            <div className="pt-2 border-t border-buddy-surface space-y-2">
              <p className="text-xs font-semibold text-buddy-text-secondary">Send a suggestion</p>
              <BuddyPicker buddies={buddies} value={sugRecipient} onChange={setSugRecipient} label="Suggestion recipient" />
              <Input placeholder="Title (e.g. Try this sunrise alarm)" value={sugTitle} onChange={(e) => setSugTitle(e.target.value)} aria-label="Suggestion title" />
              <Input placeholder="Note (optional)" value={sugNote} onChange={(e) => setSugNote(e.target.value)} aria-label="Suggestion note" />
              <Input placeholder="Link (optional, https://…)" value={sugUrl} onChange={(e) => setSugUrl(e.target.value)} aria-label="Suggestion link" />
              <Button size="sm" onClick={() => void handleSendSuggestion()} isLoading={sendingSug}>
                <Send size={14} /> Send suggestion
              </Button>
            </div>
          </Card>

          {/* (e) How alarms work */}
          <Card className="p-4 space-y-2">
            <h3 className="font-heading text-sm font-semibold">How alarms work</h3>
            <p className="text-xs text-buddy-text-secondary leading-relaxed">
              Your alarms ring while the app (or at least this tab) is open and your device allows sound — keep a tab
              open overnight and your volume up, champ. Exact background timing on mobile web is best-effort: browsers
              love to nap background tabs to save battery, so for mission-critical wake-ups (races, flights, leg day
              PRs) keep a backup alarm on your phone clock too. We keep it honest so you never miss what matters.
            </p>
          </Card>
        </div>
      )}
    </SectionShell>
  );
}
