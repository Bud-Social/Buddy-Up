/**
 * SoundPicker — bottom-sheet sound browser (trending + debounced search)
 * with one-at-a-time audio previews and a sound-vs-original volume slider.
 */
import { useCallback, useEffect, useRef, useState } from 'react';
import { Loader2, Music, Pause, Play, Search, Volume2, X } from 'lucide-react';
import { feedApi, type Sound, type SoundOrdering } from '@/api/feed';
import { formatMs } from '@/lib/createStudio';

export interface SelectedSound {
  id: string;
  name: string;
  artist: string;
  volume: number; // 0–100
}

interface SoundPickerProps {
  open: boolean;
  selected: SelectedSound | null;
  /** Whether the user's clip has original audio that will be kept underneath. */
  videoHasAudio?: boolean;
  onSelect: (sound: Sound | null, volume: number) => void;
  onVolumeChange?: (volume: number) => void;
  onClose: () => void;
}

const SEARCH_DEBOUNCE_MS = 300;

export function SoundPicker({ open, selected, videoHasAudio, onSelect, onVolumeChange, onClose }: SoundPickerProps) {
  const [query, setQuery] = useState('');
  const [ordering, setOrdering] = useState<SoundOrdering>('trending');
  const [results, setResults] = useState<Sound[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [fetchError, setFetchError] = useState(false);
  const [previewId, setPreviewId] = useState<string | null>(null);
  const [volume, setVolume] = useState(selected?.volume ?? 60);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Debounced fetch: search when there's a query, browse by ordering otherwise.
  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    setIsLoading(true);
    setFetchError(false);
    const timer = setTimeout(() => {
      feedApi
        .listSounds({ q: query.trim() || undefined, ordering: query.trim() ? undefined : ordering })
        .then((res) => {
          if (!cancelled) setResults(res.data || []);
        })
        .catch(() => {
          if (!cancelled) {
            setResults([]);
            setFetchError(true);
          }
        })
        .finally(() => {
          if (!cancelled) setIsLoading(false);
        });
    }, query.trim() ? SEARCH_DEBOUNCE_MS : 0);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [open, query, ordering]);

  // Stop playback when the sheet closes or unmounts.
  useEffect(() => {
    if (!open) audioRef.current?.pause();
    return () => {
      audioRef.current?.pause();
    };
  }, [open]);

  // Mirror an externally selected sound's volume into the slider.
  useEffect(() => {
    if (selected) setVolume(selected.volume);
  }, [selected]);

  const togglePreview = useCallback((sound: Sound) => {
    if (!audioRef.current) audioRef.current = new Audio();
    const el = audioRef.current;
    if (previewId === sound.id) {
      el.pause();
      setPreviewId(null);
      return;
    }
    el.src = sound.audio_url;
    el.volume = 0.8;
    el.currentTime = 0;
    el.play().then(
      () => setPreviewId(sound.id),
      () => setPreviewId(null),
    );
    el.onended = () => setPreviewId(null);
  }, [previewId]);

  const pick = (sound: Sound | null) => {
    audioRef.current?.pause();
    if (sound) feedApi.useSound(sound.id).catch(() => {});
    onSelect(sound, volume);
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center sm:items-center">
      <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full sm:max-w-md bg-buddy-surface-raised rounded-t-3xl sm:rounded-3xl shadow-2xl flex flex-col max-h-[82vh]">
        {/* Header */}
        <div className="flex items-center gap-2 px-4 pt-4 pb-2">
          <Music size={18} className="text-buddy-green" />
          <h2 className="font-heading font-semibold text-sm flex-1">Add sound</h2>
          <button onClick={onClose} className="p-1.5 rounded-full hover:bg-buddy-surface text-buddy-text-secondary" aria-label="Close sound picker">
            <X size={18} />
          </button>
        </div>

        {/* Original-audio-only default */}
        <div className="px-4 pb-2">
          <button
            onClick={() => pick(null)}
            className={`w-full flex items-center gap-2 px-3 py-2.5 rounded-xl text-sm transition-colors ${
              !selected ? 'bg-buddy-green/15 text-buddy-green font-semibold' : 'bg-buddy-surface text-buddy-text-primary hover:bg-buddy-surface-raised'
            }`}
          >
            <Volume2 size={15} />
            Original audio only
            {!selected && <span className="ml-auto text-[10px] font-bold">DEFAULT</span>}
          </button>
          {videoHasAudio && selected && (
            <p className="text-[11px] text-buddy-text-secondary mt-2 px-1">
              Your original audio is kept — the sound plays on top at {volume}%.
            </p>
          )}
        </div>

        {/* Search */}
        <div className="px-4 pb-2">
          <div className="flex items-center gap-2 bg-buddy-surface rounded-xl px-3 py-2">
            <Search size={15} className="text-buddy-text-secondary" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search sounds"
              className="flex-1 bg-transparent text-sm outline-none text-buddy-text-primary placeholder:text-buddy-text-secondary/50"
            />
            {query && (
              <button onClick={() => setQuery('')} aria-label="Clear search">
                <X size={14} className="text-buddy-text-secondary" />
              </button>
            )}
          </div>
          {!query.trim() && (
            <div className="flex gap-1 mt-2 bg-buddy-surface rounded-xl p-1 w-max">
              {(['trending', 'recent'] as const).map((o) => (
                <button
                  key={o}
                  onClick={() => setOrdering(o)}
                  className={`px-3 py-1 rounded-lg text-xs font-semibold capitalize transition-colors ${
                    ordering === o ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'
                  }`}
                >
                  {o}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Volume */}
        {selected && (
          <div className="px-4 pb-2">
            <div className="flex items-center gap-3">
              <Volume2 size={15} className="text-buddy-text-secondary shrink-0" />
              <input
                type="range"
                min={0}
                max={100}
                value={volume}
                onChange={(e) => {
                  const v = Number(e.target.value);
                  setVolume(v);
                  onVolumeChange?.(v);
                }}
                className="flex-1 accent-buddy-green"
                aria-label="Sound volume"
              />
              <span className="text-xs font-mono w-9 text-right">{volume}%</span>
            </div>
          </div>
        )}

        {/* Results */}
        <div className="flex-1 overflow-y-auto px-4 pb-6 space-y-1">
          {isLoading && (
            <div className="flex justify-center py-8">
              <Loader2 size={22} className="animate-spin text-buddy-green" />
            </div>
          )}
          {!isLoading && fetchError && (
            <p className="text-center text-sm text-buddy-text-secondary py-8">Could not load sounds. Try again.</p>
          )}
          {!isLoading && !fetchError && results.length === 0 && (
            <p className="text-center text-sm text-buddy-text-secondary py-8">
              {query.trim() ? 'No sounds match your search.' : 'No sounds yet — your original audio always works.'}
            </p>
          )}
          {!isLoading &&
            results.map((sound) => {
              const isSelected = selected?.id === sound.id;
              const isPreviewing = previewId === sound.id;
              return (
                <div
                  key={sound.id}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-colors ${isSelected ? 'bg-buddy-green/10' : 'hover:bg-buddy-surface'}`}
                >
                  <button
                    onClick={() => togglePreview(sound)}
                    className="p-2 rounded-full bg-buddy-surface-raised text-buddy-green hover:bg-buddy-green/20 transition-colors"
                    aria-label={isPreviewing ? `Pause preview of ${sound.name}` : `Preview ${sound.name}`}
                  >
                    {isPreviewing ? <Pause size={15} /> : <Play size={15} />}
                  </button>
                  <button onClick={() => pick(sound)} className="flex-1 min-w-0 text-left">
                    <p className={`text-sm truncate ${isSelected ? 'text-buddy-green font-semibold' : 'text-buddy-text-primary'}`}>
                      {sound.name}
                    </p>
                    <p className="text-[11px] text-buddy-text-secondary truncate">
                      {sound.artist} · {formatMs(sound.duration_ms)} · {sound.usage_count} uses
                    </p>
                  </button>
                  {isSelected && <span className="text-[10px] font-bold text-buddy-green shrink-0">SELECTED</span>}
                </div>
              );
            })}
        </div>
      </div>
    </div>
  );
}
