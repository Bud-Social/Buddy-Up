import React, { useState, useRef, useEffect } from 'react';
import { Play, Pause } from 'lucide-react';

interface CustomAudioPlayerProps {
  src: string;
  isMine: boolean;
}

export function CustomAudioPlayer({ src, isMine }: CustomAudioPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [playbackRate, setPlaybackRate] = useState(1);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateProgress = () => {
      setProgress((audio.currentTime / audio.duration) * 100);
    };

    const handleLoadedMetadata = () => {
      setDuration(audio.duration);
    };

    const handleEnded = () => {
      setIsPlaying(false);
      setProgress(0);
    };

    audio.addEventListener('timeupdate', updateProgress);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', updateProgress);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('ended', handleEnded);
    };
  }, []);

  const togglePlay = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (audioRef.current) {
      if (isPlaying) {
        audioRef.current.pause();
      } else {
        audioRef.current.play();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    e.stopPropagation();
    const newProgress = parseFloat(e.target.value);
    setProgress(newProgress);
    if (audioRef.current) {
      audioRef.current.currentTime = (newProgress / 100) * audioRef.current.duration;
    }
  };

  const toggleSpeed = (e: React.MouseEvent) => {
    e.stopPropagation();
    const nextRate = playbackRate === 1 ? 1.5 : playbackRate === 1.5 ? 2 : 1;
    setPlaybackRate(nextRate);
    if (audioRef.current) {
      audioRef.current.playbackRate = nextRate;
    }
  };

  const formatTime = (time: number) => {
    if (isNaN(time) || !isFinite(time)) return '0:00';
    const m = Math.floor(time / 60);
    const s = Math.floor(time % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  const currentTime = audioRef.current ? audioRef.current.currentTime : 0;

  return (
    <div className={`flex items-center gap-2 p-2 rounded-xl border ${isMine ? 'bg-buddy-black/10 border-buddy-black/20 text-buddy-black' : 'bg-buddy-surface border-buddy-text-secondary/20 text-buddy-text-primary'}`}>
      <button 
        onClick={togglePlay}
        className={`p-2 rounded-full shrink-0 flex items-center justify-center ${isMine ? 'bg-buddy-black text-buddy-green' : 'bg-buddy-green text-buddy-black'}`}
        style={{ width: 32, height: 32 }}
      >
        {isPlaying ? <Pause size={14} fill="currentColor" /> : <Play size={14} fill="currentColor" className="ml-0.5" />}
      </button>
      
      <div className="flex-1 flex flex-col gap-1 min-w-[100px]" onClick={e => e.stopPropagation()}>
        <input 
          type="range" 
          min="0" 
          max="100" 
          value={isNaN(progress) ? 0 : progress} 
          onChange={handleSeek}
          className="w-full h-1.5 bg-black/10 rounded-full appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-current"
        />
        <div className="flex justify-between text-[10px] opacity-70 font-medium px-0.5">
          <span>{formatTime(currentTime)}</span>
          <span>{formatTime(duration)}</span>
        </div>
      </div>

      <button 
        onClick={toggleSpeed}
        className={`text-[10px] font-bold px-1.5 py-0.5 rounded shrink-0 transition-colors ${isMine ? 'bg-buddy-black/20 hover:bg-buddy-black/30 text-buddy-black' : 'bg-buddy-green/20 hover:bg-buddy-green/30 text-buddy-green'}`}
      >
        {playbackRate}x
      </button>

      <audio ref={audioRef} src={src} className="hidden" />
    </div>
  );
}
