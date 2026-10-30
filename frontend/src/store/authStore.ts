import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { wsManager } from '@/lib/wsManager';
import type { User, Profile } from '@/types';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8002/api/v1';

interface AuthState {
  isAuthenticated: boolean;
  accessToken: string | null;
  refreshToken: string | null;
  user: User | null;
  profile: Profile | null;
  isLoading: boolean;
  /**
   * Short-lived credential that lets a staff member who cannot yet hold a
   * session enrol two-factor authentication.
   *
   * Held in memory only -- never persisted. It is not a session, it is good for
   * ten minutes, and it authorises exactly two endpoints, so putting it in
   * localStorage would be storing a credential with no benefit and a real cost
   * if the origin is ever compromised.
   */
  totpEnrolmentToken: string | null;
  setTokens: (access: string, refresh: string | null) => void;
  setTotpEnrolmentToken: (token: string | null) => void;
  setAccessToken: (access: string) => void;
  setUser: (user: User, profile: Profile) => void;
  setProfile: (profile: Profile) => void;
  logout: () => void;
  setLoading: (loading: boolean) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      isAuthenticated: false, accessToken: null, refreshToken: null, user: null, profile: null, isLoading: true,
      totpEnrolmentToken: null,
      setTotpEnrolmentToken: (token) => set({ totpEnrolmentToken: token }),
      setTokens: (access, refresh) => {
        wsManager.setAccessToken(access);
        set({ accessToken: access, refreshToken: refresh, isAuthenticated: true });
      },
      setAccessToken: (access) => {
        wsManager.setAccessToken(access);
        set({ accessToken: access });
      },
      setUser: (user, profile) => set({ user, profile, isAuthenticated: true, isLoading: false }),
      setProfile: (profile) => set({ profile }),
      logout: () => {
        wsManager.setAccessToken(null);
        set({ totpEnrolmentToken: null });
        wsManager.disconnectAll();
        // Server side: deactivate the device session and clear the httpOnly
        // refresh cookie. Fire-and-forget plain fetch (no custom headers, so
        // no preflight) — it must succeed even when the access token is
        // already gone; the backend deactivates by cookie/body token hash.
        try {
          fetch(`${API_BASE_URL}/auth/logout/`, {
            method: 'POST',
            credentials: 'include',
            keepalive: true,
          }).catch(() => undefined);
        } catch { /* noop — local logout must never fail */ }
        // Purge service-worker runtime caches so no authenticated response
        // survives logout on disk (shared-device hygiene). Also clears caches
        // written by older SW versions that cached /api/ responses.
        if (typeof caches !== 'undefined') {
          caches.delete('api-cache-v3');
          caches.delete('navigation-cache-v3');
        }
        set({ isAuthenticated: false, accessToken: null, refreshToken: null, user: null, profile: null, isLoading: false });
      },
      setLoading: (loading) => set({ isLoading: loading }),
    }),
    {
      name: 'buddyup-auth',
      // SECURITY: accessToken is persisted so the session survives navigation
      // and page reloads. The refresh token lives in an httpOnly cookie set by
      // the backend and is used to re-mint the access token on boot.
      partialize: (state) => ({
        isAuthenticated: state.isAuthenticated,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        user: state.user,
        profile: state.profile,
      }),
      onRehydrateStorage: (state) => {
        // Feed the persisted access token into wsManager so live sockets
        // re-handshake with the new credential immediately on rehydration.
        if (state?.accessToken) {
          wsManager.setAccessToken(state.accessToken);
        }
      },
    }
  )
);
