import { useState, useRef, useEffect } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { feedApi } from '@/api/feed';
import { analyticsApi } from '@/api/analytics';
import { playAlarmSound, stopAllAlarms } from '@/lib/alarmPlayer';
import { buildWorkoutPayload, normalizeCategory, specFor, typeOrder, useWorkoutTypes } from '@/lib/workoutTypes';
import { WORKOUT_DURATION_PRESETS } from '@/types/analytics';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Camera, Upload, RefreshCw, Video, Square, Timer, Check } from 'lucide-react';

const exercises = ['auto', 'squat', 'deadlift', 'bench_press', 'overhead_press', 'bicep_curl', 'push_up', 'lunge'] as const;
const PLAYBACK_SPEEDS = [0.5, 1, 1.5, 2, 2.5, 3, 4, 5] as const;
const exerciseLabels: Record<string, string> = {
  auto: 'Auto Detect',
  squat: 'Squat',
  deadlift: 'Deadlift',
  bench_press: 'Bench Press',
  overhead_press: 'Overhead Press',
};

// Category → detector exercise hint (sets the exercise picker above).
// Only body-part categories carry a hint; a yoga style or a sport name
// leaves the picker on auto-detect.
const CATEGORY_EXERCISE_HINT: Record<string, string> = {
  upper: 'overhead_press',
  lower: 'squat',
  legs: 'lunge',
  push: 'bench_press',
  pull: 'deadlift',
  core: 'push_up',
  arms: 'bicep_curl',
  full: 'auto',
};

