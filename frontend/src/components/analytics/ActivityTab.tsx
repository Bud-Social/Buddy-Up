import { useEffect, useRef, useState } from 'react';
import { Play, Square, Trash2, Navigation, Footprints, Activity as ActivityIcon } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { RouteMap } from '@/components/analytics/RouteMap';
import { formatDuration, formatKm, formatPace, titleCase, formatDateTime } from '@/components/analytics/format';
import { analyticsApi } from '@/api/analytics';
import type { ActivityRecordInput, ActivitySummary } from '@/types/analytics';

const ACTIVITY_TYPES: { key: ActivityRecordInput['activity_type']; label: string; icon: typeof Footprints }[] = [
  { key: 'walk', label: 'Walk', icon: Footprints },
  { key: 'run', label: 'Run', icon: ActivityIcon },
  { key: 'hike', label: 'Hike', icon: Navigation },
  { key: 'cycle', label: 'Cycle', icon: ActivityIcon },
];

interface TrackPoint { lat: number; lng: number; ts: number; }

export function ActivityTab() {
  const [activities, setActivities] = useState<ActivitySummary['recent']>([]);
  const [loading, setLoading] = useState(true);
  const [type, setType] = useState<ActivityRecordInput['activity_type']>('run');

  // Tracker state
  const [tracking, setTracking] = useState(false);
  const [elapsed, setElapsed] = useState(0);
  const [distanceM, setDistanceM] = useState(0);
  const [points, setPoints] = useState<TrackPoint[]>([]);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState<ActivityRecordInput | null>(null);
  const [error, setError] = useState<string | null>(null);
  const watchIdRef = useRef<number | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const load = () => {
    analyticsApi.getActivities()
      .then((res) => setActivities(res.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  useEffect(() => {
    return () => { stopTracking(); };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const startTracking = () => {
    setError(null);
    setSaved(null);
    setDistanceM(0);
    setElapsed(0);
    setPoints([]);

    let lastPos: TrackPoint | null = null;
    if (navigator.geolocation) {
      watchIdRef.current = navigator.geolocation.watchPosition(
        (pos) => {
          const p: TrackPoint = { lat: pos.coords.latitude, lng: pos.coords.longitude, ts: Date.now() };
          setPoints((prev) => {
            if (lastPos && lastPos.lat === p.lat && lastPos.lng === p.lng) return prev;
            const next = lastPos ? [...prev, p] : [p];
            lastPos = p;
            return next;
          });
        },
        () => setError('Location access denied. Activity will be tracked without GPS.'),
        { enableHighAccuracy: true, maximumAge: 1000, timeout: 10000 },
      );
    } else {
      setError('GPS not supported by this browser.');
    }

    timerRef.current = setInterval(() => setElapsed((e) => e + 1), 1000);
    setTracking(true);
  };

  const stopTracking = () => {
    if (watchIdRef.current !== null) {
      navigator.geolocation.clearWatch(watchIdRef.current);
      watchIdRef.current = null;
    }
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
    setTracking(false);
  };

  const haversine = (a: TrackPoint, b: TrackPoint) => {
    const R = 6371000;
    const dLat = ((b.lat - a.lat) * Math.PI) / 180;
    const dLng = ((b.lng - a.lng) * Math.PI) / 180;
    const la1 = (a.lat * Math.PI) / 180;
    const la2 = (b.lat * Math.PI) / 180;
    const h = Math.sin(dLat / 2) ** 2 + Math.cos(la1) * Math.cos(la2) * Math.sin(dLng / 2) ** 2;
    return 2 * R * Math.asin(Math.sqrt(h));
  };

  useEffect(() => {
    if (points.length < 2) return;
    let total = 0;
    for (let i = 1; i < points.length; i++) total += haversine(points[i - 1], points[i]);
    setDistanceM(Math.round(total));
  }, [points]);

  const handleStop = () => {
    stopTracking();
  };

  const handleSave = async () => {
    if (elapsed <= 0) return;
    setSaving(true);
    setError(null);
    const payload: ActivityRecordInput = {
      activity_type: type,
      duration_seconds: elapsed,
      distance_meters: distanceM,
      avg_pace: elapsed > 0 && distanceM > 0 ? (elapsed / (distanceM / 1000)) : null,
      calories_burned: Math.round(distanceM * 0.06),
      route: points.map((p) => [p.lat, p.lng, p.ts]),
    };
    try {
      await analyticsApi.createActivity(payload);
      setSaved(payload);
      setPoints([]);
      setDistanceM(0);
      setElapsed(0);
      load();
    } catch {
      setError('Failed to save activity.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await analyticsApi.deleteActivity(id);
      setActivities((prev) => prev.filter((a) => a.id !== id));
    } catch {
      setError('Failed to delete activity.');
    }
  };

  const liveRoute = points.map((p) => [p.lat, p.lng, p.ts]);

  return (
    <div className="space-y-4">
      {/* Live tracker */}
      <Card className="p-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-heading font-semibold">Walking / Running Tracker</h3>
          <span className={`inline-flex items-center gap-1.5 text-xs font-medium px-2 py-1 rounded-full ${tracking ? 'bg-buddy-red/15 text-buddy-red' : 'bg-buddy-surface-raised text-buddy-text-secondary'}`}>
            <span className={`w-1.5 h-1.5 rounded-full ${tracking ? 'bg-buddy-red animate-pulse' : 'bg-buddy-text-secondary/40'}`} />
            {tracking ? 'Tracking' : 'Idle'}
          </span>
        </div>

        {/* Type picker */}
        <div className="flex flex-wrap gap-2 mb-3">
          {ACTIVITY_TYPES.map(({ key, label, icon: Icon }) => (
            <button
              key={key}
              disabled={tracking}
              onClick={() => setType(key)}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm transition-colors disabled:opacity-50 ${
                type === key
                  ? 'bg-buddy-green text-buddy-black font-medium'
                  : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
              }`}
            >
              <Icon size={14} />
              {label}
            </button>
          ))}
        </div>

        {/* Live stats */}
        <div className="grid grid-cols-3 gap-3 mb-3">
          <div className="bg-buddy-surface-raised rounded-xl p-3 text-center">
            <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Time</p>
            <p className="text-xl font-display font-bold mt-0.5 font-mono">{formatDuration(elapsed)}</p>
          </div>
          <div className="bg-buddy-surface-raised rounded-xl p-3 text-center">
            <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Distance</p>
            <p className="text-xl font-display font-bold mt-0.5 font-mono">{formatKm(distanceM / 1000)} km</p>
          </div>
          <div className="bg-buddy-surface-raised rounded-xl p-3 text-center">
            <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">Pace</p>
            <p className="text-xl font-display font-bold mt-0.5 font-mono">
              {distanceM > 0 ? formatPace(elapsed / (distanceM / 1000)) : '—'}
            </p>
          </div>
        </div>

        {/* Live route */}
        <div className="mb-3">
          <RouteMap route={liveRoute} height={180} />
        </div>

        {error && <p className="text-sm text-buddy-red mb-2">{error}</p>}

        {/* Controls */}
        {!tracking ? (
          <div className="flex gap-2">
            <Button onClick={startTracking} className="flex-1 gap-2">
              <Play size={16} /> Start
            </Button>
          </div>
        ) : (
          <div className="flex gap-2">
            <Button variant="destructive" onClick={handleStop} className="flex-1 gap-2">
              <Square size={16} /> Stop
            </Button>
            <Button variant="outline" onClick={handleSave} isLoading={saving} className="flex-1 gap-2" disabled={elapsed <= 0}>
              Save Activity
            </Button>
          </div>
        )}

        {saved && (
          <p className="mt-3 text-sm text-buddy-green">
            Saved {titleCase(saved.activity_type)} — {formatKm(saved.distance_meters / 1000)} km in {formatDuration(saved.duration_seconds)}.
          </p>
        )}
      </Card>

      {/* Recent activities */}
      <div>
        <h3 className="font-heading font-semibold mb-3">Recent Activities</h3>
        {loading ? (
          <div className="space-y-3 animate-pulse">
            {Array.from({ length: 3 }).map((_, i) => <div key={i} className="h-28 bg-buddy-surface rounded-2xl" />)}
          </div>
        ) : activities.length === 0 ? (
          <Card className="p-6 text-center text-buddy-text-secondary text-sm">
            No activities yet. Press Start to track your first walk or run.
          </Card>
        ) : (
          <div className="space-y-3">
            {activities.map((a) => (
              <Card key={a.id} className="p-4">
                <div className="flex items-start justify-between gap-3 mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-buddy-green"><ActivityIcon size={16} /></span>
                    <p className="font-medium text-sm capitalize">{titleCase(a.activity_type)}</p>
                    <span className="text-xs text-buddy-text-secondary">{formatDateTime(a.started_at)}</span>
                  </div>
                  <button onClick={() => handleDelete(a.id)} className="p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-red hover:bg-buddy-red/10 transition-colors" title="Delete">
                    <Trash2 size={15} />
                  </button>
                </div>
                <div className="grid grid-cols-3 gap-2 text-sm mb-2">
                  <div>
                    <p className="text-xs text-buddy-text-secondary">Distance</p>
                    <p className="font-medium">{formatKm(a.distance_km)} km</p>
                  </div>
                  <div>
                    <p className="text-xs text-buddy-text-secondary">Time</p>
                    <p className="font-medium">{formatDuration(a.duration_seconds)}</p>
                  </div>
                  <div>
                    <p className="text-xs text-buddy-text-secondary">Calories</p>
                    <p className="font-medium">{Math.round(a.calories_burned ?? 0)}</p>
                  </div>
                </div>
                <RouteMap route={a.route} height={140} />
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
