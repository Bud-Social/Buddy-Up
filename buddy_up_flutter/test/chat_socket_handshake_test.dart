import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:buddy_up_flutter/core/chat/chat_socket.dart';

/// The handshake is the whole mobile contract, and it is easy to break without
/// any test noticing:
///
///  * The token must NOT ride in the query string — it leaks into daphne access
///    logs, proxy logs and referrers. It travels in `Sec-WebSocket-Protocol` as
///    `['bearer', token]`, the same carrier the web client uses, which is why
///    `messaging/auth.py` reads subprotocols before the `?token=` fallback.
///  * `dart:io` attaches no `Origin` header (there is no browser policy engine
///    to add one), so the server's Origin validator has to tolerate an absent
///    header. That is the backend's half; these tests pin the client half.
///  * A rejected handshake used to be an endless, invisible reconnect loop.
///    It now has to surface as an auth failure and stop, because the server
///    accepts-then-closes with a real 4001/4003 instead of a bare 403.
void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env.example', isOptional: true);
  });

  group('handshake construction', () {
    test('URL carries the conversation but never the token', () {
      final uri = ChatSocket.socketUri('wss://api.buddyup.app', 'conv-123');

      expect(uri.path, '/ws/conversation/conv-123/');
      expect(uri.query, isEmpty, reason: 'a token in the query string leaks into logs');
      expect(uri.toString(), isNot(contains('token')));
    });

    test('URL is built on the configured websocket base', () {
      expect(
        ChatSocket.socketUri('ws://localhost:8002', 'abc').toString(),
        'ws://localhost:8002/ws/conversation/abc/',
      );
    });

    test('token is carried in the bearer subprotocol pair', () {
      expect(ChatSocket.bearerProtocols('jwt-value'), ['bearer', 'jwt-value']);
    });

    test('a live connect sends the token as a subprotocol, not in the URL', () {
      final server = _FakeServer([_open()]);
      final socket = _socketFor(server, token: 'jwt-value');

      socket.connect();

      expect(server.uris.single.path, '/ws/conversation/conv-1/');
      expect(server.uris.single.toString(), isNot(contains('jwt-value')));
      expect(server.protocols.single, ['bearer', 'jwt-value']);
      socket.dispose();
    });

    test('a refreshed token is used on the next attempt', () {
      final server = _FakeServer([_open()]);
      final socket = _socketFor(server, token: 'old-token');

      socket.connect();
      socket.updateToken('new-token');

      expect(server.protocols.last, ['bearer', 'new-token']);
      expect(server.uris.every((uri) => uri.query.isEmpty), isTrue);
      socket.dispose();
    });
  });

  group('rejected handshake', () {
    test('4001 surfaces as an auth failure and retries with the stored token',
        () async {
      final server = _FakeServer([_closed(4001), _open()]);
      final socket = _socketFor(server, token: 'stale-token', stored: 'fresh-token');
      final statuses = <ChatSocketStatus>[];
      socket.status.listen(statuses.add);

      socket.connect();
      await server.idle(2);

      expect(statuses, contains(ChatSocketStatus.authFailed));
      expect(statuses, contains(ChatSocketStatus.connected));
      expect(socket.token, 'fresh-token');
      expect(server.protocols, [
        ['bearer', 'stale-token'],
        ['bearer', 'fresh-token'],
      ]);
      socket.dispose();
    });

    test('a handshake refused with 403 counts as an auth failure', () async {
      // Daphne answers a pre-accept close with a bare 403 and no close frame,
      // so `closeCode` is null. That must not become an infinite retry loop.
      final server = _FakeServer([_refused(), _open()]);
      final socket = _socketFor(server, token: 'bad-token', stored: 'fresh-token');
      final statuses = <ChatSocketStatus>[];
      socket.status.listen(statuses.add);

      socket.connect();
      await server.idle(2);

      expect(statuses, contains(ChatSocketStatus.authFailed));
      expect(socket.token, 'fresh-token');
      socket.dispose();
    });

    test('4003 surfaces as forbidden and is never retried', () async {
      final server = _FakeServer([_closed(4003)]);
      final socket = _socketFor(server, token: 'good-token');
      final statuses = <ChatSocketStatus>[];
      socket.status.listen(statuses.add);

      socket.connect();
      await server.idle(1);
      await pumpEventQueue();

      expect(statuses, contains(ChatSocketStatus.forbidden));
      expect(server.attempts, 1, reason: 'retrying a non-member can never succeed');
      socket.dispose();
    });

    test('auth retries are bounded instead of looping silently', () async {
      final server = _FakeServer([_closed(4001)]);
      final socket = _socketFor(server, token: 'stale-token', stored: 'stale-token');
      final statuses = <ChatSocketStatus>[];
      socket.status.listen(statuses.add);

      socket.connect();
      await server.idle(4);
      await pumpEventQueue();

      // One initial attempt plus a bounded number of token retries, then it
      // stops. The previous implementation reconnected forever with no
      // terminal state any caller could observe.
      expect(server.attempts, 4);
      expect(
        statuses.where((s) => s == ChatSocketStatus.authFailed).length,
        4,
        reason: 'every attempt reports an auth failure, not a silent retry',
      );
      // Nothing further is attempted after the budget is spent.
      await server.idle(5, wait: const Duration(milliseconds: 100));
      expect(server.attempts, 4);
      socket.dispose();
    });
  });

  group('dropped live socket', () {
    test('a network drop reconnects and reports connected', () async {
      final server = _FakeServer([_closed(1006), _open()]);
      final socket = _socketFor(server, token: 'good-token');
      final statuses = <ChatSocketStatus>[];
      socket.status.listen(statuses.add);

      socket.connect();
      await server.idle(
        2,
        wait: const Duration(milliseconds: 1500),
      );

      expect(statuses, contains(ChatSocketStatus.disconnected));
      expect(statuses, contains(ChatSocketStatus.connected));
      expect(server.attempts, 2, reason: 'a network drop must be retried');
      socket.dispose();
    });
  });
}

