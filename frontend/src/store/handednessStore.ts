import { create } from 'zustand';

export type Handedness = 'right' | 'left';

interface HandednessState {
  handedness: Handedness;
  setHandedness: (value: Handedness) => void;
}

const STORAGE_KEY = 'buddyup-handedness';

const getInit = (): Handedness => {
  if (typeof window === 'undefined') return 'right';
  try {
    return window.localStorage.getItem(STORAGE_KEY) === 'left' ? 'left' : 'right';
  } catch {
    return 'right';
  }
};

/** Device-level left-handed mode. Post interaction rails move to the left
 *  side of the card so they sit under a left thumb. */
export const useHandednessStore = create<HandednessState>((set) => ({
  handedness: getInit(),
  setHandedness: (value) =>
    set(() => {
      try {
        window.localStorage.setItem(STORAGE_KEY, value);
      } catch {
        // Storage unavailable — the in-memory choice still applies this session.
      }
      return { handedness: value };
    }),
}));
