import { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';
import { refreshAccessToken, isAuthRefreshRejection } from '@/api/client';

const PUBLIC_ROUTES = ['/', '/login', '/signup', '/verify-age', '/forgot-password', '/terms', '/privacy', '/community-guidelines', '/cookie-policy', '/medical-disclaimer', '/sponsorship-policy', '/adult-content-policy'];

export function useAuthRequired() {
  const { isAuthenticated, isLoading, setUser, logout, setLoading } = useAuthStore();
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      // Tokens are memory-only now: identity is persisted, access is
      // re-minted from the httpOnly refresh cookie.
      if (!isAuthenticated) {
        setLoading(false);
        if (!PUBLIC_ROUTES.includes(location.pathname) && !location.pathname.startsWith('/:')) {
          navigate('/login');
        }
        return;
      }
      try {
        if (!useAuthStore.getState().accessToken) {
          await refreshAccessToken();
        }
        const profileRes = await import('@/api').then((m) => m.profilesApi.getMyProfile());
        if (profileRes.data) {
          const user = useAuthStore.getState().user;
          if (user) setUser(user, profileRes.data);
        }
      } catch (e) {
        if (isAuthRefreshRejection(e)) {
          logout();
          if (!PUBLIC_ROUTES.includes(location.pathname)) navigate('/login');
        }
      } finally {
        setLoading(false);
      }
    };
    checkAuth();
  }, []);

  return { isAuthenticated, isLoading };
}
