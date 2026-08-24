/**
 * CallRoom.tsx – Full-screen multi-party LiveKit call overlay.
 * Features: participant grid (N people), camera-off placeholders,
 * screen share, add-people entry point, PiP-free responsive layout.
 *
 * Media flows peer-to-peer/SFU via LiveKit; signaling & membership are
 * enforced server-side (see ConversationCallSessionView).
 */
import { useEffect, useRef, useState } from 'react';
import {
  PhoneOff, Mic, MicOff, Video, VideoOff, Monitor, MonitorOff, Phone, Users, X, UserPlus,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import type { LkCallState, CallTile } from '@/hooks/useLiveKitCall';

interface CallRoomProps {
  callState: LkCallState;
  callType: 'audio' | 'video';
  cameraError: string | null;
  tiles: CallTile[];
  myUserId: string;
  identityName: string;
  identityAvatar?: string;
  isCallee: boolean; // true = we received the invite
  onAccept: () => void;
  onDecline: () => void;
  onHangUp: () => void;
  onToggleMute: () => void;
  onToggleCamera: () => void;
  onToggleScreenShare: () => Promise<void>;
}

/** Resolve the active video track (screen share wins over camera). */
function activeVideoTrack(participant: unknown): { track: unknown | null; kind: 'screen' | 'camera' } {
  const p = participant as {
    getTrackPublication?: (src: string) => { track?: unknown; isEnabled?: boolean } | undefined;
  } | null;
  if (!p?.getTrackPublication) return { track: null, kind: 'camera' };
  const screen = p.getTrackPublication('screen_share');
  if (screen?.track && screen.isEnabled !== false) return { track: screen.track, kind: 'screen' };
  const cam = p.getTrackPublication('camera');
  if (cam?.track && cam.isEnabled !== false) return { track: cam.track, kind: 'camera' };
  return { track: null, kind: 'camera' };
}

function ParticipantTile({ tile, cols }: { tile: CallTile; cols: number }) {
  const videoRef = useRef<HTMLVideoElement>(null);

  // Attach/detach the tile's video track.
  useEffect(() => {
    const el = videoRef.current;
    const { track } = activeVideoTrack(tile.participant);
    if (!el || !track) return;
    try {
      (track as { attach: (el: HTMLMediaElement) => void }).attach(el);
    } catch { /* noop */ }
    return () => {
      try {
        (track as { detach: (el: HTMLMediaElement) => void }).detach(el);
      } catch { /* noop */ }
    };
  }, [tile]);

  // Attach remote audio exactly once per mic track.
  useEffect(() => {
    if (tile.isLocal) return;
    const p = tile.participant as {
      getTrackPublication?: (src: string) => { track?: unknown; isEnabled?: boolean } | undefined;
    } | null;
    const mic = p?.getTrackPublication?.('microphone')?.track as
      | { attach: () => HTMLMediaElement; detach: (el: HTMLMediaElement) => void }
      | null | undefined;
    if (!mic) return;
    let el: HTMLMediaElement | null = null;
    try { el = mic.attach(); } catch { /* noop */ }
    return () => { try { if (el) mic.detach(el); } catch { /* noop */ } };
  }, [tile.participant]);

  const { kind } = activeVideoTrack(tile.participant);
  const showVideo = tile.isVideoEnabled || tile.isScreenSharing;

  return (
    <div
      className="relative bg-gray-900 rounded-2xl overflow-hidden border border-gray-800 min-h-0"
      style={{ aspectRatio: cols > 1 ? undefined : undefined }}
    >
      {showVideo ? (
        <video ref={videoRef} autoPlay playsInline className="absolute inset-0 w-full h-full object-cover" />
      ) : (
        <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 bg-gradient-to-b from-gray-800/50 to-gray-900">
          <Avatar src={tile.avatarUrl} alt={tile.name} size={cols > 2 ? 'md' : 'lg'} className="opacity-70" />
          <VideoOff size={16} className="text-gray-500" />
        </div>
      )}
      <div className="absolute bottom-2 left-2 right-2 flex items-center gap-1.5">
        <span className="text-[11px] font-semibold text-white bg-black/60 rounded-full px-2 py-0.5 truncate max-w-[70%]">
          {tile.isLocal ? 'You' : tile.name}
          {kind === 'screen' ? ' (screen)' : ''}
        </span>
        {!tile.isAudioEnabled && (
          <span className="bg-black/60 rounded-full p-1"><MicOff size={11} className="text-red-400" /></span>
        )}
      </div>
    </div>
  );
}

export function CallRoom({
  callState, callType, cameraError, tiles, myUserId,
  identityName, identityAvatar, isCallee,
  onAccept, onDecline, onHangUp, onToggleMute, onToggleCamera, onToggleScreenShare,
}: CallRoomProps) {
  const ringAudioRef = useRef<HTMLAudioElement>(null);
  const [showAddPeople, setShowAddPeople] = useState(false);
  const [durationSecs, setDurationSecs] = useState(0);

  // Duration timer
  useEffect(() => {
    if (callState === 'in_call') {
      const interval = setInterval(() => setDurationSecs((v) => v + 1), 1000);
      return () => clearInterval(interval);
    }
    setDurationSecs(0);
  }, [callState]);

  // Ringing audio
  useEffect(() => {
    if (callState === 'calling' || (callState === 'ringing' && isCallee)) {
      ringAudioRef.current?.play().catch(() => {});
    } else if (ringAudioRef.current) {
      ringAudioRef.current.pause();
      ringAudioRef.current.currentTime = 0;
    }
  }, [callState, isCallee]);

  if (callState === 'idle') return null;

  const isRinging = callState === 'ringing';
  const isCalling = callState === 'calling';
  const isInCall = callState === 'in_call';

  const localTile = tiles.find((t) => t.identity === myUserId || t.isLocal);
  const isMuted = localTile ? !localTile.isAudioEnabled : false;
  const isCameraOff = localTile ? !localTile.isVideoEnabled : true;
  const isSharingScreen = tiles.some((t) => t.isLocal && t.isScreenSharing);

  const formatDuration = (secs: number) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  const statusLabel = isCalling ? 'Calling…'
    : isRinging && isCallee ? 'Incoming call'
    : isRinging ? 'Ringing…'
    : isInCall ? `${tiles.length} in call`
    : 'Call ended';

  const cols = tiles.length <= 1 ? 1 : tiles.length <= 4 ? 2 : 3;
  const anySharing = tiles.some((t) => t.isScreenSharing);

  return (
    <div className="fixed inset-0 z-[100] bg-gradient-to-b from-gray-950 via-gray-900 to-black flex flex-col overflow-hidden"
      style={{ paddingLeft: 'env(safe-area-inset-left)', paddingRight: 'env(safe-area-inset-right)' }}>
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-buddy-green to-transparent" />

      {/* ── PRE-CALL ── */}
      {(isCalling || isRinging || callState === 'ended') && (
        <div className="flex-1 flex flex-col items-center justify-center gap-6 p-8 pt-[calc(2rem+env(safe-area-inset-top))]">
          {isRinging && (
            <div className="absolute w-64 h-64 rounded-full border-2 border-buddy-green/20 animate-ping" />
          )}
          <div className="relative">
            <Avatar
              src={identityAvatar}
              alt={identityName}
              size="xl"
              className="w-32 h-32 ring-4 ring-buddy-green/30 shadow-[0_0_60px_rgba(0,255,157,0.15)]"
            />
            {isRinging && (
              <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-buddy-green rounded-full flex items-center justify-center shadow-lg">
                {callType === 'video' ? <Video size={14} className="text-black" /> : <Phone size={14} className="text-black" />}
              </div>
            )}
          </div>
          <div className="text-center">
            <h2 className="text-2xl font-bold font-display text-white mb-1">{identityName}</h2>
            <p className={`text-sm font-medium ${isRinging ? 'text-buddy-green animate-pulse' : 'text-gray-400'}`}>
              {statusLabel}
            </p>
          </div>
          {callState === 'ended' && <p className="text-gray-500 text-sm">Call ended</p>}
        </div>
      )}

      {/* ── IN-CALL grid ── */}
      {isInCall && (
        <div className="flex-1 relative overflow-hidden flex flex-col pt-[calc(1rem+env(safe-area-inset-top))] px-3 pb-2">
          {/* Status bar */}
          <div className="flex items-center gap-2 mb-2 shrink-0">
            <div className="bg-black/50 text-white text-xs font-mono px-3 py-1.5 rounded-lg backdrop-blur-sm flex items-center gap-2">
              {anySharing && <Monitor size={12} className="text-buddy-green" />}
              {formatDuration(durationSecs)}
            </div>
            <div className="bg-black/50 text-white/80 text-xs px-3 py-1.5 rounded-lg backdrop-blur-sm flex items-center gap-1.5">
              <Users size={12} />
              {tiles.length}
            </div>
            {cameraError && (
              <div className="bg-yellow-900/80 border border-yellow-600/50 rounded-xl px-3 py-1.5 text-xs text-yellow-300 truncate">
                {cameraError} — audio only
              </div>
            )}
          </div>

          {/* Participant grid */}
          <div
            className="flex-1 grid gap-2 min-h-0"
            style={{
              gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))`,
              gridAutoRows: '1fr',
            }}
          >
            {tiles.map((t) => (
              <ParticipantTile key={`${t.identity}-${t.isLocal ? 'l' : 'r'}`} tile={t} cols={cols} />
            ))}
          </div>
        </div>
      )}

      <audio ref={ringAudioRef} src="data:audio/mp3;base64,//NExAAAAANIAAAAAExBTUUzLjEwMKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq" preload="auto" />

      {/* ── CONTROLS BAR ── */}
      <div className="shrink-0 px-4 pb-[calc(1.5rem+env(safe-area-inset-bottom))] pt-4">
        {/* Add people panel */}
        {showAddPeople && (
          <div className="mb-4 bg-gray-900 border border-gray-700 rounded-2xl p-4 animate-in fade-in slide-in-from-bottom-2">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm font-semibold text-white">Add people</p>
              <button onClick={() => setShowAddPeople(false)} className="p-1 text-gray-500 hover:text-white">
                <X size={14} />
              </button>
            </div>
            <p className="text-xs text-gray-500 text-center py-3">
              Everyone in this conversation can join — they&apos;ll see the call ringing.
              Invite more members from the conversation header.
            </p>
          </div>
        )}

        <div className="flex flex-wrap items-center justify-center gap-2 md:gap-3">
          {/* Mute */}
          <button
            onClick={onToggleMute}
            className={`w-13 h-13 rounded-full flex items-center justify-center transition-all ${
              isMuted ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'
            }`}
            title={isMuted ? 'Unmute' : 'Mute'}
          >
            {isMuted ? <MicOff size={20} /> : <Mic size={20} />}
          </button>

          {/* End / decline */}
          <button
            onClick={isRinging && isCallee ? onDecline : onHangUp}
            className="w-16 h-16 rounded-full bg-red-500 hover:bg-red-600 flex items-center justify-center shadow-[0_0_24px_rgba(239,68,68,0.5)] transition-all hover:scale-105"
          >
            <PhoneOff size={24} className="text-white" />
          </button>

          {/* Camera (video calls only) */}
          {callType === 'video' && isInCall && (
            <button
              onClick={onToggleCamera}
              className={`w-13 h-13 rounded-full flex items-center justify-center transition-all ${
                isCameraOff ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'
              }`}
              title={isCameraOff ? 'Enable camera' : 'Disable camera'}
            >
              {isCameraOff ? <VideoOff size={20} /> : <Video size={20} />}
            </button>
          )}

          {/* Screen share (video calls only) */}
          {callType === 'video' && isInCall && (
            <button
              onClick={() => { void onToggleScreenShare(); }}
              className={`w-13 h-13 rounded-full flex items-center justify-center transition-all ${
                isSharingScreen ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'
              }`}
              title={isSharingScreen ? 'Stop sharing' : 'Share screen'}
            >
              {isSharingScreen ? <MonitorOff size={20} /> : <Monitor size={20} />}
            </button>
          )}

          {/* Add people */}
          {isInCall && (
            <button
              onClick={() => setShowAddPeople((v) => !v)}
              className="w-13 h-13 rounded-full flex items-center justify-center bg-gray-800 text-white hover:bg-gray-700 transition-all"
              title="Add people"
            >
              <UserPlus size={18} />
            </button>
          )}
        </div>

        {/* Accept / Decline for incoming call */}
        {isRinging && isCallee && (
          <div className="flex items-center justify-center gap-8 mt-6">
            <div className="flex flex-col items-center gap-1.5">
              <button
                onClick={onDecline}
                className="w-16 h-16 rounded-full bg-red-500/20 border border-red-500/40 text-red-400 hover:bg-red-500/30 flex items-center justify-center transition-all"
              >
                <PhoneOff size={22} />
              </button>
              <span className="text-xs text-gray-500">Decline</span>
            </div>
            <div className="flex flex-col items-center gap-1.5">
              <button
                onClick={onAccept}
                className="w-16 h-16 rounded-full bg-buddy-green text-black flex items-center justify-center shadow-[0_0_24px_rgba(0,255,157,0.4)] hover:bg-buddy-green-deep transition-all hover:scale-105"
              >
                {callType === 'video' ? <Video size={22} /> : <Phone size={22} />}
              </button>
              <span className="text-xs text-gray-400">Accept</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
