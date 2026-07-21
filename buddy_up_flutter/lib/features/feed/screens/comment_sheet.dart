import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/comment_tile.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: BuddyColors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: BuddyColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.comment, color: BuddyColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Comments',
                      style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: commentsAsync.when(
                  loading: () => const PageLoader(),
                  error: (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(commentsProvider(widget.postId)),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: BuddyColors.textSecondary),
                        ),
                      );
                    }
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: comments.map((c) => CommentTile(
                        comment: c,
                        onReply: (_) {},
                      )).toList(),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: BuddyColors.black,
                  border: Border(top: BorderSide(color: BuddyColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BuddyInput(
                        controller: _commentController,
                        hint: 'Write a comment...',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: BuddyColors.green),
                      onPressed: () => _submitComment(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    final repo = ref.read(feedRepositoryProvider);
    try {
      await repo.addComment(widget.postId, CommentCreateInput(body: body));
      _commentController.clear();
      ref.invalidate(commentsProvider(widget.postId));
    } catch (_) {}
  }
}
