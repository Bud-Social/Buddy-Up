import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../data/repositories/messaging_repository.dart';
import '../../../data/models/messaging.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/chat/chat_socket.dart';
import '../services/call_engine.dart';
import '../services/user_channel_socket.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final dio = ref.watch(apiClientProvider4).dio;
  return MessagingRepository(dio);
});

final apiClientProvider4 = Provider<ApiClient>((_) => ApiClient());

List<Conversation> _parseConvList(dynamic data) =>
    (data as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
List<Message> _parseMsgList(dynamic data) =>
    (data as List).map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ConversationsNotifier extends Notifier<ConversationsState> {
  @override
  ConversationsState build() => const ConversationsState();

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await _repository.getConversations();
      state = state.copyWith(conversations: _parseConvList(raw['data']), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateConversation(Conversation updated) {
    state = state.copyWith(
      conversations: state.conversations.map((c) => c.id == updated.id ? updated : c).toList(),
    );
  }

  void decrementUnread(String convId) {
    state = state.copyWith(
      conversations: state.conversations.map((c) {
        if (c.id == convId && c.unreadCount > 0) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList(),
    );
  }
}

final conversationsProvider = NotifierProvider<ConversationsNotifier, ConversationsState>(ConversationsNotifier.new);

class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? beforeCursor;
  final bool hasMore;
  final String? error;
  final bool isTyping;
  final String? typingUserName;
  final String? replyToId;
  final Message? replyToMessage;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.beforeCursor,
    this.hasMore = true,
    this.error,
    this.isTyping = false,
    this.typingUserName,
    this.replyToId,
    this.replyToMessage,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    String? beforeCursor,
    bool? hasMore,
    String? error,
    bool? isTyping,
    String? typingUserName,
    String? replyToId,
    Message? replyToMessage,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      beforeCursor: beforeCursor ?? this.beforeCursor,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      isTyping: isTyping ?? this.isTyping,
      typingUserName: typingUserName ?? this.typingUserName,
      replyToId: replyToId ?? this.replyToId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }
}

class MessagesNotifier extends Notifier<MessagesState> {
  final String conversationId;

  MessagesNotifier(this.conversationId);

  @override
  MessagesState build() => const MessagesState();

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await _repository.getMessages(conversationId);
      final data = raw['data'];
      final pagination = raw['pagination'] as Map<String, dynamic>?;
      final msgs = _parseMsgList(data);
      state = state.copyWith(
        messages: msgs,
        isLoading: false,
        beforeCursor: msgs.isNotEmpty ? msgs.last.id : null,
        hasMore: pagination?['next'] != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final raw = await _repository.getMessages(conversationId, before: state.beforeCursor);
      final msgs = _parseMsgList(raw['data']);
      state = state.copyWith(
        messages: [...state.messages, ...msgs],
        isLoadingMore: false,
        beforeCursor: msgs.isNotEmpty ? msgs.last.id : state.beforeCursor,
        hasMore: msgs.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void addMessage(Message msg) {
    state = state.copyWith(messages: [msg, ...state.messages]);
  }

  void updateMessage(String msgId, Map<String, int> reactions) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == msgId) return m.copyWith(reactions: reactions);
        return m;
      }).toList(),
    );
  }

  void removeMessage(String msgId) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != msgId).toList(),
    );
  }

  void setReplyTo(Message? msg) {
    state = state.copyWith(replyToId: msg?.id, replyToMessage: msg);
  }

  void clearReply() {
    state = state.copyWith(replyToId: null, replyToMessage: null);
  }

  void setTyping(bool typing, String? userName) {
    state = state.copyWith(isTyping: typing, typingUserName: userName);
  }

  void setRead(String readerId) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.senderId != readerId) return m;
        return m.copyWith(isRead: true);
      }).toList(),
    );
  }
}

final messagesProvider = NotifierProvider.family<MessagesNotifier, MessagesState, String>(
  MessagesNotifier.new,
);

final chatSocketProvider = Provider.family<ChatSocket?, String>((ref, conversationId) {
  final token = ref.watch(accessTokenProvider);
  final socket = ChatSocket(conversationId: conversationId, token: token);
  ref.onDispose(() => socket.dispose());
  socket.connect();
  ref.listen(accessTokenProvider, (prev, next) {
    if (next != prev) {
      socket.updateToken(next);
    }
  });
  return socket;
});

