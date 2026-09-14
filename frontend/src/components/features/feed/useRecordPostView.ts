import { useCallback, useEffect, useState } from 'react';
import { feedApi } from '@/api/feed';

// Once per post per session. Module-level so every mounted instance shares it.
const recordedThisSession = new Set<string>();

/** Test-only reset for the session dedupe set. */
export function __resetRecordedViewsForTests() {
  recordedThisSession.clear();
}

interface RecordViewOpts {
  /** The post is the focused/playing item (active fullscreen slide, etc.). */
  active: boolean;
  /** Playback progress 0..1 (or 0 when there is no media element). */
  progress?: number;
  /** Fraction of progress that counts as a view. Default 0.25. */
  progressThreshold?: number;
  /** Milliseconds of in-view active time that counts as a view. Default 2000. */
  activeMs?: number;
  /** IntersectionObserver threshold. Default 0.5. */
  inViewThreshold?: number;
  /** Called with the authoritative count after a successful record. */
  onRecorded?: (viewCount: number) => void;
}

/**
 * Records a qualified post view: the element is in view AND the post has
 * >= `activeMs` of active time OR >= `progressThreshold` playback progress.
 * Fires at most once per post per session; failures are silent.
 *
 * Returns a callback ref to attach to the post's container element.
 */
export function useRecordPostView(
  postId: string | undefined,
  { active, progress = 0, progressThreshold = 0.25, activeMs = 2000, inViewThreshold = 0.5, onRecorded }: RecordViewOpts,
): (node: HTMLDivElement | null) => void {
  const [el, setEl] = useState<HTMLDivElement | null>(null);
  const [inView, setInView] = useState(false);
  const ref = useCallback((node: HTMLDivElement | null) => setEl(node), []);

  useEffect(() => {
    if (!el || !postId) return;
    if (typeof IntersectionObserver === 'undefined') {
      setInView(true);
      return;
    }
    const obs = new IntersectionObserver(
      ([entry]) => setInView(entry.isIntersecting),
      { threshold: inViewThreshold },
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [el, postId, inViewThreshold]);

  const qualifiedByProgress = progress >= progressThreshold;

  useEffect(() => {
    if (!postId || !active || !inView) return;
    if (recordedThisSession.has(postId)) return;
    if (!qualifiedByProgress) {
      const t = setTimeout(() => {
        if (recordedThisSession.has(postId)) return;
        recordedThisSession.add(postId);
        feedApi.recordView(postId).then((res) => {
          const n = res.data?.view_count;
          if (typeof n === 'number') onRecorded?.(n);
        }).catch(() => {});
      }, activeMs);
      return () => clearTimeout(t);
    }
    recordedThisSession.add(postId);
    feedApi.recordView(postId).then((res) => {
      const n = res.data?.view_count;
      if (typeof n === 'number') onRecorded?.(n);
    }).catch(() => {});
  }, [postId, active, inView, qualifiedByProgress, activeMs, onRecorded]);

  return ref;
}