export default function WorkoutForm() {
  const [searchParams] = useSearchParams();
  const { types } = useWorkoutTypes();
  const [exercise, setExercise] = useState<string>('auto');
  const [mode, setMode] = useState<'photo' | 'video' | 'timer'>('photo');
  const [image, setImage] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recording, setRecording] = useState(false);
  const [recSecs, setRecSecs] = useState(0);
  const [speed, setSpeed] = useState<number>(1);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<number | null>(null);
  const countdownRef = useRef<number | null>(null);
  const playbackRef = useRef<HTMLVideoElement>(null);
  // Timer-only mode (no getUserMedia): countdown from a duration preset.
  const [timerPresetMin, setTimerPresetMin] = useState<number>(30);
  const [timerSecsLeft, setTimerSecsLeft] = useState<number | null>(null);
  const [timerRunning, setTimerRunning] = useState(false);
  const [timerFinished, setTimerFinished] = useState(false);
  const [timerLogged, setTimerLogged] = useState(false);
  const [loggingTimer, setLoggingTimer] = useState(false);
  const alarmStopRef = useRef<(() => void) | null>(null);

  // ── Start workout (no typing) ─────────────────────────────────────────────
  // Type + category + duration are the only choices; the recorder and the
  // countdown run from here and the POST happens on finish.
  const [session, setSession] = useState({ type: 'strength', category: '', durationMin: 30 });
  const [logged, setLogged] = useState<{ minutes: number } | null>(null);
  const [quick, setQuick] = useState(false);
  const [pendingCamera, setPendingCamera] = useState(false);
  const [pendingTimer, setPendingTimer] = useState<number | null>(null);
  // Read inside MediaRecorder.onstop, which fires after the click that
  // stopped it — state would already be re-rendered by then.
  const recSecsRef = useRef(0);

  const sessionSpec = specFor(types, session.type);

  useEffect(() => {
    if (playbackRef.current) playbackRef.current.playbackRate = speed;
  }, [speed, result]);

  useEffect(() => () => {
    if (timerRef.current) window.clearInterval(timerRef.current);
    if (countdownRef.current) window.clearInterval(countdownRef.current);
    alarmStopRef.current?.();
    stopAllAlarms();
    stopCamera();
  }, []);

  /** Switching mode mounts the video element — start the recorder after it lands. */
  useEffect(() => {
    if (!pendingCamera || !videoRef.current) return;
    setPendingCamera(false);
    void startRecording();
  }, [pendingCamera, mode]);

  /** Same for the countdown, which must start from the chosen preset. */
  useEffect(() => {
    if (pendingTimer == null) return;
    setPendingTimer(null);
    startTimerCountdown(pendingTimer);
  }, [pendingTimer, mode]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selected = e.target.files?.[0];
    if (!selected) return;
    setFile(selected);
    setResult(null);
    const reader = new FileReader();
    reader.onloadend = () => setImage(reader.result as string);
    reader.readAsDataURL(selected);
  };

  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
    } catch (e) {
      setError('Unable to access camera. Use upload instead.');
    }
  };

  const captureImage = () => {
    if (!videoRef.current || !canvasRef.current) return;
    const video = videoRef.current;
    const canvas = canvasRef.current;
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    canvas.toBlob((blob) => {
      if (!blob) return;
      const f = new File([blob], 'capture.jpg', { type: 'image/jpeg' });
      setFile(f);
      setImage(URL.createObjectURL(f));
      stopCamera();
    }, 'image/jpeg');
  };

  const stopCamera = () => {
    if (videoRef.current?.srcObject) {
      (videoRef.current.srcObject as MediaStream).getTracks().forEach((t) => t.stop());
      videoRef.current.srcObject = null;
    }
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
      const rec = new MediaRecorder(stream, { mimeType: MediaRecorder.isTypeSupported('video/webm') ? 'video/webm' : undefined });
      chunksRef.current = [];
      rec.ondataavailable = (e) => { if (e.data.size) chunksRef.current.push(e.data); };
      rec.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: 'video/webm' });
        const f = new File([blob], `workout-${Date.now()}.webm`, { type: 'video/webm' });
        setFile(f);
        setImage(URL.createObjectURL(f));
        setResult(null);
        stopCamera();
        // Captured at record time: this closure knows whether the clip came
        // from Start workout or from the analyzer.
        if (quick) void logRecordedWorkout(Math.max(1, Math.round(recSecsRef.current / 60)));
      };
      rec.start(500);
      recorderRef.current = rec;
      setRecording(true);
      setRecSecs(0);
      recSecsRef.current = 0;
      timerRef.current = window.setInterval(() => {
        recSecsRef.current += 1;
        setRecSecs(recSecsRef.current);
      }, 1000);
    } catch {
      setError('Unable to access camera. Use upload instead.');
    }
  };

  const stopRecording = () => {
    recorderRef.current?.stop();
    if (timerRef.current) window.clearInterval(timerRef.current);
    setRecording(false);
  };

  const fmtTime = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  /** One POST path for every finish — camera, timer, or manual. */
  const postSession = async (minutes: number) => {
    await analyticsApi.createWorkout(buildWorkoutPayload({
      workout_type: session.type,
      category: session.category,
      duration_minutes: minutes,
    }, types));
  };

  /** A finished recording logs itself; the clip stays on screen for review. */
  const logRecordedWorkout = async (minutes: number) => {
    setLoggingTimer(true);
    setError(null);
    try {
      await postSession(minutes);
      setLogged({ minutes });
    } catch {
      setError('Failed to log workout.');
    } finally {
      setLoggingTimer(false);
    }
  };

  const startQuick = async (source: 'camera' | 'timer') => {
    setError(null);
    setLogged(null);
    setTimerLogged(false);
    setTimerFinished(false);
    setResult(null);
    setFile(null);
    setImage(null);
    setQuick(true);
    if (source === 'camera') {
      setMode('video');
      setPendingCamera(true);
    } else {
      setMode('timer');
      setTimerPresetMin(session.durationMin);
      setPendingTimer(session.durationMin);
    }
  };

  const chooseType = (key: string) => {
    setLogged(null);
    setSession((s) => ({ ...s, type: key, category: normalizeCategory(specFor(types, key), s.category) }));
  };

  const startTimerCountdown = (minutes: number = timerPresetMin) => {
    if (countdownRef.current) window.clearInterval(countdownRef.current);
    alarmStopRef.current?.();
    setTimerFinished(false);
    setTimerLogged(false);
    setError(null);
    const total = minutes * 60;
    setTimerSecsLeft(total);
    setTimerRunning(true);
    countdownRef.current = window.setInterval(() => {
      setTimerSecsLeft((prev) => {
        if (prev == null) return prev;
        if (prev <= 1) {
          if (countdownRef.current) window.clearInterval(countdownRef.current);
          countdownRef.current = null;
          setTimerRunning(false);
          setTimerFinished(true);
          try {
            alarmStopRef.current = playAlarmSound('', { loops: 3 });
          } catch {
            // audible fallback already handled inside alarmPlayer
          }
          try {
            if (typeof navigator !== 'undefined' && navigator.vibrate) navigator.vibrate([300, 150, 300]);
          } catch {
            // vibrate unsupported — ignore
          }
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const stopTimerCountdown = () => {
    if (countdownRef.current) window.clearInterval(countdownRef.current);
    countdownRef.current = null;
    setTimerRunning(false);
  };

  const logTimerWorkout = async () => {
    setLoggingTimer(true);
    setError(null);
    try {
      await postSession(timerPresetMin);
      setTimerLogged(true);
      setLogged({ minutes: timerPresetMin });
    } catch {
      setError('Failed to log timer workout.');
    } finally {
      setLoggingTimer(false);
    }
  };

  const analyze = async () => {
    if (!file) return;
    setLoading(true);
    setError(null);
    try {
      const res = await feedApi.analyzeWorkoutForm(file, exercise === 'auto' ? undefined : exercise);
      if (res.success && res.data) {
        setResult(res.data);
      } else {
        setError(res.message || 'Analysis failed.');
      }
    } catch (e: any) {
      setError(e?.response?.data?.message || 'Failed to analyze form.');
    } finally {
      setLoading(false);
    }
  };

  const scoreColor = (score: number) => {
    if (score >= 80) return 'text-buddy-green';
    if (score >= 60) return 'text-yellow-400';
    return 'text-buddy-red';
  };

  const formCategories = specFor(types, session.type).categories;

  return (
    <div className="p-4 max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto space-y-4">
      {/* ── Start workout: type + category + duration, then just record ── */}
      <Card className="p-4 space-y-4">
        <div className="flex items-center justify-between gap-2">
          <h1 className="font-display text-xl font-bold">Start workout</h1>
          {searchParams.get('start') === '1' && (
            <Link to="/analytics" className="text-xs text-buddy-text-secondary hover:text-buddy-green underline">
              View analytics
            </Link>
          )}
        </div>
        <p className="-mt-2 text-sm text-buddy-text-secondary">
          No typing needed — pick what you did and start recording.
        </p>

        <div>
          <p className="text-sm font-medium mb-2">What are you doing?</p>
          <div className="flex flex-wrap gap-2">
            {typeOrder(types).map((key) => (
              <button
                key={key}
                onClick={() => chooseType(key)}
                aria-pressed={session.type === key}
                className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                  session.type === key
                    ? 'bg-buddy-green text-buddy-black font-medium'
                    : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                }`}
              >
                {specFor(types, key).label}
              </button>
            ))}
          </div>
        </div>

        {formCategories.length > 0 && (
          <div>
            <p className="text-sm font-medium mb-2">{sessionSpec.label} category</p>
            <div className="flex flex-wrap gap-2">
              {formCategories.map((c) => (
                <button
                  key={c.key}
                  onClick={() => setSession((s) => ({ ...s, category: s.category === c.key ? '' : c.key }))}
                  aria-pressed={session.category === c.key}
                  className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                    session.category === c.key
                      ? 'bg-buddy-green text-buddy-black font-medium'
                      : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                  }`}
                >
                  {c.label}
                </button>
              ))}
            </div>
          </div>
        )}

        <div>
          <p className="text-sm font-medium mb-2">How long?</p>
          <div className="flex flex-wrap gap-2">
            {WORKOUT_DURATION_PRESETS.map((m) => (
              <button
                key={m}
                onClick={() => setSession((s) => ({ ...s, durationMin: m }))}
                aria-pressed={session.durationMin === m}
                className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                  session.durationMin === m
                    ? 'bg-buddy-green text-buddy-black font-medium'
                    : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                }`}
              >
                {m} min
              </button>
            ))}
          </div>
        </div>

        <div className="flex gap-2">
          <Button onClick={() => startQuick('camera')} className="flex-1 gap-2" aria-label="Start workout with camera">
            <Camera size={18} /> Camera
          </Button>
          <Button variant="outline" onClick={() => startQuick('timer')} className="flex-1 gap-2">
            <Timer size={18} /> Timer only
          </Button>
        </div>

        {logged && (
          <div className="flex items-start gap-2 rounded-lg bg-buddy-green/10 p-3">
            <Check size={16} className="text-buddy-green mt-0.5 shrink-0" />
            <p className="text-sm text-buddy-text-primary">
              Logged {sessionSpec.label.toLowerCase()}
              {session.category ? ` · ${session.category.replace(/_/g, ' ')}` : ''} — {logged.minutes} min.{' '}
              <Link to="/analytics" className="text-buddy-green underline">See it in analytics</Link>
            </p>
          </div>
        )}
        {loggingTimer && !logged && (
          <p className="text-sm text-buddy-text-secondary">Logging your workout…</p>
        )}
      </Card>

      <h1 className="font-display text-xl font-bold">Form Analyzer</h1>
      <p className="-mt-2 text-buddy-text-secondary text-sm">Capture a frame or record a set — the detector names the workout, counts reps and maps the muscles worked.</p>

      <div className="flex rounded-xl bg-buddy-surface p-1">
        {(['photo', 'video', 'timer'] as const).map((m) => (
          <button key={m} onClick={() => { setQuick(false); stopTimerCountdown(); setMode(m); setFile(null); setImage(null); setResult(null); setTimerFinished(false); setTimerLogged(false); setTimerSecsLeft(null); }}
            className={`flex-1 py-2 text-sm font-medium rounded-lg capitalize transition-colors ${mode === m ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{m === 'photo' ? 'Photo frame' : m === 'video' ? 'Record set' : 'Timer-only'}</button>
        ))}
      </div>

      <Card className="p-4 space-y-4">
        {/* Category is picked once, in Start workout — it drives both the log
            payload and the detector hint below. */}
        {session.category && CATEGORY_EXERCISE_HINT[session.category] && (
          <p className="text-xs text-buddy-text-secondary">
            Detector hint: {exerciseLabels[CATEGORY_EXERCISE_HINT[session.category]] ?? CATEGORY_EXERCISE_HINT[session.category]}
          </p>
        )}
        <div>
          <p className="text-sm font-medium mb-2">Exercise</p>
          <div className="flex flex-wrap gap-2">
            {exercises.map((ex) => (
              <button
                key={ex}
                onClick={() => setExercise(ex)}
                className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                  exercise === ex
                    ? 'bg-buddy-green text-buddy-black font-medium'
                    : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                }`}
              >
                {exerciseLabels[ex]}
              </button>
            ))}
          </div>
        </div>

        {mode === 'timer' ? (
          <div className="space-y-3 rounded-xl bg-buddy-surface-raised p-4">
            <p className="text-sm font-medium">Timer-only — no camera needed</p>
            <div className="flex flex-wrap gap-1.5">
              {WORKOUT_DURATION_PRESETS.map((m) => (
                <button
                  key={m}
                  onClick={() => { if (!timerRunning) { setTimerPresetMin(m); setSession((s) => ({ ...s, durationMin: m })); setTimerSecsLeft(null); setTimerFinished(false); setTimerLogged(false); } }}
                  aria-pressed={timerPresetMin === m}
                  className={`px-3 py-1.5 rounded-full text-sm transition-colors ${
                    timerPresetMin === m
                      ? 'bg-buddy-green text-buddy-black font-medium'
                      : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                  }`}
                >
                  {m} min
                </button>
              ))}
            </div>
            {(timerSecsLeft != null || timerRunning || timerFinished) && (
              <p className="font-mono text-3xl font-bold text-center tabular-nums">
                {timerSecsLeft != null ? `${Math.floor(timerSecsLeft / 60)}:${String(timerSecsLeft % 60).padStart(2, '0')}` : `${timerPresetMin}:00`}
              </p>
            )}
            <div className="flex gap-2">
              {!timerRunning ? (
                <Button onClick={() => startTimerCountdown()} className="flex-1 gap-2">
                  <Timer size={18} /> Start {timerPresetMin} min timer
                </Button>
              ) : (
                <Button variant="destructive" onClick={stopTimerCountdown} className="flex-1 gap-2">
                  <Square size={18} /> Cancel ({timerSecsLeft != null ? fmtTime(timerSecsLeft) : ''})
                </Button>
              )}
            </div>
            {timerFinished && (
              <div className="space-y-2 rounded-lg bg-buddy-green/10 p-3">
                <p className="text-sm font-medium text-buddy-green">Time! Nice work.</p>
                <p className="text-xs text-buddy-text-secondary">
                  Photo frame capture needs a camera — switch to Photo to Analyze form, or log this {timerPresetMin} min{timerPresetMin === 1 ? '' : 's'} directly to analytics.
                </p>
                {!timerLogged ? (
                  <Button onClick={logTimerWorkout} isLoading={loggingTimer} className="w-full">
                    {loggingTimer ? 'Logging…' : `Log ${timerPresetMin} min workout`}
                  </Button>
                ) : (
                  <p className="text-sm text-buddy-green">Logged to analytics.</p>
                )}
              </div>
            )}
          </div>
        ) : (
        <div className="flex gap-2">
          {mode === 'photo' ? (
            <>
              <Button variant="outline" onClick={startCamera} className="flex-1 gap-2">
                <Camera size={18} /> Camera
              </Button>
              <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="flex-1 gap-2">
                <Upload size={18} /> Upload
              </Button>
            </>
          ) : recording ? (
            <Button variant="destructive" onClick={stopRecording} className="flex-1 gap-2">
              <Square size={18} /> Stop ({fmtTime(recSecs)})
            </Button>
          ) : (
            <>
              <Button variant="outline" onClick={startRecording} className="flex-1 gap-2">
                <Video size={18} /> Record set
              </Button>
              <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="flex-1 gap-2">
                <Upload size={18} /> Upload clip
              </Button>
            </>
          )}
          <input
            ref={fileInputRef}
            type="file"
            accept={mode === 'photo' ? 'image/*' : 'video/*'}
            className="hidden"
            onChange={handleFileChange}
          />
        </div>
        )}

        {recording && (
          <p className="flex items-center gap-2 text-sm text-buddy-red font-medium">
            <Timer size={15} /> Recording… {fmtTime(recSecs)}
          </p>
        )}

        {mode !== 'timer' && (
        <>
        <video ref={videoRef} className="w-full rounded-xl bg-black" playsInline muted />

        {videoRef.current?.srcObject && (
          <Button onClick={captureImage} className="w-full">
            Capture Frame
          </Button>
        )}

        {image && (
          <div className="relative">
            <img src={image} alt="Pose" className="w-full rounded-xl" />
          </div>
        )}

        {image && !result && (
          <Button onClick={analyze} isLoading={loading} className="w-full">
            {loading ? 'Analyzing...' : 'Analyze Form'}
          </Button>
        )}
        </>
        )}
        {mode === 'timer' && (
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={handleFileChange}
          />
        )}
      </Card>

      {error && (
        <Card className="p-4 bg-buddy-red/10 text-buddy-red">
          <p>{error}</p>
        </Card>
      )}

      {result && image && file?.type.startsWith('video/') && (
        <Card className="p-4 space-y-3">
          <video ref={playbackRef} src={image} controls playsInline className="w-full rounded-xl bg-black" />
          <div>
            <p className="text-xs font-medium text-buddy-text-secondary mb-1.5">Review speed (compressed replay)</p>
            <div className="flex flex-wrap gap-1.5">
              {PLAYBACK_SPEEDS.map((s) => (
                <button key={s} onClick={() => setSpeed(s)}
                  className={`px-2.5 py-1 rounded-full text-xs transition-colors ${speed === s ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary'}`}
                >{s}x</button>
              ))}
            </div>
          </div>
        </Card>
      )}

      {result && (
        <Card className="p-6 space-y-4">
          <div className="flex items-baseline justify-between">
            <p className="font-heading font-semibold text-lg">{exerciseLabels[result.exercise] || result.exercise?.replace(/_/g, ' ')}</p>
            <p className={`text-2xl font-extrabold ${scoreColor(result.form_score)}`}>{result.form_score}/100</p>
          </div>

          {(result.reps !== undefined || result.muscles?.length > 0 || result.duration_seconds) && (
            <div className="grid grid-cols-3 gap-2 text-center">
              <div className="rounded-xl bg-buddy-surface-raised p-2.5">
                <p className="font-mono font-bold text-lg">{result.reps ?? '—'}</p>
                <p className="text-[11px] text-buddy-text-secondary">Reps</p>
              </div>
              <div className="rounded-xl bg-buddy-surface-raised p-2.5">
                <p className="font-mono font-bold text-lg">{result.duration_seconds ? `${result.duration_seconds}s` : '—'}</p>
                <p className="text-[11px] text-buddy-text-secondary">Time</p>
              </div>
              <div className="rounded-xl bg-buddy-surface-raised p-2.5">
                <p className="font-mono font-bold text-sm leading-6 capitalize">{result.body_area || '—'}</p>
                <p className="text-[11px] text-buddy-text-secondary">Area</p>
              </div>
            </div>
          )}
          {result.muscles?.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {result.muscles.map((m: string) => (
                <span key={m} className="text-xs px-2 py-1 rounded-md bg-buddy-green/10 text-buddy-green capitalize">{m}</span>
              ))}
            </div>
          )}

          {result.hip_angle !== undefined && (
            <p className="text-sm text-buddy-text-secondary">Hip angle: {result.hip_angle}°</p>
          )}
          {result.knee_angle !== undefined && (
            <p className="text-sm text-buddy-text-secondary">Knee angle: {result.knee_angle}°</p>
          )}
          {result.back_angle !== undefined && (
            <p className="text-sm text-buddy-text-secondary">Back angle: {result.back_angle}°</p>
          )}
          {result.left_elbow_angle !== undefined && (
            <p className="text-sm text-buddy-text-secondary">Elbow angles: {result.left_elbow_angle}° / {result.right_elbow_angle}°</p>
          )}

          <div>
            <p className="text-sm font-medium mb-2">Feedback</p>
            <ul className="space-y-1">
              {result.feedback.map((tip: string, i: number) => (
                <li key={i} className="text-sm text-buddy-text-secondary flex gap-2 items-start">
                  <span className="text-buddy-green">•</span>
                  {tip}
                </li>
              ))}
            </ul>
          </div>

          {result.issues.length > 0 && (
            <div>
              <p className="text-sm font-medium mb-2 text-buddy-red">Form Issues</p>
              <div className="flex flex-wrap gap-1">
                {result.issues.map((issue: string) => (
                  <span key={issue} className="text-xs px-2 py-1 rounded-md bg-buddy-red/10 text-buddy-red capitalize">
                    {issue.replace(/_/g, ' ')}
                  </span>
                ))}
              </div>
            </div>
          )}

          <Button variant="outline" onClick={() => { setImage(null); setFile(null); setResult(null); }} className="w-full gap-2">
            <RefreshCw size={18} /> Analyze Another
          </Button>
        </Card>
      )}
    </div>
  );
}