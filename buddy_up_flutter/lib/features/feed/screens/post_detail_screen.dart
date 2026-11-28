import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/share_sheet.dart';
import '../widgets/comment_tile.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/toast.dart';
import '../../../shared/widgets/emoji_picker_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emoji_utils.dart';
import '../../../data/models/post.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/navigation/main_header.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// When set, the comment composer is in "reply" mode — tapping send
  /// creates a child comment under this parent.
  String? _replyToCommentId;
  String? _replyToDisplayName;

  static const _builtInStickers = [
    '💪',
    '🔥',
    '🏃',
    '🏋️',
    '🚴',
    '🧘',
    '🥇',
    '⚡',
    '🙌',
    '👏',
    '✅',
    '❤️',
    '🎯',
    '💯',
    '😎',
    '🤝',
  ];

  /// Comment IDs whose reply threads are expanded inline.
  final Set<String> _expandedReplies = {};

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
      appBar: const MainAppBar(title: 'Post'),
      body: postAsync.when(
        loading: () => const PageLoader(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(postDetailProvider(widget.postId)),
        ),
        data: (post) => Column(
          children: [
            // A taken-down post used to 410 with no body and no explanation.
            // The creator could not read why their post was gone, and staff
            // could not review what they had just hidden.
            if (post.tombstone != null)
              _TombstoneBanner(tombstone: post.tombstone!),
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
                    _TopReactions(counts: post.reactionCounts),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: commentsAsync.when(
                        loading: () => const PageLoader(),
                        error: (e, _) => ErrorView(
                          message: e.toString(),
                          onRetry: () =>
                              ref.invalidate(commentsProvider(widget.postId)),
                        ),
                        data: (comments) {
                          if (comments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'No comments yet. Be the first!',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: comments.map((c) {
                              final isExpanded = _expandedReplies.contains(
                                c.id,
                              );
                              final repliesAsync = isExpanded
                                  ? ref.watch(
                                      commentRepliesProvider((
                                        widget.postId,
                                        c.id,
                                      )),
                                    )
                                  : null;
                              return CommentTile(
                                comment: c,
                                onReply: (comment) => setState(() {
                                  _replyToCommentId = comment.id;
                                  _replyToDisplayName =
                                      comment.authorData.displayName;
                                }),
                                onReact: (comment, reaction) =>
                                    _handleCommentReact(comment, reaction),
                                onViewReplies: (comment) => setState(() {
                                  if (_expandedReplies.contains(comment.id)) {
                                    _expandedReplies.remove(comment.id);
                                  } else {
                                    _expandedReplies.add(comment.id);
                                  }
                                }),
                                isRepliesExpanded: isExpanded,
                                replies: isExpanded
                                    ? repliesAsync?.maybeWhen(
                                        data: (d) => d,
                                        orElse: () => null,
                                      )
                                    : null,
                              );
                            }).toList(),
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(
                  top: BorderSide(color: BuddyColors.border),
                ),
              ),
              child: post.commentsDisabled
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.messagesSquare,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Comments are turned off for this post',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_replyToCommentId != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BuddyColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Replying to @${_replyToDisplayName ?? ''}',
                                        style: const TextStyle(
                                          color: BuddyColors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _replyToCommentId = null;
                                          _replyToDisplayName = null;
                                        }),
                                        child: Icon(
                                          LucideIcons.x,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: BuddyInput(
                                controller: _commentController,
                                hint: _replyToCommentId != null
                                    ? 'Reply...'
                                    : 'Write a comment...',
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.send,
                                color: BuddyColors.green,
                              ),
                              onPressed: () => _submitTextComment(post.id),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: Icon(
                                LucideIcons.smile,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () async {
                                final emoji = await showEmojiPickerSheet(
                                  context,
                                );
                                if (emoji == null) return;
                                final text = _commentController.text;
                                final sel = _commentController.selection;
                                final start = sel.start < 0
                                    ? text.length
                                    : sel.start;
                                final end = sel.end < 0 ? text.length : sel.end;
                                _commentController.text =
                                    '${text.substring(0, start)}$emoji${text.substring(end)}';
                                _commentController.selection =
                                    TextSelection.collapsed(
                                      offset: start + emoji.length,
                                    );
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: Icon(
                                LucideIcons.image,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => _showCommentMediaSheet(post.id),
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

  void _handleReact(Post post, String reaction) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      if (reaction.isEmpty) {
        // Empty means "remove" — the chip strip's un-react path.
        if (post.userReaction == null) return;
        await repo.unreact(post.id);
      } else {
        await repo.react(
          post.id,
          ReactionInput(reactionType: toReactionEmoji(reaction)),
        );
      }
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

  void _handleCommentReact(Comment comment, String reaction) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      if (reaction.isEmpty) {
        await repo.unreactToComment(widget.postId, comment.id);
      } else {
        await repo.reactToComment(
          widget.postId,
          comment.id,
          ReactionInput(reactionType: toReactionEmoji(reaction)),
        );
      }
      ref.invalidate(commentsProvider(widget.postId));
      // If the comment's thread is expanded, refresh the replies too.
      if (_expandedReplies.contains(comment.id)) {
        ref.invalidate(commentRepliesProvider((widget.postId, comment.id)));
      }
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
      await repo.addComment(
        postId,
        CommentCreateInput(body: body, parentId: _replyToCommentId),
      );
      _commentController.clear();
      setState(() => _replyToCommentId = null);
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
            const Text(
              'Add to comment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MediaSheetOption(
                  icon: LucideIcons.image,
                  label: 'GIF',
                  color: BuddyColors.green,
                  onTap: () => _showStickerGifPicker(postId, 'gif'),
                ),
                _MediaSheetOption(
                  icon: LucideIcons.smile,
                  label: 'Sticker',
                  color: BuddyColors.red,
                  onTap: () => _showStickerGifPicker(postId, 'sticker'),
                ),
                _MediaSheetOption(
                  icon: LucideIcons.image,
                  label: 'Photo',
                  color: BuddyColors.green,
                  onTap: () => _pickImageComment(postId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStickerGifPicker(String postId, String type) async {
    Navigator.of(context).pop();
    if (type == 'sticker') {
      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BuddyUp stickers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 8,
                  shrinkWrap: true,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (final sticker in _builtInStickers)
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext, sticker),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sticker,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, '__custom__'),
                  icon: const Icon(LucideIcons.image),
                  label: const Text('Make a sticker from a photo'),
                ),
              ],
            ),
          ),
        ),
      );
      if (selected == null) return;
      if (selected == '__custom__') {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1024,
        );
        if (picked != null) {
          await _submitMediaComment(postId, 'sticker', picked.path);
        }
        return;
      }
      try {
        await ref
            .read(feedRepositoryProvider)
            .addComment(
              postId,
              CommentCreateInput(
                body: selected,
                mediaType: 'sticker',
                stickerPack: 'BuddyUp',
              ),
            );
        ref.invalidate(commentsProvider(widget.postId));
      } catch (_) {
        if (mounted) showToast(context, 'Could not send sticker');
      }
      return;
    }
    // Use the Instagram-style device gallery for GIFs. It includes animated
    // GIFs in the image view and gives the upload endpoint the original file,
    // so animation is preserved rather than reduced to a still frame.
    await _pickGifComment(postId);
  }

  Future<void> _pickGifComment(String postId) async {
    var submitted = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (pickerContext) => Dialog.fullscreen(
        child: GalleryMediaPicker(
          appBarLeadingWidget: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(pickerContext).pop(),
          ),
          pathList: (paths) async {
            if (submitted || paths.isEmpty) return;
            final asset = paths.first;
            final path = asset.path.isNotEmpty
                ? asset.path
                : asset.file?.path;
            if (path == null || path.isEmpty) return;
            submitted = true;
            Navigator.of(pickerContext).pop();
            await _submitMediaComment(postId, 'gif', path);
          },
          mediaPickerParams: MediaPickerParamsModel(
            singlePick: true,
            maxPickImages: 1,
            mediaType: GalleryMediaType.image,
            thumbnailQuality: ThumbnailQuality.high,
            appBarColor: Theme.of(context).colorScheme.surface,
            gridViewBgColor: Theme.of(context).colorScheme.surface,
            thumbnailBgColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            albumTextColor: Theme.of(context).colorScheme.onSurface,
            albumSelectTextColor: Theme.of(context).colorScheme.onSurface,
            albumSelectIconColor: Theme.of(context).colorScheme.onSurface,
            selectedCheckColor: Theme.of(context).colorScheme.onPrimary,
            selectedCheckBgColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
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

  Future<void> _submitMediaComment(
    String postId,
    String mediaType,
    String filePath,
  ) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final uploadResult = await repo.uploadCommentMedia(
        File(filePath),
        mediaType,
      );
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
              Icon(LucideIcons.eyeOff, size: 16, color: BuddyColors.gold),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
          if (tombstone.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              tombstone.note,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
          if (days != null) ...[
            const SizedBox(height: 4),
            Text(
              days > 0
                  ? 'You can appeal this for another $days days.'
                  : 'The appeal window has closed.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Web `PostDetailModal` reaction summary: the top three emoji glyphs followed
/// by the total count (and how many reactions are hidden behind them).
class _TopReactions extends StatelessWidget {
  final Map<String, int> counts;

  const _TopReactions({required this.counts});

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeReactionCounts(counts);
    final sorted = normalized.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const SizedBox.shrink();

    final total = sorted.fold<int>(0, (sum, e) => sum + e.value);
    final top = sorted.take(3).toList();
    final remaining = sorted.skip(3).fold<int>(0, (sum, e) => sum + e.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 22 + (top.length - 1) * 12.0,
            height: 20,
            child: Stack(
              children: [
                for (var i = 0; i < top.length; i++)
                  Positioned(
                    left: i * 12.0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: BuddyColors.surfaceRaised,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BuddyColors.surface,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        top[i].key,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$total reaction${total == 1 ? '' : 's'}'
              '${remaining > 0 ? ' (+$remaining more)' : ''}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
