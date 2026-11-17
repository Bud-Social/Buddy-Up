import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/gym_engagement.dart';
import '../providers/gym_insights_provider.dart';

/// Open the gym-identity comment sheet for a post.
///
/// Everything inside — reading, writing, liking, replying — happens as the
/// gym via the gym-engagement endpoints, mirroring the web console. The
/// acting member is recorded server-side as the audit trail.
Future<void> showGymCommentSheet(
  BuildContext context, {
  required String slug,
  required String gymName,
  required String postId,
  String? communityId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BuddyColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => GymCommentSheet(
      slug: slug,
      gymName: gymName,
      postId: postId,
      communityId: communityId,
    ),
  );
}

class GymCommentSheet extends ConsumerStatefulWidget {
  final String slug;
  final String gymName;
  final String postId;
  final String? communityId;

  const GymCommentSheet({
    super.key,
    required this.slug,
    required this.gymName,
    required this.postId,
    this.communityId,
  });

  @override
  ConsumerState<GymCommentSheet> createState() => _GymCommentSheetState();
}

enum _CommentSort { newest, oldest, top }

class _CommentRow {
  final String id;
  final String body;
  final String? replyToId;
  final String displayName;
  final String username;
  final String avatarUrl;
  final String? verificationStatus;
  final bool isGym;
  final int likeCount;
  final int replyCount;
  final bool likedByGym;
  final String createdAt;

  const _CommentRow({
    required this.id,
    required this.body,
    this.replyToId,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    this.verificationStatus,
    required this.isGym,
    required this.likeCount,
    required this.replyCount,
    required this.likedByGym,
    required this.createdAt,
  });

  factory _CommentRow.fromJson(Map<String, dynamic> json) {
    final author = (json['author_data'] as Map?) ?? const {};
    final avatar = author['avatar_url'];
    final counts = json['reaction_counts'];
    final likes = counts is Map ? (counts['❤️'] as num?)?.toInt() ?? 0 : 0;
    return _CommentRow(
      id: '${json['id']}',
      body: '${json['body'] ?? ''}',
      replyToId: json['reply_to_id']?.toString(),
      displayName: '${author['display_name'] ?? ''}',
      username: '${author['username'] ?? ''}',
      avatarUrl: avatar is String ? avatar : '',
      verificationStatus: author['verification_status']?.toString(),
      isGym: author['is_gym'] == true,
      likeCount: likes,
      replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
      likedByGym: json['user_reaction'] != null,
      createdAt: '${json['created_at'] ?? ''}',
    );
  }

  _CommentRow copyWith({int? likeCount, bool? likedByGym, int? replyCount}) => _CommentRow(
        id: id,
        body: body,
        replyToId: replyToId,
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
        verificationStatus: verificationStatus,
        isGym: isGym,
        likeCount: likeCount ?? this.likeCount,
        replyCount: replyCount ?? this.replyCount,
        likedByGym: likedByGym ?? this.likedByGym,
        createdAt: createdAt,
      );
}

class _GymCommentSheetState extends ConsumerState<GymCommentSheet> {
  List<_CommentRow>? _comments;
  bool _loading = true;
  bool _error = false;
  bool _submitting = false;
  String? _replyingTo;
  _CommentSort _sort = _CommentSort.newest;

