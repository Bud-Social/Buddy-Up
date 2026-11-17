import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../../feed/widgets/post_card.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/gym_engagement.dart';
import '../providers/gym_insights_provider.dart';
import 'gym_comment_sheet.dart';

/// The gym's saved posts — home-feed saves and gym-saved community posts in
/// one list. Engagement here happens as the gym via the gym endpoints,
/// exactly like the web console; unsave is gym-scoped.
class GymSavedPostsTab extends ConsumerWidget {
  final String slug;
  final String gymName;
  const GymSavedPostsTab({super.key, required this.slug, required this.gymName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(gymSavedFeedProvider(slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Saved by this gym'),
        const SizedBox(height: 10),
        savedAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (_, _) => const RoleNotice(
            message: 'Could not load saved posts. Pull to refresh, or try again later.',
            isError: true,
          ),
          data: (saved) {
            if (saved.isEmpty) {
              return const RoleNotice(
                message: 'Nothing saved yet — tap the bookmark on a post from the home feed to keep it here.',
              );
            }
            return Column(
              children: [
                for (final item in saved)
                  PostCard(
                    key: ValueKey('${item.communityId ?? 'feed'}:${item.post.id}'),
                    post: item.post,
                    onSave: (postId) => _toggleGymSave(ref, slug, postId, item.communityId, context),
                    onLike: (postId) => _react(ref, slug, postId, '💪', item.communityId, context),
                    onReact: (postId, reaction) => _react(ref, slug, postId, reaction, item.communityId, context),
                    onRepost: (postId) => _toggleRepost(ref, slug, postId, item.communityId, context),
                    onComment: (postId) => showGymCommentSheet(
                      context,
                      slug: slug,
                      gymName: gymName,
                      postId: postId,
                      communityId: item.communityId,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _toggleGymSave(
    WidgetRef ref,
    String slug,
    String postId,
    String? communityId,
    BuildContext context,
  ) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.toggleSave(dio, slug, postId: postId, communityId: communityId);
      if (!context.mounted) return;
      ref.invalidate(gymSavedFeedProvider(slug));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update saved state.')),
      );
    }
  }

  Future<void> _react(
    WidgetRef ref,
    String slug,
    String postId,
    String reaction,
    String? communityId,
    BuildContext context,
  ) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.react(
        dio,
        slug,
        postId: postId,
        reactionType: reaction.isEmpty ? '💪' : reaction,
        communityId: communityId,
      );
      if (!context.mounted) return;
      ref.invalidate(gymSavedFeedProvider(slug));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not react to that post.')),
      );
    }
  }

  Future<void> _toggleRepost(
    WidgetRef ref,
    String slug,
    String postId,
    String? communityId,
    BuildContext context,
  ) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      await GymEngagementService.repost(dio, slug, postId: postId, communityId: communityId);
      if (!context.mounted) return;
      ref.invalidate(gymSavedFeedProvider(slug));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not repost that.')),
      );
    }
  }
}
