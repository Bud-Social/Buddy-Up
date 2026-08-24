import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/livekit_call_provider.dart';
import '../providers/messaging_provider.dart';
import '../screens/call_room_screen.dart';
import 'incoming_call_overlay.dart';

/// Root-level overlay host. Keeps the global user-channel socket alive for
/// incoming calls and stacks the ringing prompt / active call room above the
/// entire app.
class CallHost extends ConsumerWidget {
  final Widget child;
  const CallHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.user != null) {
      ref.watch(userChannelSocketProvider(authState.user!.id));
    }

    final callState = ref.watch(liveKitCallProvider);
    final invite = ref.watch(pendingInviteProvider);

    Widget? overlay;
    if (callState.phase == LkCallPhase.calling || callState.phase == LkCallPhase.inCall) {
      overlay = const Positioned.fill(child: CallRoomScreen());
    } else if (invite != null && callState.phase == LkCallPhase.idle) {
      overlay = const Positioned.fill(child: IncomingCallOverlay());
    }

    if (overlay == null) return child;

    return Stack(
      children: [
        child,
        overlay,
      ],
    );
  }
}
