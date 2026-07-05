import { useEffect, useRef } from 'react';

interface VoiceIndicatorProps {
  audioTrack: MediaStreamTrack | null;
  isMicOn: boolean;
}

const BAR_COUNT = 10;
const BAR_WIDTH = 3;
const RADIUS = 16;
const GAIN = 2.5;

function logSpace(start: number, end: number, count: number): number[] {
  const ratio = end / start;
  const step = Math.log(ratio) / count;
  const bins: number[] = [];
  for (let i = 0; i < count; i++) {
    const low = Math.round(start * Math.exp(i * step));
    const high = Math.round(start * Math.exp((i + 1) * step));
    bins.push(high - low);
  }
  return bins;
}

export default function VoiceIndicator({ audioTrack, isMicOn }: VoiceIndicatorProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const rafRef = useRef<number>(0);
  const prevHeightsRef = useRef<number[]>(new Array(BAR_COUNT).fill(0));

  useEffect(() => {
    const bars = containerRef.current?.querySelectorAll<HTMLDivElement>('[data-bar]');
    if (!audioTrack || !isMicOn) {
      bars?.forEach((b) => { b.style.height = '0px'; b.style.opacity = '0.15'; });
      return;
    }

    const audioCtx = new AudioContext();
    if (audioCtx.state === 'suspended') audioCtx.resume();
    const analyser = audioCtx.createAnalyser();
    analyser.fftSize = 256;
    const source = audioCtx.createMediaStreamSource(new MediaStream([audioTrack]));
    source.connect(analyser);

    const bufferLength = analyser.frequencyBinCount; // 128
    const dataArray = new Uint8Array(bufferLength);
    const binSizes = logSpace(1, bufferLength, BAR_COUNT);
    const prev = prevHeightsRef.current;

    const draw = () => {
      analyser.getByteFrequencyData(dataArray);
      if (bars) {
        let binOffset = 0;
        for (let i = 0; i < bars.length && i < BAR_COUNT; i++) {
          const count = binSizes[i];
          let sum = 0;
          for (let j = 0; j < count && binOffset + j < bufferLength; j++) {
            sum += dataArray[binOffset + j] || 0;
          }
          binOffset += count;
          const raw = sum / count / 255;
          const boosted = Math.min(raw * GAIN, 1);
          const newHeight = Math.max(1, boosted * 14);
          const smoothed = prev[i] * 0.65 + newHeight * 0.35;
          prev[i] = smoothed;
          bars[i].style.height = `${smoothed}px`;
          bars[i].style.opacity = `${0.25 + boosted * 0.75}`;
        }
      }
      rafRef.current = requestAnimationFrame(draw);
    };
    draw();

    return () => {
      cancelAnimationFrame(rafRef.current);
      source.disconnect();
      audioCtx.close();
    };
  }, [audioTrack, isMicOn]);

  return (
    <div ref={containerRef} className="absolute inset-0 pointer-events-none" style={{ zIndex: 0 }}>
      {Array.from({ length: BAR_COUNT }).map((_, i) => {
        const angle = (i / BAR_COUNT) * 360;
        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: '50%',
              top: '50%',
              width: '0px',
              height: '0px',
              transform: `rotate(${angle}deg)`,
            }}
          >
            <div
              data-bar
              style={{
                position: 'absolute',
                left: `${-BAR_WIDTH / 2}px`,
                bottom: `${RADIUS}px`,
                width: `${BAR_WIDTH}px`,
                height: '0px',
                borderRadius: '1px',
                background: '#00C896',
                transformOrigin: 'center bottom',
                transition: 'height 0.04s linear, opacity 0.04s linear',
                opacity: '0.15',
              }}
            />
          </div>
        );
      })}
    </div>
  );
}
