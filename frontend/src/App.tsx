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

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function AuthInitializer({ children }: { children: React.ReactNode }) {
  const { setUser, _logout, setLoading, isAuthenticated } = useAuthStore();

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
