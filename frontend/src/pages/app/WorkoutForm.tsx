import { useState, useRef } from 'react';
import { feedApi } from '@/api/feed';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Camera, Upload, RefreshCw } from 'lucide-react';

const exercises = ['auto', 'squat', 'deadlift', 'bench_press', 'overhead_press'] as const;
const exerciseLabels: Record<string, string> = {
  auto: 'Auto Detect',
  squat: 'Squat',
  deadlift: 'Deadlift',
  bench_press: 'Bench Press',
  overhead_press: 'Overhead Press',
};

export default function WorkoutForm() {
  const [exercise, setExercise] = useState<string>('auto');
  const [image, setImage] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

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

  return (
    <div className="p-4 max-w-xl mx-auto space-y-4">
      <h1 className="font-display text-2xl font-bold">Form Analyzer</h1>
      <p className="text-buddy-text-secondary text-sm">Capture or upload a video frame to get real-time form feedback.</p>

      <Card className="p-4 space-y-4">
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

        <div className="flex gap-2">
          <Button variant="outline" onClick={startCamera} className="flex-1 gap-2">
            <Camera size={18} /> Camera
          </Button>
          <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="flex-1 gap-2">
            <Upload size={18} /> Upload
          </Button>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={handleFileChange}
          />
        </div>

        <video ref={videoRef} className="w-full rounded-xl bg-black" playsInline muted />
        <canvas ref={canvasRef} className="hidden" />

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
      </Card>

      {error && (
        <Card className="p-4 bg-buddy-red/10 text-buddy-red">
          <p>{error}</p>
        </Card>
      )}

      {result && (
        <Card className="p-6 space-y-4">
          <div className="flex items-baseline justify-between">
            <p className="font-heading font-semibold text-lg">{exerciseLabels[result.exercise]}</p>
            <p className={`text-2xl font-extrabold ${scoreColor(result.form_score)}`}>{result.form_score}/100</p>
          </div>

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
