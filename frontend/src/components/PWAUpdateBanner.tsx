import { useCallback, useEffect, useState } from 'react';
import { verifyOnline } from '@/lib/connectivity';

const RECHECK_INTERVAL_MS = 30000;

export function PWAUpdateBanner() {
  const [needsUpdate, setNeedsUpdate] = useState(false);
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);
  const [offline, setOffline] = useState(false);

  // Confirm real connectivity: navigator.onLine alone false-positives, so a
  // failed heartbeat is required before showing persistent offline UI.
  const recheck = useCallback(async () => {
    if (navigator.onLine) {
      setOffline(false);
      return;
    }
    setOffline(!(await verifyOnline()));
  }, []);

  useEffect(() => {
    void recheck();
    const onOnline = () => setOffline(false);
    const onOffline = () => void recheck();
    window.addEventListener('online', onOnline);
    window.addEventListener('offline', onOffline);
    const interval = setInterval(() => void recheck(), RECHECK_INTERVAL_MS);
    return () => {
      window.removeEventListener('online', onOnline);
      window.removeEventListener('offline', onOffline);
      clearInterval(interval);
    };
  }, [recheck]);

  useEffect(() => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistration().then((reg) => {
        if (reg) {
          setRegistration(reg);
          reg.addEventListener('updatefound', () => {
            reg.installing?.addEventListener('statechange', () => {
              if (reg.installing?.state === 'installed' && navigator.serviceWorker.controller) {
                setNeedsUpdate(true);
              }
            });
          });
        }
      });
    }
  }, []);

  const update = () => {
    if (registration?.waiting) {
      registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      // Wait for the new worker to take control before reloading —
      // reloading immediately races it and the old worker keeps control.
      const done = () => window.location.reload();
      const timeout = setTimeout(done, 2000);
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        clearTimeout(timeout);
        done();
      }, { once: true });
    } else {
      // No waiting worker (e.g. stuck predecessor): force a fresh check,
      // then reload into whatever is newest.
      registration?.update().catch(() => undefined);
      setTimeout(() => window.location.reload(), 1500);
    }
  };

  if (offline) {
    return (
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-buddy-red/90 text-white text-xs text-center py-2 px-4 backdrop-blur-sm">
        You are offline — some features may be unavailable.
      </div>
    );
  }

  if (needsUpdate) {
    return (
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-buddy-green/90 text-buddy-black text-xs text-center py-2 px-4 backdrop-blur-sm">
        <span>A new version is available. </span>
        <button onClick={update} className="underline font-semibold cursor-pointer bg-transparent border-none text-inherit">
          Update now
        </button>
      </div>
    );
  }

  return null;
}
