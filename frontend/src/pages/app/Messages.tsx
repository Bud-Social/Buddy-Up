/**
 * Messages.tsx – Full-featured messaging UI with:
 * - URL-based conversation routing (/messages/:conversationId)
 * - Real-time WebSocket messaging (text, media, voice, polls, location)
 * - File upload with progress
 * - Typing indicators + read receipts
 * - Advanced WebRTC audio/video calls via CallRoom component
 * - Emoji reactions, message reply / delete
 * - Online presence + last seen
 */
import {
  useState, useEffect, useRef, useCallback, useMemo,
} from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Send, Phone, Video, MoreVertical, Check, CheckCheck,
  X, FileText, Plus, MapPin, BarChart2, Smile, Mic, Search, Calendar, Clock, Download, Forward,
  ChevronLeft, ChevronRight,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { messagingApi } from '@/api/messaging';
import type { Conversation, Message as MsgType, LinkPreviewData } from '@/api/messaging';
import { useAuthStore } from '@/store/authStore';
import { useChatSocket } from '@/hooks/useChatSocket';
import type { ChatEvent } from '@/hooks/useChatSocket';
import { useWebRTC } from '@/hooks/useWebRTC';
import { usePresence, formatLastSeen } from '@/hooks/usePresence';
import { AttachmentMenu } from '@/components/chat/AttachmentMenu';
import { VoiceNoteRecorder } from '@/components/chat/VoiceNoteRecorder';
import { CallRoom } from '@/components/chat/CallRoom';
import { CustomAudioPlayer } from '@/components/chat/CustomAudioPlayer';

// Quick emoji picker options
const QUICK_EMOJIS = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥', '💪'];

const GOOGLE_MAPS_KEY = import.meta.env.VITE_GOOGLE_MAPS_KEY as string | undefined;

