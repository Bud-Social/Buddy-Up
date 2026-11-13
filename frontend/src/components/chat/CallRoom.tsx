/**
 * CallRoom – full-screen audio/video call surface, shared by the Messages
 * screens. Voice calls show only the remote people (no self tile); video
 * calls put the remote person in focus with a small self overlay you tap to
 * swap. Screen share, screen record, screenshot, on-screen text and captions
 * live behind one overflow button so the control bar stays calm.
 */
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  Mic, MicOff, Video, VideoOff, PhoneOff, Users, X,
  Monitor, MonitorOff, UserPlus,
  MoreVertical, Circle, Camera, Type, Captions, Phone,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { profilesApi } from '@/api/profiles';
import { useAuthStore } from '@/store/authStore';
import { useToast } from '@/components/ui/Toast';
import { playRingback, playRingtone, playFaintChime } from '@/lib/ringtone';
import type { RemoteCallEvent } from '@/hooks/useLiveKitCall';

export type CallTile = {
  identity: string;
  name: string;
  avatarUrl: string;
  isLocal: boolean;
  /** Opaque LocalParticipant | RemoteParticipant – attach tracks in the UI. */
  participant: unknown;
  isAudioEnabled: boolean;
  isVideoEnabled: boolean;
  isScreenSharing: boolean;
};

type LkCallState = 'idle' | 'calling' | 'ringing' | 'in_call' | 'ended';

type Recordable = {
  mic: MediaStreamTrack | null;
  camera: MediaStreamTrack | null;
  screen: MediaStreamTrack | null;
  remoteTracks: MediaStreamTrack[];
};

export interface CallRoomProps {
  callState: LkCallState;
  callType: 'audio' | 'video';
  cameraError: string | null;
  tiles: CallTile[];
  myUserId: string;
  remoteCallEvent: RemoteCallEvent | null;
  publishCallEvent: (e: Omit<RemoteCallEvent, 'at'>) => boolean;
  mediaSnapshot: () => Recordable | null;
  identityName: string;
  identityAvatar: string;
  isCallee: boolean;
  switchRequestFrom: string | null;
  switchPending: boolean;
  onRequestVideoSwitch: () => void;
  onAcceptSwitch: () => void;
  onDeclineSwitch: () => void;
  onAccept: () => void;
  onDecline: () => void;
  onHangUp: () => void;
  onToggleMute: () => void;
  onToggleCamera: () => void;
  onToggleScreenShare: () => void;
  onAddBuddy: (buddyUserId: string) => void;
}

function activeVideoTrack(tile: CallTile): { track: MediaStreamTrack | null; kind: 'screen' | 'camera' } {
  const p = tile.participant as {
    getTrackPublication?: (src: string) => { track?: { mediaStreamTrack?: MediaStreamTrack } } | undefined;
  } | null;
  if (!p?.getTrackPublication) return { track: null, kind: 'camera' };
  const screen = p.getTrackPublication('screen_share')?.track?.mediaStreamTrack ?? null;
  if (screen && tile.isScreenSharing) return { track: screen, kind: 'screen' };
  const cam = p.getTrackPublication('camera')?.track?.mediaStreamTrack ?? null;
  return { track: cam, kind: 'camera' };
}

