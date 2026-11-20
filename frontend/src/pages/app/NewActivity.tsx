import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  ArrowLeft, Activity as ActivityIcon, Footprints, Navigation, Timer, Mountain,
  Bike, Play, Square, Save, Trash2, MapPin, Loader2, Moon, RotateCcw,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { RouteMap } from '@/components/analytics/RouteMap';
import { useToast } from '@/components/ui/Toast';
import { useActivityTracker, type TrackerType } from '@/hooks/useActivityTracker';
import { activityMetrics, activityLabel } from '@/lib/activityMetrics';
import {
  checkpointAgeLabel, clearActivityCheckpoint, loadActivityCheckpoint, saveActivityCheckpoint,
  type ActivityCheckpoint,
} from '@/lib/activityCheckpoint';
import { analyticsApi } from '@/api/analytics';
import { track } from '@/lib/analytics';
import { enqueueActivity, isRetryableActivityError, newActivityClientId, removeQueuedActivity } from '@/lib/offlineActivities';
import { useAuthStore } from '@/store/authStore';
import { ActivityQueueBanner } from '@/components/analytics/ActivityQueueBanner';
import type { ActivityRecordInput } from '@/types/analytics';

const TYPES: { key: TrackerType; label: string; icon: typeof Footprints; hint: string }[] = [
  { key: 'walk', label: 'Walk', icon: Footprints, hint: 'Steps and pace' },
  { key: 'run', label: 'Run', icon: ActivityIcon, hint: 'Pace and speed' },
  { key: 'hike', label: 'Hike', icon: Mountain, hint: 'Distance and ascent' },
  { key: 'cycle', label: 'Cycle', icon: Bike, hint: 'Speed and distance' },
];

/**
 * Start and save an activity.
 *
 * A dedicated page, so a session has room: the route is drawn on a map
 * that follows you while you move, and the numbers on screen are the ones
 * that matter for the kind of activity being done.
 */
