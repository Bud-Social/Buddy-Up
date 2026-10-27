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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
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
                                if (comment.mediaType == 'text' && comment.body.isNotEmpty)
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
                          if (comment.mediaType != 'text') ...[
                            const SizedBox(width: 8),
                            _buildMediaPreview(context),
                          ],
                        ],
                      ),
                      if (comment.mediaType == 'sticker' && comment.stickerPack != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            comment.stickerPack!,
                            style: const TextStyle(
                              color: BuddyColors.textSecondary,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
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

  Widget _buildMediaPreview(BuildContext context) {
    final url = comment.mediaUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    final isGif = comment.mediaType == 'gif';
    final isSticker = comment.mediaType == 'sticker';
    final size = isSticker ? 40.0 : 56.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSticker
              ? BuddyColors.green.withValues(alpha: 0.3)
              : BuddyColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: BuddyColors.surfaceRaised,
            child: Icon(
              isGif ? Icons.gif : Icons.image,
              size: 20,
              color: BuddyColors.textSecondary,
            ),
          ),
        ),
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
