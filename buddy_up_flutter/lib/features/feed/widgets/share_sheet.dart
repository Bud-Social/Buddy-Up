import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/feed_provider.dart';

/// Canonical deep link for a post. Video posts land in the fullscreen
/// player; everything else lands on the post in its feed tab.
String canonicalPostUrl(Post post, {String origin = ''}) {
  final isVideo = post.media.any((m) => m.isVideo) ||
      post.mediaUrls.any((u) {
        final lower = u.toLowerCase();
        return lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.webm');
      });
  if (isVideo) return '$origin/videos?start=${post.id}';
  return '$origin/feed/${post.id}';
}

/// Bottom sheet: copy link, repost, save, open creator profile. Records the
/// share server-side so the share counter stays truthful.
class ShareSheet extends ConsumerWidget {
  final Post post;

  const ShareSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BuddyColors.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share post',
              style: TextStyle(
                color: BuddyColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.link,
              label: 'Copy link',
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: canonicalPostUrl(post)),
                );
                await _recordShare(ref);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showToast(context, 'Link copied', type: ToastType.success);
                }
              },
            ),
            _Row(
              icon: Icons.repeat,
              label: post.isRepostedByMe ? 'Undo repost' : 'Repost',
              trailing: Text(
                '${post.repostCount}',
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(feedProvider.notifier).toggleRepost(post.id);
              },
            ),
            _Row(
              icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              label: post.isSaved ? 'Saved' : 'Save',
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(feedProvider.notifier).toggleSaveById(post.id);
              },
            ),
            _Row(
              icon: Icons.person_outline,
              label: 'View creator profile',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/${post.authorData.username}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordShare(WidgetRef ref) async {
    await ref.read(feedProvider.notifier).recordShareById(post.id);
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: BuddyColors.green),
      title: Text(
        label,
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
