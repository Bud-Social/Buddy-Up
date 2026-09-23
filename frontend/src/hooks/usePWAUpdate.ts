import { useEffect, useState } from 'react';

interface PWAUpdateState {
  needsUpdate: boolean;
  update: () => void;
}

export function usePWAUpdate(): PWAUpdateState {
  const [needsUpdate, setNeedsUpdate] = useState(false);
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);

  useEffect(() => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistration().then((reg) => {
        if (reg) {
          setRegistration(reg);
          reg.addEventListener('updatefound', () => {
            const installing = reg.installing;
            if (installing) {
              installing.addEventListener('statechange', () => {
                if (installing.state === 'installed' && navigator.serviceWorker.controller) {
                  setNeedsUpdate(true);
                }
              });
            }
          });
        }
      });
    }
  }, []);

  const update = () => {
    if (registration && registration.waiting) {
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
      registration?.update().catch(() => undefined);
      setTimeout(() => window.location.reload(), 1500);
    }
  };

  return { needsUpdate, update };
}
