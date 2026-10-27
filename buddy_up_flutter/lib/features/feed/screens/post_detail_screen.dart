import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/share_sheet.dart';
import '../widgets/comment_tile.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/toast.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: postAsync.when(
        loading: () => const PageLoader(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(postDetailProvider(widget.postId))),
        data: (post) => Column(
          children: [
            // A taken-down post used to 410 with no body and no explanation.
            // The creator could not read why their post was gone, and staff
            // could not review what they had just hidden.
            if (post.tombstone != null) _TombstoneBanner(tombstone: post.tombstone!),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PostCard(
                      post: post,
                      onReact: (id, reaction) => _handleReact(post, reaction),
                      onSave: (id) => _handleSave(post),
                      onShare: (_) => ShareSheet.show(context, post),
                      onDelete: (id) => _handleDelete(post.id),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: commentsAsync.when(
                        loading: () => const PageLoader(),
                        error: (e, _) => ErrorView(
                          message: e.toString(),
                          onRetry: () => ref.invalidate(commentsProvider(widget.postId)),
                        ),
                        data: (comments) {
                          if (comments.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'No comments yet. Be the first!',
                                  style: TextStyle(color: BuddyColors.textSecondary),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: comments.map((c) => CommentTile(
                              comment: c,
                              onReply: (_) {},
                              onReact: (_, _) {},
                            )).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: BuddyColors.black,
                border: Border(top: BorderSide(color: BuddyColors.border)),
              ),
              child: post.commentsDisabled
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_bank_outlined,
                            color: BuddyColors.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Comments are turned off for this post',
                          style: TextStyle(color: BuddyColors.textSecondary),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: BuddyInput(
                            controller: _commentController,
                            hint: 'Write a comment...',
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.send, color: BuddyColors.green),
                          onPressed: () => _submitTextComment(post.id),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.insert_emoticon, color: BuddyColors.textSecondary),
                          onPressed: () => _showCommentMediaSheet(post.id),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.image, color: BuddyColors.textSecondary),
                          onPressed: () => _pickImageComment(post.id),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReact(Post post, String reaction) async {
    if (reaction.isEmpty) return;
    final repo = ref.read(feedRepositoryProvider);
    try {
      await repo.react(post.id, ReactionInput(reactionType: reaction));
      ref.invalidate(postDetailProvider(widget.postId));
    } catch (_) {}
  }

  void _handleSave(Post post) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      if (post.isSaved) {
        await repo.unsave(post.id);
      } else {
        await repo.save(post.id, const SavePayload());
      }
      ref.invalidate(postDetailProvider(widget.postId));
    } catch (_) {}
  }

  void _handleDelete(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      await repo.deletePost(postId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {}
  }

  void _submitTextComment(String postId) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    final post = ref.read(postDetailProvider(postId)).value;
    if (post?.commentsDisabled ?? false) {
      showToast(context, 'Comments are turned off for this post');
      return;
    }
    final repo = ref.read(feedRepositoryProvider);
    try {
      await repo.addComment(postId, CommentCreateInput(body: body));
      _commentController.clear();
      ref.invalidate(commentsProvider(widget.postId));
    } catch (_) {}
  }

  void _showCommentMediaSheet(String postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add to comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                _MediaSheetOption(
                  icon: Icons.gif,
                  label: 'GIF',
                  color: BuddyColors.green,
                  onTap: () => _showStickerGifPicker(postId, 'gif'),
                ),
                _MediaSheetOption(
                  icon: Icons.sentiment_very_satisfied,
                  label: 'Sticker',
                  color: BuddyColors.red,
                  onTap: () => _showStickerGifPicker(postId, 'sticker'),
                ),
                _MediaSheetOption(
                  icon: Icons.image,
                  label: 'Photo',
                  color: BuddyColors.green,
                  onTap: () => _pickImageComment(postId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStickerGifPicker(String postId, String type) async {
    Navigator.of(context).pop();
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    await _submitMediaComment(postId, type, picked.path);
  }

  Future<void> _pickImageComment(String postId) async {
    Navigator.of(context).pop();
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    await _submitMediaComment(postId, 'image', picked.path);
  }

  Future<void> _submitMediaComment(String postId, String mediaType, String filePath) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final uploadResult = await repo.uploadCommentMedia(File(filePath), mediaType);
      final mediaUrl = uploadResult['url'] as String;
      final stickerPack = mediaType == 'sticker' ? 'default' : null;

      await repo.addComment(
        postId,
        CommentCreateInput(
          body: '',
          mediaType: mediaType,
          mediaUrl: mediaUrl,
          stickerPack: stickerPack,
        ),
      );
      ref.invalidate(commentsProvider(widget.postId));
    } catch (_) {
      if (mounted) showToast(context, 'Failed to upload comment media');
    }
  }
}

/// Why something is hidden, and how long it can still be appealed.
class _TombstoneBanner extends StatelessWidget {
  final PostTombstone tombstone;

  const _TombstoneBanner({required this.tombstone});

  @override
  Widget build(BuildContext context) {
    final days = tombstone.appealWindowDays;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_off_outlined,
                  size: 16, color: BuddyColors.gold),
              SizedBox(width: 8),
              Text(
                'Taken down by moderators',
                style: TextStyle(
                  color: BuddyColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (tombstone.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${tombstone.reason.replaceAll('_', ' ')}',
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
            ),
          ],
          if (tombstone.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              tombstone.note,
              style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12),
            ),
          ],
          if (days != null) ...[
            const SizedBox(height: 4),
            Text(
              days > 0
                  ? 'You can appeal this for another $days days.'
                  : 'The appeal window has closed.',
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single option in the comment media bottom sheet.
class _MediaSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaSheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: BuddyColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
