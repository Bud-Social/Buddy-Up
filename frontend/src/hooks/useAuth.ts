import { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';
import { authApi } from '@/api';

const PUBLIC_ROUTES = ['/', '/login', '/signup', '/verify-age', '/forgot-password', '/terms', '/privacy', '/community-guidelines', '/cookie-policy', '/medical-disclaimer', '/sponsorship-policy', '/adult-content-policy'];

export function useAuthRequired() {
  const { isAuthenticated, isLoading, setUser, logout, setLoading, setTokens } = useAuthStore();
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      const refreshToken = useAuthStore.getState().refreshToken;
      if (!refreshToken) {
        setLoading(false);
        if (!PUBLIC_ROUTES.includes(location.pathname) && !location.pathname.startsWith('/:')) {
          navigate('/login');
        }
        return;
      }
      try {
        const res = await authApi.refreshToken(refreshToken);
        setTokens(res.data.access, refreshToken);
        const profileRes = await import('@/api').then((m) => m.profilesApi.getMyProfile());
        if (profileRes.data) {
          const user = useAuthStore.getState().user;
          setUser(user!, profileRes.data);
        }
      } catch {
        logout();
        if (!PUBLIC_ROUTES.includes(location.pathname)) navigate('/login');
      } finally {
        setLoading(false);
      }
    };
    checkAuth();
  }, []);

  return { isAuthenticated, isLoading };
}