/** One participant tile. Voice = avatar card; video = live video + remote audio. */
function ParticipantTile({ tile, big }: { tile: CallTile; big?: boolean }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const audioRef = useRef<HTMLAudioElement>(null);
  const { track } = activeVideoTrack(tile);
  const showVideo = !!track && (tile.isVideoEnabled || tile.isScreenSharing);

  useEffect(() => {
    const el = videoRef.current;
    if (!el || !track) {
      if (el) el.srcObject = null;
      return;
    }
    try { el.srcObject = new MediaStream([track]); void el.play().catch(() => {}); } catch { /* noop */ }
  }, [track]);

  // Remote mic: attach to a real element in the DOM. Detached elements are
  // muted on most mobile browsers — this is why the far side seemed inactive.
  useEffect(() => {
    const el = audioRef.current;
    if (!el || tile.isLocal) return;
    const p = tile.participant as {
      getTrackPublication?: (src: string) => { track?: { mediaStreamTrack?: MediaStreamTrack } } | undefined;
    } | null;
    const mic = p?.getTrackPublication?.('microphone')?.track?.mediaStreamTrack ?? null;
    if (!mic) return;
    try { el.srcObject = new MediaStream([mic]); void el.play().catch(() => {}); } catch { /* noop */ }
    return () => { el.srcObject = null; };
  }, [tile.participant, tile.isLocal, tile.isAudioEnabled]);

  return (
    <div className="relative bg-gray-900 rounded-2xl overflow-hidden border border-gray-800 min-h-0 h-full w-full">
      {showVideo ? (
        <video ref={videoRef} autoPlay playsInline muted={tile.isLocal}
          className={`absolute inset-0 w-full h-full ${tile.isScreenSharing ? 'object-contain' : 'object-cover'}`} />
      ) : (
        <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 bg-gradient-to-b from-gray-800/50 to-gray-900">
          <Avatar src={tile.avatarUrl} alt={tile.name} size={big ? 'xl' : 'lg'} className="opacity-80" />
        </div>
      )}
      <div className="absolute bottom-2 left-2 right-2 flex items-center gap-1.5">
        <span className="text-[11px] font-semibold text-white bg-black/60 rounded-full px-2 py-0.5 truncate max-w-[70%]">
          {tile.isLocal ? 'You' : tile.name}
          {tile.isScreenSharing ? ' (screen)' : ''}
        </span>
        {!tile.isAudioEnabled && (
          <span className="bg-black/60 rounded-full p-1"><MicOff size={11} className="text-red-400" /></span>
        )}
      </div>
      <audio ref={audioRef} autoPlay playsInline className="hidden" />
    </div>
  );
}

const fmt = (secs: number) => `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, '0')}`;

