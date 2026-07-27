import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface ConversationTheme {
  background: string;
  senderBubbleColor: string;
  receiverBubbleColor: string;
}

export interface ChatPreferences {
  background: string;
  senderBubbleColor: string;
  receiverBubbleColor: string;
  messageFontSize: number;
  perConversationThemes: Record<string, ConversationTheme>;
  setGlobalBackground: (bg: string) => void;
  setSenderBubbleColor: (c: string) => void;
  setReceiverBubbleColor: (c: string) => void;
  setMessageFontSize: (s: number) => void;
  setConversationTheme: (convId: string, theme: ConversationTheme) => void;
  resetConversationTheme: (convId: string) => void;
  resetAll: () => void;
}

export const DEFAULT_PREFERENCES = {
  background: '',
  senderBubbleColor: '',
  receiverBubbleColor: '',
  messageFontSize: 14,
  perConversationThemes: {},
};

export const BACKGROUND_PRESETS = [
  { label: 'None', value: '' },
  { label: 'Dark', value: '#1a1a2e' },
  { label: 'Navy', value: '#0f0c29' },
  { label: 'Forest', value: '#0b1a11' },
  { label: 'Warm', value: '#2d1b0e' },
  { label: 'Purple', value: '#1a0b2e' },
  { label: 'Slate', value: '#0f172a' },
  { label: 'Coal', value: '#1e1e1e' },
];

export const BUBBLE_COLOR_PRESETS = [
  { label: 'Green (default)', mine: '#bef264', theirs: '#2a2a2e' },
  { label: 'Blue', mine: '#60a5fa', theirs: '#1e3a5f' },
  { label: 'Purple', mine: '#a78bfa', theirs: '#2e1a47' },
  { label: 'Pink', mine: '#f472b6', theirs: '#4a1e3a' },
  { label: 'Teal', mine: '#5eead4', theirs: '#134e4a' },
  { label: 'Orange', mine: '#fb923c', theirs: '#4a2e0b' },
  { label: 'Red', mine: '#f87171', theirs: '#4a1a1a' },
  { label: 'White', mine: '#ffffff', theirs: '#3a3a3e' },
];

export const useChatPreferences = create<ChatPreferences>()(
  persist(
    (set) => ({
      ...DEFAULT_PREFERENCES,
      setGlobalBackground: (background) => set({ background }),
      setSenderBubbleColor: (senderBubbleColor) => set({ senderBubbleColor }),
      setReceiverBubbleColor: (receiverBubbleColor) => set({ receiverBubbleColor }),
      setMessageFontSize: (messageFontSize) => set({ messageFontSize }),
      setConversationTheme: (convId, theme) =>
        set((state) => ({
          perConversationThemes: { ...state.perConversationThemes, [convId]: theme },
        })),
      resetConversationTheme: (convId) =>
        set((state) => {
          const { [convId]: _, ...rest } = state.perConversationThemes;
          return { perConversationThemes: rest };
        }),
      resetAll: () => set({ ...DEFAULT_PREFERENCES }),
    }),
    { name: 'buddy-chat-preferences' },
  ),
);
