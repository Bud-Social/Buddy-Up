import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emoji_utils.dart';
import '../../../core/utils/profanity.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/media_gallery.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/feed_provider.dart';
import '../../settings/providers/settings_providers.dart';
import 'repost_indicator.dart';
import 'gym_actor_identity.dart';
import '../../../features/gym/widgets/verified_gym_badge.dart';
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

  /// When the console acts as a gym, the repost ribbon renders the gym
  /// identity instead of the acting staff member's.
  final GymActorIdentity? gymActor;

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
    this.gymActor,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  Timer? _viewTimer;
  DateTime? _focusStart;
  String? _trackedPostId;
  bool _viewRecorded = false;
  bool _showLikeBurst = false;

  Post get _post => widget.post;

  /// Engagement reflects the post itself; reposts are logged properties on the
  /// original post, not separate rows.
  Map<String, int> get _reactionCounts =>
      normalizeReactionCounts(_post.reactionCounts);
  String? get _userReaction =>
      _post.userReaction == null ? null : toReactionEmoji(_post.userReaction!);
  int get _commentCount => _post.commentCount;
  int get _repostCount => _post.repostCount;
  int get _saveCount => _post.saveCount;
  int get _shareCount => _post.shareCount;
  int get _viewCount => _post.viewCount;

  /// Content always comes from the post itself (no separate repost rows).
  AuthorData get _displayAuthor => _post.authorData;
  String get _displayBody => _post.body;
  List<String> get _displayMediaUrls => _post.mediaUrls;
  List<PostMedia> get _displayMedia => _post.media;
  String get _displayCreatedAt => _post.createdAt;
  Poll? get _displayPoll => _post.poll;
  Map<String, dynamic>? get _displayWorkoutLogData => _post.workoutLogData;
  String? get _displayGymTagName => _post.gymTagName;
  // ignore: unused_element
  bool get _displayCommentsDisabled => _post.commentsDisabled;

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
      objectId: _post.id,
      properties: {'action': action},
    );
  }

  void _doubleTapLike() {
    if (_userReaction == null) {
      widget.onReact?.call(_post.id, '💪');
    }
    setState(() => _showLikeBurst = true);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _showLikeBurst = false);
    });
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
        targetId: _post.id,
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
    final viewerUserId = viewer?.userId ?? ref.read(authProvider).user?.id;
    final workoutRoute = _displayWorkoutLogData?['route'];
    return GestureDetector(
      onDoubleTap: _doubleTapLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              textDirection: ref.watch(handednessProvider)
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_post.isRepostedByMe)
                        RepostIndicator(
                          reposters: _post.reposters,
                          username: 'You',
                          viewerReposted: true,
                          viewerAvatarUrl: viewer?.avatarUrl,
                          viewerDisplayName: viewer?.displayName,
                          viewerUserId: viewerUserId,
                          gymActor: widget.gymActor,
                        ),

                      if (_post.isPinned) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text('📌', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 6),
                              Text(
                                'Pinned post',
                                style: TextStyle(
                                  color: BuddyColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      _buildHeader(context),
                      if (_displayBody.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildBody(context),
                      ],
                      if (_displayMediaUrls.isNotEmpty ||
                          _displayMedia.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        MediaGallery(
                          urls: _displayMediaUrls,
                          media: _displayMedia.isEmpty ? null : _displayMedia,
                          postId: _post.id,
                        ),
                      ],
                      if (_displayPoll != null) ...[
                        const SizedBox(height: 8),
                        PollWidget(
                          poll: _displayPoll!,
                          postId: _post.id,
                          onVote: widget.onPollVote,
                        ),
                      ],
                      if (_displayWorkoutLogData != null) ...[
                        const SizedBox(height: 8),
                        _buildWorkoutLog(context),
                        if (workoutRoute is List &&
                            workoutRoute.length >= 2) ...[
                          const SizedBox(height: 8),
                          _WorkoutRoutePreview(route: workoutRoute),
                        ],
                      ],
                      AiAnalysisCard(analysis: _post.aiAnalysis),
                      if (_displayGymTagName != null) ...[
                        const SizedBox(height: 6),
                        _buildGymTag(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionBar(context, viewer),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showLikeBurst ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _showLikeBurst ? 1 : 0.45,
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 86,
                ),
              ),
            ),
          ),
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
            widget.onProfileTap?.call(_displayAuthor.username);
          },
          child: Avatar(
            src: _displayAuthor.avatarUrl,
            alt: _displayAuthor.displayName,
            size: AvatarSize.md,
            verificationStatus: _displayAuthor.verificationStatus,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _trackPostInteraction('profile');
              widget.onProfileTap?.call(_displayAuthor.username);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _displayAuthor.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BuddyColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_displayAuthor.verificationStatus == 'gym' &&
                        _displayAuthor.isVerified) ...[
                      const SizedBox(width: 5),
                      VerifiedGymBadge(
                        verified: _displayAuthor.isVerified,
                        tier: _displayAuthor.tier,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${_displayAuthor.username}',
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
          _formatTime(_displayCreatedAt),
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
              LucideIcons.eye,
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
        if (_post.authorData.userId != ref.watch(authProvider).user?.id &&
            !_post.authorData.followedByViewer) ...[
          const SizedBox(width: 6),
          _HeaderFollowButton(
            following: _post.authorData.followedByViewer,
            onTap: () =>
                ref.read(feedProvider.notifier).toggleFollowById(_post.id),
          ),
        ],
        Semantics(
          button: true,
          label: 'Post options',
          child: GestureDetector(
            onTap: _openPostMenu,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                LucideIcons.ellipsis,
                color: BuddyColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final mask = ref.watch(profanityFilterProvider);
    return Text(
      mask ? maskProfanity(_displayBody) : _displayBody,
      style: const TextStyle(
        color: BuddyColors.textPrimary,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  /// Web parity: tap the rail heart for 💪, long-press for the full picker.
  void _showReactionPicker(BuildContext context) {
    final current = _userReaction == null
        ? null
        : toReactionEmoji(_userReaction!);
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'React',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final emoji in reactionEmojis)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _trackPostInteraction(
                          current == emoji ? 'unlike' : 'like',
                        );
                        widget.onReact?.call(
                          _post.id,
                          current == emoji ? '' : emoji,
                        );
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: current == emoji
                              ? BuddyColors.green.withValues(alpha: 0.15)
                              : BuddyColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: current == emoji
                                ? BuddyColors.green
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, final viewer) {
    final idle = Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: LucideIcons.heart,
            color: _userReaction != null ? BuddyColors.red : idle,
            label: _formatCount(
              _reactionCounts.values.fold(0, (a, b) => a + b),
            ),
            onTap: () {
              final liked = _userReaction != null;
              _trackPostInteraction(liked ? 'unlike' : 'like');
              widget.onReact?.call(_post.id, liked ? '' : '💪');
            },
            onLongPress: () => _showReactionPicker(context),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: LucideIcons.messageCircle,
            label: _formatCount(_commentCount),
            onTap: () => _handleCommentTap(context),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: LucideIcons.repeat2,
            color: _post.isRepostedByMe ? BuddyColors.green : idle,
            label: _formatCount(_repostCount),
            onTap: () {
              _trackPostInteraction(
                _post.isRepostedByMe ? 'unrepost' : 'repost',
              );
              widget.onRepost?.call(_post.id);
            },
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: LucideIcons.bookmark,
            color: _post.isSaved ? BuddyColors.green : idle,
            label: _formatCount(_saveCount),
            onTap: () {
              _trackPostInteraction(_post.isSaved ? 'unsave' : 'save');
              widget.onSave?.call(_post.id);
            },
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: LucideIcons.share2,
            label: _formatCount(_shareCount),
            onTap: () {
              _trackPostInteraction('share');
              widget.onShare?.call(_post.id);
            },
          ),
        ],
      ),
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
      objectId: _post.id,
    );
    widget.onComment?.call(_post.id);
  }

  Widget _buildWorkoutLog(BuildContext context) {
    final data = _displayWorkoutLogData!;
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
              const Icon(
                LucideIcons.dumbbell,
                color: BuddyColors.green,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                data['exercise'] as String? ?? 'Workout',
                style: const TextStyle(
                  color: BuddyColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (data['sets'] != null || data['reps'] != null)
            Text(
              '${data['sets'] ?? '?'} sets × ${data['reps'] ?? '?'} reps',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          if (data.entries.any(
            (entry) => entry.key != 'exercise' && entry.value != null,
          )) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final entry in data.entries)
                  if (!{'exercise', 'sets', 'reps'}.contains(entry.key) &&
                      entry.value != null)
                    Chip(
                      label: Text('${_metricLabel(entry.key)}: ${entry.value}'),
                      visualDensity: VisualDensity.compact,
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _metricLabel(String key) => switch (key) {
    'duration_minutes' => 'Duration (min)',
    'distance_km' => 'Distance (km)',
    'distance_meters' => 'Distance (m)',
    'calories_burned' => 'Calories',
    'avg_pace' => 'Avg pace',
    'avg_speed_kmh' => 'Avg speed',
    'steps' => 'Steps',
    'weight_kg' => 'Weight (kg)',
    'rounds' => 'Rounds',
    _ => key.replaceAll('_', ' '),
  };

  Widget _buildGymTag() {
    return Row(
      children: [
        const Icon(LucideIcons.dumbbell, size: 14, color: BuddyColors.green),
        const SizedBox(width: 4),
        Text(
          _displayGymTagName!,
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
    // The card's widget input is the authoritative snapshot. Reading a second
    // provider list here can resurrect a stale reaction when a recycled feed
    // row opens its menu.
    final live = post;
    final orig = live.isRepost ? live.originalPostData : null;
    final rawReaction = orig?.userReaction ?? live.userReaction;
    final currentEmoji = rawReaction == null
        ? null
        : toReactionEmoji(rawReaction);
    final isLiked = currentEmoji != null;
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
              icon: LucideIcons.heart,
              iconColor: isLiked ? BuddyColors.red : null,
              label: 'Like',
              subtitle: isLiked ? 'Remove your current reaction' : null,
              onTap: () {
                Navigator.of(context).pop();
                notifier.toggleReactionForRow(
                  rowId: post.id,
                  targetId: targetId,
                  emoji: isLiked ? currentEmoji : '💪',
                );
              },
            ),
            _MenuRow(
              icon: LucideIcons.eyeOff,
              label: 'Not interested',
              subtitle: 'See fewer posts like this',
              onTap: () => _hidePost(context),
            ),
            _MenuRow(
              icon: LucideIcons.flag,
              label: 'Report',
              subtitle: 'Report this post to moderators',
              onTap: () {
                Navigator.of(context).pop();
                onOpenReport();
              },
            ),
            _MenuRow(
              icon: LucideIcons.ban,
              label: 'Block @$username',
              subtitle: 'They won\'t be able to find or contact you',
              onTap: () => _confirmBlock(context, username),
            ),
            _MenuRow(
              icon: LucideIcons.userMinus,
              label: 'Don\'t suggest this creator',
              subtitle: 'Hide all posts from @$username',
              onTap: () => _muteAuthor(context, username),
            ),
            if (onSave != null)
              _MenuRow(
                icon: LucideIcons.bookmark,
                label: live.isSaved ? 'Unsave' : 'Save',
                onTap: () {
                  Navigator.of(context).pop();
                  onSave!(targetId);
                },
              ),
            if (onPin != null)
              _MenuRow(
                icon: LucideIcons.pin,
                label: live.isPinned ? 'Unpin' : 'Pin',
                onTap: () {
                  Navigator.of(context).pop();
                  onPin!(post.id);
                },
              ),
            if (onDelete != null)
              _MenuRow(
                icon: LucideIcons.trash2,
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
            child: const Text(
              'Block',
              style: TextStyle(color: BuddyColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
    final err = await notifier.blockAuthor(username);
    messenger.showSnackBar(
      SnackBar(content: Text(err ?? '@$username blocked.')),
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
          color: destructive ? BuddyColors.red : BuddyColors.textPrimary,
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
  final VoidCallback? onLongPress;

  const _ActionButton({
    required this.icon,
    this.color,
    this.label,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: tint),
          if (label != null && int.tryParse(label!) != 0) ...[
            const SizedBox(height: 2),
            Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tint, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderFollowButton extends StatelessWidget {
  const _HeaderFollowButton({required this.following, required this.onTap});

  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: following
              ? BuddyColors.green.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          following ? 'Following' : 'Follow',
          style: TextStyle(
            color: following
                ? BuddyColors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WorkoutRoutePreview extends StatelessWidget {
  const _WorkoutRoutePreview({required this.route});

  final List route;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _RoutePainter(route, Theme.of(context).colorScheme.primary),
        child: const Center(
          child: Icon(Icons.route, color: Colors.white54, size: 22),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter(this.route, this.color);
  final List route;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = <Offset>[];
    for (final point in route) {
      if (point is! List || point.length < 2) continue;
      final x = double.tryParse('${point[1]}');
      final y = double.tryParse('${point[0]}');
      if (x != null && y != null) values.add(Offset(x, y));
    }
    if (values.length < 2) return;
    final minX = values.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final maxX = values.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final minY = values.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxY = values.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final dx = maxX == minX ? .5 : (values[i].dx - minX) / (maxX - minX);
      final dy = maxY == minY ? .5 : (values[i].dy - minY) / (maxY - minY);
      final point = Offset(dx * size.width, size.height - dy * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.route != route;
}
