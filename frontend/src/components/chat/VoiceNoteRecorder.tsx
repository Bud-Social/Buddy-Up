/**
 * VoiceNoteRecorder – in-chat voice note recording UI.
 * Shows a waveform visualizer + timer while recording.
 */
import { useEffect, useRef } from 'react';
import { Mic, Square, X, Send } from 'lucide-react';
import { useVoiceRecorder } from '@/hooks/useVoiceRecorder';

interface Props {
  onSend: (blob: Blob, durationMs: number) => void;
  onCancel: () => void;
}

function formatDuration(ms: number): string {
  const s = Math.floor(ms / 1000);
  const m = Math.floor(s / 60);
  return `${String(m).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
}

export function VoiceNoteRecorder({ onSend, onCancel }: Props) {
  const { state, durationMs, audioBlob, audioUrl, start, stop, cancel, reset } = useVoiceRecorder();
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const animFrameRef = useRef<number>(0);
  const analyserRef = useRef<AnalyserNode | null>(null);

  // Start recording immediately on mount
  useEffect(() => {
    start();
    return () => { cancel(); };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Draw waveform on canvas
  useEffect(() => {
    if (state !== 'recording') {
      cancelAnimationFrame(animFrameRef.current);
      return;
    }

    navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
      const ctx = new AudioContext();
      const source = ctx.createMediaStreamSource(stream);
      const analyser = ctx.createAnalyser();
      analyser.fftSize = 64;
      source.connect(analyser);
      analyserRef.current = analyser;

      const draw = () => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx2d = canvas.getContext('2d');
        if (!ctx2d) return;
        const bufferLength = analyser.frequencyBinCount;
        const dataArr = new Uint8Array(bufferLength);
        analyser.getByteFrequencyData(dataArr);

        ctx2d.clearRect(0, 0, canvas.width, canvas.height);
        const barW = canvas.width / bufferLength;
        dataArr.forEach((val, i) => {
          const barH = (val / 255) * canvas.height;
          const x = i * barW;
          ctx2d.fillStyle = `hsl(${145 + (val / 255) * 30}, 70%, 55%)`;
          ctx2d.fillRect(x, canvas.height - barH, barW - 1, barH);
        });
        animFrameRef.current = requestAnimationFrame(draw);
      };
      draw();
    }).catch(() => {});

    return () => {
      cancelAnimationFrame(animFrameRef.current);
    };
  }, [state]);

  const handleSend = () => {
    if (state === 'recording') {
      stop();
    } else if (state === 'done' && audioBlob) {
      onSend(audioBlob, durationMs);
      reset();
    }
  };

  const handleCancel = () => {
    cancel();
    reset();
    onCancel();
  };

  // Auto-send when recording is stopped and blob is ready
  useEffect(() => {
    if (state === 'done' && audioBlob) {
      onSend(audioBlob, durationMs);
      reset();
    }
  }, [state, audioBlob]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div className="flex items-center gap-3 px-3 py-2 bg-buddy-surface/80 border border-buddy-surface-raised rounded-2xl">
      {/* Cancel */}
      <button onClick={handleCancel} className="p-1.5 text-buddy-red hover:bg-buddy-red/10 rounded-full transition-colors shrink-0">
        <X size={18} />
      </button>

      {/* Mic icon + waveform visualizer */}
      <div className="flex items-center gap-2 flex-1 min-w-0">
        <div className={`p-1.5 rounded-full shrink-0 ${state === 'recording' ? 'bg-buddy-red/20 animate-pulse' : 'bg-buddy-surface-raised'}`}>
          <Mic size={16} className={state === 'recording' ? 'text-buddy-red' : 'text-buddy-text-secondary'} />
        </div>
        {state === 'recording' ? (
          <canvas ref={canvasRef} width={120} height={30} className="flex-1 rounded-lg" />
        ) : (
          <div className="flex-1 h-7 bg-buddy-surface rounded-lg flex items-center px-2">
            {audioUrl && <audio src={audioUrl} controls className="h-6 w-full" />}
          </div>
        )}
      </div>

      {/* Duration */}
      <span className={`text-xs font-mono shrink-0 ${state === 'recording' ? 'text-buddy-red font-bold' : 'text-buddy-text-secondary'}`}>
        {formatDuration(durationMs)}
      </span>

      {/* Stop/Send */}
      <button
        onClick={handleSend}
        className="p-2 bg-buddy-green text-buddy-black rounded-full hover:scale-105 transition-all shrink-0"
      >
        {state === 'recording' ? <Square size={16} /> : <Send size={16} />}
      </button>
    </div>
  );
}
