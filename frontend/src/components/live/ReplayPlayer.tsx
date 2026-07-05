import { lazy, Suspense, useState } from 'react';
import { X, Play, Loader } from 'lucide-react';
import { Button } from '@/components/ui/Button';

const MuxPlayer = lazy(() => import('@mux/mux-player-react'));

interface ReplayPlayerProps {
  title: string;
  hostName: string;
  replayUrl: string;
  muxPlaybackId?: string;
  onClose: () => void;
}

export default function ReplayPlayer({ title, hostName, replayUrl, muxPlaybackId, onClose }: ReplayPlayerProps) {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className="fixed inset-0 z-50 bg-buddy-black flex flex-col">
      <div className="flex items-center justify-between px-4 py-3 bg-buddy-black/80 backdrop-blur z-10">
        <div className="min-w-0">
          <h1 className="text-sm font-semibold truncate">{title}</h1>
          <p className="text-xs text-buddy-text-secondary">{hostName}</p>
        </div>
        <Button variant="ghost" size="sm" onClick={onClose}>
          <X size={18} />
        </Button>
      </div>

      <div className="flex-1 flex items-center justify-center bg-black relative">
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center">
            <Loader size={32} className="animate-spin text-buddy-green" />
          </div>
        )}

        {muxPlaybackId ? (
          <Suspense fallback={null}>
            <MuxPlayer
              playbackId={muxPlaybackId}
              metadata={{ video_title: title }}
              accentColor="#22c55e"
              style={{ width: '100%', height: '100%', maxHeight: '100vh' }}
              onCanPlay={() => setIsLoading(false)}
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
