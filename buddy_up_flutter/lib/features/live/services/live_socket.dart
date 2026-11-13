import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/env/env.dart';

/// Chat line pushed by `/ws/live/<id>/` — mirrors the web's ChatMessage.
class LiveChatMessage {
  final String? userId;
  final String displayName;
  final String avatarUrl;
  final String message;
  final int timestamp;
  /// Marks a system line ("X joined the live") — rendered centered + muted.
  final String? system;
  final Map<String, dynamic>? gift;

  LiveChatMessage({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.message,
    required this.timestamp,
    this.system,
    this.gift,
  });

  factory LiveChatMessage.fromJson(Map<String, dynamic> j) => LiveChatMessage(
        userId: j['user_id'] as String?,
        displayName: (j['display_name'] ?? '') as String,
        avatarUrl: (j['avatar_url'] ?? '') as String,
        message: (j['message'] ?? '') as String,
        timestamp: (j['timestamp'] as num?)?.toInt() ?? 0,
        system: j['system'] as String?,
        gift: j['gift'] as Map<String, dynamic>?,
      );
}

class LiveReaction {
  final String userId;
  final String displayName;
  final String emoji;
  final int timestamp;

  LiveReaction({
    required this.userId,
    required this.displayName,
    required this.emoji,
    required this.timestamp,
  });