function LocationCard({ lat, lng, label, isMine }: { lat: number; lng: number; label: string; isMine: boolean }) {
  const [showPopup, setShowPopup] = useState(false);
  const staticUrl = GOOGLE_MAPS_KEY 
    ? `https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=15&size=400x200&maptype=roadmap&markers=color:red%7C${lat},${lng}&key=${GOOGLE_MAPS_KEY}`
    : `https://www.mapquestapi.com/staticmap/v5/map?center=${lat},${lng}&zoom=15&size=400,200&type=map&locations=${lat},${lng}|marker-red`;
  
  const googleMapsUrl = `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`;
  const appleMapsUrl = `http://maps.apple.com/?q=${lat},${lng}`;

  return (
    <div className="relative inline-block w-56">
      <button 
        onClick={(e) => { e.stopPropagation(); setShowPopup(!showPopup); }} 
        className="block w-full group/loc text-left"
      >
        <div className="h-28 bg-gradient-to-br from-gray-700 to-gray-800 relative overflow-hidden rounded-t-lg">
          <div className="absolute inset-0 bg-cover bg-center" style={{ backgroundImage: `url(${staticUrl})` }} />
          <div className="absolute inset-x-0 bottom-0 h-8 bg-gradient-to-t from-black/60 to-transparent" />
          <div className="absolute bottom-1.5 right-2 text-[9px] text-white/90 font-medium">Tap to open map</div>
        </div>
        <div className={`flex items-center gap-2 px-3 py-2 ${isMine ? 'bg-buddy-black/5 text-buddy-black' : 'bg-buddy-surface-raised text-buddy-text-primary'}`}>
          <MapPin size={14} className={isMine ? 'text-buddy-black/70' : 'text-buddy-green'} />
          <span className="text-xs truncate">{label}</span>
        </div>
      </button>

      {showPopup && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={(e) => { e.stopPropagation(); setShowPopup(false); }}>
          <div className="bg-white dark:bg-buddy-surface shadow-2xl rounded-2xl overflow-hidden z-[110] border border-black/10 dark:border-white/10 text-sm w-64 flex flex-col animate-in fade-in zoom-in-95" onClick={e => e.stopPropagation()}>
            <div className="px-4 py-3 border-b border-black/5 dark:border-white/5 font-semibold text-center text-buddy-text-primary">
              Open Map
            </div>
            <a 
              href={googleMapsUrl} target="_blank" rel="noreferrer" 
              className="block w-full px-4 py-3 hover:bg-black/5 dark:hover:bg-white/5 text-center text-buddy-black dark:text-white"
              onClick={() => setShowPopup(false)}
            >
              Google Maps
            </a>
            <a 
              href={appleMapsUrl} target="_blank" rel="noreferrer" 
              className="block w-full px-4 py-3 hover:bg-black/5 dark:hover:bg-white/5 border-t border-black/5 dark:border-white/5 text-center text-buddy-black dark:text-white"
              onClick={() => setShowPopup(false)}
            >
              Apple Maps
            </a>
            <button 
              className="w-full px-4 py-3 hover:bg-black/5 dark:hover:bg-white/5 border-t border-black/5 dark:border-white/5 text-center text-buddy-text-secondary font-medium"
              onClick={(e) => { e.stopPropagation(); setShowPopup(false); }}
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function PollCard({ msg, isMine }: { msg: MsgType; isMine: boolean }) {
  const [localVote, setLocalVote] = useState<number | null>(null);
  const pollData = msg.metadata?.poll as { question: string; options: { text: string; votes: number }[] };
  if (!pollData) return null;

  const opts = pollData.options ?? [];
  const totalVotes = opts.reduce((s, o, i) => s + o.votes + (localVote === i ? 1 : 0), 0);

  return (
    <div className="p-3 w-64">
      <div className="flex items-center gap-1.5 mb-2">
        <BarChart2 size={13} className={isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'} />
        <span className={`text-[10px] font-bold tracking-wider ${isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'}`}>POLL</span>
      </div>
      <p className="font-semibold text-sm mb-3 leading-snug">{pollData.question}</p>
      
      {opts.map((opt, oi) => {
        const votesForOption = opt.votes + (localVote === oi ? 1 : 0);
        const pct = totalVotes > 0 ? Math.round((votesForOption / totalVotes) * 100) : 0;
        const hasVotedThis = localVote === oi;
        
        return (
          <button 
            key={oi}
            onClick={async (e) => {
              e.stopPropagation();
              if (localVote !== null) return; // Prevent double voting locally
              setLocalVote(oi);
              try {
                await messagingApi.reactToMessage(msg.id, `poll:${oi}`);
              } catch {
                setLocalVote(null); // Revert on failure
              }
            }}
            className={`w-full text-left px-4 py-2.5 rounded-xl text-sm font-semibold border-2 transition-all mb-2 relative overflow-hidden flex justify-between items-center ${
              hasVotedThis 
                ? isMine ? 'bg-buddy-black text-white border-buddy-black' : 'bg-buddy-green text-buddy-black border-buddy-green shadow-sm'
                : isMine 
                  ? 'bg-buddy-black/5 border-buddy-black/10 hover:border-buddy-black/20 text-buddy-black' 
                  : 'bg-buddy-surface border-buddy-surface-raised hover:border-buddy-text-secondary/20 text-buddy-text-primary'
            }`}
          >
            {/* Progress Bar Background */}
            {totalVotes > 0 && (
              <div
                className={`absolute inset-y-0 left-0 transition-all duration-700 ease-out ${
                  hasVotedThis ? (isMine ? 'bg-white/20' : 'bg-black/10') : isMine ? 'bg-buddy-black/10' : 'bg-buddy-green/20'
                }`}
                style={{ width: `${pct}%` }}
              />
            )}
            <span className="relative z-10">{opt.text}</span>
            {totalVotes > 0 && (
              <span className={`relative z-10 text-xs ${hasVotedThis ? 'opacity-100' : 'opacity-70'}`}>
                {pct}%
              </span>
            )}
          </button>
        );
      })}
      
      {totalVotes > 0 && (
        <p className="text-[10px] opacity-60 mt-2 text-right font-medium">{totalVotes} vote{totalVotes !== 1 ? 's' : ''}</p>
      )}
    </div>
  );
}

export default function Messages() {
  const { conversationId: routeConvoId } = useParams<{ conversationId: string }>();
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);

  // ── State ──────────────────────────────────────────────────────────────────
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeConvo, setActiveConvo] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<MsgType[]>([]);
  const [previewFileUrl, setPreviewFileUrl] = useState<{url: string, name: string} | null>(null);
  const [conversationListCollapsed, setConversationListCollapsed] = useState(false);
  const [attachmentFilter, setAttachmentFilter] = useState('');
  const [forwardModalConvId, setForwardModalConvId] = useState<string | null>(null);
  const [showForwardModal, setShowForwardModal] = useState(false);
  const [linkPreviews, setLinkPreviews] = useState<Record<string, LinkPreviewData>>({});
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [typingUsers, setTypingUsers] = useState<Record<string, string>>({});
  const [isTyping, setIsTyping] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const [mediaFile, setMediaFile] = useState<File | null>(null);
  const [mediaPreviewUrl, setMediaPreviewUrl] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [replyTo, setReplyTo] = useState<MsgType | null>(null);
  const [showOptionsId, setShowOptionsId] = useState<string | null>(null);
  const [showEmojiPickerId, setShowEmojiPickerId] = useState<string | null>(null);
  const [showAttachMenu, setShowAttachMenu] = useState(false);
  const [showVoiceRecorder, setShowVoiceRecorder] = useState(false);
  const [showNewGroupModal, setShowNewGroupModal] = useState(false);
  const [newGroupName, setNewGroupName] = useState('');
  const [newGroupUsers, setNewGroupUsers] = useState<string>('');

  const linkPreviewsRef = useRef(linkPreviews);
  linkPreviewsRef.current = linkPreviews;

  useEffect(() => {
    const urlRegex = /https?:\/\/[^\s]+/g;
    messages.forEach((msg) => {
      if (msg.message_type === 'text' && msg.body) {
        const matches = msg.body.match(urlRegex);
        if (matches) {
          matches.forEach(async (url) => {
            if (linkPreviewsRef.current[url]) return;
            try {
              const data = await messagingApi.linkPreview(url);
              setLinkPreviews((prev) => ({ ...prev, [url]: data }));
            } catch {}
          });
        }
      }
    });
  }, [messages]);

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const typingTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const activeConvoRef = useRef<Conversation | null>(null);
  activeConvoRef.current = activeConvo;

  // ── Derived: "other" participant (1-on-1 chats) ────────────────────────────
  const other = useMemo(() => {
    if (!activeConvo || activeConvo.is_group) return null;
    return activeConvo.participants_data.find((p) => p.user_id !== profile?.user_id) ?? activeConvo.participants_data[0] ?? null;
  }, [activeConvo, profile?.user_id]);

  // ── Presence ───────────────────────────────────────────────────────────────
  const partnerIds = useMemo(() => (other?.user_id ? [other.user_id] : []), [other?.user_id]);
  const presence = usePresence(partnerIds);
  const presenceInfo = useMemo(() => (other?.user_id ? presence[other.user_id] ?? null : null), [other?.user_id, presence]);

  const typingNames = Object.values(typingUsers);

  // ── WS Event handler ───────────────────────────────────────────────────────
  const sendReadRef = useRef<(id?: string) => void>(() => {});
  const handleWebRTCSignalRef = useRef<(type: string, data: Record<string, unknown>) => void>(() => {});

  const handleChatEvent = useCallback((event: ChatEvent) => {
    if (event.type === 'message') {
      const msg = event as unknown as MsgType & { type: string };
      setMessages((prev) => {
        // Already have this exact message (by real ID) — skip
        if (prev.find((m) => m.id === msg.id)) return prev;

        // If it's our own message echoed back, replace the matching optimistic temp entry
        if (msg.sender_id === profile?.user_id) {
          const tempIdx = prev.findIndex(
            (m) =>
              m.id.startsWith('temp_') &&
              m.sender_id === msg.sender_id &&
              m.message_type === msg.message_type &&
              m.body === msg.body,
          );
          if (tempIdx !== -1) {
            const next = [...prev];
            next[tempIdx] = msg;
            return next;
          }
        }

        return [...prev, msg];
      });
      if (
        activeConvoRef.current &&
        msg.conversation_id === activeConvoRef.current.id &&
        msg.sender_id !== profile?.user_id
      ) {
        sendReadRef.current(msg.id);
      }
      return;
    }
    if (event.type === 'typing_start' && event.user_id !== profile?.user_id) {
      setTypingUsers((prev) => ({ ...prev, [event.user_id]: event.display_name }));
      return;
    }
    if (event.type === 'typing_stop') {
      setTypingUsers((prev) => {
        const n = { ...prev };
        delete n[event.user_id];
        return n;
      });
      return;
    }
    if (event.type === 'read' && event.reader_id !== profile?.user_id) {
      setMessages((prev) =>
        prev.map((m) => (m.sender_id === profile?.user_id ? { ...m, is_read: true } : m)),
      );
      return;
    }
    if (event.type === 'react') {
      setMessages((prev) =>
        prev.map((m) => (m.id === event.message_id ? { ...m, reactions: event.reactions } : m)),
      );
      return;
    }
    if (['call_offer', 'call_answer', 'call_ice', 'call_end', 'call_decline', 'call_ringing'].includes(event.type)) {
      const data = (event as { data?: Record<string, unknown> }).data ?? {};
      handleWebRTCSignalRef.current(event.type, data);
    }
  }, [profile?.user_id]);

  const { sendMessage, sendTypingStart, sendTypingStop, sendRead, sendReact, sendCallSignal } = useChatSocket({
    conversationId: activeConvo?.id ?? null,
    onEvent: handleChatEvent,
  });

  useEffect(() => { sendReadRef.current = sendRead; }, [sendRead]);

  // ── WebRTC ─────────────────────────────────────────────────────────────────
  const onSignal = useCallback(
    (type: string, data: object, callType: 'audio' | 'video') =>
      sendCallSignal(type as 'call_offer', data, callType),
    [sendCallSignal],
  );

  const {
    callState, callType, localStream, remoteStream,
    isMuted, isRemoteMuted, isCameraOff, isSharingScreen, isRecording, cameraError, floatingReactions,
    startCall, acceptIncomingCall, declineCall, hangUp,
    toggleMute, toggleCamera, toggleScreenShare, toggleRecording, sendReaction, handleSignal: handleWebRTCSignal,
  } = useWebRTC({ onSignal });

  useEffect(() => {
    handleWebRTCSignalRef.current = (type: string, data: Record<string, unknown>) => {
      handleWebRTCSignal(type, data);
    };
  }, [handleWebRTCSignal]);

  // ── Fetch conversations ────────────────────────────────────────────────────
  const fetchConversations = useCallback(async () => {
    try {
      const res = await messagingApi.getConversations();
      setConversations(res.data ?? []);
    } catch { /* silent */ }
    finally { setIsLoading(false); }
  }, []);

  useEffect(() => {
    fetchConversations();
    const interval = setInterval(() => { if (!activeConvoRef.current) fetchConversations(); }, 15000);
    return () => clearInterval(interval);
  }, [fetchConversations]);

  const openConversation = useCallback(async (convo: Conversation, pushUrl = true) => {
    setActiveConvo(convo);
    setMessages([]);
    setTypingUsers({});
    setReplyTo(null);
    setMediaFile(null);
    setMediaPreviewUrl(null);
    if (pushUrl) navigate(`/messages/${convo.id}`, { replace: false });
    try {
      const res = await messagingApi.getMessages(convo.id);
      setMessages(res.data ?? []);
      messagingApi.markRead(convo.id).catch(() => {});
    } catch { /* silent */ }
  }, [navigate]);

  const closeConversation = useCallback(() => {
    setActiveConvo(null);
    navigate('/messages', { replace: false });
  }, [navigate]);

  // Auto-open from URL param (:conversationId)
  useEffect(() => {
    if (!conversations.length || !routeConvoId) return;
    if (activeConvo?.id === routeConvoId) return;
    const found = conversations.find((c) => c.id === routeConvoId);
    if (found) openConversation(found, false);
  }, [conversations, routeConvoId, activeConvo?.id, openConversation]);

  // Scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, typingUsers]);

  // ── Input / typing ─────────────────────────────────────────────────────────
  const handleInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    setBody(e.target.value);
    if (!isTyping) { setIsTyping(true); sendTypingStart(); }
    if (typingTimerRef.current) clearTimeout(typingTimerRef.current);
    typingTimerRef.current = setTimeout(() => { setIsTyping(false); sendTypingStop(); }, 2500);
  };

  // ── File staging ───────────────────────────────────────────────────────────
  const stageFile = useCallback((file: File) => {
    setMediaFile(file);
    if (file.type.startsWith('image/') || file.type.startsWith('video/')) {
      setMediaPreviewUrl(URL.createObjectURL(file));
    } else {
      setMediaPreviewUrl(null);
    }
    setShowAttachMenu(false);
  }, []);

  const clearMediaFile = useCallback(() => {
    if (mediaPreviewUrl) URL.revokeObjectURL(mediaPreviewUrl);
    setMediaFile(null);
    setMediaPreviewUrl(null);
  }, [mediaPreviewUrl]);

  // ── Send ───────────────────────────────────────────────────────────────────
  const sendTextOrMedia = useCallback(async (opts?: {
    body?: string;
    message_type?: string;
    media_url?: string;
    media_mime?: string;
    file_name?: string;
    metadata?: Record<string, unknown>;
  }) => {
    if (!activeConvoRef.current) return;

    const text = opts?.body ?? body.trim();
    const msgType = opts?.message_type ?? 'text';
    let mediaUrl = opts?.media_url ?? '';
    let mediaMime = opts?.media_mime ?? '';
    let fileName = opts?.file_name ?? '';

    const currentFile = mediaFile;
    if (currentFile && !mediaUrl) {
      setIsUploading(true); setUploadProgress(10);
      try {
        setUploadProgress(40);
        const up = await messagingApi.uploadAttachment(currentFile);
        setUploadProgress(90);
        mediaUrl = up.data.url;
        mediaMime = up.data.mime;
        fileName = up.data.file_name;
        setUploadProgress(100);
      } catch (err) {
        console.error('[Messages] Upload failed', err);
        setIsUploading(false); setUploadProgress(0);
        return;
      } finally {
        setIsUploading(false); setUploadProgress(0);
        clearMediaFile();
      }
    }

    if (!text && !mediaUrl && msgType === 'text') return;

    let finalType = msgType;
    if (mediaMime.startsWith('image/') && finalType === 'text') finalType = 'photo';
    else if (mediaMime.startsWith('video/') && finalType === 'text') finalType = 'video';
    else if (mediaMime.startsWith('audio/') && finalType === 'text') finalType = 'voice';
    else if (mediaMime && !mediaMime.startsWith('image/') && !mediaMime.startsWith('video/') && !mediaMime.startsWith('audio/') && finalType === 'text') finalType = 'document';

    setBody('');
    if (isTyping) { setIsTyping(false); sendTypingStop(); }
    if (typingTimerRef.current) clearTimeout(typingTimerRef.current);

    // Optimistic message
    const tempId = `temp_${Date.now()}`;
    const optimisticMsg: MsgType = {
      id: tempId,
      conversation_id: activeConvoRef.current.id,
      sender_id: profile?.user_id ?? '',
      message_type: finalType,
      body: text,
      media_url: mediaUrl,
      media_mime: mediaMime,
      file_name: fileName,
      reply_to_id: replyTo?.id ?? null,
      metadata: opts?.metadata ?? {},
      is_read: false,
      deleted_for: [],
      sender_data: {
        user_id: profile?.user_id ?? '',
        username: profile?.username ?? '',
        display_name: profile?.display_name ?? '',
        avatar_url: profile?.avatar_url ?? '',
        verification_status: profile?.verification_status ?? '',
        role: profile?.role ?? 'user',
      },
      reply_data: replyTo ? {
        id: replyTo.id,
        body: replyTo.body,
        sender_name: replyTo.sender_data.display_name,
        message_type: replyTo.message_type,
        media_url: replyTo.media_url,
      } : null,
      reactions: {},
      created_at: new Date().toISOString(),
    };

    setMessages((prev) => [...prev, optimisticMsg]);
    setReplyTo(null);

    const sent = sendMessage({
      body: text,
      message_type: finalType,
      media_url: mediaUrl,
      media_mime: mediaMime,
      file_name: fileName,
      reply_to_id: replyTo?.id,
      metadata: opts?.metadata ?? {},
    });

    if (!sent) {
      setMessages((prev) => prev.filter((m) => m.id !== tempId));
      console.warn('[Messages] WS not ready');
    }
  }, [body, mediaFile, isTyping, replyTo, sendMessage, sendTypingStop, profile, clearMediaFile]);

  const handleVoiceNoteSend = useCallback(async (blob: Blob, duration: number) => {
    setShowVoiceRecorder(false);
    if (!activeConvoRef.current) return;
    setIsUploading(true);
    try {
      const file = new File([blob], `voice_${Date.now()}.webm`, { type: blob.type });
      const up = await messagingApi.uploadAttachment(file);
      sendMessage({ body: '', message_type: 'voice', media_url: up.data.url, media_mime: up.data.mime, file_name: up.data.file_name, metadata: { duration_ms: duration } });
    } catch { /* silent */ }
    finally { setIsUploading(false); }
  }, [sendMessage]);

  const handleLocationShare = useCallback((loc: { lat: number; lng: number; label: string; mapUrl: string }) => {
    sendTextOrMedia({ body: loc.label, message_type: 'location', media_url: loc.mapUrl, metadata: { lat: loc.lat, lng: loc.lng, label: loc.label } });
  }, [sendTextOrMedia]);

  const handlePollSend = useCallback((poll: { question: string; options: string[] }) => {
    sendTextOrMedia({
      body: poll.question,
      message_type: 'poll',
      metadata: { poll: { question: poll.question, options: poll.options.map((o) => ({ text: o, votes: 0 })) } },
    });
  }, [sendTextOrMedia]);

  const handleEventSend = useCallback((event: { eventId: string; title: string; description: string; startTime: string; endTime: string; location: string; eventType: string }) => {
    sendTextOrMedia({
      body: event.title,
      message_type: 'event',
      metadata: {
        event: {
          eventId: event.eventId,
          title: event.title,
          description: event.description,
          startTime: event.startTime,
          endTime: event.endTime,
          location: event.location,
          eventType: event.eventType,
        },
      },
    });
  }, [sendTextOrMedia]);

  const handleDelete = async (msgId: string, forEveryone = false) => {
    try {
      await messagingApi.deleteMessage(msgId, forEveryone);
      setMessages((prev) =>
        forEveryone
          ? prev.filter((m) => m.id !== msgId)
          : prev.map((m) =>
              m.id === msgId ? { ...m, deleted_for: [...(m.deleted_for ?? []), profile?.user_id as string] } : m,
            ),
      );
    } catch { /* silent */ }
    setShowOptionsId(null);
  };

  // ── Filtered conversations ─────────────────────────────────────────────────
  const filteredConvos = useMemo(() => {
    if (!searchQuery.trim()) return conversations;
    const q = searchQuery.toLowerCase();
    return conversations.filter((c) => {
      const partner = c.participants_data.find((p) => p.user_id !== profile?.user_id) ?? c.participants_data[0];
      const name = (partner?.display_name ?? c.group_name ?? '').toLowerCase();
      return name.includes(q);
    });
  }, [conversations, searchQuery, profile?.user_id]);

  // Determine if I'm the callee (received the call)
  const isCallee = callState === 'ringing';

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className="flex h-full overflow-hidden bg-buddy-black">
      {/* Advanced Call Room overlay */}
      {callState !== 'idle' && (
        <CallRoom
          callState={callState}
          callType={callType}
          isMuted={isMuted}
          isRemoteMuted={isRemoteMuted}
          isCameraOff={isCameraOff}
          isSharingScreen={isSharingScreen}
          isRecording={isRecording}
          cameraError={cameraError}
          localStream={localStream}
          remoteStream={remoteStream}
          floatingReactions={floatingReactions}
          otherParticipant={other ? {
            username: other.username,
            display_name: other.display_name,
            avatar_url: other.avatar_url,
            verification_status: other.verification_status,
          } : null}
          activeConvo={activeConvo}
          isCallee={isCallee}
          isGroupCall={activeConvo?.is_group ?? false}
          onAccept={acceptIncomingCall}
          onDecline={declineCall}
          onHangUp={() => hangUp()}
          onToggleMute={toggleMute}
          onToggleCamera={toggleCamera}
          onToggleScreenShare={toggleScreenShare}
          onToggleRecording={toggleRecording}
          onSendReaction={sendReaction}
        />
      )}

      {/* Sidebar */}
      <div className={`relative flex flex-col border-r border-buddy-surface shrink-0 transition-all duration-300 ${
        activeConvo ? 'hidden md:flex' : 'flex'
      } ${conversationListCollapsed ? 'w-0 md:w-0 overflow-hidden' : 'w-full md:w-80 lg:w-96'}`}>
        <div className="p-4 border-b border-buddy-surface">
          <div className="flex items-center justify-between mb-3">
            <h1 className="text-xl font-bold font-display">Messages</h1>
            <button onClick={() => setShowNewGroupModal(true)} className="p-2 bg-buddy-surface hover:bg-buddy-surface-raised rounded-full text-buddy-green transition-colors" title="New Group">
              <Plus size={18} />
            </button>
          </div>
          <div className="flex items-center gap-2 bg-buddy-surface rounded-2xl px-3 py-2">
            <Search size={15} className="text-buddy-text-secondary shrink-0" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search conversations..."
              className="flex-1 bg-transparent text-sm focus:outline-none text-buddy-text-primary placeholder:text-buddy-text-secondary/50"
            />
          </div>
        </div>

        {isLoading ? (
          <div className="flex-1 flex items-center justify-center">
            <div className="w-8 h-8 border-2 border-buddy-green border-t-transparent rounded-full animate-spin" />
          </div>
        ) : filteredConvos.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center gap-3 p-6 text-center">
            <div className="w-16 h-16 rounded-full bg-buddy-surface flex items-center justify-center">
              <Mic size={24} className="text-buddy-text-secondary" />
            </div>
            <p className="text-buddy-text-secondary text-sm">
              {searchQuery ? 'No conversations found' : 'No conversations yet. Follow someone and say hi!'}
            </p>
          </div>
        ) : (
          <div className="flex-1 overflow-y-auto divide-y divide-buddy-surface/40">
            {filteredConvos.map((convo) => {
              const partner = convo.participants_data.find((p) => p.user_id !== profile?.user_id) ?? convo.participants_data[0];
              const name = partner?.display_name ?? convo.group_name ?? 'Group';
              const avatarUrl = partner?.avatar_url ?? convo.group_avatar_url;
              const isActive = activeConvo?.id === convo.id;

              return (
                <button
                  key={convo.id}
                  onClick={() => openConversation(convo)}
                  className={`w-full flex items-center gap-3 px-4 py-3.5 hover:bg-buddy-surface/50 transition-colors text-left ${isActive ? 'bg-buddy-surface/60' : ''}`}
                >
                  <div className="relative shrink-0">
                    <Avatar src={avatarUrl} alt={name} size="md" verificationStatus={partner?.verification_status || ''} />
                    {partner?.user_id && presence[partner.user_id]?.online && (
                      <span className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-buddy-green rounded-full border-2 border-buddy-black" />
                    )}
                    {convo.unread_count > 0 && (
                      <span className="absolute -top-1 -right-1 w-5 h-5 bg-buddy-green text-buddy-black text-[10px] font-extrabold rounded-full flex items-center justify-center border-2 border-buddy-black">
                        {convo.unread_count > 9 ? '9+' : convo.unread_count}
                      </span>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-0.5">
                      <span className={`font-semibold text-sm truncate ${convo.unread_count > 0 ? 'text-white' : 'text-buddy-text-primary'}`}>
                        {name}
                      </span>
                      <span className="text-[10px] text-buddy-text-secondary shrink-0 ml-1">
                        {convo.last_message_at
                          ? new Date(convo.last_message_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                          : ''}
                      </span>
                    </div>
                    <p className={`text-xs truncate ${convo.unread_count > 0 ? 'text-gray-300 font-medium' : 'text-buddy-text-secondary'}`}>
                      {convo.last_message
                        ? `${convo.last_message.sender_name === profile?.display_name ? 'You: ' : ''}${convo.last_message.message_type !== 'text' ? `[${convo.last_message.message_type}] ` : ''}${convo.last_message.body || '📎 Attachment'}`
                        : 'Start the conversation'}
                    </p>
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Conversation list toggle */}
      <button
        onClick={() => setConversationListCollapsed((prev) => !prev)}
        className="hidden md:flex items-center justify-center w-6 bg-buddy-surface hover:bg-buddy-surface-raised border-r border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary transition-colors shrink-0 cursor-pointer"
        title={conversationListCollapsed ? 'Show conversation list' : 'Hide conversation list'}
      >
        {conversationListCollapsed ? <ChevronRight size={14} /> : <ChevronLeft size={14} />}
      </button>

      {/* Chat Area */}
      {!activeConvo ? (
        <div className="hidden md:flex flex-1 flex-col items-center justify-center gap-4 text-buddy-text-secondary">
          <div className="w-20 h-20 rounded-full bg-buddy-surface flex items-center justify-center">
            <Mic size={32} className="text-buddy-green/60" />
          </div>
          <p className="text-lg font-semibold">Select a conversation</p>
          <p className="text-sm opacity-60">Choose someone to chat with</p>
        </div>
      ) : (
        <div className="flex-1 flex flex-col overflow-hidden relative">

          {/* Header */}
          <div className="flex items-center gap-3 p-3.5 border-b border-buddy-surface bg-buddy-black/90 backdrop-blur-md sticky top-0 z-20 shrink-0">
            <button
              onClick={closeConversation}
              className="p-1.5 rounded-xl hover:bg-buddy-surface text-buddy-text-secondary transition-colors md:hidden"
            >
              <ArrowLeft size={20} />
            </button>
            <div className="relative">
              <Avatar
                src={other?.avatar_url ?? activeConvo.group_avatar_url}
                alt={other?.display_name ?? activeConvo.group_name ?? 'Group'}
                size="md"
                verificationStatus={other?.verification_status || ''}
              />
              {presenceInfo?.online && (
                <span className="absolute bottom-0 right-0 w-3 h-3 bg-buddy-green rounded-full border-2 border-buddy-black" />
              )}
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-heading font-bold text-sm truncate leading-tight">
                {other?.display_name ?? activeConvo.group_name}
              </h3>
              <p className="text-[11px] truncate leading-tight mt-0.5">
                {typingNames.length > 0 ? (
                  <span className="text-buddy-green font-medium animate-pulse">typing…</span>
                ) : presenceInfo?.online ? (
                  <span className="text-buddy-green">Online</span>
                ) : presenceInfo?.last_seen ? (
                  <span className="text-buddy-text-secondary">{formatLastSeen(presenceInfo.last_seen)}</span>
                ) : (
                  <span className="text-buddy-text-secondary">@{other?.username}</span>
                )}
              </p>
            </div>
            <div className="flex gap-1 shrink-0">
              <button
                onClick={() => startCall('audio')}
                disabled={callState !== 'idle'}
                className="p-2 rounded-xl hover:bg-buddy-surface text-buddy-text-secondary disabled:opacity-40 transition-colors"
                title="Voice call"
              >
                <Phone size={18} />
              </button>
              <button
                onClick={() => startCall('video')}
                disabled={callState !== 'idle'}
                className="p-2 rounded-xl hover:bg-buddy-surface text-buddy-text-secondary disabled:opacity-40 transition-colors"
                title="Video call"
              >
                <Video size={18} />
              </button>
            </div>
          </div>

          {/* Attachment filter chips */}
          <div className="flex gap-2 overflow-x-auto px-4 py-2 shrink-0 scrollbar-none">
            {[
              { label: 'All', value: '' },
              { label: 'Photos', value: 'photo' },
              { label: 'Videos', value: 'video' },
              { label: 'Audio', value: 'audio' },
              { label: 'Documents', value: 'document' },
              { label: 'Links', value: 'link' },
              { label: 'Polls', value: 'poll' },
              { label: 'Locations', value: 'location' },
              { label: 'Events', value: 'event' },
            ].map((chip) => (
              <button
                key={chip.value}
                onClick={async () => {
                  setAttachmentFilter(chip.value);
                  if (activeConvo) {
                    try {
                      const res = await messagingApi.getMessages(activeConvo.id, undefined, chip.value || undefined);
                      setMessages(res.data ?? []);
                    } catch {}
                  }
                }}
                className={`shrink-0 px-4 py-1.5 rounded-full text-xs font-medium transition-colors whitespace-nowrap ${
                  attachmentFilter === chip.value
                    ? 'bg-buddy-green text-buddy-black'
                    : 'bg-buddy-surface text-buddy-text-secondary hover:bg-buddy-surface-raised'
                }`}
              >
                {chip.label}
              </button>
            ))}
          </div>

          {/* Messages */}
          <div
            className="flex-1 overflow-y-auto px-4 py-4 space-y-1"
            onClick={() => { setShowOptionsId(null); setShowEmojiPickerId(null); }}
          >
            {messages.length === 0 && (
              <div className="flex flex-col items-center justify-center py-24 gap-4">
                <Avatar src={other?.avatar_url} alt={other?.display_name ?? 'User'} size="xl" className="ring-2 ring-buddy-surface" verificationStatus={other?.verification_status} />
                <div className="text-center">
                  <p className="font-semibold text-buddy-text-primary">{other?.display_name ?? 'Group'}</p>
                  <p className="text-sm text-buddy-text-secondary mt-1">Say hi to start the conversation! 👋</p>
                </div>
              </div>
            )}

            {messages
              .filter((m) => !(m.deleted_for ?? []).includes(profile?.user_id as string))
              .map((msg, idx, arr) => {
                const isMine = msg.sender_id === profile?.user_id;
                const isTemp = msg.id.startsWith('temp_');
                const prevMsg = idx > 0 ? arr[idx - 1] : null;
                const isGroup = activeConvo.is_group;
                const isSeq = prevMsg?.sender_id === msg.sender_id;
                const isPoll = msg.metadata?.poll != null;
                const isLocation = msg.message_type === 'location';
                const isEvent = msg.message_type === 'event';

                return (
                  <div
                    key={msg.id}
                    className={`flex ${isMine ? 'justify-end' : 'justify-start'} group relative ${isTemp ? 'opacity-70' : ''}`}
                    onDoubleClick={() => setShowEmojiPickerId(showEmojiPickerId === msg.id ? null : msg.id)}
                  >
                    {/* Avatar for other person (non-sequential) */}
                    {!isMine && !isSeq && (
                      <Avatar
                        src={msg.sender_data?.avatar_url}
                        alt={msg.sender_data?.display_name ?? ''}
                        size="xs"
                        className="self-end mr-2 mb-1 shrink-0"
                        verificationStatus={msg.sender_data?.verification_status}
                      />
                    )}
                    {!isMine && isSeq && <div className="w-8 mr-2 shrink-0" />}

                    <div className={`max-w-[78%] flex flex-col ${isMine ? 'items-end' : 'items-start'}`}>
                      {/* Group sender name */}
                      {!isMine && isGroup && !isSeq && (
                        <span className="text-[10px] text-buddy-text-secondary ml-2 mb-0.5 font-medium">
                          {msg.sender_data?.display_name}
                        </span>
                      )}

                      {/* Reply context */}
                      {msg.reply_data && (
                        <div className={`text-[10px] px-2.5 py-1.5 mb-1 rounded-lg max-w-full border-l-2 ${
                          isMine ? 'bg-buddy-black/10 border-buddy-black/30 text-buddy-black' : 'bg-buddy-surface-raised border-buddy-text-secondary/20 text-buddy-text-secondary'
                        }`}>
                          <span className="font-bold block truncate">
                            {msg.reply_data.sender_name === profile?.display_name ? 'You' : msg.reply_data.sender_name}
                          </span>
                          <span className="truncate block opacity-80 mt-0.5">{msg.reply_data.body || '📎 Attachment'}</span>
                        </div>
                      )}

                      {/* Bubble */}
                      <div className="flex items-end gap-1.5 relative">
                        {/* My message options (left of bubble) */}
                        {isMine && !isTemp && (
                          <div className="flex flex-col gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                              onClick={(e) => { e.stopPropagation(); setForwardModalConvId(msg.id); setShowForwardModal(true); }}
                              className="p-1 text-buddy-text-secondary hover:text-buddy-green rounded-full"
                              title="Forward"
                            >
                              <Forward size={13} />
                            </button>
                            <button
                              onClick={(e) => { e.stopPropagation(); setShowOptionsId(showOptionsId === msg.id ? null : msg.id); }}
                              className="p-1 text-buddy-text-secondary hover:text-white rounded-full"
                            >
                              <MoreVertical size={13} />
                            </button>
                          </div>
                        )}

                        <div className={`rounded-[20px] overflow-hidden text-sm ${
                          isMine
                            ? 'bg-buddy-green text-buddy-black rounded-br-sm'
                            : 'bg-buddy-surface text-buddy-text-primary rounded-bl-sm'
                        }`} style={{ maxWidth: '100%' }}>

                          {/* Location */}
                          {isLocation && (
                            <LocationCard
                              lat={Number(msg.metadata?.lat)}
                              lng={Number(msg.metadata?.lng)}
                              label={msg.body || `${Number(msg.metadata?.lat).toFixed(4)}, ${Number(msg.metadata?.lng).toFixed(4)}`}
                              isMine={isMine}
                            />
                          )}

                          {/* Poll */}
                          {isPoll && !isLocation && (
                            <PollCard msg={msg} isMine={isMine} />
                          )}

                          {/* Event */}
                          {isEvent && !isLocation && !!msg.metadata?.event && (
                            <div className="p-3 w-64">
                              <div className="flex items-center gap-1.5 mb-2">
                                <Calendar size={13} className={isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'} />
                                <span className={`text-[10px] font-semibold ${isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'}`}>EVENT</span>
                              </div>
                              {(() => {
                                const ev = msg.metadata.event as { eventId: string; title: string; description: string; startTime: string; endTime: string; location: string; eventType: string };
                                const startDate = new Date(ev.startTime);
                                const dateStr = startDate.toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' });
                                const timeStr = startDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                                const googleCalUrl = `https://www.google.com/calendar/render?action=TEMPLATE&text=${encodeURIComponent(ev.title)}&dates=${startDate.toISOString().replace(/[-:]/g, '').split('.')[0]}Z/${new Date(ev.endTime).toISOString().replace(/[-:]/g, '').split('.')[0]}Z&details=${encodeURIComponent(ev.description)}&location=${encodeURIComponent(ev.location)}`;
                                return (
                                  <>
                                    <p className="font-semibold text-sm mb-1">{ev.title}</p>
                                    <div className="flex items-center gap-1.5 text-xs opacity-80 mb-0.5">
                                      <Calendar size={11} />
                                      <span>{dateStr}</span>
                                    </div>
                                    <div className="flex items-center gap-1.5 text-xs opacity-80 mb-0.5">
                                      <Clock size={11} />
                                      <span>{timeStr}</span>
                                    </div>
                                    <div className="flex items-center gap-1.5 text-xs opacity-80 mb-1">
                                      <MapPin size={11} />
                                      <span className="truncate">{ev.location}</span>
                                    </div>
                                    <a
                                      href={googleCalUrl}
                                      target="_blank"
                                      rel="noreferrer"
                                      className={`inline-flex items-center gap-1 text-[11px] font-medium mt-1 ${
                                        isMine ? 'text-buddy-black/70' : 'text-buddy-green'
                                      } hover:underline`}
                                      onClick={(e) => e.stopPropagation()}
                                    >
                                      <Calendar size={11} />
                                      Add to Calendar
                                    </a>
                                  </>
                                );
                              })()}
                            </div>
                          )}

                          {/* Media */}
                          {!isLocation && !isPoll && !isEvent && msg.media_url && (
                            <div className="max-w-full">
                              {msg.message_type === 'photo' ? (
                                <div className="relative group/media">
                                  <img
                                    src={msg.media_url}
                                    alt="Photo"
                                    className="max-w-xs w-full object-cover cursor-zoom-in"
                                    style={{ borderRadius: msg.body ? '0' : undefined }}
                                    onClick={() => window.open(msg.media_url, '_blank')}
                                  />
                                  <button
                                    onClick={(e) => { e.stopPropagation(); window.open(msg.media_url, '_blank'); }}
                                    className="absolute top-2 right-2 p-1.5 bg-black/50 hover:bg-black/70 rounded-full opacity-0 group-hover/media:opacity-100 transition-opacity text-white"
                                    title="Download"
                                  >
                                    <Download size={14} />
                                  </button>
                                </div>
                              ) : msg.message_type === 'video' ? (
                                <div className="relative group/media overflow-hidden rounded-[18px]">
                                  <video
                                    src={msg.media_url}
                                    controls
                                    playsInline
                                    className="max-w-xs w-full bg-black/10 object-cover"
                                    style={{ maxHeight: 300, display: 'block' }}
                                  />
                                  <button
                                    onClick={(e) => { e.stopPropagation(); window.open(msg.media_url, '_blank'); }}
                                    className="absolute top-2 right-2 p-1.5 bg-black/60 hover:bg-black/80 rounded-full opacity-0 group-hover/media:opacity-100 transition-opacity text-white backdrop-blur-sm shadow-sm"
                                    title="Download"
                                  >
                                    <Download size={14} />
                                  </button>
                                </div>
                              ) : msg.message_type === 'voice' ? (
                                <div className="px-3 pt-3 pb-3 w-64">
                                  <div className={`flex items-center gap-2 mb-2 ${isMine ? 'text-buddy-black/70' : 'text-buddy-text-secondary'}`}>
                                    <Mic size={12} />
                                    <span className="text-[10px] font-semibold tracking-wide">VOICE NOTE</span>
                                    {msg.metadata?.duration_ms ? (
                                      <span className="text-[10px] ml-auto opacity-60">{Math.round((msg.metadata.duration_ms as number) / 1000)}s</span>
                                    ) : null}
                                    <button
                                      onClick={(e) => { e.stopPropagation(); window.open(msg.media_url, '_blank'); }}
                                      className="p-1 hover:text-buddy-green transition-colors ml-auto"
                                      title="Download"
                                    >
                                      <Download size={12} />
                                    </button>
                                  </div>
                                  <CustomAudioPlayer src={msg.media_url} isMine={isMine} />
                                </div>
                              ) : (
                                <div className="flex items-center gap-3 px-3 py-3 w-64">
                                  <div className={`p-2.5 rounded-xl shrink-0 flex items-center justify-center ${isMine ? 'bg-buddy-black/10 text-buddy-black' : 'bg-buddy-surface-raised text-buddy-green'}`}>
                                    <FileText size={20} strokeWidth={2.5} />
                                  </div>
                                  <div className="flex-1 min-w-0 flex flex-col justify-center">
                                    <p className="truncate text-sm font-semibold">{msg.file_name || 'Document'}</p>
                                    <button 
                                      onClick={(e) => { e.stopPropagation(); setPreviewFileUrl({ url: msg.media_url!, name: msg.file_name || 'Document' }); }}
                                      className="text-left text-[11px] font-medium opacity-70 hover:opacity-100 transition-opacity underline-offset-2 hover:underline mt-0.5"
                                    >
                                      Tap to view
                                    </button>
                                  </div>
                                  <button
                                    onClick={(e) => { e.stopPropagation(); window.open(msg.media_url, '_blank'); }}
                                    className={`p-2 rounded-full transition-colors shrink-0 ${isMine ? 'hover:bg-buddy-black/10 text-buddy-black' : 'hover:bg-white/10 text-buddy-text-secondary hover:text-white'}`}
                                    title="Download"
                                  >
                                    <Download size={16} />
                                  </button>
                                </div>
                              )}
                            </div>
                          )}

                          {/* Text body */}
                          {!isLocation && !isPoll && msg.body && (
                            <p className="px-3 py-2 whitespace-pre-wrap break-words leading-snug">{msg.body}</p>
                          )}

                          {/* Link preview */}
                          {!isLocation && msg.message_type === 'text' && msg.body && (() => {
                            const urlMatch = msg.body.match(/https?:\/\/[^\s]+/);
                            const previewUrl = urlMatch?.[0];
                            const preview = previewUrl ? linkPreviews[previewUrl] : null;
                            return preview ? (
                              <a
                                href={preview.url}
                                target="_blank"
                                rel="noreferrer"
                                className={`block mx-3 mb-2 rounded-xl overflow-hidden border ${isMine ? 'border-buddy-black/20' : 'border-buddy-surface-raised'} hover:opacity-90 transition-opacity`}
                              >
                                {preview.image && (
                                  <img src={preview.image} alt="" className="w-full h-28 object-cover" />
                                )}
                                <div className="p-2.5">
                                  <p className="text-xs font-semibold truncate">{preview.title}</p>
                                  <p className="text-[10px] opacity-60 truncate">{preview.domain}</p>
                                  {preview.description && (
                                    <p className="text-[10px] opacity-70 mt-1 line-clamp-2">{preview.description}</p>
                                  )}
                                </div>
                              </a>
                            ) : null;
                          })()}

                          {/* Timestamp + read receipt */}
                          <div className={`flex items-center justify-end gap-1 px-2.5 pb-1.5 -mt-1 ${isMine ? 'text-buddy-black/50' : 'text-buddy-text-secondary/50'}`}>
                            <span className="text-[9px]">
                              {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                            </span>
                            {isMine && (
                              isTemp
                                ? <Check size={10} className="opacity-50" />
                                : msg.is_read
                                  ? <CheckCheck size={10} className="text-buddy-green/70" />
                                  : <Check size={10} />
                            )}
                          </div>
                        </div>

                        {/* Other message actions */}
                        {!isMine && (
                          <div className="flex flex-col gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                              onClick={(e) => { e.stopPropagation(); setReplyTo(msg); inputRef.current?.focus(); }}
                              className="p-1 text-buddy-text-secondary hover:text-white rounded-full text-base"
                            >↩</button>
                            <button
                              onClick={(e) => { e.stopPropagation(); setShowEmojiPickerId(msg.id); }}
                              className="p-1 text-buddy-text-secondary hover:text-buddy-green rounded-full"
                            >
                              <Smile size={13} />
                            </button>
                            <button
                              onClick={(e) => { e.stopPropagation(); setForwardModalConvId(msg.id); setShowForwardModal(true); }}
                              className="p-1 text-buddy-text-secondary hover:text-buddy-green rounded-full"
                              title="Forward"
                            >
                              <Forward size={13} />
                            </button>
                          </div>
                        )}

                        {/* Quick emoji react */}
                        {showEmojiPickerId === msg.id && (
                          <div
                            className={`absolute ${isMine ? 'right-full mr-2' : 'left-full ml-2'} top-0 z-20 bg-buddy-surface-raised border border-buddy-surface rounded-2xl px-2 py-1.5 flex gap-1 shadow-2xl`}
                            onClick={(e) => e.stopPropagation()}
                          >
                            {QUICK_EMOJIS.map((emoji) => (
                              <button
                                key={emoji}
                                onClick={() => { sendReact(msg.id, emoji); setShowEmojiPickerId(null); }}
                                className="text-base hover:scale-125 transition-transform p-0.5"
                              >{emoji}</button>
                            ))}
                          </div>
                        )}

                        {/* Context menu */}
                        {showOptionsId === msg.id && (
                          <div
                            className={`absolute ${isMine ? 'right-0' : 'left-0'} top-full mt-1 z-20 bg-buddy-surface-raised border border-buddy-surface rounded-2xl shadow-2xl p-1 w-52 text-sm`}
                            onClick={(e) => e.stopPropagation()}
                          >
                            <button onClick={() => { setReplyTo(msg); setShowOptionsId(null); inputRef.current?.focus(); }} className="w-full text-left px-3 py-2 rounded-xl hover:bg-buddy-surface text-buddy-text-primary flex items-center gap-2">
                              ↩ Reply
                            </button>
                            <button onClick={() => handleDelete(msg.id, true)} className="w-full text-left px-3 py-2 rounded-xl hover:bg-buddy-surface text-red-400 flex items-center gap-2">
                              Delete for Everyone
                            </button>
                            <button onClick={() => handleDelete(msg.id, false)} className="w-full text-left px-3 py-2 rounded-xl hover:bg-buddy-surface text-buddy-text-secondary flex items-center gap-2">
                              Delete for Me
                            </button>
                          </div>
                        )}
                      </div>

                      {/* Reactions */}
                      {(() => {
                        const displayReactions = Object.entries(msg.reactions ?? {}).filter(([emoji]) => !emoji.startsWith('poll:'));
                        if (displayReactions.length === 0) return null;
                        return (
                          <div className="flex flex-wrap gap-1 mt-1 px-1">
                            {displayReactions.map(([emoji, count]) => (
                              <button
                                key={emoji}
                                onClick={() => sendReact(msg.id, emoji)}
                                className="flex items-center gap-1 bg-buddy-surface rounded-full px-2 py-0.5 text-xs hover:bg-buddy-surface-raised transition-colors"
                              >
                                {emoji} <span className="opacity-70">{count}</span>
                              </button>
                            ))}
                          </div>
                        );
                      })()}
                    </div>
                  </div>
                );
              })}

            {/* Typing indicator */}
            {typingNames.length > 0 && (
              <div className="flex justify-start">
                <div className="bg-buddy-surface rounded-2xl rounded-bl-sm px-4 py-3 flex items-center gap-1">
                  <span className="w-1.5 h-1.5 bg-buddy-text-secondary rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                  <span className="w-1.5 h-1.5 bg-buddy-text-secondary rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                  <span className="w-1.5 h-1.5 bg-buddy-text-secondary rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            )}

            <div ref={messagesEndRef} />
          </div>

          {/* Input Area */}
          <div className="border-t border-buddy-surface bg-buddy-black px-3 py-3 shrink-0 relative">
            {/* Reply preview */}
            {replyTo && (
              <div className="flex items-center justify-between bg-buddy-surface rounded-xl px-3 py-2 mb-2 border-l-4 border-buddy-green">
                <div className="min-w-0">
                  <p className="text-[11px] text-buddy-green font-semibold">Replying to {replyTo.sender_data.display_name}</p>
                  <p className="text-xs text-buddy-text-secondary truncate mt-0.5">{replyTo.body || '📎 Attachment'}</p>
                </div>
                <button onClick={() => setReplyTo(null)} className="p-1 text-buddy-text-secondary hover:text-white ml-2 shrink-0">
                  <X size={14} />
                </button>
              </div>
            )}

            {/* Media preview */}
            {mediaFile && (
              <div className="flex items-center gap-3 bg-buddy-surface rounded-xl px-3 py-2 mb-2">
                {mediaPreviewUrl && mediaFile.type.startsWith('image/') ? (
                  <img src={mediaPreviewUrl} alt="Preview" className="w-12 h-12 object-cover rounded-lg" />
                ) : mediaPreviewUrl && mediaFile.type.startsWith('video/') ? (
                  <video src={mediaPreviewUrl} className="w-12 h-12 object-cover rounded-lg" />
                ) : (
                  <FileText size={24} className="text-buddy-text-secondary shrink-0" />
                )}
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-medium truncate">{mediaFile.name}</p>
                  <p className="text-[10px] text-buddy-text-secondary">{(mediaFile.size / 1024 / 1024).toFixed(2)} MB</p>
                </div>
                <button onClick={clearMediaFile} className="p-1 text-buddy-text-secondary hover:text-red-400 shrink-0">
                  <X size={16} />
                </button>
              </div>
            )}

            {/* Upload progress */}
            {isUploading && uploadProgress > 0 && (
              <div className="mb-2 h-1 bg-buddy-surface rounded-full overflow-hidden">
                <div className="h-full bg-buddy-green transition-all duration-300" style={{ width: `${uploadProgress}%` }} />
              </div>
            )}

            {/* Voice recorder */}
            {showVoiceRecorder ? (
              <VoiceNoteRecorder onSend={handleVoiceNoteSend} onCancel={() => setShowVoiceRecorder(false)} />
            ) : (
              <div className="flex items-end gap-2">
                {/* Attachment menu */}
                <div className="relative shrink-0">
                  <button
                    onClick={() => setShowAttachMenu((v) => !v)}
                    className="p-2.5 rounded-full bg-buddy-surface hover:bg-buddy-surface-raised text-buddy-text-secondary transition-colors"
                  >
                    <Plus size={20} className={`transition-transform duration-200 ${showAttachMenu ? 'rotate-45 text-buddy-green' : ''}`} />
                  </button>
                  {showAttachMenu && (
                    <AttachmentMenu
                      onFile={stageFile}
                      onLocation={handleLocationShare}
                      onPoll={handlePollSend}
                      onEvent={handleEventSend}
                      onVoiceNote={() => { setShowVoiceRecorder(true); setShowAttachMenu(false); }}
                      onClose={() => setShowAttachMenu(false)}
                    />
                  )}
                </div>

                {/* Text input */}
                <div className="flex-1 flex items-end bg-buddy-surface rounded-3xl px-4 py-2.5">
                  <input
                    ref={inputRef}
                    type="text"
                    value={body}
                    onChange={handleInput}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        sendTextOrMedia();
                      }
                    }}
                    placeholder="Message..."
                    className="flex-1 bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/40 focus:outline-none min-w-0"
                  />
                  {!body.trim() && !mediaFile && (
                    <button onClick={() => setShowVoiceRecorder(true)} className="ml-2 text-buddy-text-secondary hover:text-buddy-green transition-colors shrink-0">
                      <Mic size={17} />
                    </button>
                  )}
                </div>

                {/* Send */}
                <button
                  onClick={() => sendTextOrMedia()}
                  disabled={(!body.trim() && !mediaFile) || isUploading}
                  className="p-2.5 rounded-full bg-buddy-green text-buddy-black disabled:opacity-40 hover:bg-buddy-green-deep transition-all hover:scale-105 shrink-0"
                >
                  {isUploading
                    ? <div className="w-5 h-5 border-2 border-buddy-black border-t-transparent rounded-full animate-spin" />
                    : <Send size={18} />
                  }
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* New Group Modal */}
      {showNewGroupModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-buddy-black/80 backdrop-blur-sm">
          <div className="bg-buddy-surface-raised w-full max-w-md rounded-2xl p-6 shadow-2xl">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-bold font-display">New Group</h2>
              <button onClick={() => setShowNewGroupModal(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Group Name</label>
                <input
                  type="text"
                  value={newGroupName}
                  onChange={(e) => setNewGroupName(e.target.value)}
                  className="w-full bg-buddy-surface rounded-xl px-4 py-2.5 text-sm outline-none border border-transparent focus:border-buddy-green"
                  placeholder="E.g., Weekend Warriors"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-buddy-text-secondary mb-1">Participants (comma separated Usernames or IDs)</label>
                <input
                  type="text"
                  value={newGroupUsers}
                  onChange={(e) => setNewGroupUsers(e.target.value)}
                  className="w-full bg-buddy-surface rounded-xl px-4 py-2.5 text-sm outline-none border border-transparent focus:border-buddy-green"
                  placeholder="john_doe, sarah_connor"
                />
                <p className="text-[10px] text-buddy-text-secondary mt-1">Note: You must be buddies or interacting with a professional to message them.</p>
              </div>
              <button
                className="w-full py-2.5 rounded-xl bg-buddy-green text-buddy-black font-bold text-sm hover:scale-[1.02] transition-transform"
                onClick={async () => {
                  try {
                    const ids = newGroupUsers.split(',').map((s) => s.trim()).filter(Boolean);
                    if (!ids.length) return alert('Enter at least one participant.');
                    const res = await messagingApi.startConversation(ids, newGroupName || undefined);
                    setShowNewGroupModal(false);
                    setNewGroupName('');
                    setNewGroupUsers('');
                    fetchConversations();
                    openConversation(res.data);
                  } catch (e: any) {
                    alert(e.response?.data?.message || 'Failed to create group');
                  }
                }}
              >
                Create Group
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Forward Modal */}
      {showForwardModal && forwardModalConvId && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-buddy-black/80 backdrop-blur-sm" onClick={() => setShowForwardModal(false)}>
          <div className="bg-buddy-surface-raised w-full max-w-md rounded-2xl p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-bold font-display">Forward Message</h2>
              <button onClick={() => setShowForwardModal(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary"><X size={20} /></button>
            </div>
            <div className="max-h-80 overflow-y-auto space-y-1">
              {conversations
                .filter((c) => c.id !== activeConvo?.id)
                .map((convo) => {
                  const partner = convo.participants_data.find((p) => p.user_id !== profile?.user_id) ?? convo.participants_data[0];
                  const name = partner?.display_name ?? convo.group_name ?? 'Conversation';
                  return (
                    <button
                      key={convo.id}
                      onClick={async () => {
                        try {
                          await messagingApi.forwardMessage(forwardModalConvId, convo.id);
                          setShowForwardModal(false);
                          setForwardModalConvId(null);
                        } catch {}
                      }}
                      className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-buddy-surface transition-colors text-left"
                    >
                      <Avatar src={partner?.avatar_url} alt={name} size="sm" verificationStatus={partner?.verification_status} />
                      <span className="text-sm font-medium truncate">{name}</span>
                    </button>
                  );
                })}
              {conversations.filter((c) => c.id !== activeConvo?.id).length === 0 && (
                <p className="text-sm text-buddy-text-secondary text-center py-8">No other conversations to forward to.</p>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Document Preview Modal */}
      {previewFileUrl && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm" onClick={() => setPreviewFileUrl(null)}>
          <div className="bg-white dark:bg-buddy-surface w-full max-w-4xl h-[85vh] rounded-2xl overflow-hidden flex flex-col shadow-2xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between px-4 py-3 border-b dark:border-white/10 bg-buddy-surface-raised">
              <div className="flex items-center gap-2 min-w-0">
                <FileText size={18} className="text-buddy-green shrink-0" />
                <span className="font-semibold text-sm truncate">{previewFileUrl.name}</span>
              </div>
              <div className="flex items-center gap-2">
                <a href={previewFileUrl.url} target="_blank" rel="noreferrer" className="p-2 hover:bg-black/5 dark:hover:bg-white/5 rounded-full transition-colors" title="Download">
                  <Download size={18} />
                </a>
                <button onClick={() => setPreviewFileUrl(null)} className="p-2 hover:bg-black/5 dark:hover:bg-white/5 rounded-full transition-colors">
                  <X size={18} />
                </button>
              </div>
            </div>
            <div className="flex-1 bg-white/5">
              <iframe 
                src={previewFileUrl.url.toLowerCase().endsWith('.pdf') ? previewFileUrl.url : `https://docs.google.com/viewer?url=${encodeURIComponent(previewFileUrl.url)}&embedded=true`} 
                className="w-full h-full border-0"
                title="Document Preview"
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
