import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/media_gallery.dart';
import '../../../shared/widgets/reaction_bar.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/feed_provider.dart';
import 'repost_indicator.dart';
import 'poll_widget.dart';
import 'ai_analysis_card.dart';

/// How long a card must stay mounted before it counts as a real view.
///
/// Mirrors the Bud Press 2000ms active-play gate. Without a
/// visibility-detector dependency the proxy is mount duration: ListView only
/// builds near-viewport cards, and disposal cancels the timer.
const _kViewFocusThreshold = Duration(seconds: 2);

/// Human labels for the backend ModerationReport.REPORT_REASONS values.
const _reportReasonLabels = <String, String>{
  'spam': 'Spam or scam',
  'harassment': 'Harassment or bullying',
  'hate_speech': 'Hate speech',
  'nudity': 'Nudity or sexual content',
  'adult_ungated': 'Adult content outside mature areas',
  'violence': 'Violence or danger',
  'misinformation': 'Misinformation',
  'impersonation': 'Impersonation',
  'other': 'Something else',
};

class PostCard extends ConsumerStatefulWidget {
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
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  Timer? _viewTimer;
  DateTime? _focusStart;
  String? _trackedPostId;
  bool _viewRecorded = false;

  Post get _post => widget.post;

  /// Engagement reflects the ORIGINAL on repost rows so counts never zero out.
  OriginalPostData? get _orig =>
      _post.isRepost ? _post.originalPostData : null;
  String get _targetId => _orig?.id ?? _post.id;
  Map<String, int> get _reactionCounts =>
      _orig?.reactionCounts ?? _post.reactionCounts;
  String? get _userReaction => _orig?.userReaction ?? _post.userReaction;
  int get _commentCount => _orig?.commentCount ?? _post.commentCount;
  int get _repostCount => _orig?.repostCount ?? _post.repostCount;
  int get _saveCount => _orig?.saveCount ?? _post.saveCount;
  int get _shareCount => _orig?.shareCount ?? _post.shareCount;
  int get _viewCount => _orig?.viewCount ?? _post.viewCount;

