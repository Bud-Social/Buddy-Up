import { useState, useRef, useCallback, useEffect } from 'react';
import { Camera, Video, StopCircle, RefreshCw, X } from 'lucide-react';

interface CameraCaptureProps {
  onCapture: (file: File) => void;
  onClose: () => void;
}

export default function CameraCapture({ onCapture, onClose }: CameraCaptureProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const chunksRef = useRef<Blob[]>([]);

  const [facingMode, setFacingMode] = useState<'user' | 'environment'>('environment');
  const [mode, setMode] = useState<'photo' | 'video'>('photo');
  const [recording, setRecording] = useState(false);
  const [recordingSeconds, setRecordingSeconds] = useState(0);
  const [torch, setTorch] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const startStream = useCallback(async (facing: 'user' | 'environment') => {
    stopStream();
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: facing, width: { ideal: 1280 }, height: { ideal: 720 } },
        audio: mode === 'video',
      });
      streamRef.current = stream;
      if (videoRef.current) videoRef.current.srcObject = stream;
      setError(null);
    } catch (e: any) {
      setError(e.message || 'Camera access denied');
    }
  }, [mode]);

  const stopStream = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t) => t.stop());
      streamRef.current = null;
    }
  }, []);

  useEffect(() => {
    startStream(facingMode);
    return stopStream;
  }, [facingMode, mode, startStream, stopStream]);

  const toggleCamera = () => setFacingMode((f) => (f === 'user' ? 'environment' : 'user'));

  const capturePhoto = useCallback(() => {
    const video = videoRef.current;
    if (!video) return;
    const canvas = document.createElement('canvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d')!.drawImage(video, 0, 0);
    canvas.toBlob((blob) => {
      if (!blob) return;
      const file = new File([blob], `photo_${Date.now()}.jpg`, { type: 'image/jpeg' });
      stopStream();
      onCapture(file);
    }, 'image/jpeg', 0.92);
  }, [onCapture, stopStream]);

  const startRecording = useCallback(() => {
    const stream = streamRef.current;
    if (!stream) return;
    chunksRef.current = [];
    const recorder = new MediaRecorder(stream, { mimeType: 'video/webm;codecs=vp9,opus' });
    recorder.ondataavailable = (e) => { if (e.data.size > 0) chunksRef.current.push(e.data); };
    recorder.onstop = () => {
      const blob = new Blob(chunksRef.current, { type: 'video/webm' });
      const file = new File([blob], `video_${Date.now()}.webm`, { type: 'video/webm' });
      stopStream();
      onCapture(file);
    };
    recorder.start(100);
    mediaRecorderRef.current = recorder;
    setRecording(true);

    let sec = 0;
    const interval = setInterval(() => { sec++; setRecordingSeconds(sec); }, 1000);
    (recorder as any)._interval = interval;
  }, [onCapture, stopStream]);

  const stopRecording = useCallback(() => {
    const recorder = mediaRecorderRef.current;
    if (!recorder || recorder.state === 'inactive') return;
    recorder.stop();
    clearInterval((recorder as any)._interval);
    setRecording(false);
    setRecordingSeconds(0);
  }, []);

  const toggleTorch = async () => {
    const track = streamRef.current?.getVideoTracks()[0];
    if (!track || !('applyConstraints' in track)) return;
    try {
      await track.applyConstraints({ advanced: [{ torch: !torch } as any] });
      setTorch(!torch);
    } catch {}
  };

  const fmtTime = (s: number) => `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-black">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 shrink-0 z-10">
        <button onClick={() => { stopStream(); onClose(); }} className="p-2 text-white/80 hover:text-white rounded-full">
          <X size={24} />
        </button>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setMode('photo')}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${mode === 'photo' ? 'bg-white text-black' : 'bg-white/20 text-white'}`}
          >
            <Camera size={14} className="inline mr-1 -mt-0.5" />Photo
          </button>
          <button
            onClick={() => setMode('video')}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${mode === 'video' ? 'bg-white text-black' : 'bg-white/20 text-white'}`}
          >
            <Video size={14} className="inline mr-1 -mt-0.5" />Video
          </button>
        </div>
        <button onClick={toggleCamera} className="p-2 text-white/80 hover:text-white rounded-full" title="Flip camera">
          <RefreshCw size={20} />
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="mx-4 mb-2 px-3 py-2 bg-red-500/20 rounded-xl text-xs text-red-300 text-center">{error}</div>
      )}

      {/* Viewfinder */}
      <div className="flex-1 relative flex items-center justify-center overflow-hidden">
        <video ref={videoRef} autoPlay playsInline muted className="absolute inset-0 w-full h-full object-cover" />
        {recording && (
          <div className="absolute top-4 left-4 flex items-center gap-2 bg-red-600/80 rounded-full px-3 py-1.5 text-white text-xs font-semibold">
            <span className="w-2 h-2 rounded-full bg-white animate-pulse" />
            {fmtTime(recordingSeconds)}
          </div>
        )}
      </div>

      {/* Controls */}
      <div className="flex items-center justify-center py-6 shrink-0 gap-8 z-10">
        {mode === 'photo' ? (
          <button
            onClick={capturePhoto}
            className="w-16 h-16 rounded-full border-4 border-white flex items-center justify-center hover:scale-105 transition-transform"
          >
            <div className="w-12 h-12 rounded-full bg-white" />
          </button>
        ) : recording ? (
          <button
            onClick={stopRecording}
            className="w-16 h-16 rounded-full bg-red-600 flex items-center justify-center hover:scale-105 transition-transform"
          >
            <StopCircle size={28} className="text-white" />
          </button>
        ) : (
          <button
            onClick={startRecording}
            className="w-16 h-16 rounded-full border-4 border-red-500 flex items-center justify-center hover:scale-105 transition-transform"
          >
            <div className="w-10 h-10 rounded-full bg-red-500" />
          </button>
        )}
      </div>

      {/* Torch toggle (bottom-left) */}
      {mode === 'video' && (
        <button onClick={toggleTorch} className="absolute bottom-8 left-6 p-2 text-white/60 hover:text-white">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M9 18h6v-3l3-3V6H6v6l3 3v3z" /><circle cx="12" cy="9" r="1.5" fill="currentColor" />
          </svg>
        </button>
      )}
    </div>
  );
}
