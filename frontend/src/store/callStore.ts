import { create } from 'zustand';

export interface PendingCall {
  conversation_id: string;
  from_user_id: string;
  from_username: string;
  from_display_name: string;
  from_avatar_url: string;
  call_type: 'audio' | 'video';
  data: any; // SDP offer
}

interface CallState {
  pendingCall: PendingCall | null;
  setPendingCall: (call: PendingCall | null) => void;
}

export const useCallStore = create<CallState>((set) => ({
  pendingCall: null,
  setPendingCall: (call) => set({ pendingCall: call }),
}));
