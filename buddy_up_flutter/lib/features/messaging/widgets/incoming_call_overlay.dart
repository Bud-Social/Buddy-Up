import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/messaging_provider.dart';

/// Full-screen incoming call prompt shown while a call is ringing
/// (phase = ringing). Accept answers the call; decline rejects it.
class IncomingCallOverlay extends ConsumerWidget {
  const IncomingCallOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(callSnapshotProvider);
    return Positioned.fill(
      child: Material(
        color: BuddyColors.black.withValues(alpha: 0.96),
        child: SafeArea(
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
              const SizedBox(height: 6),
              Text(
                call.callType == 'video'
                    ? 'Incoming video call...'
                    : 'Incoming audio call...',
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: call.callType == 'video'
                        ? Icons.videocam
                        : Icons.phone,
                    label: 'Accept',
                    color: BuddyColors.green,
                    onTap: () =>
                        ref.read(callEngineProvider).answerCall(
                              token: ref.read(accessTokenProvider),
                            ),
                  ),
                  const SizedBox(width: 48),
                  _ActionButton(
                    icon: Icons.phone_disabled,
                    label: 'Decline',
                    color: BuddyColors.red,
                    onTap: () => ref.read(callEngineProvider).declineIncoming(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: color,
          foregroundColor: Colors.white,
          onPressed: onTap,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}