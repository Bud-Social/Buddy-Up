import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

/**
 * BrowserRouter does not scroll to `#hash` targets on navigation, so
 * in-app links like `/#showcase` silently do nothing. This mounts once
 * (inside SWrapper, so within router context on every route) and:
 * - scrolls to the hash target on navigation (with a retry for lazy pages),
 * - scrolls to top on plain pathname changes.
 */
export function ScrollToHash() {
  const { pathname, hash } = useLocation();

  useEffect(() => {
    if (!hash) {
      window.scrollTo(0, 0);
      return;
    }
    let attempts = 0;
    let timer: number | undefined;
    const tryScroll = () => {
      const el = document.querySelector(hash);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        return;
      }
      attempts += 1;
      if (attempts < 10) {
        timer = window.setTimeout(tryScroll, 150);
      }
    };
    tryScroll();
    return () => window.clearTimeout(timer);
  }, [pathname, hash]);

  return null;
}
