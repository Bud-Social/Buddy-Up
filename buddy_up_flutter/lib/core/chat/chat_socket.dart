import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/models/messaging.dart';
import '../env/env.dart';

/// Lifecycle of a chat socket, so a rejected handshake is visible to the UI
/// instead of an endless reconnect loop nobody can see.
enum ChatSocketStatus {
  connecting,

  /// Handshake completed (101) and the socket is live.
  connected,

  /// The server refused the token — close code 4001, or a handshake that was
  /// rejected outright (Daphne answers a pre-accept close with a bare 403).
  /// Retries pull the current token from secure storage first.
  authFailed,

  /// Close code 4003: not a participant of this conversation, or blocked by
  /// the peer. Retrying can never succeed, so the socket stays down.
  forbidden,

  /// Closed while live (network drop, server restart). Reconnects with backoff.
  disconnected,
}

/// Reads the access token the app is currently using.
///
/// Defaults to secure storage, which is where [ApiClient]'s Dio interceptor
/// writes every refreshed token — so a socket retry picks up a freshly
/// refreshed token instead of the one that was just rejected. Injectable so
/// tests (and platforms without the plugin) can supply their own.
typedef ChatSocketTokenReader = Future<String?> Function();

/// Opens the socket. Injectable so tests can drive handshake outcomes without
/// a live server.
typedef ChatSocketConnector = ChatSocketConnection Function(
  Uri uri,
  List<String> protocols,
);

/// The slice of a WebSocket this class actually uses.
///
/// Named explicitly rather than depending on [WebSocketChannel] throughout, so
/// the reconnect/auth policy can be exercised in tests without standing up a
/// real socket.
abstract interface class ChatSocketConnection {
  /// Completes when the handshake finished; errors when it was refused.
  Future<void> get ready;

  /// Close code the server sent. Stays null when the handshake was refused
  /// outright (daphne answers those with a bare 403 and no close frame).
  int? get closeCode;

  /// Inbound frames.
  Stream<Object?> get messages;

  /// Sends one text frame.
  void add(String frame);

  void close();
}

class _WebSocketConnection implements ChatSocketConnection {
  _WebSocketConnection(this._channel);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  int? get closeCode => _channel.closeCode;

  @override
  Stream<Object?> get messages => _channel.stream;

  @override
  void add(String frame) => _channel.sink.add(frame);

  @override
  void close() => _channel.sink.close();
}

ChatSocketConnection _connectOverTheWire(Uri uri, List<String> protocols) =>
    _WebSocketConnection(WebSocketChannel.connect(uri, protocols: protocols));

Future<String?> _readStoredAccessToken() async {
  try {
    return await const FlutterSecureStorage().read(key: 'access_token');
  } catch (_) {
    // Secure storage is unavailable (unit tests, unsupported desktop target).
    // Fall back to the token handed to the constructor.
    return null;
  }
}

class ChatSocket {
  /// Bounded so an auth failure that a token refresh cannot fix terminates
  /// instead of reconnecting forever in silence.
  static const int _maxAuthRetries = 3;

  final String conversationId;
  final ChatSocketTokenReader _tokenReader;
  final ChatSocketConnector _connector;
  String _token;
  ChatSocketConnection? _channel;
  final StreamController<ChatEvent> _eventController = StreamController<ChatEvent>.broadcast();
  final StreamController<ChatSocketStatus> _statusController = StreamController<ChatSocketStatus>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  int _authRetries = 0;
  bool _intentionalClose = false;
  bool _disposed = false;

  Stream<ChatEvent> get events => _eventController.stream;

  /// Handshake/auth outcome of the current attempt.
  Stream<ChatSocketStatus> get status => _statusController.stream;

  String get token => _token;

  ChatSocket({
    required this.conversationId,
    required String token,
    ChatSocketTokenReader? tokenReader,
    ChatSocketConnector? connector,
  })  : _token = token,
        _tokenReader = tokenReader ?? _readStoredAccessToken,
        _connector = connector ?? _connectOverTheWire;

  /// Handshake URL. The token is deliberately *not* here: a query string leaks
  /// into daphne access logs, proxy logs and referrers.
  @visibleForTesting
  static Uri socketUri(String wsBaseUrl, String conversationId) =>
      Uri.parse('$wsBaseUrl/ws/conversation/$conversationId/');

  /// Carries the token in `Sec-WebSocket-Protocol`, the same `['bearer', token]`
  /// pair the web client uses. `dart:io` sends no `Origin` header (it has no
  /// browser policy engine to attach one), which is why the server's Origin
  /// validator must tolerate an absent header.
  @visibleForTesting
  static List<String> bearerProtocols(String token) => ['bearer', token];

  void updateToken(String newToken) {
    if (_token == newToken) return;
    _token = newToken;
    _authRetries = 0;
    if (!_intentionalClose && !_disposed) {
      disconnect();
      _reconnectAttempts = 0;
      _doConnect();
    }
  }

