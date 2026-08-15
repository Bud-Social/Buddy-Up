import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/env/env.dart';

class IncomingCallDetails {
  final String conversationId;
  final String callType;
  final String fromUserId;
  final String fromName;
  final String fromAvatar;
  final Map<String, dynamic> data;

  const IncomingCallDetails({
    required this.conversationId,
    required this.callType,
    required this.fromUserId,
    required this.fromName,
    required this.fromAvatar,
    required this.data,
  });
}

/// Global user-channel socket (`ws/user/<user_id>/`) that surfaces events
/// pushed to the signed-in user while they are anywhere in the app, most
/// importantly `incoming_call` offers.
class UserChannelSocket {
  final String userId;
  String _token;
  final void Function(IncomingCallDetails details) onIncomingCall;
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _intentionalClose = false;
  bool _disposed = false;

  UserChannelSocket({
    required this.userId,
    required String token,
    required this.onIncomingCall,
  }) : _token = token;

  void updateToken(String newToken) {
    if (_token == newToken) return;
    _token = newToken;
    if (!_intentionalClose && !_disposed) {
      _disconnectChannel();
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
    final url = '${Env.wsBaseUrl}/ws/user/$userId/?token=$_token';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            if (decoded['type'] == 'incoming_call' && !_disposed) {
              onIncomingCall(IncomingCallDetails(
                conversationId: decoded['conversation_id'] as String? ?? '',
                callType: decoded['call_type'] as String? ?? 'audio',
                fromUserId: decoded['from_user_id'] as String? ?? '',
                fromName: decoded['from_display_name'] as String? ?? '',
                fromAvatar: decoded['from_avatar_url'] as String? ?? '',
                data: decoded['data'] as Map<String, dynamic>? ?? {},
              ));
            }
          } catch (_) {}
        },
        onDone: () => _scheduleReconnect(),
        onError: (_) => _scheduleReconnect(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    final delay = Duration(
      seconds: (1000 * (1 << _reconnectAttempts.clamp(0, 5)) ~/ 1000).clamp(1, 30),
    );
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _doConnect);
  }

  void _disconnectChannel() {
    _reconnectTimer?.cancel();
    _intentionalClose = true;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _disconnectChannel();
  }
}