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

  useEffect(() => {
    start();
    return () => { cancel(); };
  }, []);

  useEffect(() => {
    if (state !== 'recording') {
      cancelAnimationFrame(animFrameRef.current);
      return;
    }

    let ctx: AudioContext | null = null;
    let source: MediaStreamAudioSourceNode | null = null;
    let analyser: AnalyserNode | null = null;
    let stream: MediaStream | null = null;

    navigator.mediaDevices.getUserMedia({ audio: true }).then((s) => {
      stream = s;
      ctx = new AudioContext();
      source = ctx.createMediaStreamSource(s);
      analyser = ctx.createAnalyser();
      analyser.fftSize = 64;
      source.connect(analyser);

      const draw = () => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx2d = canvas.getContext('2d');
        if (!ctx2d) return;
        if (!analyser) return;
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
      if (source) source.disconnect();
      if (ctx) ctx.close();
      if (stream) stream.getTracks().forEach((t) => t.stop());
    };
  }, [state]);

  const handleSend = () => {
    if (state === 'recording') {
      stop();
    }
  };

  useEffect(() => {
    if (state === 'done' && audioBlob) {
      onSend(audioBlob, durationMs);
      reset();
    }
  }, [state, audioBlob]);

  const handleCancel = () => {
    cancel();
    reset();
    onCancel();
  };

  return (
    <div className="flex items-center gap-3 px-3 py-2 bg-buddy-surface/80 border border-buddy-surface-raised rounded-2xl">
      <button onClick={handleCancel} className="p-1.5 text-buddy-red hover:bg-buddy-red/10 rounded-full transition-colors shrink-0 self-center">
        <X size={18} />
      </button>

      <div className="flex items-center gap-2 flex-1 min-w-0">
        <div className={`p-1.5 rounded-full shrink-0 self-center ${state === 'recording' ? 'bg-buddy-red/20 animate-pulse' : 'bg-buddy-surface-raised'}`}>
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

      <span className={`text-xs font-mono shrink-0 self-center ${state === 'recording' ? 'text-buddy-red font-bold' : 'text-buddy-text-secondary'}`}>
        {formatDuration(durationMs)}
      </span>

      <button
        onClick={handleSend}
        className="p-2 bg-buddy-green text-buddy-black rounded-full hover:scale-105 transition-all shrink-0 self-center"
      >
        {state === 'recording' ? <Square size={16} /> : <Send size={16} />}
      </button>
    </div>
  );
}
