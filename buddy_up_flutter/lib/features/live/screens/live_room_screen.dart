import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:async';
import '../providers/live_provider.dart';
import '../widgets/live_chat_overlay.dart';
import '../widgets/reaction_overlay.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/live.dart';

class LiveRoomScreen extends ConsumerStatefulWidget {
  final String liveId;

  const LiveRoomScreen({super.key, required this.liveId});

  @override
  ConsumerState<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends ConsumerState<LiveRoomScreen> {
  final bool _showChat = true;
  final bool _showGiftPicker = false;

  // Agora
  RtcEngine? _agoraEngine;
  bool _isUsingAgora = false;

  // LiveKit
  Room? _liveKitRoom;
  bool _isUsingLiveKit = false;

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _cleanup() async {
    if (_agoraEngine != null) {
      await _agoraEngine!.leaveChannel();
      await _agoraEngine!.release();
    }
    if (_liveKitRoom != null) {
      await _liveKitRoom!.disconnect();
      _liveKitRoom!.dispose();
    }
  }

  Future<void> _joinWithCredentials(LiveRoomData roomData) async {
    final creds = roomData.credentials;

    if (creds.agora.appId.isNotEmpty && creds.agora.channel.isNotEmpty) {
      await _joinAgora(creds.agora);
    } else if (creds.livekit.url.isNotEmpty && creds.livekit.room.isNotEmpty) {
      await _joinLiveKit(creds.livekit);
    }
  }

  Future<void> _joinAgora(AgoraCredentials creds) async {
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine!.initialize(RtcEngineContext(appId: creds.appId));

    _agoraEngine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (_, _) {
        setState(() => _isUsingAgora = true);
      },
      onUserJoined: (_, _, _) => setState(() {}),
      onUserOffline: (_, _, _) => setState(() {}),
    ));

    await _agoraEngine!.enableVideo();
    await _agoraEngine!.startPreview();
    await _agoraEngine!.joinChannel(
      token: creds.token ?? '',
      channelId: creds.channel,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Future<void> _joinLiveKit(LiveKitCredentials creds) async {
    final room = Room();
    _liveKitRoom = room;

    await room.connect(creds.url, creds.token);

    if (creds.canPublish) {
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);
    }

    setState(() => _isUsingLiveKit = true);
  }

  @override
  Widget build(BuildContext context) {
    final roomDataAsync = ref.watch(liveDetailProvider(widget.liveId));

    return Scaffold(
      body: roomDataAsync.when(
        loading: () => const PageLoader(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(liveDetailProvider(widget.liveId))),
        data: (live) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ReactionOverlay(
                    child: Stack(
                      children: [
                        _buildVideoView(live),
                        _buildOverlay(live),
                      ],
                    ),
                  ),
                ),
                if (_showChat)
                  SizedBox(
                    height: 250,
                    child: LiveChatOverlay(liveId: widget.liveId, token: ''),
                  ),
              ],
            ),
            floatingActionButton: _showGiftPicker ? null : null,
          );
        },
      ),
    );
  }

  Widget _buildVideoView(BuddyLive live) {
    if (_isUsingAgora && _agoraEngine != null) {
      return Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _agoraEngine!,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          Positioned(
              top: 60,
              right: 12,
              child: SizedBox(
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _agoraEngine!,
                      canvas: const VideoCanvas(uid: 1),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (_isUsingLiveKit && _liveKitRoom != null) {
      final remoteParticipants = _liveKitRoom!.remoteParticipants.values.toList();
      return Stack(
        children: [
          Container(color: BuddyColors.black, child: const Center(child: Text('LiveKit Stream'))),
          if (remoteParticipants.isNotEmpty)
            Positioned(
              top: 60,
              right: 12,
              child: SizedBox(
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(color: BuddyColors.surfaceRaised),
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      color: BuddyColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(src: live.host.avatarUrl, alt: live.host.displayName, size: AvatarSize.xl),
            const SizedBox(height: 16),
            Text(live.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('@${live.host.displayName}', style: const TextStyle(color: BuddyColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final repo = ref.read(liveRepositoryProvider);
                try {
                  final raw = await repo.joinLive(widget.liveId);
                  final roomData = LiveRoomData.fromJson(raw['data'] as Map<String, dynamic>);
                  await _joinWithCredentials(roomData);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join failed: $e')));
                  }
                }
              },
              icon: const Icon(Icons.videocam),
              label: const Text('Join Live'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuddyLive live) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  _cleanup();
                  Navigator.of(context).pop();
                },
              ),
              Avatar(src: live.host.avatarUrl, alt: live.host.displayName, size: AvatarSize.sm),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(live.host.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${live.viewerCount} watching', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const Spacer(),
              if (live.status == 'live')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BuddyColors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