  final _bodyController = TextEditingController();
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final rows = await GymEngagementService.fetchComments(
        ref.read(apiClientProvider4).dio,
        widget.slug,
        postId: widget.postId,
        communityId: widget.communityId,
      );
      if (!mounted) return;
      setState(() {
        _comments = rows.map(_CommentRow.fromJson).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _submit({String? replyToId}) async {
    final controller = replyToId == null ? _bodyController : _replyController;
    final body = controller.text.trim();
    if (body.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await GymEngagementService.addComment(
        ref.read(apiClientProvider4).dio,
        widget.slug,
        postId: widget.postId,
        body: body,
        replyToId: replyToId,
        communityId: widget.communityId,
      );
      controller.clear();
      if (mounted) setState(() => _replyingTo = null);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment failed — try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _toggleLike(_CommentRow comment) async {
    // Optimistic toggle; server truth lands on refresh on failure.
    setState(() {
      _comments = _comments
          ?.map((c) => c.id == comment.id
              ? c.copyWith(
                  likedByGym: !c.likedByGym,
                  likeCount: c.likedByGym ? c.likeCount - 1 : c.likeCount + 1,
                )
              : c)
          .toList();
    });
    try {
      final res = await GymEngagementService.toggleCommentLike(
        ref.read(apiClientProvider4).dio,
        widget.slug,
        postId: widget.postId,
        commentId: comment.id,
        communityId: widget.communityId,
      );
      if (!mounted) return;
      setState(() {
        _comments = _comments
            ?.map((c) => c.id == comment.id
                ? c.copyWith(likedByGym: res.isLiked, likeCount: res.likeCount)
                : c)
            .toList();
      });
    } catch (_) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInset = MediaQuery.of(context).viewInsets.bottom;
    final comments = _sorted(_comments);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInset),
      child: SizedBox(
        height: 560,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 48, height: 5, decoration: BoxDecoration(color: BuddyColors.border, borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  'Comments${_comments != null ? ' (${_comments!.length})' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: BuddyColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: BuddyColors.textSecondary),
                  onPressed: () {
                    // Counts on cards refresh next time the panel reloads.
                    ref.invalidate(gymSavedFeedProvider(widget.slug));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, size: 14, color: BuddyColors.green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Commenting as ${widget.gymName} — the comment appears as the gym',
                      style: const TextStyle(fontSize: 11, color: BuddyColors.green),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  _SortChip(label: 'Newest', active: _sort == _CommentSort.newest, onTap: () => setState(() => _sort = _CommentSort.newest)),
                  const SizedBox(width: 8),
                  _SortChip(label: 'Oldest', active: _sort == _CommentSort.oldest, onTap: () => setState(() => _sort = _CommentSort.oldest)),
                  const SizedBox(width: 8),
                  _SortChip(label: 'Top', active: _sort == _CommentSort.top, onTap: () => setState(() => _sort = _CommentSort.top)),
                ],
              ),
            ),
            Expanded(child: _buildList(comments)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        hintStyle: const TextStyle(color: BuddyColors.textSecondary),
                        filled: true,
                        fillColor: BuddyColors.surfaceRaised,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: BuddyColors.green, width: 1)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _submitting
                      ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: BuddyColors.green)))
                      : IconButton(
                          icon: const Icon(Icons.send, color: BuddyColors.green),
                          onPressed: _submit,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_CommentRow> comments) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: BuddyColors.green));
    }
    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load comments.', style: TextStyle(color: BuddyColors.textSecondary)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (comments.isEmpty) {
      return const Center(
        child: Text('No comments yet. Be the first!', style: TextStyle(color: BuddyColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: comments.length,
      separatorBuilder: (_, _) => const Divider(color: BuddyColors.border, height: 14),
      itemBuilder: (_, i) {
        final c = comments[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(src: c.avatarUrl, alt: c.displayName, size: AvatarSize.sm, verificationStatus: c.verificationStatus),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              c.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: BuddyColors.textPrimary),
                            ),
                          ),
                          if (c.isGym) ...[
                            const SizedBox(width: 6),
                            const _GymChip(),
                          ],
                          const SizedBox(width: 6),
                          if (c.username.isNotEmpty)
                            Text('@${c.username}', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(c.body, style: const TextStyle(fontSize: 13, color: BuddyColors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(_formatDate(c.createdAt), style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                          const SizedBox(width: 14),
                          InkWell(
                            onTap: () => _toggleLike(c),
                            child: Row(
                              children: [
                                Icon(
                                  c.likedByGym ? Icons.favorite : Icons.favorite_border,
                                  size: 15,
                                  color: c.likedByGym ? BuddyColors.green : BuddyColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text('${c.likeCount}', style: TextStyle(fontSize: 11, color: c.likedByGym ? BuddyColors.green : BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          InkWell(
                            onTap: () => setState(() => _replyingTo = _replyingTo == c.id ? null : c.id),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 13, color: BuddyColors.textSecondary),
                                const SizedBox(width: 3),
                                Text('${c.replyCount}', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_replyingTo == c.id)
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        autofocus: true,
                        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Write a reply…',
                          hintStyle: const TextStyle(color: BuddyColors.textSecondary),
                          filled: true,
                          fillColor: BuddyColors.surfaceRaised,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: BuddyColors.green, width: 1)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _submit(replyToId: c.id),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.send, size: 18, color: BuddyColors.green),
                      onPressed: () => _submit(replyToId: c.id),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  List<_CommentRow> _sorted(List<_CommentRow>? list) {
    if (list == null) return const [];
    final sorted = [...list];
    switch (_sort) {
      case _CommentSort.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case _CommentSort.top:
        sorted.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case _CommentSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('MMM d, y').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}

class _GymChip extends StatelessWidget {
  const _GymChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('GYM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: BuddyColors.green, letterSpacing: 0.5)),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? BuddyColors.green : BuddyColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? BuddyColors.black : BuddyColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