  void connect() {
    if (_disposed) return;
    _intentionalClose = false;
    _reconnectAttempts = 0;
    _authRetries = 0;
    _doConnect();
  }

  void _doConnect() {
    if (_disposed) return;
    _emitStatus(ChatSocketStatus.connecting);

    // Guards against handling one terminal event twice: a rejected handshake
    // surfaces as an error on both `ready` and the message stream.
    var terminal = false;
    void onTerminal() {
      if (terminal) return;
      terminal = true;
      _handleTerminal();
    }

    final uri = socketUri(Env.wsBaseUrl, conversationId);
    final protocols = bearerProtocols(_token);
    final channel = _connector(uri, protocols);
    _channel = channel;

    channel.ready.then((_) {
      if (_disposed || terminal) return;
      _reconnectAttempts = 0;
      _emitStatus(ChatSocketStatus.connected);
    }, onError: (_) => onTerminal());

    channel.messages.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          final event = _parseEvent(decoded);
          if (event != null && !_disposed) {
            _eventController.add(event);
          }
        } catch (_) {}
      },
      onDone: onTerminal,
      onError: (_) => onTerminal(),
      cancelOnError: false,
    );
  }

  /// A socket ended. The close code decides whether this is worth retrying and
  /// whether it is an auth problem at all.
  void _handleTerminal() {
    if (_disposed || _intentionalClose) return;
    final code = _channel?.closeCode;
    // 4003: not a member / blocked. No token change can fix it, so stay down.
    if (code == 4003) {
      _emitStatus(ChatSocketStatus.forbidden);
      return;
    }
    // 4001: bad or expired token. `null` means the handshake itself was
    // rejected, which daphne reports as a bare 403 — treat it the same way
    // instead of retrying the same doomed credentials forever.
    if (code == 4001 || code == null) {
      unawaited(_retryWithFreshToken());
      return;
    }
    _emitStatus(ChatSocketStatus.disconnected);
    _scheduleReconnect();
  }

  Future<void> _retryWithFreshToken() async {
    _emitStatus(ChatSocketStatus.authFailed);
    if (_disposed || _intentionalClose) return;
    if (_authRetries >= _maxAuthRetries) return;
    _authRetries++;

    // Re-read the token the app is actually using now: ApiClient's Dio
    // interceptor refreshes on 401 and writes the new access token to secure
    // storage, so this picks that up rather than replaying a stale one.
    final fresh = await _tokenReader();
    if (_disposed || _intentionalClose) return;
    if (fresh != null && fresh.isNotEmpty) _token = fresh;

    _reconnectAttempts = 0;
    _doConnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (1000 * (1 << _reconnectAttempts.clamp(0, 5)) ~/ 1000).clamp(1, 30));
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _doConnect);
  }

  void _emitStatus(ChatSocketStatus value) {
    if (_disposed || _statusController.isClosed) return;
    _statusController.add(value);
  }

  ChatEvent? _parseEvent(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null) return null;
    switch (type) {
      case 'message':
        return ChatEvent.message(data: data['data'] as Map<String, dynamic>? ?? {});
      case 'typing_start':
        return ChatEvent.typingStart(
          userId: data['user_id'] as String? ?? '',
          username: data['username'] as String? ?? '',
          displayName: data['display_name'] as String? ?? '',
          avatarUrl: data['avatar_url'] as String? ?? '',
        );
      case 'typing_stop':
        return ChatEvent.typingStop(
          userId: data['user_id'] as String? ?? '',
          username: data['username'] as String? ?? '',
        );
      case 'read':
        return ChatEvent.read(
          conversationId: data['conversation_id'] as String? ?? '',
          readerId: data['reader_id'] as String? ?? '',
          messageId: data['message_id'] as String?,
          count: data['count'] as int? ?? 0,
        );
      case 'react':
        return ChatEvent.react(
          conversationId: data['conversation_id'] as String? ?? '',
          messageId: data['message_id'] as String? ?? '',
          reactions: (data['reactions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ?? {},
        );
      default:
        return null;
    }
  }

  void send(Map<String, dynamic> data) {
    _channel?.add(jsonEncode(data));
  }

  void sendMessagePayload(Map<String, dynamic> payload) {
    send({'type': 'message', 'data': payload});
  }

  void sendTypingStart() {
    send({'type': 'typing_start'});
  }

  void sendTypingStop() {
    send({'type': 'typing_stop'});
  }

  void sendRead(String? messageId) {
    send({'type': 'read', 'message_id': messageId});
  }

  void sendReact(String messageId, String emoji) {
    send({'type': 'react', 'message_id': messageId, 'emoji': emoji});
  }

  void sendCallSignal(String signalType, Map<String, dynamic> data, {String callType = 'audio'}) {
    send({'type': signalType, 'data': data, 'call_type': callType});
  }

  void disconnect() {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _channel?.close();
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _eventController.close();
    _statusController.close();
  }
}