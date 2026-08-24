/**
 * useLiveKitCall – multi-party audio/video calls for conversations,
 * powered by the self-hosted LiveKit SFU.
 *
 * Flow:
 *   join(conversationId, type)  → POST /calls/session/ (membership-checked,
 *                                 short-lived token) → connect room, publish media
 *   leave()                     → DELETE /calls/session/ (server ends session
 *                                 when last participant leaves)
 *
 * Participants are exposed as opaque objects so UI components can attach
 * tracks without importing livekit-client statically (keeps chunks lean).
 */
import { useCallback, useEffect, useRef, useState } from 'react';
import { messagingApi } from '@/api/messaging';
import { useAuthStore } from '@/store/authStore';

import type { CallSessionCredentials, CallParticipantInfo } from '@/api/messaging';

export type LkCallState = 'idle' | 'calling' | 'ringing' | 'in_call' | 'ended';

/** Minimal shape of a livekit participant we hand to the UI (opaque). */
export interface CallTile {
  identity: string;
  name: string;
  avatarUrl: string;
  isLocal: boolean;
  /** Opaque LocalParticipant | RemoteParticipant – attach tracks in the UI. */
  participant: unknown;
  isAudioEnabled: boolean;
  isVideoEnabled: boolean;
  isScreenSharing: boolean;
}

function flagsOf(participant: any): Pick<CallTile, 'isAudioEnabled' | 'isVideoEnabled' | 'isScreenSharing'> {
  const p = participant as {
    isMicrophoneEnabled?: boolean;
    isCameraEnabled?: boolean;
    getTrackPublication?: (src: string) => { isEnabled?: boolean } | undefined;
  };
  return {
    isAudioEnabled: p.isMicrophoneEnabled ?? false,
    isVideoEnabled: p.isCameraEnabled ?? false,
    isScreenSharing:
      !!p.getTrackPublication?.('screen_share')?.isEnabled,
  };
}

