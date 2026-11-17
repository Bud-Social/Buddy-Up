import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../../feed/widgets/post_card.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/gym_insights_provider.dart';

/// The gym's saved posts. Same public card as the home feed; the save
/// toggle here is gym-scoped (`/gyms/<slug>/feed/save/`).
class GymSavedPostsTab extends ConsumerWidget {
  final String slug;
  const GymSavedPostsTab({super.key, required this.slug});

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
          data: (posts) {
            if (posts.isEmpty) {
              return const RoleNotice(
                message: 'Nothing saved yet — tap the bookmark on a post from the home feed to keep it here.',
              );
            }
            return Column(
              children: [
                for (final post in posts)
                  PostCard(
                    post: post,
                    onSave: (postId) => _toggleGymSave(ref, slug, postId, context),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _toggleGymSave(WidgetRef ref, String slug, String postId, BuildContext context) async {
    try {
      final api = ref.read(apiClientProvider4).dio;
      await api.post('/gyms/$slug/feed/save/', data: {'post_id': postId});
      if (!context.mounted) return;
      ref.invalidate(gymSavedFeedProvider(slug));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update saved state.')),
      );
    }
  }
}
