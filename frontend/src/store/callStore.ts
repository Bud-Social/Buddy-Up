import { create } from 'zustand';

export interface PendingCall {
  conversation_id: string;
  session_id?: string;
  from_user_id: string;
  from_username: string;
  from_display_name: string;
  from_avatar_url: string;
  call_type: 'audio' | 'video';
  data?: unknown; // legacy SDP offer (old WebRTC flow)
}

/** An invite the user accepted; Messages.tsx picks this up to join the room. */
export interface AcceptedCallInvite {
  conversation_id: string;
  session_id?: string;
  call_type: 'audio' | 'video';
}

interface CallState {
  pendingCall: PendingCall | null;
  setPendingCall: (call: PendingCall | null) => void;
  acceptedInvite: AcceptedCallInvite | null;
  setAcceptedInvite: (invite: AcceptedCallInvite | null) => void;
}

export const useCallStore = create<CallState>((set) => ({
  pendingCall: null,
  setPendingCall: (call) => set({ pendingCall: call }),
  acceptedInvite: null,
  setAcceptedInvite: (invite) => set({ acceptedInvite: invite }),
}));