export function useLiveKitCall(conversationId: string | null) {
  const profile = useAuthStore((s) => s.profile);

  const [callState, setCallState] = useState<LkCallState>('idle');
  const [callType, setCallType] = useState<'audio' | 'video'>('audio');
  const [tiles, setTiles] = useState<CallTile[]>([]);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [sessionId, setSessionId] = useState<string | null>(null);

  const roomRef = useRef<any>(null);
  const attemptRef = useRef(0);
  const convoRef = useRef<string | null>(conversationId);
  convoRef.current = conversationId;

  const myUserId = profile?.user_id ?? '';

  const rebuildTiles = useCallback((room: any) => {
    const local = room.localParticipant;
    const next: CallTile[] = [
      {
        identity: String(local.identity),
        name: local.name || 'You',
        avatarUrl: '',
        isLocal: true,
        participant: local,
        ...flagsOf(local),
      },
      ...Array.from(room.remoteParticipants.values()).map((rp: any) => ({
        identity: String(rp.identity),
        name: rp.name || rp.identity,
        avatarUrl: rp.metadata || '',
        isLocal: false,
        participant: rp,
        ...flagsOf(rp),
      })),
    ];
    setTiles(next);
  }, []);

  const cleanupRoom = useCallback(() => {
    attemptRef.current += 1;
    try {
      roomRef.current?.disconnect();
    } catch { /* noop */ }
    roomRef.current = null;
    setTiles([]);
  }, []);

  // Leave (server-side) when unmounting mid-call.
  useEffect(() => () => {
    const convo = convoRef.current;
    if (roomRef.current && convo) {
      messagingApi.leaveCall(convo).catch(() => {});
    }
    cleanupRoom();
  }, [cleanupRoom]);

  /** Start or join the conversation's call. */
  const join = useCallback(async (type: 'audio' | 'video'): Promise<boolean> => {
    const convo = convoRef.current;
    if (!convo || roomRef.current) return false;
    setCallType(type);
    setCameraError(null);
    setCallState('calling');
    const attempt = ++attemptRef.current;

    let creds: CallSessionCredentials;
    try {
      const res = await messagingApi.startOrJoinCall(convo, type);
      creds = res.data as CallSessionCredentials;
    } catch {
      setCallState('idle');
      return false;
    }
    if (!creds?.livekit?.url || !creds?.livekit?.token || attempt !== attemptRef.current) {
      setCallState('idle');
      return false;
    }
    setSessionId(creds.session_id);

    const { Room, VideoPresets } = await import('livekit-client');
    if (attempt !== attemptRef.current) return false;
    const room = new Room({
      adaptiveStream: true,
      dynacast: true,
      videoCaptureDefaults: { resolution: VideoPresets.h720.resolution },
    });
    roomRef.current = room;

    const onChange = () => rebuildTiles(room);
    room
      .on('participantConnected', onChange)
      .on('participantDisconnected', onChange)
      .on('trackSubscribed', onChange)
      .on('trackUnsubscribed', onChange)
      .on('trackPublished', onChange)
      .on('trackUnpublished', onChange)
      .on('trackMuted', onChange)
      .on('trackUnmuted', onChange)
      .on('connectionStateChanged', (state: string) => {
        if (state === 'disconnected') {
          if (attempt === attemptRef.current) {
            setCallState('ended');
            setTimeout(() => setCallState((s) => (s === 'ended' ? 'idle' : s)), 1500);
          }
        }
      });

    try {
      await room.connect(creds.livekit.url, creds.livekit.token);
    } catch {
      if (attempt === attemptRef.current) {
        cleanupRoom();
        setCallState('idle');
      }
      return false;
    }
    if (attempt !== attemptRef.current) {
      room.disconnect();
      return false;
    }

    // Publish local media. Video calls fall back to audio-only gracefully.
    let micOk = false;
    let camOk = false;
    try {
      if (type === 'video') {
        await room.localParticipant.enableCameraAndMicrophone();
        micOk = true; camOk = true;
      } else {
        await room.localParticipant.setMicrophoneEnabled(true);
        micOk = true;
      }
    } catch (err) {
      const name = (err as { name?: string })?.name;
      if (type === 'video') {
        try {
          await room.localParticipant.setMicrophoneEnabled(true);
          micOk = true;
          camOk = false;
          setCameraError(name === 'NotAllowedError' ? 'Camera permission denied' : 'Camera unavailable');
        } catch {
          setCameraError('Microphone unavailable — joined listen-only');
        }
      } else {
        setCameraError('Microphone unavailable — joined listen-only');
      }
    }

    rebuildTiles(room);
    void camOk; void micOk;
    setCallState('in_call');

    // Others already in the room see us immediately; ring state resolves there.
    return true;
  }, [cleanupRoom, rebuildTiles]);

  /** Hang up / leave the current call. */
  const leave = useCallback(async () => {
    const convo = convoRef.current;
    cleanupRoom();
    setCallState('ended');
    setTimeout(() => setCallState((s) => (s === 'ended' ? 'idle' : s)), 1200);
    if (convo) {
      try { await messagingApi.leaveCall(convo); } catch { /* noop */ }
    }
  }, [cleanupRoom]);

  const toggleMute = useCallback(async () => {
    const lp = roomRef.current?.localParticipant;
    if (!lp) return;
    const next = !(lp.isMicrophoneEnabled ?? false);
    try { await lp.setMicrophoneEnabled(next); } catch { /* noop */ }
    rebuildTiles(roomRef.current);
  }, [rebuildTiles]);

  const toggleCamera = useCallback(async () => {
    const lp = roomRef.current?.localParticipant;
    if (!lp) return;
    const next = !(lp.isCameraEnabled ?? false);
    try { await lp.setCameraEnabled(next); } catch { /* noop */ }
    rebuildTiles(roomRef.current);
  }, [rebuildTiles]);

  const toggleScreenShare = useCallback(async () => {
    const lp = roomRef.current?.localParticipant;
    if (!lp) return;
    const sharing = !!lp.getTrackPublication?.('screen_share');
    try { await lp.setScreenShareEnabled(!sharing); } catch { /* user cancelled */ }
    rebuildTiles(roomRef.current);
  }, [rebuildTiles]);

  /** Accept an invite that arrived while this conversation wasn't open yet. */
  const acceptRinging = useCallback(async (type: 'audio' | 'video') => {
    await join(type);
  }, [join]);

  return {
    callState,
    callType,
    tiles,
    cameraError,
    sessionId,
    myUserId,
    join,
    acceptRinging,
    leave,
    toggleMute,
    toggleCamera,
    toggleScreenShare,
  };
}

export type { CallParticipantInfo };
