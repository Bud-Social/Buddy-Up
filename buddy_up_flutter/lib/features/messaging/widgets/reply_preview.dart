import 'package:flutter/material.dart';
import '../../../data/models/messaging.dart';
import '../../../core/theme/app_theme.dart';

class ReplyPreview extends StatelessWidget {
  final Message message;
  final VoidCallback? onDismiss;

  const ReplyPreview({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: BuddyColors.surface,
        border: Border(top: BorderSide(color: BuddyColors.border)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 32, color: BuddyColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.senderData.displayName,
                  style: const TextStyle(color: BuddyColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  message.body.isNotEmpty ? message.body : _typeLabel(message.messageType),
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: BuddyColors.textSecondary),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'image': return '📷 Photo';
      case 'video': return '🎥 Video';
      case 'voice': return '🎤 Voice note';
      case 'file': return '📄 File';
      case 'location': return '📍 Location';
      default: return 'Message';
    }
  }
}
