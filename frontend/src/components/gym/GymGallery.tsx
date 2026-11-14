import { useState } from 'react';
import { Play, X, Images } from 'lucide-react';
import { Modal } from '@/components/ui/Modal';
import type { GymMediaItem } from '@/types/gym';

/**
 * "Inside the gym" — the gallery of photos and videos owners upload.
 *
 * Visitors deciding whether to join look here first; the card is deliberately
 * the loudest thing on the page after the hero. Horizontal snap scroll of
 * thumbnails, click to open a full-size viewer (photos and videos alike).
 */
export function GymGallery({ items }: { items: GymMediaItem[] }) {
  const [viewer, setViewer] = useState<GymMediaItem | null>(null);

  if (!items.length) return null;

  return (
    <div className="mb-4">
      <div className="flex items-center justify-between mb-1.5">
        <h2 className="text-sm font-bold text-buddy-text-secondary uppercase flex items-center gap-1.5">
          <Images size={13} /> Inside the gym
        </h2>
        <span className="text-[10px] text-buddy-text-secondary">
          {items.length} item{items.length === 1 ? '' : 's'}
        </span>
      </div>

      <div className="-mx-4 px-4 overflow-x-auto scrollbar-hide">
        <div className="flex gap-2 snap-x snap-mandatory min-w-max pb-1">
          {items.map((item) => (
            <button
              key={item.id}
              type="button"
              onClick={() => setViewer(item)}
              className="snap-start relative w-44 h-28 rounded-xl overflow-hidden bg-buddy-surface-raised flex-shrink-0 group text-left"
              aria-label={item.kind === 'video' ? 'Play video' : 'View photo'}
            >
              {item.kind === 'video' ? (
                <>
                  {item.thumbnail_url
                    ? <img src={item.thumbnail_url} alt={item.caption || 'Gym video'} className="w-full h-full object-cover" loading="lazy" />
                    : <video src={item.file_url} className="w-full h-full object-cover" muted playsInline preload="metadata" />}
                  <span className="absolute inset-0 flex items-center justify-center bg-black/25 group-hover:bg-black/40 transition-colors">
                    <span className="w-9 h-9 rounded-full bg-black/60 flex items-center justify-center">
                      <Play size={16} className="text-white fill-white ml-0.5" />
                    </span>
                  </span>
                  <span className="absolute bottom-1.5 right-1.5 text-[9px] font-semibold bg-black/70 text-white px-1.5 py-0.5 rounded">
                    VIDEO
                  </span>
                </>
              ) : (
                <img
                  src={item.thumbnail_url || item.file_url}
                  alt={item.caption || 'Gym photo'}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  loading="lazy"
                />
              )}
              {item.caption && (
                <span className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent px-2 pt-4 pb-1.5 text-[10px] text-white truncate">
                  {item.caption}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      <Modal
        isOpen={!!viewer}
        onClose={() => setViewer(null)}
        title={viewer?.caption || (viewer?.kind === 'video' ? 'Gym video' : 'Gym photo')}
        size="lg"
      >
        {viewer && (
          <div className="space-y-2">
            {viewer.kind === 'video' ? (
              <video
                src={viewer.file_url}
                poster={viewer.thumbnail_url || undefined}
                controls
                autoPlay
                className="w-full max-h-[70vh] rounded-xl bg-black"
              />
            ) : (
              <img
                src={viewer.file_url}
                alt={viewer.caption || 'Gym photo'}
                className="w-full max-h-[70vh] object-contain rounded-xl bg-buddy-surface-raised"
              />
            )}
            <button
              type="button"
              onClick={() => setViewer(null)}
              className="w-full flex items-center justify-center gap-2 text-xs text-buddy-text-secondary py-2 hover:text-buddy-text-primary"
            >
              <X size={12} /> Close
            </button>
          </div>
        )}
      </Modal>
    </div>
  );
}

export default GymGallery;
