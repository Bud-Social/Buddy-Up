import { useEffect } from 'react';

export function useInViewAutoplay(
  ref: React.RefObject<HTMLVideoElement | null>,
  enabled = true,
  threshold = 0.6,
) {
  useEffect(() => {
    const el = ref.current;
    if (!el || !enabled) return;
    let inView = false;
    const obs = new IntersectionObserver(
      ([entry]) => {
        inView = entry.isIntersecting && entry.intersectionRatio >= threshold;
        if (inView) el.play().catch(() => {});
        else el.pause();
      },
      { threshold },
    );
    obs.observe(el);
    const onPlay = () => { if (!inView) el.pause(); };
    el.addEventListener('play', onPlay);
    return () => {
      obs.disconnect();
      el.removeEventListener('play', onPlay);
      el.pause();
    };
  }, [ref, enabled, threshold]);
}
