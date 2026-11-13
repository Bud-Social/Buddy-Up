import { useEffect, useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { Analytics } from '@vercel/analytics/react';
import { router } from './router';
import { ThemeProvider } from './components/layout/ThemeProvider';
import { ToastProvider } from './components/ui/Toast';
import { PWAUpdateBanner } from './components/PWAUpdateBanner';
import { useAuthStore } from './store/authStore';
import { refreshAccessToken, isAuthRefreshRejection } from './api/client';
import { useNotificationListener } from './hooks/useNotificationListener';
import { profilesApi } from './api';
import { X, MapPin, Smartphone } from 'lucide-react';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function LocationConsentDialog({ onClose }: { onClose: () => void }) {
  const [consentGiven, setConsentGiven] = useState(false);
  const [saving, setSaving] = useState(false);
  const [deviceName, setDeviceName] = useState('');

  useEffect(() => {
    const ua = navigator.userAgent;
    let name = 'Unknown Device';
    if (ua.includes('iPhone')) name = 'iPhone';
    else if (ua.includes('Android')) name = 'Android Device';
    else if (ua.includes('Windows')) name = 'Windows PC';
    else if (ua.includes('Macintosh')) name = 'Mac';
    else if (ua.includes('Linux')) name = 'Linux Device';
    setDeviceName(ua.length > 0 ? ua.substring(0, 100) : name);
  }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      await profilesApi.locationConsent({
        location_consent: consentGiven,
        device_name: deviceName,
      });
    } catch {
      // ignore errors — consent is best-effort
    } finally {
      setSaving(false);
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center">
      <div className="fixed inset-0 bg-black/80 backdrop-blur-md" onClick={onClose} />
      <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-8 w-full max-w-md z-[101] shadow-2xl">
        <div className="flex items-center justify-between mb-6">
          <h2 className="font-display text-xl font-bold text-buddy-text-primary">Help Us Improve BuddyUp</h2>
          <button onClick={onClose} className="text-buddy-text-secondary hover:text-buddy-text-primary">
            <X size={20} />
          </button>
        </div>

        <div className="space-y-6">
          <div className="flex items-start gap-3">
            <Smartphone size={28} className="text-buddy-green shrink-0 mt-0.5" />
            <div className="flex-1">
              <h3 className="font-medium text-buddy-text-primary">Device Information</h3>
              <p className="text-sm text-buddy-text-secondary">
                We automatically collect your device name ({deviceName}) to improve your experience. No consent needed.
              </p>
            </div>
          </div>

          <div className="bg-buddy-surface/50 rounded-xl p-4 border border-buddy-border">
            <div className="flex items-start gap-3">
              <MapPin size={28} className="text-buddy-green shrink-0 mt-0.5" />
              <div className="flex-1">
                <h3 className="font-medium text-buddy-text-primary">Location Sharing</h3>
                <p className="text-sm text-buddy-text-secondary">
                  Share your city and country so we can show you local events, buddies nearby, and location-relevant content.
                  You can change this anytime in settings.
                </p>
              </div>
            </div>
            <div className="mt-4">
              <label className="flex items-center gap-3 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={consentGiven}
                  onChange={(e) => setConsentGiven(e.target.checked)}
                  className="w-5 h-5 rounded border-buddy-border text-buddy-green focus:ring-buddy-green bg-buddy-surface"
                />
                <span className="text-sm text-buddy-text-primary">I consent to sharing my location</span>
              </label>
            </div>
          </div>

          <div className="pt-4 flex gap-3">
            <button
              onClick={handleSave}
              disabled={saving}
              className={`flex-1 py-3 rounded-xl text-sm font-medium transition-colors disabled:opacity-50 ${
                saving ? 'bg-buddy-surface text-buddy-text-secondary' : 'bg-buddy-green text-buddy-black hover:bg-buddy-green/90'
              }`}
            >
              {saving ? 'Saving…' : 'Continue'}
            </button>
            <button
              onClick={() => { setConsentGiven(false); handleSave(); }}
              className="flex-1 py-3 rounded-xl text-sm font-medium transition-colors bg-buddy-surface text-buddy-text-secondary hover:bg-buddy-surface/80 border border-buddy-border"
            >
              Skip for Now
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function AuthInitializer({ children }: { children: React.ReactNode }) {
  const { setUser, _logout, setLoading, isAuthenticated } = useAuthStore();
  const [showLocationConsent, setShowLocationConsent] = useState(false);

  useEffect(() => {
    const init = async () => {
      if (!isAuthenticated) {
        setLoading(false);
        return;
      }
      // Show once only — persisted to localStorage after first view
      if (localStorage.getItem('locationConsentSeen') === '1') {
        setLoading(false);
        return;
      }
      try {
        if (!useAuthStore.getState().accessToken) {
          await refreshAccessToken();
        }
        const profileRes = await import('@/api').then((m) => m.profilesApi.getMyProfile());
        const user = useAuthStore.getState().user;
        if (profileRes.data && user) {
          setUser(user, profileRes.data);
          if (!profileRes.data.location_consent) {
            setShowLocationConsent(true);
          }
        }
      } catch (e) {
        if (isAuthRefreshRejection(e)) {
          setLoading(false);
          return;
        }
      } finally {
        localStorage.setItem('locationConsentSeen', '1');
        setLoading(false);
      }
    };
    init();
  }, []);

  useNotificationListener();
  return (
    <>
      {children}
      {showLocationConsent && <LocationConsentDialog onClose={() => setShowLocationConsent(false)} />}
    </>
  );
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <ToastProvider>
          <AuthInitializer>
            <RouterProvider router={router} />
            <PWAUpdateBanner />
            <Analytics />
          </AuthInitializer>
        </ToastProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}
