import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/media_gallery.dart';
import '../../../shared/widgets/reaction_bar.dart';
import '../../../shared/widgets/toast.dart';
import '../../../core/theme/app_theme.dart';
import 'repost_indicator.dart';
import 'poll_widget.dart';
import 'ai_analysis_card.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final void Function(String postId)? onLike;
  final void Function(String postId)? onComment;
  final void Function(String postId)? onRepost;
  final void Function(String postId)? onSave;
  final void Function(String postId)? onShare;
  final void Function(String postId)? onDelete;
  final void Function(String postId)? onPin;
  final void Function(String postId, String reaction)? onReact;
  final void Function(String? username)? onProfileTap;
  final void Function(String postId, List<String> optionIds)? onPollVote;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onSave,
    this.onShare,
    this.onDelete,
    this.onPin,
    this.onReact,
    this.onProfileTap,
    this.onPollVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: BuddyColors.black,
        border: Border(bottom: BorderSide(color: BuddyColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isRepost)
            RepostIndicator(
              reposters: post.reposters,
              username: post.authorData.displayName,
              quoteBody: post.quoteBody,
            ),
          _buildHeader(context),
          if (post.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildBody(context),
          ],
          if (post.mediaUrls.isNotEmpty || post.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            MediaGallery(
              urls: post.mediaUrls,
              media: post.media.isEmpty ? null : post.media,
              postId: post.id,
            ),
          ],
          if (post.poll != null) ...[
            const SizedBox(height: 8),
            PollWidget(
              poll: post.poll!,
              postId: post.id,
              onVote: onPollVote,

            ),
          ],
          if (post.workoutLogData != null) ...[
            const SizedBox(height: 8),
            _buildWorkoutLog(context),
          ],
          if (post.mealData != null) ...[
            const SizedBox(height: 8),
            _buildMealData(context),
          ],
          if (post.progressData != null) ...[
            const SizedBox(height: 8),
            _buildProgressData(context),
          ],
          AiAnalysisCard(analysis: post.aiAnalysis),
          const SizedBox(height: 10),
          _buildActionBar(context),
          const SizedBox(height: 8),
          ReactionBar(
            counts: post.reactionCounts,
            userReaction: post.userReaction,
            onReact: (r) => onReact?.call(post.id, r),
            onUnreact: () => onReact?.call(post.id, ''),
          ),
          if (post.gymTagName != null) ...[
            const SizedBox(height: 6),
            _buildGymTag(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onProfileTap?.call(post.authorData.username),
          child: Avatar(
            src: post.authorData.avatarUrl,
            alt: post.authorData.displayName,
            size: AvatarSize.md,
            verificationStatus: post.authorData.verificationStatus,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onProfileTap?.call(post.authorData.username),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorData.displayName,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@${post.authorData.username}',
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          _formatTime(post.createdAt),
          style: const TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          color: BuddyColors.surface,
          icon: const Icon(Icons.more_horiz, color: BuddyColors.textSecondary, size: 20),
          onSelected: (value) {
            switch (value) {
              case 'save':
                onSave?.call(post.id);
              case 'pin':
                onPin?.call(post.id);
              case 'delete':
                onDelete?.call(post.id);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'save', child: Text('Save', style: TextStyle(color: BuddyColors.textPrimary))),
            if (post.isPinned)
              const PopupMenuItem(value: 'pin', child: Text('Unpin', style: TextStyle(color: BuddyColors.textPrimary))),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: BuddyColors.red))),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      post.body,
      style: const TextStyle(
        color: BuddyColors.textPrimary,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: post.userReaction != null ? Icons.favorite : Icons.favorite_border,
          color: post.userReaction != null ? BuddyColors.red : BuddyColors.textSecondary,
          label: _formatCount(post.reactionCounts.values.fold(0, (a, b) => a + b)),
          onTap: () => onReact?.call(post.id, 'fire'),
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(post.commentCount),
          onTap: () => _handleCommentTap(context),
        ),
        _ActionButton(
          icon: Icons.repeat,
          color: post.isRepostedByMe ? BuddyColors.green : BuddyColors.textSecondary,
          label: _formatCount(post.repostCount),
          onTap: () => onRepost?.call(post.id),
        ),
        _ActionButton(
          icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: post.isSaved ? BuddyColors.green : BuddyColors.textSecondary,
          onTap: () => onSave?.call(post.id),
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: () => onShare?.call(post.id),
        ),
      ],
    );
  }

  void _handleCommentTap(BuildContext context) {
    if (post.commentsDisabled) {
      showToast(context, 'Comments are turned off for this post');
      return;
    }
    onComment?.call(post.id);
  }

  Widget _buildWorkoutLog(BuildContext context) {    final data = post.workoutLogData!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: BuddyColors.green, size: 18),
              const SizedBox(width: 6),
              Text(
                data['exercise'] as String? ?? 'Workout',
                style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (data['sets'] != null || data['reps'] != null)
            Text(
              '${data['sets'] ?? '?'} sets × ${data['reps'] ?? '?'} reps',
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildMealData(BuildContext context) {
    final data = post.mealData!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: BuddyColors.green, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              data['meal'] as String? ?? 'Meal',
              style: const TextStyle(color: BuddyColors.textPrimary),
            ),
          ),
          if (data['calories'] != null)
            Text(
              '${data['calories']} cal',
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressData(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.trending_up, color: BuddyColors.green, size: 18),
          SizedBox(width: 6),
          Text(
            'Progress update',
            style: TextStyle(color: BuddyColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildGymTag() {
    return Row(
      children: [
        const Icon(Icons.fitness_center, size: 14, color: BuddyColors.green),
        const SizedBox(width: 4),
        Text(
          post.gymTagName!,
          style: const TextStyle(color: BuddyColors.green, fontSize: 12),
        ),
      ],
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
    return DateFormat.MMMd().format(dt);
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String? label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? BuddyColors.textSecondary),
            if (label != null && int.tryParse(label!) != 0) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: TextStyle(
                  color: color ?? BuddyColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
