import { useState, useEffect } from 'react';
export function useMediaQuery(query: string): boolean {
  const [m, setM] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia(query);
    setM(mq.matches);
    const fn = (e: MediaQueryListEvent) => setM(e.matches);
    mq.addEventListener('change', fn);
    return () => mq.removeEventListener('change', fn);
  }, [query]);
  return m;
}
