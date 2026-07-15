import { useEffect, useState } from 'react';

export function PWAUpdateBanner() {
  const [needsUpdate, setNeedsUpdate] = useState(false);
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);
  const [offline, setOffline] = useState(!navigator.onLine);

  useEffect(() => {
    const onOnline = () => setOffline(false);
    const onOffline = () => setOffline(true);
    window.addEventListener('online', onOnline);
    window.addEventListener('offline', onOffline);
    return () => {
      window.removeEventListener('online', onOnline);
      window.removeEventListener('offline', onOffline);
    };
  }, []);

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
    registration?.waiting?.postMessage({ type: 'SKIP_WAITING' });
    window.location.reload();
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
