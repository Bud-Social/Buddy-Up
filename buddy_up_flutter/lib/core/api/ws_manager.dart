import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef WsMessageHandler = void Function(Map<String, dynamic> data);

class WsConnection {
  final String _path;
  String _token;
  WebSocket? _ws;
  final List<WsMessageHandler> _handlers = [];
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;

  WsConnection(this._path, this._token);

  String get path => _path;
  String get token => _token;

  void updateToken(String newToken) {
    if (_token == newToken) return;
    _token = newToken;
    if (!_intentionalClose) {
      disconnect();
      _reconnectAttempts = 0;
      _doConnect();
    }
  }

  void connect() {
    _intentionalClose = false;
    _reconnectAttempts = 0;
    _doConnect();
  }

  void _doConnect() async {
    try {
      final uri = Uri.parse('$_path?token=$_token');
      _ws = await WebSocket.connect(uri.toString());

      _ws!.listen(
        (data) {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          for (final handler in _handlers) {
            handler(decoded);
          }
        },
        onDone: () {
          final closeCode = _ws?.closeCode ?? 1000;
          if (!_intentionalClose && closeCode != 4001 && closeCode != 4003
              && _reconnectAttempts < _maxReconnectAttempts) {
            final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(1, 30));
            _reconnectTimer = Timer(delay, () {
              _reconnectAttempts++;
              _doConnect();
            });
          }
        },
        onError: (_) {
          if (!_intentionalClose) {
            _ws?.close();
          }
        },
        cancelOnError: false,
      );
    } catch (_) {}
  }

  void send(Map<String, dynamic> data) {
    _ws?.add(jsonEncode(data));
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
    _ws?.close();
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

  void updateToken(String newToken) {
    for (final conn in _connections.values) {
      conn.updateToken(newToken);
    }
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
