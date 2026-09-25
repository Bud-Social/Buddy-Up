import { useEffect } from 'react';
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
  const { setUser, logout, setLoading, isAuthenticated } = useAuthStore();

  useEffect(() => {
    const init = async () => {
      // Tokens are no longer persisted: a returning user is isAuthenticated
      // from storage but holds no access token. Mint one from the httpOnly
      // refresh cookie (legacy persisted tokens are handled inside the
      // refresh too). Not authenticated → straight to the public UI.
      if (!isAuthenticated) {
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
        // A definitive 4xx means the cookie/session is really gone.
        if (isAuthRefreshRejection(e)) logout();
      } finally {
        setLoading(false);
      }
    };
    init();
  }, []);

  useNotificationListener();
  return <>{children}</>;
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