export function CallRoom({
  callState, callType, cameraError, tiles, myUserId,
  remoteCallEvent, publishCallEvent, mediaSnapshot,
  identityName, identityAvatar, isCallee,
  switchRequestFrom, switchPending,
  onRequestVideoSwitch, onAcceptSwitch, onDeclineSwitch,
  onAccept, onDecline, onHangUp, onToggleMute, onToggleCamera, onToggleScreenShare,
  onAddBuddy,
}: CallRoomProps) {
  const { toast } = useToast();
  const username = useAuthStore((s) => s.profile?.username ?? '');

  const [showAddPeople, setShowAddPeople] = useState(false);
  const [buddies, setBuddies] = useState<Array<{ user_id: string; username: string; display_name: string; avatar_url: string }>>([]);
  const [buddiesLoading, setBuddiesLoading] = useState(false);
  const [showMore, setShowMore] = useState(false);
  const [durationSecs, setDurationSecs] = useState(0);
  const [textMode, setTextMode] = useState(false);
  const [textDraft, setTextDraft] = useState('');
  const [captionsOn, setCaptionsOn] = useState(false);
  const [recording, setRecording] = useState(false);
  const [liveText, setLiveText] = useState<RemoteCallEvent | null>(null);
  const [liveCaption, setLiveCaption] = useState<RemoteCallEvent | null>(null);
  const [selfFocused, setSelfFocused] = useState(false);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const recordChunks = useRef<Blob[]>([]);
  const recordAudioCtx = useRef<AudioContext | null>(null);
  const recognitionRef = useRef<{ stop: () => void } | null>(null);
  const ringStopRef = useRef<(() => void) | null>(null);
  const stageShotRef = useRef<HTMLVideoElement | null>(null);

  const isRinging = callState === 'ringing';
  const isCalling = callState === 'calling';
  const isInCall = callState === 'in_call';
  const localTile = useMemo(() => tiles.find((t) => t.isLocal), [tiles]);
  const localId = localTile?.identity ?? myUserId;
  const isMuted = localTile ? !localTile.isAudioEnabled : false;
  const isCameraOff = localTile ? !localTile.isVideoEnabled : true;
  const isSharingScreen = tiles.some((t) => t.isLocal && t.isScreenSharing);
  const others = useMemo(() => tiles.filter((t) => t.identity !== localId), [tiles, localId]);

  // Duration timer
  useEffect(() => {
    if (callState !== 'in_call') { setDurationSecs(0); return; }
    const t = setInterval(() => setDurationSecs((v) => v + 1), 1000);
    return () => clearInterval(t);
  }, [callState]);

  // Ring out / ring back.
  useEffect(() => {
    const active = isCalling || (isRinging && isCallee);
    if (!active) { ringStopRef.current?.(); ringStopRef.current = null; return; }
    try {
      ringStopRef.current = isRinging && isCallee ? playRingtone() : playRingback();
    } catch { /* audio blocked — stay visual */ }
    return () => { ringStopRef.current?.(); ringStopRef.current = null; };
  }, [isCalling, isRinging, isCallee]);

  // A faint chime when someone asks to switch to video.
  useEffect(() => {
    if (switchRequestFrom) playFaintChime();
  }, [switchRequestFrom]);

  // Route room data-channel events into the two overlays.
  useEffect(() => {
    if (!remoteCallEvent) return;
    if (remoteCallEvent.kind === 'text') setLiveText(remoteCallEvent);
    if (remoteCallEvent.kind === 'caption') setLiveCaption(remoteCallEvent);
  }, [remoteCallEvent]);

  // The on-screen text fades on its own.
  useEffect(() => {
    if (!liveText) return;
    const t = window.setTimeout(() => setLiveText(null), 7000);
    return () => window.clearTimeout(t);
  }, [liveText]);
  // Captions fade when the speaker pauses.
  useEffect(() => {
    if (!liveCaption) return;
    const t = window.setTimeout(() => setLiveCaption(null), 5000);
    return () => window.clearTimeout(t);
  }, [liveCaption]);

  // Captions via SpeechRecognition, published over the data channel.
  const toggleCaptions = useCallback(() => {
    if (captionsOn) {
      recognitionRef.current?.stop();
      recognitionRef.current = null;
      setCaptionsOn(false);
      return;
    }
    type Recognition = {
      lang: string; continuous: boolean; interimResults: boolean;
      onresult: (e: { results: ArrayLike<{ 0: { transcript: string }; isFinal: boolean }> }) => void;
      onend: () => void; start: () => void; stop: () => void;
    };
    const SR = (window as unknown as { SpeechRecognition?: new () => Recognition; webkitSpeechRecognition?: new () => Recognition })
      .SpeechRecognition ?? (window as unknown as { webkitSpeechRecognition?: new () => Recognition }).webkitSpeechRecognition;
    if (!SR) { toast('error', 'Captions need Chrome or Safari'); return; }
    const rec = new SR();
    rec.lang = 'en-US';
    rec.continuous = true;
    rec.interimResults = true;
    rec.onresult = (e) => {
      const latest = e.results[e.results.length - 1];
      const text = (latest[0]?.transcript ?? '').trim();
      if (!text) return;
      publishCallEvent({ kind: 'caption', text: text.slice(0, 200), from: 'You', final: latest.isFinal });
      setLiveCaption({ kind: 'caption', text, from: 'You', final: latest.isFinal, at: Date.now() });
    };
    rec.onend = () => setCaptionsOn(false);
    try { rec.start(); setCaptionsOn(true); } catch { toast('error', 'Could not start captions'); }
  }, [captionsOn, publishCallEvent, toast]);

  // Screen record (screen or camera + mixed mic audio), saved locally as WebM.
  const toggleRecording = useCallback(async () => {
    if (recording) {
      recorderRef.current?.stop();
      recorderRef.current = null;
      setRecording(false);
      return;
    }
    const snap = mediaSnapshot();
    const stream = new MediaStream();
    let videoTrack = snap?.screen ?? null;
    if (!videoTrack) {
      try {
        const display = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: true });
        videoTrack = display.getVideoTracks()[0] ?? null;
        display.getAudioTracks().forEach((t) => stream.addTrack(t));
      } catch {
        videoTrack = snap?.camera ?? null;
      }
    }
    if (videoTrack) stream.addTrack(videoTrack);
    const actx = new AudioContext();
    const dest = actx.createMediaStreamDestination();
    const addAudio = (t: MediaStreamTrack | null | undefined) => {
      if (!t) return;
      try { actx.createMediaStreamSource(new MediaStream([t])).connect(dest); } catch { /* skip */ }
    };
    addAudio(snap?.mic);
    snap?.remoteTracks.filter((t) => t.kind === 'audio').forEach(addAudio);
    if (dest.stream.getAudioTracks().length > 0) {
      dest.stream.getAudioTracks().forEach((t) => stream.addTrack(t));
    }
    recordAudioCtx.current = actx;
    const mime = ['video/webm;codecs=vp9,opus', 'video/webm', 'video/mp4']
      .find((m) => (typeof MediaRecorder !== 'undefined' && MediaRecorder.isTypeSupported(m)));
    try {
      const rec = new MediaRecorder(stream, mime ? { mimeType: mime } : undefined);
      recordChunks.current = [];
      rec.ondataavailable = (e) => { if (e.data.size > 0) recordChunks.current.push(e.data); };
      rec.onstop = () => {
        const blob = new Blob(recordChunks.current, { type: mime ?? 'video/webm' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `buddyup-call-${Date.now()}.webm`;
        a.click();
        URL.revokeObjectURL(url);
        stream.getTracks().forEach((t) => t.stop());
        recordAudioCtx.current?.close().catch(() => {});
        toast('success', 'Recording saved to this device');
      };
      rec.start(250);
      recorderRef.current = rec;
      setRecording(true);
    } catch {
      toast('error', 'Screen record is not available here');
      stream.getTracks().forEach((t) => t.stop());
      actx.close().catch(() => {});
    }
  }, [mediaSnapshot, recording, toast]);

  // Snapshot of the focused tile, downloaded as PNG.
  const takeScreenshot = useCallback(() => {
    const candidate = stageShotRef.current;
    if (!candidate || !candidate.videoWidth) { toast('info', 'Nothing to capture yet'); return; }
    const canvas = document.createElement('canvas');
    canvas.width = candidate.videoWidth;
    canvas.height = candidate.videoHeight;
    canvas.getContext('2d')?.drawImage(candidate, 0, 0);
    canvas.toBlob((blob) => {
      if (!blob) return;
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `buddyup-call-${Date.now()}.png`;
      a.click();
      URL.revokeObjectURL(url);
    }, 'image/png');
  }, [toast]);

  const sendTextOnScreen = useCallback(() => {
    const text = textDraft.trim().slice(0, 140);
    if (!text) return;
    publishCallEvent({ kind: 'text', text, from: 'You' });
    setLiveText({ kind: 'text', text, from: 'You', at: Date.now() });
    setTextDraft('');
    setTextMode(false);
  }, [publishCallEvent, textDraft]);

  // Buddies for the add-people panel.
  useEffect(() => {
    if (!showAddPeople || !username) return;
    setBuddiesLoading(true);
    profilesApi.getBuddies(username)
      .then((resp) => {
        // /profiles/<username>/buddies/ returns a bare paginated envelope.
        const rows = (resp as unknown as { results?: typeof buddies })?.results
          ?? (resp as unknown as { data?: typeof buddies })?.data
          ?? [];
        setBuddies(Array.isArray(rows) ? rows : []);
      })
      .catch(() => setBuddies([]))
      .finally(() => setBuddiesLoading(false));
  }, [showAddPeople, username]); // eslint-disable-line react-hooks/exhaustive-deps

  if (callState === 'idle') return null;

  const statusLabel = isCalling ? 'Calling…'
    : isRinging && isCallee ? 'Incoming call'
    : isRinging ? 'Ringing…'
    : isInCall ? `${tiles.length} in call`
    : 'Call ended';

  const remoteTiles = others;
  const focusTile = selfFocused ? localTile : remoteTiles[0];
  const overlayTile = selfFocused ? remoteTiles[0] : localTile;
  const voiceFullScreen = callType === 'audio';

  return (
    <div className="fixed inset-0 z-[100] bg-gradient-to-b from-gray-950 via-gray-900 to-black flex flex-col overflow-hidden"
      style={{ paddingLeft: 'env(safe-area-inset-left)', paddingRight: 'env(safe-area-inset-right)' }}>
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-buddy-green to-transparent" />

      {/* ── PRE-CALL ── */}
      {(isCalling || isRinging || callState === 'ended') && (
        <div className="flex-1 flex flex-col items-center justify-center gap-6 p-8 pt-[calc(2rem+env(safe-area-inset-top))]">
          {isRinging && <div className="absolute w-64 h-64 rounded-full border-2 border-buddy-green/20 animate-ping" />}
          <div className="relative">
            <Avatar src={identityAvatar} alt={identityName} size="xl"
              className="w-32 h-32 ring-4 ring-buddy-green/30 shadow-[0_0_60px_rgba(0,255,157,0.15)]" />
            {isRinging && (
              <div className="absolute -bottom-1 -right-1 w-8 h-8 bg-buddy-green rounded-full flex items-center justify-center shadow-lg">
                {callType === 'video' ? <Video size={14} className="text-black" /> : <Phone size={14} className="text-black" />}
              </div>
            )}
          </div>
          <div className="text-center">
            <h2 className="text-2xl font-bold font-display text-white mb-1">{identityName}</h2>
            <p className={`text-sm font-medium ${isRinging ? 'text-buddy-green animate-pulse' : 'text-gray-400'}`}>{statusLabel}</p>
            {tiles.length >= 3 && <p className="text-xs text-buddy-green/80 mt-1">Buddies call</p>}
          </div>
          {callState === 'ended' && <p className="text-gray-500 text-sm">Call ended</p>}
        </div>
      )}

      {/* ── IN-CALL ── */}
      {isInCall && (
        <div className="flex-1 relative overflow-hidden flex flex-col pt-[calc(1rem+env(safe-area-inset-top))] px-3 pb-2">
          {/* Status bar */}
          <div className="flex items-center gap-2 mb-2 shrink-0">
            <div className="bg-black/50 text-white text-xs font-mono px-3 py-1.5 rounded-lg backdrop-blur-sm flex items-center gap-2">
              {isSharingScreen && <Monitor size={12} className="text-buddy-green" />}
              {fmt(durationSecs)}
            </div>
            <div className="bg-black/50 text-white/80 text-xs px-3 py-1.5 rounded-lg backdrop-blur-sm flex items-center gap-1.5">
              <Users size={12} />{tiles.length}
            </div>
            {cameraError && (
              <div className="bg-yellow-900/80 border border-yellow-600/50 rounded-xl px-3 py-1.5 text-xs text-yellow-300 truncate">{cameraError} — audio only</div>
            )}
            {recording && (
              <div className="bg-red-900/80 border border-red-600/50 rounded-xl px-3 py-1.5 text-xs text-red-200 flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-red-400 animate-pulse" /> REC
              </div>
            )}
          </div>

          {/* On-screen text (remote or local) */}
          {liveText && (
            <div className="absolute top-16 left-1/2 -translate-x-1/2 z-20 max-w-[80%] text-center">
              <span className="inline-block bg-black/80 backdrop-blur px-4 py-2 rounded-2xl text-white text-sm font-medium border border-white/10">{liveText.text}</span>
            </div>
          )}
          {/* Captions */}
          {liveCaption && (
            <div className="absolute bottom-40 left-1/2 -translate-x-1/2 z-20 max-w-[85%]">
              <span className="inline-block bg-black/80 backdrop-blur px-3 py-1.5 rounded-lg text-white text-xs border border-white/10"><span className="text-white/50 mr-1.5">{liveCaption.from}:</span>{liveCaption.text}</span>
            </div>
          )}

          {voiceFullScreen ? (
            /* ── Voice: the remote person (or people) fills the screen; no self tile ── */
            <div className={`flex-1 min-h-0 grid gap-2 ${remoteTiles.length <= 1 ? 'grid-cols-1' : remoteTiles.length === 2 ? 'grid-cols-2' : 'grid-cols-2 md:grid-cols-3'}`}>
              {remoteTiles.length === 0 && (
                <div className="col-span-full flex flex-col items-center justify-center gap-3 text-gray-500">
                  <Users size={36} className="opacity-40" />
                  <p className="text-sm">Waiting for others to join…</p>
                </div>
              )}
              {remoteTiles.map((t) => <ParticipantTile key={t.identity} tile={t} big />)}
            </div>
          ) : (
            /* ── Video: remote in focus, self as a tappable overlay ── */
            <div className="flex-1 relative min-h-0 rounded-2xl overflow-hidden border border-gray-800 bg-gray-900">
              {focusTile ? (
                <div className="absolute inset-0">
                  {activeVideoTrack(focusTile).track ? (
                    <video autoPlay playsInline muted={focusTile.isLocal}
                      className={`absolute inset-0 w-full h-full ${focusTile.isScreenSharing ? 'object-contain' : 'object-cover'}`}
                      ref={(el) => {
                        stageShotRef.current = el;
                        const t = activeVideoTrack(focusTile).track;
                        if (el && t) { try { el.srcObject = new MediaStream([t]); void el.play().catch(() => {}); } catch { /* noop */ } }
                      }} />
                  ) : (
                    <div className="absolute inset-0 flex flex-col items-center justify-center gap-3">
                      <Avatar src={focusTile.avatarUrl} alt={focusTile.name} size="xl" className="opacity-80" />
                    </div>
                  )}
                  <div className="absolute bottom-3 left-3 flex items-center gap-1.5">
                    <span className="text-xs font-semibold text-white bg-black/60 rounded-full px-2.5 py-1">{focusTile.isLocal ? 'You' : focusTile.name}</span>
                    {!focusTile.isAudioEnabled && <span className="bg-black/60 rounded-full p-1"><MicOff size={12} className="text-red-400" /></span>}
                  </div>
                </div>
              ) : (
                <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 text-gray-500">
                  <Users size={36} className="opacity-40" /><p className="text-sm">Waiting for others…</p>
                </div>
              )}

              {/* Self / counterpart overlay tile */}
              {overlayTile && (
                <button onClick={() => setSelfFocused((v) => !v)}
                  className="absolute bottom-3 right-3 w-24 h-32 sm:w-28 sm:h-36 rounded-xl overflow-hidden border-2 border-buddy-green/40 shadow-2xl z-10 bg-gray-800"
                  title={selfFocused ? 'Back to them' : 'Show me'}>
                  {activeVideoTrack(overlayTile).track ? (
                    <video autoPlay playsInline muted={overlayTile.isLocal}
                      className="absolute inset-0 w-full h-full object-cover"
                      ref={(el) => {
                        const t = activeVideoTrack(overlayTile).track;
                        if (el && t) { try { el.srcObject = new MediaStream([t]); void el.play().catch(() => {}); } catch { /* noop */ } }
                      }} />
                  ) : (
                    <div className="absolute inset-0 flex items-center justify-center"><Avatar src={overlayTile.avatarUrl} alt="" size="md" /></div>
                  )}
                  <span className="absolute bottom-1 left-1 right-1 text-[9px] font-semibold text-white bg-black/60 rounded px-1 truncate">{overlayTile.isLocal ? 'You' : overlayTile.name}</span>
                </button>
              )}
            </div>
          )}
        </div>
      )}

      {/* ── CONTROLS ── */}
      <div className="shrink-0 px-4 pb-[calc(1.25rem+env(safe-area-inset-bottom))] pt-3 relative">
        {switchPending && (
          <div className="absolute -top-10 left-1/2 -translate-x-1/2 z-20 text-[11px] text-buddy-green bg-black/80 rounded-full px-3 py-1 border border-buddy-green/30 animate-pulse">Waiting for them to switch to video…</div>
        )}

        {/* On-screen text composer */}
        {textMode && (
          <div className="mb-3 flex items-center gap-2 bg-gray-900 border border-gray-800 rounded-2xl p-2">
            <Type size={16} className="text-buddy-green shrink-0 ml-1" />
            <input autoFocus value={textDraft} onChange={(e) => setTextDraft(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') sendTextOnScreen(); }}
              placeholder="Text on screen…" maxLength={140}
              className="flex-1 bg-transparent outline-none text-sm text-white placeholder:text-gray-600" />
            <button onClick={sendTextOnScreen} className="text-xs font-semibold text-black bg-buddy-green rounded-lg px-3 py-1.5">Send</button>
            <button onClick={() => setTextMode(false)} className="text-gray-500 p-1"><X size={14} /></button>
          </div>
        )}

        {/* More actions sheet (video calls) */}
        {showMore && (
          <div className="mb-3 grid grid-cols-4 gap-2 bg-gray-900 border border-gray-800 rounded-2xl p-3 animate-in fade-in">
            {([
              { icon: recording ? Circle : Circle, label: recording ? 'Stop REC' : 'Record', active: recording, onClick: () => { void toggleRecording(); setShowMore(false); } },
              { icon: Camera, label: 'Snapshot', active: false, onClick: () => { takeScreenshot(); setShowMore(false); } },
              { icon: Type, label: 'Text', active: textMode, onClick: () => { setTextMode((v) => !v); setShowMore(false); } },
              { icon: Captions, label: 'Captions', active: captionsOn, onClick: () => { toggleCaptions(); setShowMore(false); } },
            ]).map(({ icon: Icon, label, active, onClick }) => (
              <button key={label} onClick={onClick}
                className={`flex flex-col items-center gap-1.5 rounded-xl py-2.5 transition-colors ${active ? 'bg-buddy-green/15 text-buddy-green' : 'text-gray-300 hover:bg-gray-800'}`}>
                <Icon size={18} className={label === 'Stop REC' ? 'text-red-400' : ''} />
                <span className="text-[10px]">{label}</span>
              </button>
            ))}
          </div>
        )}

        {/* Add people panel */}
        {showAddPeople && (
          <div className="mb-3 bg-gray-900/95 border border-gray-800 rounded-2xl p-4 w-full max-w-md mx-auto">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm font-semibold text-white flex items-center gap-1.5"><UserPlus size={14} /> Add a buddy</p>
              <button onClick={() => setShowAddPeople(false)} className="text-gray-500 p-1"><X size={14} /></button>
            </div>
            <p className="text-[11px] text-gray-500 mb-3">They get a ring with both of your profiles — it shows as a buddies call.</p>
            {buddiesLoading ? (
              <p className="text-xs text-gray-500 py-3 text-center">Loading buddies…</p>
            ) : buddies.length === 0 ? (
              <p className="text-xs text-gray-500 py-3 text-center">No buddies yet — match some in Find a Buddy.</p>
            ) : (
              <div className="max-h-48 overflow-y-auto space-y-1.5">
                {buddies.filter((b) => !tiles.some((t) => t.identity === b.user_id)).map((b) => (
                  <button key={b.user_id}
                    onClick={() => { onAddBuddy(b.user_id); setShowAddPeople(false); }}
                    className="w-full flex items-center gap-2.5 rounded-xl px-2.5 py-2 hover:bg-gray-800 transition-colors text-left">
                    <Avatar src={b.avatar_url} alt={b.display_name} size="sm" />
                    <span className="flex-1 min-w-0">
                      <span className="block text-xs font-semibold text-white truncate">{b.display_name}</span>
                      <span className="block text-[10px] text-gray-500">@{b.username}</span>
                    </span>
                    <span className="text-[10px] font-semibold text-buddy-green bg-buddy-green/10 rounded-full px-2 py-1">Add</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        )}

        <div className="flex flex-wrap items-center justify-center gap-3">
          {/* Mute */}
          <button onClick={onToggleMute}
            className={`w-14 h-14 rounded-full flex items-center justify-center transition-all ${isMuted ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'}`}
            title={isMuted ? 'Unmute' : 'Mute'}>
            {isMuted ? <MicOff size={20} /> : <Mic size={20} />}
          </button>

          {/* End */}
          <button onClick={isRinging && isCallee ? onDecline : onHangUp}
            title="End call"
            aria-label="End call"
            className="w-16 h-16 rounded-full bg-red-500 hover:bg-red-600 flex items-center justify-center shadow-[0_0_24px_rgba(239,68,68,0.5)] transition-all hover:scale-105">
            <PhoneOff size={24} className="text-white" />
          </button>

          {/* Video-only: camera / screen share / more */}
          {callType === 'video' && isInCall && (
            <button onClick={onToggleCamera}
              className={`w-14 h-14 rounded-full flex items-center justify-center transition-all ${isCameraOff ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'}`}
              title={isCameraOff ? 'Enable camera' : 'Disable camera'}>
              {isCameraOff ? <VideoOff size={20} /> : <Video size={20} />}
            </button>
          )}
          {callType === 'video' && isInCall && (
            <button onClick={() => void onToggleScreenShare()}
              className={`w-14 h-14 rounded-full flex items-center justify-center transition-all ${isSharingScreen ? 'bg-buddy-green text-black shadow-[0_0_16px_rgba(0,255,157,0.4)]' : 'bg-gray-800 text-white hover:bg-gray-700'}`}
              title={isSharingScreen ? 'Stop sharing' : 'Share screen'}>
              {isSharingScreen ? <MonitorOff size={20} /> : <Monitor size={20} />}
            </button>
          )}
          {isInCall && (
            <button onClick={() => setShowAddPeople((v) => !v)}
              className="w-14 h-14 rounded-full flex items-center justify-center bg-gray-800 text-white hover:bg-gray-700 transition-all"
              title="Add a buddy to the call">
              <UserPlus size={18} />
            </button>
          )}
          {/* Voice-only: switch to video */}
          {callType === 'audio' && isInCall && (
            <button onClick={onRequestVideoSwitch}
              className="w-14 h-14 rounded-full flex items-center justify-center bg-gray-800 text-white hover:bg-gray-700 transition-all"
              title="Ask to switch to video">
              <Video size={20} />
            </button>
          )}
          {callType === 'video' && isInCall && (
            <button onClick={() => setShowMore((v) => !v)}
              className={`w-14 h-14 rounded-full flex items-center justify-center transition-all ${showMore ? 'bg-buddy-green text-black' : 'bg-gray-800 text-white hover:bg-gray-700'}`}
              title="More actions">
              <MoreVertical size={20} />
            </button>
          )}
        </div>

        {/* Accept / decline incoming */}
        {isRinging && isCallee && (
          <div className="flex items-center justify-center gap-8 mt-5">
            <div className="flex flex-col items-center gap-1.5">
              <button onClick={onDecline}
                className="w-16 h-16 rounded-full bg-red-500/20 border border-red-500/40 text-red-400 hover:bg-red-500/30 flex items-center justify-center">
                <PhoneOff size={22} />
              </button>
              <span className="text-xs text-gray-500">Decline</span>
            </div>
            <div className="flex flex-col items-center gap-1.5">
              <button onClick={onAccept}
                className="w-16 h-16 rounded-full bg-buddy-green text-black flex items-center justify-center shadow-[0_0_24px_rgba(0,255,157,0.4)] hover:bg-buddy-green-deep transition-all hover:scale-105">
                {callType === 'video' ? <Video size={22} /> : <Phone size={22} />}
              </button>
              <span className="text-xs text-gray-400">Accept</span>
            </div>
          </div>
        )}
      </div>

      {/* ── Switch-to-video request dialog ── */}
      {switchRequestFrom && (
        <div className="absolute inset-0 z-30 flex items-center justify-center bg-black/60 backdrop-blur-sm px-6">
          <div className="bg-gray-900 border border-gray-800 rounded-2xl p-5 max-w-xs w-full text-center space-y-3 shadow-2xl">
            <Video size={22} className="mx-auto text-buddy-green" />
            <p className="text-sm font-semibold text-white">{switchRequestFrom} wants to switch to video</p>
            <p className="text-xs text-gray-500">Accepting turns the call into a video call for both of you.</p>
            <div className="flex gap-2">
              <Button variant="outline" className="flex-1" onClick={onDeclineSwitch}>Stay voice</Button>
              <Button className="flex-1" onClick={onAcceptSwitch}>Switch</Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
