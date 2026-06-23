import { useEffect } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { router } from './router';
import { ThemeProvider } from './components/layout/ThemeProvider';
import { useAuthStore } from './store/authStore';
import { authApi } from './api';

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
  const { setUser, logout, setLoading, setTokens, refreshToken } = useAuthStore();

  useEffect(() => {
    const init = async () => {
      if (!refreshToken) {
        setLoading(false);
        return;
      }
      try {
        const res = await authApi.refreshToken(refreshToken);
        setTokens(res.data.access, refreshToken);
        const profileRes = await import('@/api').then((m) => m.profilesApi.getMyProfile());
        const user = useAuthStore.getState().user;
        if (profileRes.data && user) {
          setUser(user, profileRes.data);
        }
      } catch {
        logout();
      } finally {
        setLoading(false);
      }
    };
    init();
  }, []);

  return <>{children}</>;
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <AuthInitializer>
          <RouterProvider router={router} />
        </AuthInitializer>
      </ThemeProvider>
    </QueryClientProvider>
  );
}
