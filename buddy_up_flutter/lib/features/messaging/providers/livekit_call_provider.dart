import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../../data/repositories/messaging_repository.dart';
import 'messaging_provider.dart';

enum LkCallPhase { idle, calling, inCall, ended }

/// One participant tile in the call grid.
class CallTile {
  final String identity; // user id
  final String name;
  final bool isLocal;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  /// Active video track to render (screen share wins over camera), if any.
  final lk.VideoTrack? videoTrack;

  const CallTile({
    required this.identity,
    required this.name,
    required this.isLocal,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.isScreenSharing,
    this.videoTrack,
  });
}

class LiveKitCallState {
  final LkCallPhase phase;
  final String callType; // 'audio' | 'video'
  final List<CallTile> tiles;
  final String? cameraError;
  final String? sessionId;
  final String conversationId;

  const LiveKitCallState({
    this.phase = LkCallPhase.idle,
    this.callType = 'audio',
    this.tiles = const [],
    this.cameraError,
    this.sessionId,
    this.conversationId = '',
  });

  LiveKitCallState copyWith({
    LkCallPhase? phase,
    String? callType,
    List<CallTile>? tiles,
    String? cameraError,
    bool clearCameraError = false,
    String? sessionId,
    String? conversationId,
  }) {
    return LiveKitCallState(
      phase: phase ?? this.phase,
      callType: callType ?? this.callType,
      tiles: tiles ?? this.tiles,
      cameraError: clearCameraError ? null : (cameraError ?? this.cameraError),
      sessionId: sessionId ?? this.sessionId,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  bool get isActive => phase == LkCallPhase.calling || phase == LkCallPhase.inCall;
}

/// Multi-party audio/video calls over the self-hosted LiveKit SFU.
///
/// Joining hits the membership-checked session API which returns a
/// short-lived token scoped to the conversation's room. The server ends the
/// session when the last participant leaves.
class LiveKitCallController extends Notifier<LiveKitCallState> {
  lk.Room? _room;
  lk.CancelListenFunc? _cancelEvents;
  int _attempt = 0;

  @override
  LiveKitCallState build() {
    ref.onDispose(_teardown);
    return const LiveKitCallState();
  }

  MessagingRepository get _repo => ref.read(messagingRepositoryProvider);

  void _rebuildTiles() {
    final room = _room;
    if (room == null) return;
    final local = room.localParticipant;
    final tiles = <CallTile>[
      if (local != null) _tileFor(local, isLocal: true),
      ...room.remoteParticipants.values.map((p) => _tileFor(p, isLocal: false)),
    ];
    state = state.copyWith(tiles: tiles);
  }

  CallTile _tileFor(lk.Participant? p, {required bool isLocal}) {
    if (p == null) {
      return const CallTile(
        identity: 'local', name: 'You', isLocal: true,
        isAudioEnabled: false, isVideoEnabled: false, isScreenSharing: false,
      );
    }
    lk.VideoTrack? video;
    final screenPub = p.getTrackPublicationBySource(lk.TrackSource.screenShareVideo);
    if (screenPub?.track is lk.VideoTrack && screenPub?.muted != true) {
      video = screenPub!.track as lk.VideoTrack;
    } else {
      final camPub = p.getTrackPublicationBySource(lk.TrackSource.camera);
      if (camPub?.track is lk.VideoTrack && camPub?.muted != true) {
        video = camPub!.track as lk.VideoTrack;
      }
    }
    return CallTile(
      identity: p.identity,
      name: p.name.isNotEmpty ? p.name : p.identity,
      isLocal: isLocal,
      isAudioEnabled: p.isMicrophoneEnabled(),
      isVideoEnabled: p.isCameraEnabled(),
      isScreenSharing: p.isScreenShareEnabled(),
      videoTrack: video,
    );
  }

  /// Start or join this conversation's call. Returns true when connected.
  Future<bool> join(String conversationId, String callType) async {
    if (state.isActive) return false;
    final attempt = ++_attempt;
    state = state.copyWith(
      phase: LkCallPhase.calling,
      callType: callType,
      conversationId: conversationId,
      clearCameraError: true,
    );

    Map<String, dynamic> creds;
    try {
      final res = await _repo.startOrJoinCallSession(conversationId, {'call_type': callType});
      creds = (res['data'] as Map<String, dynamic>);
    } catch (_) {
      _resetToIdle();
      return false;
    }
    if (attempt != _attempt) return false;

    final livekit = creds['livekit'] as Map<String, dynamic>?;
    final url = livekit?['url'] as String? ?? '';
    final token = livekit?['token'] as String? ?? '';
    if (url.isEmpty || token.isEmpty) {
      _resetToIdle();
      return false;
    }
    state = state.copyWith(sessionId: creds['session_id'] as String?);

    final room = lk.Room();
    _room = room;
    _cancelEvents = room.events.listen((event) {
      if (attempt != _attempt) return;
      if (event is lk.ParticipantConnectedEvent ||
          event is lk.ParticipantDisconnectedEvent ||
          event is lk.TrackSubscribedEvent ||
          event is lk.TrackUnsubscribedEvent ||
          event is lk.TrackMutedEvent ||
          event is lk.TrackUnmutedEvent ||
          event is lk.LocalTrackPublishedEvent ||
          event is lk.LocalTrackUnpublishedEvent ||
          event is lk.TrackPublishedEvent ||
          event is lk.TrackUnpublishedEvent) {
        _rebuildTiles();
      } else if (event is lk.RoomDisconnectedEvent) {
        if (attempt == _attempt) {
          _markEnded();
        }
      }
    });

    try {
      await room.connect(url, token);
    } catch (_) {
      await _teardown();
      _resetToIdle();
      return false;
    }
    if (attempt != _attempt) {
      try { await room.disconnect(); } catch (_) {}
      return false;
    }

    // Publish local media; video calls degrade to audio-only gracefully.
    final lp = room.localParticipant;
    if (lp != null) {
      try {
        if (callType == 'video') {
          await lp.setCameraEnabled(true);
          await lp.setMicrophoneEnabled(true);
        } else {
          await lp.setMicrophoneEnabled(true);
        }
      } catch (_) {
        try {
          await lp.setMicrophoneEnabled(true);
          state = state.copyWith(cameraError: 'Camera unavailable');
        } catch (_) {
          state = state.copyWith(cameraError: 'Microphone unavailable — joined listen-only');
        }
      }
    }

    _rebuildTiles();
    state = state.copyWith(phase: LkCallPhase.inCall);
    return true;
  }

  Future<void> leave() async {
    final convoId = state.conversationId;
    await _teardown();
    _markEnded();
    if (convoId.isNotEmpty) {
      try {
        await _repo.leaveCallSession(convoId);
      } catch (_) {}
    }
    ref.read(callProvider.notifier).endCall();
  }

  Future<void> toggleMute() async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    try { await lp.setMicrophoneEnabled(!lp.isMicrophoneEnabled()); } catch (_) {}
    _rebuildTiles();
  }

  Future<void> toggleCamera() async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    try { await lp.setCameraEnabled(!lp.isCameraEnabled()); } catch (_) {}
    _rebuildTiles();
  }

  Future<void> toggleScreenShare() async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    try { await lp.setScreenShareEnabled(!lp.isScreenShareEnabled()); } catch (_) {}
    _rebuildTiles();
  }

  void _resetToIdle() {
    state = LiveKitCallState(
      callType: state.callType,
      conversationId: state.conversationId,
    );
  }

  void _markEnded() {
    state = state.copyWith(phase: LkCallPhase.ended);
    Timer(const Duration(milliseconds: 1500), () {
      if (state.phase == LkCallPhase.ended && _room == null) _resetToIdle();
    });
  }

  Future<void> _teardown() async {
    _attempt++;
    try { _cancelEvents?.call(); } catch (_) {}
    _cancelEvents = null;
    try { await _room?.disconnect(); } catch (_) {}
    _room = null;
  }
}

final liveKitCallProvider =
    NotifierProvider<LiveKitCallController, LiveKitCallState>(LiveKitCallController.new);
