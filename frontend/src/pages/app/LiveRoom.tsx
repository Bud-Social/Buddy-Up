import { useEffect, useRef, useState, useCallback, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Mic, MicOff, Video, VideoOff, PhoneOff, Users, Copy, Check,
  MessageCircle, MessageCircleOff, Send,
  LogOut, Shield, Gift, X, Crown, Coins, Headphones,
  Monitor, ChevronDown, PictureInPicture2, UserPlus, Reply,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { livesApi } from '@/api/lives';
import { useLiveWebSocket } from '@/hooks/useLiveWebSocket';
import { useAuthStore } from '@/store/authStore';
import { useArtifactStore } from '@/store/artifactStore';
import { useMediaQuery } from '@/hooks/useMediaQuery';
import useSimulatedAttendees from '@/hooks/useSimulatedAttendees';
import VoiceIndicator from '@/components/live/VoiceIndicator';
import type { LiveCredentials, LiveRoomData, CoHost, AttendeeInfo, PipShape } from '@/types/live';
import type { ChatMessage } from '@/hooks/useLiveWebSocket';

type Provider = 'agora' | 'livekit' | null;
type ConnectionState = 'connecting' | 'connected' | 'failed' | 'disconnected';

const REACTIONS = [
  { emoji: '🔥', label: 'Fire' },
  { emoji: '❤️', label: 'Love' },
  { emoji: '👍', label: 'Thumbs Up' },
  { emoji: '⭐', label: 'Star' },
  { emoji: '😂', label: 'LOL' },
  { emoji: '👏', label: 'Clap' },
];

interface FloatingGift {
  id: number;
  artifactType: string;
}

export default function LiveRoom() {
  const { liveId } = useParams<{ liveId: string }>();
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const myUserId = profile?.user_id || '';

  const [roomData, setRoomData] = useState<LiveRoomData | null>(null);
  const isHost = roomData?.host_user_id === myUserId;
  const [provider, setProvider] = useState<Provider>(null);
  const [connectionState, setConnectionState] = useState<ConnectionState>('disconnected');
  const [error, setError] = useState('');
  const [isMicOn, setIsMicOn] = useState(true);
  const [isCamOn, setIsCamOn] = useState(true);
  const [showEndConfirm, setShowEndConfirm] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [chatInput, setChatInput] = useState('');
  const [replyTo, setReplyTo] = useState<ChatMessage | null>(null);
  const [showGiftTotals, setShowGiftTotals] = useState(false);
  const [showRechargePrompt, setShowRechargePrompt] = useState(false);
  const [floatingGifts, setFloatingGifts] = useState<FloatingGift[]>([]);
  const [showGiftPicker, setShowGiftPicker] = useState(false);

  const {
    isConnected: wsConnected,
    chatMessages,
    reactions,
    viewerCount,
    giftTotals,
    cohostEvents,
    sendChat,
    sendReaction,
    sendGift,
    sendCohostEvent,
  } = useLiveWebSocket(liveId);

  const artifactBalance = useArtifactStore((s) => s.balance);

  const ARTIFACT_LIST = [
    { type: 'dumbbell', label: 'Dumbbell', value: 0.10 },
    { type: 'barbell', label: 'Barbell', value: 0.50 },
    { type: 'burpee', label: 'Burpee', value: 1.00 },
    { type: 'squat', label: 'Squat', value: 2.50 },
    { type: 'sprint', label: 'Sprint', value: 5.00 },
    { type: 'pr', label: 'PR', value: 10.00 },
    { type: 'champion', label: 'Champion', value: 25.00 },
  ];

  const [selectedGift, setSelectedGift] = useState<{ type: string; qty: number } | null>(null);
  const [showCoHostInput, setShowCoHostInput] = useState(false);
  const [coHostUsername, setCoHostUsername] = useState('');
  const [coHosts] = useState<CoHost[]>([]);

  const isAudioLive = roomData?.live_type === 'audio';
  const [speakerRequests, setSpeakerRequests] = useState<{ user_id: string; username: string; display_name: string; avatar_url: string }[]>([]);
  const [hasRequestedToSpeak, setHasRequestedToSpeak] = useState(false);
  const [cohostToast, setCohostToast] = useState('');

  const showCohostToast = useCallback((message: string) => {
    setCohostToast(message);
    setTimeout(() => setCohostToast(''), 2500);
  }, []);

  const [attendees, setAttendees] = useState<AttendeeInfo[]>([]);
  const [isSharingScreen, setIsSharingScreen] = useState(false);
  const screenTrackRef = useRef<unknown>(null);

  const isDesktop = useMediaQuery('(min-width: 1024px)');

  const [pipShape, setPipShape] = useState<PipShape>('circle');
  const [showPipMenu, setShowPipMenu] = useState(false);
  const [showScreenShareToast, setShowScreenShareToast] = useState(false);
  const [showScreenShareBar, setShowScreenShareBar] = useState(true);
  const [focusedSpeakerId, setFocusedSpeakerId] = useState<string | null>(null);
  const [hostRowPinned, setHostRowPinned] = useState(true);
  const videoTrackMap = useRef<Map<string, MediaStreamTrack>>(new Map()).current;
  const screenVideoTrackRef = useRef<MediaStreamTrack | null>(null);
  const localAudioTrackRef = useRef<MediaStreamTrack | null>(null);
  const [pipDragPos, setPipDragPos] = useState<{ x: number; y: number } | null>(null);
  const [isPipActive, setIsPipActive] = useState(false);
  const pipWindowRef = useRef<Window | null>(null);
  const isPipSupported = typeof window !== 'undefined' && 'documentPictureInPicture' in window;

  const PIP_OPTIONS = [
    { value: 'circle', label: 'Circle', preview: 'rounded-full' },
    { value: 'rounded', label: 'Rounded', preview: 'rounded-lg' },
    { value: 'square', label: 'Square', preview: 'rounded-none' },
    { value: 'rectangle', label: 'Rectangle', preview: 'rounded-lg w-full' },
    { value: 'fit', label: 'Fit', preview: 'rounded-lg object-contain' },
    { value: 'fill', label: 'Fill', preview: 'rounded-lg object-cover' },
  ];
  const pipShapeStyles: Record<PipShape, string> = {
    circle: 'w-20 h-20 rounded-full object-cover',
    rounded: 'w-24 h-24 rounded-xl object-cover',
    square: 'w-24 h-24 rounded-none object-cover',
    rectangle: 'w-32 h-24 rounded-xl object-cover',
    fit: 'w-24 h-24 rounded-xl object-contain',
    fill: 'w-24 h-24 rounded-xl object-cover',
  };

  const hostUserIds = new Set([
    roomData?.host_user_id,
    ...(roomData?.co_hosts?.map((ch) => ch.user_id) || []),
  ].filter(Boolean));
  const hosts = attendees.filter((a) => hostUserIds.has(a.id));
  const simulatedAttendees = useSimulatedAttendees();
  const allAttendees: AttendeeInfo[] = useMemo(() =>
    connectionState === 'connected' ? [...attendees, ...simulatedAttendees] : attendees,
    [attendees, simulatedAttendees, connectionState]
  );

  const localVideoRef = useRef<HTMLVideoElement>(null);
  const pipRef = useRef<HTMLDivElement>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const recorderChunksRef = useRef<Blob[]>([]);
  const recorderSessionRef = useRef<string | null>(null);
  const chunkIndexRef = useRef(0);
  const chunkIntervalRef = useRef<ReturnType<typeof setInterval>>();

  const remoteContainerRef = useRef<HTMLDivElement>(null);
  const agoraClientRef = useRef<unknown>(null);
  const localTracksRef = useRef<unknown[]>([]);
  const livekitRoomRef = useRef<unknown>(null);
  const chatEndRef = useRef<HTMLDivElement>(null);
  const connectAttemptRef = useRef(0);
  const pipCleanupRef = useRef<(() => void) | null>(null);

  useEffect(() => {
    if (showChat) {
      chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [chatMessages, showChat]);

  const addFloatingGift = useCallback((artifactType: string) => {
    const id = Date.now() + Math.random();
    setFloatingGifts((prev) => [...prev, { id, artifactType }]);
    setTimeout(() => {
      setFloatingGifts((prev) => prev.filter((g) => g.id !== id));
    }, 1500);
  }, []);

  const handleArtifactGift = useCallback((artifactType: string) => {
    const bal = artifactBalance[artifactType as keyof typeof artifactBalance] || 0;
    if (bal < 1) {
      setShowRechargePrompt(true);
      return;
    }
    sendGift(artifactType, 1);
    addFloatingGift(artifactType);
  }, [artifactBalance, sendGift, addFloatingGift]);

  const openGiftPicker = useCallback(() => {
    setShowGiftPicker(true);
  }, []);

  const selectGiftForChat = useCallback((type: string) => {
    setSelectedGift({ type, qty: 1 });
    setShowGiftPicker(false);
  }, []);

  const sortAttendees = useCallback((list: AttendeeInfo[]) => {
    return [...list].sort((a, b) => {
      if (a.isLocal) return -1;
      if (b.isLocal) return 1;
      if (a.isSpeaking !== b.isSpeaking) return a.isSpeaking ? -1 : 1;
      if (a.hasMicOn !== b.hasMicOn) return a.hasMicOn ? -1 : 1;
      return b.audioLevel - a.audioLevel;
    });
  }, []);

  const handleSpeakerChange = useCallback((speakers: { identity: string; isSpeaking: boolean; audioLevel: number }[]) => {
    setAttendees((prev) => {
      const updated = prev.map((a) => {
        const s = speakers.find((sp) => sp.identity === a.id);
        if (s) return { ...a, isSpeaking: s.isSpeaking, audioLevel: s.audioLevel };
        return { ...a, isSpeaking: false, audioLevel: 0 };
      });
      return sortAttendees(updated);
    });
  }, [sortAttendees]);

  const toggleScreenShare = useCallback(async () => {
    if (isSharingScreen) {
      if (provider === 'livekit') {
        const room = livekitRoomRef.current as { localParticipant: { setScreenShareEnabled: (v: boolean) => Promise<{ track?: { mediaStreamTrack?: MediaStreamTrack } | null }> } } | null;
        await room?.localParticipant.setScreenShareEnabled(false);
      } else if (provider === 'agora') {
        const client = agoraClientRef.current as { unpublish: (t: unknown) => Promise<void> } | null;
        if (screenTrackRef.current && client) {
          await client.unpublish(screenTrackRef.current);
          (screenTrackRef.current as { close?: () => void })?.close?.();
          screenTrackRef.current = null;
        }
      }
      setIsSharingScreen(false);
      screenVideoTrackRef.current = null;
    } else {
      if (provider === 'livekit') {
        const room = livekitRoomRef.current as { localParticipant: { setScreenShareEnabled: (v: boolean) => Promise<{ track?: { mediaStreamTrack?: MediaStreamTrack } | null }> } } | null;
        if (room) {
          const pub = await room.localParticipant.setScreenShareEnabled(true);
          if (pub?.track?.mediaStreamTrack) screenVideoTrackRef.current = pub.track.mediaStreamTrack;
          setIsSharingScreen(true);
          setShowScreenShareToast(true);
          setTimeout(() => setShowScreenShareToast(false), 2000);
          setTimeout(() => {
            if (!screenVideoTrackRef.current) {
              setIsSharingScreen((prev) => {
                if (prev) screenVideoTrackRef.current = null;
                return false;
              });
            }
          }, 5000);
        }
      } else if (provider === 'agora') {
        const { default: AgoraRTC } = await import('agora-rtc-sdk-ng');
        const client = agoraClientRef.current as { publish: (t: unknown) => Promise<void> } | null;
        if (client) {
          const screenTrack = await AgoraRTC.createScreenVideoTrack({}, 'enable');
          screenTrackRef.current = screenTrack;
          screenVideoTrackRef.current = (screenTrack as { mediaStreamTrack?: MediaStreamTrack }).mediaStreamTrack || null;
          await client.publish(screenTrack);
          setIsSharingScreen(true);
          setShowScreenShareToast(true);
          setTimeout(() => setShowScreenShareToast(false), 2000);
        }
      }
    }
  }, [isSharingScreen, provider]);

  const fetchRoomData = useCallback(async () => {
    if (!liveId) return;
    try {
      // Admission performs access and payment checks before a media token is issued.
      await livesApi.joinLive(liveId);
      const res = await livesApi.getLiveCredentials(liveId);
      setRoomData(res.data);
    } catch {
      setError('Failed to load live session.');
    }
  }, [liveId]);

  useEffect(() => {
    fetchRoomData();
  }, [fetchRoomData]);

  // Refresh pending speaker requests whenever the cohost panel opens
  useEffect(() => {
    if (showCoHostInput && isHost && liveId) {
      livesApi.getCohostRequests(liveId).then((res) => setSpeakerRequests(res.data || [])).catch(() => {});
    }
  }, [showCoHostInput, isHost, liveId]);

  // React to realtime cohost events broadcast through the room socket
  useEffect(() => {
    if (cohostEvents.length === 0) return;
    const last = cohostEvents[cohostEvents.length - 1];
    if (!last?.display_name) return;
    if (last.action === 'request') {
      if (isHost) {
        showCohostToast(`${last.display_name} requested to speak`);
        livesApi.getCohostRequests(liveId!).then((res) => setSpeakerRequests(res.data || [])).catch(() => {});
      }
    } else if (last.action === 'invite') {
      if (myUserId && last.user_id === myUserId) {
        showCohostToast(`${last.display_name} invited you to co-host`);
      }
    } else if (last.action === 'response') {
      if (last.user_id === myUserId) {
        showCohostToast(last.action === 'response' && last.username ? `You're a co-host now!` : 'Cohost update');
      }
    }
  }, [cohostEvents, isHost, myUserId, liveId, showCohostToast]);

  const joinLiveKit = useCallback(async (creds: LiveCredentials['livekit'], attempt: number) => {
    if (!creds.url || !creds.token) {
      setConnectionState('failed');
      setError('No video provider available.');
      return false;
    }
    try {
      const { Room, VideoPresets } = await import('livekit-client');
      const room = new Room({
        adaptiveStream: true, dynacast: true,
        videoCaptureDefaults: { resolution: VideoPresets.h720.resolution },
        publishDefaults: { videoSimulcastLayers: [VideoPresets.h720, VideoPresets.h360, VideoPresets.h180], videoCodec: 'vp8' },
      });
      livekitRoomRef.current = room;

      room.on('trackSubscribed', (track, _publication, participant) => {
        const mst = track.mediaStreamTrack;
        if (mst) videoTrackMap.set(participant.identity, mst);
        if (track.kind === 'video') {
          const container = document.createElement('div');
          container.id = `remote-lk-${participant.identity}`;
          container.className = 'relative rounded-xl overflow-hidden bg-buddy-surface';
          remoteContainerRef.current?.appendChild(container);
          container.appendChild(track.attach());
        }
        if (track.kind === 'audio') track.attach();
      });
      room.on('trackUnsubscribed', (_track, _publication, participant) => {
        videoTrackMap.delete(participant.identity);
        document.getElementById(`remote-lk-${participant.identity}`)?.remove();
      });

      room.on('participantConnected', (participant) => {
        setAttendees((prev) => sortAttendees([...prev, {
          id: participant.identity,
          displayName: participant.name || participant.identity,
          avatarUrl: participant.metadata || '',
          isSpeaking: false,
          hasMicOn: Array.from(participant.trackPublications.values()).some((p) => p.kind === 'audio' && p.isEnabled),
          hasVideoOn: Array.from(participant.trackPublications.values()).some((p) => p.kind === 'video' && p.isEnabled),
          isLocal: false,
          audioLevel: 0,
        }]));
      });
      room.on('participantDisconnected', (participant) => {
        videoTrackMap.delete(participant.identity);
        document.getElementById(`remote-lk-${participant.identity}`)?.remove();
        setAttendees((prev) => prev.filter((a) => a.id !== participant.identity));
      });
      room.on('connectionStateChanged', (state) => {
        if (state === 'disconnected') setConnectionState('disconnected');
      });

      await room.connect(creds.url, creds.token);

      if (connectAttemptRef.current !== attempt) {
        room.disconnect();
        return false;
      }

      let camOk = false;
      let micOk = false;
      if (creds.can_publish) try {
        if (isAudioLive) {
          // Audio-only live — publish just the microphone
          await room.localParticipant.setMicrophoneEnabled(true);
          camOk = false;
          micOk = true;
        } else {
          await room.localParticipant.enableCameraAndMicrophone();
          camOk = true;
          micOk = true;
        }
      } catch {
        try {
          await room.localParticipant.setMicrophoneEnabled(true);
          micOk = true;
        } catch {
          // listening only — neither camera nor mic available
        }
      }
      setIsCamOn(camOk);
      setIsMicOn(micOk);

      if (connectAttemptRef.current !== attempt) {
        room.disconnect();
        return false;
      }

      if (localVideoRef.current) {
        room.localParticipant.videoTrackPublications.forEach((pub) => {
          if (pub.track) pub.track.attach(localVideoRef.current!);
        });
      }
      room.localParticipant.audioTrackPublications.forEach((pub) => {
        if (pub.track?.kind === 'audio' && pub.track.mediaStreamTrack) {
          localAudioTrackRef.current = pub.track.mediaStreamTrack;
        }
      });

      // Build initial attendee list
      const localAttendee: AttendeeInfo = {
        id: profile?.user_id || 'local',
        displayName: profile?.display_name || 'You',
        avatarUrl: profile?.avatar_url || '',
        isSpeaking: false,
        hasMicOn: micOk,
        hasVideoOn: camOk,
        isLocal: true,
        audioLevel: 0,
      };
      const remoteAttendees: AttendeeInfo[] = Array.from(room.remoteParticipants.values()).map((p) => ({
        id: p.identity,
        displayName: p.name || p.identity,
        avatarUrl: p.metadata || '',
        isSpeaking: false,
        hasMicOn: Array.from(p.trackPublications.values()).some((pub) => pub.kind === 'audio' && pub.isEnabled),
        hasVideoOn: Array.from(p.trackPublications.values()).some((pub) => pub.kind === 'video' && pub.isEnabled),
        isLocal: false,
        audioLevel: 0,
      }));
      setAttendees(sortAttendees([localAttendee, ...remoteAttendees]));

      // Listen for track changes to update mic/video status + capture screen share
      room.on('trackPublished', (publication, participant) => {
        if (participant.isLocal && publication.kind === 'video' && (publication as unknown as { source: string }).source === 'screen_share') {
          const track = publication.track;
          if (track?.mediaStreamTrack) screenVideoTrackRef.current = track.mediaStreamTrack;
        }
        setAttendees((prev) => prev.map((a) =>
          a.id === participant.identity
            ? { ...a, hasMicOn: Array.from(participant.trackPublications.values()).some((p) => p.kind === 'audio' && p.isEnabled), hasVideoOn: Array.from(participant.trackPublications.values()).some((p) => p.kind === 'video' && p.isEnabled) }
            : a
        ));
      });

      // Active speaker detection
      room.on('activeSpeakersChanged', (speakers) => {
        handleSpeakerChange(speakers.map((s) => ({
          identity: s.identity,
          isSpeaking: true,
          audioLevel: s.audioLevel || 0,
        })));
        // Reset non-speakers
        setAttendees((prev) => prev.map((a) => {
          if (speakers.some((s) => s.identity === a.id)) return a;
          return { ...a, isSpeaking: false, audioLevel: 0 };
        }));
      });

      startClientRecording().catch(() => {});

      setConnectionState('connected');
      setProvider('livekit');
      return true;
    } catch {
      setConnectionState('failed');
      setError('Could not connect to live session.');
      return false;
    }
  }, [sortAttendees, handleSpeakerChange, profile, isAudioLive]);

  const connect = useCallback(async () => {
    if (!roomData) return;
    const creds = roomData.credentials;
    const attempt = ++connectAttemptRef.current;
    setConnectionState('connecting');

    const livekitOk = creds.livekit?.url && creds.livekit?.token;
    if (livekitOk) {
      const ok = await joinLiveKit(creds.livekit, attempt);
      if (connectAttemptRef.current !== attempt) return;
      if (ok) return;
    }

    setConnectionState('failed');
    setError('The self-hosted video service is unavailable.');
  }, [roomData, joinLiveKit]);

  useEffect(() => {
    if (roomData && roomData.status !== 'ended') connect();
    return () => {
      connectAttemptRef.current++;
      pipCleanupRef.current?.();
      pipCleanupRef.current = null;
      stopClientRecording();
      leaveRoom();
    };
  }, [roomData]);

  const toggleMic = async () => {
    const tracks = localTracksRef.current as Array<{ setEnabled: (v: boolean) => void; muted: boolean }>;
    if (provider === 'agora' && tracks[0]) { tracks[0].setEnabled(!isMicOn); }
    else if (provider === 'livekit') {
      const room = livekitRoomRef.current as { localParticipant: { setMicrophoneEnabled: (v: boolean) => void } } | null;
      await room?.localParticipant.setMicrophoneEnabled(!isMicOn);
    }
    setIsMicOn(!isMicOn);
  };

  const toggleCam = async () => {
    const tracks = localTracksRef.current as Array<{ setEnabled: (v: boolean) => void; muted: boolean }>;
    if (provider === 'agora' && tracks[1]) { tracks[1].setEnabled(!isCamOn); }
    else if (provider === 'livekit') {
      const room = livekitRoomRef.current as { localParticipant: { setCameraEnabled: (v: boolean) => void } } | null;
      await room?.localParticipant.setCameraEnabled(!isCamOn);
    }
    setIsCamOn(!isCamOn);
  };

  const togglePictureInPicture = useCallback(async () => {
    if (pipWindowRef.current) {
      pipWindowRef.current.close();
      return;
    }
    const localStream = localVideoRef.current?.srcObject;
    if (!localStream) return;
    try {
      const pipWin = await (window as unknown as { documentPictureInPicture: { requestWindow: (opts: Record<string, unknown>) => Promise<Window> } }).documentPictureInPicture.requestWindow({
        width: 420, height: 340, copyStyleSheets: true,
      });
      pipWindowRef.current = pipWin;
      setIsPipActive(true);

      pipWin.document.body.innerHTML = `
        <div style="width:100%;height:100%;position:relative;background:#000;display:flex;flex-direction:column;overflow:hidden;">
          <video id="pip-video" autoplay muted playsinline style="flex:1;width:100%;object-fit:contain;min-height:0;"></video>
          <div style="display:flex;justify-content:center;gap:16px;padding:10px 8px;background:rgba(0,0,0,0.85);">
            <button id="pip-mic" style="width:36px;height:36px;border-radius:50%;border:none;cursor:pointer;font-size:16px;display:flex;align-items:center;justify-content:center;background:#1E1E1E;color:#fff;">${isMicOn ? '🎤' : '🔇'}</button>
            <button id="pip-cam" style="width:36px;height:36px;border-radius:50%;border:none;cursor:pointer;font-size:16px;display:flex;align-items:center;justify-content:center;background:#1E1E1E;color:#fff;">${isCamOn ? '📷' : '📵'}</button>
            <button id="pip-fullscreen" style="width:36px;height:36px;border-radius:50%;border:none;cursor:pointer;font-size:16px;display:flex;align-items:center;justify-content:center;background:#1E1E1E;color:#fff;">⛶</button>
          </div>
        </div>
      `;

      const pipVideo = pipWin.document.getElementById('pip-video') as HTMLVideoElement;
      pipVideo.srcObject = localStream;

      pipWin.document.getElementById('pip-mic')!.onclick = toggleMic;
      pipWin.document.getElementById('pip-cam')!.onclick = toggleCam;
      pipWin.document.getElementById('pip-fullscreen')!.onclick = () => {
        pipWin.document.documentElement.requestFullscreen().catch(() => {});
      };

      pipWin.addEventListener('pagehide', () => {
        pipWindowRef.current = null;
        setIsPipActive(false);
      });
    } catch {
      // PiP not supported or user cancelled
    }
  }, [isMicOn, isCamOn, toggleMic, toggleCam]);

  const leaveRoom = async () => {
    if (pipWindowRef.current) {
      pipWindowRef.current.close();
      pipWindowRef.current = null;
      setIsPipActive(false);
    }
    if (isSharingScreen) {
      const st = screenTrackRef.current as { stop?: () => void; close?: () => void } | null;
      st?.stop?.();
      st?.close?.();
      screenTrackRef.current = null;
    }
    screenVideoTrackRef.current = null;
    setIsSharingScreen(false);
    if (provider === 'agora') {
      const client = agoraClientRef.current as { leave: () => Promise<void> } | null;
      const tracks = localTracksRef.current as Array<{ stop: () => void; close: () => void }>;
      tracks.forEach((t) => { t.stop(); t.close(); });
      if (client) await client.leave();
    } else if (provider === 'livekit') {
      const room = livekitRoomRef.current as { disconnect: () => void } | null;
      room?.disconnect();
    }
    agoraClientRef.current = null;
    localTracksRef.current = [];
    livekitRoomRef.current = null;
    setAttendees([]);
    setConnectionState('disconnected');
    setProvider(null);
  };

  const handleEndLive = async (saveReplay = false) => {
    if (!liveId) return;
    shouldSaveReplayRef.current = saveReplay;
    if (saveReplay) {
      await stopClientRecordingAsync();
    } else {
      await stopClientRecording();
    }
    try { await livesApi.endLive(liveId, saveReplay); } catch {}
    await leaveRoom();
    navigate('/lives');
  };

  const handleLeave = async () => {
    await leaveRoom();
    navigate('/lives');
  };

  const handleCopyLink = () => {
    navigator.clipboard.writeText(window.location.href);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const startClientRecording = useCallback(async () => {
    if (!liveId || !livekitRoomRef.current) return;
    try {
      const { Room } = await import('livekit-client');
      const room = livekitRoomRef.current as InstanceType<typeof Room>;
      const publications = Array.from(room.localParticipant.trackPublications.values());
      const videoPub = publications.find((p) => p.kind === 'video');
      const audioPub = publications.find((p) => p.kind === 'audio');
      const tracks: MediaStreamTrack[] = [];
      if (videoPub?.track?.mediaStreamTrack) tracks.push(videoPub.track.mediaStreamTrack);
      if (audioPub?.track?.mediaStreamTrack) tracks.push(audioPub.track.mediaStreamTrack);
      if (!tracks.length) return;

      const mediaStream = new MediaStream(tracks);
      const mimeType = MediaRecorder.isTypeSupported('video/webm;codecs=vp9')
        ? 'video/webm;codecs=vp9'
        : 'video/webm';
      const recorder = new MediaRecorder(mediaStream, { mimeType });
      recorderRef.current = recorder;
      recorderChunksRef.current = [];
      chunkIndexRef.current = 0;
      shouldSaveReplayRef.current = false;

      const res = await livesApi.initClientRecording(liveId);
      recorderSessionRef.current = res.data?.session_id || null;

      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          recorderChunksRef.current.push(e.data);
        }
      };

      recorder.onstop = async () => {
        if (!shouldSaveReplayRef.current) {
          recorderChunksRef.current = [];
          return;
        }
        if (recorderChunksRef.current.length > 0 && liveId) {
          const blob = new Blob(recorderChunksRef.current, { type: mimeType });
          const idx = chunkIndexRef.current++;
          try {
            await livesApi.uploadReplayChunk(liveId, blob, idx);
          } catch {}
          recorderChunksRef.current = [];
        }
        if (liveId) {
          try {
            await livesApi.completeClientReplay(liveId);
          } catch {}
        }
      };

      chunkIntervalRef.current = setInterval(() => {
        if (recorderRef.current?.state === 'recording') {
          recorderRef.current.stop();
          recorderRef.current.start(30000);
        }
      }, 30000);

      recorder.start(30000);
    } catch {}
  }, [liveId]);

  const shouldSaveReplayRef = useRef(false);

  const stopClientRecording = useCallback(async () => {
    clearInterval(chunkIntervalRef.current);
    if (recorderRef.current?.state === 'recording') {
      recorderRef.current.stop();
    }
    recorderRef.current = null;
  }, []);

  const stopClientRecordingAsync = useCallback(async () => {
    clearInterval(chunkIntervalRef.current);
    if (recorderRef.current?.state === 'recording') {
      await new Promise<void>((resolve) => {
        const orig = recorderRef.current!.onstop;
        recorderRef.current!.onstop = async (e: Event) => {
          await (orig as (e: Event) => Promise<void> | void)?.(e);
          recorderRef.current = null;
          resolve();
        };
        recorderRef.current!.stop();
      });
    } else {
      recorderRef.current = null;
    }
  }, []);

  const handleReaction = useCallback((emoji: string) => {
    sendReaction(emoji);
  }, [sendReaction]);

  const handleSendChat = (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim() && !selectedGift) return;
    const payload: { message: string; gift?: { artifact_type: string; quantity: number } } = { message: chatInput.trim() };
    if (selectedGift) {
      payload.gift = { artifact_type: selectedGift.type, quantity: selectedGift.qty };
      addFloatingGift(selectedGift.type);
    }
    sendChat(payload.message, payload.gift, replyTo);
    setChatInput('');
    setSelectedGift(null);
    setReplyTo(null);
  };

  const liveMessages = chatMessages.slice(-15);

  if (!liveId) {
    return <div className="p-4 text-center text-buddy-text-secondary">Invalid live session.</div>;
  }

  return (
    <div className="h-screen bg-buddy-black flex flex-col">
      {/* HEADER */}
      <header className="flex items-center justify-between px-4 py-3 bg-buddy-black/80 backdrop-blur z-20 shrink-0">
        <div className="flex items-center gap-3">
          {roomData && (
            <>
              <Avatar src={roomData.host_avatar} alt={roomData.host_name} size="sm" />
              <div>
                <h1 className="text-sm font-semibold truncate max-w-[200px]">{roomData.title}</h1>
                <p className="text-xs text-buddy-text-secondary flex items-center gap-1.5">
                  {roomData.host_name}
                  <span className="inline-flex items-center gap-0.5 text-[10px] bg-buddy-green/10 text-buddy-green px-1.5 py-0.5 rounded-full font-medium">
                    <Shield size={10} /> Host
                  </span>
                </p>
              </div>
            </>
          )}
        </div>
        <div className="flex items-center gap-2">
          {/* Collapsible gift totals */}
          {isHost && Object.keys(giftTotals).length > 0 && (
            <div className="relative">
              <button
                onClick={() => setShowGiftTotals(!showGiftTotals)}
                className="flex items-center gap-1 text-xs text-buddy-text-secondary bg-buddy-surface/30 px-2 py-1 rounded-lg hover:bg-buddy-surface/50 transition-colors"
              >
                <div className="flex -space-x-1.5 mr-0.5">
                  {Object.entries(giftTotals).slice(0, 3).map(([k]) => (
                    <span key={k} className="relative">
                      <ArtifactIcon artifact={k} size={12} />
                    </span>
                  ))}
                </div>
                <span className="font-coin font-bold">
                  {Object.values(giftTotals).reduce((a, b) => a + b, 0)}
                </span>
                <Gift size={10} />
              </button>
              {showGiftTotals && (
                <div className="absolute right-0 top-full mt-1 bg-buddy-surface rounded-xl p-2 shadow-xl border border-buddy-surface-raised min-w-[140px] z-30">
                  {Object.entries(giftTotals).map(([k, v]) => (
                    <div key={k} className="flex items-center justify-between gap-2 px-1 py-1 text-xs">
                      <span className="flex items-center gap-1">
                        <ArtifactIcon artifact={k} size={14} />
                        <span className="capitalize text-buddy-text-secondary">{k}</span>
                      </span>
                      <span className="font-coin font-bold">{v}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
          <button onClick={handleCopyLink} className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">
            {copied ? <Check size={18} /> : <Copy size={18} />}
          </button>
          {isHost && (
            <button onClick={() => setShowCoHostInput(!showCoHostInput)} className="p-2 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary" title="Manage co-hosts">
              <Crown size={18} />
            </button>
          )}
          <span className="flex items-center gap-1 text-xs text-buddy-text-secondary">
            <Users size={14} /> {viewerCount}
          </span>
          {isPipSupported && connectionState === 'connected' && (
            <button onClick={togglePictureInPicture}
              className={`p-2 rounded-lg transition-colors ${isPipActive ? 'bg-buddy-green text-buddy-black' : 'hover:bg-buddy-surface text-buddy-text-secondary'}`}
              title={isPipActive ? 'Exit Picture-in-Picture' : 'Picture-in-Picture'}
            ><PictureInPicture2 size={18} /></button>
          )}
          <span className={`flex items-center gap-1 text-xs px-2 py-1 rounded-full ${
            wsConnected ? 'bg-buddy-green/20 text-buddy-green' : 'bg-buddy-red/20 text-buddy-red'
          }`}>
            <span className={`w-1.5 h-1.5 rounded-full ${wsConnected ? 'bg-buddy-green' : 'bg-buddy-red'}`} />
            {wsConnected ? 'Live' : 'Offline'}
          </span>
        </div>
      </header>

      {/* CO-HOST INPUT */}
      {showCoHostInput && isHost && (
        <div className="bg-buddy-surface px-4 py-2 flex items-center gap-2 border-b border-buddy-surface-raised shrink-0">
          <input type="text" value={coHostUsername} onChange={(e) => setCoHostUsername(e.target.value)}
            placeholder="Enter username to invite..."
            className="flex-1 bg-buddy-black rounded-lg px-3 py-1.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/30"
          />
          <button onClick={async () => {
            if (!coHostUsername.trim() || !liveId) return;
            try {
              await livesApi.inviteCohost(liveId, coHostUsername.trim());
              sendCohostEvent('cohost_invite', { username: coHostUsername.trim(), display_name: coHostUsername.trim() });
              showCohostToast(`Invited @${coHostUsername.trim()} to co-host`);
              setCoHostUsername('');
            } catch {}
          }} className="text-xs bg-buddy-green text-buddy-black px-3 py-1.5 rounded-lg font-semibold">Invite</button>
          <button onClick={() => setShowCoHostInput(false)} className="text-buddy-text-secondary p-1"><X size={16} /></button>
        </div>
      )}

      {/* SPEAKER REQUESTS — host panel */}
      {showCoHostInput && isHost && speakerRequests.length > 0 && (
        <div className="bg-buddy-surface/60 px-4 py-2 border-b border-buddy-surface-raised shrink-0 space-y-1.5">
          <p className="text-xs font-semibold text-buddy-text-secondary flex items-center gap-1.5">
            <Headphones size={12} /> Speaker requests ({speakerRequests.length})
          </p>
          {speakerRequests.map((req) => (
            <div key={req.user_id} className="flex items-center gap-2 bg-buddy-black/40 rounded-lg px-2.5 py-1.5">
              <Avatar src={req.avatar_url} alt={req.display_name} size="sm" />
              <div className="flex-1 min-w-0">
                <p className="text-xs font-medium truncate">{req.display_name}</p>
                <p className="text-[10px] text-buddy-text-secondary">@{req.username}</p>
              </div>
              <button onClick={async () => {
                try {
                  await livesApi.respondToSpeakRequest(liveId!, req.username, 'approve');
                  setSpeakerRequests((prev) => prev.filter((r) => r.user_id !== req.user_id));
                  sendCohostEvent('cohost_response', { username: req.username, display_name: req.display_name, action: 'approve' });
                  showCohostToast(`@${req.username} can now speak`);
                } catch {}
              }} className="text-[11px] bg-buddy-green text-buddy-black px-2.5 py-1 rounded-lg font-semibold">Approve</button>
              <button onClick={async () => {
                try {
                  await livesApi.respondToSpeakRequest(liveId!, req.username, 'deny');
                  setSpeakerRequests((prev) => prev.filter((r) => r.user_id !== req.user_id));
                } catch {}
              }} className="text-[11px] bg-buddy-surface text-buddy-text-secondary px-2.5 py-1 rounded-lg">Deny</button>
            </div>
          ))}
        </div>
      )}

      {/* COHOST TOAST */}
      {cohostToast && (
        <div className="absolute top-16 left-1/2 -translate-x-1/2 z-50 animate-slide-in-down">
          <div className="bg-buddy-green/90 backdrop-blur text-white px-4 py-2 rounded-full text-sm font-semibold flex items-center gap-2 shadow-xl">
            <Crown size={14} /> {cohostToast}
          </div>
        </div>
      )}
      {coHosts.length > 0 && (
        <div className="bg-buddy-surface/50 px-4 py-1.5 flex items-center gap-2 overflow-x-auto border-b border-buddy-surface-raised shrink-0">
          <Crown size={12} className="text-buddy-yellow shrink-0" />
          {coHosts.map((ch) => (
            <span key={ch.user_id} className="flex items-center gap-1 text-xs text-buddy-text-secondary bg-buddy-surface px-2 py-0.5 rounded-full shrink-0">
              <Avatar src={ch.avatar_url} alt={ch.display_name} size="sm" />
              {ch.display_name}
            </span>
          ))}
        </div>
      )}

      {/* Screen share indicator bar — pushes tiles down */}
      {isSharingScreen && showScreenShareBar && (
        <div className="shrink-0 bg-buddy-red/90 backdrop-blur px-4 py-1.5 flex items-center justify-between text-white text-xs">
          <span className="flex items-center gap-1.5"><Monitor size={14} /> You are sharing your screen</span>
          <div className="flex items-center gap-2">
            <button onClick={() => setShowScreenShareBar(false)} className="opacity-70 hover:opacity-100">✕</button>
            <button onClick={toggleScreenShare} className="underline font-semibold">Stop Sharing</button>
          </div>
        </div>
      )}
      {/* MAIN CONTENT */}
      <div className="flex-1 relative overflow-hidden">
        {connectionState === 'connecting' && (
          <div className="absolute inset-0 flex items-center justify-center z-10">
            <div className="text-center space-y-4">
              <div className="w-16 h-16 rounded-full border-4 border-buddy-surface border-t-buddy-green animate-spin mx-auto" />
              <p className="text-buddy-text-secondary">Connecting to live session...</p>
            </div>
          </div>
        )}

        {connectionState === 'failed' && (
          <div className="absolute inset-0 flex items-center justify-center z-10">
            <div className="text-center space-y-4">
              <VideoOff size={48} className="mx-auto text-buddy-red" />
              <p className="text-buddy-text-secondary">{error || 'Connection failed.'}</p>
              <div className="flex gap-2 justify-center">
                <Button onClick={() => fetchRoomData()}>Retry</Button>
                <Button variant="outline" onClick={handleLeave}>Leave</Button>
              </div>
            </div>
          </div>
        )}

        {/* VIDEO AREA */}
        <div className="absolute inset-0">
          {/* Focused speaker background */}
          <div ref={remoteContainerRef} className="absolute inset-0" />

          {/* LEFT ARTIFACT COLUMN */}
          <div className="absolute left-2 top-1/2 -translate-y-1/2 z-20 flex flex-col gap-1">
            {ARTIFACT_LIST.map((a) => {
              const bal = artifactBalance[a.type as keyof typeof artifactBalance] || 0;
              return (
                <button key={a.type} onClick={() => handleArtifactGift(a.type)}
                  className="flex flex-col items-center gap-0.5 p-1.5 rounded-xl bg-buddy-black/50 backdrop-blur hover:bg-buddy-surface/60 transition-colors min-w-[44px]"
                  title={`${a.label} (${bal})`}
                >
                  <ArtifactIcon artifact={a.type} size={isDesktop ? 22 : 18} />
                  <span className={`text-[9px] font-coin leading-tight ${bal > 0 ? 'text-buddy-green' : 'text-buddy-text-secondary/50'}`}>{bal}</span>
                </button>
              );
            })}
          </div>

          {/* PIP — customizable shape/size, draggable, auto-repositions when screen sharing */}
          {!isPipActive && !isAudioLive && (
          <div ref={pipRef}
            className="absolute z-30"
            style={
              pipDragPos
                ? { left: pipDragPos.x, top: pipDragPos.y, transition: 'none' }
                : { left: isSharingScreen ? undefined : '4rem', right: isSharingScreen ? '0.75rem' : undefined, top: '0.75rem', transition: 'left 0.3s ease, right 0.3s ease, top 0.3s ease' }
            }
          >
            <div className="relative group"
              onMouseDown={(e) => {
                e.preventDefault();
                const rect = pipRef.current?.getBoundingClientRect();
                if (!rect) return;
                const offsetX = e.clientX - rect.left;
                const offsetY = e.clientY - rect.top;
                const onMove = (ev: MouseEvent) => {
                  setPipDragPos({ x: ev.clientX - offsetX, y: ev.clientY - offsetY });
                };
                const onUp = () => {
                  document.removeEventListener('mousemove', onMove);
                  document.removeEventListener('mouseup', onUp);
                  pipCleanupRef.current = null;
                };
                document.addEventListener('mousemove', onMove);
                document.addEventListener('mouseup', onUp);
                pipCleanupRef.current = () => {
                  document.removeEventListener('mousemove', onMove);
                  document.removeEventListener('mouseup', onUp);
                };
              }}
              onTouchStart={(e) => {
                const touch = e.touches[0];
                const rect = pipRef.current?.getBoundingClientRect();
                if (!rect) return;
                const offsetX = touch.clientX - rect.left;
                const offsetY = touch.clientY - rect.top;
                const onMove = (ev: TouchEvent) => {
                  setPipDragPos({ x: ev.touches[0].clientX - offsetX, y: ev.touches[0].clientY - offsetY });
                };
                const onUp = () => {
                  document.removeEventListener('touchmove', onMove);
                  document.removeEventListener('touchend', onUp);
                  pipCleanupRef.current = null;
                };
                document.addEventListener('touchmove', onMove, { passive: true });
                document.addEventListener('touchend', onUp);
                pipCleanupRef.current = () => {
                  document.removeEventListener('touchmove', onMove);
                  document.removeEventListener('touchend', onUp);
                };
              }}
            >
              <video ref={localVideoRef} autoPlay muted playsInline
                className={`${pipShapeStyles[pipShape]} border-2 shadow-lg bg-buddy-surface transition-all duration-200 ${
                  provider && isCamOn ? 'opacity-100 border-buddy-green' : 'opacity-0 pointer-events-none'
                }`}
              />
              <button onClick={() => setShowPipMenu(!showPipMenu)}
                className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-buddy-surface border border-buddy-surface-raised flex items-center justify-center text-buddy-text-secondary hover:text-white opacity-0 group-hover:opacity-100 transition-opacity"
              ><ChevronDown size={10} /></button>
            </div>
            {showPipMenu && (
              <div className="absolute top-full left-0 mt-1 bg-buddy-surface rounded-xl p-1.5 shadow-xl border border-buddy-surface-raised z-40 min-w-[130px]">
                {PIP_OPTIONS.map((opt) => (
                  <button key={opt.value}
                    onClick={() => { setPipShape(opt.value as PipShape); setShowPipMenu(false); }}
                    className={`flex items-center gap-2 w-full px-2 py-1.5 rounded-lg text-xs transition-colors ${pipShape === opt.value ? 'bg-buddy-green/20 text-buddy-green' : 'text-buddy-text-secondary hover:text-white hover:bg-buddy-surface-raised'}`}
                  >
                    <div className={`w-5 h-5 border border-current ${opt.preview}`} />
                    {opt.label}
                  </button>
                ))}
              </div>
            )}
          </div>
          )}

          {/* HOST ROW — fixed at top, horizontal scroll */}
          {connectionState === 'connected' && allAttendees.length > 3 && hostRowPinned && (
            <div className="absolute top-0 right-0 left-16 z-20 pointer-events-none">
              <div className="flex items-center gap-1.5 px-2 pt-2 overflow-x-auto scrollbar-hide pointer-events-auto">
                {hosts.map((h) => (
                  <button key={h.id} onClick={() => setFocusedSpeakerId(h.id)}
                    className={`flex flex-col items-center gap-0.5 shrink-0 transition-all ${focusedSpeakerId === h.id ? 'scale-110' : 'opacity-70 hover:opacity-100'}`}
                  >
                    <div className={`relative w-11 h-11 rounded-full overflow-hidden border-2 transition-all ${
                      h.isSpeaking ? 'border-buddy-green shadow-lg shadow-buddy-green/30' : 'border-buddy-surface'
                    }`}>
                      {h.avatarUrl ? (
                        <img src={h.avatarUrl} alt={h.displayName} className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center bg-buddy-surface text-buddy-text-secondary text-xs font-semibold">
                          {h.displayName.charAt(0).toUpperCase()}
                        </div>
                      )}
                    </div>
                    <span className="text-[9px] text-white/70 truncate max-w-[50px] text-center leading-tight">{h.displayName.split(' ')[0]}</span>
                  </button>
                ))}
                <button onClick={() => setHostRowPinned(false)}
                  className="shrink-0 px-1.5 py-0.5 rounded text-[9px] text-white/40 hover:text-white/70 border border-white/10"
                >Unpin</button>
              </div>
            </div>
          )}

          {/* GALLERY GRID — scrollable vertically, below host row */}
          {connectionState === 'connected' && !isAudioLive && (
            <div className={`absolute inset-0 z-10 overflow-y-auto scrollbar-hide ${hostRowPinned && allAttendees.length > 3 ? 'pt-14' : 'pt-0'} pb-36`}>
              <div className="grid grid-cols-3 md:grid-cols-4 xl:grid-cols-5 gap-1.5 p-1.5 pl-12 auto-rows-[minmax(80px,1fr)]">
                {/* Screen share block (2×2, pinned top-left) */}
                {isSharingScreen && (
                  <div className="col-span-2 row-span-2 rounded-lg overflow-hidden bg-buddy-surface border border-buddy-red/30 flex items-center justify-center text-buddy-text-secondary text-xs">
                    {screenVideoTrackRef.current ? (
                      <video ref={(el) => {
                        if (el && screenVideoTrackRef.current) {
                          if (!(el.srcObject instanceof MediaStream)) {
                            try { el.srcObject = new MediaStream([screenVideoTrackRef.current]); } catch {}
                          }
                        }
                      }} autoPlay muted playsInline className="w-full h-full object-contain" />
                    ) : (
                      <span className="flex flex-col items-center gap-1"><Monitor size={24} /><span>Starting…</span></span>
                    )}
                  </div>
                )}

                {/* Attendee tiles */}
                {allAttendees.filter((a) => !a.isLocal).map((att) => (
                  <div key={att.id} onClick={() => setFocusedSpeakerId(att.id)}
                    className={`relative rounded-lg overflow-hidden bg-buddy-surface border transition-all cursor-pointer ${
                      att.isSpeaking ? 'border-buddy-green ring-1 ring-buddy-green/30' : 'border-buddy-surface-raised hover:border-white/20'
                    } ${focusedSpeakerId === att.id ? 'ring-2 ring-buddy-green' : ''}`}
                  >
                    {att.hasVideoOn || videoTrackMap.get(att.id) ? (
                      <video ref={(el) => {
                        if (el && videoTrackMap.has(att.id)) {
                          const existing = el.srcObject instanceof MediaStream;
                          if (!existing) {
                            try { el.srcObject = new MediaStream([videoTrackMap.get(att.id)!]); } catch {}
                          }
                        }
                      }} autoPlay muted playsInline className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex flex-col items-center justify-center gap-1.5 bg-buddy-surface-raised/60">
                        {att.avatarUrl ? (
                          <img src={att.avatarUrl} alt={att.displayName} className="w-14 h-14 rounded-full object-cover ring-2 ring-buddy-surface-raised" />
                        ) : (
                          <div className="w-14 h-14 rounded-full bg-gradient-to-br from-buddy-green/30 to-buddy-electric/20 flex items-center justify-center text-white text-xl font-bold ring-2 ring-buddy-surface-raised">
                            {att.displayName.charAt(0).toUpperCase()}
                          </div>
                        )}
                        <span className="text-[9px] text-white/70 truncate max-w-[80%] text-center font-medium">{att.displayName}</span>
                        {!att.hasMicOn && !att.hasVideoOn ? (
                          <span className="text-[8px] text-buddy-text-secondary/60 bg-buddy-black/40 px-1.5 py-0.5 rounded-full">Listening Only</span>
                        ) : (
                          <span className="text-[8px] text-buddy-text-secondary/60 bg-buddy-black/40 px-1.5 py-0.5 rounded-full">Camera Off</span>
                        )}
                      </div>
                    )}
                    {/* Mic indicator */}
                    {att.hasMicOn && (
                      <span className={`absolute top-1 right-1 w-2.5 h-2.5 rounded-full border border-buddy-black ${att.isSpeaking ? 'bg-buddy-green' : 'bg-buddy-green/50'}`} />
                    )}
                    {/* Name bar */}
                    <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-buddy-black/80 to-transparent px-1.5 py-1">
                      <span className="text-[9px] text-white/80 truncate block">{att.displayName}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* AUDIO-ONLY PANEL */}
          {connectionState === 'connected' && isAudioLive && (
            <div className="absolute inset-0 z-10 flex flex-col items-center justify-center px-6 pb-24">
              <div className="flex items-end gap-2 h-24 mb-6">
                {[0.6, 1, 0.75, 1.2, 0.5, 0.9, 1.1, 0.65, 1, 0.8, 1.15, 0.55].map((h, i) => (
                  <span key={i}
                    className={`w-1.5 rounded-full bg-gradient-to-t from-buddy-green to-buddy-electric transition-all ${isMicOn ? 'animate-pulse' : 'opacity-30'}`}
                    style={{ height: `${h * 100}%`, animationDelay: `${i * 0.08}s`, animationDuration: '0.9s' }}
                  />
                ))}
              </div>
              <Avatar src={roomData?.host_avatar} alt={roomData?.host_name} size="xl" className="ring-4 ring-buddy-green/30" />
              <p className="mt-4 text-lg font-bold text-white">{roomData?.title}</p>
              <p className="text-sm text-buddy-text-secondary">{roomData?.host_name} • Audio Live</p>
              <p className="mt-2 flex items-center gap-1.5 text-xs text-buddy-green">
                <span className="w-2 h-2 bg-buddy-red rounded-full animate-pulse" /> LIVE
                <span className="text-buddy-text-secondary ml-1">{viewerCount} listening</span>
              </p>
            </div>
          )}

          {/* LIVE CHAT STREAM */}
          {connectionState === 'connected' && (
            <div className="absolute bottom-0 left-0 right-0 z-10 pointer-events-none">
              <div className="max-h-[140px] overflow-y-auto px-4 pt-6 pb-2 bg-gradient-to-t from-buddy-black/80 via-buddy-black/40 to-transparent">
                <div className="flex flex-col-reverse gap-1.5">
                  {[...liveMessages].reverse().map((msg, i) => (
                    <div key={`${msg.timestamp}-${i}`} className="flex items-start gap-2 text-sm">
                      <Avatar src={msg.avatar_url} alt={msg.display_name} size="sm" className="shrink-0 mt-0.5" />
                      <div className="flex-1 min-w-0">
                        {msg.reply_data && (
                          <div className="mb-0.5 text-[10px] text-buddy-text-secondary bg-buddy-black/30 rounded px-1.5 py-0.5 truncate max-w-[260px]">
                            ↪ @{msg.reply_data.sender_name}: {msg.reply_data.message}
                          </div>
                        )}
                        <span className="text-xs font-semibold text-white/90 mr-1.5">{msg.display_name}</span>
                        <span className="text-white/80 text-xs break-words">{msg.message}</span>
                        {msg.gift && (
                          <span className="inline-flex items-center gap-1 ml-1 text-buddy-green">
                            <ArtifactIcon artifact={msg.gift.artifact_type} size={12} />
                            <span className="font-coin text-xs">x{msg.gift.quantity}</span>
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* SCREEN SHARE TOAST */}
          {showScreenShareToast && (
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 animate-slide-in-down">
              <div className="bg-buddy-green/90 backdrop-blur text-white px-4 py-2 rounded-full text-sm font-semibold flex items-center gap-2 shadow-xl">
                <Monitor size={16} /> Screen sharing started
              </div>
            </div>
          )}
        </div>

        {/* BOTTOM CONTROLS */}
        {connectionState !== 'connecting' && connectionState !== 'failed' && (
          <div className="absolute bottom-0 left-0 right-0 z-20 flex items-center justify-center gap-3 px-4 py-3 bg-gradient-to-t from-buddy-black/90 via-buddy-black/60 to-transparent">
            <div className="relative flex items-center justify-center">
              <VoiceIndicator audioTrack={localAudioTrackRef.current} isMicOn={isMicOn} />
              <button onClick={toggleMic}
                className={`relative z-10 p-2.5 rounded-full transition-colors ${isMicOn ? 'bg-buddy-surface/80 backdrop-blur text-buddy-text-primary' : 'bg-buddy-red text-white'}`}
              >{isMicOn ? <Mic size={16} className="opacity-80" /> : <MicOff size={16} />}</button>
            </div>

            <div className="flex gap-1">
              {REACTIONS.map(({ emoji, label }) => (
                <button key={emoji} onClick={() => handleReaction(emoji)}
                  title={label}
                  className="p-2 rounded-full bg-buddy-surface/50 hover:bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary transition-colors text-lg"
                >{emoji}</button>
              ))}
            </div>

            {/* Screen share — host/co-host only */}
            {(isHost || roomData?.co_hosts?.some((ch) => ch.user_id === myUserId)) && (
              <button onClick={toggleScreenShare}
                className={`p-2.5 rounded-full transition-colors ${isSharingScreen ? 'bg-buddy-red text-white' : 'bg-buddy-surface text-buddy-text-primary'}`}
                title={isSharingScreen ? 'Stop Sharing' : 'Share Screen'}
              ><Monitor size={16} /></button>
            )}

            <button onClick={() => setShowChat(!showChat)}
              className={`p-2.5 rounded-full transition-colors ${showChat ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-text-primary'}`}
            >{showChat ? <MessageCircle size={16} /> : <MessageCircleOff size={16} />}</button>

            {isHost ? (
              <button onClick={() => setShowEndConfirm(true)}
                className="p-2.5 rounded-full bg-buddy-red text-white"
              ><PhoneOff size={16} /></button>
            ) : (
              <button onClick={handleLeave}
                className="p-2.5 rounded-full bg-buddy-red/80 text-white"
              ><LogOut size={16} /></button>
            )}

            {/* Request to speak (attendees) */}
            {!isHost && !roomData?.co_hosts?.some((ch) => ch.user_id === myUserId) && (
              <button onClick={async () => {
                if (!liveId || hasRequestedToSpeak) return;
                try {
                  await livesApi.requestToSpeak(liveId);
                  setHasRequestedToSpeak(true);
                  sendCohostEvent('cohost_request', { display_name: profile?.display_name || myUserId });
                  showCohostToast('Request sent to host');
                } catch {}
              }}
                className={`p-2.5 rounded-full transition-colors ${hasRequestedToSpeak ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-text-primary'}`}
                title={hasRequestedToSpeak ? 'Request sent — waiting for host' : 'Request to speak'}
              >{hasRequestedToSpeak ? <Check size={16} /> : <UserPlus size={16} />}</button>
            )}

            {!isAudioLive && (
            <button onClick={toggleCam}
              className={`p-2.5 rounded-full transition-colors ${isCamOn ? 'bg-buddy-surface text-buddy-text-primary' : 'bg-buddy-red text-white'}`}
            >{isCamOn ? <Video size={16} /> : <VideoOff size={16} />}</button>
            )}
          </div>
        )}

        {/* Floating reaction animations */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 flex flex-wrap gap-2 pointer-events-none z-30">
          {reactions.filter(Boolean).map((r, i) => (
            <span key={`${r.timestamp}-${i}`} className="text-3xl animate-bounce">{r.emoji}</span>
          ))}
        </div>

        {/* CHAT OVERLAY (right panel on desktop, bottom sheet on tablet/phone) */}
        {showChat && (
          <div className={`absolute inset-0 z-40 flex ${isDesktop ? 'justify-end' : 'flex-col justify-end'}`}>
            <div className="flex-1 bg-buddy-black/50" onClick={() => setShowChat(false)} />
            <div className={`flex flex-col bg-buddy-black/95 ${isDesktop ? 'w-80 border-l border-buddy-surface' : 'w-full h-[55vh] border-t border-buddy-surface rounded-t-2xl'}`}>
              <div className="flex items-center justify-between px-4 py-3 border-b border-buddy-surface shrink-0">
                <h3 className="text-sm font-semibold">Live Chat</h3>
                <div className="flex items-center gap-2">
                  <span className="text-xs text-buddy-text-secondary">{chatMessages.length} messages</span>
                  <button onClick={() => setShowChat(false)} className="text-buddy-text-secondary p-1"><X size={16} /></button>
                </div>
              </div>

              <div className="flex-1 overflow-y-auto p-3 space-y-2">
                {chatMessages.length === 0 && (
                  <p className="text-center text-buddy-text-secondary/50 text-sm mt-8">No messages yet. Say hi!</p>
                )}
                {[...chatMessages].sort((a) => (a.priority ? -1 : 1)).map((msg, i) => (
                  <div key={i} className={`flex gap-2 ${msg.user_id === myUserId ? 'flex-row-reverse' : ''} ${msg.priority ? 'bg-buddy-green/5 -mx-3 px-3 py-1.5 rounded-lg border border-buddy-green/20' : ''}`}>
                    <Avatar src={msg.avatar_url} alt={msg.display_name} size="sm" className="shrink-0" />
                    <div className={`max-w-[80%] ${msg.user_id === myUserId ? 'items-end' : ''}`}>
                      <p className="text-xs text-buddy-text-secondary mb-0.5 flex items-center gap-1">
                        {msg.display_name}
                        {msg.gift && <Gift size={10} className="text-buddy-green" />}
                      </p>
                      <div className={`rounded-xl px-3 py-1.5 text-sm ${
                        msg.user_id === myUserId ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-text-primary'
                      }`}>
                        {msg.reply_data && (
                          <div className="mb-1 text-[10px] opacity-70 bg-buddy-black/20 rounded px-1.5 py-0.5 truncate">
                            ↪ @{msg.reply_data.sender_name}: {msg.reply_data.message}
                          </div>
                        )}
                        {msg.message}
                        {msg.gift && (
                          <div className="mt-1 pt-1 border-t border-white/10 text-xs flex items-center gap-1">
                            <ArtifactIcon artifact={msg.gift.artifact_type} size={14} />
                            <span className="font-coin">x{msg.gift.quantity}</span>
                          </div>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-0.5">
                        <button onClick={() => { setReplyTo(msg); setShowChat(true); }}
                          className="text-[10px] text-buddy-text-secondary hover:text-buddy-green flex items-center gap-0.5 transition-colors"
                        ><Reply size={10} /> Reply</button>
                        {msg.gift && isHost && (
                          <button onClick={async () => {
                            try {
                              await livesApi.refundGift(liveId!, msg.gift!.tx_id);
                            } catch {}
                          }} className="text-[10px] text-buddy-red/60 hover:text-buddy-red flex items-center gap-0.5">
                            <X size={10} /> Refund
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
                <div ref={chatEndRef} className="h-px" />
              </div>

              {replyTo && (
                <div className="px-3 pt-2 flex items-center gap-2 bg-buddy-surface/40 border-t border-buddy-surface">
                  <Reply size={12} className="text-buddy-green shrink-0" />
                  <div className="flex-1 min-w-0 text-xs text-buddy-text-secondary truncate">
                    Replying to <span className="text-buddy-text-primary font-medium">{replyTo.display_name}</span>
                    {replyTo.message && <span className="truncate block text-[11px] opacity-70">{replyTo.message}</span>}
                  </div>
                  <button onClick={() => setReplyTo(null)} className="text-buddy-text-secondary p-0.5"><X size={14} /></button>
                </div>
              )}

              <form onSubmit={handleSendChat} className="p-3 border-t border-buddy-surface flex gap-2 shrink-0">
                {selectedGift ? (
                  <div className="flex items-center gap-1.5 bg-buddy-green/10 rounded-lg px-2 py-1">
                    <ArtifactIcon artifact={selectedGift.type} size={14} />
                    <span className="font-coin text-xs font-bold">x{selectedGift.qty}</span>
                    <button onClick={() => setSelectedGift(null)} className="ml-0.5 text-buddy-text-secondary"><X size={12} /></button>
                  </div>
                ) : (
                  <button type="button" onClick={openGiftPicker}
                    className="p-2 rounded-xl bg-buddy-surface text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10 transition-colors"
                    title="Attach Gift"
                  ><Gift size={16} /></button>
                )}
                <input type="text" value={chatInput} onChange={(e) => setChatInput(e.target.value)}
                  placeholder={selectedGift ? `Gifting ${selectedGift.qty}x ${selectedGift.type}...` : 'Type a message...'}
                  className="flex-1 bg-buddy-surface rounded-xl px-3 py-2 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
                <button type="submit" disabled={!chatInput.trim() && !selectedGift}
                  className="p-2 rounded-xl bg-buddy-green text-buddy-black disabled:opacity-30"
                ><Send size={16} /></button>
              </form>
            </div>
          </div>
        )}

        {/* INLINE GIFT PICKER (inside chat overlay) */}
        {showGiftPicker && (
          <div className="absolute right-0 bottom-[60px] z-50 bg-buddy-surface rounded-2xl p-4 shadow-2xl border border-buddy-surface-raised w-[85vw] max-w-xs" onClick={() => setShowGiftPicker(false)}>
            <div className="space-y-2" onClick={(e) => e.stopPropagation()}>
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-semibold flex items-center gap-1.5"><Gift size={12} /> Attach Gift</h4>
                <button onClick={() => setShowGiftPicker(false)} className="text-buddy-text-secondary"><X size={14} /></button>
              </div>
              <div className="grid grid-cols-4 gap-1.5">
                {ARTIFACT_LIST.map((a) => {
                  const bal = artifactBalance[a.type as keyof typeof artifactBalance] || 0;
                  return (
                    <button key={a.type}
                      onClick={() => {
                        if (bal < 1) {
                          setShowGiftPicker(false);
                          setShowRechargePrompt(true);
                          return;
                        }
                        selectGiftForChat(a.type);
                      }}
                      className={`flex flex-col items-center gap-0.5 p-1.5 rounded-xl transition-colors ${bal < 1 ? 'opacity-30' : 'hover:bg-buddy-surface-raised'}`}
                    >
                      <ArtifactIcon artifact={a.type} size={20} />
                      <span className="font-coin text-[10px]">{bal}</span>
                    </button>
                  );
                })}
              </div>
              {selectedGift && (
                <div className="flex items-center gap-2 pt-1 border-t border-buddy-surface-raised">
                  <span className="text-[10px] text-buddy-text-secondary">Qty:</span>
                  {[1, 5, 10, 25].map((q) => (
                    <button key={q} onClick={() => setSelectedGift({ ...selectedGift, qty: q })}
                      className={`px-2 py-0.5 rounded-lg text-xs font-semibold transition-colors ${selectedGift.qty === q ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface-raised text-buddy-text-secondary'}`}
                    >{q}</button>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* FLOATING GIFT ANIMATIONS */}
        <div className="absolute bottom-24 left-1/2 -translate-x-1/2 pointer-events-none z-30">
          {floatingGifts.map((g) => (
            <div key={g.id} className="animate-float-up">
              <ArtifactIcon artifact={g.artifactType} size={32} />
            </div>
          ))}
        </div>

        {/* RECHARGE PROMPT */}
        {showRechargePrompt && (
          <div className="fixed inset-0 z-[70] bg-buddy-black/60 flex items-center justify-center p-4" onClick={() => setShowRechargePrompt(false)}>
            <div className="bg-buddy-surface rounded-2xl p-5 max-w-xs w-full space-y-3" onClick={(e) => e.stopPropagation()}>
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-semibold flex items-center gap-2"><Coins size={16} /> Insufficient Balance</h3>
                <button onClick={() => setShowRechargePrompt(false)} className="text-buddy-text-secondary"><X size={18} /></button>
              </div>
              <p className="text-xs text-buddy-text-secondary">You don't have enough artifacts to send this gift. Recharge your account to continue.</p>
              <Button className="w-full" onClick={() => { setShowRechargePrompt(false); navigate('/marketplace'); }}>
                <Coins size={14} /> Recharge Now
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* END CONFIRM */}
      {showEndConfirm && (
        <div className="fixed inset-0 z-[60] bg-buddy-black/80 flex items-center justify-center p-4">
          <div className="bg-buddy-surface rounded-2xl p-6 max-w-sm w-full space-y-4">
            <h2 className="text-lg font-semibold">End this live?</h2>
            <p className="text-sm text-buddy-text-secondary">Do you want to save the recording for replays?</p>
            <div className="flex flex-col gap-2">
              <Button className="w-full" onClick={() => { setShowEndConfirm(false); handleEndLive(true); }}>
                Save Replay & End
              </Button>
              <Button variant="outline" className="w-full" onClick={() => { setShowEndConfirm(false); handleEndLive(false); }}>
                End Without Saving
              </Button>
              <Button variant="ghost" className="w-full" onClick={() => setShowEndConfirm(false)}>
                Cancel
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
