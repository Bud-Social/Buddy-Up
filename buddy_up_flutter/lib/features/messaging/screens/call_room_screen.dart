import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../services/call_engine.dart';
import '../providers/messaging_provider.dart';

/// Full-screen call overlay shown whenever a call is active (outgoing/calling
/// or in-call). Mounted by the root call host (CallHost).
class CallRoomScreen extends ConsumerWidget {
  const CallRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(callSnapshotProvider);
    final inCall = call.phase == CallPhase.inCall;
    final isVideo = call.callType == 'video';

    return Material(
      color: BuddyColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            if (isVideo && inCall && call.remoteStream != null)
              Positioned.fill(
                child: RTCVideoView(
                  call.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            else
              _PeerIdentity(call: call),
            if (isVideo && inCall && call.localStream != null)
              Positioned(
                top: 16,
                right: 16,
                width: 110,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    call.localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: _StatusHeader(call: call),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _Controls(call: call),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeerIdentity extends StatelessWidget {
  final CallSnapshot call;
  const _PeerIdentity({required this.call});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(
            src: call.peerAvatar,
            alt: call.peerName,
            size: AvatarSize.xl,
          ),
          const SizedBox(height: 20),
          Text(
            call.peerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatefulWidget {
  final CallSnapshot call;
  const _StatusHeader({required this.call});

  @override
  State<_StatusHeader> createState() => _StatusHeaderState();
}

class _StatusHeaderState extends State<_StatusHeader> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.call.phase == CallPhase.inCall) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final String status;
    switch (call.phase) {
      case CallPhase.calling:
        status = 'Calling...';
        break;
      case CallPhase.inCall:
        status = call.startedAt != null ? _elapsed(call.startedAt!) : '';
        break;
      case CallPhase.ended:
        status = call.didDecline ? 'Call declined' : 'Call ended';
        break;
      default:
        status = '';
    }
    return Text(
      status,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: BuddyColors.textSecondary,
        fontSize: 14,
      ),
    );
  }
}

String _elapsed(DateTime start) {
  final d = DateTime.now().difference(start);
  final m = '${d.inMinutes.remainder(60)}'.padLeft(2, '0');
  final s = '${d.inSeconds.remainder(60)}'.padLeft(2, '0');
  final hours = d.inHours > 0 ? '${'${d.inHours}'.padLeft(2, '0')}:' : '';
  return '$hours$m:$s';
}

class _Controls extends ConsumerWidget {
  final CallSnapshot call;
  const _Controls({required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCall = call.phase == CallPhase.inCall;
    final isVideo = call.callType == 'video';
    final engine = ref.read(callEngineProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (inCall)
          _ControlButton(
            icon: Icons.mic_off,
            label: call.isMuted ? 'Unmute' : 'Mute',
            color: call.isMuted ? BuddyColors.green : Colors.white24,
            onTap: engine.toggleMute,
          ),
        if (isVideo && inCall) ...[
          const SizedBox(width: 24),
          _ControlButton(
            icon: Icons.videocam_off,
            label: call.isCameraOff ? 'Camera on' : 'Camera off',
            color: call.isCameraOff ? BuddyColors.green : Colors.white24,
            onTap: engine.toggleCamera,
          ),
        ],
        const SizedBox(width: 24),
        _ControlButton(
          icon: Icons.call_end,
          label: call.isInitiator && call.phase == CallPhase.calling
              ? 'Cancel'
              : 'End',
          color: BuddyColors.red,
          iconColor: Colors.white,
          onTap: engine.hangUp,
        ),
      ],
    );
  }
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