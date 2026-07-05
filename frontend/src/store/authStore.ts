import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { wsManager } from '@/lib/wsManager';
import type { User, Profile } from '@/types';

interface AuthState {
  isAuthenticated: boolean;
  accessToken: string | null;
  refreshToken: string | null;
  user: User | null;
  profile: Profile | null;
  isLoading: boolean;
  setTokens: (access: string, refresh: string) => void;
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
        set({ isAuthenticated: false, accessToken: null, refreshToken: null, user: null, profile: null, isLoading: false });
      },
      setLoading: (loading) => set({ isLoading: loading }),
    }),
    {
      name: 'buddyup-auth',
      partialize: (state) => ({
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        user: state.user,
        profile: state.profile,
      }),
    }
  )
);
