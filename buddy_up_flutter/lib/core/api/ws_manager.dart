import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WsMessageHandler = void Function(Map<String, dynamic> data);

class WsConnection {
  final String _path;
  final String _token;
  WebSocketChannel? _channel;
  final List<WsMessageHandler> _handlers = [];
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;

  WsConnection(this._path, this._token);

  String get path => _path;

  void connect() {
    _intentionalClose = false;
    _reconnectAttempts = 0;
    _doConnect();
  }

  void _doConnect() {
    final uri = Uri.parse('$_path?token=$_token');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        for (final handler in _handlers) {
          handler(decoded);
        }
      },
      onDone: () {
        if (!_intentionalClose && _reconnectAttempts < _maxReconnectAttempts) {
          final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(1, 30));
          _reconnectTimer = Timer(delay, () {
            _reconnectAttempts++;
            _doConnect();
          });
        }
      },
      onError: (_) {
        if (!_intentionalClose) {
          _channel?.sink.close();
        }
      },
    );
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void addHandler(WsMessageHandler handler) {
    _handlers.add(handler);
  }

  void removeHandler(WsMessageHandler handler) {
    _handlers.remove(handler);
  }

  void disconnect() {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _handlers.clear();
  }
}

class WsManager {
  final Map<String, WsConnection> _connections = {};

  WsConnection connect(String path, String token) {
    final existing = _connections[path];
    if (existing != null) {
      existing.disconnect();
    }
    final conn = WsConnection(path, token);
    _connections[path] = conn;
    conn.connect();
    return conn;
  }

  void disconnect(String path) {
    _connections[path]?.disconnect();
    _connections.remove(path);
  }

  void disconnectAll() {
    for (final conn in _connections.values) {
      conn.disconnect();
    }
    _connections.clear();
  }
}
