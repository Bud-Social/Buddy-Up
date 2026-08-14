/**
 * CallRoom.tsx – Full-screen advanced call overlay.
 * Features: group call grid, camera-off placeholders, screen share,
 * floating emoji reactions, add-people panel, PiP self-view.
 */
import { useRef, useEffect, useState } from 'react';
import {
  PhoneOff, Mic, MicOff, Video, VideoOff, Monitor, MonitorOff,
  Users, Smile, UserPlus, X, Phone,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import type { CallState } from '@/hooks/useWebRTC';
import type { Conversation } from '@/api/messaging';

const CALL_EMOJIS = ['❤️', '👍', '😂', '😮', '🔥', '💪', '👏', '🎉'];

interface Participant {
  username: string;
  display_name: string;
  avatar_url?: string;
  verification_status?: string;
}

interface CallRoomProps {
  callState: CallState;
  callType: 'audio' | 'video';
  isMuted: boolean;
  isRemoteMuted: boolean;
  isCameraOff: boolean;
  isSharingScreen: boolean;
  isRecording: boolean;
  cameraError: string | null;
  localStream: MediaStream | null;
  remoteStream: MediaStream | null;
  floatingReactions: { id: number; emoji: string }[];
  // The person we're in a call with (1-on-1) or participants array (group)
  otherParticipant: Participant | null;
  activeConvo: Conversation | null;
  isCallee: boolean; // true = we received the call, false = we initiated
  isGroupCall?: boolean;
  groupParticipants?: Participant[];
  onAccept: () => void;
  onDecline: () => void;
  onHangUp: () => void;
  onToggleMute: () => void;
  onToggleCamera: () => void;
  onToggleScreenShare: () => Promise<void>;
  onToggleRecording: () => void;
  onSendReaction: (emoji: string) => void;
}

function CameraPlaceholder({ participant, size = 'md' }: { participant?: Participant; size?: 'sm' | 'md' | 'lg' }) {
  const sizeClass = size === 'lg' ? 'w-full h-full' : size === 'md' ? 'w-full h-48' : 'w-24 h-24';
  return (
    <div className={`${sizeClass} bg-gray-900 rounded-2xl flex flex-col items-center justify-center gap-2 relative overflow-hidden`}>
      <div className="absolute inset-0 bg-gradient-to-b from-gray-800/50 to-gray-900" />
      {participant ? (
        <Avatar src={participant.avatar_url} alt={participant.display_name} size={size === 'lg' ? 'xl' : 'lg'} className="relative z-10 opacity-60" />
      ) : (
        <VideoOff size={size === 'lg' ? 40 : 24} className="text-gray-500 relative z-10" />
      )}
      {participant && (
        <p className="text-xs text-gray-400 font-medium relative z-10">{participant.display_name}</p>
      )}
    </div>
  );
}

export function CallRoom({
  callState, callType, isMuted, isRemoteMuted, isCameraOff, isSharingScreen, isRecording, cameraError,
  localStream, remoteStream, floatingReactions,
  otherParticipant, activeConvo, isCallee, isGroupCall, groupParticipants,
  onAccept, onDecline, onHangUp, onToggleMute, onToggleCamera,
  onToggleScreenShare, onToggleRecording, onSendReaction,
}: CallRoomProps) {
  const localVideoRef = useRef<HTMLVideoElement>(null);
  const remoteVideoRef = useRef<HTMLVideoElement>(null);
  const remoteAudioRef = useRef<HTMLAudioElement>(null);
  const ringAudioRef = useRef<HTMLAudioElement>(null);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [showAddPeople, setShowAddPeople] = useState(false);
  const [durationSecs, setDurationSecs] = useState(0);

  // Duration timer
  useEffect(() => {
    if (callState === 'in_call') {
      const interval = setInterval(() => setDurationSecs((v) => v + 1), 1000);
      return () => clearInterval(interval);
    } else {
      setDurationSecs(0);
    }
  }, [callState]);

  // Ringing audio
  useEffect(() => {
    if (callState === 'calling' || (callState === 'ringing' && isCallee)) {
      if (ringAudioRef.current) {
        ringAudioRef.current.loop = true;
        ringAudioRef.current.play().catch(() => {});
      }
    } else {
      if (ringAudioRef.current) {
        ringAudioRef.current.pause();
        ringAudioRef.current.currentTime = 0;
      }
    }
  }, [callState, isCallee]);

  const formatDuration = (secs: number) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  // Attach streams to video elements
  useEffect(() => {
    if (localVideoRef.current && localStream) localVideoRef.current.srcObject = localStream;
  }, [localStream]);

  useEffect(() => {
    if (remoteStream) {
      if (callType === 'video' && remoteVideoRef.current) remoteVideoRef.current.srcObject = remoteStream;
      if (callType === 'audio' && remoteAudioRef.current) remoteAudioRef.current.srcObject = remoteStream;
    }
  }, [remoteStream, callType]);

  if (callState === 'idle') return null;

  const isRinging = callState === 'ringing';
  const isCalling = callState === 'calling';
  const isInCall = callState === 'in_call';
  const isEnded = callState === 'ended';

  const displayName = otherParticipant?.display_name ?? activeConvo?.group_name ?? 'Unknown';
  const avatarUrl = otherParticipant?.avatar_url ?? activeConvo?.group_avatar_url;

  const statusLabel = isCalling ? 'Calling…'
    : isRinging && isCallee ? 'Incoming call'
    : isRinging ? 'Ringing…'
    : isInCall ? 'Connected'
    : 'Call ended';

  return (
    <div className="fixed inset-0 z-[100] bg-gradient-to-b from-gray-950 via-gray-900 to-black flex flex-col overflow-hidden" style={{ paddingLeft: 'env(safe-area-inset-left)', paddingRight: 'env(safe-area-inset-right)' }}>
      {/* Top glow strip */}
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-buddy-green to-transparent" />

      {/* Floating emoji reactions */}
      <div className="absolute inset-0 pointer-events-none z-30 overflow-hidden">
        {floatingReactions.map((r) => (
          <div
            key={r.id}
            className="absolute bottom-24 text-4xl animate-float-up"
            style={{ left: `${20 + Math.random() * 60}%` }}
          >
            {r.emoji}
          </div>
        ))}
      </div>

      {/* ── PRE-CALL: Calling / Ringing states ── */}
      {(isCalling || isRinging || isEnded) && (
        <div className="flex-1 flex flex-col items-center justify-center gap-6 p-8 pt-[calc(2rem+env(safe-area-inset-top))]">
          {/* Pulse ring when ringing */}
          {isRinging && (
            <div className="absolute w-64 h-64 rounded-full border-2 border-buddy-green/20 animate-ping" />
          )}
          <div className="relative">
            <Avatar
              src={avatarUrl}
              alt={displayName}
              size="xl"
              verificationStatus={otherParticipant?.verification_status}
              className="w-32 h-32 ring-4 ring-buddy-green/30 shadow-[0_0_60px_rgba(0,255,157,0.15)]"
            />
            {isRinging && (
              <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-buddy-green rounded-full flex items-center justify-center shadow-lg">
                {callType === 'video' ? <Video size={14} className="text-black" /> : <Phone size={14} className="text-black" />}
              </div>
            )}
          </div>

          <div className="text-center">
            <h2 className="text-2xl font-bold font-display text-white mb-1">{displayName}</h2>
            {isGroupCall && groupParticipants && isRinging && isCallee && (
              <p className="text-sm text-buddy-text-secondary mb-1">
                Group call · {groupParticipants.length + 1} participants
              </p>
            )}
            <p className={`text-sm font-medium ${isRinging ? 'text-buddy-green animate-pulse' : 'text-gray-400'}`}>
              {statusLabel}
            </p>
            {callType === 'video' && (
              <p className="text-xs text-gray-500 mt-1">
                {callType === 'video' ? 'Video call' : 'Voice call'}
              </p>
            )}
          </div>

          {isEnded && (
            <p className="text-gray-500 text-sm">Call ended</p>
          )}
        </div>
      )}

      {/* ── IN-CALL: Video streams ── */}
      {isInCall && callType === 'video' && (
        <div className="flex-1 relative overflow-hidden">
          {/* Remote video (full screen) */}
          {remoteStream ? (
            <video
              ref={remoteVideoRef}
              autoPlay
              playsInline
              className="absolute inset-0 w-full h-full object-cover"
            />
          ) : (
            <CameraPlaceholder participant={otherParticipant ?? undefined} size="lg" />
          )}

          {/* Camera-off or Muted overlay for remote */}
          {(isCameraOff || isRemoteMuted) && (
            <div className="absolute inset-0 bg-gray-900/90 flex flex-col items-center justify-center gap-3">
              <Avatar src={avatarUrl} alt={displayName} size="xl" className={isCameraOff ? 'opacity-50' : ''} />
              <div className="flex items-center gap-2 text-gray-400">
                {isCameraOff && <><VideoOff size={16} /><span className="text-sm">Camera off</span></>}
                {isRemoteMuted && <><MicOff size={16} className="ml-2" /><span className="text-sm">Muted</span></>}
              </div>
            </div>
          )}

          {/* Screen share banner */}
          {isSharingScreen && (
            <div className="absolute top-4 left-1/2 -translate-x-1/2 bg-buddy-green text-black text-xs font-bold px-4 py-1.5 rounded-full shadow-lg flex items-center gap-1.5" style={{ top: 'calc(1rem + env(safe-area-inset-top))' }}>
              <Monitor size={13} />
              Sharing screen
            </div>
          )}

          {/* Camera error notice */}
          {cameraError && (
            <div className="absolute top-4 left-4 right-4 bg-yellow-900/80 border border-yellow-600/50 rounded-xl px-3 py-2 text-xs text-yellow-300 flex items-center gap-2">
              <VideoOff size={13} className="shrink-0" />
              {cameraError} — audio only
            </div>
          )}

          {/* PiP self-view */}
          <div className="absolute bottom-24 right-4 w-28 h-20 rounded-xl overflow-hidden border-2 border-gray-700 shadow-2xl bg-gray-900">
            {localStream && !isCameraOff ? (
              <video ref={localVideoRef} autoPlay playsInline muted className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center bg-gray-800">
                <VideoOff size={16} className="text-gray-500" />
              </div>
            )}
          </div>

          {/* Group call grid overlay (top strip) */}
          {isGroupCall && groupParticipants && groupParticipants.length > 0 && (
            <div className="absolute top-4 left-4 right-4 flex gap-2 overflow-x-auto scrollbar-none pb-2" style={{ top: 'calc(1rem + env(safe-area-inset-top))' }}>
              {groupParticipants.map((p) => (
                <div key={p.username} className="shrink-0 relative w-14 h-14 rounded-xl overflow-hidden border border-gray-700 bg-gray-900">
                  <Avatar src={p.avatar_url} alt={p.display_name} size="sm" className="w-full h-full" />
                  <div className="absolute inset-x-0 bottom-0 bg-black/60 text-[8px] text-center text-white py-0.5 truncate px-0.5">
                    {p.display_name.split(' ')[0]}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* ── IN-CALL: Audio only (no video) ── */}
      {isInCall && callType === 'audio' && (
        <div className="flex-1 flex flex-col items-center justify-center gap-4">
          <Avatar
            src={avatarUrl}
            alt={displayName}
            size="xl"
            verificationStatus={otherParticipant?.verification_status}
            className="w-28 h-28 ring-4 ring-buddy-green/20 shadow-[0_0_40px_rgba(0,255,157,0.1)]"
          />
          <div className="text-center">
            <h2 className="text-xl font-bold text-white">{displayName}</h2>
            <p className="text-sm text-buddy-green mt-1 font-medium">{formatDuration(durationSecs)}</p>
          </div>
          {/* Animated audio waveform bars */}
          <div className="flex items-end gap-1 h-8">
            {[...Array(7)].map((_, i) => (
              <div
                key={i}
                className={`w-1.5 rounded-full bg-buddy-green ${isMuted ? 'opacity-20' : 'animate-audio-bar'}`}
                style={{
                  height: `${30 + Math.sin(i * 0.9) * 20}%`,
                  animationDelay: `${i * 80}ms`,
                }}
              />
            ))}
          </div>
          {isRemoteMuted && <p className="text-xs text-red-400 font-medium mt-2"><MicOff size={12} className="inline mr-1" /> Remote muted</p>}
          {isMuted && <p className="text-xs text-gray-500">Microphone muted</p>}
        </div>
      )}

      {/* Video duration overlay */}
      {isInCall && callType === 'video' && (
        <div className="absolute top-4 left-4 bg-black/50 text-white text-xs font-mono px-3 py-1.5 rounded-lg backdrop-blur-sm z-20 flex items-center gap-2" style={{ top: 'calc(1rem + env(safe-area-inset-top))' }}>
          {isRecording && <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />}
          {formatDuration(durationSecs)}
        </div>
      )}

      {/* Recording overlay (Audio) */}
      {isInCall && callType === 'audio' && isRecording && (
        <div className="absolute top-8 left-1/2 -translate-x-1/2 bg-red-500/20 border border-red-500/50 text-red-400 text-xs font-bold px-4 py-1.5 rounded-full z-20 flex items-center gap-2 animate-pulse">
          <div className="w-2 h-2 rounded-full bg-red-500" />
          Recording Call...
        </div>
      )}

      <audio ref={remoteAudioRef} autoPlay />
      {/* Empty src means it will just fail silently or we can use a blank data URI. Using a blank data URI for now to prevent errors. */}
      <audio ref={ringAudioRef} src="data:audio/mp3;base64,//NExAAAAANIAAAAAExBTUUzLjEwMKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq" preload="auto" />

      {/* ── CONTROLS BAR ── */}
      <div className="shrink-0 px-4 pb-[calc(1.5rem+env(safe-area-inset-bottom))] pt-4">
        {/* Emoji picker popup */}
        {showEmojiPicker && (
          <div className="flex justify-center gap-2 mb-4 animate-in fade-in slide-in-from-bottom-2">
            {CALL_EMOJIS.map((e) => (
              <button
                key={e}
                onClick={() => { onSendReaction(e); setShowEmojiPicker(false); }}
                className="text-2xl hover:scale-125 transition-transform bg-gray-800 w-11 h-11 rounded-full flex items-center justify-center"
              >
                {e}
              </button>
            ))}
          </div>
        )}

        {/* Add people panel */}
        {showAddPeople && (
          <div className="mb-4 bg-gray-900 border border-gray-700 rounded-2xl p-4 animate-in fade-in slide-in-from-bottom-2">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm font-semibold text-white">Add to call</p>
              <button onClick={() => setShowAddPeople(false)} className="p-1 text-gray-500 hover:text-white">
                <X size={14} />
              </button>
            </div>
            <p className="text-xs text-gray-500 text-center py-4">
              Select a buddy from your list to add them to this call.
            </p>
          </div>
        )}

        {/* Main call controls */}
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

          {/* Record */}
          {isInCall && (
            <button
              onClick={onToggleRecording}
              className={`w-13 h-13 rounded-full flex items-center justify-center transition-all border-2 ${
                isRecording ? 'border-red-500 bg-red-500/20 text-red-500 shadow-[0_0_16px_rgba(239,68,68,0.4)] animate-pulse' : 'border-transparent bg-gray-800 text-white hover:bg-gray-700'
              }`}
              title={isRecording ? 'Stop Recording' : 'Start Recording'}
            >
              <div className={`rounded-full ${isRecording ? 'w-4 h-4 bg-red-500' : 'w-4 h-4 bg-white'}`} />
            </button>
          )}

          {/* Camera (video calls only) */}
          {callType === 'video' && (
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

          {/* End call (center, prominent) */}
          <button
            onClick={isInCall || isCalling ? onHangUp : isRinging && isCallee ? onDecline : onHangUp}
            className="w-16 h-16 rounded-full bg-red-500 hover:bg-red-600 flex items-center justify-center shadow-[0_0_24px_rgba(239,68,68,0.5)] transition-all hover:scale-105"
          >
            <PhoneOff size={24} className="text-white" />
          </button>

          {/* Screen share (video calls only) */}
          {callType === 'video' && isInCall && (
            <button
              onClick={onToggleScreenShare}
              className={`w-13 h-13 rounded-full flex items-center justify-center transition-all ${
                isSharingScreen ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'
              }`}
              title={isSharingScreen ? 'Stop sharing' : 'Share screen'}
            >
              {isSharingScreen ? <MonitorOff size={20} /> : <Monitor size={20} />}
            </button>
          )}

          {/* Emoji reactions */}
          {isInCall && (
            <button
              onClick={() => setShowEmojiPicker((v) => !v)}
              className={`w-13 h-13 rounded-full flex items-center justify-center transition-all ${
                showEmojiPicker ? 'bg-buddy-green text-black' : 'bg-gray-800 text-white hover:bg-gray-700'
              }`}
              title="React"
            >
              <Smile size={20} />
            </button>
          )}
        </div>

        {/* Accept / Decline for incoming call (isCallee ringing) */}
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

        {/* Add people & participants count (in call) */}
        {isInCall && (
          <div className="flex items-center justify-center gap-4 mt-3">
            <button
              onClick={() => setShowAddPeople((v) => !v)}
              className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-white transition-colors"
            >
              <UserPlus size={13} />
              Add people
            </button>
            {isGroupCall && groupParticipants && (
              <button className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-white transition-colors">
                <Users size={13} />
                {groupParticipants.length + 2} in call
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
