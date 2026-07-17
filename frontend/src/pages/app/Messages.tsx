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
  X, FileText, Plus, MapPin, BarChart2, Smile, Mic, Search, Camera,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { messagingApi } from '@/api/messaging';
import type { Conversation, Message as MsgType } from '@/api/messaging';
import { useAuthStore } from '@/store/authStore';
import { useChatSocket } from '@/hooks/useChatSocket';
import type { ChatEvent } from '@/hooks/useChatSocket';
import { useWebRTC } from '@/hooks/useWebRTC';
import { usePresence, formatLastSeen } from '@/hooks/usePresence';
import { AttachmentMenu } from '@/components/chat/AttachmentMenu';
import { VoiceNoteRecorder } from '@/components/chat/VoiceNoteRecorder';
import { CallRoom } from '@/components/chat/CallRoom';

// Quick emoji picker options
const QUICK_EMOJIS = ['❤️', '😂', '😮', '😢', '👍', '👎', '🔥', '💪'];

export default function Messages() {
  const { conversationId: routeConvoId } = useParams<{ conversationId: string }>();
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);

  // ── State ──────────────────────────────────────────────────────────────────
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeConvo, setActiveConvo] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<MsgType[]>([]);
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
      setMessages((prev) => (prev.find((m) => m.id === msg.id) ? prev : [...prev, msg]));
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
      <div className={`w-full md:w-80 lg:w-96 flex flex-col border-r border-buddy-surface shrink-0 ${activeConvo ? 'hidden md:flex' : 'flex'}`}>
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
                    {/* Online dot */}
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
                        <div className={`text-[11px] px-3 py-1.5 mb-1 rounded-xl max-w-full border-l-4 ${
                          isMine ? 'bg-buddy-green/10 border-buddy-green text-buddy-green/80' : 'bg-buddy-surface border-buddy-text-secondary/30 text-buddy-text-secondary'
                        }`}>
                          <span className="font-semibold block truncate">
                            {msg.reply_data.sender_name === profile?.display_name ? 'You' : msg.reply_data.sender_name}
                          </span>
                          <span className="truncate block opacity-80">{msg.reply_data.body || '📎 Attachment'}</span>
                        </div>
                      )}

                      {/* Bubble */}
                      <div className="flex items-end gap-1.5 relative">
                        {/* My message options (left of bubble) */}
                        {isMine && !isTemp && (
                          <div className="flex flex-col gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                              onClick={(e) => { e.stopPropagation(); setShowOptionsId(showOptionsId === msg.id ? null : msg.id); }}
                              className="p-1 text-buddy-text-secondary hover:text-white rounded-full"
                            >
                              <MoreVertical size={13} />
                            </button>
                          </div>
                        )}

                        <div className={`rounded-2xl overflow-hidden text-sm ${
                          isMine
                            ? 'bg-buddy-green text-buddy-black rounded-br-sm'
                            : 'bg-buddy-surface text-buddy-text-primary rounded-bl-sm'
                        }`} style={{ maxWidth: '100%' }}>

                          {/* Location */}
                          {isLocation && (
                            <a
                              href={`https://www.openstreetmap.org/?mlat=${msg.metadata?.lat}&mlon=${msg.metadata?.lng}#map=15/${msg.metadata?.lat}/${msg.metadata?.lng}`}
                              target="_blank"
                              rel="noreferrer"
                              className="block w-56 group/loc"
                            >
                              <div className="h-28 bg-gradient-to-br from-gray-700 to-gray-800 relative overflow-hidden">
                                <div className="absolute inset-0 flex items-center justify-center flex-col gap-1">
                                  <MapPin size={28} className={`drop-shadow-lg ${isMine ? 'text-buddy-black' : 'text-buddy-green'}`} />
                                  <div className="w-3 h-1 rounded-full bg-black/30" />
                                </div>
                                <div className="absolute inset-0 bg-[url('https://tile.openstreetmap.org/14/8192/5460.png')] opacity-20 bg-cover" />
                                <div className="absolute inset-x-0 bottom-0 h-8 bg-gradient-to-t from-black/60 to-transparent" />
                                <div className="absolute bottom-1.5 right-2 text-[9px] text-white/60">Tap to open map</div>
                              </div>
                              <div className="flex items-center gap-2 px-3 py-2">
                                <MapPin size={14} className={isMine ? 'text-buddy-black/70' : 'text-buddy-green'} />
                                <span className="text-xs truncate">{msg.body || `${Number(msg.metadata?.lat).toFixed(4)}, ${Number(msg.metadata?.lng).toFixed(4)}`}</span>
                              </div>
                            </a>
                          )}

                          {/* Poll */}
                          {isPoll && !isLocation && (
                            <div className="p-3 w-64">
                              <div className="flex items-center gap-1.5 mb-2">
                                <BarChart2 size={13} className={isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'} />
                                <span className={`text-[10px] font-semibold ${isMine ? 'text-buddy-black/60' : 'text-buddy-text-secondary'}`}>POLL</span>
                              </div>
                              <p className="font-semibold text-sm mb-3">{(msg.metadata.poll as { question: string }).question}</p>
                              {(() => {
                                const opts = (msg.metadata.poll as { options: { text: string; votes: number }[] }).options ?? [];
                                const totalVotes = opts.reduce((s, o) => s + o.votes, 0);
                                return opts.map((opt, oi) => {
                                  const pct = totalVotes > 0 ? Math.round((opt.votes / totalVotes) * 100) : 0;
                                  return (
                                    <button key={oi}
                                      onClick={async (e) => {
                                        e.stopPropagation();
                                        try {
                                          await messagingApi.reactToMessage(msg.id, `poll:${oi}`);
                                        } catch {}
                                      }}
                                      className={`w-full text-left px-3 py-2 rounded-xl text-xs font-medium border transition-all hover:scale-[1.01] mb-1.5 relative overflow-hidden ${
                                        isMine ? 'bg-buddy-black/20 border-buddy-black/30 hover:bg-buddy-black/30' : 'bg-buddy-surface-raised border-buddy-surface hover:bg-buddy-green/10'
                                      }`}
                                    >
                                      {totalVotes > 0 && (
                                        <div
                                          className={`absolute inset-y-0 left-0 rounded-xl opacity-20 ${isMine ? 'bg-buddy-black' : 'bg-buddy-green'}`}
                                          style={{ width: `${pct}%` }}
                                        />
                                      )}
                                      <span className="relative z-10">{opt.text}</span>
                                      {totalVotes > 0 && <span className="float-right relative z-10 opacity-70">{pct}%</span>}
                                    </button>
                                  );
                                });
                              })()}
                              {(() => {
                                const opts = (msg.metadata.poll as { options: { text: string; votes: number }[] }).options ?? [];
                                const total = opts.reduce((s,o)=>s+o.votes,0);
                                return total > 0 ? <p className="text-[10px] opacity-50 mt-1 text-right">{total} votes</p> : null;
                              })()}
                            </div>
                          )}

                          {/* Media */}
                          {!isLocation && !isPoll && msg.media_url && (
                            <div className="max-w-full">
                              {msg.message_type === 'photo' ? (
                                <img
                                  src={msg.media_url}
                                  alt="Photo"
                                  className="max-w-xs w-full object-cover cursor-zoom-in"
                                  style={{ borderRadius: msg.body ? '0' : undefined }}
                                  onClick={() => window.open(msg.media_url, '_blank')}
                                />
                              ) : msg.message_type === 'video' ? (
                                <video
                                  src={msg.media_url}
                                  controls
                                  playsInline
                                  className="max-w-xs w-full rounded-t-2xl"
                                  style={{ maxHeight: 300 }}
                                />
                              ) : msg.message_type === 'voice' ? (
                                <div className="px-3 pt-3 pb-2 w-56">
                                  <div className={`flex items-center gap-2 mb-1.5 ${isMine ? 'text-buddy-black/70' : 'text-buddy-text-secondary'}`}>
                                    <Mic size={12} />
                                    <span className="text-[10px] font-semibold tracking-wide">VOICE NOTE</span>
                                    {msg.metadata?.duration_ms ? (
                                      <span className="text-[10px] ml-auto opacity-60">{Math.round((msg.metadata.duration_ms as number) / 1000)}s</span>
                                    ) : null}
                                  </div>
                                  <audio
                                    src={msg.media_url}
                                    controls
                                    className="w-full"
                                    style={{ height: 36 }}
                                    onLoadedMetadata={(e) => {
                                      // Force small size
                                      (e.target as HTMLAudioElement).style.width = '100%';
                                    }}
                                  />
                                </div>
                              ) : (
                                <a href={msg.media_url} target="_blank" rel="noreferrer" className="flex items-center gap-2 px-3 py-2.5 hover:opacity-80">
                                  <FileText size={18} />
                                  <div className="min-w-0">
                                    <p className="truncate text-xs font-medium">{msg.file_name || 'Document'}</p>
                                    <p className="text-[10px] opacity-50">Tap to open</p>
                                  </div>
                                </a>
                              )}
                            </div>
                          )}

                          {/* Text body */}
                          {!isLocation && msg.body && (
                            <p className="px-3.5 py-2.5 whitespace-pre-wrap break-words leading-relaxed">{msg.body}</p>
                          )}

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
                      {Object.keys(msg.reactions ?? {}).length > 0 && (
                        <div className="flex flex-wrap gap-1 mt-1 px-1">
                          {Object.entries(msg.reactions).map(([emoji, count]) => (
                            <button
                              key={emoji}
                              onClick={() => sendReact(msg.id, emoji)}
                              className="flex items-center gap-1 bg-buddy-surface rounded-full px-2 py-0.5 text-xs hover:bg-buddy-surface-raised transition-colors"
                            >
                              {emoji} <span className="opacity-70">{count}</span>
                            </button>
                          ))}
                        </div>
                      )}
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
                      onEvent={() => { setShowAttachMenu(false); }}
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
    </div>
  );
}