ChatSocket _socketFor(
  _FakeServer server, {
  required String token,
  String? stored,
}) =>
    ChatSocket(
      conversationId: 'conv-1',
      token: token,
      tokenReader: () async => stored ?? token,
      connector: server.connect,
    );

/// What the fake server does with a single connection attempt.
class _Outcome {
  const _Outcome({this.closeCode, this.refuse = false});

  /// Close frame sent immediately after accepting — the shape `ChatConsumer`
  /// now produces for its reject paths.
  final int? closeCode;

  /// The handshake is answered with 403 and never reaches "accepted".
  final bool refuse;
}

_Outcome _open() => const _Outcome();

_Outcome _closed(int code) => _Outcome(closeCode: code);

_Outcome _refused() => const _Outcome(refuse: true);

/// Stands in for daphne: completes (or refuses) the handshake, applies the
/// configured outcome, and records what every attempt was sent.
class _FakeServer {
  _FakeServer(this.outcomes);

  final List<_Outcome> outcomes;
  final List<Uri> uris = <Uri>[];
  final List<List<String>> protocols = <List<String>>[];
  int attempts = 0;

  ChatSocketConnection connect(Uri uri, List<String> protocols) {
    uris.add(uri);
    this.protocols.add(protocols);
    final outcome =
        attempts < outcomes.length ? outcomes[attempts] : outcomes.last;
    attempts++;
    return _FakeConnection(
      handshakeError: outcome.refuse ? StateError('403 Access denied') : null,
      serverCloseCode: outcome.closeCode,
    );
  }

  /// Waits until [attempts] connections have been made.
  Future<void> idle(
    int attempts, {
    Duration wait = const Duration(milliseconds: 200),
  }) async {
    final deadline = DateTime.now().add(wait);
    while (this.attempts < attempts && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }
}

/// Reproduces the two shapes a handshake can end in: completed (optionally
/// followed by a close frame), or refused — where `ready` errors and the
/// message stream errors then closes, exactly as a real channel does.
class _FakeConnection implements ChatSocketConnection {
  _FakeConnection({this.handshakeError, this.serverCloseCode}) {
    if (handshakeError != null) {
      _ready.completeError(handshakeError!);
      _messages.addError(handshakeError!);
      _messages.close();
    } else {
      _ready.complete();
      if (serverCloseCode != null) {
        _closeCode = serverCloseCode;
        _messages.close();
      }
    }
  }

  final Object? handshakeError;
  final int? serverCloseCode;
  int? _closeCode;

  final StreamController<Object?> _messages = StreamController<Object?>();
  final Completer<void> _ready = Completer<void>();

  @override
  Future<void> get ready => _ready.future;

  @override
  int? get closeCode => _closeCode;

  @override
  Stream<Object?> get messages => _messages.stream;

  @override
  void add(String frame) {}

  @override
  void close() {}
}