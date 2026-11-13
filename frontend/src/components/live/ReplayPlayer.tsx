import { lazy, Suspense, useEffect, useRef, useState } from 'react';
import { X, Loader, Share2, ChevronDown, Eye } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { livesApi } from '@/api/lives';

const MuxPlayer = lazy(() => import('@mux/mux-player-react'));

type ReplayVisibility = 'public' | 'buddies' | 'gym_members' | 'private';

interface ReplayPlayerProps {
  title: string;
  hostName: string;
  replayUrl: string;
  muxPlaybackId?: string;
  liveId?: string;
  access?: string;
  isHost?: boolean;
  onShareReplay?: () => void;
  onVisibilityChange?: (access: ReplayVisibility) => void;
  onClose: () => void;
}

const VISIBILITY_OPTIONS: Array<{ value: ReplayVisibility; label: string }> = [
  { value: 'public', label: 'Public — anyone' },
  { value: 'buddies', label: 'Buddies only' },
  { value: 'gym_members', label: 'Gym members' },
  { value: 'private', label: 'Only me' },
];

export default function ReplayPlayer({ title, hostName, replayUrl, muxPlaybackId, liveId, access, isHost, onShareReplay, onVisibilityChange, onClose }: ReplayPlayerProps) {
  const [isLoading, setIsLoading] = useState(true);
  const [useFallback, setUseFallback] = useState(false);
  const [visibility, setVisibility] = useState<ReplayVisibility>((access as ReplayVisibility) || 'public');
  const [showVisibility, setShowVisibility] = useState(false);
  const pinged = useRef(false);

  // Unique-per-viewer replay view: fire once per mount; the server dedupes.
  useEffect(() => {
    if (liveId && !pinged.current) {
      pinged.current = true;
      livesApi.recordReplayView(liveId).catch(() => {});
    }
  }, [liveId]);

  return (
    <div className="fixed inset-0 z-50 bg-buddy-black flex flex-col">
      <div className="flex items-center justify-between px-4 py-3 bg-buddy-black/80 backdrop-blur z-10">
        <div className="min-w-0">
          <h1 className="text-sm font-semibold truncate">{title}</h1>
          <p className="text-xs text-buddy-text-secondary">{hostName}</p>
        </div>
        <div className="flex items-center gap-1.5 shrink-0">
          {isHost && onShareReplay && (
            <Button variant="ghost" size="sm" className="gap-1.5" onClick={onShareReplay} title="Share this replay as a post">
              <Share2 size={16} /> Share
            </Button>
          )}
          {isHost && onVisibilityChange && (
            <div className="relative">
              <button
                onClick={() => setShowVisibility((v) => !v)}
                className="flex items-center gap-1.5 text-xs text-buddy-text-primary hover:text-buddy-text-primary bg-buddy-surface rounded-lg px-2.5 py-1.5"
                title="Who can watch this replay"
              >
                <Eye size={14} />
                {VISIBILITY_OPTIONS.find((o) => o.value === visibility)?.label.split(' —')[0]}
                <ChevronDown size={12} />
              </button>
              {showVisibility && (
                <div className="absolute right-0 top-full mt-1.5 z-20 w-44 bg-buddy-surface border border-buddy-surface-raised rounded-xl shadow-2xl overflow-hidden py-1">
                  {VISIBILITY_OPTIONS.map((opt) => (
                    <button key={opt.value}
                      onClick={() => { setVisibility(opt.value); onVisibilityChange(opt.value); setShowVisibility(false); }}
                      className={`w-full text-left text-xs px-3 py-2 hover:bg-buddy-surface-raised ${visibility === opt.value ? 'text-buddy-green' : 'text-buddy-text-primary'}`}
                    >{opt.label}</button>
                  ))}
                </div>
              )}
            </div>
          )}
          <Button variant="ghost" size="sm" onClick={onClose}>
            <X size={18} />
          </Button>
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center bg-black relative">
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center">
            <Loader size={32} className="animate-spin text-buddy-green" />
          </div>
        )}

        {muxPlaybackId && !useFallback ? (
          <Suspense fallback={null}>
            <MuxPlayer
              playbackId={muxPlaybackId}
              metadata={{ video_title: title }}
              accentColor="#22c55e"
              style={{ width: '100%', height: '100%', maxHeight: '100vh' }}
              onCanPlay={() => setIsLoading(false)}
              onError={() => setUseFallback(true)}
            />
          </Suspense>
        ) : (
          <video
            src={replayUrl}
            controls
            autoPlay
            className="w-full h-full max-h-screen object-contain"
            onCanPlay={() => setIsLoading(false)}
          >
            <p className="text-buddy-text-secondary p-4">Your browser doesn't support video playback.</p>
          </video>
        )}
      </div>
    </div>
  );
}
