import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emoji_utils.dart';
import '../../../data/models/messaging.dart';
import '../../../data/models/post.dart';
import '../../community/providers/community_provider.dart';
import '../../community/widgets/community_post_card.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';

/// Feed "Communities" tab, mirroring the web `/feed/communities` page:
/// a chip row (All + each joined community) over a community post feed with
/// a per-community ribbon on every card.
class CommunitiesTab extends ConsumerStatefulWidget {
  const CommunitiesTab({super.key});

  @override
  ConsumerState<CommunitiesTab> createState() => _CommunitiesTabState();
}

class _CommunitiesTabState extends ConsumerState<CommunitiesTab> {
  /// null = All communities.
  String? _selectedCommunityId;

  @override
  Widget build(BuildContext context) {
    final communities =
        ref.watch(communitiesListProvider).value?.mine ??
        const <Conversation>[];

    return Column(
      children: [
        _CommunityChipBar(
          communities: communities,
          selectedId: _selectedCommunityId,
          onSelect: (id) => setState(() => _selectedCommunityId = id),
        ),
        Expanded(
          child: _selectedCommunityId == null
              ? const _AllCommunitiesFeed()
              : _CommunityFeedView(
                  key: ValueKey(_selectedCommunityId),
                  communityId: _selectedCommunityId!,
                ),
        ),
      ],
    );
  }
}

class _CommunityChipBar extends StatelessWidget {
  const _CommunityChipBar({
    required this.communities,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Conversation> communities;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _chip(
            context: context,
            label: 'All',
            avatarUrl: null,
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          for (final c in communities)
            _chip(
              context: context,
              label: c.groupName.isEmpty ? 'Community' : c.groupName,
              avatarUrl: c.groupAvatarUrl,
              selected: selectedId == c.id,
              onTap: () => onSelect(c.id),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required BuildContext context,
    required String label,
    required String? avatarUrl,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? BuddyColors.green : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatarUrl != null && avatarUrl.isNotEmpty) ...[
                CircleAvatar(
                  radius: 9,
                  backgroundColor: cs.surface,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 6),
              ] else if (!selected) ...[
                Icon(
                  LucideIcons.users,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? BuddyColors.black : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "All communities" feed — one `/communities/posts/` call, web parity.
class _AllCommunitiesFeed extends ConsumerWidget {
  const _AllCommunitiesFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allCommunityPostsProvider);
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () async =>
          ref.invalidate(allCommunityPostsProvider),
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: PageLoader()),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            ErrorView(
              message: '$error',
              onRetry: () => ref.invalidate(allCommunityPostsProvider),
            ),
          ],
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(
                  LucideIcons.messagesSquare,
                  size: 44,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'No community posts yet.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Join a community or post something to get started.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              return CommunityPostCardWithTag(
                post: entry.post,
                communityName: entry.communityName,
                communityCoverUrl: entry.communityCoverUrl,
                onLike: (_) => _mutate(
                  ref,
                  entry.communityId,
                  () => ref
                      .read(communityRepositoryProvider)
                      .togglePostLike(entry.communityId, entry.post.id),
                ),
                onReact: (_, reaction) => _mutate(
                  ref,
                  entry.communityId,
                  () => ref
                      .read(communityRepositoryProvider)
                      .reactCommunityPost(
                        entry.communityId,
                        entry.post.id,
                        {'reaction_type': _reactionToSend(entry.post, reaction)},
                      ),
                ),
                onRepost: (_) => _mutate(
                  ref,
                  entry.communityId,
                  () => ref
                      .read(communityRepositoryProvider)
                      .repostCommunityPost(
                        entry.communityId,
                        entry.post.id,
                      ),
                ),
                onSave: (_) => _mutate(
                  ref,
                  entry.communityId,
                  () => ref
                      .read(communityRepositoryProvider)
                      .saveCommunityPost(entry.communityId, entry.post.id),
                ),
                onComment: (_) => context.push(
                  '/communities/${entry.communityId}',
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// An empty reaction from PostCard means "remove mine"; the community
  /// endpoint toggles the supplied type, so send the current glyph instead.
  String _reactionToSend(Post post, String reaction) {
    if (reaction.isEmpty) {
      return toReactionEmoji(post.userReaction ?? '');
    }
    return toReactionEmoji(reaction);
  }

  Future<void> _mutate(
    WidgetRef ref,
    String communityId,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      // Leave the card as-is; a failed engagement is not worth a dialog.
    }
    ref.invalidate(allCommunityPostsProvider);
    // The selected-community view reads its own provider; keep it in sync too.
    ref.invalidate(communityFeedProvider(communityId));
  }
}

/// Single-community feed, used when a chip is selected.
class _CommunityFeedView extends ConsumerStatefulWidget {
  const _CommunityFeedView({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<_CommunityFeedView> createState() => _CommunityFeedViewState();
}

class _CommunityFeedViewState extends ConsumerState<_CommunityFeedView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(communityFeedProvider(widget.communityId).notifier)
          .loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(communityFeedProvider(widget.communityId));
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () async => ref
          .read(communityFeedProvider(widget.communityId).notifier)
          .loadPosts(),
      child: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: PageLoader()),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            ErrorView(
              message: '$error',
              onRetry: () => ref
                  .read(communityFeedProvider(widget.communityId).notifier)
                  .loadPosts(),
            ),
          ],
        ),
        data: (state) {
          final posts = state.posts;
          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Icon(
                  LucideIcons.messagesSquare,
                  size: 44,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'No posts in this community yet.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }
          final name = state.detail?.groupName ?? '';
          final cover = state.detail?.coverUrl;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            itemCount: posts.length,
            itemBuilder: (_, i) {
              final p = posts[i];
              return CommunityPostCardWithTag(
                post: p.toPost(),
                communityName: name,
                communityCoverUrl: cover,
                onLike: (_) => ref
                    .read(communityFeedProvider(widget.communityId).notifier)
                    .toggleLike(p.id),
                onReact: (_, reaction) => ref
                    .read(communityFeedProvider(widget.communityId).notifier)
                    .react(p.id, _reactionToSend(p.toPost(), reaction)),
                onRepost: (_) => ref
                    .read(communityFeedProvider(widget.communityId).notifier)
                    .repost(p.id),
                onSave: (_) => ref
                    .read(communityFeedProvider(widget.communityId).notifier)
                    .save(p.id),
                onComment: (_) => context.push(
                  '/communities/${widget.communityId}',
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _reactionToSend(Post post, String reaction) {
    if (reaction.isEmpty) {
      return toReactionEmoji(post.userReaction ?? '');
    }
    return toReactionEmoji(reaction);
  }
}
