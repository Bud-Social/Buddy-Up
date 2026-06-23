import { create } from 'zustand';

interface PresenceData { user_id: string; is_online: boolean; last_active: string | null; }

interface PresenceState {
  presences: Record<string, PresenceData>;
  setPresence: (user_id: string, data: PresenceData) => void;
  setOnline: (user_id: string, is_online: boolean) => void;
  removePresence: (user_id: string) => void;
}

export const usePresenceStore = create<PresenceState>((set) => ({
  presences: {},
  setPresence: (user_id, data) => set((s) => ({ presences: { ...s.presences, [user_id]: data } })),
  setOnline: (user_id, is_online) => set((s) => {
    const ex = s.presences[user_id];
    return { presences: { ...s.presences, [user_id]: { ...ex, user_id, is_online, last_active: is_online ? ex?.last_active ?? null : new Date().toISOString() } } };
  }),
  removePresence: (user_id) => set((s) => { const n = { ...s.presences }; delete n[user_id]; return { presences: n }; }),
}));
