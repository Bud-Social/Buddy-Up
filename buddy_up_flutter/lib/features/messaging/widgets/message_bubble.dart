import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import 'message_reaction_bar.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showSender;
  final void Function()? onReply;
  final void Function(String emoji)? onReact;
  final void Function()? onDelete;
  final void Function()? onForward;
  final Color? senderBubbleColor;
  final Color? receiverBubbleColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showSender = true,
    this.onReply,
    this.onReact,
    this.onDelete,
    this.onForward,
    this.senderBubbleColor,
    this.receiverBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !isMine)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 2),
              child: Text(
                message.senderData.displayName,
                style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMine && showSender)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Avatar(src: message.senderData.avatarUrl, alt: message.senderData.displayName, size: AvatarSize.xs),
                ),
              if (!isMine && !showSender) const SizedBox(width: 36),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showActions(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMine
                          ? (senderBubbleColor ?? BuddyColors.green.withValues(alpha: 0.15))
                          : (receiverBubbleColor ?? BuddyColors.surface),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMine ? 16 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 16),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.replyToId != null && message.replyData != null)
                          _buildReplyPreview(),
                        _buildContent(),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(color: isMine ? BuddyColors.textSecondary.withValues(alpha: 0.7) : BuddyColors.textSecondary, fontSize: 10),
                            ),
                            if (isMine) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead ? Icons.check_circle : Icons.check_circle_outline,
                                size: 12,
                                color: message.isRead ? BuddyColors.green : BuddyColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                        if (message.reactions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: MessageReactionBar(reactions: message.reactions),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMine ? BuddyColors.green.withValues(alpha: 0.1) : BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: BuddyColors.green, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.replyData!.senderName,
            style: const TextStyle(color: BuddyColors.green, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            message.replyData!.body.isNotEmpty ? message.replyData!.body : '📎 ${message.replyData!.messageType}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.messageType) {
      case 'text':
        return Text(
          message.body,
          style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15),
        );
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.mediaUrl,
            fit: BoxFit.cover,
            width: 200,
            height: 200,
            errorBuilder: (_, _, _) => Container(
              width: 200, height: 200,
              color: BuddyColors.surfaceRaised,
              child: const Icon(Icons.broken_image, color: BuddyColors.textSecondary),
            ),
          ),
        );
      case 'video':
        return Container(
          width: 200, height: 150,
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (message.mediaUrl.isNotEmpty)
                Image.network(message.mediaUrl, fit: BoxFit.cover, width: 200, height: 150,
                  errorBuilder: (_, _, _) => Container(color: BuddyColors.surfaceRaised),
                ),
              Container(
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
              ),
            ],
          ),
        );
      case 'file':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: BuddyColors.green, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.fileName.isNotEmpty ? message.fileName : 'File',
                    style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  if (message.mediaMime.isNotEmpty)
                    Text(message.mediaMime, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        );
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: BuddyColors.green, size: 20),
            const SizedBox(width: 8),
            Container(
              width: 100, height: 30,
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(width: 8),
            const Text('0:12', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
          ],
        );
      case 'location':
        return Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: BuddyColors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message.body.isNotEmpty ? message.body : 'Location',
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
              ),
            ],
          ),
        );
      case 'poll':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.poll, color: BuddyColors.green, size: 18),
              const SizedBox(height: 4),
              Text(message.body, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
            ],
          ),
        );
      default:
        return Text(message.body, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15));
    }
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: BuddyColors.textSecondary),
              title: const Text('Reply', style: TextStyle(color: BuddyColors.textPrimary)),
              onTap: () { Navigator.pop(context); onReply?.call(); },
            ),
            ListTile(
              leading: const Icon(Icons.forward, color: BuddyColors.textSecondary),
              title: const Text('Forward', style: TextStyle(color: BuddyColors.textPrimary)),
              onTap: () { Navigator.pop(context); onForward?.call(); },
            ),
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete, color: BuddyColors.red),
                title: const Text('Delete', style: TextStyle(color: BuddyColors.red)),
                onTap: () { Navigator.pop(context); onDelete?.call(); },
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat.jm().format(dt);
  }
}
