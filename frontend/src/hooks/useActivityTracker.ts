import { useCallback, useEffect, useRef, useState } from 'react';
import type { ActivityRecordInput } from '@/types/analytics';

/**
 * The activity tracker.
 *
 * Owns the GPS watch, the timer, the distance and the step count, so the
 * same tracking can be used from the analytics tab and from the dedicated
 * page where a session is started and saved.
 */

export interface TrackPoint {
  lat: number;
  lng: number;
  ts: number;
}

export type TrackerType = ActivityRecordInput['activity_type'];

export interface TrackerState {
  type: TrackerType;
  tracking: boolean;
  elapsed: number;
  distanceM: number;
  steps: number;
  gpsFix: boolean;
  gpsAccuracy: number | null;
  points: TrackPoint[];
  error: string | null;
}

/** Metres between two points. */
export function haversine(a: TrackPoint, b: TrackPoint): number {
  const R = 6371000;
  const dLat = ((b.lat - a.lat) * Math.PI) / 180;
  const dLng = ((b.lng - a.lng) * Math.PI) / 180;
  const la1 = (a.lat * Math.PI) / 180;
  const la2 = (b.lat * Math.PI) / 180;
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(la1) * Math.cos(la2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

/** Stride length by activity — a ride has no steps. */
function strideMetres(type: TrackerType): number {
  if (type === 'run') return 1.15;
  if (type === 'hike') return 0.75;
  return 0.76;
}

export function useActivityTracker(initialType: TrackerType = 'run') {
  const [type, setType] = useState<TrackerType>(initialType);
  const [tracking, setTracking] = useState(false);
  const [elapsed, setElapsed] = useState(0);
  const [distanceM, setDistanceM] = useState(0);
  const [steps, setSteps] = useState(0);
  const [gpsFix, setGpsFix] = useState(false);
  const [gpsAccuracy, setGpsAccuracy] = useState<number | null>(null);
  const [points, setPoints] = useState<TrackPoint[]>([]);
  const [error, setError] = useState<string | null>(null);

  const watchIdRef = useRef<number | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const lastPosRef = useRef<TrackPoint | null>(null);
  const motionStepsRef = useRef(0);
  const lastMotionAtRef = useRef(0);
  const motionHandlerRef = useRef<((e: DeviceMotionEvent) => void) | null>(null);

  // ── Hybrid step counting ──────────────────────────────────────────────────
  // Real motion-sensor cadence when the browser offers it; otherwise a
  // stride-model estimate from the GPS distance.
  const startMotionListener = useCallback(() => {
    if (type !== 'walk') return;
    interface MotionCtor {
      new(cb: (e: DeviceMotionEvent) => void): { start: () => void; stop?: () => void };
    }
    const Ctor = ((window as unknown as Record<string, unknown>).DeviceMotionEvent) as MotionCtor | undefined;
    if (!Ctor) return; // estimate path
    try {
      const handler = (e: DeviceMotionEvent) => {
        const acc = e.accelerationIncludingGravity;
        if (!acc) return;
        const mag = Math.sqrt((acc.x ?? 0) ** 2 + (acc.y ?? 0) ** 2 + (acc.z ?? 0) ** 2);
        const now = Date.now();
        // Peak detection with a 280ms refractory period (~213 steps/min cap).
        if (mag > 11.5 && now - lastMotionAtRef.current > 280) {
          lastMotionAtRef.current = now;
          motionStepsRef.current += 1;
          setSteps(motionStepsRef.current);
        }
      };
      motionHandlerRef.current = handler;
      window.addEventListener('devicemotion', handler);
    } catch {
      // No motion sensor — the estimate path covers it.
    }
  }, [type]);

  const stopMotionListener = useCallback(() => {
    if (motionHandlerRef.current) {
      window.removeEventListener('devicemotion', motionHandlerRef.current);
      motionHandlerRef.current = null;
    }
  }, []);

  /** The step count: measured when possible, estimated otherwise. */
  const estimateSteps = useCallback((): number => {
    if (motionStepsRef.current > 0 && type === 'walk') return motionStepsRef.current;
    if (distanceM <= 0 || type === 'cycle') return 0;
    return Math.round(distanceM / strideMetres(type));
  }, [distanceM, type]);

  const reset = useCallback(() => {
    setTracking(false);
    setElapsed(0);
    setDistanceM(0);
    setSteps(0);
    setGpsFix(false);
    setGpsAccuracy(null);
    setPoints([]);
    setError(null);
    motionStepsRef.current = 0;
    lastPosRef.current = null;
  }, []);

  const start = useCallback(() => {
    setError(null);
    setDistanceM(0);
    setElapsed(0);
    setPoints([]);
    setSteps(0);
    setGpsFix(false);
    setGpsAccuracy(null);
    motionStepsRef.current = 0;
    lastPosRef.current = null;

    if (navigator.geolocation) {
      watchIdRef.current = navigator.geolocation.watchPosition(
        (pos) => {
          setGpsFix(true);
          setGpsAccuracy(Math.round(pos.coords.accuracy));
          // Record the first fix immediately so a session with no movement
          // still shows where the user was.
          const p: TrackPoint = { lat: pos.coords.latitude, lng: pos.coords.longitude, ts: Date.now() };
          // The dedupe lives outside the state updater: React may call an
          // updater more than once, and a side effect inside one would then
          // be applied twice — dropping the point it had just added.
          const last = lastPosRef.current;
          if (last && last.lat === p.lat && last.lng === p.lng) return;
          lastPosRef.current = p;
          setPoints((prev) => [...prev, p]);
        },
        (err) => setError(
          err.code === err.PERMISSION_DENIED
            ? 'Location access denied. The session is tracked without GPS.'
            : 'Waiting for a GPS signal…',
        ),
        { enableHighAccuracy: true, maximumAge: 1000, timeout: 10000 },
      );
    } else {
      setError('GPS is not supported by this browser.');
    }

    if (type === 'walk') startMotionListener();
    timerRef.current = setInterval(() => setElapsed((e) => e + 1), 1000);
    setTracking(true);
  }, [startMotionListener, type]);

  const stop = useCallback(() => {
    if (watchIdRef.current !== null) {
      navigator.geolocation.clearWatch(watchIdRef.current);
      watchIdRef.current = null;
    }
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
    stopMotionListener();
    setTracking(false);
  }, [stopMotionListener]);

  // The distance follows the route.
  useEffect(() => {
    if (points.length < 2) return;
    let total = 0;
    for (let i = 1; i < points.length; i++) total += haversine(points[i - 1], points[i]);
    setDistanceM(Math.round(total));
  }, [points]);

  useEffect(() => () => { stop(); }, [stop]);

  /** The payload for the tracker, with the numbers each kind cares about. */
  const buildPayload = useCallback((): ActivityRecordInput => {
    const km = distanceM / 1000;
    const pace = elapsed > 0 && distanceM > 0 ? elapsed / km : null;
    const speed = elapsed > 0 && distanceM > 0 ? (distanceM / elapsed) * 3.6 : null;
    return {
      activity_type: type,
      duration_seconds: elapsed,
      distance_meters: distanceM,
      avg_pace: pace,
      avg_speed_kmh: speed != null ? Math.round(speed * 10) / 10 : null,
      // A rough burn: rides cost less per kilometre than running.
      calories_burned: Math.round(
        type === 'cycle' ? Math.max(15, distanceM * 0.03) : Math.max(8, distanceM * 0.06),
      ),
      steps: type === 'walk' ? estimateSteps() : null,
      route: points.map((p) => [p.lat, p.lng, p.ts]),
    };
  }, [distanceM, elapsed, estimateSteps, points, type]);

  const state: TrackerState = {
    type, tracking, elapsed, distanceM, steps, gpsFix, gpsAccuracy, points, error,
  };

  return {
    state,
    setType,
    start,
    stop,
    reset,
    buildPayload,
    estimateSteps,
  };
}
