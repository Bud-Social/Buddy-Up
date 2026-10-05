import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/messaging_repository.dart';
import '../../../data/models/messaging.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/chat/chat_socket.dart';
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

  /// When set, [conversations] is narrowed to buddy-discovery threads only.
  /// The full list screen leaves it null and shows everything.
  final ConversationFilter? filter;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
    this.filter,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
    ConversationFilter? filter,
    bool clearFilter = false,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }
}

/// Narrows a conversation list without asking the server for a second copy —
/// the filter runs over the same `/messaging/conversations/` payload the main
/// Messages tab already owns, so the two screens can never disagree.
enum ConversationFilter {
  /// Threads that came out of Find a Buddy: `origin == 'discovery'`, or any
  /// DM already promoted into a buddy relationship. Once accepted the backend
  /// rewrites origin to 'buddy', so a promoted thread stays in the list rather
  /// than vanishing the moment it succeeds.
  discovery;

  bool matches(Conversation convo) {
    if (convo.isGroup || convo.isCommunity) return false;
    return convo.origin == 'discovery' || convo.origin == 'buddy';
  }
}

class ConversationsNotifier extends Notifier<ConversationsState> {
  @override
  ConversationsState build() => const ConversationsState();

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  /// [filter] narrows the list; omitting it keeps whatever filter is already
  /// active (a promotion re-reads through the same filter). Pass
  /// [clearFilter] from the unfiltered Messages tab.
  Future<void> load({ConversationFilter? filter, bool clearFilter = false}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      filter: filter,
      clearFilter: clearFilter,
    );
    try {
      final raw = await _repository.getConversations();
      final all = _parseConvList(raw['data']);
      state = state.copyWith(
        conversations: _apply(state.filter, all),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  static List<Conversation> _apply(
    ConversationFilter? filter,
    List<Conversation> all,
  ) {
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  /// Insert or replace [updated] by id.
  ///
  /// Upsert, not replace: callers use this for a conversation they have just
  /// created or fetched on its own, which is not in the list yet. A promotion
  /// also rewrites `origin`, so the row can enter or leave a filtered list —
  /// [filter] decides, not the update.
  void updateConversation(Conversation updated) {
    final existing = state.conversations.where((c) => c.id == updated.id).toList();
    final next = [
      for (final c in state.conversations)
        if (c.id != updated.id) c,
      updated,
    ];
    if (existing.isEmpty && (state.filter?.matches(updated) == false)) {
      // Never let a filtered list grow a row the filter rejects.
      return;
    }
    state = state.copyWith(conversations: _apply(state.filter, next));
  }

  /// Ask the other side to make this thread a buddy relationship. Returns a
  /// message to show on failure, or null on success — the server's own
  /// wording wins ("You are already buddies.") over ours.
  Future<String?> promoteConversation(String conversationId) async {
    try {
      await _repository.promoteConversation(conversationId);
      await load();
      return null;
    } catch (e) {
      return _promotionError(e, 'Could not send the buddy request.');
    }
  }

  /// Accept or decline a pending promotion. Only the invited participant may
  /// respond; on accept both become confirmed buddies.
  Future<String?> respondToPromotion(String promotionId, {required bool accept}) async {
    try {
      await _repository.respondToPromotion(promotionId, {'accept': accept});
      await load();
      return null;
    } catch (e) {
      return _promotionError(e, accept ? 'Could not accept.' : 'Could not decline.');
    }
  }

  static String _promotionError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final direct = data['message'] ?? data['detail'];
        if (direct is String && direct.isNotEmpty) return direct;
      }
      if (e.response?.statusCode == 409) return 'You are already buddies.';
    }
    return fallback;
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

/// Snapshot of an incoming call invite awaiting the user's decision.
/// Auto-dismisses after 30 seconds if unanswered.
final pendingInviteProvider =
    NotifierProvider<PendingInviteNotifier, IncomingCallDetails?>(PendingInviteNotifier.new);

class PendingInviteNotifier extends Notifier<IncomingCallDetails?> {
  Timer? _dismissTimer;

  @override
  IncomingCallDetails? build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return null;
  }

  void set(IncomingCallDetails? details) {
    _dismissTimer?.cancel();
    state = details;
    if (details != null) {
      _dismissTimer = Timer(const Duration(seconds: 30), () {
        if (state != null && state!.conversationId == details.conversationId) {
          state = null;
        }
      });
    }
  }
}

final userChannelSocketProvider = Provider.family<UserChannelSocket?, String>((ref, userId) {
  final token = ref.watch(accessTokenProvider);
  if (token.isEmpty) return null;
  final socket = UserChannelSocket(
    userId: userId,
    token: token,
    onIncomingCall: (details) {
      // Surface ringing/late-join invites; the overlay decides what to show.
      ref.read(pendingInviteProvider.notifier).set(details);
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