  factory LiveReaction.fromJson(Map<String, dynamic> j) => LiveReaction(
        userId: (j['user_id'] ?? '') as String,
        displayName: (j['display_name'] ?? '') as String,
        emoji: (j['emoji'] ?? '') as String,
        timestamp: (j['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      );
}

/// A timed audience poll — arrives over WS, votes go over HTTP.
class LivePoll {
  final String pollId;
  final String question;
  final List<String> options;
  final int durationSeconds;
  final String? endsAt;
  List<int>? tally;
  int totalVotes;
  int? yourVote;

  LivePoll({
    required this.pollId,
    required this.question,
    required this.options,
    required this.durationSeconds,
    this.endsAt,
    this.tally,
    this.totalVotes = 0,
    this.yourVote,
  });
}

/// Co-host ladder events surfaced from the live socket — the UI listens for
/// `cohostSeq` bumps and reads the latest payload.
class LiveCohostEvent {
  final String type;
  final Map<String, dynamic> data;

  const LiveCohostEvent({required this.type, required this.data});
}

/// A settled gift — artifact, quantity and who sent it. Surfaced so the UI
/// can burst for everyone in the room, including the sender.
class LiveGiftEvent {
  final String artifactType;
  final int quantity;
  final String senderId;
  final String senderName;
  final int total;

  const LiveGiftEvent({
    required this.artifactType,
    required this.quantity,
    required this.senderId,
    required this.senderName,
    required this.total,
  });
}

class LiveSocketState {
  final bool isConnected;
  final List<LiveChatMessage> chatMessages;
  final int viewerCount;
  final Map<String, int> giftTotals;
  final LivePoll? currentPoll;
  final bool feedbackPinned;
  /// Co-host ladder signal events — bumps on every request/invite/response/
  /// removal event so listeners can refresh without diffing payloads.
  final LiveCohostEvent? cohostEvent;
  final int cohostSeq;
  /// Bumps every time a reaction lands.
  final LiveReaction? lastReaction;
  final int reactionSeq;
  /// Bumps every time a gift settles — the room floats the burst.
  final LiveGiftEvent? lastGift;
  final int giftSeq;

  const LiveSocketState({
    this.isConnected = false,
    this.chatMessages = const [],
    this.viewerCount = 0,
    this.giftTotals = const {},
    this.currentPoll,
    this.feedbackPinned = false,
    this.cohostEvent,
    this.cohostSeq = 0,
    this.lastReaction,
    this.reactionSeq = 0,
    this.lastGift,
    this.giftSeq = 0,
  });

  LiveSocketState copyWith({
    bool? isConnected,
    List<LiveChatMessage>? chatMessages,
    int? viewerCount,
    Map<String, int>? giftTotals,
    LivePoll? currentPoll,
    bool clearPoll = false,
    bool? feedbackPinned,
    LiveCohostEvent? cohostEvent,
    int? cohostSeq,
    LiveReaction? lastReaction,
    int? reactionSeq,
    LiveGiftEvent? lastGift,
    int? giftSeq,
  }) {
    return LiveSocketState(
      isConnected: isConnected ?? this.isConnected,
      chatMessages: chatMessages ?? this.chatMessages,
      viewerCount: viewerCount ?? this.viewerCount,
      giftTotals: giftTotals ?? this.giftTotals,
      currentPoll: clearPoll ? null : (currentPoll ?? this.currentPoll),
      feedbackPinned: feedbackPinned ?? this.feedbackPinned,
      cohostEvent: cohostEvent ?? this.cohostEvent,
      cohostSeq: cohostSeq ?? this.cohostSeq,
      lastReaction: lastReaction ?? this.lastReaction,
      reactionSeq: reactionSeq ?? this.reactionSeq,
      lastGift: lastGift ?? this.lastGift,
      giftSeq: giftSeq ?? this.giftSeq,
    );
  }
}

/// Real `/ws/live/<id>/` client — same protocol as the web: token rides in
/// Sec-WebSocket-Protocol (['bearer', token]), never in the query string.
class LiveSocketNotifier extends Notifier<LiveSocketState> {
  LiveSocketNotifier(this.liveId);

  final String liveId;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  int _retries = 0;
  static const _maxRetries = 10;

  @override
  LiveSocketState build() {
    ref.onDispose(_teardown);
    _connect(liveId);
    return const LiveSocketState();
  }

  void _connect(String liveId) {
    final token = ref.read(accessTokenProvider);
    if (token.isEmpty) return;

    _teardown();
    final uri = Uri.parse('${Env.wsBaseUrl}/ws/live/$liveId/');
    final channel = WebSocketChannel.connect(uri, protocols: ['bearer', token]);
    _channel = channel;
    _sub = channel.stream.listen(
      _onMessage,
      onError: (_) => _scheduleReconnect(liveId),
      onDone: () => _scheduleReconnect(liveId),
      cancelOnError: false,
    );
  }

  void _scheduleReconnect(String liveId) {
    if (_channel == null) return; // disposed
    state = state.copyWith(isConnected: false);
    _retries += 1;
    if (_retries > _maxRetries) return;
    final delay = Duration(milliseconds: (1000 * (1 << (_retries - 1))).clamp(1000, 30000));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => _connect(liveId));
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final type = msg['type'] as String?;
    final data = msg['data'];
    switch (type) {
      case 'connected':
        if (data is Map && data['viewer_count'] != null) {
          state = state.copyWith(
            isConnected: true,
            viewerCount: (data['viewer_count'] as num).toInt(),
          );
        } else {
          state = state.copyWith(isConnected: true);
        }
        _retries = 0;
      case 'live_reaction':
        if (data is Map<String, dynamic> && data['emoji'] != null) {
          state = state.copyWith(
            lastReaction: LiveReaction.fromJson(data),
            reactionSeq: state.reactionSeq + 1,
          );
        }
      case 'live_cohost_invite':
      case 'live_cohost_request':
      case 'live_cohost_response':
      case 'live_cohost_removed':
        if (data is Map<String, dynamic>) {
          state = state.copyWith(
            cohostEvent: LiveCohostEvent(type: type!, data: data),
            cohostSeq: state.cohostSeq + 1,
          );
        }
      case 'live_chat':
        if (data is Map<String, dynamic>) {
          final line = LiveChatMessage.fromJson(data);
          state = state.copyWith(
            chatMessages: [...state.chatMessages.takeLast(99), line],
          );
        }
      case 'live_viewer_count':
        if (data is Map && data['count'] != null) {
          state = state.copyWith(viewerCount: (data['count'] as num).toInt());
        }
      case 'live_gift':
        if (data is Map) {
          if (data['totals'] is Map) {
            final totals = (data['totals'] as Map).map(
              (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
            );
            state = state.copyWith(giftTotals: totals);
          }
          if (data['gift'] is Map<String, dynamic>) {
            final g = data['gift'] as Map<String, dynamic>;
            state = state.copyWith(
              lastGift: LiveGiftEvent(
                artifactType: (g['artifact_type'] ?? 'gift').toString(),
                quantity: (g['quantity'] as num?)?.toInt() ?? 1,
                senderId: (g['sender_id'] ?? '').toString(),
                senderName: (g['sender_name'] ?? 'Anonymous').toString(),
                total: (g['total'] as num?)?.toInt() ?? 0,
              ),
              giftSeq: state.giftSeq + 1,
            );
          }
        }
      case 'live_poll':
        if (data is Map) {
          state = state.copyWith(
            currentPoll: LivePoll(
              pollId: (data['poll_id'] ?? '').toString(),
              question: (data['question'] ?? '').toString(),
              options: (data['options'] as List? ?? const []).map((e) => e.toString()).toList(),
              durationSeconds: (data['duration_seconds'] as num?)?.toInt() ?? 60,
              endsAt: data['ends_at'] as String?,
              totalVotes: 0,
            ),
          );
        }
      case 'live_poll_update':
        if (data is Map) {
          final pollId = (data['poll_id'] ?? '').toString();
          final current = state.currentPoll;
          if (current != null && current.pollId == pollId) {
            current.tally = (data['tally'] as List?)?.map((e) => (e as num?)?.toInt() ?? 0).toList();
            current.totalVotes = (data['total_votes'] as num?)?.toInt() ?? current.totalVotes;
            state = state.copyWith(currentPoll: current);
          }
        }
      case 'live_feedback_pin':
        if (data is Map) {
          state = state.copyWith(feedbackPinned: data['pinned'] == true);
        }
    }
  }

  void sendChat(String message, {Map<String, dynamic>? gift, Map<String, dynamic>? replyTo}) {
    _send({
      'type': 'chat',
      'data': {
        'message': message,
        'gift': ?gift,
        'reply_to': ?replyTo,
      },
    });
  }

  void sendReaction(String emoji) => _send({'type': 'reaction', 'data': {'emoji': emoji}});

  void sendGift(String artifactType, int quantity) =>
      _send({'type': 'gift', 'data': {'artifact_type': artifactType, 'quantity': quantity}});

  void sendFeedbackPin(bool pinned) =>
      _send({'type': 'feedback_pin', 'data': {'pinned': pinned}});

  /// Co-host ladder signalling relayed through the room — the web sends the
  /// same events; the host's invite/response lands on the invitee/requester.
  void sendCohostEvent(String type, Map<String, dynamic> data) =>
      _send({'type': type, 'data': data});

  void setPollVote(int option) {
    final poll = state.currentPoll;
    if (poll == null) return;
    state = state.copyWith(
      currentPoll: poll..yourVote = option,
    );
  }

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) return;
    if (channel.closeCode != null) return;
    channel.sink.add(jsonEncode(payload));
  }

  void _teardown() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
  }
}

extension on List<LiveChatMessage> {
  List<LiveChatMessage> takeLast(int n) =>
      length <= n ? this : sublist(length - n);
}

final liveSocketProvider =
    NotifierProvider.family<LiveSocketNotifier, LiveSocketState, String>(LiveSocketNotifier.new);

