import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' show VideoTrackRenderer, VideoViewFit;

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../providers/livekit_call_provider.dart';
import '../providers/messaging_provider.dart';
import '../utils/conversation_identity.dart';
import '../../../core/auth/auth_provider.dart';

/// Full-screen multi-party LiveKit call room. Participant grid for N people,
/// camera-off placeholders with avatars, mute/camera/screen-share controls.
class CallRoomScreen extends ConsumerWidget {
  const CallRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveKitCallProvider);
    final conversations =
        ref.watch(conversationsProvider).conversations;
    final convo = conversations
        .where((c) => c.id == state.conversationId)
        .firstOrNull;
    final myUserId = ref.watch(authProvider).user?.id;
    final identity = ConversationIdentity.of(convo, myUserId);

    return Material(
      color: BuddyColors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (state.phase != LkCallPhase.inCall)
              Expanded(child: _PreCall(state: state, identity: identity))
            else ...[
              _StatusBar(state: state),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _ParticipantGrid(tiles: state.tiles),
                ),
              ),
              if (state.cameraError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
                  child: Text(
                    '${state.cameraError} — audio only',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                  ),
                ),
            ],
            _Controls(state: state),
          ],
        ),
      ),
    );
  }
}

class _PreCall extends StatelessWidget {
  final LiveKitCallState state;
  final ConversationIdentity identity;
  const _PreCall({required this.state, required this.identity});

  @override
  Widget build(BuildContext context) {
    final String label;
    switch (state.phase) {
      case LkCallPhase.calling:
        label = 'Calling...';
        break;
      case LkCallPhase.ended:
        label = 'Call ended';
        break;
      default:
        label = '';
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(src: identity.avatarUrl, alt: identity.name, size: AvatarSize.xl),
          const SizedBox(height: 20),
          Text(
            identity.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatusBar extends StatefulWidget {
  final LiveKitCallState state;
  const _StatusBar({required this.state});

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _elapsed {
    // Duration is approximated from when the room reached in-call; a
    // server-side started_at is available via the session API if needed.
    return '${widget.state.tiles.length} in call';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _elapsed,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ParticipantGrid extends StatelessWidget {
  final List<CallTile> tiles;
  const _ParticipantGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: BuddyColors.green),
      );
    }
    final cols = tiles.length <= 1 ? 1 : (tiles.length <= 4 ? 2 : 3);
    return GridView.builder(
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, i) => _Tile(tile: tiles[i]),
    );
  }
}

class _Tile extends StatelessWidget {
  final CallTile tile;
  const _Tile({required this.tile});

  @override
  Widget build(BuildContext context) {
    final hasVideo = tile.videoTrack != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade800, Colors.grey.shade900],
              ),
            ),
            child: hasVideo
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 1.4,
                      child: VideoTrackRenderer(tile.videoTrack!, fit: VideoViewFit.cover),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: BuddyColors.surfaceRaised,
                          backgroundImage: null,
                          child: Text(
                            tile.name.isNotEmpty ? tile.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.videocam_off,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tile.isLocal ? 'You' : tile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                if (!tile.isAudioEnabled) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.mic_off, size: 13, color: Colors.redAccent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  final LiveKitCallState state;
  const _Controls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(liveKitCallProvider.notifier);
    final localTile = state.tiles.where((t) => t.isLocal).firstOrNull;
    final isMuted = localTile != null && !localTile.isAudioEnabled;
    final isCameraOff = localTile == null || !localTile.isVideoEnabled;
    final isVideo = state.callType == 'video';
    final inCall = state.phase == LkCallPhase.inCall;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18,
        runSpacing: 10,
        children: [
          _ControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            color: isMuted ? BuddyColors.green : Colors.white24,
            onTap: controller.toggleMute,
          ),
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: BuddyColors.red,
            iconColor: Colors.white,
            onTap: controller.leave,
          ),
          if (isVideo && inCall)
            _ControlButton(
              icon: Icons.videocam_off,
              label: isCameraOff ? 'Camera on' : 'Camera off',
              color: isCameraOff ? BuddyColors.green : Colors.white24,
              onTap: controller.toggleCamera,
            ),
          if (isVideo && inCall && !PlatformIsDesktop.current)
            _ControlButton(
              icon: Icons.screen_share,
              label: 'Share',
              color: Colors.white24,
              onTap: controller.toggleScreenShare,
            ),
        ],
      ),
    );
  }
}

/// Screen share requires platform support; gate on mobile for now.
class PlatformIsDesktop {
  static bool get current =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: color ?? Colors.white24,
          foregroundColor: iconColor ?? Colors.white,
          onPressed: onTap,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
