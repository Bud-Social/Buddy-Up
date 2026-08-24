import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../providers/livekit_call_provider.dart';
import '../providers/messaging_provider.dart';

/// Full-screen incoming call prompt shown while an invite is pending.
/// Accept joins the conversation's LiveKit session; decline dismisses it.
class IncomingCallOverlay extends ConsumerWidget {
  const IncomingCallOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(pendingInviteProvider);
    if (invite == null) return const SizedBox.shrink();

    Future<void> accept() async {
      final details = invite;
      ref.read(pendingInviteProvider.notifier).set(null);
      await ref.read(liveKitCallProvider.notifier).join(
            details.conversationId,
            details.callType,
          );
    }

    void decline() => ref.read(pendingInviteProvider.notifier).set(null);

    return Positioned.fill(
      child: Material(
        color: BuddyColors.black.withValues(alpha: 0.96),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Avatar(src: invite.fromAvatar, alt: invite.fromName, size: AvatarSize.xl),
              const SizedBox(height: 20),
              Text(
                invite.fromName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Incoming ${invite.callType == 'video' ? 'video' : 'audio'} call...',
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
                    icon: invite.callType == 'video' ? Icons.videocam : Icons.phone,
                    label: 'Accept',
                    color: BuddyColors.green,
                    onTap: () => accept(),
                  ),
                  const SizedBox(width: 48),
                  _ActionButton(
                    icon: Icons.phone_disabled,
                    label: 'Decline',
                    color: BuddyColors.red,
                    onTap: decline,
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
