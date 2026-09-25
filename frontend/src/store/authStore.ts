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
  setTokens: (access: string, refresh: string | null) => void;
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
      // SECURITY: tokens are never persisted. The long-lived refresh token
      // lives only in an httpOnly cookie (set by the backend); the 15-minute
      // access token stays in memory and is re-minted from the cookie on
      // boot. Only identity is persisted so the UI can render while the
      // silent boot refresh runs.
      partialize: (state) => ({
        isAuthenticated: state.isAuthenticated,
        user: state.user,
        profile: state.profile,
      }),
      onRehydrateStorage: () => () => {
        // No tokens exist at rehydration by design; App's AuthInitializer
        // mints an access token from the httpOnly cookie right after boot.
        // (Legacy sessions that still have a refreshToken in storage are
        // handled transparently by client.ts's refresh — it sends the body
        // token once, the backend rotates it and sets the cookie.)
      },
    }
  )
);