export default function NewActivity() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [searchParams] = useSearchParams();
  const tracker = useActivityTracker('run');
  const { state, setType, start, stop, reset, resume, buildPayload, estimateSteps, wakeLockActive, wakeLockSupported } = tracker;

  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState<ActivityRecordInput | null>(null);
  const [savedId, setSavedId] = useState<string | null>(null);
  const [queuedId, setQueuedId] = useState<string | null>(null);
  const [notes, setNotes] = useState('');
  const [resumePrompt, setResumePrompt] = useState<ActivityCheckpoint | null>(null);

  // The live session, readable from the checkpoint interval without making
  // it restart on every timer tick or GPS fix.
  const latestRef = useRef({
    type: state.type,
    elapsed: state.elapsed,
    distanceM: state.distanceM,
    steps: state.steps,
    points: state.points,
  });
  latestRef.current = {
    type: state.type,
    elapsed: state.elapsed,
    distanceM: state.distanceM,
    steps: state.steps,
    points: state.points,
  };
  const startedAtRef = useRef(new Date().toISOString());

  /** Persist the live session (route included) to localStorage. */
  const persistCheckpoint = () => {
    const ownerId = useAuthStore.getState().user?.id;
    if (!ownerId) return;
    const live = latestRef.current;
    if (live.elapsed <= 0 && live.points.length === 0) return;
    saveActivityCheckpoint({
      version: 1,
      ownerId,
      type: live.type,
      startedAt: startedAtRef.current,
      elapsed: live.elapsed,
      distanceM: live.distanceM,
      steps: live.steps,
      points: live.points,
      lastUpdated: Date.now(),
    });
  };

  // Offer to continue an interrupted session (dead battery, closed tab, OS
  // freezing a background tab). Checkpoints belong to the signed-in account.
  useEffect(() => {
    const ownerId = useAuthStore.getState().user?.id;
    if (!ownerId) return;
    const checkpoint = loadActivityCheckpoint(ownerId);
    if (checkpoint) setResumePrompt(checkpoint);
  }, []);

  // Checkpoint every 10s and whenever the page is hidden or unloaded. A
  // locked phone freezes the tab without a chance to run cleanup code, so
  // the periodic write is the one that matters.
  useEffect(() => {
    if (!state.tracking) return;
    persistCheckpoint();
    const id = window.setInterval(persistCheckpoint, 10_000);
    const onVisibility = () => {
      if (document.visibilityState === 'hidden') persistCheckpoint();
    };
    window.addEventListener('pagehide', persistCheckpoint);
    document.addEventListener('visibilitychange', onVisibility);
    return () => {
      window.clearInterval(id);
      window.removeEventListener('pagehide', persistCheckpoint);
      document.removeEventListener('visibilitychange', onVisibility);
    };
  // persistCheckpoint reads live values from latestRef by design.
  }, [state.tracking]);

  // The kind and the target come from the page the user came from.
  const requestedType = searchParams.get('type');
  const targetParam = searchParams.get('target');

  useEffect(() => {
    if (requestedType && ['walk', 'run', 'hike', 'cycle'].includes(requestedType)) {
      setType(requestedType as TrackerType);
    }
  }, [requestedType, setType]);

  const liveRoute = useMemo(
    () => state.points.map((p) => [p.lat, p.lng, p.ts]),
    [state.points],
  );

  // The numbers on screen are the ones that matter for this kind.
  const metrics = useMemo(
    () => activityMetrics({
      activity_type: state.type,
      duration_seconds: state.elapsed,
      distance_meters: state.distanceM,
      calories_burned: state.tracking || state.elapsed > 0
        ? Math.round(state.type === 'cycle'
          ? Math.max(15, state.distanceM * 0.03)
          : Math.max(8, state.distanceM * 0.06))
        : null,
      steps: state.type === 'walk' ? estimateSteps() : null,
    }, 4),
    [state.type, state.elapsed, state.distanceM, state.tracking, estimateSteps],
  );

  const hasSession = state.elapsed > 0 || state.points.length > 0;

  // The target the user picked on the way in, and how far along they are.
  const target = useMemo(() => {
    const value = Number(targetParam);
    if (!Number.isFinite(value) || value <= 0) return null;
    const unit = state.type === 'walk' ? 'steps' : state.type === 'cycle' ? 'km' : 'km';
    return { value, unit };
  }, [targetParam, state.type]);

  const targetProgress = useMemo(() => {
    if (!target) return null;
    const reached = target.unit === 'steps'
      ? estimateSteps()
      : state.distanceM / 1000;
    return Math.min(100, Math.round((reached / target.value) * 100));
  }, [target, estimateSteps, state.distanceM]);

  const handleStopAndSave = async () => {
    // Flush the final state before the tracker zeroes itself, so a failed
    // save still leaves the full session resumable.
    persistCheckpoint();
    stop();
    if (state.elapsed <= 0) {
      clearActivityCheckpoint(useAuthStore.getState().user?.id);
      reset();
      return;
    }
    setSaving(true);
    const ownerId = useAuthStore.getState().user?.id;
    const clientId = newActivityClientId();
    const payload: ActivityRecordInput = {
      ...buildPayload(),
      started_at: startedAtRef.current,
      source_event_id: clientId,
      ...(notes.trim() ? { notes: notes.trim() } : {}),
    };
    try {
      const res = await analyticsApi.createActivity(payload);
      setSaved(payload);
      setSavedId((res.data as { id?: string } | undefined)?.id ?? null);
      clearActivityCheckpoint(ownerId);
      track('activity.saved', { surface: 'activities_new', properties: { activity_type: payload.activity_type } });
      toast('success', 'Activity saved.');
    } catch (error) {
      // The server never answered (offline, timeout, flaky network): keep the
      // full session on the device and replay it when the connection returns.
      const unreachable = (typeof navigator !== 'undefined' && navigator.onLine === false)
        || isRetryableActivityError(error);
      if (unreachable && ownerId) {
        try {
          await enqueueActivity(payload, ownerId);
          setSaved(payload);
          setSavedId(null);
          setQueuedId(clientId);
          clearActivityCheckpoint(ownerId);
          track('activity.queued_offline', { surface: 'activities_new', properties: { activity_type: payload.activity_type } });
          toast('info', 'Saved on this device. It will upload when you are back online.');
          return;
        } catch {
          // Storage refused too — report the honest failure below.
        }
      }
      // Keep the checkpoint: tapping save again can upload it without
      // re-walking the route.
      toast('error', 'Could not save the activity. Your session is still here — try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleUndo = async () => {
    if (queuedId) {
      try {
        await removeQueuedActivity(queuedId);
        setSaved(null);
        setQueuedId(null);
        toast('success', 'Activity removed.');
      } catch {
        toast('error', 'Could not remove the activity.');
      }
      return;
    }
    if (!savedId) {
      setSaved(null);
      return;
    }
    try {
      await analyticsApi.deleteActivity(savedId);
      setSaved(null);
      setSavedId(null);
      toast('success', 'Activity removed.');
    } catch {
      toast('error', 'Could not remove the activity.');
    }
  };

  const handleDiscard = () => {
    clearActivityCheckpoint(useAuthStore.getState().user?.id);
    reset();
    setSaved(null);
    setSavedId(null);
    setQueuedId(null);
    setNotes('');
  };

  const handleStartFresh = () => {
    if (resumePrompt) {
      clearActivityCheckpoint(useAuthStore.getState().user?.id);
      setResumePrompt(null);
    }
    startedAtRef.current = new Date().toISOString();
    start();
  };

  const handleResumeCheckpoint = () => {
    if (!resumePrompt) return;
    startedAtRef.current = resumePrompt.startedAt;
    resume({
      type: resumePrompt.type,
      elapsed: resumePrompt.elapsed,
      distanceM: resumePrompt.distanceM,
      steps: resumePrompt.steps,
      points: resumePrompt.points,
    });
    setResumePrompt(null);
    toast('info', 'Session resumed. Keep going.');
  };

  const handleDiscardCheckpoint = () => {
    clearActivityCheckpoint(useAuthStore.getState().user?.id);
    setResumePrompt(null);
  };

  // A saved session can be shared straight away.
  const handleShare = async () => {
    if (!savedId) return;
    try {
      await analyticsApi.sharePrepare({ kind: 'activity', obj_id: savedId, visibility: 'public' });
      navigate('/activities');
    } catch {
      toast('error', 'Could not prepare the activity for sharing.');
    }
  };

  useEffect(() => {
    if (saved) {
      // The route is drawn from the saved session.
      return;
    }
  }, [saved]);

  return (
    <div className="p-4 max-w-3xl mx-auto space-y-4">
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/activities')}
          aria-label="Back to activities"
          className="p-2 rounded-full bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="flex-1 min-w-0">
          <h1 className="font-display text-2xl font-extrabold">New activity</h1>
          <p className="text-sm text-buddy-text-secondary">
            {queuedId
              ? 'Saved on this device. It uploads automatically when you reconnect.'
              : saved
                ? 'Saved. Share it, or record another.'
                : 'Pick what you are doing, then start.'}
          </p>
        </div>
        {saved && savedId && (
          <Button size="sm" variant="outline" onClick={handleShare}>
            Share
          </Button>
        )}
      </div>

      <ActivityQueueBanner />

      {/* Interrupted session — resume the exact route instead of starting over. */}
      {resumePrompt && !state.tracking && !saved && (
        <Card className="p-4 border-buddy-green/40 bg-buddy-green/5">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-buddy-green/15 text-buddy-green flex items-center justify-center shrink-0">
              <RotateCcw size={18} />
            </div>
            <div className="flex-1 min-w-0">
              <h2 className="font-heading font-semibold">Resume your {activityLabel(resumePrompt.type).toLowerCase()}?</h2>
              <p className="text-sm text-buddy-text-secondary mt-0.5">
                {(resumePrompt.distanceM / 1000).toFixed(2)} km ·{' '}
                {Math.floor(resumePrompt.elapsed / 60)} min · {resumePrompt.points.length} route points
              </p>
              <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                Last checkpoint {checkpointAgeLabel(resumePrompt)}. The route is stored on this device.
              </p>
            </div>
          </div>
          <div className="flex gap-2 mt-3">
            <Button size="sm" className="flex-1" onClick={handleResumeCheckpoint}>
              <Play size={14} className="mr-1.5" /> Resume
            </Button>
            <Button size="sm" variant="outline" className="flex-1" onClick={handleDiscardCheckpoint}>
              <Trash2 size={14} className="mr-1.5" /> Discard
            </Button>
          </div>
        </Card>
      )}

      {/* The kind of activity — it decides which numbers matter. */}
      <Card className="p-4">
        <div className="flex flex-wrap gap-2">
          {TYPES.map(({ key, label, icon: Icon, hint }) => {
            const active = state.type === key;
            return (
              <button
                key={key}
                disabled={state.tracking}
                onClick={() => setType(key)}
                className={`flex items-center gap-2 px-3 py-2 rounded-xl border transition-colors disabled:opacity-50 ${
                  active
                    ? 'bg-buddy-green text-buddy-black border-buddy-green font-medium'
                    : 'bg-buddy-surface border-buddy-border text-buddy-text-secondary hover:border-buddy-green/50'
                }`}
              >
                <Icon size={16} />
                <span className="text-sm">{label}</span>
                <span className={`text-[11px] ${active ? 'text-buddy-black/70' : 'text-buddy-text-secondary/70'}`}>
                  {hint}
                </span>
              </button>
            );
          })}
        </div>
      </Card>

      {/* The live map — it follows you while the session runs. */}
      <Card className="p-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-heading font-semibold flex items-center gap-2">
            <MapPin size={16} className="text-buddy-green" /> Route
          </h2>
          <span
            className={`inline-flex items-center gap-1.5 text-xs font-medium px-2 py-1 rounded-full ${
              state.tracking
                ? 'bg-buddy-red/15 text-buddy-red'
                : 'bg-buddy-surface-raised text-buddy-text-secondary'
            }`}
          >
            <span className={`w-1.5 h-1.5 rounded-full ${state.tracking ? 'bg-buddy-red animate-pulse' : 'bg-buddy-text-secondary/40'}`} />
            {state.tracking ? 'Tracking' : saved ? 'Saved' : 'Idle'}
          </span>
        </div>

        {state.tracking && (
          <div className="flex items-center gap-2 mb-3 text-xs">
            <span
              className={`inline-flex items-center gap-1.5 px-2 py-1 rounded-full font-medium ${
                state.gpsFix
                  ? 'bg-buddy-green/10 text-buddy-green'
                  : 'bg-buddy-gold/10 text-buddy-gold animate-pulse'
              }`}
            >
              <Navigation size={11} />
              {state.gpsFix ? `GPS locked ±${state.gpsAccuracy ?? '?'} m` : 'Acquiring GPS…'}
            </span>
            {state.type === 'walk' && state.steps > 0 && (
              <span className="inline-flex items-center gap-1.5 px-2 py-1 rounded-full bg-buddy-surface-raised text-buddy-text-secondary">
                <Footprints size={11} /> {state.steps} steps
              </span>
            )}
          </div>
        )}

        {state.tracking && (
          <p className="mb-3 text-[11px] text-buddy-text-secondary flex items-center gap-1.5">
            {wakeLockSupported && wakeLockActive ? (
              <>
                <Moon size={11} className="text-buddy-green" />
                Screen stays awake while tracking. If you switch apps, GPS may pause — finish the session here.
              </>
            ) : wakeLockSupported ? (
              <>
                <Moon size={11} className="text-buddy-gold" />
                Screen kept awake not available — keep this page in the foreground, GPS suspends in background tabs.
              </>
            ) : (
              <>
                <Moon size={11} className="text-buddy-gold" />
                Your browser doesn't support keeping the screen awake — keep this page in the foreground while tracking.
              </>
            )}
          </p>
        )}

        <RouteMap route={liveRoute} height={280} follow={state.tracking} />
      </Card>

      {/* The numbers that matter for this kind of activity. */}
      <Card className="p-4">
        <h2 className="font-heading font-semibold mb-3 flex items-center gap-2">
          <Timer size={16} className="text-buddy-green" /> {activityLabel(state.type)} metrics
        </h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          {metrics.length === 0 ? (
            <p className="col-span-full text-sm text-buddy-text-secondary">
              Start the session and the numbers appear here.
            </p>
          ) : metrics.map((m) => (
            <div key={m.label} className="bg-buddy-surface-raised rounded-xl p-3 text-center">
              <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">{m.label}</p>
              <p
                className={`text-xl font-display font-bold mt-0.5 font-mono ${
                  m.tone === 'orange' ? 'text-buddy-gold' : 'text-buddy-text-primary'
                }`}
              >
                {m.value}
              </p>
            </div>
          ))}
        </div>

        {state.error && <p className="text-sm text-buddy-red mt-3">{state.error}</p>}

        {/* Progress against the target the user picked. */}
        {target && targetProgress !== null && (
          <div className="mt-4">
            <div className="flex items-center justify-between mb-1 text-xs">
              <span className="text-buddy-text-secondary">Target</span>
              <span className={targetProgress >= 100 ? 'text-buddy-gold font-medium' : 'text-buddy-text-secondary'}>
                {target.value} {target.unit} · {targetProgress}%
              </span>
            </div>
            <div className="w-full bg-buddy-surface/50 rounded-full h-2 overflow-hidden">
              <div
                className={`h-full transition-all duration-500 ${targetProgress >= 100 ? 'bg-buddy-gold' : 'bg-buddy-green'}`}
                style={{ width: `${targetProgress}%` }}
              />
            </div>
          </div>
        )}

        {!state.tracking && !saved && (
          <label className="block mt-4 text-xs text-buddy-text-secondary">
            Notes (optional)
            <input
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="How did it go?"
              maxLength={200}
              className="mt-1 w-full bg-buddy-surface-raised rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
            />
          </label>
        )}
      </Card>

      {/* Controls */}
      <div className="flex items-center gap-3 pb-4">
        {!state.tracking && !saved && (
          <Button className="flex-1" onClick={handleStartFresh}>
            <Play size={16} className="mr-2" /> Start {activityLabel(state.type).toLowerCase()}
          </Button>
        )}

        {state.tracking && (
          <Button className="flex-1" variant="outline" onClick={() => void handleStopAndSave()} disabled={saving}>
            {saving ? <Loader2 size={16} className="animate-spin mr-2" /> : <Square size={16} className="mr-2" />}
            Stop &amp; save
          </Button>
        )}

        {saved && (
          <>
            <Button className="flex-1" variant="outline" onClick={handleUndo}>
              <Trash2 size={16} className="mr-2" /> Undo save
            </Button>
            <Button className="flex-1" onClick={handleDiscard}>
              <Save size={16} className="mr-2" /> Record another
            </Button>
          </>
        )}

        {hasSession && !state.tracking && !saved && (
          <Button variant="ghost" onClick={handleDiscard} aria-label="Discard session">
            <Trash2 size={16} />
          </Button>
        )}
      </div>
    </div>
  );
}