  @override
  void initState() {
    super.initState();
    _beginFocus();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _reportFocus();
      _beginFocus();
    }
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _reportFocus();
    super.dispose();
  }

  void _beginFocus() {
    _viewTimer?.cancel();
    _viewRecorded = false;
    _focusStart = DateTime.now();
    _trackedPostId = widget.post.id;
    _viewTimer = Timer(_kViewFocusThreshold, () {
      if (!mounted) return;
      _viewRecorded = true;
      ref.read(feedProvider.notifier).recordViewById(widget.post.id);
    });
  }

  /// Visibility-based focus time, reported on dispose/hide. Lightweight: a
  /// single track call, no per-frame work.
  void _reportFocus() {
    final start = _focusStart;
    _focusStart = null;
    if (start == null) return;
    final ms = DateTime.now().difference(start).inMilliseconds;
    if (ms < 250) return; // Ignore transient builds/recycled rows.
    AnalyticsService.instance.track(
      'feed.post_focus',
      surface: 'feed',
      objectType: 'post',
      objectId: _trackedPostId ?? widget.post.id,
      properties: {'focus_ms': ms, 'view_recorded': _viewRecorded},
    );
  }

  void _trackPostInteraction(String action) {
    AnalyticsService.instance.track(
      'feed.post_interaction',
      surface: 'feed',
      objectType: 'post',
      objectId: _targetId,
      properties: {'action': action},
    );
  }

  void _openPostMenu() {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(feedProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _PostMenuSheet(
        post: _post,
        targetId: _targetId,
        messenger: messenger,
        notifier: notifier,
        onSave: widget.onSave,
        onPin: widget.onPin,
        onDelete: widget.onDelete,
        onOpenReport: () => _openReportSheet(_post),
      ),
    );
  }

  void _openReportSheet(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReportSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewer = ref.watch(authProvider).profile;
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
          if (_post.isRepost)
            RepostIndicator(
              reposters: _post.reposters,
              username: _post.authorData.displayName,
              quoteBody: _post.quoteBody,
              viewerReposted: _post.isRepostedByMe,
              viewerAvatarUrl: viewer?.avatarUrl,
              viewerDisplayName: viewer?.displayName,
            ),
          _buildHeader(context),
          if (_post.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildBody(context),
          ],
          if (_post.mediaUrls.isNotEmpty || _post.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            MediaGallery(
              urls: _post.mediaUrls,
              media: _post.media.isEmpty ? null : _post.media,
              postId: _post.id,
            ),
          ],
          if (_post.poll != null) ...[
            const SizedBox(height: 8),
            PollWidget(
              poll: _post.poll!,
              postId: _post.id,
              onVote: widget.onPollVote,

            ),
          ],
          if (_post.workoutLogData != null) ...[
            const SizedBox(height: 8),
            _buildWorkoutLog(context),
          ],
          if (_post.mealData != null) ...[
            const SizedBox(height: 8),
            _buildMealData(context),
          ],
          if (_post.progressData != null) ...[
            const SizedBox(height: 8),
            _buildProgressData(context),
          ],
          AiAnalysisCard(analysis: _post.aiAnalysis),
          const SizedBox(height: 10),
          _buildActionBar(context),
          const SizedBox(height: 8),
          ReactionBar(
            counts: _reactionCounts,
            userReaction: _userReaction,
            onReact: (r) {
              _trackPostInteraction('like');
              widget.onReact?.call(_targetId, r);
            },
            onUnreact: () {
              _trackPostInteraction('unlike');
              widget.onReact?.call(_targetId, '');
            },
          ),
          if (_post.gymTagName != null) ...[
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
          onTap: () {
            _trackPostInteraction('profile');
            widget.onProfileTap?.call(_post.authorData.username);
          },
          child: Avatar(
            src: _post.authorData.avatarUrl,
            alt: _post.authorData.displayName,
            size: AvatarSize.md,
            verificationStatus: _post.authorData.verificationStatus,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _trackPostInteraction('profile');
              widget.onProfileTap?.call(_post.authorData.username);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _post.authorData.displayName,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@${_post.authorData.username}',
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
          _formatTime(_post.createdAt),
          style: const TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 14,
              color: BuddyColors.textSecondary,
            ),
            const SizedBox(width: 3),
            Text(
              _formatCount(_viewCount),
              key: const ValueKey('post-header-view-count'),
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz,
              color: BuddyColors.textSecondary, size: 20),
          tooltip: 'Post options',
          onPressed: _openPostMenu,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      _post.body,
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
          icon: _userReaction != null ? Icons.favorite : Icons.favorite_border,
          color: _userReaction != null ? BuddyColors.red : BuddyColors.textSecondary,
          label: _formatCount(_reactionCounts.values.fold(0, (a, b) => a + b)),
          onTap: () {
            _trackPostInteraction(
                _userReaction != null ? 'unlike' : 'like');
            widget.onReact?.call(_targetId, 'fire');
          },
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: _formatCount(_commentCount),
          onTap: () => _handleCommentTap(context),
        ),
        _ActionButton(
          icon: Icons.repeat,
          color: _post.isRepostedByMe ? BuddyColors.green : BuddyColors.textSecondary,
          label: _formatCount(_repostCount),
          onTap: () {
            _trackPostInteraction(
                _post.isRepostedByMe ? 'unrepost' : 'repost');
            widget.onRepost?.call(_post.id);
          },
        ),
        _ActionButton(
          icon: _post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: _post.isSaved ? BuddyColors.green : BuddyColors.textSecondary,
          label: _formatCount(_saveCount),
          onTap: () {
            _trackPostInteraction(_post.isSaved ? 'unsave' : 'save');
            widget.onSave?.call(_targetId);
          },
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.share_outlined,
          label: _formatCount(_shareCount),
          onTap: () {
            _trackPostInteraction('share');
            widget.onShare?.call(_post.id);
          },
        ),
      ],
    );
  }

  void _handleCommentTap(BuildContext context) {
    if (_post.commentsDisabled) {
      showToast(context, 'Comments are turned off for this post');
      return;
    }
    _trackPostInteraction('comment');
    AnalyticsService.instance.track(
      'feed.comment_focus',
      surface: 'feed',
      objectType: 'post',
      objectId: _targetId,
    );
    widget.onComment?.call(_targetId);
  }

  Widget _buildWorkoutLog(BuildContext context) {    final data = _post.workoutLogData!;
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
    final data = _post.mealData!;
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
          _post.gymTagName!,
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

/// Mobile-native post options sheet: engagement + moderation rows.
///
/// Legacy owner rows (save/pin/delete) render only when the host screen
/// passes those callbacks, preserving PostCard's previous popup behaviour.
class _PostMenuSheet extends ConsumerWidget {
  final Post post;
  final String targetId;
  final ScaffoldMessengerState messenger;
  final FeedNotifier notifier;
  final void Function(String postId)? onSave;
  final void Function(String postId)? onPin;
  final void Function(String postId)? onDelete;
  final VoidCallback onOpenReport;

  const _PostMenuSheet({
    required this.post,
    required this.targetId,
    required this.messenger,
    required this.notifier,
    this.onSave,
    this.onPin,
    this.onDelete,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Post live = post;
    for (final p in ref.watch(feedProvider).posts) {
      if (p.id == post.id) {
        live = p;
        break;
      }
    }
    final orig = live.isRepost ? live.originalPostData : null;
    final isLiked = (orig?.userReaction ?? live.userReaction) != null;
    final username = live.authorData.username;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BuddyColors.textSecondary,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuRow(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              label: isLiked ? 'Unlike' : 'Like',
              onTap: () {
                Navigator.of(context).pop();
                notifier.toggleReactionForRow(
                  rowId: post.id,
                  targetId: targetId,
                  emoji: 'fire',
                );
              },
            ),
            _MenuRow(
              icon: Icons.visibility_off,
              label: 'Not interested',
              subtitle: 'See fewer posts like this',
              onTap: () => _hidePost(context),
            ),
            _MenuRow(
              icon: Icons.flag_outlined,
              label: 'Report',
              subtitle: 'Report this post to moderators',
              onTap: () {
                Navigator.of(context).pop();
                onOpenReport();
              },
            ),
            _MenuRow(
              icon: Icons.block,
              label: 'Block @$username',
              subtitle: 'They won\'t be able to find or contact you',
              onTap: () => _confirmBlock(context, username),
            ),
            _MenuRow(
              icon: Icons.person_off_outlined,
              label: 'Don\'t suggest this creator',
              subtitle: 'Hide all posts from @$username',
              onTap: () => _muteAuthor(context, username),
            ),
            if (onSave != null)
              _MenuRow(
                icon: live.isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: live.isSaved ? 'Unsave' : 'Save',
                onTap: () {
                  Navigator.of(context).pop();
                  onSave!(targetId);
                },
              ),
            if (onPin != null)
              _MenuRow(
                icon: Icons.push_pin_outlined,
                label: live.isPinned ? 'Unpin' : 'Pin',
                onTap: () {
                  Navigator.of(context).pop();
                  onPin!(post.id);
                },
              ),
            if (onDelete != null)
              _MenuRow(
                icon: Icons.delete_outline,
                iconColor: BuddyColors.red,
                label: 'Delete',
                destructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!(post.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _hidePost(BuildContext context) async {
    Navigator.of(context).pop();
    final err = await notifier.hidePostById(post.id);
    if (err != null) {
      // Defensive path (e.g. 404 while the backend rolls out): the provider
      // restored the card, so only surface the server message.
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Post hidden. You\'ll see fewer like this.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final undoErr = await notifier.unhidePost(post);
            if (undoErr != null) {
              messenger.showSnackBar(SnackBar(content: Text(undoErr)));
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmBlock(BuildContext context, String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: Text(
          'Block @$username?',
          style: const TextStyle(color: BuddyColors.textPrimary),
        ),
        content: const Text(
          'They won\'t be able to find your profile or contact you. '
          'Their posts will be removed from your feed.',
          style: TextStyle(color: BuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Block',
                style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    final err = await notifier.blockAuthor(username);
    messenger.showSnackBar(
      SnackBar(
        content: Text(err ?? '@$username blocked.'),
      ),
    );
  }

  Future<void> _muteAuthor(BuildContext context, String username) async {
    Navigator.of(context).pop();
    final err = await notifier.muteAuthor(username);
    messenger.showSnackBar(
      SnackBar(
        content: Text(err ?? 'You won\'t see posts from @$username anymore.'),
      ),
    );
  }
}

/// Report flow: reason picker (backend REPORT_REASONS values) + optional
/// details, submitted to POST /moderation/reports/.
class _ReportSheet extends ConsumerStatefulWidget {
  final Post post;

  const _ReportSheet({required this.post});

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  String _reason = 'spam';
  final TextEditingController _details = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final notifier = ref.read(feedProvider.notifier);
    // target_user is a user PK server-side; fall back to the username when
    // the row didn't carry an id.
    final target = widget.post.authorData.userId?.isNotEmpty == true
        ? widget.post.authorData.userId!
        : widget.post.authorData.username;
    final err = await notifier.submitReport(
      targetUser: target,
      reason: _reason,
      description: _details.text.trim(),
      contentUrl: '/feed/${widget.post.id}',
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Thanks — our moderators will take a look.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post.authorData.username;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BuddyColors.textSecondary,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Report @$username\'s post',
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Why are you reporting this?',
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: RadioGroup<String>(
                  groupValue: _reason,
                  onChanged: (v) {
                    if (_submitting) return;
                    setState(() => _reason = v ?? _reason);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final reason in FeedNotifier.reportReasons)
                        RadioListTile<String>(
                          value: reason,
                          title: Text(
                            _reportReasonLabels[reason] ?? reason,
                            style: const TextStyle(
                              color: BuddyColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          activeColor: BuddyColors.green,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _details,
              enabled: !_submitting,
              maxLines: 2,
              maxLength: 1000,
              style: const TextStyle(color: BuddyColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Add details (optional)',
                hintStyle: TextStyle(color: BuddyColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: BuddyColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: BuddyColors.green),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Submitting…' : 'Submit report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final bool destructive;
  final VoidCallback? onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.subtitle,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: iconColor ?? BuddyColors.green),
      title: Text(
        label,
        style: TextStyle(
          color:
              destructive ? BuddyColors.red : BuddyColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 12,
              ),
            ),
      onTap: onTap,
    );
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
