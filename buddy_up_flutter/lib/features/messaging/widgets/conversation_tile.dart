import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ConversationTile({super.key, required this.conversation, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGroup = conversation.isGroup;
    final displayName = isGroup
        ? (conversation.groupName.isNotEmpty ? conversation.groupName : 'Group')
        : (conversation.participantsData.isNotEmpty
            ? conversation.participantsData.first.displayName
            : 'Unknown');
    final avatarUrl = isGroup
        ? conversation.groupAvatarUrl
        : (conversation.participantsData.isNotEmpty
            ? conversation.participantsData.first.avatarUrl
            : null);
    final lastMsg = conversation.lastMessage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: BuddyColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Avatar(src: avatarUrl, alt: displayName, size: AvatarSize.lg),
                if (!isGroup && conversation.participantsData.isNotEmpty)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BuddyColors.green,
                        border: Border.all(color: BuddyColors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: BuddyColors.textPrimary,
                            fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg != null
                              ? '${lastMsg.senderName.isNotEmpty ? '${lastMsg.senderName}: ' : ''}${_messagePreview(lastMsg)}'
                              : 'No messages yet',
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? BuddyColors.textPrimary
                                : BuddyColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: BuddyColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                            style: const TextStyle(color: BuddyColors.black, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _messagePreview(LastMessageData msg) {
    switch (msg.messageType) {
      case 'image': return '📷 Photo';
      case 'video': return '🎥 Video';
      case 'voice': return '🎤 Voice note';
      case 'file': return '📄 ${msg.mediaUrl.split('/').last}';
      case 'location': return '📍 Location';
      case 'poll': return '📊 Poll';
      case 'event': return '📅 Event';
      default: return msg.body;
    }
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return DateFormat.E().format(dt);
    return DateFormat.Md().format(dt);
  }
}
