import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/chat/chat_socket.dart';
import '../../../data/models/messaging.dart';

enum CallPhase { idle, calling, ringing, inCall, ended }

/// Global WebRTC call engine. One engine drives a single call at a time.
///
/// Signaling happens over `ChatSocket` (conversation channel). The engine is
/// socket-agnostic: whoever feeds it a socket (the chat screen while it is
/// open, or a lazily created socket when accepting from the global incoming
/// call overlay) becomes the signaling channel for the duration of the call.
class CallEngine extends ChangeNotifier {
  CallPhase phase = CallPhase.idle;
  String callType = 'audio';
  bool isMuted = false;
  bool isCameraOff = false;
  bool isInitiator = false;
  bool didDecline = false;
  String conversationId = '';
  String peerUserId = '';
  String peerName = '';
  String peerAvatar = '';
  DateTime? startedAt;

  MediaStream? localStream;
  MediaStream? remoteStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool renderersReady = false;

  RTCPeerConnection? _pc;
  ChatSocket? _socket;
  StreamSubscription<ChatEvent>? _socketSub;
  final List<RTCIceCandidate> _pendingIce = [];
  Map<String, dynamic>? _offer;
  bool _remoteDescSet = false;

  static const Map<String, dynamic> _pcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'iceCandidatePoolSize': 0,
  };

  bool get isActive =>
      phase == CallPhase.calling ||
      phase == CallPhase.ringing ||
      phase == CallPhase.inCall;

  /// Attach a signaling socket and keep a live subscription routing call
  /// events straight into the engine.
  void bind(ChatSocket socket) {
    _socketSub?.cancel();
    _socket = socket;
    _socketSub = socket.events.listen((event) {
      event.when(
        message: (data) {},
        typingStart: (a, b, c, d) {},
        typingStop: (a, b) {},
        read: (a, b, c, d) {},
        react: (a, b, c) {},
        callOffer: (t, data) => handleSignal('callOffer', data: data, callTypeFromEvent: t),
        callAnswer: (t, data) => handleSignal('callAnswer', data: data, callTypeFromEvent: t),
        callIce: (data) => handleSignal('callIce', data: data),
        callEnd: () => handleSignal('callEnd'),
        callDecline: () => handleSignal('callDecline'),
        callRinging: (data) => handleSignal('callRinging', data: data),
      );
    });
  }

  void detach() {
    _socketSub?.cancel();
    _socketSub = null;
    _socket = null;
  }

  /// Attach a signaling socket without subscribing. The caller (e.g. the chat
  /// screen) forwards decoded call events into [handleSignal] itself, avoiding
  /// double-handling when the same socket is also feeding its own UI.
  void attach(ChatSocket socket) {
    _socket = socket;
  }

  void setPeer({String userId = '', String name = '', String avatar = ''}) {
    peerUserId = userId;
    peerName = name;
    peerAvatar = avatar;
  }

  /// Outgoing call. The chat screen is open, so it supplies its socket.
  Future<void> startCall({
    required ChatSocket socket,
    required String conversationId,
    required String callType,
    required String peerName,
    required String peerAvatar,
    required String peerUserId,
  }) async {
    _reset();
    isInitiator = true;
    this.callType = callType;
    this.conversationId = conversationId;
    setPeer(userId: peerUserId, name: peerName, avatar: peerAvatar);
    attach(socket);
    phase = CallPhase.calling;
    notifyListeners();
    try {
      final pc = await _ensurePeer();
      await _ensureMedia(pc);
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      if (_offer != null) {
        _offer = null;
      }
      _socket?.sendCallSignal(
        'call_offer',
        {'sdp': offer.sdp, 'type': offer.type},
        callType: callType,
      );
    } catch (e) {
      debugPrint('CallEngine.startCall error: $e');
    }
  }

  /// Incoming call signalled from a conversation socket (chat screen open)
  /// or the global user channel.
  Future<void> incomingCall({
    required String conversationId,
    required String callType,
    required Map<String, dynamic> data,
    String fromUserId = '',
    String fromName = '',
    String fromAvatar = '',
  }) async {
    if (isActive) return;
    _reset();
    isInitiator = false;
    this.callType = callType;
    this.conversationId = conversationId;
    peerUserId = fromUserId;
    peerName = fromName;
    peerAvatar = fromAvatar;
    _offer = Map<String, dynamic>.from(data);
    phase = CallPhase.ringing;
    notifyListeners();
  }

  /// Accept the incoming call. `token` is used to lazily open a conversation
  /// socket when none is bound yet (e.g. answering from the global overlay).
  Future<void> answerCall({String? token}) async {
    if (!isActive || isInitiator) return;
    try {
      if (_socket == null && token != null && token.isNotEmpty) {
        final socket = ChatSocket(conversationId: conversationId, token: token);
        bind(socket);
        socket.connect();
      }
      final pc = await _ensurePeer();
      await _ensureMedia(pc);
      if (_offer != null) {
        await pc.setRemoteDescription(
          RTCSessionDescription(
            _offer!['type'] as String? ?? 'offer',
            _offer!['sdp'] as String? ?? '',
          ),
        );
        _offer = null;
        _remoteDescSet = true;
      }
      await _flushIce();
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      _socket?.sendCallSignal(
        'call_answer',
        {'sdp': answer.sdp, 'type': answer.type},
        callType: callType,
      );
      phase = CallPhase.inCall;
      startedAt = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('CallEngine.answerCall error: $e');
    }
  }

  void declineIncoming() {
    if (!isActive || isInitiator) return;
    didDecline = true;
    _socket?.sendCallSignal('call_decline', {});
    _teardown();
    phase = CallPhase.ended;
    notifyListeners();
  }

  void hangUp() {
    if (!isActive) {
      _teardown();
      phase = CallPhase.ended;
      notifyListeners();
      return;
    }
    _socket?.sendCallSignal('call_end', {});
    _teardown();
    phase = CallPhase.ended;
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted);
    notifyListeners();
  }

  void toggleCamera() {
    if (callType != 'video') return;
    isCameraOff = !isCameraOff;
    localStream?.getVideoTracks().forEach((t) => t.enabled = !isCameraOff);
    notifyListeners();
  }

  /// Route any decoded call signal into the engine regardless of origin.
  void handleSignal(
    String kind, {
    Map<String, dynamic>? data,
    String? callTypeFromEvent,
  }) {
    switch (kind) {
      case 'callOffer':
        if (isInitiator || isActive) return;
        incomingCall(
          conversationId: data?['conversation_id'] as String? ?? conversationId,
          callType: callTypeFromEvent ?? data?['call_type'] as String? ?? 'audio',
          data: data ?? {},
          fromUserId: data?['from_user_id'] as String? ?? '',
          fromName: data?['from_display_name'] as String? ?? '',
          fromAvatar: data?['from_avatar_url'] as String? ?? '',
        );
        break;
      case 'callAnswer':
        if (!isInitiator) return;
        _setRemoteAnswer(data?['sdp'] as String?);
        break;
      case 'callIce':
        _addIce(data);
        break;
      case 'callEnd':
      case 'callDecline':
        if (!isActive) return;
        didDecline = kind == 'callDecline';
        _teardown();
        phase = CallPhase.ended;
        notifyListeners();
        break;
      case 'callRinging':
        break;
      default:
        break;
    }
  }

  void _setRemoteAnswer(String? sdp) {
    if (sdp == null || _pc == null) return;
    _pc!.setRemoteDescription(RTCSessionDescription('answer', sdp)).then((_) {
      _remoteDescSet = true;
      _flushIce();
      if (phase == CallPhase.calling) {
        phase = CallPhase.inCall;
        startedAt = DateTime.now();
      }
      notifyListeners();
    }).catchError((_) {});
  }

  Future<void> _addIce(Map<String, dynamic>? data) async {
    if (data == null || _pc == null) return;
    final candidate = RTCIceCandidate(
      data['candidate'] as String? ?? '',
      data['sdpMid'] as String?,
      data['sdpMLineIndex'] as int?,
    );
    if (!_remoteDescSet) {
      _pendingIce.add(candidate);
      return;
    }
    await _pc!.addCandidate(candidate).catchError((_) {});
  }

  Future<void> _flushIce() async {
    for (final c in _pendingIce) {
      await _pc?.addCandidate(c).catchError((_) {});
    }
    _pendingIce.clear();
  }

  Future<RTCPeerConnection> _ensurePeer() async {
    if (_pc != null) return _pc!;
    final pc = await createPeerConnection(_pcConfig);
    pc.onIceCandidate = (candidate) {
      if (!_remoteDescSet) {
        _pendingIce.add(RTCIceCandidate(
          candidate.candidate ?? '',
          candidate.sdpMid,
          candidate.sdpMLineIndex,
        ));
        return;
      }
      _socket?.sendCallSignal('call_ice', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      }, callType: callType);
    };
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams.first;
        if (renderersReady) {
          remoteRenderer.srcObject = remoteStream;
        }
        notifyListeners();
      }
    };
    _pc = pc;
    return pc;
  }

  Future<void> _ensureMedia(RTCPeerConnection pc) async {
    if (localStream != null) return;
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': callType == 'video'
            ? {'facingMode': 'user', 'width': 1280, 'height': 720}
            : false,
      });
      localStream = stream;
      for (final track in stream.getTracks()) {
        pc.addTrack(track, stream);
      }
      if (callType == 'video' && !renderersReady) {
        await localRenderer.initialize();
        await remoteRenderer.initialize();
        renderersReady = true;
        localRenderer.srcObject = stream;
      }
      if (isMuted) {
        stream.getAudioTracks().forEach((t) => t.enabled = false);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('CallEngine._ensureMedia error: $e');
    }
  }

  void _reset() {
    _teardown();
    _pendingIce.clear();
    _offer = null;
    isMuted = false;
    isCameraOff = false;
    didDecline = false;
    startedAt = null;
    _remoteDescSet = false;
  }

  void _teardown() {
    _socketSub?.cancel();
    _socketSub = null;
    _socket = null;
    if (_pc != null) {
      _pc!.close();
      _pc = null;
    }
    if (renderersReady) {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    }
    if (localStream != null) {
      localStream!.getTracks().forEach((t) => t.stop());
      localStream = null;
    }
    remoteStream = null;
    renderersReady = false;
    _remoteDescSet = false;
  }

  @override
  void dispose() {
    _teardown();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }
}