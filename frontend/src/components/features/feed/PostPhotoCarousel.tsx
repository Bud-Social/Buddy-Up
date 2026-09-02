/**
 * PostPhotoCarousel — photo-mode pages for multi-media Bud Press posts:
 * horizontal scroll-snap pages, tap to advance, "2/5" counter, caption
 * pinned at the bottom. Video pages autoplay muted while visible.
 */
import { useMemo, useRef, useState } from 'react';
import { useInViewAutoplay } from '@/hooks/useInViewAutoplay';
import { mediaPagesFromPost, type MediaPage } from '@/lib/mediaPages';
import type { Post } from '@/types';

function PhotoModeVideo({ page }: { page: MediaPage }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [muted, setMuted] = useState(true);
  useInViewAutoplay(videoRef, true, 0.5);
  return (
    <video
      ref={videoRef}
      src={page.url}
      poster={page.poster_url ?? undefined}
      muted={muted}
      loop
      playsInline
      preload="metadata"
      onClick={(e) => { e.stopPropagation(); setMuted((m) => !m); }}
      className="absolute inset-0 w-full h-full object-contain bg-black"
    />
  );
}

export function PostPhotoCarousel({
  post, className, counterClassName = 'top-3 right-3',
}: {
  post: Post;
  className?: string;
  /** Offset override when a host header occupies the top-right corner. */
  counterClassName?: string;
}) {
  const pages = useMemo(() => mediaPagesFromPost(post), [post]);
  const [idx, setIdx] = useState(0);
  const trackRef = useRef<HTMLDivElement>(null);

  const onScroll = () => {
    const el = trackRef.current;
    if (!el || el.clientWidth === 0) return;
    const next = Math.round(el.scrollLeft / el.clientWidth);
    if (next !== idx && next >= 0 && next < pages.length) setIdx(next);
  };

  const advance = () => {
    const el = trackRef.current;
    if (!el || idx >= pages.length - 1) return;
    el.scrollTo({ left: (idx + 1) * el.clientWidth, behavior: 'smooth' });
  };

  return (
    <div className={`relative ${className ?? ''}`}>
      <div
        ref={trackRef}
        onScroll={onScroll}
        onClick={advance}
        className="flex h-full w-full overflow-x-auto snap-x snap-mandatory scrollbar-none"
      >
        {pages.map((p, i) => (
          <div key={`${p.url}-${i}`} className="relative w-full h-full shrink-0 snap-center snap-always bg-black">
            {p.type === 'video' ? (
              <PhotoModeVideo page={p} />
            ) : (
              <img
                src={p.url}
                alt={p.alt_text ?? ''}
                loading="lazy"
                className="absolute inset-0 w-full h-full object-contain"
              />
            )}
          </div>
        ))}
      </div>

      {pages.length > 1 && (
        <span className={`absolute z-10 px-2 py-0.5 rounded-full bg-black/60 text-white text-[11px] font-bold pointer-events-none ${counterClassName}`}>
          {idx + 1}/{pages.length}
        </span>
      )}

      {post.body && (
        <p className="absolute bottom-3 left-3 right-14 z-10 text-white/90 text-xs line-clamp-2 drop-shadow pointer-events-none">
          {post.body}
        </p>
      )}
    </div>
  );
}
