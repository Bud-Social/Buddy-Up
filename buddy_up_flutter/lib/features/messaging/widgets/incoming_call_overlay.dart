import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/messaging_provider.dart';

class IncomingCallOverlay extends ConsumerWidget {
  final PendingCall pendingCall;

  const IncomingCallOverlay({super.key, required this.pendingCall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Material(
        color: BuddyColors.black.withValues(alpha: 0.95),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar(src: pendingCall.fromAvatarUrl, alt: pendingCall.fromDisplayName, size: AvatarSize.xl),
                const SizedBox(height: 16),
                Text(pendingCall.fromDisplayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  pendingCall.callType == 'video' ? 'Incoming video call...' : 'Incoming audio call...',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'accept',
                          backgroundColor: BuddyColors.green,
                          onPressed: () {
                            ref.read(callProvider.notifier).startCall(pendingCall.conversationId);
                          },
                          child: Icon(
                            pendingCall.callType == 'video' ? Icons.videocam : Icons.phone,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 48),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decline',
                          backgroundColor: BuddyColors.red,
                          onPressed: () {
                            ref.read(callProvider.notifier).setPendingCall(null);
                          },
                          child: const Icon(Icons.phone_disabled, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text('Decline', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
