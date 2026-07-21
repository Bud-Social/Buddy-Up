import 'package:flutter/material.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final void Function(Comment)? onReply;
  final void Function(Comment, String)? onReact;
  final void Function(String)? onDelete;
  final bool isThreaded;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    this.onReact,
    this.onDelete,
    this.isThreaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isThreaded ? 40 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            src: comment.authorData.avatarUrl,
            alt: comment.authorData.displayName,
            size: AvatarSize.sm,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BuddyColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorData.displayName,
                        style: const TextStyle(
                          color: BuddyColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.body,
                        style: const TextStyle(
                          color: BuddyColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(comment.createdAt),
                      style: const TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (comment.replyCount > 0) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => onReply?.call(comment),
                        child: Text(
                          '${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => onReply?.call(comment),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: BuddyColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (comment.reactionCounts.isNotEmpty) ...[
                      const Spacer(),
                      ...comment.reactionCounts.entries.take(3).map((e) =>
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '${e.key} ${e.value}',
                            style: const TextStyle(
                              color: BuddyColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}
