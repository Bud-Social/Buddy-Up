import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/models/messaging.dart';
import '../env/env.dart';

class ChatSocket {
  final String conversationId;
  String _token;
  WebSocketChannel? _channel;
  final StreamController<ChatEvent> _eventController = StreamController<ChatEvent>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _intentionalClose = false;
  bool _disposed = false;

  Stream<ChatEvent> get events => _eventController.stream;
  String get token => _token;

  ChatSocket({required this.conversationId, required String token}) : _token = token;

  void updateToken(String newToken) {
    if (_token == newToken) return;
    _token = newToken;
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
    _doConnect();
  }

  void _doConnect() {
    if (_disposed) return;
    final url = '${Env.wsBaseUrl}/ws/conversation/$conversationId/?token=$_token';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            final event = _parseEvent(decoded);
            if (event != null && !_disposed) {
              _eventController.add(event);
            }
          } catch (_) {}
        },
        onDone: () {
          if (!_intentionalClose && !_disposed) {
            _scheduleReconnect();
          }
        },
        onError: (_) {
          if (!_intentionalClose && !_disposed) {
            _scheduleReconnect();
          }
        },
      );
    } catch (_) {
      if (!_disposed) _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (1000 * (1 << _reconnectAttempts.clamp(0, 5)) ~/ 1000).clamp(1, 30));
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _doConnect);
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
      case 'call_offer':
        return ChatEvent.callOffer(
          callType: data['call_type'] as String? ?? 'audio',
          data: data['data'] as Map<String, dynamic>? ?? {},
        );
      case 'call_answer':
        return ChatEvent.callAnswer(
          callType: data['call_type'] as String? ?? 'audio',
          data: data['data'] as Map<String, dynamic>? ?? {},
        );
      case 'call_ice':
        return ChatEvent.callIce(data: data['data'] as Map<String, dynamic>? ?? {});
      case 'call_end':
        return const ChatEvent.callEnd();
      case 'call_decline':
        return const ChatEvent.callDecline();
      case 'call_ringing':
        return ChatEvent.callRinging(data: data['data'] as Map<String, dynamic>? ?? {});
      default:
        return null;
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
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
    _channel?.sink.close();
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _eventController.close();
  }
}
