/**
 * useWebRTC – peer connection management for audio/video calls.
 * Supports: screen share, camera error detection, mute, camera toggle.
 */
import { useRef, useCallback, useState } from 'react';

export type CallState = 'idle' | 'calling' | 'ringing' | 'in_call' | 'ended';

interface Options {
  onSignal: (
    type: 'call_offer' | 'call_answer' | 'call_ice' | 'call_end' | 'call_decline' | 'call_ringing',
    data: object,
    callType: 'audio' | 'video',
  ) => void;
}

const ICE_SERVERS = [
  { urls: 'stun:stun.l.google.com:19302' },
  { urls: 'stun:stun1.l.google.com:19302' },
];

export function useWebRTC({ onSignal }: Options) {
  const pcRef = useRef<RTCPeerConnection | null>(null);
  const localStreamRef = useRef<MediaStream | null>(null);
  const screenStreamRef = useRef<MediaStream | null>(null);

  const [callState, setCallState] = useState<CallState>('idle');
  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);
  const [callType, setCallType] = useState<'audio' | 'video'>('audio');
  const [isMuted, setIsMuted] = useState(false);
  const [isCameraOff, setIsCameraOff] = useState(false);
  const [isSharingScreen, setIsSharingScreen] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [floatingReactions, setFloatingReactions] = useState<{ id: number; emoji: string }[]>([]);
  const [isRemoteMuted, setIsRemoteMuted] = useState(false);
  const [isRecording, setIsRecording] = useState(false);

  const dataChannelRef = useRef<RTCDataChannel | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const recordedChunksRef = useRef<BlobPart[]>([]);
  const remoteStreamRef = useRef<MediaStream | null>(null);

  // Reference to keep callType stable in closures
  const callTypeRef = useRef<'audio' | 'video'>('audio');

  const createPeerConnection = useCallback(() => {
    const pc = new RTCPeerConnection({ iceServers: ICE_SERVERS });
    pcRef.current = pc;

    const remote = new MediaStream();
    setRemoteStream(remote);
    remoteStreamRef.current = remote;

    const setupDataChannel = (dc: RTCDataChannel) => {
      dc.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          if (msg.type === 'reaction') {
            const id = Date.now() + Math.random();
            setFloatingReactions((prev) => [...prev, { id, emoji: msg.emoji }]);
            setTimeout(() => setFloatingReactions((prev) => prev.filter((r) => r.id !== id)), 3000);
          } else if (msg.type === 'mute_status') {
            setIsRemoteMuted(msg.isMuted);
          } else if (msg.type === 'recording_started') {
            setIsRecording(true);
          } else if (msg.type === 'recording_stopped') {
            setIsRecording(false);
          }
        } catch {}
      };
      dataChannelRef.current = dc;
    };

    pc.ondatachannel = (event) => {
      setupDataChannel(event.channel);
    };

    pc.ontrack = (evt) => {
      evt.streams[0]?.getTracks().forEach((t) => remote.addTrack(t));
    };

    pc.onicecandidate = (evt) => {
      if (evt.candidate) {
        onSignal('call_ice', { candidate: evt.candidate.toJSON() }, callTypeRef.current);
      }
    };

    pc.onconnectionstatechange = () => {
      if (['disconnected', 'failed', 'closed'].includes(pc.connectionState)) {
        setCallState('ended');
        setTimeout(() => setCallState('idle'), 1200);
      }
    };

    // Attach setupDataChannel to pc so we can call it when initiating
    (pc as any)._setupDataChannel = setupDataChannel;

    return pc;
  }, [onSignal]);

  const getLocalStream = useCallback(async (type: 'audio' | 'video') => {
    setCameraError(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: true,
        video: type === 'video' ? { width: { ideal: 1280 }, height: { ideal: 720 } } : false,
      });
      localStreamRef.current = stream;
      setLocalStream(stream);
      return stream;
    } catch (err: unknown) {
      const error = err as { name?: string };
      if (type === 'video' && (error.name === 'NotFoundError' || error.name === 'NotAllowedError' || error.name === 'NotReadableError')) {
        // Camera not available – fall back to audio only
        setCameraError(error.name === 'NotAllowedError' ? 'Camera permission denied' : 'Camera not found or in use');
        const audioStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
        localStreamRef.current = audioStream;
        setLocalStream(audioStream);
        setIsCameraOff(true);
        return audioStream;
      }
      throw err;
    }
  }, []);

  // ── Initiate a call ───────────────────────────────────────────────────────
  const startCall = useCallback(
    async (type: 'audio' | 'video') => {
      setCallType(type);
      callTypeRef.current = type;
      setCallState('calling');
      setIsCameraOff(false);
      const pc = createPeerConnection();
      const dc = pc.createDataChannel('buddyup-chat');
      if ((pc as any)._setupDataChannel) (pc as any)._setupDataChannel(dc);
      
      const stream = await getLocalStream(type);
      stream.getTracks().forEach((t) => pc.addTrack(t, stream));
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      onSignal('call_offer', { sdp: offer, call_type: type }, type);
    },
    [createPeerConnection, getLocalStream, onSignal],
  );

  // ── Answer an incoming call ───────────────────────────────────────────────
  const answerCall = useCallback(
    async (offerSdp: RTCSessionDescriptionInit, type: 'audio' | 'video') => {
      setCallType(type);
      callTypeRef.current = type;
      setCallState('in_call');
      const pc = createPeerConnection();
      const stream = await getLocalStream(type);
      stream.getTracks().forEach((t) => pc.addTrack(t, stream));
      await pc.setRemoteDescription(new RTCSessionDescription(offerSdp));
      const answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      onSignal('call_answer', { sdp: answer }, type);
    },
    [createPeerConnection, getLocalStream, onSignal],
  );

  // ── Handle incoming signal ────────────────────────────────────────────────
  const handleSignal = useCallback(
    async (signalType: string, data: Record<string, unknown>) => {
      const pc = pcRef.current;
      if (signalType === 'call_offer') {
        setCallState('ringing');
        (window as unknown as Record<string, unknown>).__buddyup_pending_offer = data.sdp;
        (window as unknown as Record<string, unknown>).__buddyup_call_type = data.call_type || 'audio';
        onSignal('call_ringing', {}, (data.call_type as 'audio' | 'video') || 'audio');
      } else if (signalType === 'call_ringing') {
        setCallState((prev) => (prev === 'calling' ? 'ringing' : prev));
      } else if (signalType === 'call_answer' && pc) {
        await pc.setRemoteDescription(new RTCSessionDescription(data.sdp as RTCSessionDescriptionInit));
        setCallState('in_call');
      } else if (signalType === 'call_ice' && pc) {
        try {
          await pc.addIceCandidate(new RTCIceCandidate(data.candidate as RTCIceCandidateInit));
        } catch { /* stale */ }
      } else if (signalType === 'call_end' || signalType === 'call_decline') {
        hangUp(false);
      }
    },
    [onSignal], // hangUp will be defined below but captured via ref
  );

  // ── Accept ringing call ───────────────────────────────────────────────────
  const acceptIncomingCall = useCallback(async () => {
    const pendingOffer = (window as unknown as Record<string, unknown>).__buddyup_pending_offer as RTCSessionDescriptionInit | undefined;
    const pendingType = ((window as unknown as Record<string, unknown>).__buddyup_call_type as 'audio' | 'video') ?? 'audio';
    if (!pendingOffer) return;
    await answerCall(pendingOffer, pendingType);
  }, [answerCall]);

  // ── Hang up / decline ─────────────────────────────────────────────────────
  const hangUp = useCallback(
    (notify = true) => {
      if (notify) onSignal('call_end', {}, callTypeRef.current);
      // Stop screen share if active
      screenStreamRef.current?.getTracks().forEach((t) => t.stop());
      screenStreamRef.current = null;
      setIsSharingScreen(false);
      // Stop local camera/mic
      pcRef.current?.close();
      pcRef.current = null;
      localStreamRef.current?.getTracks().forEach((t) => t.stop());
      localStreamRef.current = null;
      setLocalStream(null);
      setRemoteStream(null);
      setCallState('ended');
      setCameraError(null);
      setIsMuted(false);
      setIsCameraOff(false);
      setTimeout(() => setCallState('idle'), 1200);
    },
    [onSignal],
  );

  const declineCall = useCallback(() => {
    onSignal('call_decline', {}, callTypeRef.current);
    setCallState('idle');
  }, [onSignal]);

  // ── Mute / camera ─────────────────────────────────────────────────────────
  const toggleMute = useCallback(() => {
    localStreamRef.current?.getAudioTracks().forEach((t) => { t.enabled = !t.enabled; });
    setIsMuted((v) => {
      const next = !v;
      if (dataChannelRef.current?.readyState === 'open') {
        dataChannelRef.current.send(JSON.stringify({ type: 'mute_status', isMuted: next }));
      }
      return next;
    });
  }, []);

  const toggleCamera = useCallback(() => {
    localStreamRef.current?.getVideoTracks().forEach((t) => { t.enabled = !t.enabled; });
    setIsCameraOff((v) => !v);
  }, []);

  // ── Screen Share ──────────────────────────────────────────────────────────
  const toggleScreenShare = useCallback(async () => {
    const pc = pcRef.current;
    if (!pc) return;

    if (isSharingScreen) {
      // Stop screen share, restore camera
      screenStreamRef.current?.getTracks().forEach((t) => t.stop());
      screenStreamRef.current = null;
      setIsSharingScreen(false);
      // Restore camera track
      const cameraStream = await navigator.mediaDevices.getUserMedia({ video: true }).catch(() => null);
      if (cameraStream) {
        const videoTrack = cameraStream.getVideoTracks()[0];
        const sender = pc.getSenders().find((s) => s.track?.kind === 'video');
        if (sender && videoTrack) {
          await sender.replaceTrack(videoTrack);
          localStreamRef.current?.getVideoTracks().forEach((t) => t.stop());
          // Replace in localStream
          setLocalStream(cameraStream);
          localStreamRef.current = cameraStream;
        }
      }
    } else {
      try {
        const screenStream = await (navigator.mediaDevices as unknown as { getDisplayMedia: (c: object) => Promise<MediaStream> }).getDisplayMedia({
          video: true, audio: false,
        });
        screenStreamRef.current = screenStream;
        const screenTrack = screenStream.getVideoTracks()[0];
        // Replace video sender track
        const sender = pc.getSenders().find((s) => s.track?.kind === 'video');
        if (sender) {
          await sender.replaceTrack(screenTrack);
        }
        // When user stops sharing from browser UI
        screenTrack.onended = () => { setIsSharingScreen(false); };
        setIsSharingScreen(true);
      } catch { /* user cancelled */ }
    }
  }, [isSharingScreen]);

  // ── Floating emoji reactions ───────────────────────────────────────────────
  const sendReaction = useCallback((emoji: string) => {
    const id = Date.now();
    setFloatingReactions((prev) => [...prev, { id, emoji }]);
    setTimeout(() => {
      setFloatingReactions((prev) => prev.filter((r) => r.id !== id));
    }, 3000);
    if (dataChannelRef.current?.readyState === 'open') {
      dataChannelRef.current.send(JSON.stringify({ type: 'reaction', emoji }));
    }
  }, []);

  // ── Call Recording ──────────────────────────────────────────────────────────
  const toggleRecording = useCallback(() => {
    if (isRecording) {
      mediaRecorderRef.current?.stop();
      setIsRecording(false);
      if (dataChannelRef.current?.readyState === 'open') {
        dataChannelRef.current.send(JSON.stringify({ type: 'recording_stopped' }));
      }
    } else {
      const streamToRecord = remoteStreamRef.current || localStreamRef.current;
      if (!streamToRecord) return;
      try {
        const recorder = new MediaRecorder(streamToRecord, { mimeType: callTypeRef.current === 'video' ? 'video/webm' : 'audio/webm' });
        recordedChunksRef.current = [];
        recorder.ondataavailable = (e) => {
          if (e.data.size > 0) recordedChunksRef.current.push(e.data);
        };
        recorder.onstop = () => {
          const blob = new Blob(recordedChunksRef.current, { type: callTypeRef.current === 'video' ? 'video/webm' : 'audio/webm' });
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.style.display = 'none';
          a.href = url;
          a.download = `BuddyUp-Call-${Date.now()}.webm`;
          document.body.appendChild(a);
          a.click();
          window.URL.revokeObjectURL(url);
        };
        recorder.start();
        mediaRecorderRef.current = recorder;
        setIsRecording(true);
        if (dataChannelRef.current?.readyState === 'open') {
          dataChannelRef.current.send(JSON.stringify({ type: 'recording_started' }));
        }
      } catch (err) {
        console.error("Recording error:", err);
      }
    }
  }, [isRecording]);

  return {
    callState,
    callType,
    localStream,
    remoteStream,
    isMuted,
    isRemoteMuted,
    isCameraOff,
    isSharingScreen,
    isRecording,
    cameraError,
    floatingReactions,
    startCall,
    acceptIncomingCall,
    declineCall,
    hangUp,
    toggleMute,
    toggleCamera,
    toggleScreenShare,
    toggleRecording,
    sendReaction,
    handleSignal,
  };
}
