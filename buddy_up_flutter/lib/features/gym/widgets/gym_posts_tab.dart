import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../../feed/widgets/post_card.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/gym_engagement.dart';
import '../providers/gym_posts_provider.dart';
import '../providers/gym_insights_provider.dart';
import 'gym_comment_sheet.dart';
import 'gym_saved_posts_tab.dart';

enum _PostsTab { gymFeed, homeFeed, saved }

/// The gym console's Posts surface — a nested Gym feed / Home feed / Saved
/// trio, mirroring the web console. Both feed panes engage *as the gym*
/// through the gym endpoints; Saved keeps the gym-scoped bookmark.
class GymPostsTab extends ConsumerStatefulWidget {
  final String slug;
  final String gymName;
  const GymPostsTab({super.key, required this.slug, required this.gymName});

  @override
  ConsumerState<GymPostsTab> createState() => _GymPostsTabState();
}

class _GymPostsTabState extends ConsumerState<GymPostsTab> {
  _PostsTab _tab = _PostsTab.gymFeed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SubTab(label: 'Gym feed', active: _tab == _PostsTab.gymFeed, onTap: () => setState(() => _tab = _PostsTab.gymFeed)),
            const SizedBox(width: 8),
            _SubTab(label: 'Home feed', active: _tab == _PostsTab.homeFeed, onTap: () => setState(() => _tab = _PostsTab.homeFeed)),
            const SizedBox(width: 8),
            _SubTab(label: 'Saved', active: _tab == _PostsTab.saved, onTap: () => setState(() => _tab = _PostsTab.saved)),
          ],
        ),
        const SizedBox(height: 10),
        switch (_tab) {
          _PostsTab.gymFeed => _GymFeedPane(slug: widget.slug, gymName: widget.gymName),
          _PostsTab.homeFeed => _HomeFeedPane(slug: widget.slug, gymName: widget.gymName),
          _PostsTab.saved => GymSavedPostsTab(slug: widget.slug, gymName: widget.gymName),
        },
      ],
    );
  }
}

class _SubTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SubTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? BuddyColors.green : BuddyColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? BuddyColors.green : BuddyColors.surfaceRaised),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? BuddyColors.black : BuddyColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Shared gym-engagement wiring for a feed-post card in the gym console.
/// Returns callbacks bound to the post id; the gym reacts as itself.
class _GymFeedActions {
  final WidgetRef ref;
  final BuildContext context;
  final String slug;
  final String gymName;
  final void Function() invalidate;

  const _GymFeedActions({
    required this.ref,
    required this.context,
    required this.slug,
    required this.gymName,
    required this.invalidate,
  });

  void _refresh() {
    invalidate();
  }

  void onLike(String postId) => _react(postId, '💪');
  void onReact(String postId, String reaction) => _react(postId, reaction.isEmpty ? '💪' : reaction);

  Future<void> _react(String postId, String reaction) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.react(dio, slug, postId: postId, reactionType: reaction);
      _refresh();
    } catch (_) {
      _toast('Could not react to that post.');
    }
  }

  Future<void> onRepost(String postId) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.repost(dio, slug, postId: postId);
      _refresh();
    } catch (_) {
      _toast('Could not repost that.');
    }
  }

  Future<void> onSave(String postId) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.toggleSave(dio, slug, postId: postId);
      ref.invalidate(gymSavedFeedProvider(slug));
      _refresh();
    } catch (_) {
      _toast('Could not update saved state.');
    }
  }

  Future<void> onComment(String postId) async {
    await showGymCommentSheet(
      context,
      slug: slug,
      gymName: gymName,
      postId: postId,
    );
    ref.invalidate(gymSavedFeedProvider(slug));
    _refresh();
  }

  void _toast(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GymFeedPane extends ConsumerWidget {
  final String slug;
  final String gymName;
  const _GymFeedPane({required this.slug, required this.gymName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(gymOwnFeedProvider(slug));
    final actions = _GymFeedActions(
      ref: ref,
      context: context,
      slug: slug,
      gymName: gymName,
      invalidate: () => ref.invalidate(gymOwnFeedProvider(slug)),
    );
    return feedAsync.when(
      loading: () => const PageLoader(fullScreen: false),
      error: (_, _) => const RoleNotice(
        message: 'Could not load the gym feed. Check your connection and try again.',
        isError: true,
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const RoleNotice(
            message: 'Nothing on the gym feed yet — post from the home feed with a gym tag and it shows up here.',
          );
        }
        return Column(
          children: [
            for (final post in posts)
              PostCard(
                key: ValueKey('gym:${post.id}'),
                post: post,
                onLike: actions.onLike,
                onReact: actions.onReact,
                onRepost: actions.onRepost,
                onSave: actions.onSave,
                onComment: actions.onComment,
              ),
          ],
        );
      },
    );
  }
}

class _HomeFeedPane extends ConsumerWidget {
  final String slug;
  final String gymName;
  const _HomeFeedPane({required this.slug, required this.gymName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(gymHomeFeedProvider);
    final actions = _GymFeedActions(
      ref: ref,
      context: context,
      slug: slug,
      gymName: gymName,
      invalidate: () => ref.invalidate(gymHomeFeedProvider),
    );
    return feedAsync.when(
      loading: () => const PageLoader(fullScreen: false),
      error: (_, _) => const RoleNotice(
        message: 'Could not load the home feed. Pull to refresh, or try again later.',
        isError: true,
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const RoleNotice(
            message: 'The home feed is empty — create something and share it with your members.',
          );
        }
        return Column(
          children: [
            for (final post in posts)
              PostCard(
                key: ValueKey('home:${post.id}'),
                post: post,
                onLike: actions.onLike,
                onReact: actions.onReact,
                onRepost: actions.onRepost,
                onSave: actions.onSave,
                onComment: actions.onComment,
              ),
          ],
        );
      },
    );
  }
}
