import { create } from 'zustand';
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

export const useAuthStore = create<AuthState>((set) => ({
  isAuthenticated: false, accessToken: null, refreshToken: null, user: null, profile: null, isLoading: true,
  setTokens: (access, refresh) => set({ accessToken: access, refreshToken: refresh, isAuthenticated: true }),
  setAccessToken: (access) => set({ accessToken: access }),
  setUser: (user, profile) => set({ user, profile, isAuthenticated: true, isLoading: false }),
  setProfile: (profile) => set({ profile }),
  logout: () => set({ isAuthenticated: false, accessToken: null, refreshToken: null, user: null, profile: null, isLoading: false }),
  setLoading: (loading) => set({ isLoading: loading }),
}));
