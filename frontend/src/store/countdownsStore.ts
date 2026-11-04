import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { countdownsApi } from '@/api/countdowns';
import type { UserCountdown, CountdownTemplate, CreateUserCountdown } from '@/types/countdowns';

interface CountdownsState {
  templates: CountdownTemplate[];
  countdowns: UserCountdown[];
  loading: boolean;
  error: string | null;

  fetchTemplates: () => Promise<void>;
  fetchCountdowns: (is_active?: boolean) => Promise<void>;
  createCountdown: (payload: CreateUserCountdown) => Promise<UserCountdown>;
  checkIn: (id: string) => Promise<void>;
  resetCountdown: (id: string) => Promise<void>;
  updateCountdown: (id: string, payload: Partial<CreateUserCountdown>) => Promise<void>;
  deleteCountdown: (id: string) => Promise<void>;
  setTemplates: (templates: CountdownTemplate[]) => void;
}

export const useCountdownsStore = create<CountdownsState>()(
  persist(
    (set, get) => ({
      templates: [],
      countdowns: [],
      loading: false,
      error: null,

      fetchTemplates: async () => {
        set({ loading: true, error: null });
        try {
          const templates = await countdownsApi.listTemplates();
          set({ templates, loading: false });
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Failed to load templates', loading: false });
        }
      },

      fetchCountdowns: async (is_active) => {
        set({ loading: true, error: null });
        try {
          const countdowns = await countdownsApi.listCountdowns({ is_active });
          set({ countdowns, loading: false });
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Failed to load countdowns', loading: false });
        }
      },

      createCountdown: async (payload) => {
        set({ loading: true, error: null });
        try {
          const created = await countdownsApi.createCountdown(payload);
          set((state) => ({
            countdowns: [created, ...state.countdowns],
            loading: false,
          }));
          return created;
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Failed to create countdown', loading: false });
          throw err;
        }
      },

      checkIn: async (id) => {
        try {
          const updated = await countdownsApi.checkIn(id);
          set((state) => ({
            countdowns: state.countdowns.map((c) => (c.id === id ? updated : c)),
          }));
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Check-in failed' });
          throw err;
        }
      },

      resetCountdown: async (id) => {
        try {
          const updated = await countdownsApi.reset(id);
          set((state) => ({
            countdowns: state.countdowns.map((c) => (c.id === id ? updated : c)),
          }));
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Reset failed' });
          throw err;
        }
      },

      updateCountdown: async (id, payload) => {
        set({ loading: true, error: null });
        try {
          const updated = await countdownsApi.updateCountdown(id, payload);
          set((state) => ({
            countdowns: state.countdowns.map((c) => (c.id === id ? updated : c)),
            loading: false,
          }));
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Failed to update countdown', loading: false });
          throw err;
        }
      },

      deleteCountdown: async (id) => {
        set({ loading: true, error: null });
        try {
          await countdownsApi.deleteCountdown(id);
          set((state) => ({
            countdowns: state.countdowns.filter((c) => c.id !== id),
            loading: false,
          }));
        } catch (err: any) {
          set({ error: err?.response?.data?.message || 'Failed to delete countdown', loading: false });
          throw err;
        }
      },

      setTemplates: (templates) => set({ templates }),
    }),
    {
      name: 'buddyup-countdowns',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ templates: state.templates }),
    },
  ),
);
