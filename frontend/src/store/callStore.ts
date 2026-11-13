import { create } from 'zustand';

export interface PendingCallParticipant {
  user_id?: string;
  display_name?: string;
  username?: string;
  avatar_url?: string;
}

export interface PendingCall {
  conversation_id: string;
  session_id?: string;
  from_user_id: string;
  from_username: string;
  from_display_name: string;
  from_avatar_url: string;
  call_type: 'audio' | 'video';
  /** Set when a third person is pulled into a live call. */
  is_buddies_call?: boolean;
  participants?: PendingCallParticipant[];
  data?: unknown; // legacy SDP offer (old WebRTC flow)
}

/** An invite the user accepted; Messages.tsx picks this up to join the room. */
export interface AcceptedCallInvite {
  conversation_id: string;
  session_id?: string;
  call_type: 'audio' | 'video';
}

interface RemoteEndSignal {
  conversation_id: string;
  session_id?: string;
}

interface CallState {
  pendingCall: PendingCall | null;
  setPendingCall: (call: PendingCall | null) => void;
  acceptedInvite: AcceptedCallInvite | null;
  setAcceptedInvite: (invite: AcceptedCallInvite | null) => void;
  /** Set when the backend ends a session this client is part of (e.g. the
   *  last-but-one participant left). Messages.tsx answers by leaving the room. */
  remoteEnd: RemoteEndSignal | null;
  setRemoteEnd: (signal: RemoteEndSignal | null) => void;
}

export const useCallStore = create<CallState>((set) => ({
  pendingCall: null,
  setPendingCall: (call) => set({ pendingCall: call }),
  acceptedInvite: null,
  setAcceptedInvite: (invite) => set({ acceptedInvite: invite }),
  remoteEnd: null,
  setRemoteEnd: (signal) => set({ remoteEnd: signal }),
}));
