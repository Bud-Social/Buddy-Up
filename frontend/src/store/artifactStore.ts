import { create } from 'zustand';
import type { ArtifactBalance } from '@/types';

interface ArtifactState { balance: ArtifactBalance; isLoaded: boolean; setBalance: (b: ArtifactBalance) => void; updateBalance: (u: Partial<ArtifactBalance>) => void; clearBalance: () => void; }

const empty: ArtifactBalance = { dumbbell: 0, barbell: 0, burpee: 0, squat: 0, sprint: 0, pr: 0, champion: 0 };

export const useArtifactStore = create<ArtifactState>((set) => ({
  balance: empty, isLoaded: false,
  setBalance: (balance) => set({ balance, isLoaded: true }),
  updateBalance: (update) => set((s) => ({ balance: { ...s.balance, ...update } })),
  clearBalance: () => set({ balance: empty, isLoaded: false }),
}));