/// Snapshot of the call state, kept in sync with the [CallEngine] so widgets
/// rebuild whenever anything call-related changes (phase, streams, mute...).
class CallSnapshot {
  final CallPhase phase;
  final String callType;
  final bool isMuted;
  final bool isCameraOff;
  final bool isInitiator;
  final bool didDecline;
  final String conversationId;
  final String peerName;
  final String peerAvatar;
  final DateTime? startedAt;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final bool renderersReady;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const CallSnapshot({
    required this.phase,
    required this.callType,
    required this.isMuted,
    required this.isCameraOff,
    required this.isInitiator,
    required this.didDecline,
    required this.conversationId,
    required this.peerName,
    required this.peerAvatar,
    required this.startedAt,
    required this.localStream,
    required this.remoteStream,
    required this.renderersReady,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  factory CallSnapshot.from(CallEngine engine) => CallSnapshot(
        phase: engine.phase,
        callType: engine.callType,
        isMuted: engine.isMuted,
        isCameraOff: engine.isCameraOff,
        isInitiator: engine.isInitiator,
        didDecline: engine.didDecline,
        conversationId: engine.conversationId,
        peerName: engine.peerName,
        peerAvatar: engine.peerAvatar,
        startedAt: engine.startedAt,
        localStream: engine.localStream,
        remoteStream: engine.remoteStream,
        renderersReady: engine.renderersReady,
        localRenderer: engine.localRenderer,
        remoteRenderer: engine.remoteRenderer,
      );
}

final callEngineProvider = Provider<CallEngine>((ref) {
  final engine = CallEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

class CallSnapshotNotifier extends Notifier<CallSnapshot> {
  @override
  CallSnapshot build() {
    final engine = ref.watch(callEngineProvider);
    void onEngineChanged() => state = CallSnapshot.from(engine);
    engine.addListener(onEngineChanged);
    ref.onDispose(() => engine.removeListener(onEngineChanged));
    return CallSnapshot.from(engine);
  }
}

final callSnapshotProvider =
    NotifierProvider<CallSnapshotNotifier, CallSnapshot>(CallSnapshotNotifier.new);

final userChannelSocketProvider = Provider.family<UserChannelSocket?, String>((ref, userId) {
  final token = ref.watch(accessTokenProvider);
  if (token.isEmpty) return null;
  final socket = UserChannelSocket(
    userId: userId,
    token: token,
    onIncomingCall: (details) {
      ref.read(callEngineProvider).incomingCall(
        conversationId: details.conversationId,
        callType: details.callType,
        data: details.data,
        fromUserId: details.fromUserId,
        fromName: details.fromName,
        fromAvatar: details.fromAvatar,
      );
    },
  );
  ref.onDispose(socket.dispose);
  socket.connect();
  ref.listen(accessTokenProvider, (prev, next) {
    if (next != prev) socket.updateToken(next);
  });
  return socket;
});

class CallState {
  final PendingCall? pendingCall;
  final bool inCall;
  final String? activeCallConversationId;

  const CallState({
    this.pendingCall,
    this.inCall = false,
    this.activeCallConversationId,
  });

  CallState copyWith({
    PendingCall? pendingCall,
    bool? inCall,
    String? activeCallConversationId,
  }) {
    return CallState(
      pendingCall: pendingCall ?? this.pendingCall,
      inCall: inCall ?? this.inCall,
      activeCallConversationId: activeCallConversationId ?? this.activeCallConversationId,
    );
  }
}

class CallNotifier extends Notifier<CallState> {
  @override
  CallState build() => const CallState();

  void setPendingCall(PendingCall? call) {
    state = state.copyWith(pendingCall: call);
  }

  void startCall(String conversationId) {
    state = state.copyWith(inCall: true, activeCallConversationId: conversationId, pendingCall: null);
  }

  void endCall() {
    state = state.copyWith(inCall: false, activeCallConversationId: null);
  }
}

final callProvider = NotifierProvider<CallNotifier, CallState>(CallNotifier.new);

class UnreadCountNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state = state > 0 ? state - 1 : 0;
  void setCount(int count) => state = count;
}

final unreadCountProvider = NotifierProvider<UnreadCountNotifier, int>(UnreadCountNotifier.new);
